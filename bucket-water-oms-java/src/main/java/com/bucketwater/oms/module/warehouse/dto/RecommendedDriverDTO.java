package com.bucketwater.oms.module.warehouse.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;

/**
 * 推荐司机 DTO
 */
@Schema(description = "推荐司机响应DTO")
public class RecommendedDriverDTO {

    @Schema(description = "司机ID")
    private String driverId;

    @Schema(description = "司机工号")
    private String code;

    @Schema(description = "姓名")
    private String name;

    @Schema(description = "联系电话")
    private String phone;

    @Schema(description = "当前纬度")
    private BigDecimal currentLat;

    @Schema(description = "当前经度")
    private BigDecimal currentLng;

    @Schema(description = "在线状态: online/offline/break")
    private String onlineStatus;

    @Schema(description = "在线状态文本")
    private String onlineStatusText;

    @Schema(description = "当前待配送任务数")
    private Integer currentTaskCount;

    @Schema(description = "今日已完成配送数")
    private Integer todayCompletedCount;

    @Schema(description = "历史评分 (0-100)")
    private Integer rating;

    @Schema(description = "总配送数")
    private Integer totalDeliveries;

    @Schema(description = "推荐原因: distance(距离最近)/min_tasks(任务最少)/online(在线优先)")
    private String recommendReason;

    @Schema(description = "推荐原因文本")
    private String recommendReasonText;

    @Schema(description = "推荐得分 (0-100)")
    private Double recommendScore;

    @Schema(description = "距仓库距离(km)")
    private Double distanceToWarehouse;

    @Schema(description = "是否绑定当前仓库: true-绑定, false-非绑定(可跨仓库派单)")
    private Boolean boundToCurrentWarehouse;

    @Schema(description = "所属仓库名称(仅非绑定司机显示)")
    private String warehouseName;

    public RecommendedDriverDTO() {}

    public String getDriverId() { return driverId; }
    public void setDriverId(String driverId) { this.driverId = driverId; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public BigDecimal getCurrentLat() { return currentLat; }
    public void setCurrentLat(BigDecimal currentLat) { this.currentLat = currentLat; }

    public BigDecimal getCurrentLng() { return currentLng; }
    public void setCurrentLng(BigDecimal currentLng) { this.currentLng = currentLng; }

    public String getOnlineStatus() { return onlineStatus; }
    public void setOnlineStatus(String onlineStatus) { this.onlineStatus = onlineStatus; }

    public String getOnlineStatusText() { return onlineStatusText; }
    public void setOnlineStatusText(String onlineStatusText) { this.onlineStatusText = onlineStatusText; }

    public Integer getCurrentTaskCount() { return currentTaskCount; }
    public void setCurrentTaskCount(Integer currentTaskCount) { this.currentTaskCount = currentTaskCount; }

    public Integer getTodayCompletedCount() { return todayCompletedCount; }
    public void setTodayCompletedCount(Integer todayCompletedCount) { this.todayCompletedCount = todayCompletedCount; }

    public Integer getRating() { return rating; }
    public void setRating(Integer rating) { this.rating = rating; }

    public Integer getTotalDeliveries() { return totalDeliveries; }
    public void setTotalDeliveries(Integer totalDeliveries) { this.totalDeliveries = totalDeliveries; }

    public String getRecommendReason() { return recommendReason; }
    public void setRecommendReason(String recommendReason) { this.recommendReason = recommendReason; }

    public String getRecommendReasonText() { return recommendReasonText; }
    public void setRecommendReasonText(String recommendReasonText) { this.recommendReasonText = recommendReasonText; }

    public Double getRecommendScore() { return recommendScore; }
    public void setRecommendScore(Double recommendScore) { this.recommendScore = recommendScore; }

    public Double getDistanceToWarehouse() {
        return distanceToWarehouse;
    }

    public void setDistanceToWarehouse(Double distanceToWarehouse) {
        this.distanceToWarehouse = distanceToWarehouse;
    }

    public Boolean getBoundToCurrentWarehouse() {
        return boundToCurrentWarehouse;
    }

    public void setBoundToCurrentWarehouse(Boolean boundToCurrentWarehouse) {
        this.boundToCurrentWarehouse = boundToCurrentWarehouse;
    }

    public String getWarehouseName() {
        return warehouseName;
    }

    public void setWarehouseName(String warehouseName) {
        this.warehouseName = warehouseName;
    }
}
