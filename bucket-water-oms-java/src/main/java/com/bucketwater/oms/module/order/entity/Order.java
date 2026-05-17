package com.bucketwater.oms.module.order.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Data
@TableName("orders")
@Schema(description = "订单实体")
public class Order {

    @TableId(type = IdType.AUTO)
    @Schema(description = "主键ID")
    private Long id;

    @Schema(description = "订单号")
    private String orderNo;

    @TableField("station_id")
    @Schema(description = "水站ID")
    private Long stationId;

    @TableField("warehouse_id")
    @Schema(description = "仓库ID")
    private Long warehouseId;

    @TableField("driver_id")
    @Schema(description = "司机ID")
    private Long driverId;

    @TableField("factory_id")
    @Schema(description = "所属水厂ID")
    private Long factoryId;

    @Schema(description = "状态: pending_review/reviewed/dispatched/delivering/completed/cancelled/rejected")
    private String status;

    @Schema(description = "订单总金额")
    private BigDecimal totalAmount;

    @Schema(description = "订单下单桶数")
    private Integer orderBuckets;

    @Schema(description = "支付方式: prepaid/monthly/credit")
    private String paymentType;

    @Schema(description = "配送地址")
    private String deliveryAddress;

    @Schema(description = "联系人")
    private String contactName;

    @Schema(description = "联系电话")
    private String contactPhone;

    @Schema(description = "拒单原因")
    private String rejectReason;

    @Schema(description = "库存不足明细(JSON)")
    private String stockDetails;

    @Schema(description = "订单备注")
    @TableField(exist = false)
    private String remark;

    @Schema(description = "创建时间")
    private LocalDateTime createTime;

    @Schema(description = "更新时间")
    private LocalDateTime updateTime;

    @Schema(description = "审查时间")
    private LocalDateTime reviewedAt;

    @Schema(description = "派单时间")
    private LocalDateTime dispatchedAt;

    @Schema(description = "完成时间")
    private LocalDateTime deliveredAt;

    @Schema(description = "签收照片(JSON数组)")
    private String signPhotos;

    @Schema(description = "实际配送商品数量")
    private Integer deliveredQty;

    @Schema(description = "签收类型: signature/sms_code/boss_confirm")
    private String signType;

    @Schema(description = "签字数据(Base64图片或签名坐标JSON)")
    private String signData;

    @Schema(description = "签收时间")
    private LocalDateTime signTime;

    @Schema(description = "打卡纬度")
    private BigDecimal checkInLat;

    @Schema(description = "打卡经度")
    private BigDecimal checkInLng;

    @Schema(description = "打卡时间")
    private LocalDateTime checkInTime;

    @Schema(description = "打卡位置地址")
    private String checkInAddress;

    @Schema(description = "订单商品明细")
    private transient List<OrderItem> items;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getOrderNo() {
        return orderNo;
    }

    public void setOrderNo(String orderNo) {
        this.orderNo = orderNo;
    }

    public Long getStationId() {
        return stationId;
    }

    public void setStationId(Long stationId) {
        this.stationId = stationId;
    }

    public Long getWarehouseId() {
        return warehouseId;
    }

    public void setWarehouseId(Long warehouseId) {
        this.warehouseId = warehouseId;
    }

    public Long getDriverId() {
        return driverId;
    }

    public void setDriverId(Long driverId) {
        this.driverId = driverId;
    }

    public Long getFactoryId() {
        return factoryId;
    }

    public void setFactoryId(Long factoryId) {
        this.factoryId = factoryId;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public BigDecimal getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(BigDecimal totalAmount) {
        this.totalAmount = totalAmount;
    }

    public Integer getOrderBuckets() {
        return orderBuckets;
    }

    public void setOrderBuckets(Integer orderBuckets) {
        this.orderBuckets = orderBuckets;
    }

    public String getPaymentType() {
        return paymentType;
    }

    public void setPaymentType(String paymentType) {
        this.paymentType = paymentType;
    }

    public String getDeliveryAddress() {
        return deliveryAddress;
    }

    public void setDeliveryAddress(String deliveryAddress) {
        this.deliveryAddress = deliveryAddress;
    }

    public String getContactName() {
        return contactName;
    }

    public void setContactName(String contactName) {
        this.contactName = contactName;
    }

    public String getContactPhone() {
        return contactPhone;
    }

    public void setContactPhone(String contactPhone) {
        this.contactPhone = contactPhone;
    }

    public String getRejectReason() {
        return rejectReason;
    }

    public void setRejectReason(String rejectReason) {
        this.rejectReason = rejectReason;
    }

    public String getRemark() {
        return remark;
    }

    public void setRemark(String remark) {
        this.remark = remark;
    }

    public LocalDateTime getCreateTime() {
        return createTime;
    }

    public void setCreateTime(LocalDateTime createTime) {
        this.createTime = createTime;
    }

    public LocalDateTime getUpdateTime() {
        return updateTime;
    }

    public void setUpdateTime(LocalDateTime updateTime) {
        this.updateTime = updateTime;
    }

    public LocalDateTime getReviewedAt() {
        return reviewedAt;
    }

    public void setReviewedAt(LocalDateTime reviewedAt) {
        this.reviewedAt = reviewedAt;
    }

    public LocalDateTime getDispatchedAt() {
        return dispatchedAt;
    }

    public void setDispatchedAt(LocalDateTime dispatchedAt) {
        this.dispatchedAt = dispatchedAt;
    }

    public LocalDateTime getDeliveredAt() {
        return deliveredAt;
    }

    public void setDeliveredAt(LocalDateTime deliveredAt) {
        this.deliveredAt = deliveredAt;
    }

    public String getSignPhotos() {
        return signPhotos;
    }

    public void setSignPhotos(String signPhotos) {
        this.signPhotos = signPhotos;
    }

    public Integer getDeliveredQty() {
        return deliveredQty;
    }

    public void setDeliveredQty(Integer deliveredQty) {
        this.deliveredQty = deliveredQty;
    }

    public String getSignType() {
        return signType;
    }

    public void setSignType(String signType) {
        this.signType = signType;
    }

    public String getSignData() {
        return signData;
    }

    public void setSignData(String signData) {
        this.signData = signData;
    }

    public LocalDateTime getSignTime() {
        return signTime;
    }

    public void setSignTime(LocalDateTime signTime) {
        this.signTime = signTime;
    }

    public BigDecimal getCheckInLat() {
        return checkInLat;
    }

    public void setCheckInLat(BigDecimal checkInLat) {
        this.checkInLat = checkInLat;
    }

    public BigDecimal getCheckInLng() {
        return checkInLng;
    }

    public void setCheckInLng(BigDecimal checkInLng) {
        this.checkInLng = checkInLng;
    }

    public LocalDateTime getCheckInTime() {
        return checkInTime;
    }

    public void setCheckInTime(LocalDateTime checkInTime) {
        this.checkInTime = checkInTime;
    }

    public String getCheckInAddress() {
        return checkInAddress;
    }

    public void setCheckInAddress(String checkInAddress) {
        this.checkInAddress = checkInAddress;
    }

    public List<OrderItem> getItems() {
        return items;
    }

    public void setItems(List<OrderItem> items) {
        this.items = items;
    }
}
