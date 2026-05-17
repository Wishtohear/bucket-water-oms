package com.bucketwater.oms.module.aftersales.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

/**
 * 创建售后响应DTO
 */
@Data
@Schema(description = "创建售后响应DTO")
public class CreateAfterSalesResponse {

    @Schema(description = "售后ID")
    private Long id;

    @Schema(description = "售后单号")
    private String afterSalesNo;

    @Schema(description = "状态")
    private String status;

    public CreateAfterSalesResponse() {
    }

    public CreateAfterSalesResponse(Long id, String afterSalesNo, String status) {
        this.id = id;
        this.afterSalesNo = afterSalesNo;
        this.status = status;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getAfterSalesNo() {
        return afterSalesNo;
    }

    public void setAfterSalesNo(String afterSalesNo) {
        this.afterSalesNo = afterSalesNo;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
