package com.bucketwater.oms.module.admin.service;

import com.bucketwater.oms.common.exception.BusinessException;
import com.bucketwater.oms.common.response.ResultCode;
import com.bucketwater.oms.module.admin.dto.*;
import com.bucketwater.oms.module.admin.entity.PolicyTemplate;
import com.bucketwater.oms.module.admin.entity.PolicyPricingRule;
import com.bucketwater.oms.module.admin.mapper.PolicyTemplateMapper;
import com.bucketwater.oms.module.admin.mapper.PolicyPricingRuleMapper;
import com.bucketwater.oms.module.bucket.entity.BucketTransaction;
import com.bucketwater.oms.module.bucket.mapper.BucketTransactionMapper;
import com.bucketwater.oms.module.order.entity.Order;
import com.bucketwater.oms.module.order.entity.OrderItem;
import com.bucketwater.oms.module.order.mapper.OrderItemMapper;
import com.bucketwater.oms.module.order.mapper.OrderMapper;
import com.bucketwater.oms.module.product.entity.Product;
import com.bucketwater.oms.module.product.entity.StationProductPrice;
import com.bucketwater.oms.module.product.mapper.ProductMapper;
import com.bucketwater.oms.module.product.mapper.StationProductPriceMapper;
import com.bucketwater.oms.module.station.entity.Station;
import com.bucketwater.oms.module.station.entity.StationAccount;
import com.bucketwater.oms.module.station.mapper.StationAccountMapper;
import com.bucketwater.oms.module.station.mapper.StationMapper;
import com.bucketwater.oms.module.user.entity.User;
import com.bucketwater.oms.module.user.mapper.UserMapper;
import com.bucketwater.oms.module.warehouse.entity.Warehouse;
import com.bucketwater.oms.module.warehouse.mapper.WarehouseMapper;
import com.bucketwater.oms.module.factory.entity.Factory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;

