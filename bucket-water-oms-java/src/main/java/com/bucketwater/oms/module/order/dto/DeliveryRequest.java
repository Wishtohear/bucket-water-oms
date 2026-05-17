package com.bucketwater.oms.module.order.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.util.List;

@Schema(description = "配送签收请求")
public class DeliveryRequest {

    @Schema(description = "实际配送数量（单个商品时使用）")
    private Integer actualQty;

    @NotNull(message = "回桶数量不能为空")
    @Schema(description = "回桶数量")
    private Integer bucketReturned;

    @Schema(description = "欠桶数量")
    private Integer bucketOwed;

    @Schema(description = "签收照片")
    private List<String> photos;

    @NotBlank(message = "签收类型不能为空")
    @Schema(description = "签收类型: signature/sms_code/boss_confirm")
    private String signType;

    @Schema(description = "验证码")
    private String signCode;

    @Schema(description = "位置信息")
    private LocationInfo location;

    @Schema(description = "备注")
    private String remark;

    @Schema(description = "订单商品ID列表")
    private List<DeliveryItemDTO> items;

    public Integer getActualQty() {
        return actualQty;
    }

    public void setActualQty(Integer actualQty) {
        this.actualQty = actualQty;
    }

    public Integer getBucketReturned() {
        return bucketReturned;
    }

    public void setBucketReturned(Integer bucketReturned) {
        this.bucketReturned = bucketReturned;
    }

    public Integer getBucketOwed() {
        return bucketOwed;
    }

    public void setBucketOwed(Integer bucketOwed) {
        this.bucketOwed = bucketOwed;
    }

    public List<String> getPhotos() {
        return photos;
    }

    public void setPhotos(List<String> photos) {
        this.photos = photos;
    }

    public String getSignType() {
        return signType;
    }

    public void setSignType(String signType) {
        this.signType = signType;
    }

    public String getSignCode() {
        return signCode;
    }

    public void setSignCode(String signCode) {
        this.signCode = signCode;
    }

    public LocationInfo getLocation() {
        return location;
    }

    public void setLocation(LocationInfo location) {
        this.location = location;
    }

    public String getRemark() {
        return remark;
    }

    public void setRemark(String remark) {
        this.remark = remark;
    }

    public List<DeliveryItemDTO> getItems() {
        return items;
    }

    public void setItems(List<DeliveryItemDTO> items) {
        this.items = items;
    }

    @Schema(description = "配送商品明细")
    public static class DeliveryItemDTO {

        @NotNull(message = "商品ID不能为空")
        @Schema(description = "商品ID")
        private Long productId;

        @NotNull(message = "实际数量不能为空")
        @Schema(description = "实际配送数量")
        private Integer actualQty;

        public Long getProductId() {
            return productId;
        }

        public void setProductId(Long productId) {
            this.productId = productId;
        }

        public Integer getActualQty() {
            return actualQty;
        }

        public void setActualQty(Integer actualQty) {
            this.actualQty = actualQty;
        }
    }

    @Schema(description = "位置信息")
    public static class LocationInfo {

        @Schema(description = "纬度")
        private Double lat;

        @Schema(description = "经度")
        private Double lng;

        @Schema(description = "地址")
        private String address;

        public Double getLat() {
            return lat;
        }

        public void setLat(Double lat) {
            this.lat = lat;
        }

        public Double getLng() {
            return lng;
        }

        public void setLng(Double lng) {
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
