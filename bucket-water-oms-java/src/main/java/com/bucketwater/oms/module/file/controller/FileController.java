package com.bucketwater.oms.module.file.controller;

import com.bucketwater.oms.common.response.Result;
import com.bucketwater.oms.module.file.dto.FileResponse;
import com.bucketwater.oms.module.file.service.FileService;
import com.bucketwater.oms.module.user.entity.User;
import com.bucketwater.oms.common.security.PermissionChecker;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.net.MalformedURLException;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/files")
@Tag(name = "文件模块", description = "文件上传下载管理")
public class FileController {

    private static final Logger log = LoggerFactory.getLogger(FileController.class);

    @Autowired
    private FileService fileService;

    @Autowired
    private PermissionChecker permissionChecker;

    @PostMapping("/upload/{type}")
    @Operation(summary = "文件上传", description = "上传单个文件到指定类型目录")
    public Result<FileResponse> upload(
            @PathVariable @Parameter(description = "文件类型: photos/signatures/documents/certs/other") String type,
            @RequestParam @Parameter(description = "文件") MultipartFile file,
            HttpServletRequest request) {
        try {
            User currentUser = (User) request.getAttribute("currentUser");
            permissionChecker.checkUploadPermission(currentUser, type);
            
            FileResponse response = fileService.uploadFile(file, type);
            return Result.ok(response);
        } catch (IllegalArgumentException e) {
            log.warn("文件上传参数错误: {}", e.getMessage());
            return Result.error(e.getMessage());
        } catch (Exception e) {
            log.error("文件上传失败", e);
            return Result.error("文件上传失败: " + e.getMessage());
        }
    }

    @PostMapping("/upload/multiple/{type}")
    @Operation(summary = "多文件上传", description = "批量上传多个文件到指定类型目录")
    public Result<List<FileResponse>> uploadMultiple(
            @PathVariable @Parameter(description = "文件类型: photos/signatures/documents/certs/other") String type,
            @RequestParam @Parameter(description = "文件列表") MultipartFile[] files,
            HttpServletRequest request) {
        try {
            User currentUser = (User) request.getAttribute("currentUser");
            permissionChecker.checkUploadPermission(currentUser, type);
            
            List<FileResponse> responses = fileService.uploadMultipleFiles(files, type);
            return Result.ok(responses);
        } catch (IllegalArgumentException e) {
            log.warn("多文件上传参数错误: {}", e.getMessage());
            return Result.error(e.getMessage());
        } catch (Exception e) {
            log.error("多文件上传失败", e);
            return Result.error("多文件上传失败: " + e.getMessage());
        }
    }

    @PostMapping("/upload/photos")
    @Operation(summary = "上传签收照片", description = "上传配送签收照片（至少3张）")
    public Result<List<String>> uploadPhotos(
            @RequestParam @Parameter(description = "签收照片（至少3张）") MultipartFile[] files,
            HttpServletRequest request) {
        try {
            User currentUser = (User) request.getAttribute("currentUser");
            permissionChecker.checkUploadPermission(currentUser, "photos");
            
            List<String> urls = fileService.uploadSignPhotos(files);
            return Result.ok(urls);
        } catch (IllegalArgumentException e) {
            log.warn("签收照片上传参数错误: {}", e.getMessage());
            return Result.error(e.getMessage());
        } catch (Exception e) {
            log.error("签收照片上传失败", e);
            return Result.error("签收照片上传失败: " + e.getMessage());
        }
    }

    @PostMapping("/upload/signature")
    @Operation(summary = "上传签名", description = "上传客户电子签名")
    public Result<FileResponse> uploadSignature(
            @RequestParam @Parameter(description = "签名图片") MultipartFile file,
            HttpServletRequest request) {
        try {
            User currentUser = (User) request.getAttribute("currentUser");
            permissionChecker.checkUploadPermission(currentUser, "signatures");
            
            FileResponse response = fileService.uploadFile(file, "signatures");
            return Result.ok(response);
        } catch (IllegalArgumentException e) {
            log.warn("签名上传参数错误: {}", e.getMessage());
            return Result.error(e.getMessage());
        } catch (Exception e) {
            log.error("签名上传失败", e);
            return Result.error("签名上传失败: " + e.getMessage());
        }
    }

