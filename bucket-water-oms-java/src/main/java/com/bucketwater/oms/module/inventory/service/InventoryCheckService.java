package com.bucketwater.oms.module.inventory.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.bucketwater.oms.common.exception.BusinessException;
import com.bucketwater.oms.common.response.ResultCode;
import com.bucketwater.oms.module.inventory.dto.*;
import com.bucketwater.oms.module.inventory.entity.InventoryCheckTask;
import com.bucketwater.oms.module.inventory.entity.InventoryCheckTaskItem;
import com.bucketwater.oms.module.inventory.entity.ProductInventoryCheck;
import com.bucketwater.oms.module.inventory.mapper.InventoryCheckTaskItemMapper;
import com.bucketwater.oms.module.inventory.mapper.InventoryCheckTaskMapper;
import com.bucketwater.oms.module.inventory.mapper.ProductInventoryCheckMapper;
import com.bucketwater.oms.module.product.entity.Product;
import com.bucketwater.oms.module.product.entity.ProductInventory;
import com.bucketwater.oms.module.product.mapper.ProductInventoryMapper;
import com.bucketwater.oms.module.product.mapper.ProductMapper;
import com.bucketwater.oms.module.warehouse.entity.Warehouse;
import com.bucketwater.oms.module.warehouse.mapper.WarehouseMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class InventoryCheckService {

    @Autowired
    private InventoryCheckTaskMapper taskMapper;

    @Autowired
    private InventoryCheckTaskItemMapper taskItemMapper;

    @Autowired
    private ProductInventoryCheckMapper checkMapper;

    @Autowired
    private ProductMapper productMapper;

    @Autowired
    private ProductInventoryMapper inventoryMapper;

    @Autowired
    private WarehouseMapper warehouseMapper;

    @Autowired
    private ProductInventoryTransactionService transactionService;

    private static final DateTimeFormatter NO_FORMATTER = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");

    public PageResponse<InventoryCheckTaskDTO> queryTasks(InventoryCheckQueryRequest request) {
        QueryWrapper<InventoryCheckTask> wrapper = new QueryWrapper<>();

        if (request.getWarehouseId() != null) {
            wrapper.eq("warehouse_id", request.getWarehouseId());
        }
        if (request.getStatus() != null && !request.getStatus().isBlank()) {
            wrapper.eq("status", request.getStatus());
        }
        if (request.getStartDate() != null && !request.getStartDate().isBlank()) {
            wrapper.ge("create_time", request.getStartDate() + " 00:00:00");
        }
        if (request.getEndDate() != null && !request.getEndDate().isBlank()) {
            wrapper.le("create_time", request.getEndDate() + " 23:59:59");
        }

        wrapper.orderByDesc("create_time");

        IPage<InventoryCheckTask> page = taskMapper.selectPage(
            new Page<>(request.getPage(), request.getSize()),
            wrapper
        );

        List<InventoryCheckTaskDTO> records = page.getRecords().stream()
            .map(this::convertTaskToDTO)
            .collect(Collectors.toList());

        return PageResponse.of(page.getTotal(), request.getPage(), request.getSize(), records);
    }

    public InventoryCheckTaskDTO getTaskById(Long taskId) {
        InventoryCheckTask task = taskMapper.selectById(taskId);
        if (task == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "盘点任务不存在");
        }
        return convertTaskToDTO(task);
    }

    @Transactional
    public InventoryCheckTaskDTO createCheckTask(Long warehouseId, String operator, CreateInventoryCheckRequest request) {
        Warehouse warehouse = warehouseMapper.selectById(warehouseId);
        if (warehouse == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "仓库不存在");
        }

        InventoryCheckTask task = new InventoryCheckTask();
        task.setTaskNo("CK" + LocalDateTime.now().format(NO_FORMATTER));
        task.setWarehouseId(warehouseId);
        task.setWarehouseName(warehouse.getName());
        task.setStatus("in_progress");
        task.setTotalProducts(0);
        task.setCheckedProducts(0);
        task.setSurplusCount(0);
        task.setLossCount(0);
        task.setMatchedCount(0);
        task.setSummary(request.getRemark());
        task.setCreator(operator);
        task.setStartTime(LocalDateTime.now());
        task.setCreateTime(LocalDateTime.now());
        taskMapper.insert(task);

        List<InventoryCheckTaskItem> items = new ArrayList<>();

        if (request.getProducts() != null && !request.getProducts().isEmpty()) {
            for (CreateInventoryCheckRequest.CheckProduct cp : request.getProducts()) {
                Product product = productMapper.selectById(cp.getProductId());
                if (product == null) continue;

                QueryWrapper<ProductInventory> invWrapper = new QueryWrapper<>();
                invWrapper.eq("warehouse_id", warehouseId).eq("product_id", cp.getProductId());
                ProductInventory inventory = inventoryMapper.selectOne(invWrapper);
                int systemQty = inventory != null && inventory.getQuantity() != null ? inventory.getQuantity() : 0;
                int actualQty = cp.getActualQuantity();
                int discrepancy = actualQty - systemQty;

                InventoryCheckTaskItem item = new InventoryCheckTaskItem();
                item.setTaskId(task.getId());
                item.setProductId(cp.getProductId());
                item.setProductName(product.getName());
                item.setProductCategory(product.getCategory());
                item.setSystemQuantity(systemQty);
                item.setActualQuantity(actualQty);
                item.setDiscrepancy(discrepancy);
                item.setDiscrepancyType(getDiscrepancyType(discrepancy));
                item.setRemark(cp.getRemark());
                item.setCreateTime(LocalDateTime.now());
                taskItemMapper.insert(item);
                items.add(item);

                createCheckRecord(warehouseId, warehouse.getName(), product, systemQty, actualQty, discrepancy, operator);
            }
        } else {
            QueryWrapper<ProductInventory> invWrapper = new QueryWrapper<>();
            invWrapper.eq("warehouse_id", warehouseId);
            List<ProductInventory> inventories = inventoryMapper.selectList(invWrapper);

            for (ProductInventory inv : inventories) {
                Product product = productMapper.selectById(inv.getProductId());
                if (product == null) continue;

                InventoryCheckTaskItem item = new InventoryCheckTaskItem();
                item.setTaskId(task.getId());
                item.setProductId(inv.getProductId());
                item.setProductName(product.getName());
                item.setProductCategory(product.getCategory());
                item.setSystemQuantity(inv.getQuantity() != null ? inv.getQuantity() : 0);
                item.setActualQuantity(inv.getQuantity() != null ? inv.getQuantity() : 0);
                item.setDiscrepancy(0);
                item.setDiscrepancyType("matched");
                item.setCreateTime(LocalDateTime.now());
                taskItemMapper.insert(item);
                items.add(item);
            }
        }

        task.setTotalProducts(items.size());
        task.setCheckedProducts((int) items.stream().filter(i -> i.getActualQuantity() != null && !i.getActualQuantity().equals(i.getSystemQuantity())).count());
        task.setSurplusCount((int) items.stream().filter(i -> i.getDiscrepancy() != null && i.getDiscrepancy() > 0).count());
        task.setLossCount((int) items.stream().filter(i -> i.getDiscrepancy() != null && i.getDiscrepancy() < 0).count());
        task.setMatchedCount((int) items.stream().filter(i -> i.getDiscrepancy() != null && i.getDiscrepancy() == 0).count());
        taskMapper.updateById(task);

        InventoryCheckTaskDTO dto = convertTaskToDTO(task);
        dto.setItems(items.stream().map(this::convertItemToDTO).collect(Collectors.toList()));
        return dto;
    }

    @Transactional
    public InventoryCheckTaskDTO updateTaskItem(Long taskId, Long productId, Integer actualQuantity, String remark) {
        InventoryCheckTask task = taskMapper.selectById(taskId);
        if (task == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "盘点任务不存在");
        }
        if (!"in_progress".equals(task.getStatus())) {
            throw new BusinessException(ResultCode.PARAM_ERROR, "任务已结束，无法修改");
        }

        InventoryCheckTaskItem item = taskItemMapper.findByTaskIdAndProductId(taskId, productId);
        if (item == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "盘点明细不存在");
        }

        item.setActualQuantity(actualQuantity);
        item.setDiscrepancy(actualQuantity - item.getSystemQuantity());
        item.setDiscrepancyType(getDiscrepancyType(item.getDiscrepancy()));
        if (remark != null) {
            item.setRemark(remark);
        }
        taskItemMapper.updateById(item);

        List<InventoryCheckTaskItem> allItems = taskItemMapper.findByTaskId(taskId);
        task.setCheckedProducts((int) allItems.stream().filter(i -> i.getActualQuantity() != null && !i.getActualQuantity().equals(i.getSystemQuantity())).count());
        task.setSurplusCount((int) allItems.stream().filter(i -> i.getDiscrepancy() != null && i.getDiscrepancy() > 0).count());
        task.setLossCount((int) allItems.stream().filter(i -> i.getDiscrepancy() != null && i.getDiscrepancy() < 0).count());
        task.setMatchedCount((int) allItems.stream().filter(i -> i.getDiscrepancy() != null && i.getDiscrepancy() == 0).count());
        taskMapper.updateById(task);

        Product product = productMapper.selectById(productId);
        if (product != null && item.getDiscrepancy() != 0) {
            updateProductInventoryCheck(task.getWarehouseId(), productId, actualQuantity, task.getCreator());
        }

        InventoryCheckTaskDTO dto = convertTaskToDTO(task);
        dto.setItems(allItems.stream().map(this::convertItemToDTO).collect(Collectors.toList()));
        return dto;
    }

    @Transactional
    public InventoryCheckTaskDTO confirmTask(Long taskId, String operator) {
        InventoryCheckTask task = taskMapper.selectById(taskId);
        if (task == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "盘点任务不存在");
        }
        if (!"in_progress".equals(task.getStatus())) {
            throw new BusinessException(ResultCode.PARAM_ERROR, "任务已结束");
        }

        List<InventoryCheckTaskItem> items = taskItemMapper.findByTaskId(taskId);
        for (InventoryCheckTaskItem item : items) {
            if (item.getDiscrepancy() != null && item.getDiscrepancy() != 0) {
                QueryWrapper<ProductInventory> wrapper = new QueryWrapper<>();
                wrapper.eq("warehouse_id", task.getWarehouseId()).eq("product_id", item.getProductId());
                ProductInventory inventory = inventoryMapper.selectOne(wrapper);

                if (inventory != null) {
                    int newQty = item.getActualQuantity();
                    inventory.setQuantity(newQty);
                    inventoryMapper.updateById(inventory);
                }
            }
        }

        task.setStatus("completed");
        task.setChecker(operator);
        task.setEndTime(LocalDateTime.now());
        taskMapper.updateById(task);

        return convertTaskToDTO(task);
    }

    private void createCheckRecord(Long warehouseId, String warehouseName, Product product, int systemQty, int actualQty, int discrepancy, String operator) {
        ProductInventoryCheck check = new ProductInventoryCheck();
        check.setCheckNo("CR" + LocalDateTime.now().format(NO_FORMATTER) + String.format("%04d", product.getId().intValue()));
        check.setWarehouseId(warehouseId);
        check.setWarehouseName(warehouseName);
        check.setProductId(product.getId());
        check.setProductName(product.getName());
        check.setProductCategory(product.getCategory());
        check.setSystemQuantity(systemQty);
        check.setActualQuantity(actualQty);
        check.setDiscrepancy(discrepancy);
        check.setDiscrepancyType(getDiscrepancyType(discrepancy));
        check.setStatus("pending");
        check.setChecker(operator);
        check.setCheckTime(LocalDateTime.now());
        check.setCreateTime(LocalDateTime.now());
        checkMapper.insert(check);
    }

    private void updateProductInventoryCheck(Long warehouseId, Long productId, Integer actualQuantity, String operator) {
        ProductInventoryCheck check = new ProductInventoryCheck();
        check.setWarehouseId(warehouseId);
        check.setProductId(productId);
        Product product = productMapper.selectById(productId);
        if (product != null) {
            check.setProductName(product.getName());
            check.setProductCategory(product.getCategory());
        }
        QueryWrapper<ProductInventory> wrapper = new QueryWrapper<>();
        wrapper.eq("warehouse_id", warehouseId).eq("product_id", productId);
        ProductInventory inventory = inventoryMapper.selectOne(wrapper);
        int systemQty = inventory != null && inventory.getQuantity() != null ? inventory.getQuantity() : 0;
        check.setSystemQuantity(systemQty);
        check.setActualQuantity(actualQuantity);
        check.setDiscrepancy(actualQuantity - systemQty);
        check.setDiscrepancyType(getDiscrepancyType(actualQuantity - systemQty));
        check.setStatus("pending");
        check.setChecker(operator);
        check.setCheckTime(LocalDateTime.now());
        checkMapper.insert(check);
    }

    public PageResponse<ProductInventoryCheckDTO> queryCheckRecords(InventoryCheckQueryRequest request) {
        QueryWrapper<ProductInventoryCheck> wrapper = new QueryWrapper<>();

        if (request.getWarehouseId() != null) {
            wrapper.eq("warehouse_id", request.getWarehouseId());
        }
        if (request.getProductId() != null) {
            wrapper.eq("product_id", request.getProductId());
        }
        if (request.getStatus() != null && !request.getStatus().isBlank()) {
            wrapper.eq("status", request.getStatus());
        }
        if (request.getStartDate() != null && !request.getStartDate().isBlank()) {
            wrapper.ge("create_time", request.getStartDate() + " 00:00:00");
        }
        if (request.getEndDate() != null && !request.getEndDate().isBlank()) {
            wrapper.le("create_time", request.getEndDate() + " 23:59:59");
        }

        wrapper.orderByDesc("create_time");

        IPage<ProductInventoryCheck> page = checkMapper.selectPage(
            new Page<>(request.getPage(), request.getSize()),
            wrapper
        );

        List<ProductInventoryCheckDTO> records = page.getRecords().stream()
            .map(this::convertCheckToDTO)
            .collect(Collectors.toList());

        return PageResponse.of(page.getTotal(), request.getPage(), request.getSize(), records);
    }

    private String getDiscrepancyType(Integer discrepancy) {
        if (discrepancy == null || discrepancy == 0) {
            return "matched";
        } else if (discrepancy > 0) {
            return "surplus";
        } else {
            return "loss";
        }
    }

    private InventoryCheckTaskDTO convertTaskToDTO(InventoryCheckTask task) {
        InventoryCheckTaskDTO dto = new InventoryCheckTaskDTO();
        dto.setId(task.getId());
        dto.setTaskNo(task.getTaskNo());
        dto.setWarehouseId(task.getWarehouseId());
        dto.setWarehouseName(task.getWarehouseName());
        dto.setStatus(task.getStatus());
        dto.setStatusText(getTaskStatusText(task.getStatus()));
        dto.setTotalProducts(task.getTotalProducts());
        dto.setCheckedProducts(task.getCheckedProducts());
        dto.setSurplusCount(task.getSurplusCount());
        dto.setLossCount(task.getLossCount());
        dto.setMatchedCount(task.getMatchedCount());
        dto.setSummary(task.getSummary());
        dto.setCreator(task.getCreator());
        dto.setChecker(task.getChecker());
        dto.setStartTime(task.getStartTime());
        dto.setEndTime(task.getEndTime());
        dto.setCreateTime(task.getCreateTime());
        return dto;
    }

    private InventoryCheckTaskItemDTO convertItemToDTO(InventoryCheckTaskItem item) {
        InventoryCheckTaskItemDTO dto = new InventoryCheckTaskItemDTO();
        dto.setId(item.getId());
        dto.setTaskId(item.getTaskId());
        dto.setProductId(item.getProductId());
        dto.setProductName(item.getProductName());
        dto.setProductCategory(item.getProductCategory());
        dto.setSystemQuantity(item.getSystemQuantity());
        dto.setActualQuantity(item.getActualQuantity());
        dto.setDiscrepancy(item.getDiscrepancy());
        dto.setDiscrepancyType(item.getDiscrepancyType());
        dto.setDiscrepancyTypeText(getDiscrepancyTypeText(item.getDiscrepancyType()));
        dto.setRemark(item.getRemark());
        dto.setCreateTime(item.getCreateTime());
        return dto;
    }

    private ProductInventoryCheckDTO convertCheckToDTO(ProductInventoryCheck check) {
        ProductInventoryCheckDTO dto = new ProductInventoryCheckDTO();
        dto.setId(check.getId());
        dto.setCheckNo(check.getCheckNo());
        dto.setWarehouseId(check.getWarehouseId());
        dto.setWarehouseName(check.getWarehouseName());
        dto.setProductId(check.getProductId());
        dto.setProductName(check.getProductName());
        dto.setProductCategory(check.getProductCategory());
        dto.setSystemQuantity(check.getSystemQuantity());
        dto.setActualQuantity(check.getActualQuantity());
        dto.setDiscrepancy(check.getDiscrepancy());
        dto.setDiscrepancyType(check.getDiscrepancyType());
        dto.setDiscrepancyTypeText(getDiscrepancyTypeText(check.getDiscrepancyType()));
        dto.setStatus(check.getStatus());
        dto.setStatusText(getCheckStatusText(check.getStatus()));
        dto.setChecker(check.getChecker());
        dto.setCheckTime(check.getCheckTime());
        dto.setRemark(check.getRemark());
        dto.setCreateTime(check.getCreateTime());
        return dto;
    }

    private String getTaskStatusText(String status) {
        if (status == null) return "";
        return switch (status) {
            case "in_progress" -> "盘点中";
            case "completed" -> "已完成";
            case "cancelled" -> "已取消";
            default -> status;
        };
    }

    private String getCheckStatusText(String status) {
        if (status == null) return "";
        return switch (status) {
            case "pending" -> "待确认";
            case "confirmed" -> "已确认";
            default -> status;
        };
    }

    private String getDiscrepancyTypeText(String type) {
        if (type == null) return "";
        return switch (type) {
            case "surplus" -> "盘盈";
            case "loss" -> "盘亏";
            case "matched" -> "无差异";
            default -> type;
        };
    }
}
