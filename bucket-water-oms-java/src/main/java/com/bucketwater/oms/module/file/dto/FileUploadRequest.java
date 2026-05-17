package com.bucketwater.oms.module.file.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

@Schema(description = "文件上传请求")
public class FileUploadRequest {

    @Schema(description = "文件类型: photos/signatures/documents/certs/other", example = "photos")
    @NotBlank(message = "文件类型不能为空")
    @Size(max = 50, message = "文件类型长度不能超过50")
    private String type;

    @Schema(description = "原始文件名（可选，后端会自动获取）", example = "photo.jpg")
    private String originalName;

    @Schema(description = "业务ID（可选，用于关联业务）", example = "order_123")
    private String businessId;

    @Schema(description = "业务类型（可选）", example = "order")
    private String businessType;

    public FileUploadRequest() {
    }

    public FileUploadRequest(String type) {
        this.type = type;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getOriginalName() {
        return originalName;
    }

    public void setOriginalName(String originalName) {
        this.originalName = originalName;
    }

    public String getBusinessId() {
        return businessId;
    }

    public void setBusinessId(String businessId) {
        this.businessId = businessId;
    }

    public String getBusinessType() {
        return businessType;
    }

    public void setBusinessType(String businessType) {
        this.businessType = businessType;
    }
}
