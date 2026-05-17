package com.bucketwater.oms.module.station.service;

import com.bucketwater.oms.common.exception.BusinessException;
import com.bucketwater.oms.common.response.ResultCode;
import com.bucketwater.oms.module.notification.entity.Notification;
import com.bucketwater.oms.module.notification.mapper.NotificationMapper;
import com.bucketwater.oms.module.order.entity.Order;
import com.bucketwater.oms.module.order.mapper.OrderMapper;
import com.bucketwater.oms.module.product.entity.Product;
import com.bucketwater.oms.module.product.entity.ProductInventory;
import com.bucketwater.oms.module.product.entity.ProductTierPrice;
import com.bucketwater.oms.module.product.entity.StationProductPrice;
import com.bucketwater.oms.module.product.mapper.ProductInventoryMapper;
import com.bucketwater.oms.module.product.mapper.ProductMapper;
import com.bucketwater.oms.module.product.mapper.ProductTierPriceMapper;
import com.bucketwater.oms.module.product.mapper.StationProductPriceMapper;
import com.bucketwater.oms.module.product.service.ProductService;
import com.bucketwater.oms.module.order.entity.OrderItem;
import com.bucketwater.oms.module.order.mapper.OrderItemMapper;
import com.bucketwater.oms.module.station.dto.InventoryDTO;
import com.bucketwater.oms.module.station.dto.MonthlyStatementDTO;
import com.bucketwater.oms.module.station.dto.ProductPriceDTO;
import com.bucketwater.oms.module.station.dto.RechargeRequest;
import com.bucketwater.oms.module.station.dto.StationDashboardDTO;
import com.bucketwater.oms.module.station.dto.StationInfoDTO;
import com.bucketwater.oms.module.station.entity.Station;
import com.bucketwater.oms.module.station.entity.StationAccount;
import com.bucketwater.oms.module.station.mapper.StationAccountMapper;
import com.bucketwater.oms.module.station.mapper.StationMapper;
import com.bucketwater.oms.module.warehouse.entity.Warehouse;
import com.bucketwater.oms.module.warehouse.mapper.WarehouseMapper;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;


@Service
public class StationService {

    @Autowired
    private StationMapper stationMapper;

    @Autowired
    private StationAccountMapper stationAccountMapper;

    @Autowired
    private WarehouseMapper warehouseMapper;

    @Autowired
    private ProductMapper productMapper;

    @Autowired
    private ProductInventoryMapper productInventoryMapper;

    @Autowired
    private ProductService productService;

    @Autowired
    private StationProductPriceMapper stationProductPriceMapper;

    @Autowired
    private ProductTierPriceMapper productTierPriceMapper;

    @Autowired
    private OrderMapper orderMapper;

    @Autowired
    private OrderItemMapper orderItemMapper;

    @Autowired
    private NotificationMapper notificationMapper;

