package com.bucketwater.oms.module.report.service;

import com.bucketwater.oms.common.exception.BusinessException;
import com.bucketwater.oms.common.response.ResultCode;
import com.bucketwater.oms.module.bucket.entity.BucketTransaction;
import com.bucketwater.oms.module.bucket.mapper.BucketTransactionMapper;
import com.bucketwater.oms.module.export.service.ExcelExportService;
import com.bucketwater.oms.module.order.entity.Order;
import com.bucketwater.oms.module.order.entity.OrderItem;
import com.bucketwater.oms.module.order.mapper.OrderItemMapper;
import com.bucketwater.oms.module.order.mapper.OrderMapper;
import com.bucketwater.oms.module.product.entity.Product;
import com.bucketwater.oms.module.product.entity.ProductInventory;
import com.bucketwater.oms.module.product.mapper.ProductInventoryMapper;
import com.bucketwater.oms.module.product.mapper.ProductMapper;
import com.bucketwater.oms.module.station.entity.Station;
import com.bucketwater.oms.module.station.entity.StationAccount;
import com.bucketwater.oms.module.station.mapper.StationAccountMapper;
import com.bucketwater.oms.module.station.mapper.StationMapper;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.LinkedHashMap;

@Service
public class ReportService {

    @Autowired
    private OrderMapper orderMapper;

    @Autowired
    private OrderItemMapper orderItemMapper;

    @Autowired
    private StationMapper stationMapper;

    @Autowired
    private StationAccountMapper stationAccountMapper;

    @Autowired
    private ProductMapper productMapper;

    @Autowired
    private ProductInventoryMapper productInventoryMapper;

    @Autowired
    private BucketTransactionMapper bucketTransactionMapper;

    @Autowired
    private ExcelExportService excelExportService;

    public Map<String, Object> getStationPurchaseReport(String yearMonth, String stationId) {
        Map<String, Object> report = new HashMap<>();

        List<Order> orders = getOrdersByMonth(yearMonth, stationId);

        List<Map<String, Object>> details = new ArrayList<>();
        BigDecimal totalAmount = BigDecimal.ZERO;

        for (Order order : orders) {
            Map<String, Object> detail = new HashMap<>();
            detail.put("orderId", order.getId().toString());
            detail.put("orderNo", order.getOrderNo());
            detail.put("date", order.getCreateTime().toLocalDate());
            detail.put("stationName", getStationName(order.getStationId()));
            detail.put("amount", order.getTotalAmount());
            detail.put("status", order.getStatus());

            List<OrderItem> items = orderItemMapper.selectList(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<OrderItem>()
                    .eq(OrderItem::getOrderId, order.getId())
            );

            List<Map<String, Object>> itemDetails = new ArrayList<>();
            for (OrderItem item : items) {
                Map<String, Object> itemDetail = new HashMap<>();
                itemDetail.put("productName", getProductName(item.getProductId()));
                itemDetail.put("quantity", item.getQuantity());
                itemDetail.put("amount", item.getSubtotal());
                itemDetails.add(itemDetail);
            }
            detail.put("items", itemDetails);

            details.add(detail);
            totalAmount = totalAmount.add(order.getTotalAmount());
        }

        report.put("yearMonth", yearMonth);
        report.put("totalAmount", totalAmount);
        report.put("orderCount", orders.size());
        report.put("details", details);

        return report;
    }

    public Map<String, Object> getDriverDeliveryReport(String yearMonth, String driverId) {
        Map<String, Object> report = new HashMap<>();

        List<Order> orders = getOrdersByMonthAndDriver(yearMonth, driverId);

        List<Map<String, Object>> details = new ArrayList<>();
        int totalBuckets = 0;

        for (Order order : orders) {
            Map<String, Object> detail = new HashMap<>();
            detail.put("orderId", order.getId().toString());
            detail.put("orderNo", order.getOrderNo());
            detail.put("date", order.getCreateTime().toLocalDate());
            detail.put("stationName", getStationName(order.getStationId()));
            detail.put("status", order.getStatus());
            detail.put("deliveredAt", order.getDeliveredAt());

            List<OrderItem> items = orderItemMapper.selectList(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<OrderItem>()
                    .eq(OrderItem::getOrderId, order.getId())
            );

            int bucketCount = items.stream()
                .filter(item -> isBucketProduct(item.getProductId()))
                .mapToInt(OrderItem::getActualQty)
                .sum();

            detail.put("bucketCount", bucketCount);
            details.add(detail);
            totalBuckets += bucketCount;
        }

        report.put("yearMonth", yearMonth);
        report.put("driverId", driverId);
        report.put("totalOrders", orders.size());
        report.put("totalBuckets", totalBuckets);
        report.put("details", details);

        return report;
    }

