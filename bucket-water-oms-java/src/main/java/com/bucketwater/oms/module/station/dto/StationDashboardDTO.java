package com.bucketwater.oms.module.station.dto;

import java.math.BigDecimal;
import java.util.List;

public class StationDashboardDTO {
    private String stationId;
    private String stationName;
    private String contact;
    private String contactPhone;
    private String address;
    private BigDecimal accountBalance;
    private BigDecimal creditLimit;
    private BigDecimal usedCredit;
    private BigDecimal availableCredit;
    private Integer owedBucketNum;
    private Integer owedThreshold;
    private Boolean overThreshold;
    private List<RecentOrderDTO> recentOrders;
    private List<NotificationDTO> notifications;

    public StationDashboardDTO() {}

    public StationDashboardDTO(BigDecimal accountBalance, BigDecimal creditLimit, BigDecimal usedCredit,
                            BigDecimal availableCredit, Integer owedBucketNum, Integer owedThreshold,
                            Boolean overThreshold, List<RecentOrderDTO> recentOrders, List<NotificationDTO> notifications) {
        this.accountBalance = accountBalance;
        this.creditLimit = creditLimit;
        this.usedCredit = usedCredit;
        this.availableCredit = availableCredit;
        this.owedBucketNum = owedBucketNum;
        this.owedThreshold = owedThreshold;
        this.overThreshold = overThreshold;
        this.recentOrders = recentOrders;
        this.notifications = notifications;
    }

    public BigDecimal getAccountBalance() { return accountBalance; }
    public void setAccountBalance(BigDecimal accountBalance) { this.accountBalance = accountBalance; }
    public BigDecimal getCreditLimit() { return creditLimit; }
    public void setCreditLimit(BigDecimal creditLimit) { this.creditLimit = creditLimit; }
    public BigDecimal getUsedCredit() { return usedCredit; }
    public void setUsedCredit(BigDecimal usedCredit) { this.usedCredit = usedCredit; }
    public BigDecimal getAvailableCredit() { return availableCredit; }
    public void setAvailableCredit(BigDecimal availableCredit) { this.availableCredit = availableCredit; }
    public Integer getOwedBucketNum() { return owedBucketNum; }
    public void setOwedBucketNum(Integer owedBucketNum) { this.owedBucketNum = owedBucketNum; }
    public Integer getOwedThreshold() { return owedThreshold; }
    public void setOwedThreshold(Integer owedThreshold) { this.owedThreshold = owedThreshold; }
    public Boolean getOverThreshold() { return overThreshold; }
    public void setOverThreshold(Boolean overThreshold) { this.overThreshold = overThreshold; }
    public List<RecentOrderDTO> getRecentOrders() { return recentOrders; }
    public void setRecentOrders(List<RecentOrderDTO> recentOrders) { this.recentOrders = recentOrders; }
    public List<NotificationDTO> getNotifications() { return notifications; }
    public void setNotifications(List<NotificationDTO> notifications) { this.notifications = notifications; }

    public String getStationId() { return stationId; }
    public void setStationId(String stationId) { this.stationId = stationId; }
    public String getStationName() { return stationName; }
    public void setStationName(String stationName) { this.stationName = stationName; }
    public String getContact() { return contact; }
    public void setContact(String contact) { this.contact = contact; }
    public String getContactPhone() { return contactPhone; }
    public void setContactPhone(String contactPhone) { this.contactPhone = contactPhone; }
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public static class RecentOrderDTO {
        private String orderId;
        private String orderNo;
        private String status;
        private String statusText;
        private BigDecimal totalAmount;
        private Integer totalQuantity;
        private String createdAt;

        public RecentOrderDTO() {}

        public RecentOrderDTO(String orderId, String orderNo, String status, String statusText,
                           BigDecimal totalAmount, Integer totalQuantity, String createdAt) {
            this.orderId = orderId;
            this.orderNo = orderNo;
            this.status = status;
            this.statusText = statusText;
            this.totalAmount = totalAmount;
            this.totalQuantity = totalQuantity;
            this.createdAt = createdAt;
        }

        public String getOrderId() { return orderId; }
        public void setOrderId(String orderId) { this.orderId = orderId; }
        public String getOrderNo() { return orderNo; }
        public void setOrderNo(String orderNo) { this.orderNo = orderNo; }
        public String getStatus() { return status; }
        public void setStatus(String status) { this.status = status; }
        public String getStatusText() { return statusText; }
        public void setStatusText(String statusText) { this.statusText = statusText; }
        public BigDecimal getTotalAmount() { return totalAmount; }
        public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }
        public Integer getTotalQuantity() { return totalQuantity; }
        public void setTotalQuantity(Integer totalQuantity) { this.totalQuantity = totalQuantity; }
        public String getCreatedAt() { return createdAt; }
        public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
    }

    public static class NotificationDTO {
        private String id;
        private String title;
        private String content;
        private String type;
        private String createdAt;

        public NotificationDTO() {}

        public NotificationDTO(String id, String title, String content, String type, String createdAt) {
            this.id = id;
            this.title = title;
            this.content = content;
            this.type = type;
            this.createdAt = createdAt;
        }

        public String getId() { return id; }
        public void setId(String id) { this.id = id; }
        public String getTitle() { return title; }
        public void setTitle(String title) { this.title = title; }
        public String getContent() { return content; }
        public void setContent(String content) { this.content = content; }
        public String getType() { return type; }
        public void setType(String type) { this.type = type; }
        public String getCreatedAt() { return createdAt; }
        public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
    }
}
