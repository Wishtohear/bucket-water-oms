package com.bucketwater.oms.module.product.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;
import java.util.List;

@Schema(description = "商品DTO")
public class ProductDTO {

    @Schema(description = "商品列表")
    private List<ProductItem> products;

    public ProductDTO() {}

    public ProductDTO(List<ProductItem> products) {
        this.products = products;
    }

    public List<ProductItem> getProducts() {
        return products;
    }

    public void setProducts(List<ProductItem> products) {
        this.products = products;
    }

    @Schema(description = "商品项")
    public static class ProductItem {

        @Schema(description = "商品ID")
        private String productId;

        @Schema(description = "商品名称")
        private String name;

        @Schema(description = "分类")
        private String category;

        @Schema(description = "规格")
        private String specification;

        @Schema(description = "价格")
        private BigDecimal price;

        @Schema(description = "状态")
        private String status;

        public ProductItem() {}

        public ProductItem(String productId, String name, String category, 
                         String specification, BigDecimal price, String status) {
            this.productId = productId;
            this.name = name;
            this.category = category;
            this.specification = specification;
            this.price = price;
            this.status = status;
        }

        public String getProductId() {
            return productId;
        }

        public void setProductId(String productId) {
            this.productId = productId;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public String getCategory() {
            return category;
        }

        public void setCategory(String category) {
            this.category = category;
        }

        public String getSpecification() {
            return specification;
        }

        public void setSpecification(String specification) {
            this.specification = specification;
        }

        public BigDecimal getPrice() {
            return price;
        }

        public void setPrice(BigDecimal price) {
            this.price = price;
        }

        public String getStatus() {
            return status;
        }

        public void setStatus(String status) {
            this.status = status;
        }
    }
}
