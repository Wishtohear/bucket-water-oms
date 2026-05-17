package com.bucketwater.oms.module.admin.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import java.math.BigDecimal;

@Schema(description = "水站视图对象")
public class StationVO {

    @Schema(description = "水站ID")
    private String id;

    @Schema(description = "水站名称")
    private String name;

    @Schema(description = "水站编号")
    private String code;

    @Schema(description = "联系人")
    private String contact;

    @Schema(description = "联系电话")
    private String phone;

    @Schema(description = "地址")
    private String address;

    @Schema(description = "纬度")
    private BigDecimal lat;

    @Schema(description = "经度")
    private BigDecimal lng;

    @Schema(description = "所属区域")
    private String area;

    @Schema(description = "水站类型")
    private String stationType;

    @Schema(description = "账户余额")
    private BigDecimal balance;

    @Schema(description = "信用额度")
    private BigDecimal creditLimit;

    @Schema(description = "已用信用额度")
    private BigDecimal creditUsed;

    @Schema(description = "欠桶数量")
    private Integer owedBuckets;

    @Schema(description = "状态")
    private String status;

    @Schema(description = "创建时间")
    private String createTime;

    @Schema(description = "备注")
    private String remark;

    @Schema(description = "所属水厂ID")
    private Long factoryId;

    @Schema(description = "所属水厂名称")
    private String factoryName;

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }
    public String getContact() { return contact; }
    public void setContact(String contact) { this.contact = contact; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
    public BigDecimal getLat() { return lat; }
    public void setLat(BigDecimal lat) { this.lat = lat; }
    public BigDecimal getLng() { return lng; }
    public void setLng(BigDecimal lng) { this.lng = lng; }
    public String getArea() { return area; }
    public void setArea(String area) { this.area = area; }
    public String getStationType() { return stationType; }
    public void setStationType(String stationType) { this.stationType = stationType; }
    public BigDecimal getBalance() { return balance; }
    public void setBalance(BigDecimal balance) { this.balance = balance; }
    public BigDecimal getCreditLimit() { return creditLimit; }
    public void setCreditLimit(BigDecimal creditLimit) { this.creditLimit = creditLimit; }
    public BigDecimal getCreditUsed() { return creditUsed; }
    public void setCreditUsed(BigDecimal creditUsed) { this.creditUsed = creditUsed; }
    public Integer getOwedBuckets() { return owedBuckets; }
    public void setOwedBuckets(Integer owedBuckets) { this.owedBuckets = owedBuckets; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getCreateTime() { return createTime; }
    public void setCreateTime(String createTime) { this.createTime = createTime; }
    public String getRemark() { return remark; }
    public void setRemark(String remark) { this.remark = remark; }
    public Long getFactoryId() { return factoryId; }
    public void setFactoryId(Long factoryId) { this.factoryId = factoryId; }
    public String getFactoryName() { return factoryName; }
    public void setFactoryName(String factoryName) { this.factoryName = factoryName; }
}
