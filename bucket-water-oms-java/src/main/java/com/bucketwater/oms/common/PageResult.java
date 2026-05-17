package com.bucketwater.oms.common;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.core.metadata.OrderItem;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;

import java.io.Serializable;
import java.util.List;

public class PageResult<T> implements Serializable {

    private Long total;
    private Long size;
    private Long current;
    private List<T> records;
    private Long pages;

    public PageResult() {
    }

    public PageResult(IPage<T> page) {
        this.total = page.getTotal();
        this.size = page.getSize();
        this.current = page.getCurrent();
        this.records = page.getRecords();
        this.pages = page.getPages();
    }

    public static <T> PageResult<T> of(IPage<T> page) {
        return new PageResult<>(page);
    }

    public static <T> Page<T> of(int current, int size) {
        return Page.of(current, size);
    }

    public static <T> Page<T> of(int current, int size, String sortBy, boolean isAsc) {
        Page<T> page = Page.of(current, size);
        if (isAsc) {
            page.addOrder(OrderItem.asc(sortBy));
        } else {
            page.addOrder(OrderItem.desc(sortBy));
        }
        return page;
    }

    public Long getTotal() {
        return total;
    }

    public void setTotal(Long total) {
        this.total = total;
    }

    public Long getSize() {
        return size;
    }

    public void setSize(Long size) {
        this.size = size;
    }

    public Long getCurrent() {
        return current;
    }

    public void setCurrent(Long current) {
        this.current = current;
    }

    public List<T> getRecords() {
        return records;
    }

    public void setRecords(List<T> records) {
        this.records = records;
    }

    public Long getPages() {
        return pages;
    }

    public void setPages(Long pages) {
        this.pages = pages;
    }
}
