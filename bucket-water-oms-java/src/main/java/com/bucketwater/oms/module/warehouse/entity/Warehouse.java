package com.bucketwater.oms.module.warehouse.entity;

import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableName;
import com.bucketwater.oms.common.BaseEntity;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("warehouse")
@Schema(description = "仓库实体")
public class Warehouse extends BaseEntity {

    // 使用父类的 AUTO 自增策略，不覆盖

    @TableField("factory_id")
    @Schema(description = "水厂ID")
    private Long factoryId;

    @Schema(description = "仓库名称")
    private String name;

    @Schema(description = "地址")
    private String address;

    @Schema(description = "联系电话")
    private String contactPhone;

    @Schema(description = "联系电话(别名)")
    private String phone;

    @Schema(description = "联系人")
    private String contact;

    @Schema(description = "纬度")
    private BigDecimal lat;

    @Schema(description = "经度")
    private BigDecimal lng;

    @Schema(description = "状态: active/inactive")
    private String status;

    @Schema(description = "仓库类型: main/branch")
    private String type;

    @Schema(description = "覆盖区域")
    private String coverageArea;

    @Schema(description = "默认安全库存")
    private Integer defaultSafeStock;

    @Schema(description = "库存预警开关")
    private Boolean inventoryAlertEnabled;

    @Schema(description = "低库存预警阈值百分比")
    private Integer lowStockAlertPercent;

    @Schema(description = "备注")
    private String remark;
}
