package com.bucketwater.oms.module.admin.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public class OrderManagementDTO {
    private Long id;
    private String orderNo;
    private Long stationId;
    private String stationName;
    private String stationAddress;
    private Long warehouseId;
    private String warehouseName;
    private Long driverId;
    private String driverName;
    private String status;
    private String statusText;
    private BigDecimal totalAmount;
    private String paymentType;
    private String paymentTypeText;
    private Integer totalBuckets;
    private Integer actualBuckets;
    private LocalDateTime createTime;
    private LocalDateTime reviewedAt;
    private LocalDateTime dispatchedAt;
    private LocalDateTime deliveredAt;
    private String rejectReason;
    private String signPhotos;
    private String contactName;
    private String contactPhone;
    private String deliveryAddress;
    private String remark;
    private List<OrderItemDTO> items;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getOrderNo() { return orderNo; }
    public void setOrderNo(String orderNo) { this.orderNo = orderNo; }
    public Long getStationId() { return stationId; }
    public void setStationId(Long stationId) { this.stationId = stationId; }
    public String getStationName() { return stationName; }
    public void setStationName(String stationName) { this.stationName = stationName; }
    public String getStationAddress() { return stationAddress; }
    public void setStationAddress(String stationAddress) { this.stationAddress = stationAddress; }
    public Long getWarehouseId() { return warehouseId; }
    public void setWarehouseId(Long warehouseId) { this.warehouseId = warehouseId; }
    public String getWarehouseName() { return warehouseName; }
    public void setWarehouseName(String warehouseName) { this.warehouseName = warehouseName; }
    public Long getDriverId() { return driverId; }
    public void setDriverId(Long driverId) { this.driverId = driverId; }
    public String getDriverName() { return driverName; }
    public void setDriverName(String driverName) { this.driverName = driverName; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getStatusText() { return statusText; }
    public void setStatusText(String statusText) { this.statusText = statusText; }
    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }
    public String getPaymentType() { return paymentType; }
    public void setPaymentType(String paymentType) { this.paymentType = paymentType; }
    public String getPaymentTypeText() { return paymentTypeText; }
    public void setPaymentTypeText(String paymentTypeText) { this.paymentTypeText = paymentTypeText; }
    public Integer getTotalBuckets() { return totalBuckets; }
    public void setTotalBuckets(Integer totalBuckets) { this.totalBuckets = totalBuckets; }
    public Integer getActualBuckets() { return actualBuckets; }
    public void setActualBuckets(Integer actualBuckets) { this.actualBuckets = actualBuckets; }
    public LocalDateTime getCreateTime() { return createTime; }
    public void setCreateTime(LocalDateTime createTime) { this.createTime = createTime; }
    public LocalDateTime getReviewedAt() { return reviewedAt; }
    public void setReviewedAt(LocalDateTime reviewedAt) { this.reviewedAt = reviewedAt; }
    public LocalDateTime getDispatchedAt() { return dispatchedAt; }
    public void setDispatchedAt(LocalDateTime dispatchedAt) { this.dispatchedAt = dispatchedAt; }
    public LocalDateTime getDeliveredAt() { return deliveredAt; }
    public void setDeliveredAt(LocalDateTime deliveredAt) { this.deliveredAt = deliveredAt; }
    public String getRejectReason() { return rejectReason; }
    public void setRejectReason(String rejectReason) { this.rejectReason = rejectReason; }
    public String getSignPhotos() { return signPhotos; }
    public void setSignPhotos(String signPhotos) { this.signPhotos = signPhotos; }
    public String getContactName() { return contactName; }
    public void setContactName(String contactName) { this.contactName = contactName; }
    public String getContactPhone() { return contactPhone; }
    public void setContactPhone(String contactPhone) { this.contactPhone = contactPhone; }
    public String getDeliveryAddress() { return deliveryAddress; }
    public void setDeliveryAddress(String deliveryAddress) { this.deliveryAddress = deliveryAddress; }
    public String getRemark() { return remark; }
    public void setRemark(String remark) { this.remark = remark; }
    public List<OrderItemDTO> getItems() { return items; }
    public void setItems(List<OrderItemDTO> items) { this.items = items; }

    public static class OrderItemDTO {
        private Long productId;
        private String productName;
        private Integer quantity;
        private Integer actualQty;
        private BigDecimal unitPrice;
        private BigDecimal subtotal;

        public Long getProductId() { return productId; }
        public void setProductId(Long productId) { this.productId = productId; }
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

    public static class OrderQueryDTO {
        private String keyword;
        private String status;
        private Long warehouseId;
        private Long stationId;
        private String startDate;
        private String endDate;
        private Integer page;
        private Integer size;

        public String getKeyword() { return keyword; }
        public void setKeyword(String keyword) { this.keyword = keyword; }
        public String getStatus() { return status; }
        public void setStatus(String status) { this.status = status; }
        public Long getWarehouseId() { return warehouseId; }
        public void setWarehouseId(Long warehouseId) { this.warehouseId = warehouseId; }
        public Long getStationId() { return stationId; }
        public void setStationId(Long stationId) { this.stationId = stationId; }
        public String getStartDate() { return startDate; }
        public void setStartDate(String startDate) { this.startDate = startDate; }
        public String getEndDate() { return endDate; }
        public void setEndDate(String endDate) { this.endDate = endDate; }
        public Integer getPage() { return page; }
        public void setPage(Integer page) { this.page = page; }
        public Integer getSize() { return size; }
        public void setSize(Integer size) { this.size = size; }
    }

    public static class OrderPageResult {
        private List<OrderManagementDTO> records;
        private Long total;
        private Integer page;
        private Integer size;
        private Integer totalPages;

        public List<OrderManagementDTO> getRecords() { return records; }
        public void setRecords(List<OrderManagementDTO> records) { this.records = records; }
        public Long getTotal() { return total; }
        public void setTotal(Long total) { this.total = total; }
        public Integer getPage() { return page; }
        public void setPage(Integer page) { this.page = page; }
        public Integer getSize() { return size; }
        public void setSize(Integer size) { this.size = size; }
        public Integer getTotalPages() { return totalPages; }
        public void setTotalPages(Integer totalPages) { this.totalPages = totalPages; }
    }
}
