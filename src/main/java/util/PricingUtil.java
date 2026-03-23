package util;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.DayOfWeek;
import java.time.LocalDateTime;

/**
 * Tính giá vé theo loại ghế và khung ngày (thường/cuối tuần).
 *
 * Hệ số loại ghế:
 *   Standard  × 1.0
 *   VIP       × 1.5
 *   Couple    × 2.0
 *
 * Phụ phí cuối tuần (Thứ 7, Chủ nhật): +20%
 */
public class PricingUtil {

    private PricingUtil() {}

    public static BigDecimal seatTypeMultiplier(String seatType) {
        if (seatType == null) return BigDecimal.ONE;
        return switch (seatType) {
            case "VIP"    -> new BigDecimal("1.5");
            case "Couple" -> new BigDecimal("2.0");
            default       -> BigDecimal.ONE;          // Standard
        };
    }

    /**
     * Trả về true nếu suất chiếu vào Thứ 7 hoặc Chủ nhật.
     */
    public static boolean isWeekend(LocalDateTime showtime) {
        DayOfWeek day = showtime.getDayOfWeek();
        return day == DayOfWeek.SATURDAY || day == DayOfWeek.SUNDAY;
    }

    /**
     * Tính giá thực tế của một ghế.
     *
     * @param basePrice  BasePrice của suất chiếu
     * @param seatType   Loại ghế (Standard / VIP / Couple)
     * @param startTime  Thời điểm bắt đầu suất chiếu (để xác định cuối tuần)
     * @return           Giá làm tròn đến 0 đồng
     */
    public static BigDecimal calcSeatPrice(BigDecimal basePrice, String seatType, LocalDateTime startTime) {
        BigDecimal price = basePrice.multiply(seatTypeMultiplier(seatType));
        if (isWeekend(startTime)) {
            price = price.multiply(new BigDecimal("1.2"));
        }
        // Làm tròn đến bội số 1000 đồng gần nhất
        return price.divide(new BigDecimal("1000"), 0, RoundingMode.HALF_UP)
                    .multiply(new BigDecimal("1000"));
    }
}
