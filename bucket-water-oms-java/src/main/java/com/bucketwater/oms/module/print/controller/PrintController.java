package com.bucketwater.oms.module.print.controller;

import com.bucketwater.oms.common.response.Result;
import com.bucketwater.oms.module.driver.entity.DriverReturn;
import com.bucketwater.oms.module.driver.mapper.DriverReturnMapper;
import com.bucketwater.oms.module.print.service.PrintService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/prints")
@Tag(name = "打印模块", description = "蓝牙打印服务")
public class PrintController {

    @Autowired
    private PrintService printService;

    @Autowired
    private DriverReturnMapper driverReturnMapper;

    @GetMapping("/pick-list/{orderId}")
    @Operation(summary = "生成备货单", description = "生成备货单内容")
    public Result<String> generatePickList(
            @PathVariable @Parameter(description = "订单ID") Long orderId) {
        String content = printService.generatePickList(orderId);
        return Result.ok(content);
    }

    @GetMapping("/pick-list/{orderId}/raw")
    @Operation(summary = "获取备货单原始数据", description = "获取备货单ESC/POS指令")
    public ResponseEntity<byte[]> getPickListRaw(
            @PathVariable @Parameter(description = "订单ID") Long orderId,
            @RequestParam(defaultValue = "80mm") @Parameter(description = "打印机类型") String printerType) {
        String content = printService.generatePickList(orderId);
        byte[] commands = printService.getEscPosCommands(content, printerType);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_OCTET_STREAM);
        headers.setContentDispositionFormData("attachment", "picklist_" + orderId + ".bin");

        return ResponseEntity.ok()
                .headers(headers)
                .body(commands);
    }

    @GetMapping("/return-list/{returnId}")
    @Operation(summary = "生成回仓单", description = "生成回仓单内容")
    public Result<String> generateReturnList(
            @PathVariable @Parameter(description = "回仓ID") Long returnId,
            @RequestParam @Parameter(description = "司机ID") Long driverId,
            @RequestParam @Parameter(description = "仓库ID") Long warehouseId,
            @RequestParam @Parameter(description = "桶数量") Integer bucketQty) {
        String content = printService.generateReturnList(returnId, driverId, warehouseId, bucketQty);
        return Result.ok(content);
    }

    @GetMapping("/return-list/{returnId}/raw")
    @Operation(summary = "获取回仓单原始数据", description = "获取回仓单ESC/POS指令")
    public ResponseEntity<byte[]> getReturnListRaw(
            @PathVariable @Parameter(description = "回仓ID") Long returnId) {
        DriverReturn driverReturn = driverReturnMapper.selectById(returnId);
        if (driverReturn == null) {
            return ResponseEntity.notFound().build();
        }

        String content = printService.generateReturnList(
            returnId,
            driverReturn.getDriverId(),
            driverReturn.getWarehouseId(),
            driverReturn.getBucketReturned()
        );
        byte[] commands = printService.getEscPosCommands(content, "80mm");

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_OCTET_STREAM);
        headers.setContentDispositionFormData("attachment", "returnlist_" + returnId + ".bin");

        return ResponseEntity.ok()
                .headers(headers)
                .body(commands);
    }

    @GetMapping("/delivery-list/{orderId}")
    @Operation(summary = "生成配送单", description = "生成配送单内容")
    public Result<String> generateDeliveryList(
            @PathVariable @Parameter(description = "订单ID") Long orderId) {
        String content = printService.generateDeliveryList(orderId);
        return Result.ok(content);
    }

    @GetMapping("/delivery-list/{orderId}/raw")
    @Operation(summary = "获取配送单原始数据", description = "获取配送单ESC/POS指令")
    public ResponseEntity<byte[]> getDeliveryListRaw(
            @PathVariable @Parameter(description = "订单ID") Long orderId,
            @RequestParam(defaultValue = "80mm") @Parameter(description = "打印机类型") String printerType) {
        String content = printService.generateDeliveryList(orderId);
        byte[] commands = printService.getEscPosCommands(content, printerType);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_OCTET_STREAM);
        headers.setContentDispositionFormData("attachment", "deliverylist_" + orderId + ".bin");

        return ResponseEntity.ok()
                .headers(headers)
                .body(commands);
    }
}