    public Map<String, Object> getBucketSummary() {
        Map<String, Object> summary = new HashMap<>();

        List<Station> stations = stationMapper.selectList(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Station>()
                .eq(Station::getStatus, "active")
        );

        List<Map<String, Object>> stationBuckets = new ArrayList<>();
        int totalOwedBuckets = 0;

        for (Station station : stations) {
            StationAccount account = stationAccountMapper.selectOne(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<StationAccount>()
                    .eq(StationAccount::getStationId, station.getId())
            );

            Map<String, Object> stationBucket = new HashMap<>();
            stationBucket.put("stationId", station.getId().toString());
            stationBucket.put("stationName", station.getName());
            stationBucket.put("owedBuckets", account != null ? account.getOwedBucketNum() : 0);
            stationBucket.put("depositBalance", account != null ? account.getDepositBalance() : BigDecimal.ZERO);
            stationBucket.put("bucketDepositPerUnit", account != null ? account.getBucketDepositPerUnit() : new BigDecimal("30.00"));
            stationBucket.put("owedThreshold", account != null ? account.getOwedThreshold() : 10);
            stationBucket.put("isWarning", account != null && account.getOwedBucketNum() >= account.getOwedThreshold());
            stationBuckets.add(stationBucket);

            if (account != null) {
                totalOwedBuckets += account.getOwedBucketNum();
            }
        }

        int onTheWayBuckets = countOnTheWayBuckets();
        int warehouseBuckets = countWarehouseBuckets();

        summary.put("stations", stationBuckets);
        summary.put("totalOwedBuckets", totalOwedBuckets);
        summary.put("onTheWayBuckets", onTheWayBuckets);
        summary.put("warehouseBuckets", warehouseBuckets);

        return summary;
    }

    public Map<String, Object> getAreaDistributionReport(String yearMonth, String area) {
        Map<String, Object> report = new HashMap<>();

        List<Order> orders = getOrdersByAreaAndMonth(yearMonth, area);

        Map<String, Map<String, Object>> areaStats = new LinkedHashMap<>();
        int totalOrders = 0;
        BigDecimal totalAmount = BigDecimal.ZERO;

        for (Order order : orders) {
            String stationArea = getStationArea(order.getStationId());
            if (stationArea == null || stationArea.isEmpty()) {
                stationArea = "未知区域";
            }

            areaStats.putIfAbsent(stationArea, new HashMap<>());
            Map<String, Object> stats = areaStats.get(stationArea);

            int orderCount = (int) stats.getOrDefault("orderCount", 0) + 1;
            BigDecimal areaAmount = (BigDecimal) stats.getOrDefault("totalAmount", BigDecimal.ZERO);
            areaAmount = areaAmount.add(order.getTotalAmount());

            stats.put("area", stationArea);
            stats.put("orderCount", orderCount);
            stats.put("totalAmount", areaAmount);

            totalOrders++;
            totalAmount = totalAmount.add(order.getTotalAmount());
        }

        List<Map<String, Object>> areaList = new ArrayList<>();
        for (Map.Entry<String, Map<String, Object>> entry : areaStats.entrySet()) {
            Map<String, Object> areaData = entry.getValue();
            BigDecimal amount = (BigDecimal) areaData.get("totalAmount");
            int count = (int) areaData.get("orderCount");
            double avgAmount = count > 0 ? amount.doubleValue() / count : 0;
            areaData.put("avgOrderAmount", avgAmount);
            areaData.put("orderRatio", totalOrders > 0 ? (double) count / totalOrders * 100 : 0);
            areaData.put("amountRatio", totalAmount.compareTo(BigDecimal.ZERO) > 0
                ? amount.divide(totalAmount, 4, java.math.RoundingMode.HALF_UP).doubleValue() * 100 : 0);
            areaList.add(areaData);
        }

        areaList.sort((a, b) -> {
            BigDecimal amountA = (BigDecimal) a.get("totalAmount");
            BigDecimal amountB = (BigDecimal) b.get("totalAmount");
            return amountB.compareTo(amountA);
        });

        report.put("yearMonth", yearMonth);
        report.put("area", area != null ? area : "全部");
        report.put("totalOrders", totalOrders);
        report.put("totalAmount", totalAmount);
        report.put("avgOrderAmount", totalOrders > 0 ? totalAmount.doubleValue() / totalOrders : 0);
        report.put("areaList", areaList);

        return report;
    }

