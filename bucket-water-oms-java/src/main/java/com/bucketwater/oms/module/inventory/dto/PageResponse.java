package com.bucketwater.oms.module.inventory.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.util.List;

@Data
@Schema(description = "分页响应")
public class PageResponse<T> {

    @Schema(description = "总记录数")
    private Long total;

    @Schema(description = "当前页")
    private Integer page;

    @Schema(description = "每页数量")
    private Integer size;

    @Schema(description = "总页数")
    private Integer totalPages;

    @Schema(description = "数据列表")
    private List<T> records;

    public static <T> PageResponse<T> of(Long total, Integer page, Integer size, List<T> records) {
        PageResponse<T> response = new PageResponse<>();
        response.setTotal(total);
        response.setPage(page);
        response.setSize(size);
        response.setTotalPages((int) Math.ceil((double) total / size));
        response.setRecords(records);
        return response;
    }
}
