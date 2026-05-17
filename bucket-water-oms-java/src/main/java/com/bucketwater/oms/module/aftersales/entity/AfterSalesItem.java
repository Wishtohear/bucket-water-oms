package com.bucketwater.oms.module.aftersales.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 售后商品明细实体
 */
@Data
@TableName("after_sales_item")
@Schema(description = "售后商品明细实体")
public class AfterSalesItem {

    @TableId(type = IdType.AUTO)
    @Schema(description = "主键ID")
    private Long id;

    @TableField("after_sales_id")
    @Schema(description = "售后ID")
    private Long afterSalesId;

    @TableField("product_id")
    @Schema(description = "商品ID")
    private Long productId;

    @Schema(description = "售后数量")
    private Integer quantity;

    @Schema(description = "创建时间")
    private LocalDateTime createTime;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getAfterSalesId() {
        return afterSalesId;
    }

    public void setAfterSalesId(Long afterSalesId) {
        this.afterSalesId = afterSalesId;
    }

    public Long getProductId() {
        return productId;
    }

    public void setProductId(Long productId) {
        this.productId = productId;
    }

    public Integer getQuantity() {
        return quantity;
    }

    public void setQuantity(Integer quantity) {
        this.quantity = quantity;
    }

    public LocalDateTime getCreateTime() {
        return createTime;
    }

    public void setCreateTime(LocalDateTime createTime) {
        this.createTime = createTime;
    }
}
