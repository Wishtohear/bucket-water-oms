package com.bucketwater.oms.module.admin.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

import java.util.List;

@Data
@Schema(description = "司机创建/更新请求")
public class DriverManagementDTO {

    @Schema(description = "姓名")
    @NotBlank(message = "姓名不能为空")
    private String name;

    @Schema(description = "联系电话")
    @NotBlank(message = "联系电话不能为空")
    private String phone;

    @Schema(description = "负责区域")
    private String region;

    @Schema(description = "负责区域(别名)")
    private String area;

    @Schema(description = "密码(创建时必填,编辑时可选)")
    private String password;

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

    @Schema(description = "仓库ID(单仓库兼容)")
    private Long warehouseId;

    @Schema(description = "仓库ID列表(多仓库)")
    private List<Long> warehouseIds;

    @Schema(description = "备注")
    private String remark;

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

    public String getRegion() {
        return region;
    }

    public void setRegion(String region) {
        this.region = region;
    }

    public String getArea() {
        return area;
    }

    public void setArea(String area) {
        this.area = area;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getIdCard() {
        return idCard;
    }

    public void setIdCard(String idCard) {
        this.idCard = idCard;
    }

    public String getVehicleInfo() {
        return vehicleInfo;
    }

    public void setVehicleInfo(String vehicleInfo) {
        this.vehicleInfo = vehicleInfo;
    }

    public Long getWarehouseId() {
        return warehouseId;
    }

    public void setWarehouseId(Long warehouseId) {
        this.warehouseId = warehouseId;
    }

    public String getRemark() {
        return remark;
    }

    public void setRemark(String remark) {
        this.remark = remark;
    }
}
