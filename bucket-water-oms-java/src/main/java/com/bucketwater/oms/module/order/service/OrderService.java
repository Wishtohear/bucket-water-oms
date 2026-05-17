package com.bucketwater.oms.module.order.service;

import com.bucketwater.oms.common.exception.BusinessException;
import com.bucketwater.oms.common.response.ResultCode;
import com.bucketwater.oms.module.bucket.entity.BucketTransaction;
import com.bucketwater.oms.module.bucket.mapper.BucketTransactionMapper;
import com.bucketwater.oms.module.driver.entity.Driver;
import com.bucketwater.oms.module.driver.mapper.DriverMapper;
import com.bucketwater.oms.module.notification.service.NotificationService;
import com.bucketwater.oms.module.notification.service.OrderPushService;
import com.bucketwater.oms.module.order.dto.*;
import com.bucketwater.oms.module.order.entity.Order;
import com.bucketwater.oms.module.order.entity.OrderItem;
import com.bucketwater.oms.module.order.mapper.OrderItemMapper;
import com.bucketwater.oms.module.order.mapper.OrderMapper;
import com.bucketwater.oms.module.product.entity.Product;
import com.bucketwater.oms.module.product.mapper.ProductMapper;
import com.bucketwater.oms.module.product.service.ProductService;
import com.bucketwater.oms.module.station.entity.Station;
import com.bucketwater.oms.module.station.entity.StationAccount;
import com.bucketwater.oms.module.station.mapper.StationAccountMapper;
import com.bucketwater.oms.module.station.mapper.StationMapper;
import com.bucketwater.oms.module.user.entity.User;
import com.bucketwater.oms.module.user.mapper.UserMapper;
import com.bucketwater.oms.module.warehouse.entity.Warehouse;
import com.bucketwater.oms.module.warehouse.mapper.WarehouseMapper;
import lombok.Data;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Slf4j
@Service
public class OrderService {

    @Autowired
    private WarehouseMapper warehouseMapper;

    @Autowired
    private DriverMapper driverMapper;

    @Autowired
    private OrderMapper orderMapper;

    @Autowired
    private OrderItemMapper orderItemMapper;

    @Autowired
    private StationAccountMapper stationAccountMapper;

    @Autowired
    private BucketTransactionMapper bucketTransactionMapper;

    @Autowired
    private ProductService productService;

    @Autowired
    private ProductMapper productMapper;

    @Autowired
    private NotificationService notificationService;

    @Autowired(required = false)
    private OrderPushService orderPushService;

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private StationMapper stationMapper;

