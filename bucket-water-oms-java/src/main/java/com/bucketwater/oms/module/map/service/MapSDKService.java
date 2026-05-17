package com.bucketwater.oms.module.map.service;

import com.bucketwater.oms.module.map.dto.GeocodeDTO;
import com.bucketwater.oms.module.map.dto.RouteDTO;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.*;

@Service
public class MapSDKService {

    private static final Logger log = LoggerFactory.getLogger(MapSDKService.class);

    @Value("${map.provider:amap}")
    private String mapProvider;

    @Value("${map.amap.key:}")
    private String amapKey;

    @Value("${map.baidu.key:}")
    private String baiduKey;

    @Value("${map.mock-enabled:false}")
    private boolean mockEnabled;

    @Value("${map.enabled:false}")
    private boolean mapEnabled;

    @Autowired
    private ObjectMapper objectMapper;

    private final HttpClient httpClient = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(10))
            .build();

    public GeocodeDTO geocode(String address) {
        if (mockEnabled) {
            return getMockGeocode(address);
        }

        switch (mapProvider) {
            case "amap" -> {
                try {
                    return geocodeViaAmap(address);
                } catch (Exception e) {
                    log.error("高德地图地理编码失败: {}", e.getMessage());
                    return getMockGeocode(address);
                }
            }
            case "baidu" -> {
                try {
                    return geocodeViaBaidu(address);
                } catch (Exception e) {
                    log.error("百度地图地理编码失败: {}", e.getMessage());
                    return getMockGeocode(address);
                }
            }
            default -> {
                log.warn("未配置地图服务提供商，使用模拟模式");
                return getMockGeocode(address);
            }
        }
    }

    public GeocodeDTO reverseGeocode(Double lat, Double lng) {
        if (mockEnabled) {
            return getMockReverseGeocode(lat, lng);
        }

        switch (mapProvider) {
            case "amap" -> {
                try {
                    return reverseGeocodeViaAmap(lat, lng);
                } catch (Exception e) {
                    log.error("高德地图逆地理编码失败: {}", e.getMessage());
                    return getMockReverseGeocode(lat, lng);
                }
            }
            case "baidu" -> {
                try {
                    return reverseGeocodeViaBaidu(lat, lng);
                } catch (Exception e) {
                    log.error("百度地图逆地理编码失败: {}", e.getMessage());
                    return getMockReverseGeocode(lat, lng);
                }
            }
            default -> {
                return getMockReverseGeocode(lat, lng);
            }
        }
    }

    public RouteDTO route(BigDecimal originLat, BigDecimal originLng,
                         BigDecimal destLat, BigDecimal destLng,
                         String mode) {
        if (mockEnabled) {
            return getMockRoute(originLat, originLng, destLat, destLng);
        }

        switch (mapProvider) {
            case "amap" -> {
                try {
                    return routeViaAmap(originLat, originLng, destLat, destLng, mode);
                } catch (Exception e) {
                    log.error("高德地图路线规划失败: {}", e.getMessage());
                    return getMockRoute(originLat, originLng, destLat, destLng);
                }
            }
            case "baidu" -> {
                try {
                    return routeViaBaidu(originLat, originLng, destLat, destLng, mode);
                } catch (Exception e) {
                    log.error("百度地图路线规划失败: {}", e.getMessage());
                    return getMockRoute(originLat, originLng, destLat, destLng);
                }
            }
            default -> {
                return getMockRoute(originLat, originLng, destLat, destLng);
            }
        }
    }

    public List<RouteDTO> planMultiStopRoute(List<MapWaypoint> waypoints) {
        if (waypoints == null || waypoints.size() < 2) {
            throw new IllegalArgumentException("至少需要2个途经点");
        }

        List<RouteDTO> routes = new ArrayList<>();

        for (int i = 0; i < waypoints.size() - 1; i++) {
            MapWaypoint start = waypoints.get(i);
            MapWaypoint end = waypoints.get(i + 1);
            routes.add(route(start.getLat(), start.getLng(), end.getLat(), end.getLng(), "driving"));
        }

        return routes;
    }

    public BigDecimal calculateDistance(BigDecimal lat1, BigDecimal lng1, BigDecimal lat2, BigDecimal lng2) {
        double earthRadius = 6371000;
        double dLat = Math.toRadians(lat2.doubleValue() - lat1.doubleValue());
        double dLng = Math.toRadians(lng2.doubleValue() - lng1.doubleValue());
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                   Math.cos(Math.toRadians(lat1.doubleValue())) * Math.cos(Math.toRadians(lat2.doubleValue())) *
                   Math.sin(dLng / 2) * Math.sin(dLng / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        double distance = earthRadius * c;
        return new BigDecimal(distance).setScale(2, BigDecimal.ROUND_HALF_UP);
    }

    private GeocodeDTO geocodeViaAmap(String address) throws Exception {
        if (!mapEnabled || amapKey == null || amapKey.isEmpty()) {
            log.warn("高德地图未启用或未配置密钥，使用模拟数据");
            return getMockGeocode(address);
        }

        String encodedAddress = URLEncoder.encode(address, "UTF-8");
        String url = String.format(
            "https://restapi.amap.com/v3/geocode/geo?address=%s&key=%s",
            encodedAddress, amapKey
        );

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .timeout(Duration.ofSeconds(10))
                .GET()
                .build();

        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
        log.info("高德地理编码响应: {}", response.body());

        JsonNode json = objectMapper.readTree(response.body());
        if ("1".equals(json.path("status").asText())) {
            JsonNode geocodes = json.path("geocodes");
            if (geocodes.isArray() && geocodes.size() > 0) {
                JsonNode first = geocodes.get(0);
                String location = first.path("location").asText();
                String[] coords = location.split(",");
                if (coords.length == 2) {
                    return new GeocodeDTO(
                        address,
                        new BigDecimal(coords[1]),
                        new BigDecimal(coords[0]),
                        first.path("province").asText(),
                        first.path("city").asText(),
                        first.path("district").asText()
                    );
                }
            }
        }

        log.warn("高德地理编码返回无效数据，使用模拟数据: {}", response.body());
        return getMockGeocode(address);
    }

    private GeocodeDTO reverseGeocodeViaAmap(Double lat, Double lng) throws Exception {
        String url = String.format(
            "https://restapi.amap.com/v3/geocode/regeo?location=%s,%s&key=%s",
            lng, lat, amapKey
        );

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .timeout(Duration.ofSeconds(10))
                .GET()
                .build();

        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
        log.info("高德逆地理编码响应: {}", response.body());

        return getMockReverseGeocode(lat, lng);
    }

    private RouteDTO routeViaAmap(BigDecimal originLat, BigDecimal originLng,
                                  BigDecimal destLat, BigDecimal destLng,
                                  String mode) throws Exception {
        if (!mapEnabled || amapKey == null || amapKey.isEmpty()) {
            log.warn("高德地图未启用或未配置密钥，使用模拟数据");
            return getMockRoute(originLat, originLng, destLat, destLng);
        }

        String apiMode = "driving".equals(mode) ? "driving" : "walking";
        String url = String.format(
            "https://restapi.amap.com/v3/direction/%s?origin=%s,%s&destination=%s,%s&key=%s",
            apiMode,
            originLng, originLat,
            destLng, destLat,
            amapKey
        );

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .timeout(Duration.ofSeconds(10))
                .GET()
                .build();

        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
        log.info("高德路线规划响应: {}", response.body());

        JsonNode json = objectMapper.readTree(response.body());
        if ("1".equals(json.path("status").asText())) {
            JsonNode route = json.path("route");
            if (!route.isMissingNode()) {
                String distance = route.path("distance").asText("0");
                String duration = route.path("time").asText("0");

                List<RouteDTO.Location> points = new ArrayList<>();
                points.add(new RouteDTO.Location(originLat, originLng, "起点"));
                points.add(new RouteDTO.Location(destLat, destLng, "终点"));

                return new RouteDTO(
                    new RouteDTO.Location(originLat, originLng, "起点"),
                    new RouteDTO.Location(destLat, destLng, "终点"),
                    new BigDecimal(distance),
                    Integer.parseInt(duration),
                    points,
                    "amap_polyline_" + System.currentTimeMillis()
                );
            }
        }

        log.warn("高德路线规划返回无效数据，使用模拟数据");
        return getMockRoute(originLat, originLng, destLat, destLng);
    }

    private GeocodeDTO geocodeViaBaidu(String address) throws Exception {
        return getMockGeocode(address);
    }

    private GeocodeDTO reverseGeocodeViaBaidu(Double lat, Double lng) throws Exception {
        return getMockReverseGeocode(lat, lng);
    }

    private RouteDTO routeViaBaidu(BigDecimal originLat, BigDecimal originLng,
                                   BigDecimal destLat, BigDecimal destLng,
                                   String mode) throws Exception {
        return getMockRoute(originLat, originLng, destLat, destLng);
    }

    private GeocodeDTO getMockGeocode(String address) {
        return new GeocodeDTO(
            address,
            new BigDecimal("25.2800"),
            new BigDecimal("110.3100"),
            "广西",
            "桂林",
            "秀峰区"
        );
    }

    private GeocodeDTO getMockReverseGeocode(Double lat, Double lng) {
        return new GeocodeDTO(
            "广西壮族自治区桂林市秀峰区",
            new BigDecimal(lat.toString()),
            new BigDecimal(lng.toString()),
            "广西",
            "桂林",
            "秀峰区"
        );
    }

    private RouteDTO getMockRoute(BigDecimal originLat, BigDecimal originLng,
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
            "mock_polyline_" + System.currentTimeMillis()
        );
    }

    public static class MapWaypoint {
        private BigDecimal lat;
        private BigDecimal lng;
        private String name;
        private String action;

        public MapWaypoint(BigDecimal lat, BigDecimal lng, String name, String action) {
            this.lat = lat;
            this.lng = lng;
            this.name = name;
            this.action = action;
        }

        public BigDecimal getLat() { return lat; }
        public void setLat(BigDecimal lat) { this.lat = lat; }
        public BigDecimal getLng() { return lng; }
        public void setLng(BigDecimal lng) { this.lng = lng; }
        public String getName() { return name; }
        public void setName(String name) { this.name = name; }
        public String getAction() { return action; }
        public void setAction(String action) { this.action = action; }
    }
}
