package com.bucketwater.oms.module.file.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

import java.util.Set;

@Configuration
@ConfigurationProperties(prefix = "file")
public class FileConfig {

    private String uploadDir = "./uploads";
    
    private long maxSize = 10485760L;
    
    private String accessUrlPrefix = "/files";
    
    private Set<String> allowedTypes;
    
    private Set<String> allowedExtensions;

    public String getUploadDir() {
        return uploadDir;
    }

    public void setUploadDir(String uploadDir) {
        this.uploadDir = uploadDir;
    }

    public long getMaxSize() {
        return maxSize;
    }

    public void setMaxSize(long maxSize) {
        this.maxSize = maxSize;
    }

    public String getAccessUrlPrefix() {
        return accessUrlPrefix;
    }

    public void setAccessUrlPrefix(String accessUrlPrefix) {
        this.accessUrlPrefix = accessUrlPrefix;
    }

    public Set<String> getAllowedTypes() {
        return allowedTypes;
    }

    public void setAllowedTypes(Set<String> allowedTypes) {
        this.allowedTypes = allowedTypes;
    }

    public Set<String> getAllowedExtensions() {
        return allowedExtensions;
    }

    public void setAllowedExtensions(Set<String> allowedExtensions) {
        this.allowedExtensions = allowedExtensions;
    }
}
