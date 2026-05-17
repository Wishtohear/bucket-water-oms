package com.bucketwater.oms.module.payment.service;

import com.bucketwater.oms.common.exception.BusinessException;
import com.bucketwater.oms.common.response.ResultCode;
import com.bucketwater.oms.module.payment.dto.RechargeRequest;
import com.bucketwater.oms.module.payment.dto.WechatPayRequest;
import com.bucketwater.oms.module.payment.dto.WechatPayResponse;
import com.bucketwater.oms.module.payment.entity.RechargeRecord;
import com.bucketwater.oms.module.payment.mapper.RechargeRecordMapper;
import com.bucketwater.oms.module.station.entity.Station;
import com.bucketwater.oms.module.station.entity.StationAccount;
import com.bucketwater.oms.module.station.mapper.StationAccountMapper;
import com.bucketwater.oms.module.station.mapper.StationMapper;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.hc.client5.http.classic.methods.HttpPost;
import org.apache.hc.client5.http.impl.classic.CloseableHttpClient;
import org.apache.hc.client5.http.impl.classic.CloseableHttpResponse;
import org.apache.hc.client5.http.impl.classic.HttpClients;
import org.apache.hc.core5.http.ContentType;
import org.apache.hc.core5.http.io.entity.EntityUtils;
import org.apache.hc.core5.http.io.entity.StringEntity;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

@Service
public class WechatPayService {

    private static final Logger log = LoggerFactory.getLogger(WechatPayService.class);
    private static final String UNIFIED_ORDER_URL = "https://api.mch.weixin.qq.com/pay/unifiedorder";
    private static final DateTimeFormatter DATE_TIME_FORMATTER = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");

    @Value("${wechat.appid:your-appid}")
    private String appId;

    @Value("${wechat.mchid:your-mchid}")
    private String mchId;

    @Value("${wechat.apikey:your-apikey}")
    private String apiKey;

    @Value("${wechat.notify-url:https://api.example.com/payment/wechat-notify}")
    private String notifyUrl;

    @Value("${wechat.enabled:false}")
    private boolean wechatPayEnabled;

    @Autowired
    private StationAccountMapper stationAccountMapper;

    @Autowired
    private StationMapper stationMapper;

    @Autowired
    private RechargeRecordMapper rechargeRecordMapper;

    @Autowired
    private ObjectMapper objectMapper;

    public WechatPayResponse createPrepay(String stationId, BigDecimal amount, String payType) {
        log.info("创建微信预支付订单，水站:{}, 金额:{}, 类型:{}", stationId, amount, payType);

        if (!wechatPayEnabled) {
            log.warn("微信支付未启用，返回模拟prepay_id");
            return createMockPrepay();
        }

        try {
            String outTradeNo = generateOutTradeNo();
            RechargeRecord record = createRechargeRecord(stationId, amount, outTradeNo);

            Map<String, String> params = buildUnifiedOrderParams(stationId, amount, outTradeNo);
            String xmlParams = mapToXml(params);

            String response = sendUnifiedOrderRequest(xmlParams);
            Map<String, String> responseMap = xmlToMap(response);

            if ("SUCCESS".equals(responseMap.get("return_code")) && "SUCCESS".equals(responseMap.get("result_code"))) {
                String prepayId = responseMap.get("prepay_id");
                log.info("微信统一下单成功，prepay_id:{}", prepayId);

                record.setPrepayId(prepayId);
                rechargeRecordMapper.insert(record);

                return buildWechatPayResponse(prepayId);
            } else {
                String errCode = responseMap.get("err_code");
                String errCodeDes = responseMap.get("err_code_des");
                log.error("微信统一下单失败，err_code:{}, err_code_des:{}", errCode, errCodeDes);
                throw new BusinessException(ResultCode.BUSINESS_ERROR, "微信支付下单失败: " + errCodeDes);
            }
        } catch (BusinessException e) {
            throw e;
        } catch (Exception e) {
            log.error("创建微信预支付订单异常", e);
            throw new BusinessException(ResultCode.BUSINESS_ERROR, "创建预支付订单失败: " + e.getMessage());
        }
    }

    @Transactional
    public void handlePaymentNotify(String prepayId, String transactionId, BigDecimal totalAmount) {
        log.info("处理微信支付回调，prepayId:{}, transactionId:{}, amount:{}", prepayId, transactionId, totalAmount);

        RechargeRecord record = rechargeRecordMapper.selectOne(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<RechargeRecord>()
                .eq(RechargeRecord::getPrepayId, prepayId)
        );

        if (record == null) {
            log.warn("未找到对应的充值记录，prepayId:{}", prepayId);
            return;
        }

        if ("success".equals(record.getStatus())) {
            log.info("该充值记录已处理过，prepayId:{}", prepayId);
            return;
        }

        recharge(String.valueOf(record.getStationId()), totalAmount);

        record.setStatus("success");
        record.setTransactionId(transactionId);
        record.setPayTime(LocalDateTime.now());
        record.setUpdateTime(LocalDateTime.now());
        rechargeRecordMapper.updateById(record);

        log.info("充值成功，水站:{}, 金额:{}", record.getStationId(), totalAmount);
    }

