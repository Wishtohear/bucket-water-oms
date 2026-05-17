package com.bucketwater.oms.module.driver.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Schema(description = "司机位置历史记录DTO")
public class DriverLocationHistoryDTO {

    @Schema(description = "主键ID")
    private Long id;

    @Schema(description = "纬度")
    private BigDecimal lat;

    @Schema(description = "经度")
    private BigDecimal lng;

    @Schema(description = "速度(km/h)")
    private BigDecimal speed;

    @Schema(description = "方向角度")
    private Integer heading;

    @Schema(description = "当前位置地址")
    private String address;

    @Schema(description = "记录时间")
    private LocalDateTime recordTime;

    @Schema(description = "关联订单ID")
    private String orderId;

    @Schema(description = "位置类型")
    private String locationType;

    public static DriverLocationHistoryDTO fromEntity(
            com.bucketwater.oms.module.driver.entity.DriverLocationHistory entity) {
        if (entity == null) {
            return null;
        }
        DriverLocationHistoryDTO dto = new DriverLocationHistoryDTO();
        dto.setId(entity.getId());
        dto.setLat(entity.getLat());
        dto.setLng(entity.getLng());
        dto.setSpeed(entity.getSpeed());
        dto.setHeading(entity.getHeading());
        dto.setAddress(entity.getAddress());
        dto.setRecordTime(entity.getRecordTime());
        dto.setOrderId(entity.getOrderId());
        dto.setLocationType(entity.getLocationType());
        return dto;
    }
}
