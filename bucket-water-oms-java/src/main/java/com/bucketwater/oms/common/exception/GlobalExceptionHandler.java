package com.bucketwater.oms.common.exception;

import com.bucketwater.oms.common.response.Result;
import com.bucketwater.oms.common.response.ResultCode;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.validation.BindException;
import org.springframework.validation.FieldError;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.io.IOException;
import java.util.stream.Collectors;

@RestControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    @ExceptionHandler(HttpRequestMethodNotSupportedException.class)
    @ResponseStatus(HttpStatus.METHOD_NOT_ALLOWED)
    public void handleHttpRequestMethodNotSupported(
            HttpRequestMethodNotSupportedException ex, HttpServletRequest request, HttpServletResponse response) throws IOException {
        String path = request.getRequestURI();
        String method = request.getMethod();
        log.error("HTTP方法不支持: path={}, method={}, message={}", path, method, ex.getMessage());
        
        if (isSseRequest(request)) {
            response.setContentType("text/plain;charset=UTF-8");
            response.setStatus(HttpStatus.METHOD_NOT_ALLOWED.value());
            response.getWriter().write("Request method " + method + " not supported for path " + path);
        } else {
            response.setContentType(MediaType.APPLICATION_JSON_VALUE);
            response.setStatus(HttpStatus.METHOD_NOT_ALLOWED.value());
            response.getWriter().write("{\"success\":false,\"code\":\"METHOD_NOT_ALLOWED\",\"message\":\"请求路径 " + path + " 不支持 " + method + " 方法\"}");
        }
    }

    @ExceptionHandler(MissingServletRequestParameterException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public void handleMissingServletRequestParameter(
            MissingServletRequestParameterException ex, HttpServletRequest request, HttpServletResponse response) throws IOException {
        String path = request.getRequestURI();
        log.warn("缺少请求参数: path={}, parameter={}, message={}", 
            path, ex.getParameterName(), ex.getMessage());
        
        if (isSseRequest(request)) {
            response.setContentType("text/plain;charset=UTF-8");
            response.setStatus(HttpStatus.BAD_REQUEST.value());
            response.getWriter().write("Missing required parameter: " + ex.getParameterName());
        } else {
            response.setContentType(MediaType.APPLICATION_JSON_VALUE);
            response.setStatus(HttpStatus.BAD_REQUEST.value());
            response.getWriter().write("{\"success\":false,\"code\":\"PARAM_MISSING\",\"message\":\"缺少必需参数: " + ex.getParameterName() + "\"}");
        }
    }

    @ExceptionHandler(BusinessException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public Result<Void> handleBusinessException(BusinessException ex) {
        log.warn("业务异常: code={}, message={}", ex.getCode(), ex.getMessage());
        return Result.error(ex.getCode(), ex.getMessage());
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public Result<Void> handleValidationException(MethodArgumentNotValidException ex) {
        String message = ex.getBindingResult().getFieldErrors().stream()
                .map(FieldError::getDefaultMessage)
                .collect(Collectors.joining(", "));
        log.warn("参数校验异常: {}", message);
        return Result.error(ResultCode.VALIDATION_ERROR.getCode(), message);
    }

    @ExceptionHandler(BindException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public Result<Void> handleBindException(BindException ex) {
        String message = ex.getBindingResult().getFieldErrors().stream()
                .map(FieldError::getDefaultMessage)
                .collect(Collectors.joining(", "));
        log.warn("参数绑定异常: {}", message);
        return Result.error(ResultCode.VALIDATION_ERROR.getCode(), message);
    }

    @ExceptionHandler(IllegalArgumentException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public Result<Void> handleIllegalArgumentException(IllegalArgumentException ex) {
        log.warn("非法参数异常: {}", ex.getMessage());
        return Result.error(ResultCode.PARAM_INVALID.getCode(), ex.getMessage());
    }

    @ExceptionHandler(Exception.class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    public Result<Void> handleException(Exception ex, HttpServletRequest request) {
        log.error("系统异常 - URI: {}, Method: {}, Error: {}", 
            request.getRequestURI(), request.getMethod(), ex.getMessage(), ex);
        
        // 在开发环境中，可以返回更详细的错误信息
        String message = ex.getMessage();
        if (message == null || message.isEmpty()) {
            message = ex.getClass().getSimpleName();
        }
        
        return Result.error(ResultCode.SYSTEM_ERROR.getCode(), 
            "系统错误: " + message);
    }
    
    private boolean isSseRequest(HttpServletRequest request) {
        String accept = request.getHeader("Accept");
        String uri = request.getRequestURI();
        return (accept != null && accept.contains("text/event-stream")) 
            || uri.contains("/subscribe");
    }
}