    @Transactional
    public void recharge(String stationId, BigDecimal amount) {
        Long stationIdLong = Long.parseLong(stationId);
        StationAccount account = stationAccountMapper.selectOne(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<StationAccount>()
                .eq(StationAccount::getStationId, stationIdLong)
        );

        if (account == null) {
            throw new RuntimeException("水站账户不存在");
        }

        BigDecimal newBalance = account.getDepositBalance().add(amount);
        account.setDepositBalance(newBalance);
        account.setUpdatedAt(LocalDateTime.now());
        stationAccountMapper.updateById(account);

        log.info("水站{}充值成功，金额:{}, 新余额:{}", stationId, amount, newBalance);
    }

    @Transactional
    public void rechargeByRecordId(Long recordId, BigDecimal amount) {
        RechargeRecord record = rechargeRecordMapper.selectById(recordId);
        if (record == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "充值记录不存在");
        }

        recharge(String.valueOf(record.getStationId()), amount);
    }

    @Transactional
    public void payBucketDeposit(String stationId, Integer bucketNum, BigDecimal amount) {
        StationAccount account = stationAccountMapper.selectOne(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<StationAccount>()
                .eq(StationAccount::getStationId, Long.parseLong(stationId))
        );

        if (account == null) {
            throw new RuntimeException("水站账户不存在");
        }

        account.setDepositBalance(account.getDepositBalance().subtract(amount));
        account.setOwedBucketNum(account.getOwedBucketNum() - bucketNum);
        account.setUpdatedAt(LocalDateTime.now());
        stationAccountMapper.updateById(account);

        log.info("水站{}补缴押金成功，桶数:{}, 金额:{}", stationId, bucketNum, amount);
    }

    public boolean verifySignature(WechatPayRequest request) {
        if (!wechatPayEnabled) {
            log.warn("微信支付未启用，跳过签名验证");
            return true;
        }

        try {
            Map<String, String> params = new TreeMap<>();
            params.put("return_code", request.getReturnCode() != null ? request.getReturnCode() : "");
            params.put("return_msg", request.getReturnMsg() != null ? request.getReturnMsg() : "");
            params.put("appid", request.getAppId() != null ? request.getAppId() : "");
            params.put("mch_id", request.getMchId() != null ? request.getMchId() : "");
            params.put("device_info", request.getDeviceInfo() != null ? request.getDeviceInfo() : "");
            params.put("nonce_str", request.getNonceStr() != null ? request.getNonceStr() : "");
            params.put("result_code", request.getResultCode() != null ? request.getResultCode() : "");
            params.put("err_code", request.getErrCode() != null ? request.getErrCode() : "");
            params.put("err_code_des", request.getErrCodeDes() != null ? request.getErrCodeDes() : "");
            params.put("trade_type", request.getTradeType() != null ? request.getTradeType() : "");
            params.put("prepay_id", request.getPrepayId() != null ? request.getPrepayId() : "");
            params.put("transaction_id", request.getTransactionId() != null ? request.getTransactionId() : "");
            params.put("out_trade_no", request.getOutTradeNo() != null ? request.getOutTradeNo() : "");
            params.put("time_end", request.getTimeEnd() != null ? request.getTimeEnd() : "");
            params.put("total_fee", request.getTotalFee() != null ? request.getTotalFee() : "");
            params.put("cash_fee", request.getCashFee() != null ? request.getCashFee() : "");
            params.put("fee_type", request.getFeeType() != null ? request.getFeeType() : "");
            params.put("bank_type", request.getBankType() != null ? request.getBankType() : "");

            params.remove("sign");
            String sign = generateSign(params);

            boolean verified = sign.equals(request.getSign());
            if (!verified) {
                log.warn("微信支付签名验证失败，计算签名:{}, 传入签名:{}", sign, request.getSign());
            }
            return verified;
        } catch (Exception e) {
            log.error("签名验证异常", e);
            return false;
        }
    }

    public RechargeRecord createRechargeRecord(String stationId, BigDecimal amount, String outTradeNo) {
        Station station = stationMapper.selectById(Long.parseLong(stationId));
        if (station == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "水站不存在");
        }

        StationAccount account = stationAccountMapper.selectOne(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<StationAccount>()
                .eq(StationAccount::getStationId, Long.parseLong(stationId))
        );

        BigDecimal balanceAfter = account != null ? account.getDepositBalance().add(amount) : amount;

        RechargeRecord record = new RechargeRecord();
        record.setStationId(Long.parseLong(stationId));
        record.setStationName(station.getName());
        record.setAmount(amount);
        record.setBalanceAfter(balanceAfter);
        record.setPayType("wechat");
        record.setStatus("pending");
        record.setWechatOrderNo(outTradeNo);
        record.setCreateTime(LocalDateTime.now());
        record.setUpdateTime(LocalDateTime.now());
        record.setExpireTime(LocalDateTime.now().plusMinutes(30));

        rechargeRecordMapper.insert(record);
        log.info("创建充值记录成功，ID:{}, 水站:{}, 金额:{}", record.getId(), stationId, amount);

        return record;
    }

    private Map<String, String> buildUnifiedOrderParams(String stationId, BigDecimal amount, String outTradeNo) {
        Map<String, String> params = new TreeMap<>();
        params.put("appid", appId);
        params.put("mch_id", mchId);
        params.put("nonce_str", generateNonceStr());
        params.put("body", "水站账户充值-" + stationId);
        params.put("out_trade_no", outTradeNo);
        params.put("total_fee", String.valueOf(amount.multiply(new BigDecimal("100")).intValue()));
        params.put("spbill_create_ip", "127.0.0.1");
        params.put("notify_url", notifyUrl);
        params.put("trade_type", "NATIVE");
        params.put("attach", stationId);

        String sign = generateSign(params);
        params.put("sign", sign);

        return params;
    }

    private String sendUnifiedOrderRequest(String xmlParams) throws Exception {
        try (CloseableHttpClient httpClient = HttpClients.createDefault()) {
            HttpPost httpPost = new HttpPost(UNIFIED_ORDER_URL);
            httpPost.setHeader("Content-Type", "text/xml;charset=UTF-8");
            httpPost.setEntity(new StringEntity(xmlParams, ContentType.create("text/xml", StandardCharsets.UTF_8)));

            try (CloseableHttpResponse response = httpClient.execute(httpPost)) {
                return EntityUtils.toString(response.getEntity(), StandardCharsets.UTF_8);
            }
        }
    }

    private WechatPayResponse buildWechatPayResponse(String prepayId) {
        String nonceStr = generateNonceStr();
        String timestamp = String.valueOf(System.currentTimeMillis() / 1000);

        Map<String, String> params = new TreeMap<>();
        params.put("appId", appId);
        params.put("nonceStr", nonceStr);
        params.put("package", "prepay_id=" + prepayId);
        params.put("signType", "MD5");
        params.put("timeStamp", timestamp);
        String sign = generateSign(params);

        return new WechatPayResponse(prepayId, nonceStr, timestamp, sign);
    }

    private WechatPayResponse createMockPrepay() {
        String prepayId = "wx" + System.currentTimeMillis() + UUID.randomUUID().toString().substring(0, 16);
        String nonceStr = generateNonceStr();
        String timestamp = String.valueOf(System.currentTimeMillis() / 1000);

        return new WechatPayResponse(prepayId, nonceStr, timestamp, "mock_signature");
    }

    private String generateSign(Map<String, String> params) {
        StringBuilder sb = new StringBuilder();
        for (Map.Entry<String, String> entry : params.entrySet()) {
            if (entry.getValue() != null && !entry.getValue().isEmpty()) {
                sb.append(entry.getKey()).append("=").append(entry.getValue()).append("&");
            }
        }
        sb.append("key=").append(apiKey);

        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            byte[] bytes = md.digest(sb.toString().getBytes(StandardCharsets.UTF_8));
            StringBuilder hexString = new StringBuilder();
            for (byte b : bytes) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) {
                    hexString.append("0");
                }
                hexString.append(hex);
            }
            return hexString.toString().toUpperCase();
        } catch (Exception e) {
            throw new RuntimeException("签名生成失败", e);
        }
    }

    private String generateNonceStr() {
        return UUID.randomUUID().toString().replace("-", "");
    }

    private String generateOutTradeNo() {
        return "R" + LocalDateTime.now().format(DATE_TIME_FORMATTER) + String.format("%06d", new Random().nextInt(999999));
    }

    private String mapToXml(Map<String, String> params) {
        StringBuilder sb = new StringBuilder("<xml>");
        for (Map.Entry<String, String> entry : params.entrySet()) {
            sb.append("<").append(entry.getKey()).append(">");
            sb.append("<![CDATA[").append(entry.getValue()).append("]]>");
            sb.append("</").append(entry.getKey()).append(">");
        }
        sb.append("</xml>");
        return sb.toString();
    }

    private Map<String, String> xmlToMap(String xml) {
        Map<String, String> result = new HashMap<>();
        try {
            xml = xml.trim();
            xml = xml.replaceAll("</?xml[^>]*>", "");
            String[] pairs = xml.split("<");

            for (String pair : pairs) {
                if (pair.contains(">")) {
                    int idx = pair.indexOf(">");
                    String key = pair.substring(0, idx).trim();
                    String value = pair.substring(idx + 1).replaceAll("]]>", "").trim();
                    if (!key.isEmpty()) {
                        result.put(key, value);
                    }
                }
            }
        } catch (Exception e) {
            log.error("XML解析失败", e);
        }
        return result;
    }
}
