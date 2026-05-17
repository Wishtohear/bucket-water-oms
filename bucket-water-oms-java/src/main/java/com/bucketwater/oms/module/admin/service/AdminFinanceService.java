package com.bucketwater.oms.module.admin.service;

import com.bucketwater.oms.common.enums.StatementStatus;
import com.bucketwater.oms.common.exception.BusinessException;
import com.bucketwater.oms.common.response.ResultCode;
import com.bucketwater.oms.module.admin.dto.FinanceOverviewDTO;
import com.bucketwater.oms.module.order.entity.Order;
import com.bucketwater.oms.module.order.mapper.OrderMapper;
import com.bucketwater.oms.module.station.entity.Station;
import com.bucketwater.oms.module.station.entity.StationAccount;
import com.bucketwater.oms.module.station.mapper.StationAccountMapper;
import com.bucketwater.oms.module.station.mapper.StationMapper;
import com.bucketwater.oms.module.statement.entity.MonthlyStatement;
import com.bucketwater.oms.module.statement.mapper.MonthlyStatementMapper;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.apache.poi.ss.util.CellRangeAddress;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
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
public class AdminFinanceService {

    @Autowired
    private OrderMapper orderMapper;

    @Autowired
    private MonthlyStatementMapper statementMapper;

    @Autowired
    private StationAccountMapper accountMapper;

    @Autowired
    private StationMapper stationMapper;

    public FinanceOverviewDTO getFinanceOverview() {
        FinanceOverviewDTO overview = new FinanceOverviewDTO();
        
        LocalDateTime monthStart = YearMonth.now().atDay(1).atStartOfDay();
        LocalDateTime monthEnd = LocalDateTime.now();
        
        BigDecimal totalReceivable = BigDecimal.ZERO;
        BigDecimal totalCollected = BigDecimal.ZERO;
        int disputeCount = 0;
        BigDecimal totalArrears = BigDecimal.ZERO;
        int arrearsStations = 0;
        
        LambdaQueryWrapper<Order> orderQuery = new LambdaQueryWrapper<>();
        orderQuery.ge(Order::getCreateTime, monthStart);
        orderQuery.le(Order::getCreateTime, monthEnd);
        orderQuery.eq(Order::getStatus, "completed");
        List<Order> monthOrders = orderMapper.selectList(orderQuery);
        
        for (Order order : monthOrders) {
            if (order.getTotalAmount() != null) {
                totalReceivable = totalReceivable.add(order.getTotalAmount());
            }
        }
        
        List<MonthlyStatement> statements = statementMapper.selectList(
            new LambdaQueryWrapper<MonthlyStatement>()
                .orderByDesc(MonthlyStatement::getGeneratedAt)
                .last("LIMIT 20")
        );
        
        for (MonthlyStatement statement : statements) {
            totalCollected = totalCollected.add(statement.getPaymentReceived() != null ? statement.getPaymentReceived() : BigDecimal.ZERO);
            
            if (StatementStatus.DISPUTED.name().equals(statement.getStatus())) {
                disputeCount++;
            }
            
            BigDecimal closingBalance = statement.getClosingBalance();
            if (closingBalance != null && closingBalance.compareTo(BigDecimal.ZERO) > 0) {
                totalArrears = totalArrears.add(closingBalance);
                arrearsStations++;
            }
        }
        
        overview.setMonthTotalReceivable(totalReceivable);
        overview.setReceivableGrowthRate(15.0);
        
        overview.setMonthCollected(totalCollected);
        if (totalReceivable.compareTo(BigDecimal.ZERO) > 0) {
            double collectionRate = totalCollected
                .divide(totalReceivable, 4, RoundingMode.HALF_UP)
                .multiply(new BigDecimal("100"))
                .doubleValue();
            overview.setCollectionRate(collectionRate);
        } else {
            overview.setCollectionRate(0.0);
        }
        
        overview.setPendingDisputes(disputeCount);
        overview.setTotalArrears(totalArrears);
        overview.setArrearsStations(arrearsStations);
        
        List<FinanceOverviewDTO.StatementItem> recentStatements = statements.stream()
            .limit(10)
            .map(s -> {
                FinanceOverviewDTO.StatementItem item = new FinanceOverviewDTO.StatementItem();
                item.setStatementId(s.getId().toString());
                item.setPeriod(s.getStartDate() + " ~ " + s.getEndDate());
                item.setStationName(getStationName(s.getStationId()));
                item.setTransactionAmount(s.getTotalAmount());
                item.setCurrentBalance(s.getClosingBalance());
                item.setStatus(s.getStatus());
                item.setStatusText(getStatusText(s.getStatus()));
                return item;
            })
            .collect(Collectors.toList());
        
        overview.setRecentStatements(recentStatements);
        
        return overview;
    }

