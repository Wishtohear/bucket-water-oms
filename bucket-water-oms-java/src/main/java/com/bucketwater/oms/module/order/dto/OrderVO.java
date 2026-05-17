package com.bucketwater.oms.module.order.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Schema(description = "订单VO")
public class OrderVO {

    @Schema(description = "订单ID")
    private String orderId;

    @Schema(description = "订单号")
    private String orderNo;

    @Schema(description = "水站ID")
    private String stationId;

    @Schema(description = "水站名称")
    private String stationName;

    @Schema(description = "仓库ID")
    private String warehouseId;

    @Schema(description = "仓库名称")
    private String warehouseName;

    @Schema(description = "司机ID")
    private String driverId;

    @Schema(description = "司机名称")
    private String driverName;

    @Schema(description = "状态")
    private String status;

    @Schema(description = "状态文本")
    private String statusText;

    @Schema(description = "订单进度")
    private List<ProgressItem> progress;

    @Schema(description = "总金额")
    private BigDecimal totalAmount;

    @Schema(description = "桶数")
    private Integer totalBuckets;

    @Schema(description = "实际桶数")
    private Integer actualBuckets;

    @Schema(description = "支付方式")
    private String paymentType;

    @Schema(description = "支付方式文本")
    private String paymentTypeText;

    @Schema(description = "创建时间")
    private LocalDateTime createTime;

    @Schema(description = "商品列表")
    private List<OrderItemVO> items;

    @Schema(description = "配送地址")
    private String deliveryAddress;

    @Schema(description = "联系人")
    private String contactName;

    @Schema(description = "联系电话")
    private String contactPhone;

    @Schema(description = "水站纬度")
    private BigDecimal stationLat;

    @Schema(description = "水站经度")
    private BigDecimal stationLng;

    @Schema(description = "纬度 (兼容移动端)")
    private BigDecimal latitude;

    @Schema(description = "经度 (兼容移动端)")
    private BigDecimal longitude;

    @Schema(description = "总数量 (兼容移动端)")
    private Integer totalQuantity;

    @Schema(description = "仓库信息")
    private WarehouseInfo warehouse;

    @Schema(description = "司机信息")
    private DriverInfo driver;

    @Schema(description = "空桶信息")
    private BucketReturn bucketReturn;

    @Schema(description = "拒单原因")
    private String rejectReason;

    @Schema(description = "签收照片")
    private List<String> signPhotos;

    @Schema(description = "是否可修改")
    private Boolean canModify;

    @Schema(description = "是否可取消")
    private Boolean canCancel;

    public OrderVO() {}

    public OrderVO(String orderId, String orderNo, String stationId, String stationName,
                  String warehouseId, String warehouseName, String driverId, String driverName,
                  String status, String statusText, List<ProgressItem> progress,
                  BigDecimal totalAmount, Integer totalBuckets, Integer actualBuckets,
                  String paymentType, String paymentTypeText, LocalDateTime createTime,
                  List<OrderItemVO> items, String deliveryAddress, String contactName,
                  String contactPhone, BigDecimal stationLat, BigDecimal stationLng,
                  String rejectReason, List<String> signPhotos,
                  Boolean canModify, Boolean canCancel) {
        this.orderId = orderId;
        this.orderNo = orderNo;
        this.stationId = stationId;
        this.stationName = stationName;
        this.warehouseId = warehouseId;
        this.warehouseName = warehouseName;
        this.driverId = driverId;
        this.driverName = driverName;
        this.status = status;
        this.statusText = statusText;
        this.progress = progress;
        this.totalAmount = totalAmount;
        this.totalBuckets = totalBuckets;
        this.actualBuckets = actualBuckets;
        this.paymentType = paymentType;
        this.paymentTypeText = paymentTypeText;
        this.createTime = createTime;
        this.items = items;
        this.deliveryAddress = deliveryAddress;
        this.contactName = contactName;
        this.contactPhone = contactPhone;
        this.stationLat = stationLat;
        this.stationLng = stationLng;
        this.rejectReason = rejectReason;
        this.signPhotos = signPhotos;
        this.canModify = canModify;
        this.canCancel = canCancel;
    }

