package com.bucketwater.oms.module.map.service;

import com.bucketwater.oms.module.map.dto.GeocodeDTO;
import com.bucketwater.oms.module.map.dto.RouteDTO;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@Service
public class MapService {

    private static final Logger log = LoggerFactory.getLogger(MapService.class);

    @Autowired
    private MapSDKService mapSDKService;

    public GeocodeDTO geocode(String address) {
        try {
            GeocodeDTO result = mapSDKService.geocode(address);
            log.info("地理编码成功: {} -> ({}, {})", address, result.getLat(), result.getLng());
            return result;
        } catch (Exception e) {
            log.error("地理编码失败: {}", e.getMessage());
            return getFallbackGeocode(address);
        }
    }

    public GeocodeDTO reverseGeocode(Double lat, Double lng) {
        try {
            GeocodeDTO result = mapSDKService.reverseGeocode(lat, lng);
            log.info("逆地理编码成功: ({}, {}) -> {}", lat, lng, result.getAddress());
            return result;
        } catch (Exception e) {
            log.error("逆地理编码失败: {}", e.getMessage());
            return getFallbackReverseGeocode(lat, lng);
        }
    }

    public RouteDTO route(BigDecimal originLat, BigDecimal originLng, BigDecimal destLat, BigDecimal destLng) {
        return route(originLat, originLng, destLat, destLng, "driving");
    }

    public RouteDTO route(BigDecimal originLat, BigDecimal originLng, BigDecimal destLat, BigDecimal destLng, String mode) {
        try {
            RouteDTO result = mapSDKService.route(originLat, originLng, destLat, destLng, mode);
            log.info("路线规划成功: ({}, {}) -> ({}, {}), 距离: {}m, 预计: {}秒",
                originLat, originLng, destLat, destLng, result.getDistance(), result.getDuration());
            return result;
        } catch (Exception e) {
            log.error("路线规划失败: {}", e.getMessage());
            return getFallbackRoute(originLat, originLng, destLat, destLng);
        }
    }

    public List<RouteDTO> planMultiStopRoute(List<MapSDKService.MapWaypoint> waypoints) {
        try {
            List<RouteDTO> routes = mapSDKService.planMultiStopRoute(waypoints);
            log.info("多途经点路线规划成功: {} 个途经点, {} 条路线", waypoints.size(), routes.size());
            return routes;
        } catch (Exception e) {
            log.error("多途经点路线规划失败: {}", e.getMessage());
            return getFallbackMultiStopRoute(waypoints);
        }
    }

    public BigDecimal calculateDistance(BigDecimal lat1, BigDecimal lng1, BigDecimal lat2, BigDecimal lng2) {
        return mapSDKService.calculateDistance(lat1, lng1, lat2, lng2);
    }

    private GeocodeDTO getFallbackGeocode(String address) {
        return new GeocodeDTO(
            address,
            new BigDecimal("25.2800"),
            new BigDecimal("110.3100"),
            "广西壮族自治区",
            "桂林市",
            "秀峰区"
        );
    }

    private GeocodeDTO getFallbackReverseGeocode(Double lat, Double lng) {
        return new GeocodeDTO(
            "广西壮族自治区桂林市秀峰区",
            new BigDecimal(lat.toString()),
            new BigDecimal(lng.toString()),
            "广西壮族自治区",
            "桂林市",
            "秀峰区"
        );
    }

    private RouteDTO getFallbackRoute(BigDecimal originLat, BigDecimal originLng,
                                     BigDecimal destLat, BigDecimal destLng) {
        BigDecimal distance = calculateDistance(originLat, originLng, destLat, destLng);
        int duration = distance.divide(new BigDecimal("500"), 0, BigDecimal.ROUND_CEILING).intValue() * 60;

        List<RouteDTO.Location> points = new ArrayList<>();
        points.add(new RouteDTO.Location(originLat, originLng, "起点"));
        points.add(new RouteDTO.Location(destLat, destLng, "终点"));

        return new RouteDTO(
            new RouteDTO.Location(originLat, originLng, "起点"),
            new RouteDTO.Location(destLat, destLng, "终点"),
            distance,
            duration,
            points,
            "fallback_polyline_" + System.currentTimeMillis()
        );
    }

    private List<RouteDTO> getFallbackMultiStopRoute(List<MapSDKService.MapWaypoint> waypoints) {
        List<RouteDTO> routes = new ArrayList<>();
        for (int i = 0; i < waypoints.size() - 1; i++) {
            MapSDKService.MapWaypoint start = waypoints.get(i);
            MapSDKService.MapWaypoint end = waypoints.get(i + 1);
            routes.add(getFallbackRoute(start.getLat(), start.getLng(), end.getLat(), end.getLng()));
        }
        return routes;
    }
}