    private String getStationName(Object stationId) {
        if (stationId == null) return "";
        if (stationId instanceof Long) {
            return getStationNameById((Long) stationId);
        }
        try {
            return getStationNameById(Long.parseLong(stationId.toString()));
        } catch (Exception e) {
            return "";
        }
    }

    private String getStatusText(String status) {
        if (status == null) return "未知";
        return switch (status) {
            case "pending" -> "待确认";
            case "confirmed" -> "已确认";
            case "disputed" -> "有争议";
            default -> status;
        };
    }

    private String getPaymentTypeForStation(Object stationId) {
        if (stationId == null) return "monthly";
        LambdaQueryWrapper<StationAccount> query = new LambdaQueryWrapper<>();
        query.eq(StationAccount::getStationId, (Long) stationId);
        StationAccount account = accountMapper.selectOne(query);
        return account != null && account.getPaymentType() != null ? account.getPaymentType() : "monthly";
    }

    public List<MonthlyStatement> getStatements(String yearMonth, String stationName, String status) {
        LambdaQueryWrapper<MonthlyStatement> query = new LambdaQueryWrapper<>();
        
        if (yearMonth != null && !yearMonth.isEmpty()) {
            query.eq(MonthlyStatement::getYearMonth, yearMonth);
        }
        
        if (status != null && !status.isEmpty()) {
            query.eq(MonthlyStatement::getStatus, status);
        }
        
        query.orderByDesc(MonthlyStatement::getGeneratedAt);
        
        return statementMapper.selectList(query);
    }

    public void confirmStatement(String statementId) {
        MonthlyStatement statement = statementMapper.selectById(statementId);
        if (statement != null) {
            statement.setStatus(StatementStatus.CONFIRMED.name());
            statement.setConfirmedAt(LocalDateTime.now());
            statementMapper.updateById(statement);
        }
    }

    public void handleDispute(String statementId, String resolution) {
        MonthlyStatement statement = statementMapper.selectById(statementId);
        if (statement != null) {
            statement.setStatus(StatementStatus.CONFIRMED.name());
            statement.setConfirmedAt(LocalDateTime.now());
            statementMapper.updateById(statement);
        }
    }

    public MonthlyStatement getStatementById(String statementId) {
        MonthlyStatement statement = statementMapper.selectById(statementId);
        if (statement == null) {
            throw new BusinessException(ResultCode.DATA_NOT_FOUND, "对账单不存在");
        }
        return statement;
    }

    public List<Map<String, Object>> getReceivables(Long stationId, String startDate, String endDate) {
        List<Map<String, Object>> receivables = new ArrayList<>();

        LambdaQueryWrapper<MonthlyStatement> query = new LambdaQueryWrapper<>();

        if (stationId != null) {
            query.eq(MonthlyStatement::getStationId, stationId);
        }

        if (startDate != null && !startDate.isEmpty()) {
            query.ge(MonthlyStatement::getStartDate, java.time.LocalDate.parse(startDate));
        }

        if (endDate != null && !endDate.isEmpty()) {
            query.le(MonthlyStatement::getEndDate, java.time.LocalDate.parse(endDate));
        }

        List<MonthlyStatement> statements = statementMapper.selectList(query);

        for (MonthlyStatement statement : statements) {
            Map<String, Object> item = new HashMap<>();
            item.put("stationId", statement.getStationId());
            item.put("stationName", getStationName(statement.getStationId()));
            item.put("periodStart", statement.getStartDate());
            item.put("periodEnd", statement.getEndDate());
            item.put("amount", statement.getTotalAmount());
            item.put("totalAmount", statement.getTotalAmount());
            item.put("paidAmount", statement.getPaymentReceived());
            item.put("unpaidAmount", statement.getClosingBalance());
            item.put("status", statement.getStatus());
            item.put("statementId", statement.getId().toString());
            item.put("paymentType", getPaymentTypeForStation(statement.getStationId()));
            receivables.add(item);
        }

        return receivables;
    }