    public String getOrderId() { return orderId; }
    public void setOrderId(String orderId) { this.orderId = orderId; }
    public String getOrderNo() { return orderNo; }
    public void setOrderNo(String orderNo) { this.orderNo = orderNo; }
    public String getStationId() { return stationId; }
    public void setStationId(String stationId) { this.stationId = stationId; }
    public String getStationName() { return stationName; }
    public void setStationName(String stationName) { this.stationName = stationName; }
    public String getWarehouseId() { return warehouseId; }
    public void setWarehouseId(String warehouseId) { this.warehouseId = warehouseId; }
    public String getWarehouseName() { return warehouseName; }
    public void setWarehouseName(String warehouseName) { this.warehouseName = warehouseName; }
    public String getDriverId() { return driverId; }
    public void setDriverId(String driverId) { this.driverId = driverId; }
    public String getDriverName() { return driverName; }
    public void setDriverName(String driverName) { this.driverName = driverName; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getStatusText() { return statusText; }
    public void setStatusText(String statusText) { this.statusText = statusText; }
    public List<ProgressItem> getProgress() { return progress; }
    public void setProgress(List<ProgressItem> progress) { this.progress = progress; }
    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }
    public Integer getTotalBuckets() { return totalBuckets; }
    public void setTotalBuckets(Integer totalBuckets) { this.totalBuckets = totalBuckets; }
    public Integer getActualBuckets() { return actualBuckets; }
    public void setActualBuckets(Integer actualBuckets) { this.actualBuckets = actualBuckets; }
    public String getPaymentType() { return paymentType; }
    public void setPaymentType(String paymentType) { this.paymentType = paymentType; }
    public String getPaymentTypeText() { return paymentTypeText; }
    public void setPaymentTypeText(String paymentTypeText) { this.paymentTypeText = paymentTypeText; }
    public LocalDateTime getCreateTime() { return createTime; }
    public void setCreateTime(LocalDateTime createTime) { this.createTime = createTime; }
    public LocalDateTime getCreatedAt() { return createTime; }
    public void setCreatedAt(LocalDateTime createTime) { this.createTime = createTime; }
    public List<OrderItemVO> getItems() { return items; }
    public void setItems(List<OrderItemVO> items) { this.items = items; }
    public String getDeliveryAddress() { return deliveryAddress; }
    public void setDeliveryAddress(String deliveryAddress) { this.deliveryAddress = deliveryAddress; }
    public String getContactName() { return contactName; }
    public void setContactName(String contactName) { this.contactName = contactName; }
    public String getContactPhone() { return contactPhone; }
    public void setContactPhone(String contactPhone) { this.contactPhone = contactPhone; }
    public BigDecimal getStationLat() { return stationLat; }
    public void setStationLat(BigDecimal stationLat) { this.stationLat = stationLat; }
    public BigDecimal getStationLng() { return stationLng; }
    public void setStationLng(BigDecimal stationLng) { this.stationLng = stationLng; }
    public String getRejectReason() { return rejectReason; }
    public void setRejectReason(String rejectReason) { this.rejectReason = rejectReason; }
    public List<String> getSignPhotos() { return signPhotos; }
    public void setSignPhotos(List<String> signPhotos) { this.signPhotos = signPhotos; }
    public Boolean getCanModify() { return canModify; }
    public void setCanModify(Boolean canModify) { this.canModify = canModify; }
    public Boolean getCanCancel() { return canCancel; }
    public void setCanCancel(Boolean canCancel) { this.canCancel = canCancel; }

    public BigDecimal getLatitude() { return latitude; }
    public void setLatitude(BigDecimal latitude) { this.latitude = latitude; }
    public BigDecimal getLongitude() { return longitude; }
    public void setLongitude(BigDecimal longitude) { this.longitude = longitude; }
    public Integer getTotalQuantity() { return totalBuckets; }
    public void setTotalQuantity(Integer totalQuantity) { this.totalBuckets = totalQuantity; }

    public WarehouseInfo getWarehouse() { return null; }
    public void setWarehouse(WarehouseInfo warehouse) {}
    public DriverInfo getDriver() { return null; }
    public void setDriver(DriverInfo driver) {}
    public BucketReturn getBucketReturn() { return null; }
    public void setBucketReturn(BucketReturn bucketReturn) {}

