package com.bucketwater.oms.module.file.service;

import com.bucketwater.oms.module.file.config.FileConfig;
import com.bucketwater.oms.module.file.dto.FileResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.*;

@Service
public class FileService {

    private static final Logger log = LoggerFactory.getLogger(FileService.class);

    private static final Set<String> ALLOWED_IMAGE_EXTENSIONS = new HashSet<>(Arrays.asList(
        "jpg", "jpeg", "png", "gif", "bmp", "webp"
    ));

    private static final Set<String> ALLOWED_DOCUMENT_EXTENSIONS = new HashSet<>(Arrays.asList(
        "pdf", "doc", "docx", "xls", "xlsx", "ppt", "pptx", "txt"
    ));

    @Autowired
    private FileConfig fileConfig;

    public FileResponse uploadFile(MultipartFile file, String type) throws IOException {
        if (file.isEmpty()) {
            throw new IllegalArgumentException("文件不能为空");
        }

        if (file.getSize() > fileConfig.getMaxSize()) {
            throw new IllegalArgumentException("文件大小超过限制，最大允许 " + (fileConfig.getMaxSize() / 1024 / 1024) + "MB");
        }

        String originalFilename = file.getOriginalFilename();
        if (originalFilename == null || originalFilename.isBlank()) {
            originalFilename = "unknown";
        }

        String extension = getFileExtension(originalFilename).toLowerCase();
        validateFileExtension(extension, type);

        String datePath = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy/MM/dd"));
        String uploadPath = fileConfig.getUploadDir() + File.separator + type + File.separator + datePath;

        Path path = Paths.get(uploadPath);
        if (!Files.exists(path)) {
            Files.createDirectories(path);
        }

        String newFileName = generateFileName(extension);
        Path filePath = path.resolve(newFileName);

        try (InputStream inputStream = file.getInputStream()) {
            Files.copy(inputStream, filePath, StandardCopyOption.REPLACE_EXISTING);
        }

        String relativePath = type + "/" + datePath + "/" + newFileName;
        
        log.info("文件上传成功: {}, 类型: {}, 原始文件名: {}", relativePath, type, originalFilename);

        return FileResponse.of(
            newFileName,
            relativePath,
            getFileUrl(relativePath),
            type,
            file.getSize(),
            originalFilename
        );
    }

    public List<FileResponse> uploadMultipleFiles(MultipartFile[] files, String type) throws IOException {
        if (files == null || files.length == 0) {
            throw new IllegalArgumentException("文件列表不能为空");
        }

        List<FileResponse> responses = new ArrayList<>();
        for (MultipartFile file : files) {
            if (!file.isEmpty()) {
                FileResponse response = uploadFile(file, type);
                responses.add(response);
            }
        }
        return responses;
    }

    public List<String> uploadSignPhotos(MultipartFile[] files) throws IOException {
        if (files == null || files.length == 0) {
            throw new IllegalArgumentException("签收照片不能为空");
        }

        if (files.length < 3) {
            throw new IllegalArgumentException("签收照片至少需要3张");
        }

        List<String> urls = new ArrayList<>();
        for (MultipartFile file : files) {
            if (!file.isEmpty()) {
                String filePath = uploadFile(file, "photos").getFilePath();
                urls.add(getFileUrl(filePath));
            }
        }

        log.info("签收照片上传成功，共 {} 张", urls.size());
        return urls;
    }

    public void deleteFile(String filePath) throws IOException {
        if (filePath == null || filePath.isBlank()) {
            throw new IllegalArgumentException("文件路径不能为空");
        }

        Path path = Paths.get(fileConfig.getUploadDir() + File.separator + filePath);
        if (Files.exists(path)) {
            Files.delete(path);
            log.info("文件删除成功: {}", filePath);
        } else {
            log.warn("文件不存在: {}", filePath);
        }
    }

    public Resource loadFileAsResource(String filePath) throws MalformedURLException {
        if (filePath == null || filePath.isBlank()) {
            throw new IllegalArgumentException("文件路径不能为空");
        }

        Path path = Paths.get(fileConfig.getUploadDir() + File.separator + filePath);
        Resource resource = new UrlResource(path.toUri());
        
        if (resource.exists() && resource.isReadable()) {
            return resource;
        } else {
            throw new IllegalArgumentException("文件不存在或无法读取: " + filePath);
        }
    }

    public String getFileUrl(String filePath) {
        if (filePath == null || filePath.isBlank()) {
            return "";
        }
        return fileConfig.getAccessUrlPrefix() + "/" + filePath;
    }

