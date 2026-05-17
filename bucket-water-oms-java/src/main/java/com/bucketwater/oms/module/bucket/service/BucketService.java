package com.bucketwater.oms.module.bucket.service;

import com.bucketwater.oms.module.bucket.dto.BucketSummaryDTO;
import com.bucketwater.oms.module.bucket.dto.BucketTransactionDTO;
import com.bucketwater.oms.module.bucket.entity.BucketTransaction;
import com.bucketwater.oms.module.bucket.mapper.BucketTransactionMapper;
import com.bucketwater.oms.module.station.entity.StationAccount;
import com.bucketwater.oms.module.station.mapper.StationAccountMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.util.ArrayList;
import java.util.List;


@Service
public class BucketService {

    @Autowired
    private BucketTransactionMapper bucketTransactionMapper;

    @Autowired
    private StationAccountMapper stationAccountMapper;

    public BucketTransactionDTO getTransactions(Long stationId, String startDate, String endDate) {
        StationAccount account = stationAccountMapper.selectOne(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<StationAccount>()
                .eq(StationAccount::getStationId, stationId)
        );

        com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<BucketTransaction> wrapper =
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<BucketTransaction>()
                .eq(BucketTransaction::getStationId, stationId)
                .orderByDesc(BucketTransaction::getCreatedAt)
                .last("LIMIT 50");

        if (startDate != null && !startDate.isEmpty()) {
            wrapper.ge(BucketTransaction::getCreatedAt, startDate + " 00:00:00");
        }
        if (endDate != null && !endDate.isEmpty()) {
            wrapper.le(BucketTransaction::getCreatedAt, endDate + " 23:59:59");
        }

        List<BucketTransaction> transactions = bucketTransactionMapper.selectList(wrapper);

        List<BucketTransactionDTO.TransactionItem> items = new ArrayList<>();
        for (BucketTransaction trans : transactions) {
            items.add(new BucketTransactionDTO.TransactionItem(
                trans.getId().toString(),
                trans.getType(),
                getTypeText(trans.getType()),
                trans.getQuantity(),
                trans.getBalance(),
                trans.getOrderId() != null ? trans.getOrderId().toString() : null,
                trans.getDriverId() != null ? trans.getDriverId().toString() : null,
                trans.getCreatedAt()
            ));
        }

        int totalOwed = account != null ? account.getOwedBucketNum() : 0;
        int threshold = account != null ? account.getOwedThreshold() : 10;
        java.math.BigDecimal depositPerUnit = account != null && account.getBucketDepositPerUnit() != null
            ? account.getBucketDepositPerUnit() : new java.math.BigDecimal("30");
        int depositBuckets = account != null ? account.getDepositBucketNum() : 0;
        int refundableBuckets = depositBuckets - totalOwed;
        java.math.BigDecimal refundableDeposit = depositPerUnit.multiply(new java.math.BigDecimal(Math.max(0, refundableBuckets)));

        int monthlyReturn = calculateMonthlyTotal(transactions, "return");
        int monthlyOwed = calculateMonthlyTotal(transactions, "owed");

        return new BucketTransactionDTO(
            totalOwed,
            threshold,
            depositPerUnit,
            depositPerUnit.multiply(new java.math.BigDecimal(totalOwed)),
            depositBuckets,
            refundableDeposit,
            totalOwed >= threshold,
            monthlyReturn,
            monthlyOwed,
            items
        );
    }

    private int calculateMonthlyTotal(List<BucketTransaction> transactions, String type) {
        return transactions.stream()
            .filter(t -> type.equals(t.getType()))
            .mapToInt(t -> Math.abs(t.getQuantity()))
            .sum();
    }

    private String getTypeText(String type) {
        return switch (type) {
            case "deposit" -> "押金收取";
            case "return" -> "回桶";
            case "owed" -> "欠桶";
            case "pay" -> "补缴押金";
            case "compensation" -> "差异赔偿";
            default -> type;
        };
    }

    public BucketSummaryDTO getBucketSummary(Long stationId) {
        StationAccount account = stationAccountMapper.selectOne(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<StationAccount>()
                .eq(StationAccount::getStationId, stationId)
        );

        int depositBucketNum = account != null ? account.getDepositBucketNum() : 0;
        int owedBucketNum = account != null ? account.getOwedBucketNum() : 0;
        BigDecimal bucketDepositPerUnit = account != null && account.getBucketDepositPerUnit() != null
            ? account.getBucketDepositPerUnit() : new BigDecimal("30");
        int owedThreshold = account != null ? account.getOwedThreshold() : 10;
        boolean overThreshold = owedBucketNum >= owedThreshold;
        BigDecimal owedDepositAmount = bucketDepositPerUnit.multiply(new BigDecimal(owedBucketNum));

        YearMonth currentMonth = YearMonth.now();
        LocalDateTime monthStart = currentMonth.atDay(1).atStartOfDay();
        LocalDateTime monthEnd = currentMonth.atEndOfMonth().atTime(23, 59, 59);

        com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<BucketTransaction> monthWrapper =
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<BucketTransaction>()
                .eq(BucketTransaction::getStationId, stationId)
                .ge(BucketTransaction::getCreatedAt, monthStart)
                .le(BucketTransaction::getCreatedAt, monthEnd);

        List<BucketTransaction> monthTransactions = bucketTransactionMapper.selectList(monthWrapper);

        int monthReturn = monthTransactions.stream()
            .filter(t -> "return".equals(t.getType()))
            .mapToInt(t -> Math.abs(t.getQuantity()))
            .sum();

        int monthOwe = monthTransactions.stream()
            .filter(t -> "owed".equals(t.getType()))
            .mapToInt(t -> Math.abs(t.getQuantity()))
            .sum();

        int monthNet = monthReturn - monthOwe;

        com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<BucketTransaction> allWrapper =
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<BucketTransaction>()
                .eq(BucketTransaction::getStationId, stationId);

        List<BucketTransaction> allTransactions = bucketTransactionMapper.selectList(allWrapper);

        int totalReturn = allTransactions.stream()
            .filter(t -> "return".equals(t.getType()))
            .mapToInt(t -> Math.abs(t.getQuantity()))
            .sum();

        int totalOwe = allTransactions.stream()
            .filter(t -> "owed".equals(t.getType()))
            .mapToInt(t -> Math.abs(t.getQuantity()))
            .sum();

        return new BucketSummaryDTO(
            depositBucketNum,
            owedBucketNum,
            owedDepositAmount,
            bucketDepositPerUnit,
            owedThreshold,
            overThreshold,
            monthReturn,
            monthOwe,
            monthNet,
            totalReturn,
            totalOwe
        );
    }
}