import com.bucketwater.oms.common.util.CoordinateUtil;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class AdminStationService {

    private static final Logger log = LoggerFactory.getLogger(AdminStationService.class);

    @Autowired
    private StationMapper stationMapper;

    @Autowired
    private StationAccountMapper stationAccountMapper;

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private OrderMapper orderMapper;

    @Autowired
    private OrderItemMapper orderItemMapper;

    @Autowired(required = false)
    private com.bucketwater.oms.module.factory.mapper.FactoryMapper factoryMapper;

    @Autowired
    private ProductMapper productMapper;

    @Autowired
    private StationProductPriceMapper stationProductPriceMapper;

    @Autowired
    private WarehouseMapper warehouseMapper;

    @Autowired
    private BucketTransactionMapper bucketTransactionMapper;

    @Autowired(required = false)
    private PolicyTemplateMapper policyTemplateMapper;

    @Autowired(required = false)
    private PolicyPricingRuleMapper pricingRuleMapper;

    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
    private final DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    public List<StationVO> getAllStations(String status) {
        return getAllStations(status, null);
    }

    public List<StationVO> getAllStations(String status, Long factoryId) {
        var wrapper = new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Station>();
        if (status != null && !status.isEmpty()) {
            wrapper.eq(Station::getStatus, status);
        }
        if (factoryId != null) {
            wrapper.eq(Station::getFactoryId, factoryId);
        }
        wrapper.orderByDesc(Station::getCreateTime);
        List<Station> stations = stationMapper.selectList(wrapper);

        List<Long> stationIds = stations.stream().map(Station::getId).collect(Collectors.toList());

        Map<Long, StationAccount> accountMap = stationAccountMapper.selectList(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<StationAccount>()
                .in(StationAccount::getStationId, stationIds)
        ).stream().collect(Collectors.toMap(StationAccount::getStationId, a -> a));

        List<StationVO> result = new ArrayList<>();
        for (Station station : stations) {
            StationVO vo = new StationVO();
            vo.setId(String.valueOf(station.getId()));
            vo.setName(station.getName());
            vo.setContact(station.getContact());
            vo.setPhone(station.getPhone());
            vo.setAddress(station.getAddress());
            vo.setArea(station.getArea());
            vo.setStationType(station.getStationType());
            vo.setRemark(station.getRemark());
            vo.setLat(station.getLat());
            vo.setLng(station.getLng());
            vo.setStatus(station.getStatus());
            vo.setCreateTime(station.getCreateTime() != null ? station.getCreateTime().toString() : null);
            vo.setFactoryId(station.getFactoryId());

            if (station.getFactoryId() != null && factoryMapper != null) {
                var factory = factoryMapper.selectById(station.getFactoryId());
                if (factory != null) {
                    vo.setFactoryName(factory.getName());
                }
            }

            StationAccount account = accountMap.get(station.getId());
            if (account != null) {
                vo.setBalance(account.getDepositBalance());
                vo.setCreditLimit(account.getCreditLimit());
                vo.setCreditUsed(account.getCreditUsed());
                vo.setOwedBuckets(account.getOwedBucketNum());
            } else {
                vo.setBalance(BigDecimal.ZERO);
                vo.setCreditLimit(BigDecimal.ZERO);
                vo.setCreditUsed(BigDecimal.ZERO);
                vo.setOwedBuckets(0);
            }

            result.add(vo);
        }

        return result;
    }

    public Station getStationById(Long stationId) {
        Station station = stationMapper.selectById(stationId);
        if (station == null) {
            throw new BusinessException(ResultCode.STATION_NOT_FOUND);
        }
        return station;
    }

    public StationAccount getStationAccount(Long stationId) {
        return stationAccountMapper.selectOne(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<StationAccount>()
                .eq(StationAccount::getStationId, stationId)
        );
    }

    @Transactional
    public Station createStation(StationManagementDTO request, String userPhone) {
        User existingUser = userMapper.selectOne(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<User>()
                .eq(User::getPhone, userPhone)
        );
        if (existingUser != null) {
            throw new BusinessException(ResultCode.DATA_EXISTS);
        }

        Station station = new Station();
        station.setName(request.getName());
        station.setContact(request.getContact());
        station.setPhone(request.getPhone());
        station.setAddress(request.getAddress());
        station.setArea(request.getArea());
        station.setStationType(request.getStationType());
        station.setRemark(request.getRemark());
        station.setFactoryId(request.getFactoryId());
        station.setStatus("active");
        station.setCreateTime(LocalDateTime.now());
        station.setUpdateTime(LocalDateTime.now());

        stationMapper.insert(station);

        StationAccount account = new StationAccount();
        account.setStationId(station.getId());
        account.setDepositBalance(request.getInitialBalance() != null ? request.getInitialBalance() : java.math.BigDecimal.ZERO);
        account.setCreditLimit(request.getCreditLimit() != null ? request.getCreditLimit() : java.math.BigDecimal.ZERO);
        account.setCreditUsed(java.math.BigDecimal.ZERO);
        java.math.BigDecimal depositPerUnit = request.getBucketDepositAmount() != null ? request.getBucketDepositAmount()
            : (request.getBucketDepositPerUnit() != null ? request.getBucketDepositPerUnit() : new java.math.BigDecimal("30.00"));
        account.setBucketDepositPerUnit(depositPerUnit);
        account.setOwedBucketNum(request.getDepositBucketNum() != null ? request.getDepositBucketNum() : 0);
        account.setOwedThreshold(request.getOwedThreshold() != null ? request.getOwedThreshold() : 10);
        account.setPaymentType(request.getPaymentType());
        account.setPrepaidRequiredAmount(request.getPrepaidRequiredAmount());
        account.setDepositBucketNum(request.getDepositBucketNum());
        account.setUpdatedAt(LocalDateTime.now());

        stationAccountMapper.insert(account);

        String rawPassword = (request.getPassword() != null && !request.getPassword().isEmpty())
            ? request.getPassword() : "123456";
        String encodedPassword = passwordEncoder.encode(rawPassword);

        User user = new User();
        user.setPhone(request.getPhone());
        user.setPassword(encodedPassword);
        user.setName(request.getContact());
        user.setRole("station");
        user.setStationId(station.getId());
        user.setStatus("active");
        user.setCreateTime(LocalDateTime.now());
        user.setUpdateTime(LocalDateTime.now());

        userMapper.insert(user);

        return station;
    }

    @Transactional
    public Station updateStation(Long stationId, StationManagementDTO request) {
        Station station = stationMapper.selectById(stationId);
        if (station == null) {
            throw new BusinessException(ResultCode.STATION_NOT_FOUND);
        }

        if (request.getName() != null) {
            station.setName(request.getName());
        }
        if (request.getContact() != null) {
            station.setContact(request.getContact());
        }
        if (request.getPhone() != null) {
            station.setPhone(request.getPhone());
        }
        if (request.getAddress() != null) {
            station.setAddress(request.getAddress());
        }
        if (request.getArea() != null) {
            station.setArea(request.getArea());
        }
        if (request.getStationType() != null) {
            station.setStationType(request.getStationType());
        }
        if (request.getRemark() != null) {
            station.setRemark(request.getRemark());
        }
        if (request.getLatDmm() != null && !request.getLatDmm().isEmpty()) {
            BigDecimal lat = CoordinateUtil.parseDmmToDecimalDegrees(request.getLatDmm());
            if (lat != null && CoordinateUtil.isValidLatitude(lat)) {
                station.setLat(lat);
            }
        } else if (request.getLat() != null) {
            station.setLat(request.getLat());
        }
        if (request.getLngDmm() != null && !request.getLngDmm().isEmpty()) {
            BigDecimal lng = CoordinateUtil.parseDmmToDecimalDegrees(request.getLngDmm());
            if (lng != null && CoordinateUtil.isValidLongitude(lng)) {
                station.setLng(lng);
            }
        } else if (request.getLng() != null) {
            station.setLng(request.getLng());
        }

        station.setUpdateTime(LocalDateTime.now());
        stationMapper.updateById(station);

        StationAccount account = stationAccountMapper.selectOne(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<StationAccount>()
                .eq(StationAccount::getStationId, stationId)
        );

        if (account != null) {
            if (request.getDepositBalance() != null) {
                account.setDepositBalance(request.getDepositBalance());
            } else if (request.getInitialBalance() != null) {
                account.setDepositBalance(request.getInitialBalance());
            }
            if (request.getCreditLimit() != null) {
                account.setCreditLimit(request.getCreditLimit());
            }
            if (request.getBucketDepositAmount() != null) {
                account.setBucketDepositPerUnit(request.getBucketDepositAmount());
            } else if (request.getBucketDepositPerUnit() != null) {
                account.setBucketDepositPerUnit(request.getBucketDepositPerUnit());
            }
            if (request.getOwedThreshold() != null) {
                account.setOwedThreshold(request.getOwedThreshold());
            }
            if (request.getPaymentType() != null) {
                account.setPaymentType(request.getPaymentType());
            }
            if (request.getPrepaidRequiredAmount() != null) {
                account.setPrepaidRequiredAmount(request.getPrepaidRequiredAmount());
            }
            if (request.getDepositBucketNum() != null) {
                account.setDepositBucketNum(request.getDepositBucketNum());
            }

            account.setUpdatedAt(LocalDateTime.now());
            stationAccountMapper.updateById(account);
        }

        User user = userMapper.selectOne(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<User>()
                .eq(User::getStationId, stationId)
        );

        if (user != null) {
            if (request.getContact() != null) {
                user.setName(request.getContact());
            }
            if (request.getPhone() != null) {
                user.setPhone(request.getPhone());
            }
            if (request.getPassword() != null && !request.getPassword().isEmpty()) {
                user.setPassword(passwordEncoder.encode(request.getPassword()));
            }
            user.setUpdateTime(LocalDateTime.now());
            userMapper.updateById(user);
        }

        return station;
    }

    @Transactional
    public void updateStationStatus(Long stationId, String status) {
        Station station = stationMapper.selectById(stationId);
        if (station == null) {
            throw new BusinessException(ResultCode.STATION_NOT_FOUND);
        }

        station.setStatus(status);
        station.setUpdateTime(LocalDateTime.now());
        stationMapper.updateById(station);

        userMapper.update(null,
            new com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper<User>()
                .eq(User::getStationId, stationId)
                .set(User::getStatus, status)
        );
    }

    @Transactional
    public void updateStationPolicy(StationAccountPolicyDTO request) {
        StationAccount account = stationAccountMapper.selectOne(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<StationAccount>()
                .eq(StationAccount::getStationId, Long.parseLong(request.getStationId()))
        );

        if (account == null) {
            throw new BusinessException(ResultCode.STATION_NOT_FOUND);
        }

        if (request.getPolicyId() != null) {
            if (policyTemplateMapper != null) {
                PolicyTemplate policy = policyTemplateMapper.selectById(request.getPolicyId());
                if (policy == null) {
                    throw new BusinessException(ResultCode.DATA_NOT_FOUND, "政策模板不存在");
                }
                account.setPolicyId(request.getPolicyId());
            }
        }

        if (request.getCreditLimit() != null) {
            account.setCreditLimit(request.getCreditLimit());
        }
        if (request.getBucketDepositAmount() != null) {
            account.setBucketDepositPerUnit(request.getBucketDepositAmount());
        } else if (request.getBucketDepositPerUnit() != null) {
            account.setBucketDepositPerUnit(request.getBucketDepositPerUnit());
        }
        if (request.getOwedThreshold() != null) {
            account.setOwedThreshold(request.getOwedThreshold());
        }
        if (request.getPaymentType() != null) {
            account.setPaymentType(request.getPaymentType());
        }

        account.setUpdatedAt(LocalDateTime.now());
        stationAccountMapper.updateById(account);
    }

    @Transactional
    public void assignStationPolicy(Long stationId, Long policyId) {
        Station station = stationMapper.selectById(stationId);
        if (station == null) {
            throw new BusinessException(ResultCode.STATION_NOT_FOUND);
        }

        if (policyTemplateMapper != null) {
            PolicyTemplate policy = policyTemplateMapper.selectById(policyId);
            if (policy == null) {
                throw new BusinessException(ResultCode.DATA_NOT_FOUND, "政策模板不存在");
            }
        }

        StationAccount account = stationAccountMapper.selectOne(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<StationAccount>()
                .eq(StationAccount::getStationId, stationId)
        );

        if (account == null) {
            account = new StationAccount();
            account.setStationId(stationId);
            account.setDepositBalance(BigDecimal.ZERO);
            account.setCreditLimit(BigDecimal.ZERO);
            account.setCreditUsed(BigDecimal.ZERO);
            account.setDepositBucketNum(0);
            account.setOwedBucketNum(0);
            account.setOwedThreshold(30);
            account.setBucketDepositPerUnit(new BigDecimal("20.00"));
            account.setPaymentType("PREPAID");
            account.setPrepaidRequiredAmount(BigDecimal.ZERO);
            account.setPolicyId(policyId);
            account.setUpdatedAt(LocalDateTime.now());
            stationAccountMapper.insert(account);
        } else {
            account.setPolicyId(policyId);
            account.setUpdatedAt(LocalDateTime.now());
            stationAccountMapper.updateById(account);
        }
    }

    @Transactional
    public Station updateStationLocation(Long stationId, java.math.BigDecimal latitude, java.math.BigDecimal longitude, String address) {
        Station station = stationMapper.selectById(stationId);
        if (station == null) {
            throw new BusinessException(ResultCode.STATION_NOT_FOUND);
        }

        station.setLat(latitude);
        station.setLng(longitude);
        if (address != null && !address.isEmpty()) {
            station.setAddress(address);
        }
        station.setUpdateTime(LocalDateTime.now());
        stationMapper.updateById(station);

        return station;
    }

    public StationDetailDTO getStationDetail(Long stationId) {
        Station station = stationMapper.selectById(stationId);
        if (station == null) {
            throw new BusinessException(ResultCode.STATION_NOT_FOUND);
        }

        StationDetailDTO detail = new StationDetailDTO();
        detail.setId(station.getId());
        detail.setName(station.getName());
        detail.setCode("S" + String.format("%06d", station.getId()));
        detail.setStatus(station.getStatus());
        detail.setContact(station.getContact());
        detail.setPhone(station.getPhone());
        detail.setAddress(station.getAddress());
        detail.setArea(station.getArea());
        detail.setStationType(station.getStationType());
        detail.setRemark(station.getRemark());
        detail.setLat(station.getLat());
        detail.setLng(station.getLng());
        detail.setCreateTime(station.getCreateTime() != null ? station.getCreateTime().format(dateFormatter) : null);

        StationAccount account = stationAccountMapper.selectOne(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<StationAccount>()
                .eq(StationAccount::getStationId, stationId)
        );
        if (account != null) {
            detail.setDepositBalance(account.getDepositBalance() != null ? account.getDepositBalance() : BigDecimal.ZERO);
            detail.setCreditLimit(account.getCreditLimit() != null ? account.getCreditLimit() : BigDecimal.ZERO);
            detail.setCreditUsed(account.getCreditUsed() != null ? account.getCreditUsed() : BigDecimal.ZERO);
            detail.setDepositBucketNum(account.getDepositBucketNum() != null ? account.getDepositBucketNum() : 0);
            detail.setOwedBucketNum(account.getOwedBucketNum() != null ? account.getOwedBucketNum() : 0);
            detail.setOwedThreshold(account.getOwedThreshold() != null ? account.getOwedThreshold() : 30);
            detail.setBucketDepositAmount(account.getBucketDepositPerUnit() != null ? account.getBucketDepositPerUnit() : new BigDecimal("20.00"));
            detail.setPaymentType(account.getPaymentType() != null ? account.getPaymentType() : "PREPAID");
            detail.setMinDeposit(account.getPrepaidRequiredAmount() != null ? account.getPrepaidRequiredAmount() : BigDecimal.ZERO);

            if (account.getPolicyId() != null && policyTemplateMapper != null) {
                PolicyTemplate policy = policyTemplateMapper.selectById(account.getPolicyId());
                if (policy != null) {
                    detail.setPolicyId(String.valueOf(policy.getId()));
                    detail.setPolicyName(policy.getName());
                    detail.setPolicyType(policy.getType());
                }
            }
        } else {
            detail.setDepositBalance(BigDecimal.ZERO);
            detail.setCreditLimit(BigDecimal.ZERO);
            detail.setCreditUsed(BigDecimal.ZERO);
            detail.setDepositBucketNum(0);
            detail.setOwedBucketNum(0);
            detail.setOwedThreshold(30);
            detail.setBucketDepositAmount(new BigDecimal("20.00"));
            detail.setPaymentType("PREPAID");
            detail.setMinDeposit(BigDecimal.ZERO);
        }

        List<StationPriceDTO> prices = getStationPrices(stationId);
        detail.setPrices(prices);

        List<StationStaffDTO> staffs = getStationStaffs(stationId);
        detail.setStaffs(staffs);

        MonthlyStats stats = calculateMonthlyStats(stationId);
        detail.setMonthlyOrders(stats.orderCount);
        detail.setMonthlyBuckets(stats.bucketCount);
        detail.setMonthlyAmount(stats.totalAmount);
        detail.setMonthlyReturnBuckets(stats.returnBucketCount);

        List<RecentOrderDTO> recentOrders = getRecentOrders(stationId, 10);
        detail.setRecentOrders(recentOrders);

        return detail;
    }

    private List<StationPriceDTO> getStationPrices(Long stationId) {
        List<StationProductPrice> priceList = stationProductPriceMapper.selectList(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<StationProductPrice>()
                .eq(StationProductPrice::getStationId, stationId)
                .eq(StationProductPrice::getIsEnabled, true)
        );

        List<Long> productIds = priceList.stream()
            .map(StationProductPrice::getProductId)
            .collect(Collectors.toList());

        Map<Long, Product> productMap = new java.util.HashMap<>();
        if (!productIds.isEmpty()) {
            productMapper.selectBatchIds(productIds).forEach(p -> productMap.put(p.getId(), p));
        }

        List<StationPriceDTO> result = new ArrayList<>();
        for (StationProductPrice spp : priceList) {
            StationPriceDTO dto = new StationPriceDTO();
            dto.setProductId(spp.getProductId());
            Product product = productMap.get(spp.getProductId());
            dto.setProductName(product != null ? product.getName() : "未知商品");
            dto.setPrice(spp.getPrice());
            result.add(dto);
        }
        return result;
    }

    private List<StationStaffDTO> getStationStaffs(Long stationId) {
        List<User> users = userMapper.selectList(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<User>()
                .eq(User::getStationId, stationId)
        );

        List<StationStaffDTO> result = new ArrayList<>();
        for (User user : users) {
            StationStaffDTO dto = new StationStaffDTO();
            dto.setId(user.getId());
            dto.setName(user.getName());
            dto.setPhone(user.getPhone());
            dto.setRole(user.getRole() != null && user.getRole().equals("station") ? "owner" : "staff");
            dto.setStatus(user.getStatus());
            result.add(dto);
        }
        return result;
    }

    private MonthlyStats calculateMonthlyStats(Long stationId) {
        MonthlyStats stats = new MonthlyStats();
        stats.orderCount = 0;
        stats.bucketCount = 0;
        stats.totalAmount = BigDecimal.ZERO;
        stats.returnBucketCount = 0;

        LocalDateTime startOfMonth = LocalDate.now().withDayOfMonth(1).atStartOfDay();

        List<Order> monthlyOrders = orderMapper.selectList(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Order>()
                .eq(Order::getStationId, stationId)
                .eq(Order::getStatus, "completed")
                .ge(Order::getCreateTime, startOfMonth)
        );

        stats.orderCount = monthlyOrders.size();

        List<Long> orderIds = monthlyOrders.stream().map(Order::getId).collect(Collectors.toList());
        if (!orderIds.isEmpty()) {
            List<OrderItem> items = orderItemMapper.selectList(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<OrderItem>()
                    .in(OrderItem::getOrderId, orderIds)
            );

            int totalBuckets = 0;
            BigDecimal totalAmt = BigDecimal.ZERO;
            for (Order order : monthlyOrders) {
                if (order.getTotalAmount() != null) {
                    totalAmt = totalAmt.add(order.getTotalAmount());
                }
            }
            for (OrderItem item : items) {
                if (item.getQuantity() != null) {
                    totalBuckets += item.getQuantity();
                }
            }
            stats.bucketCount = totalBuckets;
            stats.totalAmount = totalAmt;
        }

        List<BucketTransaction> returnTransactions = bucketTransactionMapper.selectList(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<BucketTransaction>()
                .eq(BucketTransaction::getStationId, stationId)
                .eq(BucketTransaction::getType, "return")
                .ge(BucketTransaction::getCreatedAt, startOfMonth)
        );

        int returnCount = 0;
        for (BucketTransaction bt : returnTransactions) {
            if (bt.getQuantity() != null && bt.getQuantity() > 0) {
                returnCount += bt.getQuantity();
            }
        }
        stats.returnBucketCount = returnCount;

        return stats;
    }

    private List<RecentOrderDTO> getRecentOrders(Long stationId, int limit) {
        List<Order> orders = orderMapper.selectList(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Order>()
                .eq(Order::getStationId, stationId)
                .orderByDesc(Order::getCreateTime)
                .last("LIMIT " + limit)
        );

        List<RecentOrderDTO> result = new ArrayList<>();
        for (Order order : orders) {
            RecentOrderDTO dto = new RecentOrderDTO();
            dto.setId(order.getId());
            dto.setOrderNo(order.getOrderNo());
            dto.setCreateTime(order.getCreateTime() != null ? order.getCreateTime().format(dateFormatter) : null);
            dto.setAmount(order.getTotalAmount() != null ? order.getTotalAmount() : BigDecimal.ZERO);
            dto.setStatus(order.getStatus());
            result.add(dto);
        }
        return result;
    }

    public List<RecentOrderDTO> getStationOrders(Long stationId, int limit) {
        return getRecentOrders(stationId, limit);
    }

    private static class MonthlyStats {
        int orderCount;
        int bucketCount;
        BigDecimal totalAmount;
        int returnBucketCount;
    }

    @Transactional
    public void createStaff(Long stationId, StationStaffDTO staff) {
        if (stationId == null || staff == null) {
            throw new BusinessException(ResultCode.PARAM_ERROR, "参数错误");
        }
        if (staff.getPhone() == null || staff.getPhone().isEmpty()) {
            throw new BusinessException(ResultCode.PARAM_ERROR, "手机号不能为空");
        }

        User user = new User();
        user.setStationId(stationId);
        user.setPhone(staff.getPhone());
        user.setName(staff.getName() != null ? staff.getName() : "店员");
        user.setRole("staff");
        user.setStatus(staff.getStatus() != null ? staff.getStatus() : "active");
        user.setPassword(passwordEncoder.encode("123456"));
        user.setCreateTime(java.time.LocalDateTime.now());
        user.setUpdateTime(java.time.LocalDateTime.now());
        userMapper.insert(user);
        log.info("创建店员账号成功: phone={}, stationId={}", staff.getPhone(), stationId);
    }

    @Transactional
    public void updateStaff(Long staffId, StationStaffDTO staff) {
        if (staffId == null) {
            throw new BusinessException(ResultCode.PARAM_ERROR, "店员ID不能为空");
        }

        User user = userMapper.selectById(staffId);
        if (user == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "店员不存在");
        }

        if (staff.getName() != null) {
            user.setName(staff.getName());
        }
        if (staff.getPhone() != null && !staff.getPhone().isEmpty()) {
            user.setPhone(staff.getPhone());
        }
        if (staff.getStatus() != null) {
            user.setStatus(staff.getStatus());
        }
        if (staff.getPassword() != null && !staff.getPassword().isEmpty()) {
            user.setPassword(passwordEncoder.encode(staff.getPassword()));
        }
        user.setUpdateTime(java.time.LocalDateTime.now());
        userMapper.updateById(user);
        log.info("更新店员账号成功: staffId={}", staffId);
    }

    @Transactional
    public void deleteStaff(Long staffId) {
        if (staffId == null) {
            throw new BusinessException(ResultCode.PARAM_ERROR, "店员ID不能为空");
        }

        User user = userMapper.selectById(staffId);
        if (user == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "店员不存在");
        }

        userMapper.deleteById(staffId);
        log.info("删除店员账号成功: staffId={}", staffId);
    }

    @Transactional
    public void resetStaffPassword(Long staffId) {
        if (staffId == null) {
            throw new BusinessException(ResultCode.PARAM_ERROR, "店员ID不能为空");
        }

        User user = userMapper.selectById(staffId);
        if (user == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "店员不存在");
        }

        user.setPassword(passwordEncoder.encode("123456"));
        user.setUpdateTime(java.time.LocalDateTime.now());
        userMapper.updateById(user);
        log.info("重置店员密码成功: staffId={}", staffId);
    }
}
