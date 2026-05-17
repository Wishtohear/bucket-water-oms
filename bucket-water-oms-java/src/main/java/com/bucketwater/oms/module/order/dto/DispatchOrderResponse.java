package com.bucketwater.oms.module.order.dto;

import com.bucketwater.oms.module.order.entity.Order;
import io.swagger.v3.oas.annotations.media.Schema;

import java.util.ArrayList;
import java.util.List;

/**
 * 派单响应 DTO
 * 包含派单结果和可能的警告信息
 */
@Schema(description = "派单响应DTO")
public class DispatchOrderResponse {

    @Schema(description = "订单信息")
    private OrderVO order;

    @Schema(description = "警告信息列表")
    private List<String> warnings;

    @Schema(description = "是否成功")
    private boolean success;

    public DispatchOrderResponse() {
        this.warnings = new ArrayList<>();
        this.success = true;
    }

    public DispatchOrderResponse(OrderVO order) {
        this.order = order;
        this.warnings = new ArrayList<>();
        this.success = true;
    }

    public void addWarning(String warning) {
        if (this.warnings == null) {
            this.warnings = new ArrayList<>();
        }
        this.warnings.add(warning);
    }

    public OrderVO getOrder() {
        return order;
    }

    public void setOrder(OrderVO order) {
        this.order = order;
    }

    public List<String> getWarnings() {
        return warnings;
    }

    public void setWarnings(List<String> warnings) {
        this.warnings = warnings;
    }

    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }
}
