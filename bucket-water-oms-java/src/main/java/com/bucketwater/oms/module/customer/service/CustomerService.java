package com.bucketwater.oms.module.customer.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.bucketwater.oms.module.customer.dto.CustomerDTO;
import com.bucketwater.oms.module.customer.entity.Customer;
import com.bucketwater.oms.module.customer.mapper.CustomerMapper;
import com.bucketwater.oms.module.station.entity.StationAccount;
import com.bucketwater.oms.module.station.mapper.StationAccountMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class CustomerService {

    @Autowired
    private CustomerMapper customerMapper;

    @Autowired
    private StationAccountMapper stationAccountMapper;

    public List<CustomerDTO> getCustomers(Long stationId, String keyword) {
        QueryWrapper<Customer> wrapper = new QueryWrapper<>();
        if (stationId != null) {
            wrapper.eq("station_id", stationId);
        }
        if (keyword != null && !keyword.isBlank()) {
            wrapper.and(w -> w.like("name", keyword).or().like("phone", keyword));
        }
        wrapper.eq("status", "active");
        wrapper.orderByDesc("created_at");

        List<Customer> customers = customerMapper.selectList(wrapper);
        return customers.stream().map(this::convertToDTO).collect(Collectors.toList());
    }

    public CustomerDTO getCustomerById(Long customerId) {
        Customer customer = customerMapper.selectById(customerId);
        if (customer == null) {
            return null;
        }
        return convertToDTO(customer);
    }

    public CustomerDTO createCustomer(Long stationId, String name, String phone, String address, String contact) {
        Customer customer = new Customer();
        customer.setStationId(stationId);
        customer.setName(name);
        customer.setPhone(phone);
        customer.setAddress(address);
        customer.setContact(contact);
        customer.setStatus("active");
        customerMapper.insert(customer);
        return convertToDTO(customer);
    }

    public CustomerDTO updateCustomer(Long customerId, String name, String phone, String address, String contact) {
        Customer customer = customerMapper.selectById(customerId);
        if (customer == null) {
            return null;
        }
        if (name != null) customer.setName(name);
        if (phone != null) customer.setPhone(phone);
        if (address != null) customer.setAddress(address);
        if (contact != null) customer.setContact(contact);
        customerMapper.updateById(customer);
        return convertToDTO(customer);
    }

    public void deleteCustomer(Long customerId) {
        Customer customer = customerMapper.selectById(customerId);
        if (customer != null) {
            customer.setStatus("deleted");
            customerMapper.updateById(customer);
        }
    }

    private CustomerDTO convertToDTO(Customer customer) {
        CustomerDTO dto = new CustomerDTO();
        dto.setId(customer.getId());
        dto.setName(customer.getName());
        dto.setPhone(customer.getPhone());
        dto.setAddress(customer.getAddress());
        dto.setContact(customer.getContact());
        dto.setStatus(customer.getStatus());
        dto.setCreatedAt(customer.getCreatedAt());

        if (customer.getStationId() != null) {
            StationAccount account = stationAccountMapper.selectOne(
                new QueryWrapper<StationAccount>().eq("station_id", customer.getStationId())
            );
            if (account != null) {
                dto.setBalance(account.getDepositBalance());
                dto.setCreditLimit(account.getCreditLimit());
                dto.setCreditUsed(account.getCreditUsed());
                dto.setOwedBuckets(account.getOwedBucketNum());
                dto.setThreshold(account.getOwedThreshold());
            }
        }

        return dto;
    }
}