    @Transactional
    public OrderVO createOrder(Long stationId, CreateOrderRequest request) {
        log.info("========== [DEBUG] createOrder 开始 ==========");
        log.info("[DEBUG] stationId={}, request={}", stationId, request);

        StationAccount account = stationAccountMapper.selectOne(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<StationAccount>()
                .eq(StationAccount::getStationId, stationId)
        );

        if (account == null) {
            throw new BusinessException(ResultCode.STATION_NOT_FOUND);
        }

        if (account.checkOwedThresholdExceeded()) {
            throw new BusinessException(ResultCode.BUCKET_OWED_THRESHOLD, "欠桶数量已达到阈值，请先补缴押金");
        }

        Long warehouseId = request.getWarehouseId();

        BigDecimal totalAmount = BigDecimal.ZERO;
        int totalBuckets = 0;
        List<OrderItem> items = new ArrayList<>();
        List<CreateOrderRequest.OrderItemDTO> itemDTOs = request.getItems();

        for (CreateOrderRequest.OrderItemDTO itemDTO : itemDTOs) {
            Long productId = itemDTO.getProductId();
            Integer quantity = itemDTO.getQuantity();

            log.info("[DEBUG] 处理商品: productId={}, quantity={}", productId, quantity);

            Integer minOrderQuantity = productService.getMinOrderQuantity(stationId, productId);
            log.info("[DEBUG] 获取最低起订量: productId={}, minOrderQuantity={}", productId, minOrderQuantity);
            if (minOrderQuantity != null && quantity < minOrderQuantity) {
                Product product = productMapper.selectById(productId);
                String productName = product != null ? product.getName() : "该商品";
                throw new BusinessException(ResultCode.PARAM_ERROR,
                    String.format("%s的最低起订量为%d桶，您当前下单数量为%d桶，请增加数量后重试", productName, minOrderQuantity, quantity));
            }

            if (!productService.checkWarehouseStock(warehouseId, productId, quantity)) {
                log.warn("[DEBUG] 库存不足: productId={}, warehouseId={}, quantity={}", productId, warehouseId, quantity);
                throw new BusinessException(ResultCode.INSUFFICIENT_STOCK, "商品库存不足，无法下单");
            }

            BigDecimal unitPrice = productService.getProductPriceForStation(stationId, productId, quantity);
            log.info("[DEBUG] 获取价格: productId={}, unitPrice={}", productId, unitPrice);

            BigDecimal subtotal = unitPrice.multiply(new BigDecimal(quantity));
            log.info("[DEBUG] 计算小计: unitPrice={}, quantity={}, subtotal={}", unitPrice, quantity, subtotal);

            totalAmount = totalAmount.add(subtotal);
            totalBuckets += quantity;
            log.info("[DEBUG] 累计金额: totalAmount={}, 累计桶数: totalBuckets={}", totalAmount, totalBuckets);
        }

        BigDecimal depositBalance = account.getDepositBalance() != null ? account.getDepositBalance() : BigDecimal.ZERO;
        BigDecimal creditLimit = account.getCreditLimit() != null ? account.getCreditLimit() : BigDecimal.ZERO;
        BigDecimal creditUsed = account.getCreditUsed() != null ? account.getCreditUsed() : BigDecimal.ZERO;
        BigDecimal availableCredit = creditLimit.subtract(creditUsed);

        BigDecimal totalAvailable = depositBalance.add(availableCredit);
        if (totalAvailable.compareTo(totalAmount) < 0) {
            throw new BusinessException(ResultCode.BALANCE_INSUFFICIENT,
                String.format("预存金%.2f元 + 信用额度%.2f元 = %.2f元，不足以支付订单金额%.2f元",
                    depositBalance, availableCredit, totalAvailable, totalAmount));
        }

        Order order = new Order();
        order.setOrderNo(generateOrderNo());
        order.setStationId(stationId);
        order.setWarehouseId(warehouseId);
        order.setStatus("pending_review");
        order.setDeliveryAddress(request.getDeliveryAddress());
        order.setContactName(request.getContactName());
        order.setContactPhone(request.getContactPhone());
        order.setRemark(request.getRemark());
        order.setPaymentType(request.getPaymentType() != null ? request.getPaymentType() : "prepaid");
        order.setTotalAmount(totalAmount);
        order.setOrderBuckets(totalBuckets);
        order.setCreateTime(LocalDateTime.now());
        order.setUpdateTime(LocalDateTime.now());

        for (CreateOrderRequest.OrderItemDTO itemDTO : itemDTOs) {
            Long productId = itemDTO.getProductId();
            BigDecimal unitPrice = productService.getProductPriceForStation(stationId, productId, itemDTO.getQuantity());
            BigDecimal subtotal = unitPrice.multiply(new BigDecimal(itemDTO.getQuantity()));

            OrderItem item = new OrderItem();
            item.setOrderId(order.getId());
            item.setProductId(productId);
            item.setQuantity(itemDTO.getQuantity());
            item.setActualQty(0);
            item.setUnitPrice(unitPrice);
            item.setSubtotal(subtotal);
            items.add(item);
        }

        order.setItems(items);

        log.info("[DEBUG] 准备插入订单: orderNo={}, totalAmount={}, items.size={}",
            order.getOrderNo(), totalAmount, items.size());

        orderMapper.insert(order);

        log.info("[DEBUG] 订单已插入: orderId={}, orderNo={}", order.getId(), order.getOrderNo());

        for (OrderItem item : items) {
            item.setOrderId(order.getId());
            log.info("[DEBUG] 准备插入订单明细: orderId={}, productId={}, quantity={}, unitPrice={}, subtotal={}",
                item.getOrderId(), item.getProductId(), item.getQuantity(), item.getUnitPrice(), item.getSubtotal());
            orderItemMapper.insert(item);
        }

        log.info("[DEBUG] 所有订单明细已插入，共 {} 条", items.size());
        log.info("========== [DEBUG] createOrder 结束 ==========");

        var warehouse = warehouseMapper.selectById(warehouseId);
        String warehouseName = warehouse != null && warehouse.getName() != null ? warehouse.getName() : "仓库";
        notificationService.sendOrderCreatedNotification(stationId, order.getOrderNo(), warehouseName);

        var warehouseUsers = userMapper.selectList(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<User>()
                .eq(User::getWarehouseId, warehouseId)
        );
        for (User warehouseUser : warehouseUsers) {
            notificationService.sendWarehouseNewOrderNotification(
                warehouseUser.getId(),
                order.getOrderNo(),
                ""
            );
        }

        if (orderPushService != null) {
            orderPushService.pushOrderCreated(order.getId());
        }

        deductBalanceAndCredit(account, totalAmount, order.getPaymentType());

        return convertToVO(order);
    }

