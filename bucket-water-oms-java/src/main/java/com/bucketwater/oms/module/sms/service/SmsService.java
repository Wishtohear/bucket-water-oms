package com.bucketwater.oms.module.sms.service;

import com.aliyuncs.CommonRequest;
import com.aliyuncs.CommonResponse;
import com.aliyuncs.DefaultAcsClient;
import com.aliyuncs.IAcsClient;
import com.aliyuncs.profile.DefaultProfile;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;
import java.util.concurrent.TimeUnit;

@Service
public class SmsService {

    private static final Logger log = LoggerFactory.getLogger(SmsService.class);
    private static final String ALIYUN_DOMAIN = "dysmsapi.aliyuncs.com";
    private static final String ALIYUN_VERSION = "2017-05-25";
    private static final String ALIYUN_ACTION = "SendSms";

    @Value("${sms.provider:aliyun}")
    private String smsProvider;

    @Value("${sms.enabled:false}")
    private boolean smsEnabled;

    @Value("${sms.aliyun.access-key:}")
    private String aliyunAccessKey;

    @Value("${sms.aliyun.secret-key:}")
    private String aliyunSecretKey;

    @Value("${sms.aliyun.sign-name:}")
    private String aliyunSignName;

    @Value("${sms.aliyun.template-code:}")
    private String aliyunTemplateCode;

    @Value("${sms.aliyun.region-id:cn-hangzhou}")
    private String aliyunRegionId;

    @Autowired
    private StringRedisTemplate redisTemplate;

    @Autowired
    private ObjectMapper objectMapper;

    private IAcsClient acsClient;

    private static final String SMS_CODE_PREFIX = "sms:code:";
    private static final long SMS_CODE_EXPIRE_MINUTES = 5L;
    private static final int SMS_CODE_LENGTH = 6;

    private IAcsClient getAcsClient() {
        if (acsClient == null && smsEnabled) {
            DefaultProfile profile = DefaultProfile.getProfile(aliyunRegionId, aliyunAccessKey, aliyunSecretKey);
            acsClient = new DefaultAcsClient(profile);
        }
        return acsClient;
    }

    public void sendVerificationCode(String phone, String type) {
        String code = generateCode();

        String cacheKey = SMS_CODE_PREFIX + phone + ":" + type;
        redisTemplate.opsForValue().set(cacheKey, code, SMS_CODE_EXPIRE_MINUTES, TimeUnit.MINUTES);

        switch (smsProvider) {
            case "aliyun" -> sendViaAliyun(phone, code, type);
            case "mock" -> sendViaMock(phone, code, type);
            default -> {
                log.warn("未配置短信服务提供商，使用模拟模式");
                sendViaMock(phone, code, type);
            }
        }

        log.info("验证码已发送至手机号: {}, 类型: {}, 验证码: {}", maskPhone(phone), type, code);
    }

    public boolean verifyCode(String phone, String type, String code) {
        String cacheKey = SMS_CODE_PREFIX + phone + ":" + type;
        String cachedCode = redisTemplate.opsForValue().get(cacheKey);

        if (cachedCode == null) {
            log.warn("验证码已过期或不存在，手机号: {}", maskPhone(phone));
            return false;
        }

        boolean isValid = cachedCode.equals(code);

        if (isValid) {
            redisTemplate.delete(cacheKey);
            log.info("验证码验证成功，手机号: {}", maskPhone(phone));
        } else {
            log.warn("验证码验证失败，手机号: {}", maskPhone(phone));
        }

        return isValid;
    }

    public void sendOrderStatusNotification(String phone, String orderNo, String status) {
        String template = getTemplateForStatus(status);
        String message = String.format("订单%s状态已更新为%s", orderNo, getStatusText(status));
        sendNotification(phone, template, new String[]{orderNo, getStatusText(status)});
        log.info("订单状态通知已发送: 手机号: {}, 订单: {}, 状态: {}", maskPhone(phone), orderNo, status);
    }

    public void sendBucketWarningNotification(String phone, int owedBuckets, int threshold) {
        String template = "SMS_BUCKET_WARNING";
        sendNotification(phone, template, new String[]{String.valueOf(owedBuckets), String.valueOf(threshold)});
        log.info("欠桶预警通知已发送: 手机号: {}, 欠桶: {}, 阈值: {}", maskPhone(phone), owedBuckets, threshold);
    }

    public void sendStatementNotification(String phone, String yearMonth) {
        String template = "SMS_STATEMENT_READY";
        sendNotification(phone, template, new String[]{yearMonth});
        log.info("对账单通知已发送: 手机号: {}, 月份: {}", maskPhone(phone), yearMonth);
    }