    public Map<String, Object> getAreaTrendReport(String startDate, String endDate, String area) {
        Map<String, Object> report = new HashMap<>();

        List<Order> orders = getOrdersByDateRangeAndArea(startDate, endDate, area);

        Map<String, Map<String, Object>> dailyStats = new LinkedHashMap<>();

        for (Order order : orders) {
            String dateKey = order.getCreateTime().toLocalDate().toString();
            String stationArea = getStationArea(order.getStationId());
            if (stationArea == null || stationArea.isEmpty()) {
                stationArea = "未知区域";
            }

            String key = dateKey + "_" + stationArea;
            dailyStats.putIfAbsent(key, new HashMap<>());
            Map<String, Object> stats = dailyStats.get(key);

            int orderCount = (int) stats.getOrDefault("orderCount", 0) + 1;
            BigDecimal dayAmount = (BigDecimal) stats.getOrDefault("totalAmount", BigDecimal.ZERO);
            dayAmount = dayAmount.add(order.getTotalAmount());

            stats.put("date", dateKey);
            stats.put("area", stationArea);
            stats.put("orderCount", orderCount);
            stats.put("totalAmount", dayAmount);
        }

        List<Map<String, Object>> trendList = new ArrayList<>(dailyStats.values());
        trendList.sort((a, b) -> {
            String dateA = (String) a.get("date");
            String dateB = (String) b.get("date");
            return dateA.compareTo(dateB);
        });

        report.put("startDate", startDate);
        report.put("endDate", endDate);
        report.put("area", area != null ? area : "全部");
        report.put("trendList", trendList);

        return report;
    }

    private List<Order> getOrdersByAreaAndMonth(String yearMonth, String area) {
        com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Order> wrapper =
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Order>();

        if (yearMonth != null && yearMonth.length() == 7) {
            int year = Integer.parseInt(yearMonth.substring(0, 4));
            int month = Integer.parseInt(yearMonth.substring(5, 7));
            LocalDate startDate = LocalDate.of(year, month, 1);
            LocalDate endDate = startDate.plusMonths(1).minusDays(1);

            wrapper.ge(Order::getCreateTime, startDate.atStartOfDay())
                   .le(Order::getCreateTime, endDate.atTime(23, 59, 59));
        }

        wrapper.orderByDesc(Order::getCreateTime);

        List<Order> orders = orderMapper.selectList(wrapper);

        if (area != null && !area.isEmpty()) {
            orders = orders.stream()
                .filter(order -> {
                    String stationArea = getStationArea(order.getStationId());
                    return area.equals(stationArea);
                })
                .collect(java.util.stream.Collectors.toList());
        }

        return orders;
    }

    private List<Order> getOrdersByDateRangeAndArea(String startDate, String endDate, String area) {
        com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Order> wrapper =
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Order>();

        if (startDate != null && !startDate.isEmpty()) {
            wrapper.ge(Order::getCreateTime, LocalDate.parse(startDate).atStartOfDay());
        }
        if (endDate != null && !endDate.isEmpty()) {
            wrapper.le(Order::getCreateTime, LocalDate.parse(endDate).atTime(23, 59, 59));
        }

        wrapper.orderByAsc(Order::getCreateTime);

        List<Order> orders = orderMapper.selectList(wrapper);

        if (area != null && !area.isEmpty()) {
            orders = orders.stream()
                .filter(order -> {
                    String stationArea = getStationArea(order.getStationId());
                    return area.equals(stationArea);
                })
                .collect(java.util.stream.Collectors.toList());
        }

        return orders;
    }

    private String getStationArea(Long stationId) {
        if (stationId == null) return "";
        Station station = stationMapper.selectById(stationId);
        return station != null ? (station.getArea() != null ? station.getArea() : "") : "";
    }

