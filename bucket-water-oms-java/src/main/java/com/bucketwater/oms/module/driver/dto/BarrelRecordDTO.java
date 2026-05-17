package com.bucketwater.oms.module.driver.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import java.time.LocalDateTime;

@Schema(description = "空桶记录DTO")
public class BarrelRecordDTO {

    @Schema(description = "记录ID")
    private Long id;

    @Schema(description = "日期/时间")
    private String date;

    @Schema(description = "记录时间")
    private LocalDateTime createdAt;

    @Schema(description = "类型: return(回桶)/pickup(领桶)/owed(欠桶)")
    private String type;

    @Schema(description = "类型文本")
    private String typeText;

    @Schema(description = "数量")
    private Integer quantity;

    @Schema(description = "关联订单号")
    private String orderNo;

    @Schema(description = "关联订单ID")
    private Long orderId;

    @Schema(description = "水站名称")
    private String stationName;

    @Schema(description = "仓库名称")
    private String warehouseName;

    @Schema(description = "变动后余额")
    private Integer balance;

    @Schema(description = "备注")
    private String remark;

    public BarrelRecordDTO() {}

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getDate() {
        return date;
    }

    public void setDate(String date) {
        this.date = date;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
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

    public Integer getQuantity() {
        return quantity;
    }

    public void setQuantity(Integer quantity) {
        this.quantity = quantity;
    }

    public String getOrderNo() {
        return orderNo;
    }

    public void setOrderNo(String orderNo) {
        this.orderNo = orderNo;
    }

    public Long getOrderId() {
        return orderId;
    }

    public void setOrderId(Long orderId) {
        this.orderId = orderId;
    }

    public String getStationName() {
        return stationName;
    }

    public void setStationName(String stationName) {
        this.stationName = stationName;
    }

    public String getWarehouseName() {
        return warehouseName;
    }

    public void setWarehouseName(String warehouseName) {
        this.warehouseName = warehouseName;
    }

    public Integer getBalance() {
        return balance;
    }

    public void setBalance(Integer balance) {
        this.balance = balance;
    }

    public String getRemark() {
        return remark;
    }

    public void setRemark(String remark) {
        this.remark = remark;
    }
}
