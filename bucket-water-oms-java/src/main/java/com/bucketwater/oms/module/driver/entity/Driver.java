package com.bucketwater.oms.module.driver.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.bucketwater.oms.common.BaseEntity;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("driver")
@Schema(description = "司机实体")
public class Driver extends BaseEntity {

    @TableId(type = IdType.AUTO)
    private Long id;

    @Schema(description = "司机工号")
    private String code;

    @Schema(description = "姓名")
    private String name;

    @Schema(description = "联系电话")
    private String phone;

    @TableField("warehouse_id")
    @Schema(description = "所属仓库ID")
    private Long warehouseId;

    @TableField("factory_id")
    @Schema(description = "所属水厂ID")
    private Long factoryId;

    @Schema(description = "负责区域")
    private String region;

    @Schema(description = "负责区域(别名)")
    private String area;

    @Schema(description = "状态: active/inactive")
    private String status;

    @Schema(description = "身份证号")
    private String idCard;

    @Schema(description = "车辆信息")
    private String vehicleInfo;

    @Schema(description = "车牌号")
    private String licensePlate;

    @Schema(description = "车辆类型")
    private String vehicleType;

    @Schema(description = "紧急联系人")
    private String emergencyContact;

    @Schema(description = "头像")
    private String avatar;

    @Schema(description = "备注")
    private String remark;

    @Schema(description = "在途空桶数量")
    private Integer bucketOnWay;

    @Schema(description = "欠桶数量")
    private Integer owedBuckets;

    @Schema(description = "在线状态: online/offline")
    private String onlineStatus;

    @Schema(description = "最后在线时间")
    private LocalDateTime lastOnlineTime;

    @Schema(description = "当前纬度")
    private BigDecimal currentLat;

    @Schema(description = "当前经度")
    private BigDecimal currentLng;

    @Schema(description = "最后位置更新时间")
    private LocalDateTime lastLocationTime;

    @TableField(exist = false)
    @Schema(description = "仓库ID列表(多仓库)")
    private List<Long> warehouseIds;

    @TableField(exist = false)
    @Schema(description = "仓库列表")
    private List<Map<String, Object>> warehouseList;

    @TableField(exist = false)
    @Schema(description = "仓库名称列表")
    private List<String> warehouseNames;
}
