package com.bucketwater.oms.module.order.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;

import java.util.List;

/**
 * 拒单请求
 */
@Schema(description = "拒单请求")
public class RejectOrderRequest {

    @Schema(description = "拒单原因")
    @NotBlank(message = "拒单原因不能为空")
    private String reason;

    @Schema(description = "库存不足明细")
    private List<StockDetail> stockDetails;

    @Schema(description = "是否库存不足")
    private Boolean stockInsufficient;

    public RejectOrderRequest() {}

    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }

    public List<StockDetail> getStockDetails() { return stockDetails; }
    public void setStockDetails(List<StockDetail> stockDetails) { this.stockDetails = stockDetails; }

    public Boolean getStockInsufficient() { return stockInsufficient; }
    public void setStockInsufficient(Boolean stockInsufficient) { this.stockInsufficient = stockInsufficient; }

    @Schema(description = "库存不足明细项")
    public static class StockDetail {
        @Schema(description = "商品ID")
        private Long productId;

        @Schema(description = "商品名称")
        private String productName;

        @Schema(description = "订单需求数量")
        private Integer requiredQuantity;

        @Schema(description = "当前库存数量")
        private Integer currentStock;

        @Schema(description = "短缺数量")
        private Integer shortageQuantity;

        public StockDetail() {}

        public StockDetail(Long productId, String productName, Integer requiredQuantity, Integer currentStock) {
            this.productId = productId;
            this.productName = productName;
            this.requiredQuantity = requiredQuantity;
            this.currentStock = currentStock;
            this.shortageQuantity = requiredQuantity - currentStock;
        }

        public Long getProductId() { return productId; }
        public void setProductId(Long productId) { this.productId = productId; }

        public String getProductName() { return productName; }
        public void setProductName(String productName) { this.productName = productName; }

        public Integer getRequiredQuantity() { return requiredQuantity; }
        public void setRequiredQuantity(Integer requiredQuantity) { this.requiredQuantity = requiredQuantity; }

        public Integer getCurrentStock() { return currentStock; }
        public void setCurrentStock(Integer currentStock) { this.currentStock = currentStock; }

        public Integer getShortageQuantity() { return shortageQuantity; }
        public void setShortageQuantity(Integer shortageQuantity) { this.shortageQuantity = shortageQuantity; }
    }
}
