package com.bucketwater.oms.module.admin.dto;

import lombok.Data;

@Data
public class StationPageQueryDTO {
    private String keyword;
    private String status;
    private String balanceFilter;
    private Integer page;
    private Integer size;

    public StationPageQueryDTO() {
        this.page = 1;
        this.size = 20;
    }

    public String getKeyword() {
        return keyword;
    }

    public void setKeyword(String keyword) {
        this.keyword = keyword;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getBalanceFilter() {
        return balanceFilter;
    }

    public void setBalanceFilter(String balanceFilter) {
        this.balanceFilter = balanceFilter;
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
}