    private void deductBalanceAndCredit(StationAccount account, BigDecimal amount, String paymentType) {
        log.info("[DEBUG] 开始扣减余额和信用额度: amount={}, paymentType={}", amount, paymentType);

        String effectivePaymentType = (paymentType != null && !paymentType.isEmpty()) ? paymentType : "prepaid";

        if ("credit".equals(effectivePaymentType) || "monthly".equals(effectivePaymentType)) {
            BigDecimal creditLimit = account.getCreditLimit() != null ? account.getCreditLimit() : BigDecimal.ZERO;
            BigDecimal creditUsed = account.getCreditUsed() != null ? account.getCreditUsed() : BigDecimal.ZERO;
            BigDecimal availableCredit = creditLimit.subtract(creditUsed);

            account.setCreditUsed(creditUsed.add(amount));
            log.info("[DEBUG] 扣减信用额度: {}元, 信用额度: {}/{}, 已用信用: {}元",
                amount, creditLimit, availableCredit, account.getCreditUsed());
        } else {
            BigDecimal depositBalance = account.getDepositBalance() != null ? account.getDepositBalance() : BigDecimal.ZERO;
            BigDecimal creditLimit = account.getCreditLimit() != null ? account.getCreditLimit() : BigDecimal.ZERO;
            BigDecimal creditUsed = account.getCreditUsed() != null ? account.getCreditUsed() : BigDecimal.ZERO;
            BigDecimal availableCredit = creditLimit.subtract(creditUsed);

            BigDecimal remainingAmount = amount;

            if (depositBalance.compareTo(BigDecimal.ZERO) > 0 && remainingAmount.compareTo(BigDecimal.ZERO) > 0) {
                if (depositBalance.compareTo(remainingAmount) >= 0) {
                    account.setDepositBalance(depositBalance.subtract(remainingAmount));
                    log.info("[DEBUG] 扣减预存金: {}元, 剩余预存金: {}元", remainingAmount, account.getDepositBalance());
                    remainingAmount = BigDecimal.ZERO;
                } else {
                    remainingAmount = remainingAmount.subtract(depositBalance);
                    account.setDepositBalance(BigDecimal.ZERO);
                    log.info("[DEBUG] 预存金全部扣减: {}元, 剩余需扣减: {}元", depositBalance, remainingAmount);
                }
            }

            if (availableCredit.compareTo(BigDecimal.ZERO) > 0 && remainingAmount.compareTo(BigDecimal.ZERO) > 0) {
                if (availableCredit.compareTo(remainingAmount) >= 0) {
                    account.setCreditUsed(creditUsed.add(remainingAmount));
                    log.info("[DEBUG] 扣减信用额度: {}元, 已用信用: {}元", remainingAmount, account.getCreditUsed());
                    remainingAmount = BigDecimal.ZERO;
                } else {
                    account.setCreditUsed(creditUsed.add(availableCredit));
                    log.info("[DEBUG] 信用额度全部扣减: {}元, 已用信用: {}元", availableCredit, account.getCreditUsed());
                    remainingAmount = remainingAmount.subtract(availableCredit);
                }
            }
        }

        account.setUpdatedAt(java.time.LocalDateTime.now());
        stationAccountMapper.updateById(account);
        log.info("[DEBUG] 余额和信用额度扣减完成");
    }

    public OrderVO getOrderDetail(Long orderId) {
        Order order = orderMapper.selectById(orderId);
        if (order == null) {
            throw new BusinessException(ResultCode.ORDER_NOT_FOUND);
        }

        List<OrderItem> items = orderItemMapper.selectList(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<OrderItem>()
                .eq(OrderItem::getOrderId, orderId)
        );
        order.setItems(items);

        return convertToVO(order);
    }

    public List<OrderVO> getOrders(Long stationId, String status, Integer page, Integer size) {
        com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Order> wrapper =
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Order>();

        if (stationId != null) {
            wrapper.eq(Order::getStationId, stationId);
        }
        if (status != null && !status.isEmpty()) {
            wrapper.eq(Order::getStatus, status);
        }

        wrapper.orderByDesc(Order::getCreateTime);
        wrapper.last("LIMIT " + size + " OFFSET " + (page - 1) * size);

        List<Order> orders = orderMapper.selectList(wrapper);
        List<OrderVO> result = new ArrayList<>();

        for (Order order : orders) {
            List<OrderItem> items = orderItemMapper.selectList(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<OrderItem>()
                    .eq(OrderItem::getOrderId, order.getId())
            );
            order.setItems(items);
            result.add(convertToVO(order));
        }

        return result;
    }

    /**
     * 修改订单（支持可选字段）
     * 只修改传入的字段，未传入的字段保持不变
     */
    @Transactional
    public OrderVO updateOrder(Long orderId, Long stationId, CreateOrderRequest request) {
        Order order = orderMapper.selectById(orderId);
        if (order == null) {
            throw new BusinessException(ResultCode.ORDER_NOT_FOUND);
        }

        if (!"pending_review".equals(order.getStatus())) {
            throw new BusinessException(ResultCode.ORDER_STATUS_NOT_ALLOWED, "只有待审查的订单才能修改");
        }

        // 验证水站权限
        if (!stationId.equals(order.getStationId())) {
            throw new BusinessException(ResultCode.FORBIDDEN, "无权修改此订单");
        }

        // 删除旧的订单商品
        List<OrderItem> oldItems = orderItemMapper.selectList(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<OrderItem>()
                .eq(OrderItem::getOrderId, orderId)
        );
        for (OrderItem item : oldItems) {
            orderItemMapper.deleteById(item.getId());
        }

        // 计算新订单金额并验证库存
        BigDecimal totalAmount = BigDecimal.ZERO;
        List<OrderItem> newItems = new ArrayList<>();

        // 使用请求中的仓库ID或订单原有的仓库ID
        Long warehouseId = request.getWarehouseId() != null ? request.getWarehouseId() : order.getWarehouseId();

        for (CreateOrderRequest.OrderItemDTO itemDTO : request.getItems()) {
            Long productId = itemDTO.getProductId();

            // 验证仓库库存
            if (!productService.checkWarehouseStock(warehouseId, productId, itemDTO.getQuantity())) {
                throw new BusinessException(ResultCode.INSUFFICIENT_STOCK, "商品库存不足，无法下单");
            }

            BigDecimal unitPrice = productService.getProductPriceForStation(stationId, productId, itemDTO.getQuantity());
            BigDecimal subtotal = unitPrice.multiply(new BigDecimal(itemDTO.getQuantity()));

            OrderItem item = new OrderItem();
            item.setOrderId(order.getId());
            item.setProductId(productId);
            item.setQuantity(itemDTO.getQuantity());
            item.setActualQty(0);
            item.setUnitPrice(unitPrice);
            item.setSubtotal(subtotal);
            totalAmount = totalAmount.add(subtotal);
            newItems.add(item);
        }

        // 更新订单
        order.setTotalAmount(totalAmount);
        order.setDeliveryAddress(request.getDeliveryAddress());
        order.setContactName(request.getContactName());
        order.setContactPhone(request.getContactPhone());
        order.setRemark(request.getRemark());
        order.setWarehouseId(warehouseId);
        order.setUpdateTime(LocalDateTime.now());

        orderMapper.updateById(order);
        for (OrderItem item : newItems) {
            orderItemMapper.insert(item);
        }

        order.setItems(newItems);
        return convertToVO(order);
    }

