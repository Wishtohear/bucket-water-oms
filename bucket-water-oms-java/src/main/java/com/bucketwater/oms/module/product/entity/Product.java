package com.bucketwater.oms.module.product.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.bucketwater.oms.common.BaseEntity;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("product")
@Schema(description = "商品实体")
public class Product extends BaseEntity {

    @Schema(description = "商品编码")
    private String code;

    @Schema(description = "商品名称")
    private String name;

    @Schema(description = "分类: bucket_water/bottled_water/equipment")
    private String category;

    @Schema(description = "规格")
    private String specification;

    @Schema(description = "规格(别名)")
    private String spec;

    @Schema(description = "默认单价")
    private BigDecimal price;

    @Schema(description = "出厂价")
    private BigDecimal factoryPrice;

    @Schema(description = "指导价最小值")
    private BigDecimal guidePriceMin;

    @Schema(description = "指导价最大值")
    private BigDecimal guidePriceMax;

    @Schema(description = "计量单位")
    private String unit;

    @Schema(description = "最小库存")
    private Integer minStock;

    @Schema(description = "安全库存")
    private Integer safeStock;

    @Schema(description = "库存数量")
    private Integer stock;

    @Schema(description = "产品图片")
    private String image;

    @Schema(description = "产品描述")
    private String description;

    @Schema(description = "备注")
    private String remark;

    @Schema(description = "状态: active/inactive")
    private String status;
}
