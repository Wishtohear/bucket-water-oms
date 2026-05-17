package com.bucketwater.oms.module.admin.service;

import com.bucketwater.oms.common.exception.BusinessException;
import com.bucketwater.oms.common.response.ResultCode;
import com.bucketwater.oms.module.product.entity.Product;
import com.bucketwater.oms.module.product.entity.ProductInventory;
import com.bucketwater.oms.module.product.mapper.ProductInventoryMapper;
import com.bucketwater.oms.module.product.mapper.ProductMapper;
import com.bucketwater.oms.module.warehouse.entity.Warehouse;
import com.bucketwater.oms.module.warehouse.mapper.WarehouseMapper;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class AdminProductService {

    @Autowired
    private ProductMapper productMapper;

    @Autowired
    private ProductInventoryMapper inventoryMapper;

    @Autowired
    private WarehouseMapper warehouseMapper;

    public List<Product> getAllProducts(String category, String status) {
        var wrapper = new LambdaQueryWrapper<Product>();

        if (category != null && !category.isEmpty()) {
            wrapper.eq(Product::getCategory, category);
        }
        if (status != null && !status.isEmpty()) {
            wrapper.eq(Product::getStatus, status);
        }

        wrapper.orderByDesc(Product::getCreateTime);
        List<Product> products = productMapper.selectList(wrapper);
        
        for (Product product : products) {
            int totalStock = calculateTotalStock(product.getId());
            product.setStock(totalStock);
        }
        
        return products;
    }

    private int calculateTotalStock(Long productId) {
        LambdaQueryWrapper<ProductInventory> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ProductInventory::getProductId, productId);
        List<ProductInventory> inventories = inventoryMapper.selectList(wrapper);
        
        int total = 0;
        for (ProductInventory inv : inventories) {
            if (inv.getQuantity() != null) {
                total += inv.getQuantity();
            }
        }
        return total;
    }

    public Product getProductById(Long productId) {
        Product product = productMapper.selectById(productId);
        if (product == null) {
            throw new BusinessException(ResultCode.PRODUCT_NOT_FOUND);
        }
        int totalStock = calculateTotalStock(productId);
        product.setStock(totalStock);
        return product;
    }

    @Transactional
    public Product createProduct(Product request) {
        Product product = new Product();
        product.setCode(generateProductCode());
        product.setName(request.getName());
        product.setCategory(request.getCategory());
        product.setSpecification(request.getSpecification());
        product.setSpec(request.getSpec());
        product.setFactoryPrice(request.getFactoryPrice() != null ? request.getFactoryPrice() : BigDecimal.ZERO);
        product.setGuidePriceMin(request.getGuidePriceMin());
        product.setGuidePriceMax(request.getGuidePriceMax());
        product.setUnit(request.getUnit() != null ? request.getUnit() : "桶");
        product.setMinStock(request.getMinStock() != null ? request.getMinStock() : 0);
        product.setSafeStock(request.getSafeStock() != null ? request.getSafeStock() : 50);
        product.setStock(request.getStock() != null ? request.getStock() : 0);
        product.setImage(request.getImage());
        product.setDescription(request.getDescription());
        product.setRemark(request.getRemark());
        product.setStatus("active");
        product.setCreateTime(LocalDateTime.now());
        product.setUpdateTime(LocalDateTime.now());

        productMapper.insert(product);

        return product;
    }

    @Transactional
    public Product updateProduct(Long productId, Product request) {
        Product product = productMapper.selectById(productId);
        if (product == null) {
            throw new BusinessException(ResultCode.PRODUCT_NOT_FOUND);
        }

        if (request.getCode() != null) {
            product.setCode(request.getCode());
        }
        if (request.getName() != null) {
            product.setName(request.getName());
        }
        if (request.getCategory() != null) {
            product.setCategory(request.getCategory());
        }
        if (request.getSpecification() != null) {
            product.setSpecification(request.getSpecification());
        }
        if (request.getSpec() != null) {
            product.setSpec(request.getSpec());
        }
        if (request.getFactoryPrice() != null) {
            product.setFactoryPrice(request.getFactoryPrice());
        }
        if (request.getGuidePriceMin() != null) {
            product.setGuidePriceMin(request.getGuidePriceMin());
        }
        if (request.getGuidePriceMax() != null) {
            product.setGuidePriceMax(request.getGuidePriceMax());
        }
        if (request.getUnit() != null) {
            product.setUnit(request.getUnit());
        }
        if (request.getMinStock() != null) {
            product.setMinStock(request.getMinStock());
        }
        if (request.getSafeStock() != null) {
            product.setSafeStock(request.getSafeStock());
        }
        if (request.getStock() != null) {
            product.setStock(request.getStock());
        }
        if (request.getImage() != null) {
            product.setImage(request.getImage());
        }
        if (request.getDescription() != null) {
            product.setDescription(request.getDescription());
        }
        if (request.getRemark() != null) {
            product.setRemark(request.getRemark());
        }

        product.setUpdateTime(LocalDateTime.now());
        productMapper.updateById(product);

        return product;
    }

    @Transactional
    public void updateProductStatus(Long productId, String status) {
        Product product = productMapper.selectById(productId);
        if (product == null) {
            throw new BusinessException(ResultCode.PRODUCT_NOT_FOUND);
        }

        product.setStatus(status);
        product.setUpdateTime(LocalDateTime.now());
        productMapper.updateById(product);
    }

    @Transactional
    public void deleteProduct(Long productId) {
        Product product = productMapper.selectById(productId);
        if (product == null) {
            throw new BusinessException(ResultCode.PRODUCT_NOT_FOUND);
        }
        productMapper.deleteById(productId);
    }

    public List<Map<String, Object>> getCategories() {
        List<Product> products = productMapper.selectList(null);
        
        Map<String, List<Product>> grouped = products.stream()
                .collect(Collectors.groupingBy(p -> p.getCategory() != null ? p.getCategory() : "other"));
        
        List<Map<String, Object>> categories = new ArrayList<>();
        for (Map.Entry<String, List<Product>> entry : grouped.entrySet()) {
            Map<String, Object> category = new HashMap<>();
            category.put("value", entry.getKey());
            category.put("label", getCategoryLabel(entry.getKey()));
            category.put("count", entry.getValue().size());
            
            int totalStock = 0;
            for (Product p : entry.getValue()) {
                totalStock += calculateTotalStock(p.getId());
            }
            category.put("stock", totalStock);
            categories.add(category);
        }
        
        return categories;
    }

    public Map<String, Object> getStats() {
        List<Product> products = productMapper.selectList(null);
        
        Map<String, Object> stats = new HashMap<>();
        
        List<Product> bucketWater = products.stream()
                .filter(p -> "bucket_water".equals(p.getCategory()))
                .collect(Collectors.toList());
        Map<String, Object> bucketWaterStats = new HashMap<>();
        bucketWaterStats.put("count", bucketWater.size());
        int bucketWaterStock = 0;
        for (Product p : bucketWater) {
            bucketWaterStock += calculateTotalStock(p.getId());
        }
        bucketWaterStats.put("stock", bucketWaterStock);
        
        List<Product> bottleWater = products.stream()
                .filter(p -> "bottled_water".equals(p.getCategory()))
                .collect(Collectors.toList());
        Map<String, Object> bottleWaterStats = new HashMap<>();
        bottleWaterStats.put("count", bottleWater.size());
        int bottleWaterStock = 0;
        for (Product p : bottleWater) {
            bottleWaterStock += calculateTotalStock(p.getId());
        }
        bottleWaterStats.put("stock", bottleWaterStock);
        
        List<Product> equipment = products.stream()
                .filter(p -> "equipment".equals(p.getCategory()))
                .collect(Collectors.toList());
        Map<String, Object> equipmentStats = new HashMap<>();
        equipmentStats.put("count", equipment.size());
        int equipmentStock = 0;
        int equipmentWarning = 0;
        for (Product p : equipment) {
            int stock = calculateTotalStock(p.getId());
            equipmentStock += stock;
            if (p.getMinStock() != null && stock < p.getMinStock()) {
                equipmentWarning++;
            }
        }
        equipmentStats.put("stock", equipmentStock);
        equipmentStats.put("warning", equipmentWarning);
        
        List<Product> other = products.stream()
                .filter(p -> p.getCategory() == null || (!"bucket_water".equals(p.getCategory()) && !"bottled_water".equals(p.getCategory()) && !"equipment".equals(p.getCategory())))
                .collect(Collectors.toList());
        Map<String, Object> otherStats = new HashMap<>();
        otherStats.put("count", other.size());
        int otherStock = 0;
        for (Product p : other) {
            otherStock += calculateTotalStock(p.getId());
        }
        otherStats.put("stock", otherStock);
        
        stats.put("bucketWater", bucketWaterStats);
        stats.put("bottleWater", bottleWaterStats);
        stats.put("equipment", equipmentStats);
        stats.put("other", otherStats);
        
        return stats;
    }

    private String generateProductCode() {
        return "P" + System.currentTimeMillis();
    }

    private String getCategoryLabel(String category) {
        return switch (category) {
            case "bucket_water" -> "桶装水";
            case "bottled_water" -> "瓶装水";
            case "equipment" -> "饮水设备";
            default -> "其他";
        };
    }

    public List<Map<String, Object>> getProductWarehouseInventory(Long productId) {
        Product product = productMapper.selectById(productId);
        if (product == null) {
            throw new BusinessException(ResultCode.PRODUCT_NOT_FOUND);
        }

        List<Map<String, Object>> result = new ArrayList<>();

        LambdaQueryWrapper<Warehouse> warehouseWrapper = new LambdaQueryWrapper<>();
        warehouseWrapper.eq(Warehouse::getStatus, "active");
        List<Warehouse> warehouses = warehouseMapper.selectList(warehouseWrapper);

        for (Warehouse warehouse : warehouses) {
            Map<String, Object> item = new HashMap<>();
            item.put("warehouseId", warehouse.getId());
            item.put("warehouseName", warehouse.getName());
            item.put("warehouseType", warehouse.getType() != null ? warehouse.getType() : "branch");

            LambdaQueryWrapper<ProductInventory> invWrapper = new LambdaQueryWrapper<>();
            invWrapper.eq(ProductInventory::getProductId, productId);
            invWrapper.eq(ProductInventory::getWarehouseId, warehouse.getId());
            ProductInventory inventory = inventoryMapper.selectOne(invWrapper);

            if (inventory != null) {
                item.put("stock", inventory.getQuantity() != null ? inventory.getQuantity() : 0);
                item.put("minStock", inventory.getSafeStock() != null ? inventory.getSafeStock() : (product.getMinStock() != null ? product.getMinStock() : 0));
            } else {
                item.put("stock", 0);
                item.put("minStock", product.getMinStock() != null ? product.getMinStock() : 0);
            }

            result.add(item);
        }

        return result;
    }
}
