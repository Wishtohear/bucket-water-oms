package com.bucketwater.oms.module.order.service;

import com.bucketwater.oms.common.exception.BusinessException;
import com.bucketwater.oms.module.order.dto.CreateOrderRequest;
import com.bucketwater.oms.module.order.dto.DeliveryRequest;
import com.bucketwater.oms.module.order.dto.DispatchOrderRequest;
import com.bucketwater.oms.module.order.dto.DispatchOrderResponse;
import com.bucketwater.oms.module.order.dto.OrderVO;
import com.bucketwater.oms.module.order.dto.ReviewOrderRequest;
import com.bucketwater.oms.module.order.entity.Order;
import com.bucketwater.oms.module.order.entity.OrderItem;
import com.bucketwater.oms.module.order.mapper.OrderItemMapper;
import com.bucketwater.oms.module.order.mapper.OrderMapper;
import com.bucketwater.oms.module.station.entity.StationAccount;
import com.bucketwater.oms.module.station.mapper.StationAccountMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;


import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@DisplayName("订单服务单元测试")
class OrderServiceTest {

    @Mock
    private OrderMapper orderMapper;

    @Mock
    private OrderItemMapper orderItemMapper;

    @Mock
    private StationAccountMapper stationAccountMapper;

    @InjectMocks
    private OrderService orderService;

    private Long stationId;
    private Long orderId;
    private Long warehouseId;
    private Long productId;
    private StationAccount stationAccount;
    private Order testOrder;

    @BeforeEach
    void setUp() {
        stationId = 1L;
        orderId = 1L;
        warehouseId = 1L;
        productId = 1L;

        stationAccount = new StationAccount();
        stationAccount.setId(1L);
        stationAccount.setStationId(stationId);
        stationAccount.setDepositBalance(new BigDecimal("10000.00"));
        stationAccount.setCreditLimit(new BigDecimal("5000.00"));
        stationAccount.setCreditUsed(BigDecimal.ZERO);
        stationAccount.setBucketDepositPerUnit(new BigDecimal("30.00"));
        stationAccount.setOwedBucketNum(5);
        stationAccount.setOwedThreshold(10);

        testOrder = new Order();
        testOrder.setId(orderId);
        testOrder.setOrderNo("ORD20260419001");
        testOrder.setStationId(stationId);
        testOrder.setWarehouseId(warehouseId);
        testOrder.setStatus("pending_review");
        testOrder.setTotalAmount(new BigDecimal("150.00"));
        testOrder.setPaymentType("prepaid");
        testOrder.setDeliveryAddress("测试地址");
        testOrder.setContactName("张三");
        testOrder.setContactPhone("13800138000");
        testOrder.setCreateTime(LocalDateTime.now());
        testOrder.setUpdateTime(LocalDateTime.now());
    }

    @Test
    @DisplayName("创建订单成功")
    void createOrder_Success() {
        CreateOrderRequest request = new CreateOrderRequest();
        request.setWarehouseId(warehouseId);
        request.setDeliveryAddress("测试地址");
        request.setContactName("张三");
        request.setContactPhone("13800138000");

        List<CreateOrderRequest.OrderItemDTO> items = new ArrayList<>();
        CreateOrderRequest.OrderItemDTO itemDTO = new CreateOrderRequest.OrderItemDTO();
        itemDTO.setProductId(productId);
        itemDTO.setQuantity(10);
        items.add(itemDTO);
        request.setItems(items);

        when(stationAccountMapper.selectOne(any())).thenReturn(stationAccount);
        when(orderMapper.insert(any(Order.class))).thenReturn(1);
        when(orderItemMapper.insert(any(OrderItem.class))).thenReturn(1);

        OrderVO result = orderService.createOrder(stationId, request);

        assertNotNull(result);
        assertEquals("pending_review", result.getStatus());
        verify(orderMapper).insert(any(Order.class));
        verify(orderItemMapper, atLeastOnce()).insert(any(OrderItem.class));
    }

    @Test
    @DisplayName("水站不存在时创建订单失败")
    void createOrder_StationNotFound() {
        CreateOrderRequest request = new CreateOrderRequest();
        request.setWarehouseId(warehouseId);
        request.setItems(new ArrayList<>());

        when(stationAccountMapper.selectOne(any())).thenReturn(null);

        assertThrows(BusinessException.class, () -> {
            orderService.createOrder(stationId, request);
        });
    }

    @Test
    @DisplayName("余额不足时创建订单失败")
    void createOrder_InsufficientBalance() {
        stationAccount.setDepositBalance(new BigDecimal("10.00"));

        CreateOrderRequest request = new CreateOrderRequest();
        request.setWarehouseId(warehouseId);
        request.setDeliveryAddress("测试地址");
        request.setContactName("张三");
        request.setContactPhone("13800138000");

        List<CreateOrderRequest.OrderItemDTO> items = new ArrayList<>();
        CreateOrderRequest.OrderItemDTO itemDTO = new CreateOrderRequest.OrderItemDTO();
        itemDTO.setProductId(productId);
        itemDTO.setQuantity(100);
        items.add(itemDTO);
        request.setItems(items);

        when(stationAccountMapper.selectOne(any())).thenReturn(stationAccount);

        assertThrows(BusinessException.class, () -> {
            orderService.createOrder(stationId, request);
        });
    }

