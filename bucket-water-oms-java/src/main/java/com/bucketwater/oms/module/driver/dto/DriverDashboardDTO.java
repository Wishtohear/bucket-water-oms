package com.bucketwater.oms.module.driver.dto;

import java.math.BigDecimal;
import java.util.List;

public class DriverDashboardDTO {
    private Integer todayDeliveries;
    private Integer pendingDeliveries;
    private Integer completedDeliveries;
    private Integer totalBucketsOnWay;
    private Integer owedBuckets;
    private Integer bucketThreshold;
    private BigDecimal todayEarnings;
    private String driverName;
    private String warehouseName;
    private List<TaskDTO> recentTasks;
    private List<NotificationDTO> notifications;

    public Integer getTodayDeliveries() {
        return todayDeliveries;
    }

    public void setTodayDeliveries(Integer todayDeliveries) {
        this.todayDeliveries = todayDeliveries;
    }

    public Integer getPendingDeliveries() {
        return pendingDeliveries;
    }

    public void setPendingDeliveries(Integer pendingDeliveries) {
        this.pendingDeliveries = pendingDeliveries;
    }

    public Integer getCompletedDeliveries() {
        return completedDeliveries;
    }

    public void setCompletedDeliveries(Integer completedDeliveries) {
        this.completedDeliveries = completedDeliveries;
    }

    public Integer getTotalBucketsOnWay() {
        return totalBucketsOnWay;
    }

    public void setTotalBucketsOnWay(Integer totalBucketsOnWay) {
        this.totalBucketsOnWay = totalBucketsOnWay;
    }

    public Integer getOwedBuckets() {
        return owedBuckets;
    }

    public void setOwedBuckets(Integer owedBuckets) {
        this.owedBuckets = owedBuckets;
    }

    public Integer getBucketThreshold() {
        return bucketThreshold;
    }

    public void setBucketThreshold(Integer bucketThreshold) {
        this.bucketThreshold = bucketThreshold;
    }

    public BigDecimal getTodayEarnings() {
        return todayEarnings;
    }

    public void setTodayEarnings(BigDecimal todayEarnings) {
        this.todayEarnings = todayEarnings;
    }

    public String getDriverName() {
        return driverName;
    }

    public void setDriverName(String driverName) {
        this.driverName = driverName;
    }

    public String getWarehouseName() {
        return warehouseName;
    }

    public void setWarehouseName(String warehouseName) {
        this.warehouseName = warehouseName;
    }

    public List<TaskDTO> getRecentTasks() {
        return recentTasks;
    }

    public void setRecentTasks(List<TaskDTO> recentTasks) {
        this.recentTasks = recentTasks;
    }

    public List<NotificationDTO> getNotifications() {
        return notifications;
    }

    public void setNotifications(List<NotificationDTO> notifications) {
        this.notifications = notifications;
    }

    public static class TaskDTO {
        private String id;
        private String taskNo;
        private String orderId;
        private String orderNo;
        private String stationId;
        private String stationName;
        private String contactName;
        private String contactPhone;
        private String address;
        private Double latitude;
        private Double longitude;
        private Double distance;
        private Integer sequence;
        private String status;
        private String statusText;
        private Integer bucketCount;
        private Integer totalQuantity;
        private Double amount;
        private String createdAt;

        public TaskDTO() {}

        public String getId() {
            return id;
        }

        public void setId(String id) {
            this.id = id;
        }

        public String getTaskNo() {
            return taskNo;
        }

        public void setTaskNo(String taskNo) {
            this.taskNo = taskNo;
        }

        public String getOrderId() {
            return orderId;
        }

        public void setOrderId(String orderId) {
            this.orderId = orderId;
        }

        public String getOrderNo() {
            return orderNo;
        }

        public void setOrderNo(String orderNo) {
            this.orderNo = orderNo;
        }

        public String getStationId() {
            return stationId;
        }

        public void setStationId(String stationId) {
            this.stationId = stationId;
        }

        public String getStationName() {
            return stationName;
        }

        public void setStationName(String stationName) {
            this.stationName = stationName;
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

        public String getAddress() {
            return address;
        }

        public void setAddress(String address) {
            this.address = address;
        }

        public Double getLatitude() {
            return latitude;
        }

        public void setLatitude(Double latitude) {
            this.latitude = latitude;
        }

        public Double getLongitude() {
            return longitude;
        }

        public void setLongitude(Double longitude) {
            this.longitude = longitude;
        }

        public Double getDistance() {
            return distance;
        }

        public void setDistance(Double distance) {
            this.distance = distance;
        }

        public Integer getSequence() {
            return sequence;
        }

        public void setSequence(Integer sequence) {
            this.sequence = sequence;
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

        public Integer getBucketCount() {
            return bucketCount;
        }

        public void setBucketCount(Integer bucketCount) {
            this.bucketCount = bucketCount;
        }

        public Integer getTotalQuantity() {
            return totalQuantity;
        }

        public void setTotalQuantity(Integer totalQuantity) {
            this.totalQuantity = totalQuantity;
        }

        public Double getAmount() {
            return amount;
        }

        public void setAmount(Double amount) {
            this.amount = amount;
        }

        public String getCreatedAt() {
            return createdAt;
        }

        public void setCreatedAt(String createdAt) {
            this.createdAt = createdAt;
        }
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

        public String getId() {
            return id;
        }

        public void setId(String id) {
            this.id = id;
        }

        public String getTitle() {
            return title;
        }

        public void setTitle(String title) {
            this.title = title;
        }

        public String getContent() {
            return content;
        }

        public void setContent(String content) {
            this.content = content;
        }

        public String getType() {
            return type;
        }

        public void setType(String type) {
            this.type = type;
        }

        public String getCreatedAt() {
            return createdAt;
        }

        public void setCreatedAt(String createdAt) {
            this.createdAt = createdAt;
        }
    }
}
