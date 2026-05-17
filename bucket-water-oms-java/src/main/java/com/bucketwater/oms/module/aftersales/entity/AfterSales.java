package com.bucketwater.oms.module.aftersales.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("after_sales")
@Schema(description = "售后实体")
public class AfterSales {

    @TableId(type = IdType.AUTO)
    @Schema(description = "主键ID")
    private Long id;

    @TableField("after_sales_no")
    @Schema(description = "售后单号")
    private String afterSalesNo;

    @TableField("station_id")
    @Schema(description = "水站ID")
    private Long stationId;

    @TableField("order_id")
    @Schema(description = "原订单ID")
    private Long orderId;

    @TableField("product_id")
    @Schema(description = "商品ID")
    private Long productId;

    @Schema(description = "类型: replenishment-补货, refund-退款, return-退货")
    private String type;

    @Schema(description = "原因")
    private String reason;

    @Schema(description = "图片(JSON数组)")
    private String photos;

    @Schema(description = "请求类型: replenishment/refund")
    private String requestType;

    @Schema(description = "请求数量")
    private Integer requestedQuantity;

    @Schema(description = "状态: pending-待处理, processing-处理中, completed-已完成, rejected-已拒绝, cancelled-已取消")
    private String status;

    @TableField("new_order_id")
    @Schema(description = "新订单ID")
    private Long newOrderId;

    @Schema(description = "处理结果")
    private String handleResult;

    @Schema(description = "处理时间")
    private LocalDateTime handleTime;

    @Schema(description = "拒绝原因")
    private String rejectReason;

    @Schema(description = "创建时间")
    private LocalDateTime createdAt;

    @Schema(description = "更新时间")
    private LocalDateTime updateTime;

    @Schema(description = "处理时间")
    private LocalDateTime processedAt;

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

    public Long getStationId() {
        return stationId;
    }

    public void setStationId(Long stationId) {
        this.stationId = stationId;
    }

    public Long getOrderId() {
        return orderId;
    }

    public void setOrderId(Long orderId) {
        this.orderId = orderId;
    }

    public Long getProductId() {
        return productId;
    }

    public void setProductId(Long productId) {
        this.productId = productId;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public String getPhotos() {
        return photos;
    }

    public void setPhotos(String photos) {
        this.photos = photos;
    }

    public String getRequestType() {
        return requestType;
    }

    public void setRequestType(String requestType) {
        this.requestType = requestType;
    }

    public Integer getRequestedQuantity() {
        return requestedQuantity;
    }

    public void setRequestedQuantity(Integer requestedQuantity) {
        this.requestedQuantity = requestedQuantity;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Long getNewOrderId() {
        return newOrderId;
    }

    public void setNewOrderId(Long newOrderId) {
        this.newOrderId = newOrderId;
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

    public String getRejectReason() {
        return rejectReason;
    }

    public void setRejectReason(String rejectReason) {
        this.rejectReason = rejectReason;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdateTime() {
        return updateTime;
    }

    public void setUpdateTime(LocalDateTime updateTime) {
        this.updateTime = updateTime;
    }

    public LocalDateTime getProcessedAt() {
        return processedAt;
    }

    public void setProcessedAt(LocalDateTime processedAt) {
        this.processedAt = processedAt;
    }
}
