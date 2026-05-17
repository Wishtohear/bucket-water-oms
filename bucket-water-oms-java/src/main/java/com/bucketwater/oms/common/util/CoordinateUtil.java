package com.bucketwater.oms.common.util;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class CoordinateUtil {

    private static final Pattern DMS_PATTERN_LAT = Pattern.compile(
            "^(\\d{1,3})°(\\d{1,2})'(\\d{1,2}(?:\\.\\d+)?)\"\\s*([NS])$",
            Pattern.CASE_INSENSITIVE
    );

    private static final Pattern DMS_PATTERN_LNG = Pattern.compile(
            "^(\\d{1,3})°(\\d{1,2})'(\\d{1,2}(?:\\.\\d+)?)\"\\s*([EW])$",
            Pattern.CASE_INSENSITIVE
    );

    private static final Pattern DMM_PATTERN = Pattern.compile(
            "^(\\d{1,3})°(\\d{1,2}\\.\\d+)'\\s*([NS])$",
            Pattern.CASE_INSENSITIVE
    );

    private static final Pattern DMM_PATTERN_LNG = Pattern.compile(
            "^(\\d{1,3})°(\\d{1,2}\\.\\d+)'\\s*([EW])$",
            Pattern.CASE_INSENSITIVE
    );

    public static BigDecimal parseDmsToDecimalDegrees(int degrees, int minutes, double seconds) {
        if (!validateDmsInput(degrees, minutes, seconds)) {
            return null;
        }
        double decimalDegrees = degrees + (minutes / 60.0) + (seconds / 3600.0);
        return BigDecimal.valueOf(decimalDegrees).setScale(6, RoundingMode.HALF_UP);
    }

    public static BigDecimal parseDmsString(String dms) {
        if (dms == null || dms.trim().isEmpty()) {
            return null;
        }

        dms = dms.trim();

        Matcher matcherLat = DMS_PATTERN_LAT.matcher(dms);
        if (matcherLat.matches()) {
            int degrees = Integer.parseInt(matcherLat.group(1));
            int minutes = Integer.parseInt(matcherLat.group(2));
            double seconds = Double.parseDouble(matcherLat.group(3));
            String direction = matcherLat.group(4).toUpperCase();

            double decimalDegrees = degrees + (minutes / 60.0) + (seconds / 3600.0);

            if (direction.equals("S")) {
                decimalDegrees = -decimalDegrees;
            }

            return BigDecimal.valueOf(decimalDegrees).setScale(6, RoundingMode.HALF_UP);
        }

        Matcher matcherLng = DMS_PATTERN_LNG.matcher(dms);
        if (matcherLng.matches()) {
            int degrees = Integer.parseInt(matcherLng.group(1));
            int minutes = Integer.parseInt(matcherLng.group(2));
            double seconds = Double.parseDouble(matcherLng.group(3));
            String direction = matcherLng.group(4).toUpperCase();

            double decimalDegrees = degrees + (minutes / 60.0) + (seconds / 3600.0);

            if (direction.equals("W")) {
                decimalDegrees = -decimalDegrees;
            }

            return BigDecimal.valueOf(decimalDegrees).setScale(6, RoundingMode.HALF_UP);
        }

        return parseDmmToDecimalDegrees(dms);
    }

    public static BigDecimal parseDmmToDecimalDegrees(String dmm) {
        if (dmm == null || dmm.trim().isEmpty()) {
            return null;
        }

        dmm = dmm.trim();

        Matcher matcher = DMM_PATTERN.matcher(dmm);
        if (matcher.matches()) {
            int degrees = Integer.parseInt(matcher.group(1));
            double minutes = Double.parseDouble(matcher.group(2));
            String direction = matcher.group(3).toUpperCase();

            double decimalDegrees = degrees + (minutes / 60.0);

            if (direction.equals("S")) {
                decimalDegrees = -decimalDegrees;
            }

            return BigDecimal.valueOf(decimalDegrees).setScale(6, RoundingMode.HALF_UP);
        }

        Matcher matcherLng = DMM_PATTERN_LNG.matcher(dmm);
        if (matcherLng.matches()) {
            int degrees = Integer.parseInt(matcherLng.group(1));
            double minutes = Double.parseDouble(matcherLng.group(2));
            String direction = matcherLng.group(3).toUpperCase();

            double decimalDegrees = degrees + (minutes / 60.0);

            if (direction.equals("W")) {
                decimalDegrees = -decimalDegrees;
            }

            return BigDecimal.valueOf(decimalDegrees).setScale(6, RoundingMode.HALF_UP);
        }

        try {
            return new BigDecimal(dmm);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    public static boolean validateDmsInput(int degrees, int minutes, double seconds) {
        if (degrees < 0 || degrees > 180) {
            return false;
        }
        if (minutes < 0 || minutes >= 60) {
            return false;
        }
        if (seconds < 0 || seconds >= 60) {
            return false;
        }
        return true;
    }

    public static String formatToDms(BigDecimal decimalDegrees, boolean isLatitude) {
        if (decimalDegrees == null) {
            return "";
        }

        double value = decimalDegrees.doubleValue();
        boolean negative = value < 0;
        value = Math.abs(value);

        int degrees = (int) value;
        double minutesDecimal = (value - degrees) * 60;
        int minutes = (int) minutesDecimal;
        double seconds = (minutesDecimal - minutes) * 60;

        String direction;
        if (isLatitude) {
            direction = negative ? "S" : "N";
        } else {
            direction = negative ? "W" : "E";
        }

        return String.format("%d°%d'%.2f\"%s", degrees, minutes, seconds, direction);
    }

    public static String formatToDmm(BigDecimal decimalDegrees, boolean isLatitude) {
        if (decimalDegrees == null) {
            return "";
        }

        double value = decimalDegrees.doubleValue();
        boolean negative = value < 0;
        value = Math.abs(value);

        int degrees = (int) value;
        double minutes = (value - degrees) * 60;

        String direction;
        if (isLatitude) {
            direction = negative ? "S" : "N";
        } else {
            direction = negative ? "W" : "E";
        }

        return String.format("%d°%.3f'%s", degrees, minutes, direction);
    }

    public static boolean isValidLatitude(BigDecimal lat) {
        if (lat == null) {
            return true;
        }
        double value = lat.doubleValue();
        return value >= -90 && value <= 90;
    }

    public static boolean isValidLongitude(BigDecimal lng) {
        if (lng == null) {
            return true;
        }
        double value = lng.doubleValue();
        return value >= -180 && value <= 180;
    }
}
