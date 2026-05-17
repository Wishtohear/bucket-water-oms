package com.bucketwater.oms.module.auth.service;

import com.bucketwater.oms.common.exception.BusinessException;
import com.bucketwater.oms.module.auth.dto.LoginRequest;
import com.bucketwater.oms.module.auth.dto.LoginResponse;
import com.bucketwater.oms.module.auth.dto.SmsCodeRequest;
import com.bucketwater.oms.module.user.entity.User;
import com.bucketwater.oms.module.user.mapper.UserMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.ValueOperations;

import java.time.LocalDateTime;


import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@DisplayName("认证服务单元测试")
class AuthServiceTest {

    @Mock
    private UserMapper userMapper;

    @Mock
    private UserService userService;

    @Mock
    private StringRedisTemplate redisTemplate;

    @Mock
    private ValueOperations<String, String> valueOperations;

    @InjectMocks
    private AuthService authService;

    private User testUser;
    private String phone = "13800138000";
    private String password = "123456";

    @BeforeEach
    void setUp() {
        testUser = new User();
        testUser.setId(1L);
        testUser.setPhone(phone);
        testUser.setPassword(password);
        testUser.setName("测试用户");
        testUser.setRole("station");
        testUser.setStatus("active");
        testUser.setCreateTime(LocalDateTime.now());
        testUser.setUpdateTime(LocalDateTime.now());
    }

    @Test
    @DisplayName("登录成功")
    void login_Success() {
        LoginRequest request = new LoginRequest();
        request.setPhone(phone);
        request.setPassword(password);
        request.setRole("station");

        when(userMapper.selectOne(any())).thenReturn(testUser);
        when(userService.validatePassword(password, password)).thenReturn(true);
        when(userService.generateToken(testUser)).thenReturn("access_token");
        when(userService.generateRefreshToken(testUser)).thenReturn("refresh_token");
        when(userMapper.updateById(any(User.class))).thenReturn(1);

        LoginResponse response = authService.login(request);

        assertNotNull(response);
        assertEquals("access_token", response.getAccessToken());
        assertEquals("refresh_token", response.getRefreshToken());
        assertEquals(7200L, response.getExpiresIn());
        assertNotNull(response.getUser());
        assertEquals(phone, response.getUser().getPhone());
    }

    @Test
    @DisplayName("用户不存在登录失败")
    void login_UserNotFound() {
        LoginRequest request = new LoginRequest();
        request.setPhone("13900000000");
        request.setPassword(password);
        request.setRole("station");

        when(userMapper.selectOne(any())).thenReturn(null);

        assertThrows(BusinessException.class, () -> {
            authService.login(request);
        });
    }

    @Test
    @DisplayName("密码错误登录失败")
    void login_PasswordError() {
        LoginRequest request = new LoginRequest();
        request.setPhone(phone);
        request.setPassword("wrong_password");
        request.setRole("station");

        when(userMapper.selectOne(any())).thenReturn(testUser);
        when(userService.validatePassword("wrong_password", password)).thenReturn(false);

        assertThrows(BusinessException.class, () -> {
            authService.login(request);
        });
    }

    @Test
    @DisplayName("刷新Token成功")
    void refreshToken_Success() {
        when(userService.validateRefreshToken("refresh_token")).thenReturn(testUser);
        when(userService.generateToken(testUser)).thenReturn("new_access_token");
        when(userService.generateRefreshToken(testUser)).thenReturn("new_refresh_token");

        LoginResponse response = authService.refreshToken("refresh_token");

        assertNotNull(response);
        assertEquals("new_access_token", response.getAccessToken());
        assertEquals("new_refresh_token", response.getRefreshToken());
    }

    @Test
    @DisplayName("无效Token刷新失败")
    void refreshToken_InvalidToken() {
        when(userService.validateRefreshToken("invalid_token")).thenReturn(null);

        assertThrows(BusinessException.class, () -> {
            authService.refreshToken("invalid_token");
        });
    }

    @Test
    @DisplayName("发送验证码成功")
    void sendSmsCode_Success() {
        SmsCodeRequest request = new SmsCodeRequest();
        request.setPhone(phone);
        request.setType("login");

        when(redisTemplate.opsForValue()).thenReturn(valueOperations);

        authService.sendSmsCode(request);

        verify(valueOperations).set(anyString(), anyString(), any());
    }

    @Test
    @DisplayName("验证验证码成功")
    void verifySmsCode_Success() {
        String code = "123456";
        when(redisTemplate.opsForValue()).thenReturn(valueOperations);
        when(valueOperations.get(anyString())).thenReturn(code);

        boolean result = authService.verifySmsCode(phone, "login", code);

        assertTrue(result);
    }

    @Test
    @DisplayName("验证码错误")
    void verifySmsCode_WrongCode() {
        when(redisTemplate.opsForValue()).thenReturn(valueOperations);
        when(valueOperations.get(anyString())).thenReturn("123456");

        boolean result = authService.verifySmsCode(phone, "login", "654321");

        assertFalse(result);
    }

    @Test
    @DisplayName("验证码过期")
    void verifySmsCode_Expired() {
        when(redisTemplate.opsForValue()).thenReturn(valueOperations);
        when(valueOperations.get(anyString())).thenReturn(null);

        boolean result = authService.verifySmsCode(phone, "login", "123456");

        assertFalse(result);
    }
}
