package com.bucketwater.oms.module.product.service;

import com.bucketwater.oms.module.product.dto.ProductDTO;
import com.bucketwater.oms.module.product.entity.Product;
import com.bucketwater.oms.module.product.entity.ProductInventory;
import com.bucketwater.oms.module.product.entity.ProductTierPrice;
import com.bucketwater.oms.module.product.entity.StationProductPrice;
import com.bucketwater.oms.module.product.mapper.ProductInventoryMapper;
import com.bucketwater.oms.module.product.mapper.ProductMapper;
import com.bucketwater.oms.module.product.mapper.ProductTierPriceMapper;
import com.bucketwater.oms.module.product.mapper.StationProductPriceMapper;
import com.bucketwater.oms.module.admin.entity.PolicyPricingRule;
import com.bucketwater.oms.module.admin.mapper.PolicyPricingRuleMapper;
import com.bucketwater.oms.module.station.entity.StationAccount;
import com.bucketwater.oms.module.station.mapper.StationAccountMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.List;


@Slf4j
@Service
public class ProductService {

    @Autowired
    private ProductMapper productMapper;

    @Autowired
    private ProductInventoryMapper productInventoryMapper;

    @Autowired
    private StationProductPriceMapper stationProductPriceMapper;

    @Autowired
    private ProductTierPriceMapper productTierPriceMapper;

    @Autowired(required = false)
    private PolicyPricingRuleMapper pricingRuleMapper;

    @Autowired(required = false)
    private StationAccountMapper stationAccountMapper;

    public ProductDTO getProducts(String category) {
        com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Product> wrapper =
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Product>()
                .eq(Product::getStatus, "active");

        if (category != null && !category.isEmpty()) {
            wrapper.eq(Product::getCategory, category);
        }

        List<Product> products = productMapper.selectList(wrapper);
        List<ProductDTO.ProductItem> items = new ArrayList<>();

        for (Product product : products) {
            BigDecimal price = product.getPrice();
            if (price == null || price.compareTo(BigDecimal.ZERO) <= 0) {
                price = product.getGuidePriceMax();
            }
            items.add(new ProductDTO.ProductItem(
                product.getId().toString(),
                product.getName(),
                product.getCategory(),
                product.getSpecification(),
                price,
                product.getStatus()
            ));
        }

        return new ProductDTO(items);
    }

    public List<ProductInventory> getWarehouseInventory(Long warehouseId) {
        return productInventoryMapper.selectList(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<ProductInventory>()
                .eq(ProductInventory::getWarehouseId, warehouseId)
        );
    }

    public BigDecimal getProductPriceForStation(Long stationId, Long productId, int quantity) {
        log.info("[DEBUG] getProductPriceForStation: stationId={}, productId={}, quantity={}", stationId, productId, quantity);

        // 1. 首先检查水站是否分配了政策模板
        if (stationAccountMapper != null && pricingRuleMapper != null) {
            StationAccount account = stationAccountMapper.selectOne(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<StationAccount>()
                    .eq(StationAccount::getStationId, stationId)
            );
            if (account != null && account.getPolicyId() != null) {
                PolicyPricingRule policyRule = pricingRuleMapper.selectOne(
                    new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<PolicyPricingRule>()
                        .eq(PolicyPricingRule::getPolicyId, account.getPolicyId())
                        .eq(PolicyPricingRule::getProductId, productId)
                        .eq(PolicyPricingRule::getDeleted, 0)
                );
                if (policyRule != null && policyRule.getPrice() != null) {
                    log.info("[DEBUG] 使用政策模板价格: policyId={}, price={}", account.getPolicyId(), policyRule.getPrice());
                    return policyRule.getPrice();
                }
            }
        }

        // 2. 检查阶梯价
        var tierPriceOpt = productTierPriceMapper.findTierPrice(stationId, productId, quantity);
        if (tierPriceOpt.isPresent()) {
            BigDecimal price = tierPriceOpt.get().getTierPrice();
            log.info("[DEBUG] 找到阶梯价: price={}", price);
            return price;
        }
        log.info("[DEBUG] 未找到阶梯价");

        // 3. 检查水站自定义价格
        var customPriceOpt = stationProductPriceMapper.findByStationAndProduct(stationId, productId);
        if (customPriceOpt.isPresent()) {
            StationProductPrice customPrice = customPriceOpt.get();
            BigDecimal price = customPrice.getPrice();
            BigDecimal discountRate = customPrice.getDiscountRate();
            log.info("[DEBUG] 找到水站自定义价格: price={}, discountRate={}", price, discountRate);
            if (discountRate != null && discountRate.compareTo(BigDecimal.ONE) < 0) {
                BigDecimal finalPrice = price.multiply(discountRate).setScale(2, RoundingMode.HALF_UP);
                log.info("[DEBUG] 应用折扣后价格: finalPrice={}", finalPrice);
                return finalPrice;
            }
            return price;
        }
        log.info("[DEBUG] 未找到水站自定义价格");

        // 4. 获取商品的默认价格
        Product product = productMapper.selectById(productId);
        if (product != null) {
            BigDecimal price = product.getGuidePriceMax();
            if (price != null && price.compareTo(BigDecimal.ZERO) > 0) {
                log.info("[DEBUG] 使用商品最高指导价: productId={}, guidePriceMax={}", productId, price);
                return price;
            }
            price = product.getPrice();
            log.info("[DEBUG] 使用商品原价: productId={}, price={}", productId, price);
            return price != null ? price : BigDecimal.ZERO;
        }
        log.warn("[DEBUG] 商品不存在: productId={}", productId);
        return BigDecimal.ZERO;
    }