    @Test
    @DisplayName("获取订单详情成功")
    void getOrderDetail_Success() {
        List<OrderItem> items = new ArrayList<>();
        OrderItem item = new OrderItem();
        item.setId(1L);
        item.setOrderId(orderId);
        item.setProductId(productId);
        item.setQuantity(10);
        item.setActualQty(10);
        item.setUnitPrice(new BigDecimal("15.00"));
        item.setSubtotal(new BigDecimal("150.00"));
        items.add(item);

        when(orderMapper.selectById(orderId)).thenReturn(testOrder);
        when(orderItemMapper.selectList(any())).thenReturn(items);

        OrderVO result = orderService.getOrderDetail(orderId);

        assertNotNull(result);
        assertEquals(orderId.toString(), result.getOrderId());
        assertEquals("ORD20260419001", result.getOrderNo());
        assertEquals("pending_review", result.getStatus());
        assertEquals(1, result.getItems().size());
    }

    @Test
    @DisplayName("订单不存在时获取详情失败")
    void getOrderDetail_NotFound() {
        when(orderMapper.selectById(orderId)).thenReturn(null);

        assertThrows(BusinessException.class, () -> {
            orderService.getOrderDetail(orderId);
        });
    }

    @Test
    @DisplayName("审查前订单可取消")
    void cancelOrder_Success() {
        when(orderMapper.selectById(orderId)).thenReturn(testOrder);
        when(orderMapper.updateById(any(Order.class))).thenReturn(1);

        orderService.cancelOrder(orderId, "客户要求取消");

        verify(orderMapper).updateById(any(Order.class));
    }

    @Test
    @DisplayName("已接单订单不可取消")
    void cancelOrder_AlreadyReviewed() {
        testOrder.setStatus("reviewed");

        when(orderMapper.selectById(orderId)).thenReturn(testOrder);

        assertThrows(BusinessException.class, () -> {
            orderService.cancelOrder(orderId, "客户要求取消");
        });
    }

    @Test
    @DisplayName("仓库接单成功")
    void reviewOrder_Accept_Success() {
        ReviewOrderRequest request = new ReviewOrderRequest();
        request.setAction("accept");

        when(orderMapper.selectById(orderId)).thenReturn(testOrder);
        when(orderMapper.updateById(any(Order.class))).thenReturn(1);
        when(orderItemMapper.selectList(any())).thenReturn(new ArrayList<>());

        OrderVO result = orderService.reviewOrder(orderId, warehouseId, request);

        assertNotNull(result);
        assertEquals("reviewed", result.getStatus());
    }

    @Test
    @DisplayName("仓库拒单成功")
    void reviewOrder_Reject_Success() {
        ReviewOrderRequest request = new ReviewOrderRequest();
        request.setAction("reject");
        request.setReason("库存不足");

        when(orderMapper.selectById(orderId)).thenReturn(testOrder);
        when(orderMapper.updateById(any(Order.class))).thenReturn(1);
        when(orderItemMapper.selectList(any())).thenReturn(new ArrayList<>());

        OrderVO result = orderService.reviewOrder(orderId, warehouseId, request);

        assertNotNull(result);
        assertEquals("rejected", result.getStatus());
    }

    @Test
    @DisplayName("派单成功")
    void dispatchOrder_Success() {
        Long driverId = 2L;
        DispatchOrderRequest request = new DispatchOrderRequest();
        request.setDriverId(driverId);

        testOrder.setStatus("reviewed");

        when(orderMapper.selectById(orderId)).thenReturn(testOrder);
        when(orderMapper.updateById(any(Order.class))).thenReturn(1);
        when(orderItemMapper.selectList(any())).thenReturn(new ArrayList<>());

        DispatchOrderResponse response = orderService.dispatchOrder(orderId, warehouseId, request);

        assertNotNull(response);
        assertTrue(response.isSuccess());
        OrderVO result = response.getOrder();
        assertNotNull(result);
        assertEquals("dispatched", result.getStatus());
    }

    @Test
    @DisplayName("未接单订单不能派单")
    void dispatchOrder_NotReviewed() {
        DispatchOrderRequest request = new DispatchOrderRequest();
        request.setDriverId(2L);

        when(orderMapper.selectById(orderId)).thenReturn(testOrder);

        assertThrows(BusinessException.class, () -> {
            orderService.dispatchOrder(orderId, warehouseId, request);
        });
    }

    @Test
    @DisplayName("配送签收成功")
    void deliverOrder_Success() {
        testOrder.setStatus("dispatched");

        List<OrderItem> items = new ArrayList<>();
        OrderItem item = new OrderItem();
        item.setId(1L);
        item.setOrderId(orderId);
        item.setProductId(productId);
        item.setQuantity(10);
        item.setUnitPrice(new BigDecimal("15.00"));
        item.setSubtotal(new BigDecimal("150.00"));
        items.add(item);

        DeliveryRequest request = new DeliveryRequest();
        request.setActualQty(10);
        request.setBucketReturned(8);
        request.setBucketOwed(2);
        request.setSignType("signature");

        List<DeliveryRequest.DeliveryItemDTO> deliveryItems = new ArrayList<>();
        DeliveryRequest.DeliveryItemDTO deliveryItem = new DeliveryRequest.DeliveryItemDTO();
        deliveryItem.setProductId(productId);
        deliveryItem.setActualQty(10);
        deliveryItems.add(deliveryItem);
        request.setItems(deliveryItems);

        when(orderMapper.selectById(orderId)).thenReturn(testOrder);
        when(orderItemMapper.selectList(any())).thenReturn(items);
        when(orderItemMapper.updateById(any(OrderItem.class))).thenReturn(1);
        when(orderMapper.updateById(any(Order.class))).thenReturn(1);

        OrderVO result = orderService.deliverOrder(orderId, request);

        assertNotNull(result);
        assertEquals("completed", result.getStatus());
    }
}
