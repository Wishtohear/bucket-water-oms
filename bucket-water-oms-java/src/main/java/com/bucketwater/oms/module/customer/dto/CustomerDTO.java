package com.bucketwater.oms.module.customer.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class CustomerDTO {
    private Long id;
    private String name;
    private String phone;
    private String address;
    private String contact;
    private String status;
    private BigDecimal balance;
    private BigDecimal creditLimit;
    private BigDecimal creditUsed;
    private Integer owedBuckets;
    private Integer threshold;
    private String paymentType;
    private LocalDateTime createdAt;
    private LocalDateTime lastOrderAt;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
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

    public String getContact() {
        return contact;
    }

    public void setContact(String contact) {
        this.contact = contact;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public BigDecimal getBalance() {
        return balance;
    }

    public void setBalance(BigDecimal balance) {
        this.balance = balance;
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

    public Integer getOwedBuckets() {
        return owedBuckets;
    }

    public void setOwedBuckets(Integer owedBuckets) {
        this.owedBuckets = owedBuckets;
    }

    public Integer getThreshold() {
        return threshold;
    }

    public void setThreshold(Integer threshold) {
        this.threshold = threshold;
    }

    public String getPaymentType() {
        return paymentType;
    }

    public void setPaymentType(String paymentType) {
        this.paymentType = paymentType;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getLastOrderAt() {
        return lastOrderAt;
    }

    public void setLastOrderAt(LocalDateTime lastOrderAt) {
        this.lastOrderAt = lastOrderAt;
    }
}
