package com.bucketwater.oms.module.admin.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.bucketwater.oms.common.exception.BusinessException;
import com.bucketwater.oms.common.response.ResultCode;
import com.bucketwater.oms.module.admin.dto.StationPageDTO;
import com.bucketwater.oms.module.admin.dto.StationPageQueryDTO;
import com.bucketwater.oms.module.station.entity.Station;
import com.bucketwater.oms.module.station.entity.StationAccount;
import com.bucketwater.oms.module.station.mapper.StationAccountMapper;
import com.bucketwater.oms.module.station.mapper.StationMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class AdminStationPageService {

    @Autowired
    private StationMapper stationMapper;

    @Autowired
    private StationAccountMapper stationAccountMapper;

    public StationPageDTO queryStations(StationPageQueryDTO query) {
        StationPageDTO pageDTO = new StationPageDTO();
        
        LambdaQueryWrapper<Station> queryWrapper = new LambdaQueryWrapper<>();
        
        if (query.getKeyword() != null && !query.getKeyword().trim().isEmpty()) {
            queryWrapper.and(w -> w
                .like(Station::getName, query.getKeyword())
                .or()
                .like(Station::getContact, query.getKeyword())
                .or()
                .like(Station::getPhone, query.getKeyword())
            );
        }
        
        if (query.getStatus() != null && !query.getStatus().trim().isEmpty()) {
            if ("active".equals(query.getStatus())) {
                queryWrapper.eq(Station::getStatus, "active");
            } else if ("suspended".equals(query.getStatus())) {
                queryWrapper.eq(Station::getStatus, "suspended");
            } else if ("cancelled".equals(query.getStatus())) {
                queryWrapper.eq(Station::getStatus, "cancelled");
            }
        }
        
        queryWrapper.orderByDesc(Station::getCreateTime);
        
        Page<Station> page = new Page<>(query.getPage(), query.getSize());
        IPage<Station> stationPage = stationMapper.selectPage(page, queryWrapper);
        
        List<Station> stations = stationPage.getRecords();
        List<Long> stationIds = stations.stream().map(Station::getId).collect(Collectors.toList());
        
        Map<Long, StationAccount> accountMap = getAccountMap(stationIds);
        
        List<StationPageDTO.StationItem> items = new ArrayList<>();
        for (Station station : stations) {
            StationPageDTO.StationItem item = new StationPageDTO.StationItem();
            item.setId(station.getId().toString());
            item.setName(station.getName());
            item.setContact(station.getContact());
            item.setPhone(station.getPhone());
            item.setAddress(station.getAddress());
            item.setStatus(station.getStatus());
            item.setStatusText(getStatusText(station.getStatus()));
            
            StationAccount account = accountMap.get(station.getId());
            if (account != null) {
                item.setDepositBalance(account.getDepositBalance());
                item.setOwedBucketNum(account.getOwedBucketNum());
                item.setCreditLimit(account.getCreditLimit());
                item.setCreditUsed(account.getCreditUsed());
            } else {
                item.setDepositBalance(BigDecimal.ZERO);
                item.setOwedBucketNum(0);
                item.setCreditLimit(BigDecimal.ZERO);
                item.setCreditUsed(BigDecimal.ZERO);
            }
            
            if ("balance_sufficient".equals(query.getBalanceFilter())) {
                if (account == null || account.getDepositBalance().compareTo(BigDecimal.ZERO) < 0) {
                    continue;
                }
            } else if ("balance_low".equals(query.getBalanceFilter())) {
                if (account == null || account.getDepositBalance().compareTo(new BigDecimal("1000")) >= 0) {
                    continue;
                }
            } else if ("balance_arrears".equals(query.getBalanceFilter())) {
                if (account == null || account.getDepositBalance().compareTo(BigDecimal.ZERO) >= 0) {
                    continue;
                }
            }
            
            items.add(item);
        }
        
        pageDTO.setTotal(stationPage.getTotal());
        pageDTO.setPage(query.getPage());
        pageDTO.setSize(query.getSize());
        pageDTO.setTotalPages((int) stationPage.getPages());
        pageDTO.setStations(items);
        
        return pageDTO;
    }

    private Map<Long, StationAccount> getAccountMap(List<Long> stationIds) {
        if (stationIds.isEmpty()) {
            return Map.of();
        }
        
        LambdaQueryWrapper<StationAccount> query = new LambdaQueryWrapper<>();
        query.in(StationAccount::getStationId, stationIds);
        
        List<StationAccount> accounts = stationAccountMapper.selectList(query);
        
        return accounts.stream().collect(Collectors.toMap(StationAccount::getStationId, a -> a));
    }

    private String getStatusText(String status) {
        if (status == null) return "未知";
        return switch (status) {
            case "active" -> "正常运营";
            case "suspended" -> "欠费停供";
            case "cancelled" -> "已注销";
            default -> status;
        };
    }
}
