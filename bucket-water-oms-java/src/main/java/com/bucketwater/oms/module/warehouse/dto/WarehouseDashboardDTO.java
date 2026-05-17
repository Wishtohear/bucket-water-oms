package com.bucketwater.oms.module.warehouse.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import java.util.List;

@Schema(description = "仓库仪表盘DTO")
public class WarehouseDashboardDTO {
    private Integer todayInbound;
    private Integer todayOutbound;
    private Integer totalInventory;
    private Integer lowStockWarnings;
    private List<TaskDTO> recentTasks;
    private List<InventoryWarningDTO> inventoryWarnings;
    private List<NotificationDTO> notifications;
    @Schema(description = "仓库名称")
    private String warehouseName;
    @Schema(description = "仓库ID")
    private Long warehouseId;

    public WarehouseDashboardDTO() {}

    public WarehouseDashboardDTO(Integer todayInbound, Integer todayOutbound, Integer totalInventory,
                              Integer lowStockWarnings, List<TaskDTO> recentTasks,
                              List<InventoryWarningDTO> inventoryWarnings, List<NotificationDTO> notifications) {
        this.todayInbound = todayInbound;
        this.todayOutbound = todayOutbound;
        this.totalInventory = totalInventory;
        this.lowStockWarnings = lowStockWarnings;
        this.recentTasks = recentTasks;
        this.inventoryWarnings = inventoryWarnings;
        this.notifications = notifications;
    }

    public Integer getTodayInbound() { return todayInbound; }
    public void setTodayInbound(Integer todayInbound) { this.todayInbound = todayInbound; }
    public Integer getTodayOutbound() { return todayOutbound; }
    public void setTodayOutbound(Integer todayOutbound) { this.todayOutbound = todayOutbound; }
    public Integer getTotalInventory() { return totalInventory; }
    public void setTotalInventory(Integer totalInventory) { this.totalInventory = totalInventory; }
    public Integer getLowStockWarnings() { return lowStockWarnings; }
    public void setLowStockWarnings(Integer lowStockWarnings) { this.lowStockWarnings = lowStockWarnings; }
    public List<TaskDTO> getRecentTasks() { return recentTasks; }
    public void setRecentTasks(List<TaskDTO> recentTasks) { this.recentTasks = recentTasks; }
    public List<InventoryWarningDTO> getInventoryWarnings() { return inventoryWarnings; }
    public void setInventoryWarnings(List<InventoryWarningDTO> inventoryWarnings) { this.inventoryWarnings = inventoryWarnings; }
    public List<NotificationDTO> getNotifications() { return notifications; }
    public void setNotifications(List<NotificationDTO> notifications) { this.notifications = notifications; }
    public String getWarehouseName() { return warehouseName; }
    public void setWarehouseName(String warehouseName) { this.warehouseName = warehouseName; }
    public Long getWarehouseId() { return warehouseId; }
    public void setWarehouseId(Long warehouseId) { this.warehouseId = warehouseId; }

    @Schema(description = "任务DTO")
    public static class TaskDTO {
        private String taskId;
        private String taskNo;
        private String type;
        private String typeText;
        private String status;
        private String statusText;
        private String customerName;
        private Integer quantity;
        private String createdAt;

        public TaskDTO() {}

        public TaskDTO(String taskId, String taskNo, String type, String typeText,
                       String status, String statusText, String customerName, Integer quantity, String createdAt) {
            this.taskId = taskId;
            this.taskNo = taskNo;
            this.type = type;
            this.typeText = typeText;
            this.status = status;
            this.statusText = statusText;
            this.customerName = customerName;
            this.quantity = quantity;
            this.createdAt = createdAt;
        }

        public String getTaskId() { return taskId; }
        public void setTaskId(String taskId) { this.taskId = taskId; }
        public String getTaskNo() { return taskNo; }
        public void setTaskNo(String taskNo) { this.taskNo = taskNo; }
        public String getType() { return type; }
        public void setType(String type) { this.type = type; }
        public String getTypeText() { return typeText; }
        public void setTypeText(String typeText) { this.typeText = typeText; }
        public String getStatus() { return status; }
        public void setStatus(String status) { this.status = status; }
        public String getStatusText() { return statusText; }
        public void setStatusText(String statusText) { this.statusText = statusText; }
        public String getCustomerName() { return customerName; }
        public void setCustomerName(String customerName) { this.customerName = customerName; }
        public Integer getQuantity() { return quantity; }
        public void setQuantity(Integer quantity) { this.quantity = quantity; }
        public String getCreatedAt() { return createdAt; }
        public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
    }

    @Schema(description = "库存预警DTO")
    public static class InventoryWarningDTO {
        private String productId;
        private String productName;
        private Integer currentStock;
        private Integer safeStock;
        private String warehouseName;

        public InventoryWarningDTO() {}

        public InventoryWarningDTO(String productId, String productName, Integer currentStock, Integer safeStock, String warehouseName) {
            this.productId = productId;
            this.productName = productName;
            this.currentStock = currentStock;
            this.safeStock = safeStock;
            this.warehouseName = warehouseName;
        }

        public String getProductId() { return productId; }
        public void setProductId(String productId) { this.productId = productId; }
        public String getProductName() { return productName; }
        public void setProductName(String productName) { this.productName = productName; }
        public Integer getCurrentStock() { return currentStock; }
        public void setCurrentStock(Integer currentStock) { this.currentStock = currentStock; }
        public Integer getSafeStock() { return safeStock; }
        public void setSafeStock(Integer safeStock) { this.safeStock = safeStock; }
        public String getWarehouseName() { return warehouseName; }
        public void setWarehouseName(String warehouseName) { this.warehouseName = warehouseName; }
    }

    @Schema(description = "通知DTO")
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
