package com.bucketwater.oms.module.map.controller;

import com.bucketwater.oms.common.response.Result;
import com.bucketwater.oms.module.map.dto.GeocodeDTO;
import com.bucketwater.oms.module.map.dto.RouteDTO;
import com.bucketwater.oms.module.map.service.MapService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;

@RestController
@RequestMapping("/map")
@Tag(name = "地图模块", description = "地理编码、路线规划")
public class MapController {

    @Autowired
    private MapService mapService;

    @GetMapping("/geocode")
    @Operation(summary = "地址编码", description = "将地址转换为坐标")
    public Result<GeocodeDTO> geocode(
            @RequestParam @Parameter(description = "地址") String address) {
        GeocodeDTO result = mapService.geocode(address);
        return Result.ok(result);
    }

    @GetMapping("/reverse-geocode")
    @Operation(summary = "逆地址编码", description = "将坐标转换为地址")
    public Result<GeocodeDTO> reverseGeocode(
            @RequestParam @Parameter(description = "纬度") Double lat,
            @RequestParam @Parameter(description = "经度") Double lng) {
        GeocodeDTO result = mapService.reverseGeocode(lat, lng);
        return Result.ok(result);
    }

    @GetMapping("/route")
    @Operation(summary = "路线规划", description = "获取两点之间的路线")
    public Result<RouteDTO> route(
            @RequestParam @Parameter(description = "起点纬度") BigDecimal originLat,
            @RequestParam @Parameter(description = "起点经度") BigDecimal originLng,
            @RequestParam @Parameter(description = "终点纬度") BigDecimal destLat,
            @RequestParam @Parameter(description = "终点经度") BigDecimal destLng) {
        RouteDTO result = mapService.route(originLat, originLng, destLat, destLng);
        return Result.ok(result);
    }
}
