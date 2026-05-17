package com.bucketwater.oms.module.admin.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
@Schema(description = "水站详情DTO")
public class StationDetailDTO {

    @Schema(description = "水站ID")
    private Long id;

    @Schema(description = "水站名称")
    private String name;

    @Schema(description = "水站编号")
    private String code;

    @Schema(description = "状态: active/suspended/closed")
    private String status;

    @Schema(description = "联系人")
    private String contact;

    @Schema(description = "联系电话")
    private String phone;

    @Schema(description = "详细地址")
    private String address;

    @Schema(description = "所属区域")
    private String area;

    @Schema(description = "水站类型")
    private String stationType;

    @Schema(description = "备注")
    private String remark;

    @Schema(description = "纬度")
    private BigDecimal lat;

    @Schema(description = "经度")
    private BigDecimal lng;

    @Schema(description = "创建时间")
    private String createTime;

    @Schema(description = "负责仓库名称")
    private String warehouse;

    @Schema(description = "预存金余额")
    private BigDecimal depositBalance;

    @Schema(description = "信用额度")
    private BigDecimal creditLimit;

    @Schema(description = "已用信用额度")
    private BigDecimal creditUsed;

    @Schema(description = "押金桶数量")
    private Integer depositBucketNum;

    @Schema(description = "当前欠桶数量")
    private Integer owedBucketNum;

    @Schema(description = "欠桶阈值")
    private Integer owedThreshold;

    @Schema(description = "每桶押金金额")
    private BigDecimal bucketDepositAmount;

    @Schema(description = "账期类型: PREPAID/MONTHLY/QUARTERLY")
    private String paymentType;

    @Schema(description = "预存金要求")
    private BigDecimal minDeposit;

    @Schema(description = "本月订单总数")
    private Integer monthlyOrders;

    @Schema(description = "本月进货桶数")
    private Integer monthlyBuckets;

    @Schema(description = "本月进货金额")
    private BigDecimal monthlyAmount;

    @Schema(description = "本月回桶数量")
    private Integer monthlyReturnBuckets;

    @Schema(description = "独立定价列表")
    private List<StationPriceDTO> prices;

    @Schema(description = "店员账号列表")
    private List<StationStaffDTO> staffs;

    @Schema(description = "最近订单列表")
    private List<RecentOrderDTO> recentOrders;

    @Schema(description = "销售政策ID")
    private String policyId;

    @Schema(description = "销售政策名称")
    private String policyName;

    @Schema(description = "销售政策类型")
    private String policyType;
}
