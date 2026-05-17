package com.bucketwater.oms.common.security;

import com.bucketwater.oms.common.enums.UserRole;
import com.bucketwater.oms.module.user.entity.User;
import com.bucketwater.oms.module.user.mapper.UserMapper;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import javax.crypto.SecretKey;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.Optional;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private static final Logger log = LoggerFactory.getLogger(JwtAuthenticationFilter.class);

    @Value("${jwt.secret:defaultSecretKeyForDevelopment123456789012345678901234567890}")
    private String jwtSecret;

    @Autowired
    private UserMapper userMapper;

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain) throws ServletException, IOException {

        String path = request.getRequestURI();

        if (isPublicPath(path)) {
            filterChain.doFilter(request, response);
            return;
        }

        String authHeader = request.getHeader("Authorization");
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            log.debug("请求路径={}，未携带有效的Authorization头，跳过认证", path);
            filterChain.doFilter(request, response);
            return;
        }

        String token = authHeader.substring(7);

        try {
            Claims claims = validateToken(token);
            String userId = claims.getSubject();
            
            if (userId != null && !userId.isEmpty()) {
                try {
                    Long id = Long.parseLong(userId);
                    User user = userMapper.selectById(id);
                    if (user != null) {
                        request.setAttribute("currentUser", user);
                        log.debug("用户认证成功：userId={}, role={}", userId, user.getRole());
                    } else {
                        log.warn("Token中的用户不存在：userId={}", userId);
                    }
                } catch (NumberFormatException e) {
                    log.warn("无效的用户ID格式：userId={}", userId);
                }
            }
        } catch (JwtException e) {
            log.warn("JWT验证失败：{}", e.getMessage());
        } catch (Exception e) {
            log.error("认证过程中发生错误：", e);
        }

        filterChain.doFilter(request, response);
    }

    private Claims validateToken(String token) {
        SecretKey key = Keys.hmacShaKeyFor(jwtSecret.getBytes(StandardCharsets.UTF_8));
        return Jwts.parser()
                .verifyWith(key)
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }

    private boolean isPublicPath(String path) {
        return Arrays.asList(
            "/api/auth/login",
            "/api/auth/register",
            "/api/auth/sms/send",
            "/api/auth/refresh",
            "/api/notifications/subscribe",
            "/api/notifications/heartbeat",
            "/swagger-ui",
            "/v3/api-docs",
            "/files/view",
            "/files/download",
            "/platform/auth/login",
            "/platform/auth/refresh"
        ).stream().anyMatch(path::startsWith);
    }

    public static Optional<User> getCurrentUser(HttpServletRequest request) {
        Object user = request.getAttribute("currentUser");
        if (user instanceof User) {
            return Optional.of((User) user);
        }
        return Optional.empty();
    }
}