    public String getRelativePath(String absolutePath) {
        if (absolutePath == null || absolutePath.isBlank()) {
            return "";
        }
        return absolutePath.replace(fileConfig.getUploadDir() + File.separator, "");
    }

    public long getFileSize(String filePath) throws IOException {
        Path path = Paths.get(fileConfig.getUploadDir() + File.separator + filePath);
        if (Files.exists(path)) {
            return Files.size(path);
        }
        return 0;
    }

    public String getFileExtension(String filename) {
        if (filename == null || filename.isBlank()) {
            return "";
        }
        int lastDotIndex = filename.lastIndexOf('.');
        if (lastDotIndex > 0 && lastDotIndex < filename.length() - 1) {
            return filename.substring(lastDotIndex + 1);
        }
        return "";
    }

    public String getFileNameWithoutExtension(String filename) {
        if (filename == null || filename.isBlank()) {
            return filename;
        }
        int lastDotIndex = filename.lastIndexOf('.');
        if (lastDotIndex > 0) {
            return filename.substring(0, lastDotIndex);
        }
        return filename;
    }

    private String generateFileName(String extension) {
        return UUID.randomUUID().toString().replace("-", "") + 
               (extension.isEmpty() ? "" : "." + extension);
    }

    private void validateFileExtension(String extension, String type) {
        if (extension.isEmpty()) {
            throw new IllegalArgumentException("文件必须包含扩展名");
        }

        Set<String> allowedExtensions = fileConfig.getAllowedExtensions();
        if (allowedExtensions != null && !allowedExtensions.isEmpty()) {
            if (!allowedExtensions.contains(extension.toLowerCase())) {
                throw new IllegalArgumentException("不允许的文件类型: " + extension);
            }
            return;
        }

        switch (type.toLowerCase()) {
            case "photos":
            case "signatures":
                if (!ALLOWED_IMAGE_EXTENSIONS.contains(extension)) {
                    throw new IllegalArgumentException("图片类型文件仅支持: " + String.join(", ", ALLOWED_IMAGE_EXTENSIONS));
                }
                break;
            case "documents":
                if (!ALLOWED_DOCUMENT_EXTENSIONS.contains(extension) && 
                    !ALLOWED_IMAGE_EXTENSIONS.contains(extension)) {
                    throw new IllegalArgumentException("文档类型文件仅支持: " + 
                        String.join(", ", ALLOWED_DOCUMENT_EXTENSIONS) + " 或图片类型");
                }
                break;
            case "certs":
                if (!ALLOWED_DOCUMENT_EXTENSIONS.contains(extension) && 
                    !ALLOWED_IMAGE_EXTENSIONS.contains(extension)) {
                    throw new IllegalArgumentException("证书类型文件仅支持: " + 
                        String.join(", ", ALLOWED_DOCUMENT_EXTENSIONS) + " 或图片类型");
                }
                break;
            default:
                if (!ALLOWED_DOCUMENT_EXTENSIONS.contains(extension) && 
                    !ALLOWED_IMAGE_EXTENSIONS.contains(extension)) {
                    throw new IllegalArgumentException("不支持的文件类型: " + extension);
                }
                break;
        }
    }

    public boolean fileExists(String filePath) {
        if (filePath == null || filePath.isBlank()) {
            return false;
        }
        Path path = Paths.get(fileConfig.getUploadDir() + File.separator + filePath);
        return Files.exists(path) && Files.isRegularFile(path);
    }

    public void createDirectory(String directoryPath) throws IOException {
        if (directoryPath == null || directoryPath.isBlank()) {
            throw new IllegalArgumentException("目录路径不能为空");
        }
        Path path = Paths.get(fileConfig.getUploadDir() + File.separator + directoryPath);
        if (!Files.exists(path)) {
            Files.createDirectories(path);
            log.info("目录创建成功: {}", directoryPath);
        }
    }

    public List<String> listFiles(String directory) throws IOException {
        final String dir = (directory == null || directory.isBlank()) ? "" : directory;
        Path path = Paths.get(fileConfig.getUploadDir() + File.separator + dir);
        if (!Files.exists(path) || !Files.isDirectory(path)) {
            return Collections.emptyList();
        }

        List<String> files = new ArrayList<>();
        try (var stream = Files.list(path)) {
            stream.forEach(file -> {
                try {
                    String relativePath = dir.isEmpty() ? file.getFileName().toString() : 
                                        dir + "/" + file.getFileName().toString();
                    files.add(relativePath);
                } catch (Exception e) {
                    log.error("列出文件失败", e);
                }
            });
        }
        return files;
    }
}
