package com.bucketwater.oms.controller;

import com.bucketwater.oms.common.response.Result;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/api/v1/sample")
@RequiredArgsConstructor
@Tag(name = "示例接口", description = "API使用示例，演示Swagger注解的使用方法")
public class SampleController {

    @GetMapping("/hello")
    @Operation(summary = "打招呼", description = "返回一个简单的问候信息")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "成功返回问候信息",
                    content = @Content(mediaType = "application/json",
                            schema = @Schema(example = "{\"success\":true,\"data\":\"Hello, World!\",\"message\":\"操作成功\",\"code\":\"0000\"}")))
    })
    public Result<String> hello() {
        log.info("Sample hello called");
        return Result.ok("Hello, World!");
    }

    @GetMapping("/user/{id}")
    @Operation(summary = "获取用户信息", description = "根据用户ID获取用户详细信息")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "成功获取用户信息"),
            @ApiResponse(responseCode = "400", description = "参数错误"),
            @ApiResponse(responseCode = "404", description = "用户不存在")
    })
    public Result<Map<String, Object>> getUser(
            @Parameter(description = "用户ID", required = true, example = "1")
            @PathVariable Long id) {

        log.info("Get user by id: {}", id);

        Map<String, Object> user = new HashMap<>();
        user.put("id", id);
        user.put("username", "user" + id);
        user.put("email", "user" + id + "@example.com");
        user.put("role", "STATION_OWNER");

        return Result.ok(user);
    }

    @PostMapping("/user")
    @Operation(summary = "创建用户", description = "创建一个新的用户账号")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "用户创建成功"),
            @ApiResponse(responseCode = "400", description = "参数校验失败")
    })
    public Result<Map<String, Object>> createUser(
            @io.swagger.v3.oas.annotations.parameters.RequestBody(
                    description = "用户信息",
                    required = true,
                    content = @Content(mediaType = "application/json",
                            schema = @Schema(example = "{\"username\":\"testuser\",\"password\":\"123456\",\"phone\":\"13800138000\",\"role\":\"STATION_OWNER\"}")))
            @RequestBody Map<String, Object> userRequest) {

        log.info("Create user: {}", userRequest);

        Map<String, Object> result = new HashMap<>();
        result.put("id", 1001L);
        result.put("username", userRequest.get("username"));
        result.put("created", true);

        return Result.ok(result, "用户创建成功");
    }

    @PutMapping("/user/{id}")
    @Operation(summary = "更新用户信息", description = "根据用户ID更新用户信息")
    public Result<Void> updateUser(
            @Parameter(description = "用户ID", required = true, example = "1")
            @PathVariable Long id,

            @io.swagger.v3.oas.annotations.parameters.RequestBody(
                    description = "更新的用户信息",
                    required = true)
            @RequestBody Map<String, Object> updateRequest) {

        log.info("Update user id: {}, data: {}", id, updateRequest);
        return Result.ok();
    }

    @DeleteMapping("/user/{id}")
    @Operation(summary = "删除用户", description = "根据用户ID删除用户")
    public Result<Void> deleteUser(
            @Parameter(description = "用户ID", required = true, example = "1")
            @PathVariable Long id) {

        log.info("Delete user id: {}", id);
        return Result.ok();
    }

    @GetMapping("/users")
    @Operation(summary = "获取用户列表", description = "分页获取用户列表")
    public Result<Map<String, Object>> getUsers(
            @Parameter(description = "页码", example = "0")
            @RequestParam(defaultValue = "0") int page,

            @Parameter(description = "每页数量", example = "20")
            @RequestParam(defaultValue = "20") int size,

            @Parameter(description = "用户角色过滤", example = "STATION_OWNER")
            @RequestParam(required = false) String role) {

        log.info("Get users page: {}, size: {}, role: {}", page, size, role);

        Map<String, Object> result = new HashMap<>();
        result.put("total", 100);
        result.put("page", page);
        result.put("size", size);
        result.put("users", new Object[]{});

        return Result.ok(result);
    }
}
