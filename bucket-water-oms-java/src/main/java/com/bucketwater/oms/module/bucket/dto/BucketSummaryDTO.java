package com.bucketwater.oms.module.bucket.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.math.BigDecimal;

@Data
@Schema(description = "空桶汇总DTO")
public class BucketSummaryDTO {

    @Schema(description = "押金桶总数")
    private Integer depositBucketNum;

    @Schema(description = "当前欠桶数")
    private Integer owedBucketNum;

    @Schema(description = "欠桶押金金额")
    private BigDecimal owedDepositAmount;

    @Schema(description = "每桶押金金额")
    private BigDecimal bucketDepositPerUnit;

    @Schema(description = "欠桶阈值")
    private Integer owedThreshold;

    @Schema(description = "是否超过阈值")
    private Boolean overThreshold;

    @Schema(description = "本月回桶数")
    private Integer monthReturn;

    @Schema(description = "本月欠桶数")
    private Integer monthOwe;

    @Schema(description = "净回桶数(回桶-欠桶)")
    private Integer monthNet;

    @Schema(description = "历史累计回桶数")
    private Integer totalReturn;

    @Schema(description = "历史累计欠桶数")
    private Integer totalOwe;

    public BucketSummaryDTO() {
    }

    public BucketSummaryDTO(Integer depositBucketNum, Integer owedBucketNum, BigDecimal owedDepositAmount,
                            BigDecimal bucketDepositPerUnit, Integer owedThreshold, Boolean overThreshold,
                            Integer monthReturn, Integer monthOwe, Integer monthNet,
                            Integer totalReturn, Integer totalOwe) {
        this.depositBucketNum = depositBucketNum;
        this.owedBucketNum = owedBucketNum;
        this.owedDepositAmount = owedDepositAmount;
        this.bucketDepositPerUnit = bucketDepositPerUnit;
        this.owedThreshold = owedThreshold;
        this.overThreshold = overThreshold;
        this.monthReturn = monthReturn;
        this.monthOwe = monthOwe;
        this.monthNet = monthNet;
        this.totalReturn = totalReturn;
        this.totalOwe = totalOwe;
    }
}