    /**
     * 修改订单（支持可选字段增强版）
     * 只更新传入的字段
     */
    @Transactional
    public OrderVO updateOrderOptional(Long orderId, Long stationId, UpdateOrderRequest request) {
        Order order = orderMapper.selectById(orderId);
        if (order == null) {
            throw new BusinessException(ResultCode.ORDER_NOT_FOUND);
        }

        if (!"pending_review".equals(order.getStatus())) {
            throw new BusinessException(ResultCode.ORDER_STATUS_NOT_ALLOWED, "只有待审查的订单才能修改");
        }

        // 验证水站权限
        if (!stationId.equals(order.getStationId())) {
            throw new BusinessException(ResultCode.FORBIDDEN, "无权修改此订单");
        }

        // 更新仓库ID（如果传入）
        if (request.getWarehouseId() != null) {
            order.setWarehouseId(request.getWarehouseId());
        }

        // 更新配送信息（如果传入）
        if (request.getDeliveryAddress() != null) {
            order.setDeliveryAddress(request.getDeliveryAddress());
        }
        if (request.getContactName() != null) {
            order.setContactName(request.getContactName());
        }
        if (request.getContactPhone() != null) {
            order.setContactPhone(request.getContactPhone());
        }
        if (request.getRemark() != null) {
            order.setRemark(request.getRemark());
        }
        if (request.getPaymentType() != null) {
            order.setPaymentType(request.getPaymentType());
        }

        // 更新商品列表（如果传入）
        List<OrderItem> newItems = null;
        if (request.getItems() != null && !request.getItems().isEmpty()) {
            // 删除旧的订单商品
            List<OrderItem> oldItems = orderItemMapper.selectList(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<OrderItem>()
                    .eq(OrderItem::getOrderId, orderId)
            );
            for (OrderItem item : oldItems) {
                orderItemMapper.deleteById(item.getId());
            }

            // 计算新订单金额并验证库存
            BigDecimal totalAmount = BigDecimal.ZERO;
            newItems = new ArrayList<>();

            for (UpdateOrderRequest.OrderItemDTO itemDTO : request.getItems()) {
                Long productId = itemDTO.getProductId();
                Integer quantity = itemDTO.getQuantity();

                // 验证仓库库存
                if (!productService.checkWarehouseStock(order.getWarehouseId(), productId, quantity)) {
                    throw new BusinessException(ResultCode.INSUFFICIENT_STOCK, "商品库存不足，无法下单");
                }

                BigDecimal unitPrice = productService.getProductPriceForStation(stationId, productId, quantity);
                BigDecimal subtotal = unitPrice.multiply(new BigDecimal(quantity));

                OrderItem item = new OrderItem();
                item.setOrderId(order.getId());
                item.setProductId(productId);
                item.setQuantity(quantity);
                item.setActualQty(0);
                item.setUnitPrice(unitPrice);
                item.setSubtotal(subtotal);
                totalAmount = totalAmount.add(subtotal);
                newItems.add(item);
            }

            order.setTotalAmount(totalAmount);
        }

        order.setUpdateTime(LocalDateTime.now());
        orderMapper.updateById(order);

        // 插入新的订单商品
        if (newItems != null) {
            for (OrderItem item : newItems) {
                orderItemMapper.insert(item);
            }
            order.setItems(newItems);
        }

        // 重新加载订单商品
        if (newItems == null) {
            List<OrderItem> items = orderItemMapper.selectList(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<OrderItem>()
                    .eq(OrderItem::getOrderId, orderId)
            );
            order.setItems(items);
        }

        return convertToVO(order);
    }