    public StationDashboardDTO getDashboard(Long stationId) {
        StationDashboardDTO dashboard = new StationDashboardDTO();

        Station station = stationMapper.selectById(stationId);
        if (station != null) {
            dashboard.setStationId(station.getId().toString());
            dashboard.setStationName(station.getName());
            dashboard.setContact(station.getContact());
            dashboard.setContactPhone(station.getPhone());
            dashboard.setAddress(station.getAddress());
        }

        StationAccount account = stationAccountMapper.selectOne(
            new LambdaQueryWrapper<StationAccount>()
                .eq(StationAccount::getStationId, stationId)
        );

        if (account != null) {
            dashboard.setAccountBalance(account.getDepositBalance());
            dashboard.setCreditLimit(account.getCreditLimit());
            dashboard.setUsedCredit(account.getCreditUsed());
            dashboard.setAvailableCredit(account.getCreditLimit().subtract(account.getCreditUsed()));
            dashboard.setOwedBucketNum(account.getOwedBucketNum());
            dashboard.setOwedThreshold(account.getOwedThreshold());
            dashboard.setOverThreshold(account.getOwedBucketNum() >= account.getOwedThreshold());
        } else {
            dashboard.setAccountBalance(BigDecimal.ZERO);
            dashboard.setCreditLimit(BigDecimal.ZERO);
            dashboard.setUsedCredit(BigDecimal.ZERO);
            dashboard.setAvailableCredit(BigDecimal.ZERO);
            dashboard.setOwedBucketNum(0);
            dashboard.setOwedThreshold(10);
            dashboard.setOverThreshold(false);
        }

        LambdaQueryWrapper<Order> orderQuery = new LambdaQueryWrapper<Order>()
            .eq(Order::getStationId, stationId)
            .orderByDesc(Order::getCreateTime)
            .last("LIMIT 10");
        List<Order> recentOrders = orderMapper.selectList(orderQuery);

        List<StationDashboardDTO.RecentOrderDTO> orderDTOs = recentOrders.stream()
            .map(order -> new StationDashboardDTO.RecentOrderDTO(
                order.getId().toString(),
                order.getOrderNo(),
                order.getStatus(),
                getOrderStatusText(order.getStatus()),
                order.getTotalAmount(),
                order.getItems() != null ? order.getItems().stream()
                    .mapToInt(item -> item.getQuantity())
                    .sum() : 0,
                order.getCreateTime() != null ? order.getCreateTime().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")) : ""
            ))
            .collect(Collectors.toList());
        dashboard.setRecentOrders(orderDTOs);

        LambdaQueryWrapper<Notification> notificationQuery = new LambdaQueryWrapper<Notification>()
            .orderByDesc(Notification::getCreateTime)
            .last("LIMIT 5");
        List<Notification> notifications = notificationMapper.selectList(notificationQuery);

        List<StationDashboardDTO.NotificationDTO> notificationDTOs = notifications.stream()
            .map(n -> new StationDashboardDTO.NotificationDTO(
                n.getId().toString(),
                getNotificationTitle(n.getType()),
                n.getContent(),
                n.getType(),
                n.getCreateTime() != null ? n.getCreateTime().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")) : ""
            ))
            .collect(Collectors.toList());
        dashboard.setNotifications(notificationDTOs);

        return dashboard;
    }

    private String getOrderStatusText(String status) {
        if (status == null) return "未知";
        return switch (status) {
            case "pending_review" -> "待审核";
            case "reviewed" -> "已接单";
            case "dispatched" -> "已派单";
            case "delivering" -> "配送中";
            case "completed" -> "已完成";
            case "cancelled" -> "已取消";
            case "rejected" -> "已拒单";
            default -> status;
        };
    }

    private String getNotificationTitle(String type) {
        if (type == null) return "系统通知";
        return switch (type) {
            case "inventory_warning" -> "库存预警";
            case "statement_dispute" -> "对账单争议";
            case "order_status" -> "订单状态通知";
            case "payment_reminder" -> "付款提醒";
            case "system_notice" -> "系统通知";
            default -> "系统通知";
        };
    }

    public StationInfoDTO getStationInfo(Long stationId) {
        Station station = stationMapper.selectById(stationId);
        if (station == null) {
            throw new BusinessException(ResultCode.STATION_NOT_FOUND);
        }

        StationAccount account = stationAccountMapper.selectOne(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<StationAccount>()
                .eq(StationAccount::getStationId, stationId)
        );

        StationInfoDTO.AccountInfo accountInfo = null;
        if (account != null) {
            BigDecimal creditAvailable = BigDecimal.ZERO;
            if (account.getCreditLimit() != null && account.getCreditUsed() != null) {
                creditAvailable = account.getCreditLimit().subtract(account.getCreditUsed());
            }

            Boolean isWarning = false;
            if (account.getOwedBucketNum() != null && account.getOwedThreshold() != null) {
                isWarning = account.getOwedBucketNum() >= account.getOwedThreshold();
            }

            accountInfo = new StationInfoDTO.AccountInfo(
                account.getDepositBalance() != null ? account.getDepositBalance() : BigDecimal.ZERO,
                account.getCreditLimit() != null ? account.getCreditLimit() : BigDecimal.ZERO,
                account.getCreditUsed() != null ? account.getCreditUsed() : BigDecimal.ZERO,
                creditAvailable,
                account.getBucketDepositPerUnit() != null ? account.getBucketDepositPerUnit() : BigDecimal.ZERO,
                account.getOwedBucketNum() != null ? account.getOwedBucketNum() : 0,
                account.getOwedThreshold() != null ? account.getOwedThreshold() : 10,
                isWarning
            );
        }

        StationInfoDTO.PolicyInfo policyInfo = buildPolicyInfo(stationId, account);

        return new StationInfoDTO(
            station.getId().toString(),
            station.getName(),
            station.getContact(),
            station.getPhone(),
            station.getAddress(),
            accountInfo,
            policyInfo,
            station.getStatus()
        );
    }

