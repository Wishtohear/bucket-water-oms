package com.bucketwater.oms.module.driver.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import java.math.BigDecimal;

@Schema(description = "司机信息DTO")
public class DriverInfoDTO {

    @Schema(description = "司机ID")
    private Long id;

    @Schema(description = "司机工号")
    private String code;

    @Schema(description = "姓名")
    private String name;

    @Schema(description = "联系电话")
    private String phone;

    @Schema(description = "车辆信息")
    private String vehicle;

    @Schema(description = "车牌号")
    private String licensePlate;

    @Schema(description = "车辆类型")
    private String vehicleType;

    @Schema(description = "仓库名称")
    private String warehouseName;

    @Schema(description = "负责区域")
    private String area;

    @Schema(description = "状态")
    private String status;

    @Schema(description = "在线状态")
    private String onlineStatus;

    @Schema(description = "今日配送数")
    private Integer todayDeliveries;

    @Schema(description = "累计配送数")
    private Integer totalDeliveries;

    @Schema(description = "本月收入")
    private BigDecimal monthIncome;

    @Schema(description = "欠桶数量")
    private Integer owedBuckets;

    @Schema(description = "在途空桶数")
    private Integer bucketOnWay;

    @Schema(description = "押金桶总数")
    private Integer depositBuckets;

    @Schema(description = "押金单价")
    private BigDecimal depositPrice;

    @Schema(description = "累计欠桶总额")
    private BigDecimal totalOwedAmount;

    public DriverInfoDTO() {}

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getVehicle() {
        return vehicle;
    }

    public void setVehicle(String vehicle) {
        this.vehicle = vehicle;
    }

    public String getLicensePlate() {
        return licensePlate;
    }

    public void setLicensePlate(String licensePlate) {
        this.licensePlate = licensePlate;
    }

    public String getVehicleType() {
        return vehicleType;
    }

    public void setVehicleType(String vehicleType) {
        this.vehicleType = vehicleType;
    }

    public String getWarehouseName() {
        return warehouseName;
    }

    public void setWarehouseName(String warehouseName) {
        this.warehouseName = warehouseName;
    }

    public String getArea() {
        return area;
    }

    public void setArea(String area) {
        this.area = area;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getOnlineStatus() {
        return onlineStatus;
    }

    public void setOnlineStatus(String onlineStatus) {
        this.onlineStatus = onlineStatus;
    }

    public Integer getTodayDeliveries() {
        return todayDeliveries;
    }

    public void setTodayDeliveries(Integer todayDeliveries) {
        this.todayDeliveries = todayDeliveries;
    }

    public Integer getTotalDeliveries() {
        return totalDeliveries;
    }

    public void setTotalDeliveries(Integer totalDeliveries) {
        this.totalDeliveries = totalDeliveries;
    }

    public BigDecimal getMonthIncome() {
        return monthIncome;
    }

    public void setMonthIncome(BigDecimal monthIncome) {
        this.monthIncome = monthIncome;
    }

    public Integer getOwedBuckets() {
        return owedBuckets;
    }

    public void setOwedBuckets(Integer owedBuckets) {
        this.owedBuckets = owedBuckets;
    }

    public Integer getBucketOnWay() {
        return bucketOnWay;
    }

    public void setBucketOnWay(Integer bucketOnWay) {
        this.bucketOnWay = bucketOnWay;
    }

    public Integer getDepositBuckets() {
        return depositBuckets;
    }

    public void setDepositBuckets(Integer depositBuckets) {
        this.depositBuckets = depositBuckets;
    }

    public BigDecimal getDepositPrice() {
        return depositPrice;
    }

    public void setDepositPrice(BigDecimal depositPrice) {
        this.depositPrice = depositPrice;
    }

    public BigDecimal getTotalOwedAmount() {
        return totalOwedAmount;
    }

    public void setTotalOwedAmount(BigDecimal totalOwedAmount) {
        this.totalOwedAmount = totalOwedAmount;
    }
}