    @Transactional
    public void cancelOrder(Long orderId, String reason) {
        Order order = orderMapper.selectById(orderId);
        if (order == null) {
            throw new BusinessException(ResultCode.ORDER_NOT_FOUND);
        }

        if (!"pending_review".equals(order.getStatus())) {
            throw new BusinessException(ResultCode.ORDER_STATUS_NOT_ALLOWED);
        }

        order.setStatus("cancelled");
        order.setRejectReason(reason);
        order.setUpdateTime(LocalDateTime.now());
        orderMapper.updateById(order);

        notificationService.sendOrderCancelledNotification(order.getStationId(), order.getOrderNo(), reason);

        if (orderPushService != null) {
            orderPushService.pushOrderCancelled(order.getId(), reason);
        }
    }

    @Transactional
    public OrderVO reviewOrder(Long orderId, Long warehouseId, ReviewOrderRequest request) {
        Order order = orderMapper.selectById(orderId);
        if (order == null) {
            throw new BusinessException(ResultCode.ORDER_NOT_FOUND);
        }

        // 检查订单状态
        if (!"pending_review".equals(order.getStatus())) {
            throw new BusinessException(ResultCode.ORDER_STATUS_NOT_ALLOWED, "只有待审查的订单才能操作");
        }

        // 检查仓库权限：订单未指定仓库（warehouseId为null）时，任何仓库都可以接单（先到先得）
        // 订单已指定仓库时，只有所属仓库才能操作
        if (order.getWarehouseId() != null && !warehouseId.equals(order.getWarehouseId())) {
            throw new BusinessException(ResultCode.PARAM_ERROR, "无权操作此订单，该订单已被其他仓库接单");
        }

        if ("accept".equals(request.getAction())) {
            // 库存检查
            List<OrderItem> items = orderItemMapper.selectList(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<OrderItem>()
                    .eq(OrderItem::getOrderId, orderId)
            );

            for (OrderItem item : items) {
                if (!productService.checkWarehouseStock(warehouseId, item.getProductId(), item.getQuantity())) {
                    throw new BusinessException(ResultCode.INSUFFICIENT_STOCK, "商品库存不足，无法接单");
                }
            }

            // 设置仓库ID（如果订单之前未指定仓库）
            order.setWarehouseId(warehouseId);
            order.setStatus("reviewed");
            order.setReviewedAt(LocalDateTime.now());
            notificationService.sendOrderReviewedNotification(order.getStationId(), order.getOrderNo(), true, null);
        } else if ("reject".equals(request.getAction())) {
            order.setStatus("rejected");
            order.setRejectReason(request.getReason());
            notificationService.sendOrderReviewedNotification(order.getStationId(), order.getOrderNo(), false, request.getReason());
        } else {
            throw new BusinessException(ResultCode.PARAM_INVALID);
        }

        order.setUpdateTime(LocalDateTime.now());
        orderMapper.updateById(order);

        if (orderPushService != null) {
            boolean accepted = "accept".equals(request.getAction());
            orderPushService.pushOrderReviewed(order.getId(), accepted);
        }

        return convertToVO(order);
    }

    @Transactional
    public DispatchOrderResponse dispatchOrder(Long orderId, Long warehouseId, DispatchOrderRequest request) {
        Order order = orderMapper.selectById(orderId);
        if (order == null) {
            throw new BusinessException(ResultCode.ORDER_NOT_FOUND);
        }

        if (!warehouseId.equals(order.getWarehouseId())) {
            throw new BusinessException(ResultCode.PARAM_ERROR, "无权操作此订单，该订单不属于当前仓库");
        }

        if (!"reviewed".equals(order.getStatus())) {
            throw new BusinessException(ResultCode.ORDER_STATUS_NOT_ALLOWED);
        }

        // 检查司机是否绑定当前仓库
        Driver driver = driverMapper.selectById(request.getDriverId());
        boolean isCrossWarehouse = driver != null && driver.getWarehouseId() != null
            && !driver.getWarehouseId().equals(warehouseId);

        // 记录派单前的司机仓库信息（用于后续逻辑）
        Long driverOriginalWarehouseId = driver != null ? driver.getWarehouseId() : null;

        order.setDriverId(request.getDriverId());
        order.setStatus("dispatched");
        order.setDispatchedAt(LocalDateTime.now());
        order.setUpdateTime(LocalDateTime.now());
        orderMapper.updateById(order);

        String driverName = driver != null ? driver.getName() : "司机";
        String driverPhone = driver != null && driver.getPhone() != null ? driver.getPhone() : "";

        // 发送通知给水站
        notificationService.sendOrderDispatchedNotification(
            order.getStationId(),
            order.getOrderNo(),
            driverName,
            driverPhone
        );

        // 发送通知给司机
        if (driver != null) {
            notificationService.sendDriverNewTaskNotification(
                driver.getId(),
                order.getOrderNo(),
                "",
                order.getDeliveryAddress()
            );
        }

        // 构建响应
        DispatchOrderResponse response = new DispatchOrderResponse(convertToVO(order));

        // 如果是跨仓库派单，添加警告信息
        if (isCrossWarehouse && driverOriginalWarehouseId != null) {
            // 获取司机原来的仓库名称
            Warehouse driverWarehouse = warehouseMapper.selectById(driverOriginalWarehouseId);
            String warehouseName = driverWarehouse != null ? driverWarehouse.getName() : "其他仓库";

            response.addWarning("该司机原本绑定在仓库【" + warehouseName + "】，跨仓库派单可能导致配送效率降低");
            response.addWarning("建议：优先选择绑定当前仓库的司机进行派单");
        }

        if (orderPushService != null) {
            orderPushService.pushOrderDispatched(order.getId());
            if (driver != null) {
                orderPushService.pushNewDeliveryTask(driver.getId(), order.getId());
            }
        }

        return response;
    }