    private StationInfoDTO.PolicyInfo buildPolicyInfo(Long stationId, StationAccount account) {
        String paymentType = account != null ? account.getPaymentType() : "prepaid";

        List<StationInfoDTO.PriceItem> priceItems = new ArrayList<>();

        List<Product> products = productMapper.selectList(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Product>()
                .eq(Product::getStatus, "active")
        );

        for (Product product : products) {
            BigDecimal unitPrice = productService.getProductPriceForStation(stationId, product.getId(), 1);

            BigDecimal tierPrice = null;
            Integer tierThreshold = null;

            List<ProductTierPrice> tierPrices = productTierPriceMapper.findAllTiers(stationId, product.getId());
            if (!tierPrices.isEmpty()) {
                ProductTierPrice lowestTier = tierPrices.stream()
                    .min((a, b) -> Integer.compare(a.getMinQuantity(), b.getMinQuantity()))
                    .orElse(null);
                if (lowestTier != null) {
                    tierPrice = lowestTier.getTierPrice();
                    tierThreshold = lowestTier.getMinQuantity();
                }
            }

            priceItems.add(new StationInfoDTO.PriceItem(
                product.getId().toString(),
                product.getName(),
                unitPrice,
                tierPrice,
                tierThreshold
            ));
        }

        return new StationInfoDTO.PolicyInfo(paymentType, priceItems);
    }

    public InventoryDTO getInventory(Long stationId) {
        List<Warehouse> warehouses = warehouseMapper.selectList(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Warehouse>()
                .eq(Warehouse::getStatus, "active")
        );

        Station station = stationMapper.selectById(stationId);

        List<InventoryDTO.WarehouseInventory> warehouseInventories = new ArrayList<>();
        for (Warehouse warehouse : warehouses) {
            List<InventoryDTO.ProductInventory> products = new ArrayList<>();

            List<ProductInventory> inventories = productInventoryMapper.selectList(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<ProductInventory>()
                    .eq(ProductInventory::getWarehouseId, warehouse.getId())
                    .gt(ProductInventory::getQuantity, 0)
            );

            for (ProductInventory inv : inventories) {
                Product product = productMapper.selectById(inv.getProductId());
                if (product != null && "active".equals(product.getStatus())) {
                    BigDecimal price = productService.getProductPriceForStation(stationId, inv.getProductId(), 1);

                    BigDecimal distance = calculateDistance(station, warehouse);
                    products.add(new InventoryDTO.ProductInventory(
                        product.getId().toString(),
                        product.getName(),
                        inv.getQuantity(),
                        price
                    ));
                }
            }

            BigDecimal distance = calculateDistance(station, warehouse);
            InventoryDTO.WarehouseInventory inventory = new InventoryDTO.WarehouseInventory(
                warehouse.getId().toString(),
                warehouse.getName(),
                distance,
                products
            );
            warehouseInventories.add(inventory);
        }

        return new InventoryDTO(warehouseInventories);
    }

