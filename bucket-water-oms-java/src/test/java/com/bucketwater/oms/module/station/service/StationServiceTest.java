package com.bucketwater.oms.module.station.service;

import com.bucketwater.oms.common.exception.BusinessException;
import com.bucketwater.oms.module.station.dto.InventoryDTO;
import com.bucketwater.oms.module.station.dto.RechargeRequest;
import com.bucketwater.oms.module.station.dto.StationInfoDTO;
import com.bucketwater.oms.module.station.entity.Station;
import com.bucketwater.oms.module.station.entity.StationAccount;
import com.bucketwater.oms.module.station.mapper.StationAccountMapper;
import com.bucketwater.oms.module.station.mapper.StationMapper;
import com.bucketwater.oms.module.warehouse.entity.Warehouse;
import com.bucketwater.oms.module.warehouse.mapper.WarehouseMapper;
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
@DisplayName("水站服务单元测试")
class StationServiceTest {

    @Mock
    private StationMapper stationMapper;

    @Mock
    private StationAccountMapper stationAccountMapper;

    @Mock
    private WarehouseMapper warehouseMapper;

    @InjectMocks
    private StationService stationService;

    private Long stationId;
    private Station testStation;
    private StationAccount testAccount;

    @BeforeEach
    void setUp() {
        stationId = 1L;

        testStation = new Station();
        testStation.setId(stationId);
        testStation.setName("测试水站");
        testStation.setContact("张三");
        testStation.setPhone("13800138000");
        testStation.setAddress("测试地址");
        testStation.setStatus("active");
        testStation.setCreateTime(LocalDateTime.now());
        testStation.setUpdateTime(LocalDateTime.now());

        testAccount = new StationAccount();
        testAccount.setId(1L);
        testAccount.setStationId(stationId);
        testAccount.setDepositBalance(new BigDecimal("5000.00"));
        testAccount.setCreditLimit(new BigDecimal("10000.00"));
        testAccount.setCreditUsed(new BigDecimal("3000.00"));
        testAccount.setBucketDepositPerUnit(new BigDecimal("30.00"));
        testAccount.setOwedBucketNum(5);
        testAccount.setOwedThreshold(10);
        testAccount.setUpdatedAt(LocalDateTime.now());
    }

    @Test
    @DisplayName("获取水站信息成功")
    void getStationInfo_Success() {
        when(stationMapper.selectById(stationId)).thenReturn(testStation);
        when(stationAccountMapper.selectOne(any())).thenReturn(testAccount);

        StationInfoDTO result = stationService.getStationInfo(stationId);

        assertNotNull(result);
        assertEquals(stationId.toString(), result.getId());
        assertEquals("测试水站", result.getName());
        assertNotNull(result.getAccount());
        assertEquals(new BigDecimal("5000.00"), result.getAccount().getDepositBalance());
        assertEquals(new BigDecimal("7000.00"), result.getAccount().getCreditAvailable());
        assertFalse(result.getAccount().getIsWarning());
    }

    @Test
    @DisplayName("水站不存在获取信息失败")
    void getStationInfo_NotFound() {
        when(stationMapper.selectById(stationId)).thenReturn(null);

        assertThrows(BusinessException.class, () -> {
            stationService.getStationInfo(stationId);
        });
    }

    @Test
    @DisplayName("获取实时库存成功")
    void getInventory_Success() {
        List<Warehouse> warehouses = new ArrayList<>();
        Warehouse warehouse = new Warehouse();
        warehouse.setId(1L);
        warehouse.setName("测试仓库");
        warehouse.setStatus("active");
        warehouses.add(warehouse);

        when(warehouseMapper.selectList(any())).thenReturn(warehouses);

        InventoryDTO result = stationService.getInventory(stationId);

        assertNotNull(result);
        assertEquals(1, result.getWarehouses().size());
        assertEquals("测试仓库", result.getWarehouses().get(0).getWarehouseName());
    }

    @Test
    @DisplayName("账户充值成功")
    void recharge_Success() {
        RechargeRequest request = new RechargeRequest();
        request.setAmount(new BigDecimal("1000.00"));
        request.setPaymentMethod("wechat_pay");

        when(stationAccountMapper.selectOne(any())).thenReturn(testAccount);
        when(stationAccountMapper.updateById(any(StationAccount.class))).thenReturn(1);

        stationService.recharge(stationId, request);

        verify(stationAccountMapper).updateById(any(StationAccount.class));
    }

    @Test
    @DisplayName("充值账户不存在失败")
    void recharge_AccountNotFound() {
        RechargeRequest request = new RechargeRequest();
        request.setAmount(new BigDecimal("1000.00"));
        request.setPaymentMethod("wechat_pay");

        when(stationAccountMapper.selectOne(any())).thenReturn(null);

        assertThrows(BusinessException.class, () -> {
            stationService.recharge(stationId, request);
        });
    }

    @Test
    @DisplayName("补缴空桶押金成功")
    void payBucketDeposit_Success() {
        when(stationAccountMapper.selectOne(any())).thenReturn(testAccount);
        when(stationAccountMapper.updateById(any(StationAccount.class))).thenReturn(1);

        stationService.payBucketDeposit(stationId, 5);

        verify(stationAccountMapper).updateById(any(StationAccount.class));
    }

    @Test
    @DisplayName("余额不足补缴失败")
    void payBucketDeposit_InsufficientBalance() {
        testAccount.setDepositBalance(new BigDecimal("10.00"));

        when(stationAccountMapper.selectOne(any())).thenReturn(testAccount);

        assertThrows(BusinessException.class, () -> {
            stationService.payBucketDeposit(stationId, 5);
        });
    }
}
