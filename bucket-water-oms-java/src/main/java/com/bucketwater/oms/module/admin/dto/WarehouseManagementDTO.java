package com.bucketwater.oms.module.admin.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

import java.math.BigDecimal;

@Data
@Schema(description = "仓库创建/更新请求")
public class WarehouseManagementDTO {

    @Schema(description = "仓库名称")
    @NotBlank(message = "仓库名称不能为空")
    private String name;

    @Schema(description = "地址")
    private String address;

    @Schema(description = "联系电话")
    @NotBlank(message = "联系电话不能为空")
    private String contactPhone;

    @Schema(description = "联系电话(别名)")
    private String phone;

    @Schema(description = "联系人")
    private String contact;

    @Schema(description = "纬度")
    private BigDecimal lat;

    @Schema(description = "经度")
    private BigDecimal lng;

    @Schema(description = "覆盖区域")
    private String coverageArea;

    @Schema(description = "密码(创建时必填,编辑时可选)")
    private String password;

    @Schema(description = "仓库类型(main/branch)")
    private String type;

    @Schema(description = "默认安全库存")
    private Integer defaultSafeStock;

    @Schema(description = "库存预警开关")
    private Boolean inventoryAlertEnabled;

    @Schema(description = "低库存预警阈值百分比")
    private Integer lowStockAlertPercent;

    @Schema(description = "备注")
    private String remark;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getContactPhone() {
        return contactPhone;
    }

    public void setContactPhone(String contactPhone) {
        this.contactPhone = contactPhone;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
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

    public String getCoverageArea() {
        return coverageArea;
    }

    public void setCoverageArea(String coverageArea) {
        this.coverageArea = coverageArea;
    }

    public String getContact() {
        return contact;
    }

    public void setContact(String contact) {
        this.contact = contact;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public Integer getDefaultSafeStock() {
        return defaultSafeStock;
    }

    public void setDefaultSafeStock(Integer defaultSafeStock) {
        this.defaultSafeStock = defaultSafeStock;
    }

    public Boolean getInventoryAlertEnabled() {
        return inventoryAlertEnabled;
    }

    public void setInventoryAlertEnabled(Boolean inventoryAlertEnabled) {
        this.inventoryAlertEnabled = inventoryAlertEnabled;
    }

    public Integer getLowStockAlertPercent() {
        return lowStockAlertPercent;
    }

    public void setLowStockAlertPercent(Integer lowStockAlertPercent) {
        this.lowStockAlertPercent = lowStockAlertPercent;
    }

    public String getRemark() {
        return remark;
    }

    public void setRemark(String remark) {
        this.remark = remark;
    }
}
