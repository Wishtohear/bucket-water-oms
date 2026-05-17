package com.bucketwater.oms.module.aftersales.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.bucketwater.oms.common.exception.BusinessException;
import com.bucketwater.oms.common.response.ResultCode;
import com.bucketwater.oms.module.aftersales.dto.*;
import com.bucketwater.oms.module.aftersales.entity.AfterSales;
import com.bucketwater.oms.module.aftersales.entity.AfterSalesImage;
import com.bucketwater.oms.module.aftersales.entity.AfterSalesItem;
import com.bucketwater.oms.module.aftersales.mapper.AfterSalesImageMapper;
import com.bucketwater.oms.module.aftersales.mapper.AfterSalesItemMapper;
import com.bucketwater.oms.module.aftersales.mapper.AfterSalesMapper;
import com.bucketwater.oms.module.file.service.FileService;
import com.bucketwater.oms.module.notification.service.NotificationService;
import com.bucketwater.oms.module.order.entity.Order;
import com.bucketwater.oms.module.order.entity.OrderItem;
import com.bucketwater.oms.module.order.mapper.OrderItemMapper;
import com.bucketwater.oms.module.order.mapper.OrderMapper;
import com.bucketwater.oms.module.product.entity.Product;
import com.bucketwater.oms.module.product.mapper.ProductMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class AfterSalesService {

    private static final Logger log = LoggerFactory.getLogger(AfterSalesService.class);

    @Autowired
    private AfterSalesMapper afterSalesMapper;

    @Autowired
    private AfterSalesItemMapper afterSalesItemMapper;

    @Autowired
    private AfterSalesImageMapper afterSalesImageMapper;

    @Autowired
    private OrderMapper orderMapper;

    @Autowired
    private OrderItemMapper orderItemMapper;

    @Autowired
    private ProductMapper productMapper;

    @Autowired
    private NotificationService notificationService;

    @Autowired
    private FileService fileService;

    /**
     * 获取售后列表（水站端）
     */
    public Page<AfterSalesDTO> getAfterSalesList(Long stationId, String status, Integer page, Integer size) {
        Page<AfterSales> pageParam = new Page<>(page, size);

        LambdaQueryWrapper<AfterSales> wrapper = new LambdaQueryWrapper<AfterSales>()
                .eq(AfterSales::getStationId, stationId)
                .orderByDesc(AfterSales::getCreatedAt);

        if (status != null && !status.isEmpty() && !"all".equalsIgnoreCase(status)) {
            wrapper.eq(AfterSales::getStatus, status);
        }

        Page<AfterSales> pageResult = afterSalesMapper.selectPage(pageParam, wrapper);
        Page<AfterSalesDTO> dtoPage = new Page<>(pageResult.getCurrent(), pageResult.getSize(), pageResult.getTotal());

        List<AfterSalesDTO> records = pageResult.getRecords().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());

        dtoPage.setRecords(records);
        return dtoPage;
    }

    /**
     * 获取售后详情（水站端）
     */
    public AfterSalesDetailDTO getAfterSalesDetail(Long stationId, Long afterSalesId) {
        AfterSales afterSales = afterSalesMapper.selectById(afterSalesId);
        if (afterSales == null) {
            throw new BusinessException(ResultCode.AFTER_SALES_NOT_FOUND);
        }

        // 验证售后记录属于该水站
        if (!afterSales.getStationId().equals(stationId)) {
            throw new BusinessException(ResultCode.FORBIDDEN, "无权查看此售后记录");
        }

        return convertToDetailDTO(afterSales);
    }

    /**
     * 创建售后申请（水站端）
     */
    @Transactional
    public CreateAfterSalesResponse createAfterSales(Long stationId, CreateAfterSalesRequestV2 request) {
        // 验证订单
        Order order = orderMapper.selectById(Long.parseLong(request.getOrderId()));
        if (order == null) {
            throw new BusinessException(ResultCode.ORDER_NOT_FOUND);
        }

        // 验证订单属于该水站
        if (!order.getStationId().equals(stationId)) {
            throw new BusinessException(ResultCode.FORBIDDEN, "无权对该订单申请售后");
        }

        // 验证订单状态为已完成
        if (!"completed".equals(order.getStatus())) {
            throw new BusinessException(ResultCode.ORDER_STATUS_NOT_ALLOWED, "只能在订单完成后申请售后");
        }

        // 验证售后商品在订单中存在
        List<OrderItem> orderItems = orderItemMapper.selectList(
                new LambdaQueryWrapper<OrderItem>().eq(OrderItem::getOrderId, order.getId())
        );
        Map<Long, OrderItem> orderItemMap = orderItems.stream()
                .collect(Collectors.toMap(OrderItem::getProductId, item -> item));

        for (CreateAfterSalesRequestV2.AfterSalesItemRequest item : request.getItems()) {
            Long productId = Long.parseLong(item.getProductId());
            OrderItem orderItem = orderItemMap.get(productId);
            if (orderItem == null) {
                throw new BusinessException(ResultCode.PARAM_ERROR, "商品不在订单中: " + item.getProductId());
            }

            // 验证售后数量不超过订单数量
            if (item.getQuantity() > orderItem.getQuantity()) {
                throw new BusinessException(ResultCode.PARAM_ERROR, "售后数量不能超过订单数量");
            }
        }

        // 验证售后类型
        validateAfterSalesType(request.getType());

        // 生成售后单号
        String afterSalesNo = generateAfterSalesNo();

        // 创建售后记录
        AfterSales afterSales = new AfterSales();
        afterSales.setAfterSalesNo(afterSalesNo);
        afterSales.setStationId(stationId);
        afterSales.setOrderId(order.getId());
        afterSales.setType(request.getType());
        afterSales.setReason(request.getReason());
        afterSales.setStatus("pending");
        afterSales.setCreatedAt(LocalDateTime.now());
        afterSalesMapper.insert(afterSales);

        // 保存售后商品明细
        for (CreateAfterSalesRequestV2.AfterSalesItemRequest itemRequest : request.getItems()) {
            AfterSalesItem item = new AfterSalesItem();
            item.setAfterSalesId(afterSales.getId());
            item.setProductId(Long.parseLong(itemRequest.getProductId()));
            item.setQuantity(itemRequest.getQuantity());
            item.setCreateTime(LocalDateTime.now());
            afterSalesItemMapper.insert(item);
        }

        // 处理图片上传
        if (request.getImages() != null && !request.getImages().isEmpty()) {
            for (String base64Image : request.getImages()) {
                try {
                    String imageUrl = saveBase64Image(base64Image, afterSales.getId());
                    if (imageUrl != null && !imageUrl.isEmpty()) {
                        AfterSalesImage image = new AfterSalesImage();
                        image.setAfterSalesId(afterSales.getId());
                        image.setImageUrl(imageUrl);
                        image.setCreateTime(LocalDateTime.now());
                        afterSalesImageMapper.insert(image);
                    }
                } catch (Exception e) {
                    log.error("保存售后图片失败", e);
                }
            }
        }

        // 发送通知
        notificationService.sendAfterSalesCreatedNotification(
                stationId,
                afterSalesNo,
                request.getType()
        );

        log.info("水站 {} 创建售后申请成功，售后单号: {}", stationId, afterSalesNo);

        return new CreateAfterSalesResponse(afterSales.getId(), afterSalesNo, "pending");
    }

    /**
     * 取消售后申请（水站端）
     */
    @Transactional
    public void cancelAfterSales(Long stationId, Long afterSalesId) {
        AfterSales afterSales = afterSalesMapper.selectById(afterSalesId);
        if (afterSales == null) {
            throw new BusinessException(ResultCode.AFTER_SALES_NOT_FOUND);
        }

        // 验证售后记录属于该水站
        if (!afterSales.getStationId().equals(stationId)) {
            throw new BusinessException(ResultCode.FORBIDDEN, "无权取消此售后记录");
        }

        // 只能取消待处理的售后
        if (!"pending".equals(afterSales.getStatus())) {
            throw new BusinessException(ResultCode.ORDER_STATUS_NOT_ALLOWED, "只能取消待处理的售后申请");
        }

        afterSales.setStatus("cancelled");
        afterSales.setUpdateTime(LocalDateTime.now());
        afterSales.setHandleTime(LocalDateTime.now());
        afterSalesMapper.updateById(afterSales);

        log.info("水站 {} 取消了售后申请: {}", stationId, afterSales.getAfterSalesNo());
    }

    /**
     * 处理售后单（仓库端）
     */
    @Transactional
    public AfterSales processAfterSales(Long afterSalesId, ProcessAfterSalesRequest request) {
        AfterSales afterSales = afterSalesMapper.selectById(afterSalesId);
        if (afterSales == null) {
            throw new BusinessException(ResultCode.AFTER_SALES_NOT_FOUND);
        }

        if ("approve".equals(request.getAction())) {
            afterSales.setStatus("completed");
            if (request.getNewOrderId() != null) {
                afterSales.setNewOrderId(Long.parseLong(request.getNewOrderId()));
            }
        } else if ("reject".equals(request.getAction())) {
            afterSales.setStatus("rejected");
            afterSales.setHandleResult(request.getReason());
        } else if ("processing".equals(request.getAction())) {
            afterSales.setStatus("processing");
        } else {
            throw new BusinessException(ResultCode.PARAM_INVALID);
        }

        afterSales.setHandleTime(LocalDateTime.now());
        afterSalesMapper.updateById(afterSales);

        // 发送通知
        String result = "";
        if ("completed".equals(afterSales.getStatus())) {
            result = "已同意售后申请";
        } else if ("rejected".equals(afterSales.getStatus())) {
            result = request.getReason() != null ? request.getReason() : "库存不足";
        }
        notificationService.sendAfterSalesProcessedNotification(
                afterSales.getStationId(),
                afterSales.getAfterSalesNo(),
                afterSales.getStatus(),
                result
        );

        return afterSales;
    }

    /**
     * 仓库获取售后列表
     */
    public Page<AfterSalesDTO> getAfterSalesListForWarehouse(Long warehouseId, String status, Integer page, Integer size) {
        // 获取仓库对应的订单ID列表
        List<Order> orders = orderMapper.selectList(
                new LambdaQueryWrapper<Order>().eq(Order::getWarehouseId, warehouseId)
        );

        if (orders.isEmpty()) {
            return new Page<>(page, size);
        }

        List<Long> orderIds = orders.stream().map(Order::getId).collect(Collectors.toList());

        Page<AfterSales> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<AfterSales> wrapper = new LambdaQueryWrapper<AfterSales>()
                .in(AfterSales::getOrderId, orderIds)
                .orderByDesc(AfterSales::getCreatedAt);

        if (status != null && !status.isEmpty() && !"all".equalsIgnoreCase(status)) {
            wrapper.eq(AfterSales::getStatus, status);
        }

        Page<AfterSales> pageResult = afterSalesMapper.selectPage(pageParam, wrapper);
        Page<AfterSalesDTO> dtoPage = new Page<>(pageResult.getCurrent(), pageResult.getSize(), pageResult.getTotal());

        List<AfterSalesDTO> records = pageResult.getRecords().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());

        dtoPage.setRecords(records);
        return dtoPage;
    }

    /**
     * 获取售后详情（通用）
     */
    public AfterSales getAfterSalesDetail(Long afterSalesId) {
        AfterSales afterSales = afterSalesMapper.selectById(afterSalesId);
        if (afterSales == null) {
            throw new BusinessException(ResultCode.AFTER_SALES_NOT_FOUND);
        }
        return afterSales;
    }

    /**
     * 获取售后类型文本
     */
    public String getTypeText(String type) {
        if (type == null) return "未知";
        return switch (type) {
            case "replenishment" -> "补货";
            case "refund" -> "退款";
            case "return" -> "退货";
            case "quality_issue" -> "质量问题";
            case "wrong_product" -> "错发商品";
            case "shortage" -> "少送";
            case "damage" -> "商品损坏";
            default -> type;
        };
    }

    /**
     * 获取售后状态文本
     */
    public String getStatusText(String status) {
        if (status == null) return "未知";
        return switch (status) {
            case "pending" -> "待处理";
            case "processing" -> "处理中";
            case "completed" -> "已完成";
            case "rejected" -> "已拒绝";
            case "cancelled" -> "已取消";
            default -> status;
        };
    }

    /**
     * 生成售后单号
     */
    private String generateAfterSalesNo() {
        String date = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        // 获取今天最大的序号
        LambdaQueryWrapper<AfterSales> wrapper = new LambdaQueryWrapper<AfterSales>()
                .likeRight(AfterSales::getAfterSalesNo, "AS" + date)
                .orderByDesc(AfterSales::getCreatedAt)
                .last("LIMIT 1");

        AfterSales lastAfterSales = afterSalesMapper.selectOne(wrapper);
        int sequence = 1;
        if (lastAfterSales != null) {
            String lastNo = lastAfterSales.getAfterSalesNo();
            String lastSeq = lastNo.substring(lastNo.length() - 6);
            try {
                sequence = Integer.parseInt(lastSeq) + 1;
            } catch (NumberFormatException ignored) {
            }
        }
        return "AS" + date + String.format("%06d", sequence);
    }

    /**
     * 验证售后类型
     */
    private void validateAfterSalesType(String type) {
        if (type == null || type.isEmpty()) {
            throw new BusinessException(ResultCode.PARAM_ERROR, "售后类型不能为空");
        }

        List<String> validTypes = List.of("replenishment", "refund", "return");
        if (!validTypes.contains(type)) {
            throw new BusinessException(ResultCode.PARAM_ERROR,
                    "无效的售后类型，有效值: " + String.join(", ", validTypes));
        }
    }

    /**
     * 保存Base64图片
     */
    private String saveBase64Image(String base64Image, Long afterSalesId) throws IOException {
        // 移除data:image前缀
        String imageData;
        if (base64Image.contains(",")) {
            imageData = base64Image.substring(base64Image.indexOf(",") + 1);
        } else {
            imageData = base64Image;
        }

        byte[] imageBytes = Base64.getDecoder().decode(imageData);

        // 生成文件名
        String fileName = "aftersales_" + afterSalesId + "_" + System.currentTimeMillis() + ".jpg";

        // 获取上传目录
        String uploadDir = fileService.getFileUrl("").replace("/files", "");
        java.nio.file.Path uploadPath = java.nio.file.Paths.get(
            System.getProperty("java.io.tmpdir"),
            "aftersales",
            java.time.LocalDate.now().format(java.time.format.DateTimeFormatter.ofPattern("yyyy/MM/dd"))
        );

        // 创建目录
        java.nio.file.Files.createDirectories(uploadPath);

        // 保存文件
        java.nio.file.Path filePath = uploadPath.resolve(fileName);
        java.nio.file.Files.write(filePath, imageBytes);

        // 返回相对路径
        String relativePath = "aftersales/" +
            java.time.LocalDate.now().format(java.time.format.DateTimeFormatter.ofPattern("yyyy/MM/dd")) +
            "/" + fileName;

        return fileService.getFileUrl(relativePath);
    }

    /**
     * 转换为DTO
     */
    private AfterSalesDTO convertToDTO(AfterSales afterSales) {
        AfterSalesDTO dto = new AfterSalesDTO();
        dto.setId(afterSales.getId());
        dto.setAfterSalesNo(afterSales.getAfterSalesNo());
        dto.setOrderId(afterSales.getOrderId());
        dto.setType(afterSales.getType());
        dto.setTypeText(getTypeText(afterSales.getType()));
        dto.setReason(afterSales.getReason());
        dto.setStatus(afterSales.getStatus());
        dto.setStatusText(getStatusText(afterSales.getStatus()));
        dto.setHandleResult(afterSales.getHandleResult());
        dto.setHandleTime(afterSales.getHandleTime());
        dto.setCreateTime(afterSales.getCreatedAt());

        // 获取关联订单信息
        Order order = orderMapper.selectById(afterSales.getOrderId());
        if (order != null) {
            dto.setOrderNo(order.getOrderNo());
        }

        // 获取售后商品明细
        List<AfterSalesItem> items = afterSalesItemMapper.selectList(
                new LambdaQueryWrapper<AfterSalesItem>()
                        .eq(AfterSalesItem::getAfterSalesId, afterSales.getId())
        );
        dto.setItems(convertItemsToDTO(items));

        // 获取图片列表
        List<AfterSalesImage> images = afterSalesImageMapper.selectList(
                new LambdaQueryWrapper<AfterSalesImage>()
                        .eq(AfterSalesImage::getAfterSalesId, afterSales.getId())
        );
        dto.setImages(images.stream()
                .map(AfterSalesImage::getImageUrl)
                .collect(Collectors.toList()));

        return dto;
    }

    /**
     * 转换为详情DTO
     */
    private AfterSalesDetailDTO convertToDetailDTO(AfterSales afterSales) {
        AfterSalesDetailDTO dto = new AfterSalesDetailDTO();
        dto.setId(afterSales.getId());
        dto.setAfterSalesNo(afterSales.getAfterSalesNo());
        dto.setOrderId(afterSales.getOrderId());
        dto.setType(afterSales.getType());
        dto.setTypeText(getTypeText(afterSales.getType()));
        dto.setReason(afterSales.getReason());
        dto.setStatus(afterSales.getStatus());
        dto.setStatusText(getStatusText(afterSales.getStatus()));
        dto.setHandleResult(afterSales.getHandleResult());
        dto.setHandleTime(afterSales.getHandleTime());
        dto.setCreateTime(afterSales.getCreatedAt());

        // 获取关联订单信息
        Order order = orderMapper.selectById(afterSales.getOrderId());
        if (order != null) {
            dto.setOrderNo(order.getOrderNo());

            AfterSalesDetailDTO.OrderInfo orderInfo = new AfterSalesDetailDTO.OrderInfo();
            orderInfo.setId(order.getId());
            orderInfo.setOrderNo(order.getOrderNo());
            orderInfo.setStatus(order.getStatus());
            orderInfo.setDeliveryAddress(order.getDeliveryAddress());
            orderInfo.setContactName(order.getContactName());
            orderInfo.setContactPhone(order.getContactPhone());
            orderInfo.setCreateTime(order.getCreateTime());
            dto.setOrder(orderInfo);
        }

        // 获取售后商品明细
        List<AfterSalesItem> items = afterSalesItemMapper.selectList(
                new LambdaQueryWrapper<AfterSalesItem>()
                        .eq(AfterSalesItem::getAfterSalesId, afterSales.getId())
        );
        dto.setItems(convertItemsToDTO(items));

        // 获取图片列表
        List<AfterSalesImage> images = afterSalesImageMapper.selectList(
                new LambdaQueryWrapper<AfterSalesImage>()
                        .eq(AfterSalesImage::getAfterSalesId, afterSales.getId())
        );
        dto.setImages(images.stream()
                .map(AfterSalesImage::getImageUrl)
                .collect(Collectors.toList()));

        return dto;
    }

    /**
     * 转换售后商品明细
     */
    private List<AfterSalesItemDTO> convertItemsToDTO(List<AfterSalesItem> items) {
        List<AfterSalesItemDTO> dtoList = new ArrayList<>();

        for (AfterSalesItem item : items) {
            AfterSalesItemDTO itemDTO = new AfterSalesItemDTO();
            itemDTO.setProductId(item.getProductId());
            itemDTO.setQuantity(item.getQuantity());

            // 获取商品信息
            Product product = productMapper.selectById(item.getProductId());
            if (product != null) {
                itemDTO.setProductName(product.getName());
                itemDTO.setPrice(product.getPrice());
                itemDTO.setAmount(product.getPrice().multiply(BigDecimal.valueOf(item.getQuantity())));
            }

            dtoList.add(itemDTO);
        }

        return dtoList;
    }
}