    private int countOnTheWayBuckets() {
        List<Order> orders = orderMapper.selectList(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Order>()
                .in(Order::getStatus, "dispatched", "delivering")
        );

        int totalBuckets = 0;
        for (Order order : orders) {
            List<OrderItem> items = orderItemMapper.selectList(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<OrderItem>()
                    .eq(OrderItem::getOrderId, order.getId())
            );
            for (OrderItem item : items) {
                if (isBucketProduct(item.getProductId())) {
                    totalBuckets += item.getQuantity();
                }
            }
        }
        return totalBuckets;
    }

    private int countWarehouseBuckets() {
        List<Product> bucketProducts = productMapper.selectList(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Product>()
                .eq(Product::getCategory, "bucket_water")
                .eq(Product::getStatus, "active")
        );

        int totalBuckets = 0;
        for (Product product : bucketProducts) {
            List<ProductInventory> inventories = productInventoryMapper.selectList(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<ProductInventory>()
                    .eq(ProductInventory::getProductId, product.getId())
            );
            for (ProductInventory inv : inventories) {
                totalBuckets += inv.getQuantity();
            }
        }
        return totalBuckets;
    }

    private List<Order> getOrdersByMonth(String yearMonth, String stationId) {
        com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Order> wrapper =
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Order>();

        if (yearMonth != null && yearMonth.length() == 7) {
            int year = Integer.parseInt(yearMonth.substring(0, 4));
            int month = Integer.parseInt(yearMonth.substring(5, 7));
            LocalDate startDate = LocalDate.of(year, month, 1);
            LocalDate endDate = startDate.plusMonths(1).minusDays(1);

            wrapper.ge(Order::getCreateTime, startDate.atStartOfDay())
                   .le(Order::getCreateTime, endDate.atTime(23, 59, 59));
        }

        if (stationId != null && !stationId.isEmpty()) {
            wrapper.eq(Order::getStationId, Long.parseLong(stationId));
        }

        wrapper.orderByDesc(Order::getCreateTime);

        return orderMapper.selectList(wrapper);
    }

    private List<Order> getOrdersByMonthAndDriver(String yearMonth, String driverId) {
        com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Order> wrapper =
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Order>();

        if (yearMonth != null && yearMonth.length() == 7) {
            int year = Integer.parseInt(yearMonth.substring(0, 4));
            int month = Integer.parseInt(yearMonth.substring(5, 7));
            LocalDate startDate = LocalDate.of(year, month, 1);
            LocalDate endDate = startDate.plusMonths(1).minusDays(1);

            wrapper.ge(Order::getCreateTime, startDate.atStartOfDay())
                   .le(Order::getCreateTime, endDate.atTime(23, 59, 59));
        }

        if (driverId != null && !driverId.isEmpty()) {
            wrapper.eq(Order::getDriverId, Long.parseLong(driverId));
        }

        wrapper.eq(Order::getStatus, "completed");
        wrapper.orderByDesc(Order::getCreateTime);

        return orderMapper.selectList(wrapper);
    }

    private String getStationName(Long stationId) {
        if (stationId == null) return "";
        Station station = stationMapper.selectById(stationId);
        return station != null ? station.getName() : "";
    }

    private String getProductName(Long productId) {
        if (productId == null) return "";
        Product product = productMapper.selectById(productId);
        return product != null ? product.getName() : "";
    }

    private boolean isBucketProduct(Long productId) {
        if (productId == null) return false;
        Product product = productMapper.selectById(productId);
        return product != null && "bucket_water".equals(product.getCategory());
    }

    public byte[] exportReport(String type, String yearMonth) {
        return switch (type) {
            case "station_purchase" -> exportStationPurchaseReport(yearMonth);
            case "driver_delivery" -> exportDriverDeliveryReport(yearMonth);
            case "bucket_summary" -> exportBucketSummaryReport();
            default -> throw new BusinessException(ResultCode.PARAM_INVALID, "不支持的报表类型: " + type);
        };
    }

