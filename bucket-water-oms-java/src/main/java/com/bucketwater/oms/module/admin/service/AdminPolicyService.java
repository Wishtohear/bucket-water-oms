package com.bucketwater.oms.module.admin.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.bucketwater.oms.common.exception.BusinessException;
import com.bucketwater.oms.common.response.ResultCode;
import com.bucketwater.oms.module.admin.dto.PolicyTemplateDTO;
import com.bucketwater.oms.module.admin.entity.PolicyPricingRule;
import com.bucketwater.oms.module.admin.entity.PolicyTemplate;
import com.bucketwater.oms.module.admin.mapper.PolicyPricingRuleMapper;
import com.bucketwater.oms.module.admin.mapper.PolicyTemplateMapper;
import com.bucketwater.oms.module.product.entity.Product;
import com.bucketwater.oms.module.product.mapper.ProductMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class AdminPolicyService {

    @Autowired
    private PolicyTemplateMapper policyTemplateMapper;

    @Autowired
    private PolicyPricingRuleMapper pricingRuleMapper;

    @Autowired
    private ProductMapper productMapper;

    public List<PolicyTemplateDTO> getPolicyTemplates() {
        List<PolicyTemplate> templates = policyTemplateMapper.selectList(
            new LambdaQueryWrapper<PolicyTemplate>()
                .eq(PolicyTemplate::getDeleted, 0)
                .orderByDesc(PolicyTemplate::getCreateTime)
        );

        List<PolicyTemplateDTO> result = new ArrayList<>();
        for (PolicyTemplate template : templates) {
            PolicyTemplateDTO dto = convertToDTO(template);
            result.add(dto);
        }
        return result;
    }

    public PolicyTemplateDTO getPolicyTemplate(Long templateId) {
        PolicyTemplate template = policyTemplateMapper.selectOne(
            new LambdaQueryWrapper<PolicyTemplate>()
                .eq(PolicyTemplate::getId, templateId)
                .eq(PolicyTemplate::getDeleted, 0)
        );

        if (template == null) {
            throw new BusinessException(ResultCode.DATA_NOT_FOUND, "政策模板不存在");
        }

        return convertToDTO(template);
    }

    @Transactional
    public void createPolicyTemplate(PolicyTemplateDTO request) {
        validatePolicyData(request);

        PolicyTemplate template = new PolicyTemplate();
        template.setName(request.getName());
        template.setType(request.getType() != null ? request.getType() : "default");
        template.setStatus(request.getStatus() != null ? request.getStatus() : "active");
        template.setRemark(request.getRemark() != null ? request.getRemark() : request.getDescription());
        template.setBucketWaterPrice(request.getBucketWaterPrice());
        template.setMinOrderQuantity(request.getMinOrderQuantity() != null ?
            request.getMinOrderQuantity().intValue() : 50);
        template.setCreditLimit(request.getCreditLimit() != null ?
            request.getCreditLimit() : BigDecimal.ZERO);
        template.setPaymentType(request.getPaymentType() != null ? request.getPaymentType() : "immediate");
        template.setPreDeposit(request.getPreDeposit() != null ? request.getPreDeposit() : BigDecimal.ZERO);
        template.setBucketThreshold(request.getBucketThreshold() != null ? request.getBucketThreshold() : 10);
        template.setCoverageCount(0);
        template.setDeleted(0);

        policyTemplateMapper.insert(template);

        List<PolicyTemplateDTO.ProductPrice> pricingRules = request.getPricingRules();
        if (pricingRules != null && !pricingRules.isEmpty()) {
            for (PolicyTemplateDTO.ProductPrice pp : pricingRules) {
                validateProductPrice(pp);
                savePricingRule(template.getId(), pp);
            }
        }
    }

    @Transactional
    public void updatePolicyTemplate(Long templateId, PolicyTemplateDTO request) {
        validatePolicyData(request);

        PolicyTemplate template = policyTemplateMapper.selectOne(
            new LambdaQueryWrapper<PolicyTemplate>()
                .eq(PolicyTemplate::getId, templateId)
                .eq(PolicyTemplate::getDeleted, 0)
        );

        if (template == null) {
            throw new BusinessException(ResultCode.DATA_NOT_FOUND, "政策模板不存在");
        }

        if (request.getName() != null) {
            template.setName(request.getName());
        }
        if (request.getType() != null) {
            template.setType(request.getType());
        }
        if (request.getStatus() != null) {
            template.setStatus(request.getStatus());
        }
        if (request.getRemark() != null) {
            template.setRemark(request.getRemark());
        } else if (request.getDescription() != null) {
            template.setRemark(request.getDescription());
        }
        if (request.getBucketWaterPrice() != null) {
            template.setBucketWaterPrice(request.getBucketWaterPrice());
        }
        if (request.getMinOrderQuantity() != null) {
            template.setMinOrderQuantity(request.getMinOrderQuantity().intValue());
        }
        if (request.getCreditLimit() != null) {
            template.setCreditLimit(request.getCreditLimit());
        }
        if (request.getPaymentType() != null) {
            template.setPaymentType(request.getPaymentType());
        }
        if (request.getPreDeposit() != null) {
            template.setPreDeposit(request.getPreDeposit());
        }
        if (request.getBucketThreshold() != null) {
            template.setBucketThreshold(request.getBucketThreshold());
        }

        policyTemplateMapper.updateById(template);

        List<PolicyTemplateDTO.ProductPrice> pricingRules = request.getPricingRules();
        if (pricingRules != null) {
            LambdaQueryWrapper<PolicyPricingRule> ruleWrapper = new LambdaQueryWrapper<>();
            ruleWrapper.eq(PolicyPricingRule::getPolicyId, templateId);
            pricingRuleMapper.delete(ruleWrapper);

            for (PolicyTemplateDTO.ProductPrice pp : pricingRules) {
                validateProductPrice(pp);
                savePricingRule(template.getId(), pp);
            }
        }
    }

    @Transactional
    public void deletePolicyTemplate(Long templateId) {
        PolicyTemplate template = policyTemplateMapper.selectOne(
            new LambdaQueryWrapper<PolicyTemplate>()
                .eq(PolicyTemplate::getId, templateId)
                .eq(PolicyTemplate::getDeleted, 0)
        );

        if (template == null) {
            throw new BusinessException(ResultCode.DATA_NOT_FOUND, "政策模板不存在");
        }

        LambdaQueryWrapper<PolicyPricingRule> ruleWrapper = new LambdaQueryWrapper<>();
        ruleWrapper.eq(PolicyPricingRule::getPolicyId, templateId);
        pricingRuleMapper.delete(ruleWrapper);

        policyTemplateMapper.deleteById(templateId);
    }

    @Transactional
    public PolicyTemplateDTO copyPolicyTemplate(Long templateId) {
        PolicyTemplate original = policyTemplateMapper.selectOne(
            new LambdaQueryWrapper<PolicyTemplate>()
                .eq(PolicyTemplate::getId, templateId)
                .eq(PolicyTemplate::getDeleted, 0)
        );

        if (original == null) {
            throw new BusinessException(ResultCode.DATA_NOT_FOUND, "政策模板不存在");
        }

        PolicyTemplate copy = new PolicyTemplate();
        copy.setName(original.getName() + " (副本)");
        copy.setType(original.getType());
        copy.setStatus("inactive");
        copy.setRemark(original.getRemark());
        copy.setBucketWaterPrice(original.getBucketWaterPrice());
        copy.setMinOrderQuantity(original.getMinOrderQuantity());
        copy.setCreditLimit(original.getCreditLimit());
        copy.setPaymentType(original.getPaymentType());
        copy.setPreDeposit(original.getPreDeposit());
        copy.setBucketThreshold(original.getBucketThreshold());
        copy.setCoverageCount(0);
        copy.setStartDate(original.getStartDate());
        copy.setEndDate(original.getEndDate());
        copy.setGiftRatio(original.getGiftRatio());
        copy.setDeleted(0);

        policyTemplateMapper.insert(copy);

        LambdaQueryWrapper<PolicyPricingRule> ruleWrapper = new LambdaQueryWrapper<>();
        ruleWrapper.eq(PolicyPricingRule::getPolicyId, templateId);
        List<PolicyPricingRule> originalRules = pricingRuleMapper.selectList(ruleWrapper);

        for (PolicyPricingRule originalRule : originalRules) {
            PolicyPricingRule copyRule = new PolicyPricingRule();
            copyRule.setPolicyId(copy.getId());
            copyRule.setProductId(originalRule.getProductId());
            copyRule.setProductName(originalRule.getProductName());
            copyRule.setCategory(originalRule.getCategory());
            copyRule.setPrice(originalRule.getPrice());
            copyRule.setMinQuantity(originalRule.getMinQuantity());
            copyRule.setDeleted(0);
            pricingRuleMapper.insert(copyRule);
        }

        return convertToDTO(copy);
    }

    @Transactional
    public void enablePolicyTemplate(Long templateId) {
        PolicyTemplate template = policyTemplateMapper.selectOne(
            new LambdaQueryWrapper<PolicyTemplate>()
                .eq(PolicyTemplate::getId, templateId)
                .eq(PolicyTemplate::getDeleted, 0)
        );

        if (template == null) {
            throw new BusinessException(ResultCode.DATA_NOT_FOUND, "政策模板不存在");
        }

        template.setStatus("active");
        policyTemplateMapper.updateById(template);
    }

    @Transactional
    public void disablePolicyTemplate(Long templateId) {
        PolicyTemplate template = policyTemplateMapper.selectOne(
            new LambdaQueryWrapper<PolicyTemplate>()
                .eq(PolicyTemplate::getId, templateId)
                .eq(PolicyTemplate::getDeleted, 0)
        );

        if (template == null) {
            throw new BusinessException(ResultCode.DATA_NOT_FOUND, "政策模板不存在");
        }

        template.setStatus("inactive");
        policyTemplateMapper.updateById(template);
    }

    public List<PolicyTemplateDTO.ProductPrice> getProductPriceList() {
        List<Product> products = productMapper.selectList(
            new LambdaQueryWrapper<Product>()
                .eq(Product::getStatus, "active")
                .orderByAsc(Product::getCategory)
        );

        List<PolicyTemplateDTO.ProductPrice> prices = new ArrayList<>();
        for (Product product : products) {
            PolicyTemplateDTO.ProductPrice pp = new PolicyTemplateDTO.ProductPrice();
            pp.setProductId(product.getId() != null ? product.getId().toString() : null);
            pp.setProductName(product.getName());
            pp.setCategory(product.getCategory());
            pp.setStandardPrice(product.getPrice());
            pp.setGuidePriceMin(product.getPrice().multiply(new BigDecimal("1.8")));
            pp.setGuidePriceMax(product.getPrice().multiply(new BigDecimal("2.2")));
            prices.add(pp);
        }

        return prices;
    }

    public void updateProductPrice(Long productId, BigDecimal newPrice) {
        Product product = productMapper.selectById(productId);
        if (product == null) {
            throw new BusinessException(ResultCode.DATA_NOT_FOUND, "产品不存在");
        }

        product.setPrice(newPrice);
        productMapper.updateById(product);
    }

    private PolicyTemplateDTO convertToDTO(PolicyTemplate template) {
        PolicyTemplateDTO dto = new PolicyTemplateDTO();
        dto.setId(template.getId());
        dto.setName(template.getName());
        dto.setType(template.getType());
        dto.setStatus(template.getStatus());
        dto.setRemark(template.getRemark());
        dto.setDescription(template.getRemark());
        dto.setBucketWaterPrice(template.getBucketWaterPrice());
        dto.setMinOrderQuantity(template.getMinOrderQuantity() != null ?
            new BigDecimal(template.getMinOrderQuantity()) : BigDecimal.ZERO);
        dto.setCreditLimit(template.getCreditLimit());
        dto.setPaymentType(template.getPaymentType());
        dto.setPreDeposit(template.getPreDeposit());
        dto.setBucketThreshold(template.getBucketThreshold());
        dto.setCoverageCount(template.getCoverageCount());
        dto.setStartDate(template.getStartDate() != null ?
            template.getStartDate().toString() : null);
        dto.setEndDate(template.getEndDate() != null ?
            template.getEndDate().toString() : null);
        dto.setGiftRatio(template.getGiftRatio());

        String typeText = switch (template.getType()) {
            case "vip" -> "VIP客户";
            case "promotion" -> "限时促销";
            default -> "默认通用";
        };
        dto.setTypeText(typeText);

        LambdaQueryWrapper<PolicyPricingRule> ruleWrapper = new LambdaQueryWrapper<>();
        ruleWrapper.eq(PolicyPricingRule::getPolicyId, template.getId());
        List<PolicyPricingRule> rules = pricingRuleMapper.selectList(ruleWrapper);

        List<PolicyTemplateDTO.ProductPrice> pricingRules = rules.stream()
            .map(rule -> {
                PolicyTemplateDTO.ProductPrice pp = new PolicyTemplateDTO.ProductPrice();
                pp.setProductId(rule.getProductId() != null ? rule.getProductId().toString() : null);
                pp.setProductName(rule.getProductName());
                pp.setCategory(rule.getCategory());
                pp.setStandardPrice(rule.getPrice());
                Product product = rule.getProductId() != null ? productMapper.selectById(rule.getProductId()) : null;
                if (product != null) {
                    pp.setGuidePriceMin(product.getGuidePriceMin());
                    pp.setGuidePriceMax(product.getGuidePriceMax());
                } else {
                    pp.setGuidePriceMin(rule.getPrice());
                    pp.setGuidePriceMax(rule.getPrice().multiply(new BigDecimal("1.2")));
                }
                pp.setPrice(rule.getPrice());
                pp.setTierPrice(rule.getPrice());
                pp.setTierThreshold(rule.getMinQuantity());
                pp.setMinQuantity(rule.getMinQuantity());
                return pp;
            })
            .collect(Collectors.toList());
        dto.setPricingRules(pricingRules);

        return dto;
    }

    private void validatePolicyData(PolicyTemplateDTO request) {
        if (request.getName() == null || request.getName().isBlank()) {
            throw new BusinessException(ResultCode.PARAM_ERROR, "政策名称不能为空");
        }
        if (request.getType() == null || request.getType().isBlank()) {
            throw new BusinessException(ResultCode.PARAM_ERROR, "政策类型不能为空");
        }
        if (!request.getType().equals("default") && !request.getType().equals("vip") && !request.getType().equals("promotion")) {
            throw new BusinessException(ResultCode.PARAM_ERROR, "无效的政策类型");
        }
    }

    private void validateProductPrice(PolicyTemplateDTO.ProductPrice pp) {
        if (pp.getProductId() == null || pp.getProductId().isBlank()) {
            return;
        }

        Long productId;
        try {
            productId = Long.parseLong(pp.getProductId());
        } catch (NumberFormatException e) {
            return;
        }

        Product product = productMapper.selectById(productId);
        if (product == null) {
            throw new BusinessException(ResultCode.DATA_NOT_FOUND, "商品不存在: " + pp.getProductName());
        }

        BigDecimal price = pp.getPrice() != null ? pp.getPrice() : BigDecimal.ZERO;
        if (product.getGuidePriceMin() != null && price.compareTo(product.getGuidePriceMin()) < 0) {
            throw new BusinessException(ResultCode.PARAM_ERROR,
                String.format("商品[%s]的单价 %.2f 不能低于最低指导价 %.2f",
                    pp.getProductName(), price, product.getGuidePriceMin()));
        }

        Integer minQuantity = pp.getMinQuantity();
        if (minQuantity == null || minQuantity < 1) {
            throw new BusinessException(ResultCode.PARAM_ERROR,
                String.format("商品[%s]的最低起订量不能少于1", pp.getProductName()));
        }
    }

    private void savePricingRule(Long policyId, PolicyTemplateDTO.ProductPrice pp) {
        PolicyPricingRule rule = new PolicyPricingRule();
        rule.setPolicyId(policyId);

        if (pp.getProductId() != null && !pp.getProductId().equals("default")) {
            try {
                rule.setProductId(Long.parseLong(pp.getProductId()));
            } catch (NumberFormatException e) {
                rule.setProductId(null);
            }
        } else {
            rule.setProductId(null);
        }

        rule.setProductName(pp.getProductName());
        rule.setCategory(pp.getCategory());

        BigDecimal price = pp.getPrice();
        if (price == null) {
            price = pp.getStandardPrice() != null ? pp.getStandardPrice() :
                (pp.getTierPrice() != null ? pp.getTierPrice() : BigDecimal.ZERO);
        }
        rule.setPrice(price);

        Integer minQty = pp.getMinQuantity();
        if (minQty == null) {
            minQty = pp.getTierThreshold() != null ? pp.getTierThreshold() : 1;
        }
        rule.setMinQuantity(minQty);

        rule.setDeleted(0);
        pricingRuleMapper.insert(rule);
    }
}