    public List<Map<String, Object>> getPredeposits(Long stationId) {
        List<Map<String, Object>> predeposits = new ArrayList<>();

        LambdaQueryWrapper<StationAccount> query = new LambdaQueryWrapper<>();

        if (stationId != null) {
            query.eq(StationAccount::getStationId, stationId);
        }

        List<StationAccount> accounts = accountMapper.selectList(query);

        for (StationAccount account : accounts) {
            Map<String, Object> item = new HashMap<>();
            item.put("accountId", account.getId());
            item.put("stationId", account.getStationId());
            item.put("stationName", getStationName(account.getStationId()));
            item.put("balance", account.getDepositBalance());
            item.put("depositBalance", account.getDepositBalance());
            item.put("creditLimit", account.getCreditLimit());
            item.put("creditUsed", account.getCreditUsed());
            item.put("creditAvailable", account.getCreditAvailable());
            item.put("paymentType", account.getPaymentType());
            item.put("updatedAt", account.getUpdatedAt());
            item.put("createTime", account.getUpdatedAt());
            predeposits.add(item);
        }

        return predeposits;
    }

    public Map<String, Object> getFinanceSummary() {
        Map<String, Object> summary = new HashMap<>();

        LocalDateTime monthStart = YearMonth.now().atDay(1).atStartOfDay();
        LocalDateTime monthEnd = LocalDateTime.now();

        BigDecimal totalReceivable = BigDecimal.ZERO;
        BigDecimal totalPaid = BigDecimal.ZERO;
        BigDecimal totalUnpaid = BigDecimal.ZERO;

        List<MonthlyStatement> allStatements = statementMapper.selectList(
            new LambdaQueryWrapper<MonthlyStatement>()
        );

        for (MonthlyStatement statement : allStatements) {
            if (statement.getTotalAmount() != null) {
                totalReceivable = totalReceivable.add(statement.getTotalAmount());
            }
            if (statement.getPaymentReceived() != null) {
                totalPaid = totalPaid.add(statement.getPaymentReceived());
            }
            if (statement.getClosingBalance() != null) {
                totalUnpaid = totalUnpaid.add(statement.getClosingBalance());
            }
        }

        LambdaQueryWrapper<Order> orderQuery = new LambdaQueryWrapper<>();
        orderQuery.ge(Order::getCreateTime, monthStart);
        orderQuery.le(Order::getCreateTime, monthEnd);
        orderQuery.eq(Order::getStatus, "completed");
        List<Order> monthOrders = orderMapper.selectList(orderQuery);

        BigDecimal monthTotal = BigDecimal.ZERO;
        for (Order order : monthOrders) {
            if (order.getTotalAmount() != null) {
                monthTotal = monthTotal.add(order.getTotalAmount());
            }
        }

        summary.put("totalReceivable", totalReceivable.add(monthTotal));
        summary.put("totalPaid", totalPaid);
        summary.put("totalUnpaid", totalUnpaid);

        summary.put("monthTotalReceivable", monthTotal);

        YearMonth currentMonth = YearMonth.now();
        summary.put("periodStart", currentMonth.atDay(1).toString());
        summary.put("periodEnd", currentMonth.atEndOfMonth().toString());

        long totalStationsCount = stationMapper.selectCount(null);
        summary.put("totalStations", totalStationsCount);

        BigDecimal overdueAmount = BigDecimal.ZERO;
        LocalDate threshold = LocalDate.now().minusDays(30);
        for (MonthlyStatement statement : allStatements) {
            if (statement.getClosingBalance() != null
                && statement.getClosingBalance().compareTo(BigDecimal.ZERO) > 0
                && statement.getEndDate() != null
                && statement.getEndDate().isBefore(threshold)) {
                overdueAmount = overdueAmount.add(statement.getClosingBalance());
            }
        }
        summary.put("overdueAmount", overdueAmount);

        return summary;
    }

    public String getStationNameById(Long stationId) {
        if (stationId == null) return "";
        Station station = stationMapper.selectById(stationId);
        return station != null ? station.getName() : "";
    }