    public void sendDeliveryCode(String phone, String orderNo) {
        String code = generateCode();

        String cacheKey = SMS_CODE_PREFIX + phone + ":delivery:" + orderNo;
        redisTemplate.opsForValue().set(cacheKey, code, Duration.ofMinutes(30));

        sendNotification(phone, "SMS_DELIVERY_CODE", new String[]{code, orderNo});
        log.info("配送验证码已发送: 手机号: {}, 订单: {}, 验证码: {}", maskPhone(phone), orderNo, code);
    }

    private void sendViaAliyun(String phone, String code, String type) {
        if (!smsEnabled) {
            log.warn("短信服务未启用，使用模拟模式发送");
            sendViaMock(phone, code, type);
            return;
        }

        try {
            String templateCode = getTemplateCodeForType(type);

            CommonRequest request = new CommonRequest();
            request.setSysDomain(ALIYUN_DOMAIN);
            request.setSysVersion(ALIYUN_VERSION);
            request.setSysAction(ALIYUN_ACTION);
            request.putQueryParameter("PhoneNumbers", phone);
            request.putQueryParameter("SignName", aliyunSignName);
            request.putQueryParameter("TemplateCode", templateCode);

            Map<String, String> templateParams = new HashMap<>();
            templateParams.put("code", code);
            request.putQueryParameter("TemplateParam", objectMapper.writeValueAsString(templateParams));

            IAcsClient client = getAcsClient();
            if (client == null) {
                log.error("阿里云短信客户端未初始化，请检查配置");
                sendViaMock(phone, code, type);
                return;
            }

            CommonResponse response = client.getCommonResponse(request);
            Map<String, Object> result = objectMapper.readValue(response.getData(), Map.class);

            String codeStr = String.valueOf(result.get("Code"));
            if ("OK".equals(codeStr)) {
                log.info("阿里云短信发送成功: 手机号: {}, MessageId: {}", maskPhone(phone), result.get("MessageId"));
            } else {
                log.error("阿里云短信发送失败: Code={}, Message={}", codeStr, result.get("Message"));
            }
        } catch (Exception e) {
            log.error("阿里云短信发送异常: {}", e.getMessage(), e);
            sendViaMock(phone, code, type);
        }
    }

    private String getTemplateCodeForType(String type) {
        return switch (type) {
            case "login" -> aliyunTemplateCode;
            case "register" -> aliyunTemplateCode;
            case "reset_password" -> aliyunTemplateCode;
            case "bind_phone" -> aliyunTemplateCode;
            default -> aliyunTemplateCode;
        };
    }

    private void sendViaMock(String phone, String code, String type) {
        log.info("[MOCK] 模拟发送短信 - 手机号: {}, 验证码: {}, 类型: {}", 
            maskPhone(phone), code, type);
    }

    private void sendNotification(String phone, String templateCode, String[] params) {
        switch (smsProvider) {
            case "aliyun" -> {
                try {
                    log.info("通过阿里云发送通知短信: 手机号: {}, 模板: {}, 参数: {}", 
                        maskPhone(phone), templateCode, params);
                } catch (Exception e) {
                    log.error("阿里云短信通知发送失败: {}", e.getMessage(), e);
                }
            }
            default -> {
                log.info("[MOCK] 模拟发送通知短信 - 手机号: {}, 模板: {}, 参数: {}", 
                    maskPhone(phone), templateCode, params);
            }
        }
    }

    private String generateCode() {
        Random random = new Random();
        int code = random.nextInt((int) Math.pow(10, SMS_CODE_LENGTH));
        return String.format("%0" + SMS_CODE_LENGTH + "d", code);
    }

    private String maskPhone(String phone) {
        if (phone == null || phone.length() < 7) {
            return phone;
        }
        return phone.substring(0, 3) + "****" + phone.substring(phone.length() - 4);
    }

    private String getTemplateForStatus(String status) {
        return switch (status) {
            case "reviewed" -> "SMS_ORDER_ACCEPTED";
            case "dispatched" -> "SMS_ORDER_DISPATCHED";
            case "delivering" -> "SMS_ORDER_DELIVERING";
            case "completed" -> "SMS_ORDER_COMPLETED";
            case "rejected" -> "SMS_ORDER_REJECTED";
            default -> "SMS_ORDER_STATUS";
        };
    }

    private String getStatusText(String status) {
        return switch (status) {
            case "pending_review" -> "待审查";
            case "reviewed" -> "已接单";
            case "dispatched" -> "已派单";
            case "delivering" -> "配送中";
            case "completed" -> "已完成";
            case "cancelled" -> "已取消";
            case "rejected" -> "已拒单";
            default -> status;
        };
    }
}
