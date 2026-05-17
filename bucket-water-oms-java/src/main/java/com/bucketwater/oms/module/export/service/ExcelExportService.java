package com.bucketwater.oms.module.export.service;

import com.bucketwater.oms.module.driver.entity.DriverStatement;
import com.bucketwater.oms.module.driver.mapper.DriverStatementMapper;
import com.bucketwater.oms.module.order.entity.Order;
import com.bucketwater.oms.module.order.entity.OrderItem;
import com.bucketwater.oms.module.order.mapper.OrderItemMapper;
import com.bucketwater.oms.module.order.mapper.OrderMapper;
import com.bucketwater.oms.module.product.entity.Product;
import com.bucketwater.oms.module.product.mapper.ProductMapper;
import com.bucketwater.oms.module.statement.entity.MonthlyStatement;
import com.bucketwater.oms.module.statement.mapper.MonthlyStatementMapper;
import com.bucketwater.oms.module.station.entity.Station;
import com.bucketwater.oms.module.station.mapper.StationMapper;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;

import java.util.stream.Collectors;

@Service
public class ExcelExportService {

    private static final Logger log = LoggerFactory.getLogger(ExcelExportService.class);

    @Autowired
    private OrderMapper orderMapper;

    @Autowired
    private OrderItemMapper orderItemMapper;

    @Autowired
    private StationMapper stationMapper;

    @Autowired
    private ProductMapper productMapper;

    @Autowired
    private MonthlyStatementMapper statementMapper;

    @Autowired
    private DriverStatementMapper driverStatementMapper;

