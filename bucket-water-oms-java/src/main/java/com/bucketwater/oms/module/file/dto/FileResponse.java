package com.bucketwater.oms.module.file.dto;

public class FileResponse {

    private String fileName;
    private String filePath;
    private String fileUrl;
    private String fileType;
    private long fileSize;
    private String originalName;

    public FileResponse() {
    }

    public FileResponse(String fileName, String filePath, String fileUrl, String fileType, 
                      long fileSize, String originalName) {
        this.fileName = fileName;
        this.filePath = filePath;
        this.fileUrl = fileUrl;
        this.fileType = fileType;
        this.fileSize = fileSize;
        this.originalName = originalName;
    }

    public static FileResponse of(String fileName, String filePath, String fileUrl, 
                                 String fileType, long fileSize, String originalName) {
        return new FileResponse(fileName, filePath, fileUrl, fileType, fileSize, originalName);
    }

    public String getFileName() {
        return fileName;
    }

    public void setFileName(String fileName) {
        this.fileName = fileName;
    }

    public String getFilePath() {
        return filePath;
    }

    public void setFilePath(String filePath) {
        this.filePath = filePath;
    }

    public String getFileUrl() {
        return fileUrl;
    }

    public void setFileUrl(String fileUrl) {
        this.fileUrl = fileUrl;
    }

    public String getFileType() {
        return fileType;
    }

    public void setFileType(String fileType) {
        this.fileType = fileType;
    }

    public long getFileSize() {
        return fileSize;
    }

    public void setFileSize(long fileSize) {
        this.fileSize = fileSize;
    }

    public String getOriginalName() {
        return originalName;
    }

    public void setOriginalName(String originalName) {
        this.originalName = originalName;
    }
}