    @Transactional
    public OrderVO deliverOrder(Long orderId, DeliveryRequest request) {
        Order order = orderMapper.selectById(orderId);
        if (order == null) {
            throw new BusinessException(ResultCode.ORDER_NOT_FOUND);
        }

        if (!"dispatched".equals(order.getStatus()) && !"delivering".equals(order.getStatus())) {
            throw new BusinessException(ResultCode.ORDER_STATUS_NOT_ALLOWED);
        }

        List<OrderItem> items = orderItemMapper.selectList(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<OrderItem>()
                .eq(OrderItem::getOrderId, orderId)
        );

        for (DeliveryRequest.DeliveryItemDTO deliveryItem : request.getItems()) {
            Long productId = deliveryItem.getProductId();
            for (OrderItem item : items) {
                if (item.getProductId().equals(productId)) {
                    item.setActualQty(deliveryItem.getActualQty());
                    orderItemMapper.updateById(item);

                    productService.deductStock(order.getWarehouseId(), productId, deliveryItem.getActualQty());
                    break;
                }
            }
        }

        order.setStatus("completed");
        order.setDeliveredAt(LocalDateTime.now());
        order.setUpdateTime(LocalDateTime.now());

        if (request.getPhotos() != null && !request.getPhotos().isEmpty()) {
            order.setSignPhotos(String.join(",", request.getPhotos()));
        }

        orderMapper.updateById(order);

        if (request.getBucketReturned() != null && request.getBucketReturned() > 0) {
            createBucketReturnTransaction(order, request.getBucketReturned());
        }

        if (request.getBucketOwed() != null && request.getBucketOwed() > 0) {
            createBucketOwedTransaction(order, request.getBucketOwed());
        }

        order.setItems(items);

        int totalActualQty = items.stream().mapToInt(OrderItem::getActualQty).sum();
        order.setDeliveredQty(totalActualQty);
        int bucketReturned = request.getBucketReturned() != null ? request.getBucketReturned() : 0;
        notificationService.sendOrderCompletedNotification(
            order.getStationId(),
            order.getOrderNo(),
            totalActualQty,
            bucketReturned
        );

        StationAccount account = stationAccountMapper.selectOne(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<StationAccount>()
                .eq(StationAccount::getStationId, order.getStationId())
        );
        if (account != null && account.getOwedBucketNum() >= account.getOwedThreshold()) {
            notificationService.sendBucketWarningNotification(
                order.getStationId(),
                account.getOwedBucketNum(),
                account.getOwedThreshold()
            );
        }

        if (orderPushService != null) {
            orderPushService.pushOrderCompleted(order.getId(), totalActualQty, bucketReturned);
        }

        return convertToVO(order);
    }

    private void createBucketReturnTransaction(Order order, int bucketReturned) {
        StationAccount account = stationAccountMapper.selectOne(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<StationAccount>()
                .eq(StationAccount::getStationId, order.getStationId())
        );

        BucketTransaction transaction = new BucketTransaction();
        transaction.setStationId(order.getStationId());
        transaction.setOrderId(order.getId());
        transaction.setDriverId(order.getDriverId());
        transaction.setType("return");
        transaction.setQuantity(-bucketReturned);
        transaction.setBalance(account.getOwedBucketNum());
        transaction.setCreatedAt(LocalDateTime.now());
        bucketTransactionMapper.insert(transaction);

        account.setOwedBucketNum(account.getOwedBucketNum() - bucketReturned);
        stationAccountMapper.updateById(account);
    }

    private void createBucketOwedTransaction(Order order, int bucketOwed) {
        StationAccount account = stationAccountMapper.selectOne(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<StationAccount>()
                .eq(StationAccount::getStationId, order.getStationId())
        );

        BucketTransaction transaction = new BucketTransaction();
        transaction.setStationId(order.getStationId());
        transaction.setOrderId(order.getId());
        transaction.setDriverId(order.getDriverId());
        transaction.setType("owed");
        transaction.setQuantity(bucketOwed);
        transaction.setBalance(account.getOwedBucketNum() + bucketOwed);
        transaction.setCreatedAt(LocalDateTime.now());
        bucketTransactionMapper.insert(transaction);

        account.setOwedBucketNum(account.getOwedBucketNum() + bucketOwed);
        stationAccountMapper.updateById(account);
    }

