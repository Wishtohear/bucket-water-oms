package com.bucketwater.oms.module.auth.service;

import com.bucketwater.oms.common.exception.BusinessException;
import com.bucketwater.oms.common.response.ResultCode;
import com.bucketwater.oms.module.user.entity.User;
import com.bucketwater.oms.module.user.mapper.UserMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import java.nio.charset.StandardCharsets;
import java.util.Date;

@Service
public class UserService {

    private static final Logger log = LoggerFactory.getLogger(UserService.class);

    @Value("${jwt.secret:defaultSecretKeyForDevelopment123456789012345678901234567890}")
    private String jwtSecret;

    @Value("${jwt.access-token-validity:7200}")
    private Long accessTokenValidity;

    @Value("${jwt.refresh-token-validity:604800}")
    private Long refreshTokenValidity;

    @Autowired
    private UserMapper userMapper;

    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    public String generateToken(User user) {
        if (user == null || user.getId() == null) {
            log.error("生成Token失败：用户或用户ID为空");
            throw new BusinessException(ResultCode.SYSTEM_ERROR, "用户数据异常");
        }

        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + accessTokenValidity * 1000);

        String token = Jwts.builder()
                .subject(user.getId().toString())
                .claim("phone", user.getPhone())
                .claim("role", user.getRole())
                .claim("userName", user.getName())
                .issuedAt(now)
                .expiration(expiryDate)
                .signWith(getSigningKey())
                .compact();

        log.debug("生成AccessToken成功: userId={}", user.getId());
        return token;
    }

    public String generateRefreshToken(User user) {
        if (user == null || user.getId() == null) {
            log.error("生成RefreshToken失败：用户或用户ID为空");
            throw new BusinessException(ResultCode.SYSTEM_ERROR, "用户数据异常");
        }

        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + refreshTokenValidity * 1000);

        String token = Jwts.builder()
                .subject(user.getId().toString())
                .claim("type", "refresh")
                .claim("phone", user.getPhone())
                .claim("role", user.getRole())
                .issuedAt(now)
                .expiration(expiryDate)
                .signWith(getSigningKey())
                .compact();

        log.debug("生成RefreshToken成功: userId={}", user.getId());
        return token;
    }

    public User validateRefreshToken(String token) {
        try {
            Claims claims = Jwts.parser()
                    .verifyWith(getSigningKey())
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();

            if (!"refresh".equals(claims.get("type", String.class))) {
                log.warn("无效的Token类型");
                return null;
            }

            String userId = claims.getSubject();
            if (userId == null || userId.isEmpty()) {
                log.warn("Token中不包含用户ID");
                return null;
            }

            log.debug("验证RefreshToken成功: userId={}", userId);
            try {
                Long id = Long.parseLong(userId);
                return userMapper.selectById(id);
            } catch (NumberFormatException e) {
                log.warn("无效的用户ID格式：userId={}", userId);
                return null;
            }
        } catch (ExpiredJwtException e) {
            log.warn("RefreshToken已过期");
            return null;
        } catch (JwtException e) {
            log.error("Token验证失败: {}", e.getMessage());
            return null;
        } catch (Exception e) {
            log.error("验证Token时发生异常", e);
            return null;
        }
    }

    public User validateAccessToken(String token) {
        try {
            Claims claims = Jwts.parser()
                    .verifyWith(getSigningKey())
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();

            String userId = claims.getSubject();
            if (userId == null || userId.isEmpty()) {
                log.warn("Token中不包含用户ID");
                return null;
            }

            log.debug("验证AccessToken成功: userId={}", userId);
            try {
                Long id = Long.parseLong(userId);
                return userMapper.selectById(id);
            } catch (NumberFormatException e) {
                log.warn("无效的用户ID格式：userId={}", userId);
                return null;
            }
        } catch (ExpiredJwtException e) {
            log.warn("AccessToken已过期");
            return null;
        } catch (JwtException e) {
            log.error("Token验证失败: {}", e.getMessage());
            return null;
        } catch (Exception e) {
            log.error("验证Token时发生异常", e);
            return null;
        }
    }

    public boolean validatePassword(String rawPassword, String encodedPassword) {
        if (rawPassword == null || encodedPassword == null) {
            return false;
        }
        return passwordEncoder.matches(rawPassword, encodedPassword);
    }

    private SecretKey getSigningKey() {
        byte[] keyBytes = jwtSecret.getBytes(StandardCharsets.UTF_8);
        return Keys.hmacShaKeyFor(keyBytes);
    }
}