    private byte[] exportStationPurchaseReport(String yearMonth) {
        try (Workbook workbook = new XSSFWorkbook();
             ByteArrayOutputStream out = new ByteArrayOutputStream()) {

            Sheet sheet = workbook.createSheet("水站进货报表");
            CellStyle headerStyle = createHeaderStyle(workbook);
            CellStyle moneyStyle = createMoneyStyle(workbook);

            int rowNum = 0;
            Row titleRow = sheet.createRow(rowNum++);
            Cell titleCell = titleRow.createCell(0);
            titleCell.setCellValue(yearMonth + " 水站进货报表");
            titleCell.setCellStyle(headerStyle);
            sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(0, 0, 0, 5));

            rowNum++;
            Row headerRow = sheet.createRow(rowNum++);
            String[] headers = {"日期", "订单号", "水站名称", "商品明细", "金额", "状态"};
            for (int i = 0; i < headers.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(headers[i]);
                cell.setCellStyle(headerStyle);
            }

            List<Order> orders = getOrdersByMonth(yearMonth, null);
            BigDecimal totalAmount = BigDecimal.ZERO;

            for (Order order : orders) {
                Row dataRow = sheet.createRow(rowNum++);
                dataRow.createCell(0).setCellValue(order.getCreateTime().format(DateTimeFormatter.ofPattern("yyyy-MM-dd")));
                dataRow.createCell(1).setCellValue(order.getOrderNo());
                dataRow.createCell(2).setCellValue(getStationName(order.getStationId()));

                List<OrderItem> items = orderItemMapper.selectList(
                    new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<OrderItem>()
                        .eq(OrderItem::getOrderId, order.getId())
                );
                StringBuilder itemDesc = new StringBuilder();
                for (OrderItem item : items) {
                    if (itemDesc.length() > 0) itemDesc.append("; ");
                    itemDesc.append(getProductName(item.getProductId())).append("×").append(item.getQuantity());
                }
                dataRow.createCell(3).setCellValue(itemDesc.toString());

                Cell amountCell = dataRow.createCell(4);
                amountCell.setCellValue(order.getTotalAmount().doubleValue());
                amountCell.setCellStyle(moneyStyle);

                dataRow.createCell(5).setCellValue(getStatusText(order.getStatus()));
                totalAmount = totalAmount.add(order.getTotalAmount());
            }

            rowNum++;
            Row totalRow = sheet.createRow(rowNum++);
            totalRow.createCell(3).setCellValue("合计:");
            Cell totalCell = totalRow.createCell(4);
            totalCell.setCellValue(totalAmount.doubleValue());
            totalCell.setCellStyle(moneyStyle);

            for (int i = 0; i < headers.length; i++) {
                sheet.setColumnWidth(i, 4000);
            }

            workbook.write(out);
            return out.toByteArray();

        } catch (IOException e) {
            throw new RuntimeException("导出报表失败: " + e.getMessage());
        }
    }

    private byte[] exportDriverDeliveryReport(String yearMonth) {
        try (Workbook workbook = new XSSFWorkbook();
             ByteArrayOutputStream out = new ByteArrayOutputStream()) {

            Sheet sheet = workbook.createSheet("司机配送报表");
            CellStyle headerStyle = createHeaderStyle(workbook);
            CellStyle moneyStyle = createMoneyStyle(workbook);

            int rowNum = 0;
            Row titleRow = sheet.createRow(rowNum++);
            Cell titleCell = titleRow.createCell(0);
            titleCell.setCellValue(yearMonth + " 司机配送报表");
            titleCell.setCellStyle(headerStyle);
            sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(0, 0, 0, 6));

            rowNum++;
            Row headerRow = sheet.createRow(rowNum++);
            String[] headers = {"日期", "订单号", "水站名称", "商品明细", "桶数", "状态", "完成时间"};
            for (int i = 0; i < headers.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(headers[i]);
                cell.setCellStyle(headerStyle);
            }

            List<Order> orders = getOrdersByMonthAndDriver(yearMonth, null);
            int totalBuckets = 0;

            for (Order order : orders) {
                Row dataRow = sheet.createRow(rowNum++);
                dataRow.createCell(0).setCellValue(order.getCreateTime().format(DateTimeFormatter.ofPattern("yyyy-MM-dd")));
                dataRow.createCell(1).setCellValue(order.getOrderNo());
                dataRow.createCell(2).setCellValue(getStationName(order.getStationId()));

                List<OrderItem> items = orderItemMapper.selectList(
                    new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<OrderItem>()
                        .eq(OrderItem::getOrderId, order.getId())
                );
                StringBuilder itemDesc = new StringBuilder();
                int bucketCount = 0;
                for (OrderItem item : items) {
                    if (itemDesc.length() > 0) itemDesc.append("; ");
                    itemDesc.append(getProductName(item.getProductId())).append("×").append(item.getActualQty());
                    if (isBucketProduct(item.getProductId())) {
                        bucketCount += item.getActualQty();
                    }
                }
                dataRow.createCell(3).setCellValue(itemDesc.toString());
                dataRow.createCell(4).setCellValue(bucketCount);
                dataRow.createCell(5).setCellValue(getStatusText(order.getStatus()));
                dataRow.createCell(6).setCellValue(order.getDeliveredAt() != null ?
                    order.getDeliveredAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")) : "");
                totalBuckets += bucketCount;
            }

            rowNum++;
            Row totalRow = sheet.createRow(rowNum++);
            totalRow.createCell(3).setCellValue("合计:");
            totalRow.createCell(4).setCellValue(totalBuckets);

            for (int i = 0; i < headers.length; i++) {
                sheet.setColumnWidth(i, 4000);
            }

            workbook.write(out);
            return out.toByteArray();

        } catch (IOException e) {
            throw new RuntimeException("导出报表失败: " + e.getMessage());
        }
    }

    private byte[] exportBucketSummaryReport() {
        try (Workbook workbook = new XSSFWorkbook();
             ByteArrayOutputStream out = new ByteArrayOutputStream()) {

            Sheet sheet = workbook.createSheet("空桶汇总报表");
            CellStyle headerStyle = createHeaderStyle(workbook);
            CellStyle moneyStyle = createMoneyStyle(workbook);

            int rowNum = 0;
            Row titleRow = sheet.createRow(rowNum++);
            Cell titleCell = titleRow.createCell(0);
            titleCell.setCellValue("空桶汇总报表");
            titleCell.setCellStyle(headerStyle);
            sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(0, 0, 0, 5));

            Map<String, Object> summary = getBucketSummary();
            rowNum++;
            Row summaryRow = sheet.createRow(rowNum++);
            summaryRow.createCell(0).setCellValue("总欠桶数:");
            summaryRow.createCell(1).setCellValue((Integer) summary.get("totalOwedBuckets"));
            summaryRow.createCell(2).setCellValue("在途桶数:");
            summaryRow.createCell(3).setCellValue((Integer) summary.get("onTheWayBuckets"));
            summaryRow.createCell(4).setCellValue("仓库库存:");
            summaryRow.createCell(5).setCellValue((Integer) summary.get("warehouseBuckets"));

            rowNum++;
            Row headerRow = sheet.createRow(rowNum++);
            String[] headers = {"水站ID", "水站名称", "欠桶数量", "押金余额", "每桶押金", "欠桶阈值", "预警状态"};
            for (int i = 0; i < headers.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(headers[i]);
                cell.setCellStyle(headerStyle);
            }

            List<Map<String, Object>> stations = (List<Map<String, Object>>) summary.get("stations");
            for (Map<String, Object> station : stations) {
                Row dataRow = sheet.createRow(rowNum++);
                dataRow.createCell(0).setCellValue((String) station.get("stationId"));
                dataRow.createCell(1).setCellValue((String) station.get("stationName"));
                dataRow.createCell(2).setCellValue((Integer) station.get("owedBuckets"));
                Cell depositCell = dataRow.createCell(3);
                depositCell.setCellValue(((BigDecimal) station.get("depositBalance")).doubleValue());
                depositCell.setCellStyle(moneyStyle);
                depositCell.setCellValue(((BigDecimal) station.get("bucketDepositPerUnit")).doubleValue());
                dataRow.createCell(4).setCellValue((Integer) station.get("owedThreshold"));
                dataRow.createCell(5).setCellValue((Boolean) station.get("isWarning") ? "是" : "否");
            }

            for (int i = 0; i < headers.length; i++) {
                sheet.setColumnWidth(i, 4000);
            }

            workbook.write(out);
            return out.toByteArray();

        } catch (IOException e) {
            throw new RuntimeException("导出报表失败: " + e.getMessage());
        }
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

    private CellStyle createHeaderStyle(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        Font font = workbook.createFont();
        font.setBold(true);
        font.setFontHeightInPoints((short) 12);
        style.setFont(font);
        style.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
        style.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        style.setBorderBottom(BorderStyle.THIN);
        style.setBorderTop(BorderStyle.THIN);
        style.setBorderLeft(BorderStyle.THIN);
        style.setBorderRight(BorderStyle.THIN);
        style.setAlignment(HorizontalAlignment.CENTER);
        return style;
    }

    private CellStyle createMoneyStyle(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        style.setDataFormat(workbook.createDataFormat().getFormat("¥#,##0.00"));
        style.setAlignment(HorizontalAlignment.RIGHT);
        return style;
    }
}