    private void deductAccountBalance(Order order) {
        StationAccount account = stationAccountMapper.selectOne(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<StationAccount>()
                .eq(StationAccount::getStationId, order.getStationId())
        );

        if ("prepaid".equals(order.getPaymentType())) {
            account.setDepositBalance(account.getDepositBalance().subtract(order.getTotalAmount()));
        } else if ("credit".equals(order.getPaymentType()) || "monthly".equals(order.getPaymentType())) {
            account.setCreditUsed(account.getCreditUsed().add(order.getTotalAmount()));
        }
        account.setUpdatedAt(LocalDateTime.now());
        stationAccountMapper.updateById(account);
    }

    private String generateOrderNo() {
        return "ORD" + java.time.LocalDateTime.now().format(java.time.format.DateTimeFormatter.ofPattern("yyyyMMddHHmmss"))
            + String.format("%04d", (int) (Math.random() * 10000));
    }

    private OrderVO convertToVO(Order order) {
        List<OrderVO.OrderItemVO> itemVOs = new ArrayList<>();
        int totalBuckets = 0;
        if (order.getItems() != null) {
            for (OrderItem item : order.getItems()) {
                String productName = getProductName(item.getProductId());
                itemVOs.add(new OrderVO.OrderItemVO(
                    item.getProductId().toString(),
                    productName,
                    item.getQuantity(),
                    item.getActualQty(),
                    item.getUnitPrice(),
                    item.getSubtotal()
                ));
                totalBuckets += item.getQuantity() != null ? item.getQuantity() : 0;
            }
        }

        List<OrderVO.ProgressItem> progress = buildProgress(order);

        String stationName = null;
        BigDecimal stationLat = null;
        BigDecimal stationLng = null;
        if (order.getStationId() != null) {
            Station station = stationMapper.selectById(order.getStationId());
            if (station != null) {
                stationName = station.getName();
                stationLat = station.getLat();
                stationLng = station.getLng();
            }
        }

        String warehouseName = null;
        if (order.getWarehouseId() != null) {
            var warehouse = warehouseMapper.selectById(order.getWarehouseId());
            if (warehouse != null) {
                warehouseName = warehouse.getName();
            }
        }

        String driverName = null;
        if (order.getDriverId() != null) {
            var driver = driverMapper.selectById(order.getDriverId());
            if (driver != null) {
                driverName = driver.getName();
            }
        }

        List<String> signPhotos = null;
        if (order.getSignPhotos() != null && !order.getSignPhotos().isEmpty()) {
            signPhotos = List.of(order.getSignPhotos().split(","));
        }

        String paymentTypeText = getPaymentTypeText(order.getPaymentType());

        return new OrderVO(
            order.getId().toString(),
            order.getOrderNo(),
            order.getStationId() != null ? order.getStationId().toString() : null,
            stationName,
            order.getWarehouseId() != null ? order.getWarehouseId().toString() : null,
            warehouseName,
            order.getDriverId() != null ? order.getDriverId().toString() : null,
            driverName,
            order.getStatus(),
            getStatusText(order.getStatus()),
            progress,
            order.getTotalAmount(),
            totalBuckets,
            order.getDeliveredQty(),
            order.getPaymentType(),
            paymentTypeText,
            order.getCreateTime(),
            itemVOs,
            order.getDeliveryAddress(),
            order.getContactName(),
            order.getContactPhone(),
            stationLat,
            stationLng,
            order.getRejectReason(),
            signPhotos,
            "pending_review".equals(order.getStatus()),
            "pending_review".equals(order.getStatus())
        );
    }

    private String getPaymentTypeText(String paymentType) {
        if (paymentType == null) return "未知";
        switch (paymentType) {
            case "prepaid": return "预存金";
            case "credit": return "信用额度";
            case "monthly": return "月结";
            default: return paymentType;
        }
    }

    private List<OrderVO.ProgressItem> buildProgress(Order order) {
        List<OrderVO.ProgressItem> progress = new ArrayList<>();

        progress.add(new OrderVO.ProgressItem("created", "订单创建", order.getCreateTime()));

        if (order.getReviewedAt() != null) {
            progress.add(new OrderVO.ProgressItem("reviewed", "仓库已接单", order.getReviewedAt()));
        }

        if (order.getDispatchedAt() != null) {
            progress.add(new OrderVO.ProgressItem("dispatched", "已派单", order.getDispatchedAt()));
        }

        if (order.getDeliveredAt() != null) {
            progress.add(new OrderVO.ProgressItem("completed", "已完成配送", order.getDeliveredAt()));
        }

        return progress;
    }

    private OrderVO.WarehouseInfo getWarehouseInfo(Long warehouseId) {
        var warehouse = warehouseMapper.selectById(warehouseId);
        if (warehouse != null) {
            return new OrderVO.WarehouseInfo(warehouse.getId().toString(), warehouse.getName());
        }
        return null;
    }

    private OrderVO.DriverInfo getDriverInfo(Long driverId) {
        var driver = driverMapper.selectById(driverId);
        if (driver != null) {
            return new OrderVO.DriverInfo(driver.getId().toString(), driver.getName(), driver.getPhone());
        }
        return null;
    }

