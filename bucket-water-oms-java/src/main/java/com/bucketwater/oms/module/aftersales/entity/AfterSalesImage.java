package com.bucketwater.oms.module.aftersales.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 售后图片实体
 */
@Data
@TableName("after_sales_image")
@Schema(description = "售后图片实体")
public class AfterSalesImage {

    @TableId(type = IdType.AUTO)
    @Schema(description = "主键ID")
    private Long id;

    @TableField("after_sales_id")
    @Schema(description = "售后ID")
    private Long afterSalesId;

    @TableField("image_url")
    @Schema(description = "图片URL")
    private String imageUrl;

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

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public LocalDateTime getCreateTime() {
        return createTime;
    }

    public void setCreateTime(LocalDateTime createTime) {
        this.createTime = createTime;
    }
}
