package com.bucketwater.oms.module.print.service;

import com.bucketwater.oms.module.driver.entity.Driver;
import com.bucketwater.oms.module.driver.entity.DriverReturn;
import com.bucketwater.oms.module.driver.mapper.DriverMapper;
import com.bucketwater.oms.module.driver.mapper.DriverReturnMapper;
import com.bucketwater.oms.module.order.entity.Order;
import com.bucketwater.oms.module.order.entity.OrderItem;
import com.bucketwater.oms.module.order.mapper.OrderItemMapper;
import com.bucketwater.oms.module.order.mapper.OrderMapper;
import com.bucketwater.oms.module.product.entity.Product;
import com.bucketwater.oms.module.product.mapper.ProductMapper;
import com.bucketwater.oms.module.station.entity.Station;
import com.bucketwater.oms.module.station.mapper.StationMapper;
import com.bucketwater.oms.module.warehouse.entity.Warehouse;
import com.bucketwater.oms.module.warehouse.mapper.WarehouseMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class PrintService {

    private static final Logger log = LoggerFactory.getLogger(PrintService.class);

    @Autowired
    private OrderMapper orderMapper;

    @Autowired
    private OrderItemMapper orderItemMapper;

    @Autowired
    private StationMapper stationMapper;

    @Autowired
    private WarehouseMapper warehouseMapper;

    @Autowired
    private ProductMapper productMapper;

    @Autowired
    private DriverMapper driverMapper;

    @Autowired
    private DriverReturnMapper driverReturnMapper;

    public String generatePickList(Long orderId) {
        Order order = orderMapper.selectById(orderId);
        if (order == null) {
            throw new RuntimeException("订单不存在");
        }

        Station station = stationMapper.selectById(order.getStationId());
        Warehouse warehouse = warehouseMapper.selectById(order.getWarehouseId());

        List<OrderItem> items = orderItemMapper.selectList(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<OrderItem>()
                .eq(OrderItem::getOrderId, orderId)
        );

        Map<Long, Product> productMap = items.stream()
            .map(OrderItem::getProductId)
            .distinct()
            .map(productMapper::selectById)
            .collect(Collectors.toMap(Product::getId, p -> p));

        StringBuilder sb = new StringBuilder();

        sb.append("\n====================================\n");
        sb.append("        备 货 单\n");
        sb.append("====================================\n\n");

        sb.append("订单号: ").append(order.getOrderNo()).append("\n");
        sb.append("时间: ").append(LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"))).append("\n");
        sb.append("----------------------------------------\n");
        sb.append("水站: ").append(station != null ? station.getName() : "").append("\n");
        sb.append("地址: ").append(order.getDeliveryAddress()).append("\n");
        sb.append("电话: ").append(order.getContactPhone()).append("\n");
        sb.append("----------------------------------------\n\n");

        sb.append("商品明细:\n");
        sb.append("----------------------------------------\n");

        int totalQty = 0;
        for (OrderItem item : items) {
            Product product = productMap.get(item.getProductId());
            String productName = product != null ? product.getName() : "未知商品";
            String spec = product != null && product.getSpecification() != null ? product.getSpecification() : "";

            sb.append(String.format("%-15s %-8s x%d\n", productName, spec, item.getQuantity()));
            totalQty += item.getQuantity();
        }

        sb.append("----------------------------------------\n");
        sb.append(String.format("合计数量: %d 桶/件\n", totalQty));
        sb.append("====================================\n\n");

        sb.append("备货员: ________  复核员: ________\n");
        sb.append("备注: ").append(order.getRemark() != null ? order.getRemark() : "").append("\n");

        log.info("生成备货单: 订单{}", order.getOrderNo());
        return sb.toString();
    }

    public String generateReturnList(Long returnId, Long driverId, Long warehouseId, int bucketQty) {
        Warehouse warehouse = warehouseMapper.selectById(warehouseId);
        com.bucketwater.oms.module.driver.entity.Driver driver = driverId != null ? driverMapper.selectById(driverId) : null;
        com.bucketwater.oms.module.driver.entity.DriverReturn driverReturn = returnId != null ? driverReturnMapper.selectById(returnId) : null;

        StringBuilder sb = new StringBuilder();

        sb.append("\n====================================\n");
        sb.append("        回 仓 单\n");
        sb.append("====================================\n\n");

        sb.append("回仓单号: RT").append(String.format("%06d", returnId != null ? returnId : System.currentTimeMillis() % 1000000)).append("\n");
        sb.append("时间: ").append(LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"))).append("\n");
        sb.append("----------------------------------------\n");
        sb.append("仓库: ").append(warehouse != null ? warehouse.getName() : "").append("\n");
        sb.append("仓库电话: ").append(warehouse != null && warehouse.getContactPhone() != null ? warehouse.getContactPhone() : "").append("\n");
        sb.append("----------------------------------------\n");
        sb.append("司机: ").append(driver != null ? driver.getName() : "").append("\n");
        sb.append("司机电话: ").append(driver != null && driver.getPhone() != null ? driver.getPhone() : "").append("\n");
        sb.append("----------------------------------------\n\n");

        sb.append("回仓物品:\n");
        sb.append("----------------------------------------\n");
        sb.append(String.format("%-20s %d 个\n", "空桶回收", bucketQty));
        if (driverReturn != null) {
            sb.append(String.format("%-20s %d 个\n", "司机上报", driverReturn.getBucketReturned() != null ? driverReturn.getBucketReturned() : 0));
            sb.append(String.format("%-20s %d 个\n", "仓库实收", driverReturn.getActualBucketQty() != null ? driverReturn.getActualBucketQty() : 0));
            sb.append(String.format("%-20s %d 个\n", "差异数量", driverReturn.getDifference() != null ? driverReturn.getDifference() : 0));
        }
        sb.append("----------------------------------------\n");

        if (driverReturn != null && driverReturn.getDifferenceReason() != null && !driverReturn.getDifferenceReason().isEmpty()) {
            sb.append("差异原因: ").append(driverReturn.getDifferenceReason()).append("\n");
        }

        sb.append("\n司机确认: ________  仓管确认: ________\n");
        sb.append("====================================\n");
        sb.append("备注:\n");
        sb.append("\n\n");

        log.info("生成回仓单: 回仓ID{}", returnId);
        return sb.toString();
    }

    public String generateDeliveryList(Long orderId) {
        Order order = orderMapper.selectById(orderId);
        if (order == null) {
            throw new RuntimeException("订单不存在");
        }

        Station station = stationMapper.selectById(order.getStationId());
        Warehouse warehouse = warehouseMapper.selectById(order.getWarehouseId());

        List<OrderItem> items = orderItemMapper.selectList(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<OrderItem>()
                .eq(OrderItem::getOrderId, orderId)
        );

        StringBuilder sb = new StringBuilder();

        sb.append("\n====================================\n");
        sb.append("        配 送 单\n");
        sb.append("====================================\n\n");

        sb.append("订单号: ").append(order.getOrderNo()).append("\n");
        sb.append("时间: ").append(LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"))).append("\n");
        sb.append("----------------------------------------\n");
        sb.append("水站: ").append(station != null ? station.getName() : "").append("\n");
        sb.append("地址: ").append(order.getDeliveryAddress()).append("\n");
        sb.append("电话: ").append(order.getContactPhone()).append("\n");
        sb.append("----------------------------------------\n\n");

        sb.append("配送明细:\n");
        sb.append("----------------------------------------\n");

        for (OrderItem item : items) {
            Product product = productMapper.selectById(item.getProductId());
            String productName = product != null ? product.getName() : "未知商品";
            sb.append(String.format("%-15s x%d\n", productName, item.getQuantity()));
        }

        sb.append("----------------------------------------\n\n");

        sb.append("配送员: ________  客户签收: ________\n");
        sb.append("签收时间: ________\n");
        sb.append("====================================\n");

        log.info("生成配送单: 订单{}", order.getOrderNo());
        return sb.toString();
    }

    public byte[] getEscPosCommands(String content, String printerType) {
        byte[] contentBytes = content.getBytes();

        if ("58mm".equals(printerType)) {
            return generate58mmCommands(contentBytes);
        } else if ("80mm".equals(printerType)) {
            return generate80mmCommands(contentBytes);
        } else {
            return generate80mmCommands(contentBytes);
        }
    }

    private byte[] generate58mmCommands(byte[] content) {
        byte[] ESC = new byte[]{0x1B};
        byte[] INIT = new byte[]{0x1B, 0x40};
        byte[] CENTER = new byte[]{0x1B, 0x61, 0x01};
        byte[] LEFT = new byte[]{0x1B, 0x61, 0x00};
        byte[] BOLD_ON = new byte[]{0x1B, 0x45, 0x01};
        byte[] BOLD_OFF = new byte[]{0x1B, 0x45, 0x00};
        byte[] DOUBLE_HEIGHT = new byte[]{0x1B, 0x21, 0x10};
        byte[] NORMAL = new byte[]{0x1B, 0x21, 0x00};
        byte[] LF = new byte[]{0x0A};

        int totalLen = INIT.length + content.length + LF.length + 10;
        byte[] result = new byte[totalLen];
        int idx = 0;

        System.arraycopy(INIT, 0, result, idx, INIT.length);
        idx += INIT.length;

        System.arraycopy(CENTER, 0, result, idx, CENTER.length);
        idx += CENTER.length;

        System.arraycopy(BOLD_ON, 0, result, idx, BOLD_ON.length);
        idx += BOLD_ON.length;

        System.arraycopy(content, 0, result, idx, content.length);

        return result;
    }

    private byte[] generate80mmCommands(byte[] content) {
        byte[] INIT = new byte[]{0x1B, 0x40};
        byte[] LF = new byte[]{0x0A};

        int totalLen = INIT.length + content.length + 10;
        byte[] result = new byte[totalLen];
        int idx = 0;

        System.arraycopy(INIT, 0, result, idx, INIT.length);
        idx += INIT.length;

        System.arraycopy(content, 0, result, idx, content.length);
        idx += content.length;

        System.arraycopy(LF, 0, result, idx, LF.length);

        return result;
    }
}