    @GetMapping("/download/{filePath:.*}")
    @Operation(summary = "文件下载", description = "下载指定路径的文件")
    public ResponseEntity<Resource> download(
            @PathVariable @Parameter(description = "文件路径（相对路径）") String filePath) {
        try {
            Resource resource = fileService.loadFileAsResource(filePath);
            String filename = filePath.substring(filePath.lastIndexOf('/') + 1);
            
            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_DISPOSITION, 
                           "attachment; filename=\"" + filename + "\"")
                    .contentType(MediaType.APPLICATION_OCTET_STREAM)
                    .body(resource);
        } catch (MalformedURLException e) {
            log.error("文件下载失败: 无效的路径", e);
            return ResponseEntity.notFound().build();
        } catch (IllegalArgumentException e) {
            log.error("文件下载失败: {}", e.getMessage());
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            log.error("文件下载失败", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    @GetMapping("/view/{filePath:.*}")
    @Operation(summary = "文件预览", description = "在线预览图片等文件")
    public ResponseEntity<Resource> view(
            @PathVariable @Parameter(description = "文件路径（相对路径）") String filePath) {
        try {
            Resource resource = fileService.loadFileAsResource(filePath);
            
            String extension = fileService.getFileExtension(filePath).toLowerCase();
            MediaType mediaType = getMediaType(extension);
            
            return ResponseEntity.ok()
                    .contentType(mediaType)
                    .body(resource);
        } catch (MalformedURLException e) {
            log.error("文件预览失败: 无效的路径", e);
            return ResponseEntity.notFound().build();
        } catch (IllegalArgumentException e) {
            log.error("文件预览失败: {}", e.getMessage());
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            log.error("文件预览失败", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    @DeleteMapping("/{filePath:.*}")
    @Operation(summary = "删除文件", description = "删除指定路径的文件")
    public Result<Void> delete(
            @PathVariable @Parameter(description = "文件路径（相对路径）") String filePath) {
        try {
            fileService.deleteFile(filePath);
            return Result.ok(null);
        } catch (IllegalArgumentException e) {
            log.warn("文件删除参数错误: {}", e.getMessage());
            return Result.error(e.getMessage());
        } catch (Exception e) {
            log.error("文件删除失败", e);
            return Result.error("文件删除失败: " + e.getMessage());
        }
    }

    @GetMapping("/info/{filePath:.*}")
    @Operation(summary = "获取文件信息", description = "获取指定文件的信息")
    public Result<Map<String, Object>> getFileInfo(
            @PathVariable @Parameter(description = "文件路径（相对路径）") String filePath) {
        try {
            if (!fileService.fileExists(filePath)) {
                return Result.error("文件不存在");
            }

            long fileSize = fileService.getFileSize(filePath);
            String extension = fileService.getFileExtension(filePath);
            String filename = fileService.getFileNameWithoutExtension(filePath);
            String url = fileService.getFileUrl(filePath);

            Map<String, Object> info = Map.of(
                "filePath", filePath,
                "fileName", filename,
                "extension", extension,
                "fileSize", fileSize,
                "fileUrl", url,
                "exists", true
            );

            return Result.ok(info);
        } catch (Exception e) {
            log.error("获取文件信息失败", e);
            return Result.error("获取文件信息失败: " + e.getMessage());
        }
    }

    @GetMapping("/list")
    @Operation(summary = "列出文件", description = "列出指定目录下的文件")
    public Result<List<String>> listFiles(
            @RequestParam(required = false, defaultValue = "") 
            @Parameter(description = "目录路径（可选）") String directory) {
        try {
            List<String> files = fileService.listFiles(directory);
            return Result.ok(files);
        } catch (Exception e) {
            log.error("列出文件失败", e);
            return Result.error("列出文件失败: " + e.getMessage());
        }
    }

    @PostMapping("/mkdir")
    @Operation(summary = "创建目录", description = "在上传目录中创建子目录")
    public Result<Void> createDirectory(
            @RequestParam @Parameter(description = "目录路径") String directory) {
        try {
            fileService.createDirectory(directory);
            return Result.ok(null);
        } catch (IllegalArgumentException e) {
            log.warn("创建目录参数错误: {}", e.getMessage());
            return Result.error(e.getMessage());
        } catch (Exception e) {
            log.error("创建目录失败", e);
            return Result.error("创建目录失败: " + e.getMessage());
        }
    }

    private MediaType getMediaType(String extension) {
        return switch (extension) {
            case "jpg", "jpeg" -> MediaType.IMAGE_JPEG;
            case "png" -> MediaType.IMAGE_PNG;
            case "gif" -> MediaType.IMAGE_GIF;
            case "bmp" -> new MediaType("image", "bmp");
            case "webp" -> new MediaType("image", "webp");
            case "pdf" -> MediaType.APPLICATION_PDF;
            case "txt" -> MediaType.TEXT_PLAIN;
            default -> MediaType.APPLICATION_OCTET_STREAM;
        };
    }
}
