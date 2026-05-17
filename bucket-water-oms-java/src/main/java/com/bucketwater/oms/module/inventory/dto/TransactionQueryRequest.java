package com.bucketwater.oms.module.inventory.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

@Data
@Schema(description = "库存变动查询请求")
public class TransactionQueryRequest {

    @Schema(description = "仓库ID")
    private Long warehouseId;

    @Schema(description = "产品ID")
    private Long productId;

    @Schema(description = "变动类型: INBOUND-入库, OUTBOUND-出库, 空表示全部")
    private String transactionType;

    @Schema(description = "明细类型: production/purchase/transfer_in/return/order/damage/transfer_out")
    private String detailType;

    @Schema(description = "开始日期")
    private String startDate;

    @Schema(description = "结束日期")
    private String endDate;

    @Schema(description = "关联订单号")
    private String relatedOrderNo;

    @Schema(description = "页码")
    private Integer page = 1;

    @Schema(description = "每页数量")
    private Integer size = 20;
}