    public byte[] exportReceivables(Long stationId, String startDate, String endDate) {
        try (Workbook workbook = new XSSFWorkbook();
             ByteArrayOutputStream out = new ByteArrayOutputStream()) {

            Sheet sheet = workbook.createSheet("应收款报表");

            CellStyle headerStyle = createHeaderStyle(workbook);
            CellStyle moneyStyle = createMoneyStyle(workbook);

            int rowNum = 0;
            Row titleRow = sheet.createRow(rowNum++);
            Cell titleCell = titleRow.createCell(0);
            titleCell.setCellValue("应收款报表");
            titleCell.setCellStyle(headerStyle);
            sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, 5));

            rowNum++;
            Row infoRow = sheet.createRow(rowNum++);
            if (startDate != null && !startDate.isEmpty()) {
                infoRow.createCell(0).setCellValue("日期范围: " + startDate + " 至 " + (endDate != null ? endDate : "至今"));
            } else {
                infoRow.createCell(0).setCellValue("日期范围: 全部");
            }

            rowNum++;
            Row headerRow = sheet.createRow(rowNum++);
            String[] headers = {"水站名称", "账期开始", "账期结束", "应收金额", "已收金额", "未收金额", "状态"};
            for (int i = 0; i < headers.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(headers[i]);
                cell.setCellStyle(headerStyle);
            }

            LambdaQueryWrapper<MonthlyStatement> query = new LambdaQueryWrapper<>();
            if (stationId != null) {
                query.eq(MonthlyStatement::getStationId, stationId);
            }
            if (startDate != null && !startDate.isEmpty()) {
                query.ge(MonthlyStatement::getStartDate, LocalDate.parse(startDate));
            }
            if (endDate != null && !endDate.isEmpty()) {
                query.le(MonthlyStatement::getEndDate, LocalDate.parse(endDate));
            }
            query.orderByDesc(MonthlyStatement::getGeneratedAt);

            List<MonthlyStatement> statements = statementMapper.selectList(query);
            BigDecimal totalReceivable = BigDecimal.ZERO;
            BigDecimal totalPaid = BigDecimal.ZERO;
            BigDecimal totalUnpaid = BigDecimal.ZERO;

            for (MonthlyStatement statement : statements) {
                Row dataRow = sheet.createRow(rowNum++);
                dataRow.createCell(0).setCellValue(getStationNameById(statement.getStationId()));
                dataRow.createCell(1).setCellValue(statement.getStartDate() != null ? statement.getStartDate().toString() : "");
                dataRow.createCell(2).setCellValue(statement.getEndDate() != null ? statement.getEndDate().toString() : "");

                Cell receivableCell = dataRow.createCell(3);
                receivableCell.setCellValue(statement.getTotalAmount() != null ? statement.getTotalAmount().doubleValue() : 0);
                receivableCell.setCellStyle(moneyStyle);

                Cell paidCell = dataRow.createCell(4);
                paidCell.setCellValue(statement.getPaymentReceived() != null ? statement.getPaymentReceived().doubleValue() : 0);
                paidCell.setCellStyle(moneyStyle);

                Cell unpaidCell = dataRow.createCell(5);
                unpaidCell.setCellValue(statement.getClosingBalance() != null ? statement.getClosingBalance().doubleValue() : 0);
                unpaidCell.setCellStyle(moneyStyle);

                dataRow.createCell(6).setCellValue(getStatusText(statement.getStatus()));

                if (statement.getTotalAmount() != null) totalReceivable = totalReceivable.add(statement.getTotalAmount());
                if (statement.getPaymentReceived() != null) totalPaid = totalPaid.add(statement.getPaymentReceived());
                if (statement.getClosingBalance() != null) totalUnpaid = totalUnpaid.add(statement.getClosingBalance());
            }

            rowNum++;
            Row totalRow = sheet.createRow(rowNum++);
            totalRow.createCell(2).setCellValue("合计:");
            Cell totalReceivableCell = totalRow.createCell(3);
            totalReceivableCell.setCellValue(totalReceivable.doubleValue());
            totalReceivableCell.setCellStyle(moneyStyle);
            Cell totalPaidCell = totalRow.createCell(4);
            totalPaidCell.setCellValue(totalPaid.doubleValue());
            totalPaidCell.setCellStyle(moneyStyle);
            Cell totalUnpaidCell = totalRow.createCell(5);
            totalUnpaidCell.setCellValue(totalUnpaid.doubleValue());
            totalUnpaidCell.setCellStyle(moneyStyle);

