package com.bucketwater.oms.module.auth.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.bucketwater.oms.common.enums.UserRole;
import com.bucketwater.oms.common.exception.BusinessException;
import com.bucketwater.oms.common.response.ResultCode;
import com.bucketwater.oms.module.auth.dto.LoginRequest;
import com.bucketwater.oms.module.auth.dto.LoginResponse;
import com.bucketwater.oms.module.auth.dto.SmsCodeRequest;
import com.bucketwater.oms.module.station.entity.Station;
import com.bucketwater.oms.module.station.mapper.StationMapper;
import com.bucketwater.oms.module.user.entity.User;
import com.bucketwater.oms.module.user.mapper.UserMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Arrays;

import java.time.LocalDateTime;
import java.util.concurrent.TimeUnit;

@Service
public class AuthService {

    private static final Logger log = LoggerFactory.getLogger(AuthService.class);

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private UserService userService;

    @Autowired
    private StringRedisTemplate redisTemplate;

    @Autowired(required = false)
    private StationMapper stationMapper;

    private static final String SMS_CODE_PREFIX = "sms:code:";
    private static final Long SMS_CODE_EXPIRE_MINUTES = 5L;

    private BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    @Transactional
    public LoginResponse login(LoginRequest request) {
        log.info("用户登录请求: phone={}, role={}", request.getPhone(), request.getRole());

        String role = request.getRole();
        String dbRole = convertFrontendRoleToDbRole(role);
        convertToUserRole(role);
        log.info("角色验证通过: {}, 数据库角色值: {}", role, dbRole);

        LambdaQueryWrapper<User> queryWrapper = new LambdaQueryWrapper<User>()
            .eq(User::getPhone, request.getPhone())
            .eq(User::getStatus, "active");
        
        String[] possibleRoles = getPossibleDbRoles(role);
        if (possibleRoles.length == 1) {
            queryWrapper.eq(User::getRole, possibleRoles[0]);
        } else {
            queryWrapper.and(wrapper -> {
                for (int i = 0; i < possibleRoles.length; i++) {
                    if (i == 0) {
                        wrapper.eq(User::getRole, possibleRoles[i]);
                    } else {
                        wrapper.or().eq(User::getRole, possibleRoles[i]);
                    }
                }
            });
        }
        
        User user = userMapper.selectOne(queryWrapper);

        if (user == null) {
            log.warn("用户不存在或未激活: phone={}, role={}, dbRoles={}", request.getPhone(), request.getRole(), Arrays.toString(possibleRoles));
            throw new BusinessException(ResultCode.USER_NOT_FOUND);
        }

        log.debug("查询到的用户: id={}, name={}, phone={}, role={}, warehouseId={}", 
            user.getId(), user.getName(), user.getPhone(), user.getRole(), user.getWarehouseId());

        if (!userService.validatePassword(request.getPassword(), user.getPassword())) {
            log.warn("密码错误: phone={}", request.getPhone());
            throw new BusinessException(ResultCode.PASSWORD_ERROR);
        }

        if (user.getId() == null) {
            log.error("用户ID为空，这是严重的数据映射问题！phone={}", request.getPhone());
            throw new BusinessException(ResultCode.SYSTEM_ERROR, "用户数据异常，请联系管理员");
        }

        Long stationId = user.getStationId();
        if (stationId == null && stationMapper != null && "station".equalsIgnoreCase(role)) {
            Station station = stationMapper.selectOne(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Station>()
                    .eq(Station::getPhone, request.getPhone())
                    .last("LIMIT 1")
            );
            if (station != null) {
                stationId = station.getId();
                user.setStationId(stationId);
                userMapper.updateById(user);
                log.info("自动补充水站ID: stationId={}", stationId);
            }
        }

        log.info("用户登录成功: id={}, name={}, stationId={}", user.getId(), user.getName(), stationId);

        String accessToken = userService.generateToken(user);
        String refreshToken = userService.generateRefreshToken(user);

        user.setLastLoginTime(LocalDateTime.now());
        userMapper.updateById(user);

        return new LoginResponse(
            accessToken,
            refreshToken,
            7200L,
            new LoginResponse.UserInfo(
                user.getId().toString(),
                user.getName(),
                user.getRole(),
                user.getPhone(),
                null,
                stationId != null ? stationId.toString() : null,
                user.getWarehouseId() != null ? user.getWarehouseId().toString() : null,
                user.getDriverId() != null ? user.getDriverId().toString() : null
            )
        );
    }

    private UserRole convertToUserRole(String role) {
        return switch (role) {
            case "station" -> UserRole.STATION_OWNER;
            case "driver" -> UserRole.DRIVER;
            case "warehouse" -> UserRole.WAREHOUSE_ADMIN;
            case "admin" -> UserRole.FACTORY_ADMIN;
            case "clerk" -> UserRole.STATION_CLERK;
            case "staff" -> UserRole.STATION_CLERK;
            case "platform" -> UserRole.PLATFORM_ADMIN;
            default -> throw new BusinessException(ResultCode.PARAM_INVALID, "无效的角色: " + role);
        };
    }

    private String convertFrontendRoleToDbRole(String role) {
        return switch (role) {
            case "station" -> "STATION_OWNER";
            case "driver" -> "DRIVER";
            case "warehouse" -> "WAREHOUSE_ADMIN";
            case "admin" -> "FACTORY_ADMIN";
            case "clerk", "staff" -> "STATION_CLERK";
            case "platform" -> "PLATFORM_ADMIN";
            default -> role;
        };
    }

