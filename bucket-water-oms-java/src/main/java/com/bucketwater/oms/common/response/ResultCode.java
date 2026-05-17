package com.bucketwater.oms.common.response;

public enum ResultCode {

    SUCCESS("0000", "操作成功"),

    SYSTEM_ERROR("1000", "系统错误"),
    SYSTEM_BUSY("1001", "系统繁忙，请稍后再试"),

    PARAM_ERROR("2000", "参数错误"),
    PARAM_MISSING("2001", "缺少必要参数"),
    PARAM_INVALID("2002", "参数无效"),

    UNAUTHORIZED("3000", "未登录"),
    TOKEN_EXPIRED("3001", "登录已过期"),
    TOKEN_INVALID("3002", "无效的令牌"),
    FORBIDDEN("3003", "无权限访问"),

    NOT_FOUND("4000", "资源不存在"),
    DATA_NOT_FOUND("4001", "数据不存在"),

    DATA_EXISTS("5000", "数据已存在"),
    DATA_CONFLICT("5001", "数据冲突"),

    BUSINESS_ERROR("6000", "业务处理失败"),
    INSUFFICIENT_STOCK("6001", "库存不足"),
    INSUFFICIENT_BALANCE("6002", "余额不足"),
    INSUFFICIENT_CREDIT("6003", "信用额度不足"),
    ORDER_CANNOT_MODIFY("6004", "订单已接单，无法修改"),
    ORDER_CANNOT_CANCEL("6005", "订单状态不允许取消"),

    VALIDATION_ERROR("7000", "数据校验失败"),
    BUCKET_OWED_THRESHOLD("7001", "欠桶数量达到阈值"),

    USER_NOT_FOUND("8001", "用户不存在"),
    PASSWORD_ERROR("8002", "密码错误"),
    STATION_NOT_FOUND("8003", "水站不存在"),
    ORDER_NOT_FOUND("8004", "订单不存在"),
    ORDER_STATUS_NOT_ALLOWED("8005", "订单状态不允许此操作"),
    BALANCE_INSUFFICIENT("8006", "余额不足"),
    RETURN_NOT_FOUND("8007", "回仓记录不存在"),
    STATEMENT_NOT_FOUND("8008", "对账单不存在"),
    AFTER_SALES_NOT_FOUND("8009", "售后记录不存在"),
    PRODUCT_NOT_FOUND("8010", "商品不存在"),
    WAREHOUSE_NOT_FOUND("8011", "仓库不存在"),
    DRIVER_NOT_FOUND("8012", "司机不存在"),

    UNSUPPORTED_OPERATION("9000", "操作暂不支持");

    private final String code;
    private final String message;

    ResultCode(String code, String message) {
        this.code = code;
        this.message = message;
    }

    public String getCode() {
        return code;
    }

    public String getMessage() {
        return message;
    }
}
