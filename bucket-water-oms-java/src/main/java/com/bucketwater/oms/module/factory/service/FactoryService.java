package com.bucketwater.oms.module.factory.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.bucketwater.oms.common.exception.BusinessException;
import com.bucketwater.oms.common.response.ResultCode;
import com.bucketwater.oms.module.factory.entity.Factory;
import com.bucketwater.oms.module.factory.mapper.FactoryMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class FactoryService {

    @Autowired
    private FactoryMapper factoryMapper;

    public IPage<Factory> getFactoryPage(String keyword, String status, Integer page, Integer size) {
        Page<Factory> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<Factory> wrapper = new LambdaQueryWrapper<>();
        
        if (keyword != null && !keyword.isEmpty()) {
            wrapper.and(w -> w.like(Factory::getName, keyword)
                   .or()
                   .like(Factory::getCode, keyword));
        }
        
        if (status != null && !status.isEmpty()) {
            wrapper.eq(Factory::getStatus, status);
        }
        
        wrapper.orderByDesc(Factory::getCreateTime);
        return factoryMapper.selectPage(pageParam, wrapper);
    }

    public List<Factory> getAllFactories(String status) {
        LambdaQueryWrapper<Factory> wrapper = new LambdaQueryWrapper<>();
        if (status != null && !status.isEmpty()) {
            wrapper.eq(Factory::getStatus, status);
        }
        wrapper.orderByDesc(Factory::getCreateTime);
        return factoryMapper.selectList(wrapper);
    }

    public Factory getFactoryById(Long id) {
        Factory factory = factoryMapper.selectById(id);
        if (factory == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "水厂不存在");
        }
        return factory;
    }

    public Factory getFactoryByCode(String code) {
        LambdaQueryWrapper<Factory> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Factory::getCode, code);
        return factoryMapper.selectOne(wrapper);
    }

    @Transactional
    public Factory createFactory(Factory factory) {
        if (factory.getCode() == null || factory.getCode().isEmpty()) {
            throw new BusinessException(ResultCode.PARAM_INVALID, "水厂编码不能为空");
        }
        
        Factory existing = getFactoryByCode(factory.getCode());
        if (existing != null) {
            throw new BusinessException(ResultCode.DATA_EXISTS, "水厂编码已存在");
        }
        
        factory.setStatus("active");
        factory.setCreateTime(LocalDateTime.now());
        factory.setUpdateTime(LocalDateTime.now());
        factory.setDeleted(0);
        
        factoryMapper.insert(factory);
        return factory;
    }

    @Transactional
    public Factory updateFactory(Long id, Factory factory) {
        Factory existing = getFactoryById(id);
        
        if (factory.getName() != null) {
            existing.setName(factory.getName());
        }
        if (factory.getContact() != null) {
            existing.setContact(factory.getContact());
        }
        if (factory.getPhone() != null) {
            existing.setPhone(factory.getPhone());
        }
        if (factory.getAddress() != null) {
            existing.setAddress(factory.getAddress());
        }
        if (factory.getLat() != null) {
            existing.setLat(factory.getLat());
        }
        if (factory.getLng() != null) {
            existing.setLng(factory.getLng());
        }
        if (factory.getRemark() != null) {
            existing.setRemark(factory.getRemark());
        }
        
        existing.setUpdateTime(LocalDateTime.now());
        factoryMapper.updateById(existing);
        return existing;
    }

    @Transactional
    public void updateFactoryStatus(Long id, String status) {
        Factory factory = getFactoryById(id);
        factory.setStatus(status);
        factory.setUpdateTime(LocalDateTime.now());
        factoryMapper.updateById(factory);
    }

    @Transactional
    public void deleteFactory(Long id) {
        Factory factory = getFactoryById(id);
        factoryMapper.deleteById(id);
    }
}
