package com.bucketwater.oms.module.admin.service;

import com.bucketwater.oms.common.exception.BusinessException;
import com.bucketwater.oms.common.response.ResultCode;
import com.bucketwater.oms.module.admin.controller.AdminInventoryController;
import com.bucketwater.oms.module.admin.dto.*;
import com.bucketwater.oms.module.admin.entity.InventoryCheck;
import com.bucketwater.oms.module.admin.entity.InventoryCheckItem;
import com.bucketwater.oms.module.admin.mapper.InventoryCheckItemMapper;
import com.bucketwater.oms.module.admin.mapper.InventoryCheckMapper;
import com.bucketwater.oms.module.bucket.entity.BucketTransaction;
import com.bucketwater.oms.module.bucket.mapper.BucketTransactionMapper;
import com.bucketwater.oms.module.inventory.entity.ProductInbound;
import com.bucketwater.oms.module.inventory.entity.InventoryDamage;
import com.bucketwater.oms.module.inventory.entity.ProductInventoryTransaction;
import com.bucketwater.oms.module.inventory.mapper.ProductInboundMapper;
import com.bucketwater.oms.module.inventory.mapper.InventoryDamageMapper;
import com.bucketwater.oms.module.inventory.mapper.ProductInventoryTransactionMapper;
import com.bucketwater.oms.module.notification.entity.Notification;
import com.bucketwater.oms.module.notification.mapper.NotificationMapper;
import com.bucketwater.oms.module.order.entity.Order;
import com.bucketwater.oms.module.order.entity.OrderItem;
import com.bucketwater.oms.module.order.mapper.OrderItemMapper;
import com.bucketwater.oms.module.order.mapper.OrderMapper;
import com.bucketwater.oms.module.product.entity.Product;
import com.bucketwater.oms.module.product.entity.ProductInventory;
import com.bucketwater.oms.module.product.mapper.ProductInventoryMapper;
import com.bucketwater.oms.module.product.mapper.ProductMapper;
import com.bucketwater.oms.module.station.entity.Station;
import com.bucketwater.oms.module.station.mapper.StationMapper;
import com.bucketwater.oms.module.user.entity.User;
import com.bucketwater.oms.module.user.mapper.UserMapper;
import com.bucketwater.oms.module.warehouse.entity.Warehouse;
import com.bucketwater.oms.module.warehouse.mapper.WarehouseMapper;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class AdminInventoryService {

    @Autowired
    private WarehouseMapper warehouseMapper;

    @Autowired
    private ProductMapper productMapper;

    @Autowired
    private ProductInventoryMapper inventoryMapper;

    @Autowired
    private OrderMapper orderMapper;

    @Autowired
    private OrderItemMapper orderItemMapper;

    @Autowired
    private BucketTransactionMapper bucketTransactionMapper;

    @Autowired
    private StationMapper stationMapper;

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private NotificationMapper notificationMapper;

    @Autowired
    private InventoryCheckMapper inventoryCheckMapper;

    @Autowired
    private InventoryCheckItemMapper inventoryCheckItemMapper;

    @Autowired
    private ProductInboundMapper productInboundMapper;

    @Autowired
    private InventoryDamageMapper inventoryDamageMapper;

    @Autowired
    private ProductInventoryTransactionMapper transactionMapper;

    private static final DateTimeFormatter NO_FORMATTER = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");

    public InventoryOverviewDTO getInventoryOverview(String warehouseId) {
        InventoryOverviewDTO overview = new InventoryOverviewDTO();
        
        List<Warehouse> warehouses;
        if (warehouseId != null && !warehouseId.isEmpty()) {
            Warehouse warehouse = warehouseMapper.selectById(Long.parseLong(warehouseId));
            warehouses = warehouse != null ? List.of(warehouse) : new ArrayList<>();
        } else {
            warehouses = warehouseMapper.selectList(
                new LambdaQueryWrapper<Warehouse>()
                    .eq(Warehouse::getStatus, "active")
            );
        }
        
        List<InventoryOverviewDTO.WarehouseInventory> warehouseInventories = new ArrayList<>();
        List<InventoryOverviewDTO.ProductInventory> productInventories = new ArrayList<>();
        
        for (Warehouse warehouse : warehouses) {
            InventoryOverviewDTO.WarehouseInventory wi = new InventoryOverviewDTO.WarehouseInventory();
            wi.setWarehouseId(warehouse.getId().toString());
            wi.setWarehouseName(warehouse.getName());
            wi.setStatus(warehouse.getStatus());
            
            List<InventoryOverviewDTO.ProductStock> stocks = new ArrayList<>();
            
            List<Product> products = productMapper.selectList(
                new LambdaQueryWrapper<Product>()
                    .eq(Product::getStatus, "active")
            );
            
            for (Product product : products) {
                ProductInventory inventory = inventoryMapper.selectOne(
                    new LambdaQueryWrapper<ProductInventory>()
                        .eq(ProductInventory::getProductId, product.getId())
                        .eq(ProductInventory::getWarehouseId, warehouse.getId())
                );
                
                InventoryOverviewDTO.ProductStock stock = new InventoryOverviewDTO.ProductStock();
                stock.setProductId(product.getId().toString());
                stock.setProductName(product.getName());
                stock.setCategory(product.getCategory());
                stock.setQuantity(inventory != null ? inventory.getQuantity() : 0);
                stock.setSafeStock(product.getSafeStock() != null ? product.getSafeStock() : 200);
                
                if (inventory != null && inventory.getQuantity() < stock.getSafeStock()) {
                    stock.setStatus("warning");
                    stock.setStatusText("库存告警");
                } else {
                    stock.setStatus("normal");
                    stock.setStatusText("状态良好");
                }
                
                stocks.add(stock);
            }
            
            wi.setStocks(stocks);
            warehouseInventories.add(wi);
        }
        
        overview.setWarehouses(warehouseInventories);
        overview.setLastUpdateTime(LocalDateTime.now().toString());
        
        List<Product> allProducts = productMapper.selectList(
            new LambdaQueryWrapper<Product>()
                .eq(Product::getStatus, "active")
        );
        
        Map<String, Integer> categoryTotals = new HashMap<>();
        for (Product product : allProducts) {
            int totalQty = 0;
            for (Warehouse warehouse : warehouses) {
                ProductInventory inv = inventoryMapper.selectOne(
                    new LambdaQueryWrapper<ProductInventory>()
                        .eq(ProductInventory::getProductId, product.getId())
                        .eq(ProductInventory::getWarehouseId, warehouse.getId())
                );
                if (inv != null && inv.getQuantity() != null) {
                    totalQty += inv.getQuantity();
                }
            }
            
            InventoryOverviewDTO.ProductInventory pi = new InventoryOverviewDTO.ProductInventory();
            pi.setProductId(product.getId().toString());
            pi.setProductName(product.getName());
            pi.setCategory(product.getCategory());
            pi.setCategoryText(getCategoryText(product.getCategory()));
            pi.setTotalQuantity(totalQty);
            pi.setSafeStock(product.getSafeStock() != null ? product.getSafeStock() : 200);
            pi.setStatus(totalQty < pi.getSafeStock() ? "warning" : "normal");
            productInventories.add(pi);
            
            categoryTotals.merge(product.getCategory(), totalQty, Integer::sum);
        }
        
        overview.setProducts(productInventories);
        
        return overview;
    }

    private String getCategoryText(String category) {
        if (category == null) return "其他";
        return switch (category) {
            case "bucket_water" -> "桶装水";
            case "bottled_water" -> "瓶装水";
            case "一次性桶装水" -> "一次性桶装水";
            default -> category;
        };
    }

    public List<InventoryRecordDTO> getInventoryRecords(String warehouseId, String businessType, String dateRange) {
        List<InventoryRecordDTO> records = new ArrayList<>();
        
        LocalDateTime startTime = null;
        LocalDateTime endTime = LocalDateTime.now();
        
        if ("today".equals(dateRange)) {
            startTime = LocalDateTime.now().toLocalDate().atStartOfDay();
        } else if ("week".equals(dateRange)) {
            startTime = endTime.minusDays(7);
        } else if ("month".equals(dateRange)) {
            startTime = endTime.minusDays(30);
        }
        
        if (businessType == null || businessType.isEmpty() || businessType.equals("all")) {
            records.addAll(getSalesOutboundRecords(startTime, endTime));
            records.addAll(getProductionInboundRecords(startTime, endTime));
            records.addAll(getBucketReturnRecords(startTime, endTime));
            records.addAll(getDamageRecords(startTime, endTime));
        } else {
            records.addAll(switch (businessType) {
                case "sales_outbound" -> getSalesOutboundRecords(startTime, endTime);
                case "production_inbound" -> getProductionInboundRecords(startTime, endTime);
                case "bucket_return" -> getBucketReturnRecords(startTime, endTime);
                case "damage" -> getDamageRecords(startTime, endTime);
                default -> new ArrayList<>();
            });
        }
        
        records.sort((a, b) -> b.getOperateTime().compareTo(a.getOperateTime()));
        
        return records;
    }

    private List<InventoryRecordDTO> getSalesOutboundRecords(LocalDateTime startTime, LocalDateTime endTime) {
        List<InventoryRecordDTO> records = new ArrayList<>();
        
        LambdaQueryWrapper<Order> query = new LambdaQueryWrapper<>();
        query.eq(Order::getStatus, "completed");
        if (startTime != null) {
            query.ge(Order::getDeliveredAt, startTime);
        }
        query.le(Order::getDeliveredAt, endTime);
        
        List<Order> orders = orderMapper.selectList(query);
        
        for (Order order : orders) {
            List<OrderItem> items = orderItemMapper.selectList(
                new LambdaQueryWrapper<OrderItem>()
                    .eq(OrderItem::getOrderId, order.getId())
            );
            
            Station station = stationMapper.selectById(order.getStationId());
            String stationName = station != null ? station.getName() : "";
            
            for (OrderItem item : items) {
                Product product = productMapper.selectById(item.getProductId());
                
                InventoryRecordDTO record = new InventoryRecordDTO();
                record.setId(UUID.randomUUID().toString());
                record.setOperateTime(order.getDeliveredAt());
                record.setBusinessType("sales_outbound");
                record.setBusinessTypeText("销售出库");
                record.setProductName(product != null ? product.getName() : "");
                record.setQuantityChange(-item.getActualQty());
                record.setRelatedObject(stationName);
                record.setOperator("张德发");
                
                records.add(record);
            }
        }
        
        return records;
    }

    private List<InventoryRecordDTO> getProductionInboundRecords(LocalDateTime startTime, LocalDateTime endTime) {
        List<InventoryRecordDTO> records = new ArrayList<>();
        
        LambdaQueryWrapper<ProductInbound> query = new LambdaQueryWrapper<>();
        query.eq(ProductInbound::getStatus, "confirmed");
        if (startTime != null) {
            query.ge(ProductInbound::getConfirmTime, startTime);
        }
        query.le(ProductInbound::getConfirmTime, endTime);
        
        List<ProductInbound> inbounds = productInboundMapper.selectList(query);
        
        for (ProductInbound inbound : inbounds) {
            Product product = productMapper.selectById(inbound.getProductId());
            
            InventoryRecordDTO record = new InventoryRecordDTO();
            record.setId(inbound.getId().toString());
            record.setOperateTime(inbound.getConfirmTime() != null ? inbound.getConfirmTime() : inbound.getCreateTime());
            record.setBusinessType("production_inbound");
            record.setBusinessTypeText("生产入库");
            record.setProductName(product != null ? product.getName() : "");
            record.setQuantityChange(inbound.getQuantity());
            record.setRelatedObject(inbound.getSource() != null ? inbound.getSource() : "");
            record.setOperator(inbound.getConfirmer() != null ? inbound.getConfirmer() : inbound.getCreator());
            
            records.add(record);
        }
        
        return records;
    }

    private List<InventoryRecordDTO> getBucketReturnRecords(LocalDateTime startTime, LocalDateTime endTime) {
        List<InventoryRecordDTO> records = new ArrayList<>();
        
        LambdaQueryWrapper<BucketTransaction> query = new LambdaQueryWrapper<>();
        query.eq(BucketTransaction::getType, "return");
        if (startTime != null) {
            query.ge(BucketTransaction::getCreatedAt, startTime);
        }
        query.le(BucketTransaction::getCreatedAt, endTime);
        
        List<BucketTransaction> transactions = bucketTransactionMapper.selectList(query);
        
        for (BucketTransaction tx : transactions) {
            Station station = stationMapper.selectById(tx.getStationId());
            
            InventoryRecordDTO record = new InventoryRecordDTO();
            record.setId(tx.getId().toString());
            record.setOperateTime(tx.getCreatedAt());
            record.setBusinessType("bucket_return");
            record.setBusinessTypeText("空桶回厂");
            record.setProductName("18L 聚碳酸酯桶");
            record.setQuantityChange(tx.getQuantity());
            record.setRelatedObject(station != null ? station.getName() : "");
            record.setOperator("刘大锤");
            
            records.add(record);
        }
        
        return records;
    }

    private List<InventoryRecordDTO> getDamageRecords(LocalDateTime startTime, LocalDateTime endTime) {
        List<InventoryRecordDTO> records = new ArrayList<>();
        
        LambdaQueryWrapper<InventoryDamage> query = new LambdaQueryWrapper<>();
        if (startTime != null) {
            query.ge(InventoryDamage::getCreateTime, startTime);
        }
        query.le(InventoryDamage::getCreateTime, endTime);
        
        List<InventoryDamage> damages = inventoryDamageMapper.selectList(query);
        
        for (InventoryDamage damage : damages) {
            Product product = productMapper.selectById(damage.getProductId());
            
            InventoryRecordDTO record = new InventoryRecordDTO();
            record.setId(damage.getId().toString());
            record.setOperateTime(damage.getCreateTime());
            record.setBusinessType("damage");
            record.setBusinessTypeText("库存报损");
            record.setProductName(product != null ? product.getName() : "");
            record.setQuantityChange(-damage.getQuantity());
            record.setRelatedObject(damage.getReason() != null ? damage.getReason() : "");
            record.setOperator(damage.getReporter() != null ? damage.getReporter() : damage.getHandler());
            
            records.add(record);
        }
        
        return records;
    }

    @Transactional
    public void recordInbound(AdminInventoryController.InboundRequest request) {
        Long warehouseIdLong = Long.parseLong(request.getWarehouseId());
        Long productIdLong = Long.parseLong(request.getProductId());
        Integer quantity = request.getQuantity();
        String operator = request.getOperator();
        String type = request.getType();
        String remark = request.getRemark();
        
        Warehouse warehouse = warehouseMapper.selectById(warehouseIdLong);
        if (warehouse == null) {
            throw new BusinessException(ResultCode.WAREHOUSE_NOT_FOUND);
        }
        
        Product product = productMapper.selectById(productIdLong);
        if (product == null) {
            throw new BusinessException(ResultCode.DATA_NOT_FOUND);
        }
        
        ProductInventory inventory = inventoryMapper.selectOne(
            new LambdaQueryWrapper<ProductInventory>()
                .eq(ProductInventory::getProductId, productIdLong)
                .eq(ProductInventory::getWarehouseId, warehouseIdLong)
        );
        
        int balanceBefore = 0;
        int newBalance = 0;
        
        if (inventory == null) {
            inventory = new ProductInventory();
            inventory.setProductId(productIdLong);
            inventory.setWarehouseId(warehouseIdLong);
            inventory.setQuantity(quantity);
            inventory.setSafeStock(product.getSafeStock() != null ? product.getSafeStock() : 200);
            inventory.setUpdatedAt(LocalDateTime.now());
            inventoryMapper.insert(inventory);
            balanceBefore = 0;
            newBalance = quantity;
        } else {
            balanceBefore = inventory.getQuantity() != null ? inventory.getQuantity() : 0;
            newBalance = balanceBefore + quantity;
            inventory.setQuantity(newBalance);
            inventory.setUpdatedAt(LocalDateTime.now());
            inventoryMapper.updateById(inventory);
        }
        
        String detailType = "production";
        if ("purchase".equals(type)) {
            detailType = "purchase";
        } else if ("transfer_in".equals(type)) {
            detailType = "transfer_in";
        } else if ("return".equals(type)) {
            detailType = "return";
        }
        
        ProductInventoryTransaction transaction = new ProductInventoryTransaction();
        transaction.setTransactionNo("TX" + LocalDateTime.now().format(NO_FORMATTER) + String.format("%04d", productIdLong.intValue()));
        transaction.setWarehouseId(warehouseIdLong);
        transaction.setWarehouseName(warehouse.getName());
        transaction.setProductId(productIdLong);
        transaction.setProductName(product.getName());
        transaction.setProductCategory(product.getCategory());
        transaction.setTransactionType("INBOUND");
        transaction.setDetailType(detailType);
        transaction.setQuantity(quantity);
        transaction.setUnitPrice(BigDecimal.ZERO);
        transaction.setTotalAmount(BigDecimal.ZERO);
        transaction.setBalanceBefore(balanceBefore);
        transaction.setBalanceAfter(newBalance);
        transaction.setSource(getInboundSourceText(detailType));
        transaction.setRemark(remark != null ? remark : "管理后台入库登记");
        transaction.setOperator(operator != null ? operator : "系统管理员");
        transaction.setCreateTime(LocalDateTime.now());
        transactionMapper.insert(transaction);
        
        Notification notification = new Notification();
        notification.setType("inventory");
        notification.setTitle("库存变更通知");
        notification.setContent("入库登记成功: " + product.getName() + " +" + quantity);
        notification.setCreateTime(LocalDateTime.now());
        notification.setIsRead(false);
        
        User warehouseAdmin = userMapper.selectOne(
            new LambdaQueryWrapper<User>()
                .eq(User::getWarehouseId, warehouseIdLong)
                .eq(User::getRole, "warehouse")
                .last("LIMIT 1")
        );
        if (warehouseAdmin != null) {
            notification.setUserId(warehouseAdmin.getId());
        }
        
        notificationMapper.insert(notification);
    }

    private String getInboundSourceText(String detailType) {
        return switch (detailType) {
            case "production" -> "生产入库";
            case "purchase" -> "采购入库";
            case "transfer_in" -> "调拨入库";
            case "return" -> "退货入库";
            default -> "管理员手动入库";
        };
    }

    public Map<String, Object> getInventoryStats(String warehouseId) {
        Map<String, Object> stats = new HashMap<>();
        
        List<Warehouse> warehouses;
        if (warehouseId != null && !warehouseId.isEmpty()) {
            Warehouse warehouse = warehouseMapper.selectById(Long.parseLong(warehouseId));
            warehouses = warehouse != null ? List.of(warehouse) : new ArrayList<>();
        } else {
            warehouses = warehouseMapper.selectList(
                new LambdaQueryWrapper<Warehouse>()
                    .eq(Warehouse::getStatus, "active")
            );
        }
        
        int totalStock = 0;
        int totalIn = 0;
        int totalOut = 0;
        int lowStockCount = 0;
        int damagedCount = 0;
        
        for (Warehouse warehouse : warehouses) {
            List<Product> products = productMapper.selectList(
                new LambdaQueryWrapper<Product>()
                    .eq(Product::getStatus, "active")
            );
            
            for (Product product : products) {
                ProductInventory inventory = inventoryMapper.selectOne(
                    new LambdaQueryWrapper<ProductInventory>()
                        .eq(ProductInventory::getProductId, product.getId())
                        .eq(ProductInventory::getWarehouseId, warehouse.getId())
                );
                
                int qty = inventory != null ? inventory.getQuantity() : 0;
                totalStock += qty;
                
                int safeStock = product.getSafeStock() != null ? product.getSafeStock() : 200;
                if (qty < safeStock) {
                    lowStockCount++;
                }
            }
        }
        
        LocalDateTime startOfMonth = LocalDateTime.now().withDayOfMonth(1).withHour(0).withMinute(0).withSecond(0);
        
        LambdaQueryWrapper<Order> orderQuery = new LambdaQueryWrapper<>();
        orderQuery.eq(Order::getStatus, "completed");
        orderQuery.ge(Order::getDeliveredAt, startOfMonth);
        List<Order> completedOrders = orderMapper.selectList(orderQuery);
        
        for (Order order : completedOrders) {
            List<OrderItem> items = orderItemMapper.selectList(
                new LambdaQueryWrapper<OrderItem>()
                    .eq(OrderItem::getOrderId, order.getId())
            );
            for (OrderItem item : items) {
                totalOut += item.getActualQty();
            }
        }
        
        LambdaQueryWrapper<ProductInventory> invQuery = new LambdaQueryWrapper<>();
        if (warehouseId != null && !warehouseId.isEmpty()) {
            invQuery.eq(ProductInventory::getWarehouseId, Long.parseLong(warehouseId));
        }
        List<ProductInventory> allInventories = inventoryMapper.selectList(invQuery);
        int totalInventoryValue = allInventories.stream().mapToInt(ProductInventory::getQuantity).sum();
        
        damagedCount = 0;
        
        String damageRate = totalStock > 0 ? String.format("%.2f", (damagedCount * 100.0 / totalStock)) : "0.00";
        
        stats.put("totalStock", totalStock);
        stats.put("totalIn", totalIn);
        stats.put("totalOut", totalOut);
        stats.put("lowStockCount", lowStockCount);
        stats.put("damagedCount", damagedCount);
        stats.put("damageRate", damageRate);
        stats.put("bottleWaterStock", totalStock);
        stats.put("bottleStock", 0);
        stats.put("emptyBucketStock", 0);
        stats.put("safeStock", 2000);

        return stats;
    }

    public List<InventoryCheckDTO> getInventoryCheckRecords(String warehouseId) {
        LambdaQueryWrapper<InventoryCheck> query = new LambdaQueryWrapper<>();
        if (warehouseId != null && !warehouseId.isEmpty()) {
            query.eq(InventoryCheck::getWarehouseId, Long.parseLong(warehouseId));
        }
        query.orderByDesc(InventoryCheck::getCheckDate);

        List<InventoryCheck> checks = inventoryCheckMapper.selectList(query);

        return checks.stream().map(this::convertToDTO).collect(Collectors.toList());
    }

    public InventoryCheckDTO getInventoryCheckById(String checkId) {
        InventoryCheck check = inventoryCheckMapper.selectById(checkId);
        if (check == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "盘点记录不存在");
        }

        InventoryCheckDTO dto = convertToDTO(check);

        LambdaQueryWrapper<InventoryCheckItem> itemQuery = new LambdaQueryWrapper<>();
        itemQuery.eq(InventoryCheckItem::getCheckId, check.getId());
        List<InventoryCheckItem> items = inventoryCheckItemMapper.selectList(itemQuery);

        dto.setItems(items.stream().map(this::convertItemToDTO).collect(Collectors.toList()));

        return dto;
    }

    @Transactional
    public InventoryCheckDTO createInventoryCheck(CreateInventoryCheckRequest request) {
        Long warehouseIdLong = Long.parseLong(request.getWarehouseId());
        Warehouse warehouse = warehouseMapper.selectById(warehouseIdLong);
        if (warehouse == null) {
            throw new BusinessException(ResultCode.WAREHOUSE_NOT_FOUND);
        }
        
        InventoryCheck check = new InventoryCheck();
        check.setWarehouseId(warehouseIdLong);
        check.setWarehouseName(warehouse.getName());
        check.setCheckDate(LocalDateTime.now());
        check.setChecker(request.getChecker() != null ? request.getChecker() : "系统管理员");
        check.setStatus("pending");
        check.setSummary(request.getSummary());
        check.setTotalProducts(0);
        check.setMatchedProducts(0);
        check.setDiscrepancyProducts(0);

        inventoryCheckMapper.insert(check);

        Long checkId = check.getId();

        int totalProducts = 0;
        int matchedProducts = 0;
        int discrepancyProducts = 0;

        if (request.getItems() != null && !request.getItems().isEmpty()) {
            totalProducts = request.getItems().size();

            for (InventoryCheckItemDTO itemDTO : request.getItems()) {
                InventoryCheckItem item = new InventoryCheckItem();
                item.setCheckId(checkId);
                item.setProductId(Long.parseLong(itemDTO.getProductId()));
                item.setProductName(itemDTO.getProductName());
                item.setCategory(itemDTO.getCategory());
                item.setSystemQuantity(itemDTO.getSystemQuantity());
                item.setActualQuantity(itemDTO.getActualQuantity());
                item.setDiscrepancy(itemDTO.getActualQuantity() - itemDTO.getSystemQuantity());
                item.setRemark(itemDTO.getRemark());

                if (item.getDiscrepancy() == 0) {
                    matchedProducts++;
                } else {
                    discrepancyProducts++;
                }

                inventoryCheckItemMapper.insert(item);
            }
        }

        check.setTotalProducts(totalProducts);
        check.setMatchedProducts(matchedProducts);
        check.setDiscrepancyProducts(discrepancyProducts);
        inventoryCheckMapper.updateById(check);

        Notification notification = new Notification();
        notification.setType("inventory");
        notification.setContent("库存盘点完成: " + warehouse.getName() + ", 差异商品数: " + discrepancyProducts);
        notification.setCreateTime(LocalDateTime.now());
        notificationMapper.insert(notification);

        return getInventoryCheckById(checkId.toString());
    }

    @Transactional
    public InventoryCheckDTO confirmInventoryCheck(String checkId) {
        InventoryCheck check = inventoryCheckMapper.selectById(Long.parseLong(checkId));
        if (check == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "盘点记录不存在");
        }

        if ("confirmed".equals(check.getStatus())) {
            throw new BusinessException(ResultCode.PARAM_ERROR, "该盘点记录已确认");
        }

        LambdaQueryWrapper<InventoryCheckItem> itemQuery = new LambdaQueryWrapper<>();
        itemQuery.eq(InventoryCheckItem::getCheckId, check.getId());
        List<InventoryCheckItem> items = inventoryCheckItemMapper.selectList(itemQuery);

        for (InventoryCheckItem item : items) {
            if (item.getDiscrepancy() != 0) {
                ProductInventory inventory = inventoryMapper.selectOne(
                    new LambdaQueryWrapper<ProductInventory>()
                        .eq(ProductInventory::getProductId, item.getProductId())
                        .eq(ProductInventory::getWarehouseId, check.getWarehouseId())
                );

                if (inventory != null) {
                    inventory.setQuantity(item.getActualQuantity());
                    inventory.setUpdatedAt(LocalDateTime.now());
                    inventoryMapper.updateById(inventory);
                }
            }
        }

        check.setStatus("confirmed");
        inventoryCheckMapper.updateById(check);

        return getInventoryCheckById(checkId);
    }

    private InventoryCheckDTO convertToDTO(InventoryCheck check) {
        InventoryCheckDTO dto = new InventoryCheckDTO();
        dto.setId(check.getId().toString());
        dto.setWarehouseId(check.getWarehouseId().toString());
        dto.setWarehouseName(check.getWarehouseName());
        dto.setCheckDate(check.getCheckDate());
        dto.setChecker(check.getChecker());
        dto.setStatus(check.getStatus());
        dto.setSummary(check.getSummary());
        dto.setTotalProducts(check.getTotalProducts());
        dto.setMatchedProducts(check.getMatchedProducts());
        dto.setDiscrepancyProducts(check.getDiscrepancyProducts());
        dto.setCreateTime(check.getCreateTime());
        return dto;
    }

    private InventoryCheckItemDTO convertItemToDTO(InventoryCheckItem item) {
        InventoryCheckItemDTO dto = new InventoryCheckItemDTO();
        dto.setId(item.getId().toString());
        dto.setCheckId(item.getCheckId().toString());
        dto.setProductId(item.getProductId().toString());
        dto.setProductName(item.getProductName());
        dto.setCategory(item.getCategory());
        dto.setSystemQuantity(item.getSystemQuantity());
        dto.setActualQuantity(item.getActualQuantity());
        dto.setDiscrepancy(item.getDiscrepancy());
        dto.setRemark(item.getRemark());
        return dto;
    }
}