            for (int i = 0; i < headers.length; i++) {
                sheet.setColumnWidth(i, 4000);
            }

            workbook.write(out);
            return out.toByteArray();

        } catch (IOException e) {
            throw new RuntimeException("导出应收款报表失败: " + e.getMessage());
        }
    }

    public byte[] exportPredeposits(Long stationId) {
        try (Workbook workbook = new XSSFWorkbook();
             ByteArrayOutputStream out = new ByteArrayOutputStream()) {

            Sheet sheet = workbook.createSheet("预存款报表");

            CellStyle headerStyle = createHeaderStyle(workbook);
            CellStyle moneyStyle = createMoneyStyle(workbook);

            int rowNum = 0;
            Row titleRow = sheet.createRow(rowNum++);
            Cell titleCell = titleRow.createCell(0);
            titleCell.setCellValue("预存款报表");
            titleCell.setCellStyle(headerStyle);
            sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, 5));

            rowNum++;
            Row headerRow = sheet.createRow(rowNum++);
            String[] headers = {"水站名称", "预存余额", "信用额度", "已用额度", "可用额度", "账期类型"};
            for (int i = 0; i < headers.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(headers[i]);
                cell.setCellStyle(headerStyle);
            }

            LambdaQueryWrapper<StationAccount> query = new LambdaQueryWrapper<>();
            if (stationId != null) {
                query.eq(StationAccount::getStationId, stationId);
            }
            List<StationAccount> accounts = accountMapper.selectList(query);

            BigDecimal totalDeposit = BigDecimal.ZERO;
            BigDecimal totalCredit = BigDecimal.ZERO;
            BigDecimal totalUsed = BigDecimal.ZERO;

            for (StationAccount account : accounts) {
                Row dataRow = sheet.createRow(rowNum++);
                dataRow.createCell(0).setCellValue(getStationNameById(account.getStationId()));

                Cell depositCell = dataRow.createCell(1);
                depositCell.setCellValue(account.getDepositBalance() != null ? account.getDepositBalance().doubleValue() : 0);
                depositCell.setCellStyle(moneyStyle);

                Cell creditCell = dataRow.createCell(2);
                creditCell.setCellValue(account.getCreditLimit() != null ? account.getCreditLimit().doubleValue() : 0);
                creditCell.setCellStyle(moneyStyle);

                Cell usedCell = dataRow.createCell(3);
                usedCell.setCellValue(account.getCreditUsed() != null ? account.getCreditUsed().doubleValue() : 0);
                usedCell.setCellStyle(moneyStyle);

                Cell availableCell = dataRow.createCell(4);
                availableCell.setCellValue(account.getCreditAvailable() != null ? account.getCreditAvailable().doubleValue() : 0);
                availableCell.setCellStyle(moneyStyle);

                String paymentType = "月结";
                if ("immediate".equals(account.getPaymentType())) {
                    paymentType = "现结";
                } else if ("quarterly".equals(account.getPaymentType())) {
                    paymentType = "季结";
                }
                dataRow.createCell(5).setCellValue(paymentType);

                if (account.getDepositBalance() != null) totalDeposit = totalDeposit.add(account.getDepositBalance());
                if (account.getCreditLimit() != null) totalCredit = totalCredit.add(account.getCreditLimit());
                if (account.getCreditUsed() != null) totalUsed = totalUsed.add(account.getCreditUsed());
            }

            rowNum++;
            Row totalRow = sheet.createRow(rowNum++);
            totalRow.createCell(0).setCellValue("合计:");
            Cell totalDepositCell = totalRow.createCell(1);
            totalDepositCell.setCellValue(totalDeposit.doubleValue());
            totalDepositCell.setCellStyle(moneyStyle);
            Cell totalCreditCell = totalRow.createCell(2);
            totalCreditCell.setCellValue(totalCredit.doubleValue());
            totalCreditCell.setCellStyle(moneyStyle);
            Cell totalUsedCell = totalRow.createCell(3);
            totalUsedCell.setCellValue(totalUsed.doubleValue());
            totalUsedCell.setCellStyle(moneyStyle);

            for (int i = 0; i < headers.length; i++) {
                sheet.setColumnWidth(i, 4000);
            }

            workbook.write(out);
            return out.toByteArray();

        } catch (IOException e) {
            throw new RuntimeException("导出预存款报表失败: " + e.getMessage());
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
}
