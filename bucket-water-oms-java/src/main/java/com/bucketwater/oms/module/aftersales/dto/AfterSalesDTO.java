package com.bucketwater.oms.module.aftersales.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 售后列表响应DTO
 */
@Data
@Schema(description = "售后列表响应DTO")
public class AfterSalesDTO {

    @Schema(description = "售后ID")
    private Long id;

    @Schema(description = "售后单号")
    private String afterSalesNo;

    @Schema(description = "关联订单ID")
    private Long orderId;

    @Schema(description = "关联订单号")
    private String orderNo;

    @Schema(description = "售后类型: replenishment-补货, refund-退款, return-退货")
    private String type;

    @Schema(description = "类型文本")
    private String typeText;

    @Schema(description = "售后原因")
    private String reason;

    @Schema(description = "状态: pending-待处理, processing-处理中, completed-已完成, rejected-已拒绝")
    private String status;

    @Schema(description = "状态文本")
    private String statusText;

    @Schema(description = "处理结果")
    private String handleResult;

    @Schema(description = "处理时间")
    private LocalDateTime handleTime;

    @Schema(description = "创建时间")
    private LocalDateTime createTime;

    @Schema(description = "售后商品明细")
    private List<AfterSalesItemDTO> items;

    @Schema(description = "图片列表")
    private List<String> images;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getAfterSalesNo() {
        return afterSalesNo;
    }

    public void setAfterSalesNo(String afterSalesNo) {
        this.afterSalesNo = afterSalesNo;
    }

    public Long getOrderId() {
        return orderId;
    }

    public void setOrderId(Long orderId) {
        this.orderId = orderId;
    }

    public String getOrderNo() {
        return orderNo;
    }

    public void setOrderNo(String orderNo) {
        this.orderNo = orderNo;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getTypeText() {
        return typeText;
    }

    public void setTypeText(String typeText) {
        this.typeText = typeText;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getStatusText() {
        return statusText;
    }

    public void setStatusText(String statusText) {
        this.statusText = statusText;
    }

    public String getHandleResult() {
        return handleResult;
    }

    public void setHandleResult(String handleResult) {
        this.handleResult = handleResult;
    }

    public LocalDateTime getHandleTime() {
        return handleTime;
    }

    public void setHandleTime(LocalDateTime handleTime) {
        this.handleTime = handleTime;
    }

    public LocalDateTime getCreateTime() {
        return createTime;
    }

    public void setCreateTime(LocalDateTime createTime) {
        this.createTime = createTime;
    }

    public List<AfterSalesItemDTO> getItems() {
        return items;
    }

    public void setItems(List<AfterSalesItemDTO> items) {
        this.items = items;
    }

    public List<String> getImages() {
        return images;
    }

    public void setImages(List<String> images) {
        this.images = images;
    }
}
