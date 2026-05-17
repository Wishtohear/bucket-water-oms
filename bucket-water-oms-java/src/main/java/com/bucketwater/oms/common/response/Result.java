package com.bucketwater.oms.common.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import java.io.Serializable;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class Result<T> implements Serializable {
    
    private boolean success;
    private T data;
    private String message;
    private String code;

    public Result() {
    }

    public Result(boolean success, T data, String message, String code) {
        this.success = success;
        this.data = data;
        this.message = message;
        this.code = code;
    }

    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public T getData() {
        return data;
    }

    public void setData(T data) {
        this.data = data;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public static <T> Result<T> ok() {
        return new Result<>(true, null, "操作成功", "0000");
    }

    public static <T> Result<T> ok(T data) {
        return new Result<>(true, data, "操作成功", "0000");
    }

    public static <T> Result<T> ok(T data, String message) {
        return new Result<>(true, data, message, "0000");
    }

    public static <T> Result<T> error(String message) {
        return new Result<>(false, null, message, "9999");
    }

    public static <T> Result<T> error(String code, String message) {
        return new Result<>(false, null, message, code);
    }

    public static <T> Result<T> error(ResultCode resultCode) {
        return new Result<>(false, null, resultCode.getMessage(), resultCode.getCode());
    }
}
