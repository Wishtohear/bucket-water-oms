package com.bucketwater.oms.module.map.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;
import java.util.List;

@Schema(description = "路线响应")
public class RouteDTO {

    @Schema(description = "起点")
    private Location origin;

    @Schema(description = "终点")
    private Location destination;

    @Schema(description = "总距离(米)")
    private BigDecimal distance;

    @Schema(description = "预计时长(秒)")
    private Integer duration;

    @Schema(description = "路线点")
    private List<Location> points;

    @Schema(description = "路线编码")
    private String polyline;

    public RouteDTO() {}

    public RouteDTO(Location origin, Location destination, BigDecimal distance,
                  Integer duration, List<Location> points, String polyline) {
        this.origin = origin;
        this.destination = destination;
        this.distance = distance;
        this.duration = duration;
        this.points = points;
        this.polyline = polyline;
    }

    public Location getOrigin() {
        return origin;
    }

    public void setOrigin(Location origin) {
        this.origin = origin;
    }

    public Location getDestination() {
        return destination;
    }

    public void setDestination(Location destination) {
        this.destination = destination;
    }

    public BigDecimal getDistance() {
        return distance;
    }

    public void setDistance(BigDecimal distance) {
        this.distance = distance;
    }

    public Integer getDuration() {
        return duration;
    }

    public void setDuration(Integer duration) {
        this.duration = duration;
    }

    public List<Location> getPoints() {
        return points;
    }

    public void setPoints(List<Location> points) {
        this.points = points;
    }

    public String getPolyline() {
        return polyline;
    }

    public void setPolyline(String polyline) {
        this.polyline = polyline;
    }

    @Schema(description = "位置")
    public static class Location {

        @Schema(description = "纬度")
        private BigDecimal lat;

        @Schema(description = "经度")
        private BigDecimal lng;

        @Schema(description = "地址")
        private String address;

        public Location() {}

        public Location(BigDecimal lat, BigDecimal lng, String address) {
            this.lat = lat;
            this.lng = lng;
            this.address = address;
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

        public String getAddress() {
            return address;
        }

        public void setAddress(String address) {
            this.address = address;
        }
    }
}
