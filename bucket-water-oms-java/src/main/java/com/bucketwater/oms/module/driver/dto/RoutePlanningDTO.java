package com.bucketwater.oms.module.driver.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;
import java.util.List;

@Schema(description = "路线规划响应")
public class RoutePlanningDTO {

    @Schema(description = "总距离(公里)")
    private BigDecimal totalDistance;

    @Schema(description = "预计时长(分钟)")
    private Integer estimatedMinutes;

    @Schema(description = "途经点数量")
    private Integer pointCount;

    @Schema(description = "途经点")
    private List<Waypoint> waypoints;

    @Schema(description = "路线编码")
    private String polyline;

    public RoutePlanningDTO() {}

    public RoutePlanningDTO(BigDecimal totalDistance, Integer estimatedMinutes, Integer pointCount,
                          List<Waypoint> waypoints, String polyline) {
        this.totalDistance = totalDistance;
        this.estimatedMinutes = estimatedMinutes;
        this.pointCount = pointCount;
        this.waypoints = waypoints;
        this.polyline = polyline;
    }

    public BigDecimal getTotalDistance() {
        return totalDistance;
    }

    public void setTotalDistance(BigDecimal totalDistance) {
        this.totalDistance = totalDistance;
    }

    public Integer getEstimatedMinutes() {
        return estimatedMinutes;
    }

    public void setEstimatedMinutes(Integer estimatedMinutes) {
        this.estimatedMinutes = estimatedMinutes;
    }

    public Integer getPointCount() {
        return pointCount;
    }

    public void setPointCount(Integer pointCount) {
        this.pointCount = pointCount;
    }

    public List<Waypoint> getWaypoints() {
        return waypoints;
    }

    public void setWaypoints(List<Waypoint> waypoints) {
        this.waypoints = waypoints;
    }

    public String getPolyline() {
        return polyline;
    }

    public void setPolyline(String polyline) {
        this.polyline = polyline;
    }

    @Schema(description = "途经点")
    public static class Waypoint {

        @Schema(description = "类型: warehouse/station")
        private String type;

        @Schema(description = "ID")
        private String id;

        @Schema(description = "名称")
        private String name;

        @Schema(description = "纬度")
        private BigDecimal lat;

        @Schema(description = "经度")
        private BigDecimal lng;

        @Schema(description = "操作: pickup/deliver")
        private String action;

        @Schema(description = "订单ID")
        private String orderId;

        public Waypoint() {}

        public Waypoint(String type, String id, String name, BigDecimal lat, 
                       BigDecimal lng, String action, String orderId) {
            this.type = type;
            this.id = id;
            this.name = name;
            this.lat = lat;
            this.lng = lng;
            this.action = action;
            this.orderId = orderId;
        }

        public String getType() {
            return type;
        }

        public void setType(String type) {
            this.type = type;
        }

        public String getId() {
            return id;
        }

        public void setId(String id) {
            this.id = id;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public BigDecimal getLat() {
            return lat;
        }

        public void setLat(BigDecimal lat) {
            this.lat = lat;
        }

        public BigDecimal getLng() {
            return lng;
        }

        public void setLng(BigDecimal lng) {
            this.lng = lng;
        }

        public String getAction() {
            return action;
        }

        public void setAction(String action) {
            this.action = action;
        }

        public String getOrderId() {
            return orderId;
        }

        public void setOrderId(String orderId) {
            this.orderId = orderId;
        }
    }
}