    public byte[] exportStatement(Long statementId) {
        MonthlyStatement statement = statementMapper.selectById(statementId);
        if (statement == null) {
            throw new RuntimeException("对账单不存在");
        }

        Station station = stationMapper.selectById(statement.getStationId());

        try (Workbook workbook = new XSSFWorkbook();
             ByteArrayOutputStream out = new ByteArrayOutputStream()) {

            Sheet sheet = workbook.createSheet("对账单");

            CellStyle headerStyle = createHeaderStyle(workbook);
            CellStyle moneyStyle = createMoneyStyle(workbook);
            CellStyle dateStyle = createDateStyle(workbook);

            int rowNum = 0;

            Row titleRow = sheet.createRow(rowNum++);
            Cell titleCell = titleRow.createCell(0);
            titleCell.setCellValue(statement.getYearMonth() + "月对账单");
            titleCell.setCellStyle(headerStyle);
            sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(0, 0, 0, 5));

            rowNum++;

            Row infoRow1 = sheet.createRow(rowNum++);
            infoRow1.createCell(0).setCellValue("水站名称: " + (station != null ? station.getName() : ""));
            infoRow1.createCell(3).setCellValue("账单月份: " + statement.getYearMonth());

            Row infoRow2 = sheet.createRow(rowNum++);
            infoRow2.createCell(0).setCellValue("账期: " + statement.getStartDate() + " 至 " + statement.getEndDate());

            rowNum++;

            Row headerRow = sheet.createRow(rowNum++);
            String[] headers = {"日期", "订单号", "商品明细", "数量", "金额"};
            for (int i = 0; i < headers.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(headers[i]);
                cell.setCellStyle(headerStyle);
            }

            List<Order> orders = orderMapper.selectList(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Order>()
                    .eq(Order::getStationId, statement.getStationId())
                    .ge(Order::getCreateTime, statement.getStartDate().atStartOfDay())
                    .le(Order::getCreateTime, statement.getEndDate().atTime(23, 59, 59))
                    .orderByAsc(Order::getCreateTime)
            );

            BigDecimal totalAmount = BigDecimal.ZERO;
            for (Order order : orders) {
                Row dataRow = sheet.createRow(rowNum++);

                Cell dateCell = dataRow.createCell(0);
                dateCell.setCellValue(order.getCreateTime().toLocalDate().format(DateTimeFormatter.ofPattern("yyyy-MM-dd")));
                dateCell.setCellStyle(dateStyle);

                dataRow.createCell(1).setCellValue(order.getOrderNo());

                List<OrderItem> items = orderItemMapper.selectList(
                    new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<OrderItem>()
                        .eq(OrderItem::getOrderId, order.getId())
                );
                StringBuilder itemDesc = new StringBuilder();
                for (OrderItem item : items) {
                    Product product = productMapper.selectById(item.getProductId());
                    String productName = product != null ? product.getName() : "未知商品";
                    itemDesc.append(productName).append("×").append(item.getQuantity()).append("; ");
                }
                dataRow.createCell(2).setCellValue(itemDesc.toString());

                int totalQty = items.stream().mapToInt(OrderItem::getQuantity).sum();
                dataRow.createCell(3).setCellValue(totalQty);

                Cell amountCell = dataRow.createCell(4);
                amountCell.setCellValue(order.getTotalAmount().doubleValue());
                amountCell.setCellStyle(moneyStyle);

                totalAmount = totalAmount.add(order.getTotalAmount());
            }

            rowNum++;
            Row totalRow = sheet.createRow(rowNum++);
            totalRow.createCell(3).setCellValue("合计:");
            Cell totalCell = totalRow.createCell(4);
            totalCell.setCellValue(totalAmount.doubleValue());
            totalCell.setCellStyle(moneyStyle);

            rowNum++;
            Row balanceRow = sheet.createRow(rowNum++);
            balanceRow.createCell(0).setCellValue("期初余额: " + statement.getOpeningBalance());
            balanceRow.createCell(2).setCellValue("期末余额: " + statement.getClosingBalance());
            balanceRow.createCell(4).setCellValue("本月回款: " + statement.getPaymentReceived());

            for (int i = 0; i < headers.length; i++) {
                sheet.setColumnWidth(i, 4000);
            }

            workbook.write(out);
            return out.toByteArray();

        } catch (IOException e) {
            log.error("导出Excel失败: {}", e.getMessage(), e);
            throw new RuntimeException("导出Excel失败: " + e.getMessage());
        }
    }

    public byte[] exportOrders(List<Long> orderIds, String title) {
        try (Workbook workbook = new XSSFWorkbook();
             ByteArrayOutputStream out = new ByteArrayOutputStream()) {

            Sheet sheet = workbook.createSheet("订单明细");

            CellStyle headerStyle = createHeaderStyle(workbook);
            CellStyle moneyStyle = createMoneyStyle(workbook);

            int rowNum = 0;

            Row titleRow = sheet.createRow(rowNum++);
            Cell titleCell = titleRow.createCell(0);
            titleCell.setCellValue(title != null ? title : "订单明细");
            titleCell.setCellStyle(headerStyle);
            sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(0, 0, 0, 7));

            rowNum++;

            Row headerRow = sheet.createRow(rowNum++);
            String[] headers = {"订单号", "水站", "仓库", "商品", "数量", "金额", "状态", "下单时间"};
            for (int i = 0; i < headers.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(headers[i]);
                cell.setCellStyle(headerStyle);
            }

            for (Long orderId : orderIds) {
                Order order = orderMapper.selectById(orderId);
                if (order == null) continue;

                Station station = stationMapper.selectById(order.getStationId());

                Row dataRow = sheet.createRow(rowNum++);
                dataRow.createCell(0).setCellValue(order.getOrderNo());
                dataRow.createCell(1).setCellValue(station != null ? station.getName() : "");

                List<OrderItem> items = orderItemMapper.selectList(
                    new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<OrderItem>()
                        .eq(OrderItem::getOrderId, order.getId())
                );
                StringBuilder itemDesc = new StringBuilder();
                int totalQty = 0;
                for (OrderItem item : items) {
                    Product product = productMapper.selectById(item.getProductId());
                    itemDesc.append(product != null ? product.getName() : "未知").append("×").append(item.getQuantity()).append("; ");
                    totalQty += item.getQuantity();
                }
                dataRow.createCell(3).setCellValue(itemDesc.toString());
                dataRow.createCell(4).setCellValue(totalQty);

                Cell amountCell = dataRow.createCell(5);
                amountCell.setCellValue(order.getTotalAmount().doubleValue());
                amountCell.setCellStyle(moneyStyle);

                dataRow.createCell(6).setCellValue(order.getStatus());
                dataRow.createCell(7).setCellValue(order.getCreateTime().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")));
            }

            for (int i = 0; i < headers.length; i++) {
                sheet.setColumnWidth(i, 4000);
            }

            workbook.write(out);
            return out.toByteArray();

        } catch (IOException e) {
            log.error("导出Excel失败: {}", e.getMessage(), e);
            throw new RuntimeException("导出Excel失败: " + e.getMessage());
        }
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

    private CellStyle createDateStyle(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        style.setDataFormat(workbook.createDataFormat().getFormat("yyyy-mm-dd"));
        style.setAlignment(HorizontalAlignment.CENTER);
        return style;
    }

    public byte[] exportProducts(String category, String status, String keyword) {
        try (Workbook workbook = new XSSFWorkbook();
             ByteArrayOutputStream out = new ByteArrayOutputStream()) {

            Sheet sheet = workbook.createSheet("产品列表");

            CellStyle headerStyle = createHeaderStyle(workbook);
            CellStyle moneyStyle = createMoneyStyle(workbook);

            int rowNum = 0;

            Row titleRow = sheet.createRow(rowNum++);
            Cell titleCell = titleRow.createCell(0);
            titleCell.setCellValue("产品列表");
            titleCell.setCellStyle(headerStyle);
            sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(0, 0, 0, 6));

            rowNum++;

            Row headerRow = sheet.createRow(rowNum++);
            String[] headers = {"编号", "产品名称", "分类", "规格", "单价(元)", "状态"};
            for (int i = 0; i < headers.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(headers[i]);
                cell.setCellStyle(headerStyle);
            }

            com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Product> wrapper =
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<>();

            if (category != null && !category.isEmpty()) {
                wrapper.eq(Product::getCategory, category);
            }
            if (status != null && !status.isEmpty()) {
                wrapper.eq(Product::getStatus, status);
            }
            if (keyword != null && !keyword.isEmpty()) {
                wrapper.like(Product::getName, keyword);
            }

            wrapper.orderByAsc(Product::getCategory, Product::getName);

            List<Product> products = productMapper.selectList(wrapper);

            for (Product product : products) {
                Row dataRow = sheet.createRow(rowNum++);
                dataRow.createCell(0).setCellValue(product.getId() != null ? product.getId().toString() : "");
                dataRow.createCell(1).setCellValue(product.getName() != null ? product.getName() : "");
                dataRow.createCell(2).setCellValue(product.getCategory() != null ? product.getCategory() : "");
                dataRow.createCell(3).setCellValue(product.getSpec() != null ? product.getSpec() : "");
                
                Cell priceCell = dataRow.createCell(4);
                if (product.getPrice() != null) {
                    priceCell.setCellValue(product.getPrice().doubleValue());
                    priceCell.setCellStyle(moneyStyle);
                } else {
                    priceCell.setCellValue(0);
                }
                
                String statusText = "active".equals(product.getStatus()) ? "启用" : "停用";
                dataRow.createCell(5).setCellValue(statusText);
            }

            for (int i = 0; i < headers.length; i++) {
                sheet.setColumnWidth(i, 4000);
            }

            workbook.write(out);
            return out.toByteArray();

        } catch (IOException e) {
            log.error("导出产品Excel失败: {}", e.getMessage(), e);
            throw new RuntimeException("导出产品Excel失败: " + e.getMessage());
        }
    }

    public byte[] exportDriverStatement(Long statementId) {
        DriverStatement statement = driverStatementMapper.selectById(statementId);
        if (statement == null) {
            throw new RuntimeException("司机对账单不存在");
        }

        try (Workbook workbook = new XSSFWorkbook();
             ByteArrayOutputStream out = new ByteArrayOutputStream()) {

            Sheet sheet = workbook.createSheet("司机对账单");

            CellStyle headerStyle = createHeaderStyle(workbook);
            CellStyle moneyStyle = createMoneyStyle(workbook);

            int rowNum = 0;

            Row titleRow = sheet.createRow(rowNum++);
            Cell titleCell = titleRow.createCell(0);
            titleCell.setCellValue("司机配送对账单");
            titleCell.setCellStyle(headerStyle);
            sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(0, 0, 0, 6));

            rowNum++;

            Row infoRow1 = sheet.createRow(rowNum++);
            infoRow1.createCell(0).setCellValue("对账单号: " + statement.getStatementNo());
            infoRow1.createCell(3).setCellValue("司机ID: " + statement.getDriverId());

            Row infoRow2 = sheet.createRow(rowNum++);
            infoRow2.createCell(0).setCellValue("账期: " + statement.getStartDate() + " 至 " + statement.getEndDate());

            Row infoRow3 = sheet.createRow(rowNum++);
            infoRow3.createCell(0).setCellValue("生成时间: " + statement.getCreatedAt());

            rowNum++;

            Row statsRow = sheet.createRow(rowNum++);
            statsRow.createCell(0).setCellValue("配送单数: " + statement.getTotalOrders());
            statsRow.createCell(2).setCellValue("总桶数: " + statement.getTotalBuckets());

            rowNum++;

            Row headerRow = sheet.createRow(rowNum++);
            String[] headers = {"项目", "金额/数量"};
            for (int i = 0; i < headers.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(headers[i]);
                cell.setCellStyle(headerStyle);
            }

            Row dataRow1 = sheet.createRow(rowNum++);
            dataRow1.createCell(0).setCellValue("配送总金额");
            Cell amountCell1 = dataRow1.createCell(1);
            amountCell1.setCellValue(statement.getTotalAmount() != null ? statement.getTotalAmount().doubleValue() : 0);
            amountCell1.setCellStyle(moneyStyle);

            Row dataRow2 = sheet.createRow(rowNum++);
            dataRow2.createCell(0).setCellValue("提成比例");
            dataRow2.createCell(1).setCellValue((statement.getCommissionRate() != null ? statement.getCommissionRate() : BigDecimal.ZERO) + "%");

            Row dataRow3 = sheet.createRow(rowNum++);
            dataRow3.createCell(0).setCellValue("配送提成");
            Cell amountCell3 = dataRow3.createCell(1);
            amountCell3.setCellValue(statement.getDeliveryCommission() != null ? statement.getDeliveryCommission().doubleValue() : 0);
            amountCell3.setCellStyle(moneyStyle);

            Row dataRow4 = sheet.createRow(rowNum++);
            dataRow4.createCell(0).setCellValue("总里程(KM)");
            dataRow4.createCell(1).setCellValue(statement.getTotalDistance() != null ? statement.getTotalDistance().doubleValue() : 0);

            Row dataRow5 = sheet.createRow(rowNum++);
            dataRow5.createCell(0).setCellValue("里程补助");
            Cell amountCell5 = dataRow5.createCell(1);
            amountCell5.setCellValue(statement.getMileageSubsidy() != null ? statement.getMileageSubsidy().doubleValue() : 0);
            amountCell5.setCellStyle(moneyStyle);

            rowNum++;

            Row totalRow = sheet.createRow(rowNum++);
            totalRow.createCell(0).setCellValue("实际应发金额:");
            Cell totalCell = totalRow.createCell(1);
            totalCell.setCellValue(statement.getActualAmount() != null ? statement.getActualAmount().doubleValue() : 0);
            totalCell.setCellStyle(moneyStyle);

            rowNum++;

            Row statusRow = sheet.createRow(rowNum++);
            statusRow.createCell(0).setCellValue("账单状态: " + getStatementStatusText(statement.getStatus()));
            if ("confirmed".equals(statement.getStatus()) && statement.getConfirmedAt() != null) {
                statusRow.createCell(2).setCellValue("确认时间: " + statement.getConfirmedAt());
            }

            for (int i = 0; i < headers.length; i++) {
                sheet.setColumnWidth(i, 5000);
            }
            sheet.setColumnWidth(0, 8000);

            workbook.write(out);
            return out.toByteArray();

        } catch (IOException e) {
            log.error("导出司机对账单Excel失败: {}", e.getMessage(), e);
            throw new RuntimeException("导出司机对账单Excel失败: " + e.getMessage());
        }
    }

    private String getStatementStatusText(String status) {
        if (status == null) {
            return "";
        }
        return switch (status) {
            case "pending" -> "待确认";
            case "confirmed" -> "已确认";
            case "paid" -> "已支付";
            default -> status;
        };
    }

    public byte[] exportSalesReport(String startDate, String endDate) {
        try (Workbook workbook = new XSSFWorkbook();
             ByteArrayOutputStream out = new ByteArrayOutputStream()) {

            Sheet sheet = workbook.createSheet("销售统计报表");

            CellStyle headerStyle = createHeaderStyle(workbook);
            CellStyle moneyStyle = createMoneyStyle(workbook);

            int rowNum = 0;

            Row titleRow = sheet.createRow(rowNum++);
            Cell titleCell = titleRow.createCell(0);
            titleCell.setCellValue("销售统计报表");
            titleCell.setCellStyle(headerStyle);
            sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(0, 0, 0, 5));

            if (startDate != null && endDate != null) {
                Row dateRow = sheet.createRow(rowNum++);
                dateRow.createCell(0).setCellValue("统计周期: " + startDate + " 至 " + endDate);
            }

            rowNum++;

            Row headerRow = sheet.createRow(rowNum++);
            String[] headers = {"日期", "订单数", "总金额(元)", "商品数量", "客单价(元)"};
            for (int i = 0; i < headers.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(headers[i]);
                cell.setCellStyle(headerStyle);
            }

            rowNum++;

            for (int i = 0; i < headers.length; i++) {
                sheet.setColumnWidth(i, 4000);
            }

            workbook.write(out);
            return out.toByteArray();

        } catch (IOException e) {
            log.error("导出销售统计报表Excel失败: {}", e.getMessage(), e);
            throw new RuntimeException("导出销售统计报表Excel失败: " + e.getMessage());
        }
    }

    public byte[] exportStationPurchaseReport(String startDate, String endDate, Long stationId) {
        try (Workbook workbook = new XSSFWorkbook();
             ByteArrayOutputStream out = new ByteArrayOutputStream()) {

            Sheet sheet = workbook.createSheet("水站进货报表");

            CellStyle headerStyle = createHeaderStyle(workbook);
            CellStyle moneyStyle = createMoneyStyle(workbook);

            int rowNum = 0;

            Row titleRow = sheet.createRow(rowNum++);
            Cell titleCell = titleRow.createCell(0);
            titleCell.setCellValue("水站进货统计报表");
            titleCell.setCellStyle(headerStyle);
            sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(0, 0, 0, 6));

            if (stationId != null) {
                Row stationRow = sheet.createRow(rowNum++);
                stationRow.createCell(0).setCellValue("水站ID: " + stationId);
            }

            rowNum++;

            Row headerRow = sheet.createRow(rowNum++);
            String[] headers = {"水站名称", "订单数", "总桶数", "总金额(元)", "实付金额(元)", "优惠金额(元)"};
            for (int i = 0; i < headers.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(headers[i]);
                cell.setCellStyle(headerStyle);
            }

            rowNum++;

            for (int i = 0; i < headers.length; i++) {
                sheet.setColumnWidth(i, 4500);
            }

            workbook.write(out);
            return out.toByteArray();

        } catch (IOException e) {
            log.error("导出水站进货报表Excel失败: {}", e.getMessage(), e);
            throw new RuntimeException("导出水站进货报表Excel失败: " + e.getMessage());
        }
    }

    public byte[] exportDriverDeliveryReport(String startDate, String endDate, Long driverId) {
        try (Workbook workbook = new XSSFWorkbook();
             ByteArrayOutputStream out = new ByteArrayOutputStream()) {

            Sheet sheet = workbook.createSheet("司机配送报表");

            CellStyle headerStyle = createHeaderStyle(workbook);
            CellStyle moneyStyle = createMoneyStyle(workbook);

            int rowNum = 0;

            Row titleRow = sheet.createRow(rowNum++);
            Cell titleCell = titleRow.createCell(0);
            titleCell.setCellValue("司机配送统计报表");
            titleCell.setCellStyle(headerStyle);
            sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(0, 0, 0, 7));

            if (driverId != null) {
                Row driverRow = sheet.createRow(rowNum++);
                driverRow.createCell(0).setCellValue("司机ID: " + driverId);
            }

            rowNum++;

            Row headerRow = sheet.createRow(rowNum++);
            String[] headers = {"司机姓名", "配送单数", "配送桶数", "配送里程(KM)", "配送金额(元)", "提成金额(元)", "里程补助(元)"};
            for (int i = 0; i < headers.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(headers[i]);
                cell.setCellStyle(headerStyle);
            }

            rowNum++;

            for (int i = 0; i < headers.length; i++) {
                sheet.setColumnWidth(i, 4500);
            }

            workbook.write(out);
            return out.toByteArray();

        } catch (IOException e) {
            log.error("导出司机配送报表Excel失败: {}", e.getMessage(), e);
            throw new RuntimeException("导出司机配送报表Excel失败: " + e.getMessage());
        }
    }
}