    public boolean checkWarehouseStock(Long warehouseId, Long productId, int requiredQuantity) {
        log.info("[DEBUG] checkWarehouseStock: warehouseId={}, productId={}, requiredQuantity={}", warehouseId, productId, requiredQuantity);

        ProductInventory inventory = productInventoryMapper.selectOne(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<ProductInventory>()
                .eq(ProductInventory::getWarehouseId, warehouseId)
                .eq(ProductInventory::getProductId, productId)
        );

        if (inventory == null) {
            log.warn("[DEBUG] 仓库库存记录不存在: warehouseId={}, productId={}", warehouseId, productId);
            return false;
        }

        boolean sufficient = inventory.getQuantity() >= requiredQuantity;
        log.info("[DEBUG] 库存检查结果: available={}, required={}, sufficient={}", inventory.getQuantity(), requiredQuantity, sufficient);
        return sufficient;
    }

    public void deductStock(Long warehouseId, Long productId, int quantity) {
        ProductInventory inventory = productInventoryMapper.selectOne(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<ProductInventory>()
                .eq(ProductInventory::getWarehouseId, warehouseId)
                .eq(ProductInventory::getProductId, productId)
        );
        if (inventory != null) {
            inventory.setQuantity(inventory.getQuantity() - quantity);
            inventory.setUpdatedAt(java.time.LocalDateTime.now());
            productInventoryMapper.updateById(inventory);
        }
    }

    public List<ProductTierPrice> getTierPrices(Long stationId, Long productId) {
        return productTierPriceMapper.findAllTiers(stationId, productId);
    }

    public com.bucketwater.oms.module.station.dto.ProductPriceDTO getProductPriceInfo(Long stationId, Long productId) {
        log.info("[DEBUG] getProductPriceInfo: stationId={}, productId={}", stationId, productId);

        Product product = productMapper.selectById(productId);
        if (product == null) {
            log.warn("[DEBUG] 商品不存在: productId={}", productId);
            return null;
        }

        BigDecimal unitPrice = getProductPriceForStation(stationId, productId, 1);
        Integer minOrderQuantity = getMinOrderQuantity(stationId, productId);

        ProductTierPrice tierPriceInfo = null;
        List<ProductTierPrice> tiers = productTierPriceMapper.findAllTiers(stationId, productId);
        if (!tiers.isEmpty()) {
            ProductTierPrice lowestTier = tiers.stream()
                .min((a, b) -> Integer.compare(a.getMinQuantity(), b.getMinQuantity()))
                .orElse(null);
            if (lowestTier != null) {
                tierPriceInfo = lowestTier;
            }
        }

        com.bucketwater.oms.module.station.dto.ProductPriceDTO.TierPriceInfo tier = null;
        if (tierPriceInfo != null) {
            tier = new com.bucketwater.oms.module.station.dto.ProductPriceDTO.TierPriceInfo(
                tierPriceInfo.getTierPrice(),
                tierPriceInfo.getMinQuantity()
            );
        }

        return new com.bucketwater.oms.module.station.dto.ProductPriceDTO(
            productId,
            product.getName(),
            unitPrice,
            minOrderQuantity,
            tier
        );
    }

