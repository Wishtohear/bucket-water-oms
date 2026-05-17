package com.bucketwater.oms.module.inventory.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.bucketwater.oms.common.exception.BusinessException;
import com.bucketwater.oms.common.response.ResultCode;
import com.bucketwater.oms.module.inventory.dto.*;
import com.bucketwater.oms.module.inventory.entity.ProductInventoryTransaction;
import com.bucketwater.oms.module.inventory.mapper.ProductInventoryTransactionMapper;
import com.bucketwater.oms.module.product.entity.Product;
import com.bucketwater.oms.module.product.entity.ProductInventory;
import com.bucketwater.oms.module.product.mapper.ProductInventoryMapper;
import com.bucketwater.oms.module.product.mapper.ProductMapper;
import com.bucketwater.oms.module.warehouse.entity.Warehouse;
import com.bucketwater.oms.module.warehouse.mapper.WarehouseMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class ProductInventoryTransactionService {

    @Autowired
    private ProductInventoryTransactionMapper transactionMapper;

    @Autowired
    private ProductMapper productMapper;

    @Autowired
    private ProductInventoryMapper inventoryMapper;

    @Autowired
    private WarehouseMapper warehouseMapper;

    private static final DateTimeFormatter NO_FORMATTER = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");

    public PageResponse<ProductInventoryTransactionDTO> queryTransactions(TransactionQueryRequest request) {
        QueryWrapper<ProductInventoryTransaction> wrapper = new QueryWrapper<>();

        if (request.getWarehouseId() != null) {
            wrapper.eq("warehouse_id", request.getWarehouseId());
        }
        if (request.getProductId() != null) {
            wrapper.eq("product_id", request.getProductId());
        }
        if (request.getTransactionType() != null && !request.getTransactionType().isBlank()) {
            wrapper.eq("transaction_type", request.getTransactionType());
        }
        if (request.getDetailType() != null && !request.getDetailType().isBlank()) {
            wrapper.eq("detail_type", request.getDetailType());
        }
        if (request.getRelatedOrderNo() != null && !request.getRelatedOrderNo().isBlank()) {
            wrapper.eq("related_order_no", request.getRelatedOrderNo());
        }
        if (request.getStartDate() != null && !request.getStartDate().isBlank()) {
            wrapper.ge("create_time", request.getStartDate() + " 00:00:00");
        }
        if (request.getEndDate() != null && !request.getEndDate().isBlank()) {
            wrapper.le("create_time", request.getEndDate() + " 23:59:59");
        }

        wrapper.orderByDesc("create_time");

        IPage<ProductInventoryTransaction> page = transactionMapper.selectPage(
            new Page<>(request.getPage(), request.getSize()),
            wrapper
        );

        List<ProductInventoryTransactionDTO> records = page.getRecords().stream()
            .map(this::convertToDTO)
            .collect(Collectors.toList());

        return PageResponse.of(page.getTotal(), request.getPage(), request.getSize(), records);
    }

    public ProductInventoryTransactionDTO getTransactionById(Long id) {
        ProductInventoryTransaction transaction = transactionMapper.selectById(id);
        if (transaction == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "库存变动记录不存在");
        }
        return convertToDTO(transaction);
    }

    public List<ProductInventoryTransactionDTO> getTransactionsByProduct(Long warehouseId, Long productId) {
        List<ProductInventoryTransaction> transactions = transactionMapper.findByWarehouseIdAndProductId(warehouseId, productId);
        return transactions.stream().map(this::convertToDTO).collect(Collectors.toList());
    }

    public List<ProductInventoryTransactionDTO> getTransactionsByOrder(Long warehouseId, String orderNo) {
        List<ProductInventoryTransaction> transactions = transactionMapper.findByWarehouseIdAndOrderNo(warehouseId, orderNo);
        return transactions.stream().map(this::convertToDTO).collect(Collectors.toList());
    }

    @Transactional
    public List<ProductInventoryTransactionDTO> createInboundTransactions(Long warehouseId, String operator, CreateInboundTransactionRequest request) {
        Warehouse warehouse = warehouseMapper.selectById(warehouseId);
        if (warehouse == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "仓库不存在");
        }

        List<ProductInventoryTransactionDTO> results = new ArrayList<>();

        for (CreateInboundTransactionRequest.InboundItem item : request.getItems()) {
            Product product = productMapper.selectById(item.getProductId());
            if (product == null) {
                throw new BusinessException(ResultCode.NOT_FOUND, "产品不存在: " + item.getProductId());
            }

            ProductInventory inventory = getOrCreateInventory(warehouseId, item.getProductId());
            int balanceBefore = inventory.getQuantity() != null ? inventory.getQuantity() : 0;
            int newBalance = balanceBefore + item.getQuantity();

            inventory.setQuantity(newBalance);
            inventoryMapper.updateById(inventory);

            ProductInventoryTransaction transaction = new ProductInventoryTransaction();
            transaction.setTransactionNo("TX" + LocalDateTime.now().format(NO_FORMATTER) + String.format("%04d", item.getProductId().intValue()));
            transaction.setWarehouseId(warehouseId);
            transaction.setWarehouseName(warehouse.getName());
            transaction.setProductId(item.getProductId());
            transaction.setProductName(product.getName());
            transaction.setProductCategory(product.getCategory());
            transaction.setTransactionType("INBOUND");
            transaction.setDetailType(request.getInboundType());
            transaction.setQuantity(item.getQuantity());
            transaction.setUnitPrice(item.getUnitPrice() != null ? item.getUnitPrice() : BigDecimal.ZERO);
            transaction.setTotalAmount(transaction.getUnitPrice().multiply(BigDecimal.valueOf(item.getQuantity())));
            transaction.setBalanceBefore(balanceBefore);
            transaction.setBalanceAfter(newBalance);
            transaction.setRelatedOrderNo(request.getRelatedOrderNo());
            transaction.setRelatedBusinessNo("IN" + LocalDateTime.now().format(NO_FORMATTER));
            transaction.setSource(request.getSource());
            transaction.setRemark(request.getRemark());
            transaction.setOperator(operator);
            transaction.setCreateTime(LocalDateTime.now());

            transactionMapper.insert(transaction);
            results.add(convertToDTO(transaction));
        }

        return results;
    }

    private ProductInventory getOrCreateInventory(Long warehouseId, Long productId) {
        QueryWrapper<ProductInventory> wrapper = new QueryWrapper<>();
        wrapper.eq("warehouse_id", warehouseId).eq("product_id", productId);
        ProductInventory inventory = inventoryMapper.selectOne(wrapper);

        if (inventory == null) {
            inventory = new ProductInventory();
            inventory.setWarehouseId(warehouseId);
            inventory.setProductId(productId);
            inventory.setQuantity(0);
            inventoryMapper.insert(inventory);
        }
        return inventory;
    }

    public Integer getCurrentStock(Long warehouseId, Long productId) {
        QueryWrapper<ProductInventory> wrapper = new QueryWrapper<>();
        wrapper.eq("warehouse_id", warehouseId).eq("product_id", productId);
        ProductInventory inventory = inventoryMapper.selectOne(wrapper);
        return inventory != null && inventory.getQuantity() != null ? inventory.getQuantity() : 0;
    }

    private ProductInventoryTransactionDTO convertToDTO(ProductInventoryTransaction transaction) {
        ProductInventoryTransactionDTO dto = new ProductInventoryTransactionDTO();
        dto.setId(transaction.getId());
        dto.setTransactionNo(transaction.getTransactionNo());
        dto.setWarehouseId(transaction.getWarehouseId());
        dto.setWarehouseName(transaction.getWarehouseName());
        dto.setProductId(transaction.getProductId());
        dto.setProductName(transaction.getProductName());
        dto.setProductCategory(transaction.getProductCategory());
        dto.setTransactionType(transaction.getTransactionType());
        dto.setTransactionTypeText("INBOUND".equals(transaction.getTransactionType()) ? "入库" : "出库");
        dto.setDetailType(transaction.getDetailType());
        dto.setDetailTypeText(getDetailTypeText(transaction.getDetailType()));
        dto.setQuantity(transaction.getQuantity());
        dto.setUnitPrice(transaction.getUnitPrice());
        dto.setTotalAmount(transaction.getTotalAmount());
        dto.setBalanceBefore(transaction.getBalanceBefore());
        dto.setBalanceAfter(transaction.getBalanceAfter());
        dto.setRelatedOrderNo(transaction.getRelatedOrderNo());
        dto.setRelatedBusinessNo(transaction.getRelatedBusinessNo());
        dto.setSource(transaction.getSource());
        dto.setDestination(transaction.getDestination());
        dto.setRemark(transaction.getRemark());
        dto.setOperator(transaction.getOperator());
        dto.setCreateTime(transaction.getCreateTime());
        dto.setUpdateTime(transaction.getUpdateTime());
        return dto;
    }

    private String getDetailTypeText(String detailType) {
        if (detailType == null) return "";
        return switch (detailType) {
            case "production" -> "生产入库";
            case "purchase" -> "采购入库";
            case "transfer_in" -> "调拨入库";
            case "return" -> "退货入库";
            case "check_in" -> "盘盈入库";
            case "order" -> "订单出库";
            case "damage" -> "报损出库";
            case "transfer_out" -> "调拨出库";
            case "check_out" -> "盘亏出库";
            case "return_to_supplier" -> "退货给供应商";
            default -> detailType;
        };
    }
}
