package com.bucketwater.oms.module.admin.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
public class StationPageDTO {
    private Long total;
    private Integer page;
    private Integer size;
    private Integer totalPages;
    private List<StationItem> stations;

    public Long getTotal() {
        return total;
    }

    public void setTotal(Long total) {
        this.total = total;
    }

    public Integer getPage() {
        return page;
    }

    public void setPage(Integer page) {
        this.page = page;
    }

    public Integer getSize() {
        return size;
    }

    public void setSize(Integer size) {
        this.size = size;
    }

    public Integer getTotalPages() {
        return totalPages;
    }

    public void setTotalPages(Integer totalPages) {
        this.totalPages = totalPages;
    }

    public List<StationItem> getStations() {
        return stations;
    }

    public void setStations(List<StationItem> stations) {
        this.stations = stations;
    }

    @Data
    public static class StationItem {
        private String id;
        private String name;
        private String contact;
        private String phone;
        private String address;
        private String status;
        private String statusText;
        private BigDecimal depositBalance;
        private Integer owedBucketNum;
        private BigDecimal creditLimit;
        private BigDecimal creditUsed;

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

        public String getContact() {
            return contact;
        }

        public void setContact(String contact) {
            this.contact = contact;
        }

        public String getPhone() {
            return phone;
        }

        public void setPhone(String phone) {
            this.phone = phone;
        }

        public String getAddress() {
            return address;
        }

        public void setAddress(String address) {
            this.address = address;
        }

        public String getStatus() {
            return status;
        }

        public void setStatus(String status) {
            this.status = status;
        }

        public String getStatusText() {
            return statusText;
        }

        public void setStatusText(String statusText) {
            this.statusText = statusText;
        }

        public BigDecimal getDepositBalance() {
            return depositBalance;
        }

        public void setDepositBalance(BigDecimal depositBalance) {
            this.depositBalance = depositBalance;
        }

        public Integer getOwedBucketNum() {
            return owedBucketNum;
        }

        public void setOwedBucketNum(Integer owedBucketNum) {
            this.owedBucketNum = owedBucketNum;
        }

        public BigDecimal getCreditLimit() {
            return creditLimit;
        }

        public void setCreditLimit(BigDecimal creditLimit) {
            this.creditLimit = creditLimit;
        }

        public BigDecimal getCreditUsed() {
            return creditUsed;
        }

        public void setCreditUsed(BigDecimal creditUsed) {
            this.creditUsed = creditUsed;
        }
    }
}