    public Integer getMinOrderQuantity(Long stationId, Long productId) {
        // 1. 首先检查水站是否分配了政策模板
        if (stationAccountMapper != null && pricingRuleMapper != null) {
            StationAccount account = stationAccountMapper.selectOne(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<StationAccount>()
                    .eq(StationAccount::getStationId, stationId)
            );
            if (account != null && account.getPolicyId() != null) {
                PolicyPricingRule policyRule = pricingRuleMapper.selectOne(
                    new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<PolicyPricingRule>()
                        .eq(PolicyPricingRule::getPolicyId, account.getPolicyId())
                        .eq(PolicyPricingRule::getProductId, productId)
                        .eq(PolicyPricingRule::getDeleted, 0)
                );
                if (policyRule != null && policyRule.getMinQuantity() != null && policyRule.getMinQuantity() > 0) {
                    log.info("[DEBUG] 使用政策模板最低起订量: policyId={}, minQuantity={}", account.getPolicyId(), policyRule.getMinQuantity());
                    return policyRule.getMinQuantity();
                }
            }
        }

        // 2. 检查阶梯价
        var tierPrices = productTierPriceMapper.findAllTiers(stationId, productId);
        if (!tierPrices.isEmpty()) {
            Integer minTierQuantity = tierPrices.stream()
                .map(ProductTierPrice::getMinQuantity)
                .min(Integer::compare)
                .orElse(null);
            if (minTierQuantity != null && minTierQuantity > 0) {
                log.info("[DEBUG] 使用阶梯价最低起订量: minQuantity={}", minTierQuantity);
                return minTierQuantity;
            }
        }

        log.info("[DEBUG] 使用商品默认最低起订量: 1");
        return 1;
    }

    public int batchUpdateStatus(List<Long> productIds, String status) {
        if (productIds == null || productIds.isEmpty()) {
            return 0;
        }
        int count = 0;
        for (Long productId : productIds) {
            Product product = productMapper.selectById(productId);
            if (product != null) {
                product.setStatus(status);
                product.setUpdateTime(java.time.LocalDateTime.now());
                productMapper.updateById(product);
                count++;
                log.info("批量更新商品状态: productId={}, status={}", productId, status);
            }
        }
        return count;
    }

    public int batchUpdatePrice(List<Long> productIds, BigDecimal guidePrice, BigDecimal guidePriceMax) {
        if (productIds == null || productIds.isEmpty()) {
            return 0;
        }
        int count = 0;
        for (Long productId : productIds) {
            Product product = productMapper.selectById(productId);
            if (product != null) {
                if (guidePrice != null) {
                    product.setGuidePriceMin(guidePrice);
                }
                if (guidePriceMax != null) {
                    product.setGuidePriceMax(guidePriceMax);
                }
                product.setUpdateTime(java.time.LocalDateTime.now());
                productMapper.updateById(product);
                count++;
                log.info("批量更新商品价格: productId={}, guidePrice={}, guidePriceMax={}", productId, guidePrice, guidePriceMax);
            }
        }
        return count;
    }

    public int batchEnableProducts(List<Long> productIds, boolean enabled) {
        return batchUpdateStatus(productIds, enabled ? "active" : "inactive");
    }

    public int batchUpdateSafeStock(List<Long> productIds, Integer safeStock) {
        if (productIds == null || productIds.isEmpty() || safeStock == null) {
            return 0;
        }
        int count = 0;
        for (Long productId : productIds) {
            Product product = productMapper.selectById(productId);
            if (product != null) {
                product.setSafeStock(safeStock);
                product.setUpdateTime(java.time.LocalDateTime.now());
                productMapper.updateById(product);
                count++;
                log.info("批量更新安全库存: productId={}, safeStock={}", productId, safeStock);
            }
        }
        return count;
    }
}