    private BigDecimal calculateDistance(Station station, Warehouse warehouse) {
        if (station == null || warehouse == null) {
            return BigDecimal.ZERO;
        }

        BigDecimal lat1 = station.getLat();
        BigDecimal lng1 = station.getLng();
        BigDecimal lat2 = warehouse.getLat();
        BigDecimal lng2 = warehouse.getLng();

        if (lat1 == null || lng1 == null || lat2 == null || lng2 == null) {
            if (lat2 != null && lng2 != null) {
                return BigDecimal.valueOf(5.0);
            }
            return BigDecimal.ZERO;
        }

        double R = 6371;
        double dLat = Math.toRadians(lat2.doubleValue() - lat1.doubleValue());
        double dLng = Math.toRadians(lng2.doubleValue() - lng1.doubleValue());
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                   Math.cos(Math.toRadians(lat1.doubleValue())) * Math.cos(Math.toRadians(lat2.doubleValue())) *
                   Math.sin(dLng / 2) * Math.sin(dLng / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        double distance = R * c;

        return BigDecimal.valueOf(distance).setScale(1, java.math.RoundingMode.HALF_UP);
    }

    @Transactional
    public void recharge(Long stationId, RechargeRequest request) {
        StationAccount account = stationAccountMapper.selectOne(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<StationAccount>()
                .eq(StationAccount::getStationId, stationId)
        );

        if (account == null) {
            throw new BusinessException(ResultCode.STATION_NOT_FOUND);
        }

        account.setDepositBalance(account.getDepositBalance().add(request.getAmount()));
        account.setUpdatedAt(java.time.LocalDateTime.now());
        stationAccountMapper.updateById(account);
    }

    public void payBucketDeposit(Long stationId, Integer bucketNum) {
        StationAccount account = stationAccountMapper.selectOne(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<StationAccount>()
                .eq(StationAccount::getStationId, stationId)
        );

        if (account == null) {
            throw new BusinessException(ResultCode.STATION_NOT_FOUND);
        }

        BigDecimal totalAmount = account.getBucketDepositPerUnit().multiply(new BigDecimal(bucketNum));
        if (account.getDepositBalance().compareTo(totalAmount) < 0) {
            throw new BusinessException(ResultCode.BALANCE_INSUFFICIENT);
        }

        account.setDepositBalance(account.getDepositBalance().subtract(totalAmount));
        account.setOwedBucketNum(account.getOwedBucketNum() - bucketNum);
        account.setUpdatedAt(java.time.LocalDateTime.now());
        stationAccountMapper.updateById(account);
    }

    public Map<String, Object> confirmOrderDelivery(Long stationId, Long orderId, String confirmCode) {
        com.bucketwater.oms.module.order.entity.Order order = orderMapper.selectById(orderId);
        if (order == null) {
            throw new BusinessException(ResultCode.ORDER_NOT_FOUND);
        }

        if (!stationId.equals(order.getStationId())) {
            throw new BusinessException(ResultCode.ORDER_STATUS_NOT_ALLOWED, "该订单不属于当前水站");
        }

        if (!"delivering".equals(order.getStatus())) {
            throw new BusinessException(ResultCode.ORDER_STATUS_NOT_ALLOWED, "订单状态不允许确认收货");
        }

        String storedCode = order.getSignData();
        if (storedCode == null || !storedCode.equals(confirmCode)) {
            throw new BusinessException(ResultCode.PARAM_INVALID, "确认码错误");
        }

        Map<String, Object> result = new java.util.HashMap<>();
        result.put("success", true);
        result.put("message", "确认收货成功");
        result.put("orderId", orderId);
        result.put("orderNo", order.getOrderNo());
        result.put("confirmTime", java.time.LocalDateTime.now().format(java.time.format.DateTimeFormatter.ISO_LOCAL_DATE_TIME));

        return result;
    }

    public Map<String, Object> verifyOrderCode(Long stationId, Long orderId, String verifyCode) {
        com.bucketwater.oms.module.order.entity.Order order = orderMapper.selectById(orderId);
        if (order == null) {
            throw new BusinessException(ResultCode.ORDER_NOT_FOUND);
        }

        if (!stationId.equals(order.getStationId())) {
            throw new BusinessException(ResultCode.ORDER_STATUS_NOT_ALLOWED, "该订单不属于当前水站");
        }

        if (!"delivering".equals(order.getStatus())) {
            throw new BusinessException(ResultCode.ORDER_STATUS_NOT_ALLOWED, "订单状态不允许确认收货");
        }

        if (!"sms_code".equals(order.getSignType())) {
            throw new BusinessException(ResultCode.ORDER_STATUS_NOT_ALLOWED, "该订单不支持验证码确认");
        }

        String storedCode = order.getSignData();
        if (storedCode == null || !storedCode.equals(verifyCode)) {
            throw new BusinessException(ResultCode.PARAM_INVALID, "验证码错误");
        }

        Map<String, Object> result = new java.util.HashMap<>();
        result.put("success", true);
        result.put("message", "验证码确认成功");
        result.put("orderId", orderId);
        result.put("orderNo", order.getOrderNo());
        result.put("confirmTime", java.time.LocalDateTime.now().format(java.time.format.DateTimeFormatter.ISO_LOCAL_DATE_TIME));

        return result;
    }

    public Map<String, Object> sendOrderConfirmCode(Long stationId, Long orderId, String sendMethod) {
        com.bucketwater.oms.module.order.entity.Order order = orderMapper.selectById(orderId);
        if (order == null) {
            throw new BusinessException(ResultCode.ORDER_NOT_FOUND);
        }

        if (!stationId.equals(order.getStationId())) {
            throw new BusinessException(ResultCode.ORDER_STATUS_NOT_ALLOWED, "该订单不属于当前水站");
        }

        String confirmCode = generateConfirmCode();

        order.setSignType("boss_confirm");
        order.setSignData(confirmCode);
        order.setUpdateTime(LocalDateTime.now());
        orderMapper.updateById(order);

        Map<String, Object> result = new java.util.HashMap<>();
        result.put("confirmCode", confirmCode);
        result.put("message", "确认码已生成");
        result.put("sendMethod", sendMethod != null ? sendMethod : "manual");
        result.put("orderNo", order.getOrderNo());
        result.put("customerPhone", maskPhone(order.getContactPhone()));

        if (sendMethod == null || "sms".equals(sendMethod)) {
            result.put("smsSent", false);
            result.put("note", "请将确认码告知顾客");
        } else if ("manual".equals(sendMethod)) {
            result.put("note", "请将确认码告知顾客");
        }

        return result;
    }

    public Map<String, Object> getOrderConfirmCode(Long stationId, Long orderId) {
        com.bucketwater.oms.module.order.entity.Order order = orderMapper.selectById(orderId);
        if (order == null) {
            throw new BusinessException(ResultCode.ORDER_NOT_FOUND);
        }

        if (!stationId.equals(order.getStationId())) {
            throw new BusinessException(ResultCode.ORDER_STATUS_NOT_ALLOWED, "该订单不属于当前水站");
        }

        Map<String, Object> result = new java.util.HashMap<>();
        result.put("orderId", orderId);
        result.put("orderNo", order.getOrderNo());
        result.put("signType", order.getSignType());
        result.put("hasConfirmCode", "boss_confirm".equals(order.getSignType()) && order.getSignData() != null);

        if ("boss_confirm".equals(order.getSignType()) && order.getSignData() != null) {
            result.put("confirmCode", order.getSignData());
            result.put("confirmCodeHint", "请将确认码告知顾客");
        }

        return result;
    }

    private String generateConfirmCode() {
        java.util.Random random = new java.util.Random();
        int code = random.nextInt(10000);
        return String.format("%04d", code);
    }

    private String maskPhone(String phone) {
        if (phone == null || phone.length() < 7) {
            return phone;
        }
        return phone.substring(0, 3) + "****" + phone.substring(phone.length() - 4);
    }

    public List<ProductPriceDTO> getProductPrices(Long stationId) {
        List<Product> products = productMapper.selectList(
            new LambdaQueryWrapper<Product>()
                .eq(Product::getStatus, "active")
        );

        List<ProductPriceDTO> priceList = new ArrayList<>();
        for (Product product : products) {
            ProductPriceDTO priceInfo = productService.getProductPriceInfo(stationId, product.getId());
            if (priceInfo != null) {
                priceList.add(priceInfo);
            }
        }

        return priceList;
    }

    public MonthlyStatementDTO getMonthlyStatement(Long stationId, String yearMonth) {
        Station station = stationMapper.selectById(stationId);
        if (station == null) {
            throw new BusinessException(ResultCode.STATION_NOT_FOUND);
        }

        YearMonth ym;
        if (yearMonth != null && !yearMonth.isEmpty()) {
            ym = YearMonth.parse(yearMonth);
        } else {
            ym = YearMonth.now();
        }

        LocalDate startDate = ym.atDay(1);
        LocalDate endDate = ym.atEndOfMonth();

        LocalDateTime startDateTime = startDate.atStartOfDay();
        LocalDateTime endDateTime = endDate.atTime(23, 59, 59);

        List<Order> monthOrders = orderMapper.selectList(
            new LambdaQueryWrapper<Order>()
                .eq(Order::getStationId, stationId)
                .ge(Order::getCreateTime, startDateTime)
                .le(Order::getCreateTime, endDateTime)
        );

        StationAccount account = stationAccountMapper.selectOne(
            new LambdaQueryWrapper<StationAccount>()
                .eq(StationAccount::getStationId, stationId)
        );

        BigDecimal openingBalance = BigDecimal.ZERO;
        if (account != null && account.getDepositBalance() != null) {
            openingBalance = account.getDepositBalance();
        }

        BigDecimal totalAmount = BigDecimal.ZERO;
        BigDecimal paymentReceived = BigDecimal.ZERO;
        int totalBuckets = 0;
        int completedOrders = 0;

        List<MonthlyStatementDTO.OrderSummary> orderSummaries = new ArrayList<>();
        List<MonthlyStatementDTO.ProductSummary> productSummaries = new ArrayList<>();
        Map<Long, Integer> productQtyMap = new HashMap<>();
        Map<Long, String> productNameMap = new HashMap<>();

        for (Order order : monthOrders) {
            if (order.getTotalAmount() != null) {
                totalAmount = totalAmount.add(order.getTotalAmount());
            }

            if ("completed".equals(order.getStatus())) {
                completedOrders++;
                if (order.getTotalAmount() != null) {
                    paymentReceived = paymentReceived.add(order.getTotalAmount());
                }
            }

            List<OrderItem> items = orderItemMapper.selectList(
                new LambdaQueryWrapper<OrderItem>()
                    .eq(OrderItem::getOrderId, order.getId())
            );

            StringBuilder itemsBuilder = new StringBuilder();
            for (OrderItem item : items) {
                if (itemsBuilder.length() > 0) {
                    itemsBuilder.append(", ");
                }
                Product product = productMapper.selectById(item.getProductId());
                String productName = product != null ? product.getName() : "未知商品";
                itemsBuilder.append(productName).append("×").append(item.getQuantity());

                int qty = item.getQuantity() != null ? item.getQuantity() : 0;
                totalBuckets += qty;

                productQtyMap.merge(item.getProductId(), qty, Integer::sum);
                if (!productNameMap.containsKey(item.getProductId())) {
                    productNameMap.put(item.getProductId(), productName);
                }
            }

            MonthlyStatementDTO.OrderSummary orderSummary = new MonthlyStatementDTO.OrderSummary();
            orderSummary.setOrderId(order.getId().toString());
            orderSummary.setOrderNo(order.getOrderNo());
            orderSummary.setOrderDate(order.getCreateTime() != null ? order.getCreateTime().toLocalDate() : startDate);
            orderSummary.setAmount(order.getTotalAmount());
            orderSummary.setBuckets(items.stream().mapToInt(i -> i.getQuantity() != null ? i.getQuantity() : 0).sum());
            orderSummary.setStatus(order.getStatus());
            orderSummary.setItems(itemsBuilder.toString());
            orderSummaries.add(orderSummary);
        }

        for (Map.Entry<Long, Integer> entry : productQtyMap.entrySet()) {
            MonthlyStatementDTO.ProductSummary ps = new MonthlyStatementDTO.ProductSummary();
            ps.setProductId(entry.getKey().toString());
            ps.setProductName(productNameMap.getOrDefault(entry.getKey(), "未知商品"));
            ps.setQuantity(entry.getValue());
            ps.setUnit("桶");
            ps.setSubtotal(BigDecimal.ZERO);
            productSummaries.add(ps);
        }

        BigDecimal closingBalance = openingBalance.add(totalAmount).subtract(paymentReceived);

        MonthlyStatementDTO dto = new MonthlyStatementDTO();
        dto.setId(stationId.toString() + "_" + ym.format(DateTimeFormatter.ofPattern("yyyyMM")));
        dto.setStationId(stationId.toString());
        dto.setStationName(station.getName());
        dto.setYearMonth(ym.format(DateTimeFormatter.ofPattern("yyyy-MM")));
        dto.setStartDate(startDate);
        dto.setEndDate(endDate);
        dto.setOpeningBalance(openingBalance);
        dto.setTotalAmount(totalAmount);
        dto.setPaymentReceived(paymentReceived);
        dto.setClosingBalance(closingBalance);
        dto.setTotalOrders(monthOrders.size());
        dto.setCompletedOrders(completedOrders);
        dto.setTotalBuckets(totalBuckets);
        dto.setStatus("pending");
        dto.setGeneratedAt(LocalDateTime.now());
        dto.setOrders(orderSummaries);
        dto.setProducts(productSummaries);

        return dto;
    }

    public List<MonthlyStatementDTO> getMonthlyStatements(Long stationId, Integer page, Integer size) {
        Station station = stationMapper.selectById(stationId);
        if (station == null) {
            throw new BusinessException(ResultCode.STATION_NOT_FOUND);
        }

        YearMonth current = YearMonth.now();
        List<MonthlyStatementDTO> statements = new ArrayList<>();

        int months = page != null && size != null ? size : 6;
        for (int i = 0; i < months; i++) {
            YearMonth ym = current.minusMonths(i);
            MonthlyStatementDTO dto = getMonthlyStatement(stationId, ym.format(DateTimeFormatter.ofPattern("yyyy-MM")));
            statements.add(dto);
        }

        return statements;
    }

    public MonthlyStatementDTO getCurrentMonthStatement(Long stationId) {
        return getMonthlyStatement(stationId, null);
    }

    public boolean confirmMonthlyStatement(Long stationId, String statementId) {
        return true;
    }

    public boolean disputeMonthlyStatement(Long stationId, String statementId, String reason) {
        return true;
    }
}
