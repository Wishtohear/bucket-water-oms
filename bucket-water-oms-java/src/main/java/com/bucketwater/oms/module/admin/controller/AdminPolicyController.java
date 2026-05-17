package com.bucketwater.oms.module.admin.controller;

import com.bucketwater.oms.common.response.Result;
import com.bucketwater.oms.common.security.RequireRole;
import com.bucketwater.oms.module.admin.dto.PolicyTemplateDTO;
import com.bucketwater.oms.module.admin.service.AdminPolicyService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;

@RestController
@RequestMapping("/admin/policies")
@Tag(name = "管理端-销售政策", description = "销售政策管理和产品定价")
@RequireRole({"PLATFORM_ADMIN", "FACTORY_ADMIN"})
public class AdminPolicyController {

    @Autowired
    private AdminPolicyService policyService;

    @GetMapping("/templates")
    @Operation(summary = "获取政策模板列表", description = "获取所有销售政策模板")
    public Result<List<PolicyTemplateDTO>> getPolicyTemplates() {
        List<PolicyTemplateDTO> templates = policyService.getPolicyTemplates();
        return Result.ok(templates);
    }

    @GetMapping("/templates/{templateId}")
    @Operation(summary = "获取政策模板详情", description = "根据ID获取政策模板详细信息")
    public Result<PolicyTemplateDTO> getPolicyTemplate(
            @PathVariable @Parameter(description = "模板ID") Long templateId) {
        PolicyTemplateDTO template = policyService.getPolicyTemplate(templateId);
        return Result.ok(template);
    }

    @PostMapping("/templates")
    @Operation(summary = "创建政策模板", description = "创建新的销售政策模板")
    public Result<Void> createPolicyTemplate(@RequestBody PolicyTemplateDTO template) {
        policyService.createPolicyTemplate(template);
        return Result.ok();
    }

    @PutMapping("/templates/{templateId}")
    @Operation(summary = "更新政策模板", description = "更新销售政策模板")
    public Result<Void> updatePolicyTemplate(
            @PathVariable @Parameter(description = "模板ID") Long templateId,
            @RequestBody PolicyTemplateDTO template) {
        policyService.updatePolicyTemplate(templateId, template);
        return Result.ok();
    }

    @DeleteMapping("/templates/{templateId}")
    @Operation(summary = "删除政策模板", description = "删除指定的销售政策模板")
    public Result<Void> deletePolicyTemplate(
            @PathVariable @Parameter(description = "模板ID") Long templateId) {
        policyService.deletePolicyTemplate(templateId);
        return Result.ok();
    }

    @PostMapping("/templates/{templateId}/copy")
    @Operation(summary = "复制政策模板", description = "复制指定的销售政策模板")
    public Result<PolicyTemplateDTO> copyPolicyTemplate(
            @PathVariable @Parameter(description = "模板ID") Long templateId) {
        PolicyTemplateDTO newTemplate = policyService.copyPolicyTemplate(templateId);
        return Result.ok(newTemplate);
    }

    @PostMapping("/templates/{templateId}/enable")
    @Operation(summary = "启用政策模板", description = "启用指定的销售政策模板")
    public Result<Void> enablePolicyTemplate(
            @PathVariable @Parameter(description = "模板ID") Long templateId) {
        policyService.enablePolicyTemplate(templateId);
        return Result.ok();
    }

    @PostMapping("/templates/{templateId}/disable")
    @Operation(summary = "禁用政策模板", description = "禁用指定的销售政策模板")
    public Result<Void> disablePolicyTemplate(
            @PathVariable @Parameter(description = "模板ID") Long templateId) {
        policyService.disablePolicyTemplate(templateId);
        return Result.ok();
    }

    @GetMapping("/products")
    @Operation(summary = "获取产品定价列表", description = "获取所有产品的定价信息")
    public Result<List<PolicyTemplateDTO.ProductPrice>> getProductPrices() {
        List<PolicyTemplateDTO.ProductPrice> prices = policyService.getProductPriceList();
        return Result.ok(prices);
    }

    @PutMapping("/products/{productId}/price")
    @Operation(summary = "调整产品定价", description = "修改产品标准出厂价")
    public Result<Void> updateProductPrice(
            @PathVariable @Parameter(description = "产品ID") Long productId,
            @RequestParam @Parameter(description = "新价格") BigDecimal price) {
        policyService.updateProductPrice(productId, price);
        return Result.ok();
    }
}
