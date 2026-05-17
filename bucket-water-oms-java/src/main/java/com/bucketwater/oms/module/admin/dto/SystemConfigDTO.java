package com.bucketwater.oms.module.admin.dto;

import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
public class SystemConfigDTO {
    private String factoryName;
    private String customerServicePhone;
    private Integer statementConfirmDays;
    private Integer inventoryWarningThreshold;
    private List<AdminUser> adminUsers;
    private List<AuditLog> auditLogs;

    public String getFactoryName() {
        return factoryName;
    }

    public void setFactoryName(String factoryName) {
        this.factoryName = factoryName;
    }

    public String getCustomerServicePhone() {
        return customerServicePhone;
    }

    public void setCustomerServicePhone(String customerServicePhone) {
        this.customerServicePhone = customerServicePhone;
    }

    public Integer getStatementConfirmDays() {
        return statementConfirmDays;
    }

    public void setStatementConfirmDays(Integer statementConfirmDays) {
        this.statementConfirmDays = statementConfirmDays;
    }

    public Integer getInventoryWarningThreshold() {
        return inventoryWarningThreshold;
    }

    public void setInventoryWarningThreshold(Integer inventoryWarningThreshold) {
        this.inventoryWarningThreshold = inventoryWarningThreshold;
    }

    public List<AdminUser> getAdminUsers() {
        return adminUsers;
    }

    public void setAdminUsers(List<AdminUser> adminUsers) {
        this.adminUsers = adminUsers;
    }

    public List<AuditLog> getAuditLogs() {
        return auditLogs;
    }

    public void setAuditLogs(List<AuditLog> auditLogs) {
        this.auditLogs = auditLogs;
    }

    @Data
    public static class AdminUser {
        private String id;
        private String name;
        private String role;
        private String roleText;
        private String lastLoginTime;
        private String permissions;

        public String getId() {
            return id;
        }

        public void setId(String id) {
            this.id = id;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public String getRole() {
            return role;
        }

        public void setRole(String role) {
            this.role = role;
        }

        public String getRoleText() {
            return roleText;
        }

        public void setRoleText(String roleText) {
            this.roleText = roleText;
        }

        public String getLastLoginTime() {
            return lastLoginTime;
        }

        public void setLastLoginTime(String lastLoginTime) {
            this.lastLoginTime = lastLoginTime;
        }

        public String getPermissions() {
            return permissions;
        }

        public void setPermissions(String permissions) {
            this.permissions = permissions;
        }
    }

    @Data
    public static class AuditLog {
        private String id;
        private LocalDateTime time;
        private String operator;
        private String action;
        private String ipAddress;

        public String getId() {
            return id;
        }

        public void setId(String id) {
            this.id = id;
        }

        public LocalDateTime getTime() {
            return time;
        }

        public void setTime(LocalDateTime time) {
            this.time = time;
        }

        public String getOperator() {
            return operator;
        }

        public void setOperator(String operator) {
            this.operator = operator;
        }

        public String getAction() {
            return action;
        }

        public void setAction(String action) {
            this.action = action;
        }

        public String getIpAddress() {
            return ipAddress;
        }

        public void setIpAddress(String ipAddress) {
            this.ipAddress = ipAddress;
        }
    }
}