    @Schema(description = "订单商品项")
    public static class OrderItemVO {
        @Schema(description = "商品ID")
        private String productId;
        @Schema(description = "商品名称")
        private String productName;
        @Schema(description = "订购数量")
        private Integer quantity;
        @Schema(description = "实际配送数量")
        private Integer actualQty;
        @Schema(description = "单价")
        private BigDecimal unitPrice;
        @Schema(description = "小计金额")
        private BigDecimal subtotal;

        public OrderItemVO() {}

        public OrderItemVO(String productId, String productName, Integer quantity,
                         Integer actualQty, BigDecimal unitPrice, BigDecimal subtotal) {
            this.productId = productId;
            this.productName = productName;
            this.quantity = quantity;
            this.actualQty = actualQty;
            this.unitPrice = unitPrice;
            this.subtotal = subtotal;
        }

        public String getProductId() { return productId; }
        public void setProductId(String productId) { this.productId = productId; }
        public String getProductName() { return productName; }
        public void setProductName(String productName) { this.productName = productName; }
        public Integer getQuantity() { return quantity; }
        public void setQuantity(Integer quantity) { this.quantity = quantity; }
        public Integer getActualQty() { return actualQty; }
        public void setActualQty(Integer actualQty) { this.actualQty = actualQty; }
        public BigDecimal getUnitPrice() { return unitPrice; }
        public void setUnitPrice(BigDecimal unitPrice) { this.unitPrice = unitPrice; }
        public BigDecimal getSubtotal() { return subtotal; }
        public void setSubtotal(BigDecimal subtotal) { this.subtotal = subtotal; }
    }

    @Schema(description = "仓库信息")
    public static class WarehouseInfo {
        @Schema(description = "仓库ID")
        private String id;
        @Schema(description = "仓库名称")
        private String name;

        public WarehouseInfo() {}

        public WarehouseInfo(String id, String name) {
            this.id = id;
            this.name = name;
        }

        public String getId() { return id; }
        public void setId(String id) { this.id = id; }
        public String getName() { return name; }
        public void setName(String name) { this.name = name; }
    }

    @Schema(description = "司机信息")
    public static class DriverInfo {
        @Schema(description = "司机ID")
        private String id;
        @Schema(description = "姓名")
        private String name;
        @Schema(description = "电话")
        private String phone;

        public DriverInfo() {}

        public DriverInfo(String id, String name, String phone) {
            this.id = id;
            this.name = name;
            this.phone = phone;
        }

        public String getId() { return id; }
        public void setId(String id) { this.id = id; }
        public String getName() { return name; }
        public void setName(String name) { this.name = name; }
        public String getPhone() { return phone; }
        public void setPhone(String phone) { this.phone = phone; }
    }

    @Schema(description = "订单进度项")
    public static class ProgressItem {
        @Schema(description = "状态")
        private String status;
        @Schema(description = "状态文本")
        private String statusText;
        @Schema(description = "时间")
        private LocalDateTime time;

        public ProgressItem() {}

        public ProgressItem(String status, String statusText, LocalDateTime time) {
            this.status = status;
            this.statusText = statusText;
            this.time = time;
        }

        public String getStatus() { return status; }
        public void setStatus(String status) { this.status = status; }
        public String getStatusText() { return statusText; }
        public void setStatusText(String statusText) { this.statusText = statusText; }
        public LocalDateTime getTime() { return time; }
        public void setTime(LocalDateTime time) { this.time = time; }
    }

    @Schema(description = "空桶信息")
    public static class BucketReturn {
        @Schema(description = "本次回收数量")
        private Integer returnedQty;
        @Schema(description = "本次欠桶数量")
        private Integer owedQty;
        @Schema(description = "累计欠桶数量")
        private Integer totalOwed;

        public BucketReturn() {}

        public BucketReturn(Integer returnedQty, Integer owedQty, Integer totalOwed) {
            this.returnedQty = returnedQty;
            this.owedQty = owedQty;
            this.totalOwed = totalOwed;
        }

        public Integer getReturnedQty() { return returnedQty; }
        public void setReturnedQty(Integer returnedQty) { this.returnedQty = returnedQty; }
        public Integer getOwedQty() { return owedQty; }
        public void setOwedQty(Integer owedQty) { this.owedQty = owedQty; }
        public Integer getTotalOwed() { return totalOwed; }
        public void setTotalOwed(Integer totalOwed) { this.totalOwed = totalOwed; }
    }
}