    private OrderVO.BucketReturn buildBucketReturn(Order order) {
        var account = stationAccountMapper.selectOne(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<StationAccount>()
                .eq(StationAccount::getStationId, order.getStationId())
        );

        int totalOwed = account != null ? account.getOwedBucketNum() : 0;

        var transactions = bucketTransactionMapper.selectList(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<BucketTransaction>()
                .eq(BucketTransaction::getOrderId, order.getId())
                .orderByDesc(BucketTransaction::getCreatedAt)
        );

        int returnedQty = 0;
        int owedQty = 0;

        for (var trans : transactions) {
            if ("return".equals(trans.getType())) {
                returnedQty = Math.abs(trans.getQuantity());
            } else if ("owed".equals(trans.getType())) {
                owedQty = trans.getQuantity();
            }
        }

        return new OrderVO.BucketReturn(returnedQty, owedQty, totalOwed);
    }

    private String getProductName(Long productId) {
        if (productId == null) return "未知商品";
        Product product = productMapper.selectById(productId);
        return product != null ? product.getName() : "未知商品";
    }

    private String getStatusText(String status) {
        return switch (status) {
            case "pending_review" -> "待审查";
            case "reviewed" -> "已接单";
            case "dispatched" -> "已派单";
            case "delivering" -> "配送中";
            case "completed" -> "已完成";
            case "cancelled" -> "已取消";
            case "rejected" -> "已拒单";
            default -> status;
        };
    }

    /**
     * 仓库拒单（增强版）
     * 记录拒单原因和库存不足明细
     */
    @Transactional
    public OrderVO rejectOrder(Long orderId, Long warehouseId, RejectOrderRequest request) {
        Order order = orderMapper.selectById(orderId);
        if (order == null) {
            throw new BusinessException(ResultCode.ORDER_NOT_FOUND);
        }

        if (!warehouseId.equals(order.getWarehouseId())) {
            throw new BusinessException(ResultCode.PARAM_ERROR, "无权操作此订单，该订单不属于当前仓库");
        }

        if (!"pending_review".equals(order.getStatus()) && !"reviewed".equals(order.getStatus())) {
            throw new BusinessException(ResultCode.ORDER_STATUS_NOT_ALLOWED, "当前状态不允许拒单");
        }

        order.setStatus("rejected");
        order.setRejectReason(request.getReason());
        order.setUpdateTime(LocalDateTime.now());

        // 如果有库存不足明细，记录到订单中
        if (request.getStockDetails() != null && !request.getStockDetails().isEmpty()) {
            try {
                com.fasterxml.jackson.databind.ObjectMapper objectMapper = new com.fasterxml.jackson.databind.ObjectMapper();
                order.setStockDetails(objectMapper.writeValueAsString(request.getStockDetails()));
            } catch (Exception e) {
                // 忽略序列化错误
            }
        }

        orderMapper.updateById(order);

        // 发送拒单通知给水站
        notificationService.sendOrderReviewedNotification(
            order.getStationId(),
            order.getOrderNo(),
            false,
            request.getReason()
        );

        return convertToVO(order);
    }

    /**
     * 获取备货订单列表（增强版）
     * 返回订单详情、库存检查结果和操作权限
     */
    public List<OrderVO> getPreparingOrders(Long warehouseId, String status, Integer page, Integer size) {
        com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Order> queryWrapper =
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Order>()
                .eq(Order::getWarehouseId, warehouseId)
                .orderByAsc(Order::getCreateTime);

        // 根据状态筛选
        if (status != null && !status.isEmpty()) {
            if ("preparing".equals(status)) {
                // 备货中：已接单但未派单
                queryWrapper.eq(Order::getStatus, "reviewed");
            } else if ("prepared".equals(status)) {
                // 已备货：已接单且有库存
                queryWrapper.eq(Order::getStatus, "reviewed");
            } else if ("dispatched".equals(status)) {
                queryWrapper.eq(Order::getStatus, "dispatched");
            } else {
                queryWrapper.eq(Order::getStatus, status);
            }
        } else {
            // 默认显示已接单和已派单的订单
            queryWrapper.in(Order::getStatus, "reviewed", "dispatched");
        }

        queryWrapper.last("LIMIT " + size + " OFFSET " + ((page - 1) * size));

        List<Order> orders = orderMapper.selectList(queryWrapper);
        List<OrderVO> result = new ArrayList<>();

        for (Order order : orders) {
            List<OrderItem> items = orderItemMapper.selectList(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<OrderItem>()
                    .eq(OrderItem::getOrderId, order.getId())
            );
            order.setItems(items);
            result.add(convertToVO(order));
        }

        return result;
    }

    /**
     * 获取订单详情（增强版）
     * 包含库存检查结果和操作权限
     */
    public OrderVO getOrderDetailWithStockCheck(Long orderId) {
        Order order = orderMapper.selectById(orderId);
        if (order == null) {
            throw new BusinessException(ResultCode.ORDER_NOT_FOUND);
        }

        List<OrderItem> items = orderItemMapper.selectList(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<OrderItem>()
                .eq(OrderItem::getOrderId, orderId)
        );
        order.setItems(items);

        return convertToVO(order);
    }

    @Data
    public static class OrderItemProductDTO {
        private String productId;
    }
}
