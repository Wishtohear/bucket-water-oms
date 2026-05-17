package com.bucketwater.oms.module.admin.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
@Schema(description = "对账单设置")
public class StatementConfigDTO {

    @NotNull(message = "对账日不能为空")
    @Schema(description = "每月对账日（1-28）")
    private Integer statementDay;

    @Schema(description = "是否启用自动生成")
    private Boolean autoGenerate;

    @Schema(description = "生成时间（小时，0-23）")
    private Integer generateHour;
}