    private String[] getPossibleDbRoles(String role) {
        return switch (role) {
            case "admin" -> new String[]{"FACTORY_ADMIN", "admin"};
            case "station" -> new String[]{"STATION_OWNER", "station"};
            case "warehouse" -> new String[]{"WAREHOUSE_ADMIN", "warehouse"};
            case "driver" -> new String[]{"DRIVER", "driver"};
            case "clerk", "staff" -> new String[]{"STATION_CLERK", "clerk", "staff"};
            case "platform" -> new String[]{"PLATFORM_ADMIN", "platform"};
            default -> new String[]{role};
        };
    }

    public LoginResponse refreshToken(String refreshToken) {
        log.info("刷新Token请求");

        User user = userService.validateRefreshToken(refreshToken);
        if (user == null) {
            log.warn("无效的RefreshToken");
            throw new BusinessException(ResultCode.TOKEN_INVALID);
        }

        if (user.getId() == null) {
            log.error("用户ID为空，Token刷新失败");
            throw new BusinessException(ResultCode.SYSTEM_ERROR, "用户数据异常");
        }

        Long stationId = user.getStationId();
        if (stationId == null && stationMapper != null && user.getRole() != null && "station".equalsIgnoreCase(user.getRole())) {
            Station station = stationMapper.selectOne(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Station>()
                    .eq(Station::getPhone, user.getPhone())
                    .last("LIMIT 1")
            );
            if (station != null) {
                stationId = station.getId();
                user.setStationId(stationId);
                userMapper.updateById(user);
                log.info("自动补充水站ID: stationId={}", stationId);
            }
        }

        log.info("Token刷新成功: userId={}, stationId={}", user.getId(), stationId);

        String newAccessToken = userService.generateToken(user);
        String newRefreshToken = userService.generateRefreshToken(user);

        return new LoginResponse(
            newAccessToken,
            newRefreshToken,
            7200L,
            new LoginResponse.UserInfo(
                user.getId().toString(),
                user.getName(),
                user.getRole(),
                user.getPhone(),
                null,
                stationId != null ? stationId.toString() : null,
                user.getWarehouseId() != null ? user.getWarehouseId().toString() : null,
                user.getDriverId() != null ? user.getDriverId().toString() : null
            )
        );
    }

    public void sendSmsCode(SmsCodeRequest request) {
        String code = String.format("%06d", (int) (Math.random() * 1000000));
        String key = SMS_CODE_PREFIX + request.getPhone() + ":" + request.getType();
        redisTemplate.opsForValue().set(key, code, SMS_CODE_EXPIRE_MINUTES, TimeUnit.MINUTES);
        log.info("发送验证码: phone={}, code={}", request.getPhone(), code);
    }

    public boolean verifySmsCode(String phone, String type, String code) {
        String key = SMS_CODE_PREFIX + phone + ":" + type;
        String cachedCode = redisTemplate.opsForValue().get(key);
        return code.equals(cachedCode);
    }

    public LoginResponse loginWithSmsCode(String phone, String code, String role) {
        log.info("短信验证码登录请求: phone={}, role={}", phone, role);

        if (!verifySmsCode(phone, "login", code)) {
            log.warn("验证码错误或已过期: phone={}", phone);
            throw new BusinessException(ResultCode.PARAM_ERROR, "验证码错误或已过期");
        }

        // 验证角色有效性并保持原始字符串格式（用于数据库查询）
        convertToUserRole(role);
        String userRole = role;

        User user = userMapper.selectOne(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<User>()
                .eq(User::getPhone, phone)
                .eq(User::getRole, userRole)
                .eq(User::getStatus, "active")
        );

        if (user == null) {
            log.warn("用户不存在: phone={}, role={}", phone, role);
            throw new BusinessException(ResultCode.USER_NOT_FOUND);
        }

        if (user.getId() == null) {
            log.error("用户ID为空: phone={}", phone);
            throw new BusinessException(ResultCode.SYSTEM_ERROR, "用户数据异常");
        }

        String accessToken = userService.generateToken(user);
        String refreshToken = userService.generateRefreshToken(user);

        log.info("短信验证码登录成功: userId={}, phone={}", user.getId(), phone);

        Long stationId = user.getStationId();

        return new LoginResponse(
            accessToken,
            refreshToken,
            7200L,
            new LoginResponse.UserInfo(
                user.getId().toString(),
                user.getName(),
                user.getRole(),
                user.getPhone(),
                null,
                stationId != null ? stationId.toString() : null,
                user.getWarehouseId() != null ? user.getWarehouseId().toString() : null,
                user.getDriverId() != null ? user.getDriverId().toString() : null
            )
        );
    }

    @Transactional
    public void resetPasswordBySmsCode(String phone, String code, String newPassword) {
        log.info("重置密码请求: phone={}", phone);

        if (!verifySmsCode(phone, "reset", code)) {
            log.warn("验证码错误或已过期: phone={}", phone);
            throw new BusinessException(ResultCode.PARAM_ERROR, "验证码错误或已过期");
        }

        if (newPassword == null || newPassword.length() < 6) {
            log.warn("密码长度不符合要求: phone={}", phone);
            throw new BusinessException(ResultCode.PARAM_ERROR, "密码长度不能少于6位");
        }

        User user = userMapper.selectOne(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<User>()
                .eq(User::getPhone, phone)
                .eq(User::getStatus, "active")
        );

        if (user == null) {
            log.warn("用户不存在: phone={}", phone);
            throw new BusinessException(ResultCode.USER_NOT_FOUND);
        }

        String encodedPassword = passwordEncoder.encode(newPassword);
        user.setPassword(encodedPassword);
        user.setUpdateTime(LocalDateTime.now());
        userMapper.updateById(user);

        log.info("密码重置成功: userId={}, phone={}", user.getId(), phone);

        String cacheKey = SMS_CODE_PREFIX + phone + ":reset";
        redisTemplate.delete(cacheKey);
    }
}
