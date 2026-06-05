package com.bucketwater.oms.module.platform.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.bucketwater.oms.common.exception.BusinessException;
import com.bucketwater.oms.common.response.Result;
import com.bucketwater.oms.common.response.ResultCode;
import com.bucketwater.oms.common.security.RequireRole;
import com.bucketwater.oms.module.user.entity.User;
import com.bucketwater.oms.module.user.mapper.UserMapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/platform/admins")
@Tag(name = "平台管理员账号管理", description = "平台总超级管理员账号管理接口")
@RequireRole({"PLATFORM_ADMIN"})
public class PlatformAdminController {

    @Autowired
    private UserMapper userMapper;

    private BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    @GetMapping
    @Operation(summary = "获取平台管理员列表", description = "获取所有平台管理员账号（分页）")
    public Result<IPage<User>> getAdminPage(
            @RequestParam(required = false) String keyword,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "20") Integer size) {        
        Page<User> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(User::getRole, "PLATFORM_ADMIN");
        
        if (keyword != null && !keyword.isEmpty()) {
            wrapper.and(w -> w.like(User::getName, keyword)
                   .or()
                   .like(User::getPhone, keyword));
        }
        
        wrapper.orderByDesc(User::getCreateTime);
        IPage<User> pageResult = userMapper.selectPage(pageParam, wrapper);
        pageResult.getRecords().forEach(admin -> admin.setPassword(null));
        return Result.ok(pageResult);
    }

    @GetMapping("/all")
    @Operation(summary = "获取所有平台管理员", description = "获取所有平台管理员列表（不分页）")
    public Result<List<User>> getAllAdmins() {
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(User::getRole, "PLATFORM_ADMIN");
        wrapper.orderByDesc(User::getCreateTime);
        List<User> admins = userMapper.selectList(wrapper);
        admins.forEach(admin -> admin.setPassword(null));
        return Result.ok(admins);
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取管理员详情", description = "根据ID获取管理员详细信息")
    public Result<User> getAdminById(@PathVariable Long id) {
        User admin = userMapper.selectById(id);
        if (admin == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "管理员不存在");
        }
        admin.setPassword(null);
        return Result.ok(admin);
    }

    @PostMapping
    @Operation(summary = "创建管理员", description = "创建新平台管理员账号")
    @Transactional
    public Result<User> createAdmin(@RequestBody @jakarta.validation.Valid CreatePlatformAdminRequest request) {
        LambdaQueryWrapper<User> existWrapper = new LambdaQueryWrapper<>();
        existWrapper.and(w -> w.eq(User::getPhone, request.getPhone())
                .or().eq(User::getName, request.getUsername()));
        User existing = userMapper.selectOne(existWrapper);
        if (existing != null) {
            throw new BusinessException(ResultCode.DATA_EXISTS, "手机号或用户名已存在");
        }

        User admin = new User();
        admin.setName(request.getName() != null ? request.getName() : request.getUsername());
        admin.setPhone(request.getPhone());
        admin.setRole("PLATFORM_ADMIN");
        admin.setStatus("active");

        String rawPassword = request.getPassword() != null ? request.getPassword() : "123456";
        String encodedPassword = passwordEncoder.encode(rawPassword);
        admin.setPassword(encodedPassword);

        admin.setCreateTime(LocalDateTime.now());
        admin.setUpdateTime(LocalDateTime.now());

        userMapper.insert(admin);
        admin.setPassword(null);
        return Result.ok(admin);
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新管理员", description = "更新管理员信息")
    @Transactional
    public Result<User> updateAdmin(
            @PathVariable Long id,
            @RequestBody UpdatePlatformAdminRequest request) {
        User admin = userMapper.selectById(id);
        if (admin == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "管理员不存在");
        }

        if (request.getName() != null) {
            admin.setName(request.getName());
        }
        if (request.getPhone() != null) {
            admin.setPhone(request.getPhone());
        }
        if (request.getEmail() != null) {
            admin.setEmail(request.getEmail());
        }

        admin.setUpdateTime(LocalDateTime.now());
        userMapper.updateById(admin);
        admin.setPassword(null);
        return Result.ok(admin);
    }

    @PutMapping("/{id}/password")
    @Operation(summary = "重置密码", description = "重置管理员密码")
    @Transactional
    public Result<Void> resetPassword(
            @PathVariable Long id,
            @RequestParam(required = false, defaultValue = "123456") String newPassword) {
        User admin = userMapper.selectById(id);
        if (admin == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "管理员不存在");
        }

        String encodedPassword = passwordEncoder.encode(newPassword);
        admin.setPassword(encodedPassword);
        admin.setUpdateTime(LocalDateTime.now());
        userMapper.updateById(admin);
        return Result.ok();
    }

    @PutMapping("/{id}/status")
    @Operation(summary = "更新状态", description = "启用/停用管理员")
    @Transactional
    public Result<Void> updateStatus(
            @PathVariable Long id,
            @RequestParam String status) {
        User admin = userMapper.selectById(id);
        if (admin == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "管理员不存在");
        }

        admin.setStatus(status);
        admin.setUpdateTime(LocalDateTime.now());
        userMapper.updateById(admin);
        return Result.ok();
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除管理员", description = "删除管理员账号")
    @Transactional
    public Result<Void> deleteAdmin(@PathVariable Long id) {
        User admin = userMapper.selectById(id);
        if (admin == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "管理员不存在");
        }
        userMapper.deleteById(id);
        return Result.ok();
    }

    @lombok.Data
    public static class CreatePlatformAdminRequest {
        @Schema(description = "用户名（可选，默认使用姓名）")
        private String username;

        @jakarta.validation.constraints.Size(max = 50, message = "姓名长度不能超过50个字符")
        @Schema(description = "管理员姓名")
        private String name;

        @jakarta.validation.constraints.NotBlank(message = "手机号不能为空")
        @jakarta.validation.constraints.Pattern(regexp = "^1[3-9]\\d{9}$", message = "手机号格式不正确")
        @Schema(description = "手机号（登录账号）")
        private String phone;

        @Schema(description = "邮箱")
        private String email;

        @Schema(description = "密码（默认123456）")
        private String password;
    }

    @lombok.Data
    public static class UpdatePlatformAdminRequest {
        @Schema(description = "用户名")
        private String username;

        @Schema(description = "管理员姓名")
        private String name;

        @Schema(description = "手机号")
        private String phone;

        @Schema(description = "邮箱")
        private String email;
    }
}
