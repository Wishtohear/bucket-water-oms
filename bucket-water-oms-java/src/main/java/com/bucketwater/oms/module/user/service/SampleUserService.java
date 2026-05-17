package com.bucketwater.oms.module.user.service;

import com.bucketwater.oms.common.exception.BusinessException;
import com.bucketwater.oms.common.response.ResultCode;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

@Service
public class SampleUserService {

    private static final Logger log = LoggerFactory.getLogger(SampleUserService.class);

    public Map<String, Object> getUserById(Long id) {
        log.info("Get user by id: {}", id);

        if (id == null || id <= 0) {
            throw new BusinessException(ResultCode.PARAM_INVALID, "用户ID无效");
        }

        Map<String, Object> user = new HashMap<>();
        user.put("id", id);
        user.put("username", "user" + id);
        user.put("email", "user" + id + "@example.com");
        user.put("role", "STATION_OWNER");

        return user;
    }

    public Map<String, Object> createUser(Map<String, Object> request) {
        log.info("Create user: {}", request);

        String username = (String) request.get("username");
        if (username == null || username.isBlank()) {
            throw new BusinessException(ResultCode.PARAM_MISSING, "用户名不能为空");
        }

        Map<String, Object> result = new HashMap<>();
        result.put("id", System.currentTimeMillis());
        result.put("username", username);
        result.put("created", true);

        return result;
    }

    public void updateUser(Long id, Map<String, Object> updateData) {
        log.info("Update user id: {}, data: {}", id, updateData);

        if (id == null || id <= 0) {
            throw new BusinessException(ResultCode.PARAM_INVALID, "用户ID无效");
        }
    }

    public void deleteUser(Long id) {
        log.info("Delete user id: {}", id);

        if (id == null || id <= 0) {
            throw new BusinessException(ResultCode.PARAM_INVALID, "用户ID无效");
        }
    }
}
