package controller.booking;

import dao.BookingDAO;
import dao.BookingFoodItemDAO;
import dao.BookingSeatDAO;
import dao.FoodItemDAO;
import dao.PaymentDAO;
import dao.ShowtimeDAO;
import dao.VoucherDAO;
import exception.DataAccessException;
import model.Booking;
import model.BookingFoodItem;
import model.BookingSeat;
import model.FoodItem;
import model.Payment;
import model.Showtime;
import model.User;
import model.Voucher;
import util.VNPayConfig;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TimeZone;

/**
 * GET  /booking/exchange-checkout  — trang chọn food + voucher cho đổi vé
 * POST /booking/exchange-checkout  — xác nhận, áp dụng thay đổi, thanh toán phụ thu nếu cần
 *
 * Dữ liệu từ session:
 *   exchangeBookingId     : int
 *   exchangeNewShowtimeId : int
 *   exchangeSeatIds       : Set<Integer>
 */
@WebServlet(name = "ExchangeCheckoutServlet", urlPatterns = {"/booking/exchange-checkout"})
public class ExchangeCheckoutServlet extends HttpServlet {

    private final BookingDAO bookingDAO = new BookingDAO();
    private final BookingSeatDAO bookingSeatDAO = new BookingSeatDAO();
    private final BookingFoodItemDAO bookingFoodItemDAO = new BookingFoodItemDAO();
    private final FoodItemDAO foodItemDAO = new FoodItemDAO();
    private final VoucherDAO voucherDAO = new VoucherDAO();
    private final ShowtimeDAO showtimeDAO = new ShowtimeDAO();
    private final PaymentDAO paymentDAO = new PaymentDAO();

    // -----------------------------------------------------------------------
    // GET
    // -----------------------------------------------------------------------
    @Override
    @SuppressWarnings("unchecked")
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        Integer bookingId     = (Integer) session.getAttribute("exchangeBookingId");
        Integer newShowtimeId = (Integer) session.getAttribute("exchangeNewShowtimeId");
        Set<Integer> seatIds  = (Set<Integer>) session.getAttribute("exchangeSeatIds");

        if (bookingId == null || newShowtimeId == null || seatIds == null) {
            resp.sendRedirect(req.getContextPath() + "/profile/bookings");
            return;
        }

        Booking booking = bookingDAO.findById(bookingId);
        Showtime oldShowtime = showtimeDAO.findById(booking.getShowtimeId());
        Showtime newShowtime = showtimeDAO.findById(newShowtimeId);

        if (booking == null || oldShowtime == null || newShowtime == null) {
            resp.sendRedirect(req.getContextPath() + "/profile/bookings");
            return;
        }

        // Ghế cũ và food cũ để hiển thị so sánh
        List<BookingSeat> oldSeats = bookingSeatDAO.findByBookingWithSeat(bookingId);
        List<BookingFoodItem> oldFoodItems = bookingFoodItemDAO.findByBookingWithFood(bookingId);
        List<FoodItem> allFoodItems = foodItemDAO.findAvailable();

        // Map foodItemId -> qty cũ để pre-fill
        Map<Integer, Integer> oldFoodQtyMap = new HashMap<>();
        for (BookingFoodItem bfi : oldFoodItems) {
            oldFoodQtyMap.put(bfi.getFoodItemId(), bfi.getQuantity());
        }

        // Tính tiền vé mới (chưa có food/voucher)
        int seatCount = seatIds.size();
        BigDecimal newSeatPrice = newShowtime.getBasePrice();
        BigDecimal oldSeatPrice = oldSeats.isEmpty() ? oldShowtime.getBasePrice() : oldSeats.get(0).getSeatPrice();
        BigDecimal newTicketSubTotal = newSeatPrice.multiply(BigDecimal.valueOf(seatCount));

        req.setAttribute("booking", booking);
        req.setAttribute("oldShowtime", oldShowtime);
        req.setAttribute("newShowtime", newShowtime);
        req.setAttribute("oldSeats", oldSeats);
        req.setAttribute("newSeatIds", seatIds);
        req.setAttribute("seatCount", seatCount);
        req.setAttribute("oldSeatPrice", oldSeatPrice);
        req.setAttribute("newSeatPrice", newSeatPrice);
        req.setAttribute("newTicketSubTotal", newTicketSubTotal);
        req.setAttribute("allFoodItems", allFoodItems);
        req.setAttribute("oldFoodQtyMap", oldFoodQtyMap);
        req.getRequestDispatcher("/booking/exchange-checkout.jsp").forward(req, resp);
    }

    // -----------------------------------------------------------------------
    // POST — áp dụng đổi vé
    // -----------------------------------------------------------------------
    @Override
    @SuppressWarnings("unchecked")
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        User user = (User) session.getAttribute("user");

        Integer bookingId     = (Integer) session.getAttribute("exchangeBookingId");
        Integer newShowtimeId = (Integer) session.getAttribute("exchangeNewShowtimeId");
        Set<Integer> seatIds  = (Set<Integer>) session.getAttribute("exchangeSeatIds");

        if (bookingId == null || newShowtimeId == null || seatIds == null) {
            resp.sendRedirect(req.getContextPath() + "/profile/bookings");
            return;
        }

        try {
            Booking booking = bookingDAO.findById(bookingId);
            Showtime oldShowtime = showtimeDAO.findById(booking.getShowtimeId());
            Showtime newShowtime = showtimeDAO.findById(newShowtimeId);

            if (booking == null || oldShowtime == null || newShowtime == null) {
                resp.sendRedirect(req.getContextPath() + "/profile/bookings");
                return;
            }

            // ---- Tính tiền vé ----
            List<BookingSeat> oldSeats = bookingSeatDAO.findByBookingWithSeat(bookingId);
            int seatCount = seatIds.size();
            BigDecimal newSeatPrice = newShowtime.getBasePrice();
            BigDecimal oldSeatPrice = oldSeats.isEmpty() ? oldShowtime.getBasePrice() : oldSeats.get(0).getSeatPrice();
            BigDecimal newTicketSubTotal = newSeatPrice.multiply(BigDecimal.valueOf(seatCount));

            // ---- Tính food ----
            List<FoodItem> allFoodItems = foodItemDAO.findAvailable();
            List<BookingFoodItem> chosenFood = new ArrayList<>();
            BigDecimal foodTotal = BigDecimal.ZERO;
            for (FoodItem f : allFoodItems) {
                String qtyStr = req.getParameter("qty_" + f.getFoodItemId());
                if (qtyStr == null || qtyStr.isBlank()) continue;
                try {
                    int qty = Integer.parseInt(qtyStr);
                    if (qty <= 0) continue;
                    BookingFoodItem bfi = new BookingFoodItem();
                    bfi.setBookingId(bookingId);
                    bfi.setFoodItemId(f.getFoodItemId());
                    bfi.setQuantity(qty);
                    bfi.setUnitPrice(f.getPrice());
                    chosenFood.add(bfi);
                    foodTotal = foodTotal.add(f.getPrice().multiply(BigDecimal.valueOf(qty)));
                } catch (NumberFormatException ignore) {}
            }
            foodTotal = foodTotal.setScale(0, RoundingMode.HALF_UP);
            BigDecimal newSubTotal = newTicketSubTotal.add(foodTotal).setScale(0, RoundingMode.HALF_UP);

            // ---- Voucher ----
            String voucherCode = req.getParameter("voucherCode");
            Voucher appliedVoucher = null;
            BigDecimal discountAmount = BigDecimal.ZERO;
            if (voucherCode != null && !voucherCode.isBlank()) {
                Voucher v = voucherDAO.findValidByCode(voucherCode.trim(), newSubTotal);
                if (v == null) {
                    req.setAttribute("voucherError", "Mã voucher không hợp lệ hoặc không đáp ứng điều kiện.");
                    doGet(req, resp);
                    return;
                }
                appliedVoucher = v;
                if ("Percent".equalsIgnoreCase(v.getDiscountType())) {
                    discountAmount = newSubTotal.multiply(v.getDiscountValue())
                            .divide(BigDecimal.valueOf(100), 0, RoundingMode.HALF_UP);
                } else {
                    discountAmount = v.getDiscountValue().setScale(0, RoundingMode.HALF_UP);
                }
                if (discountAmount.compareTo(newSubTotal) > 0) discountAmount = newSubTotal;
            }
            BigDecimal newTotal = newSubTotal.subtract(discountAmount).setScale(0, RoundingMode.HALF_UP);

            // ---- Tính phụ thu so với booking cũ ----
            // Phụ thu = (tổng mới) - (tổng cũ không tính food cũ) + (food mới)
            // Đơn giản hơn: phụ thu chỉ tính trên chênh lệch ghế, food là thay thế hoàn toàn
            BigDecimal oldTicketTotal = oldSeatPrice.multiply(BigDecimal.valueOf(seatCount));
            BigDecimal seatSurcharge = newTicketSubTotal.subtract(oldTicketTotal);
            if (seatSurcharge.compareTo(BigDecimal.ZERO) < 0) seatSurcharge = BigDecimal.ZERO;

            // ---- Áp dụng thay đổi vào DB ----
            // 1. Xóa BookingSeats cũ, tạo mới cho suất mới
            bookingSeatDAO.updateShowtimeForBooking(bookingId, newShowtimeId, newSeatPrice);
            // Cập nhật SeatIds: xóa cũ, thêm mới
            bookingSeatDAO.deleteByBooking(bookingId);
            List<BookingSeat> newBookingSeats = new ArrayList<>();
            for (int seatId : seatIds) {
                BookingSeat bs = new BookingSeat();
                bs.setBookingId(bookingId);
                bs.setSeatId(seatId);
                bs.setShowtimeId(newShowtimeId);
                bs.setSeatPrice(newSeatPrice);
                bs.setStatus("Confirmed");
                newBookingSeats.add(bs);
            }
            bookingSeatDAO.createBatch(newBookingSeats);

            // 2. Xóa food cũ, thêm food mới
            bookingFoodItemDAO.deleteByBooking(bookingId);
            if (!chosenFood.isEmpty()) {
                bookingFoodItemDAO.createBatch(chosenFood);
            }

            // 3. Cập nhật booking: showtimeId, amounts, voucher
            bookingDAO.updateShowtime(bookingId, newShowtimeId, newSubTotal, newTotal);
            Integer voucherId = appliedVoucher != null ? appliedVoucher.getVoucherId() : null;
            bookingDAO.updateAmountsAndVoucher(bookingId, newSubTotal, discountAmount, newTotal, voucherId);
            if (appliedVoucher != null) {
                voucherDAO.increaseUsedCount(appliedVoucher.getVoucherId());
            }

            // 4. Xóa session exchange
            session.removeAttribute("exchangeBookingId");
            session.removeAttribute("exchangeNewShowtimeId");
            session.removeAttribute("exchangeSeatIds");

            // ---- Xử lý phụ thu ----
            boolean isStaff = user.getRole() != null
                    && !"CUSTOMER".equalsIgnoreCase(user.getRole().getRoleCode());

            if (seatSurcharge.compareTo(BigDecimal.ZERO) > 0) {
                if (isStaff) {
                    Payment extra = new Payment();
                    extra.setBookingId(bookingId);
                    extra.setPaymentMethod("CASH");
                    extra.setAmount(seatSurcharge);
                    extra.setStatus("Paid");
                    extra.setTransactionRef("EXCH_CASH_" + bookingId + "_" + System.currentTimeMillis());
                    extra.setPaidAt(LocalDateTime.now());
                    paymentDAO.create(extra);
                    session.setAttribute("success", "Đổi vé #" + bookingId + " thành công. Phụ thu "
                            + String.format("%,.0f", seatSurcharge) + " ₫ đã thu tại quầy.");
                    resp.sendRedirect(req.getContextPath() + "/staff/bookings");
                } else {
                    // Customer: redirect VNPay
                    String txnRef = "EXCH" + bookingId + "_" + VNPayConfig.getRandomNumber(6);
                    long amountVnpay = seatSurcharge.setScale(0, RoundingMode.HALF_UP).longValue() * 100L;

                    Map<String, String> vnpParams = new HashMap<>();
                    vnpParams.put("vnp_Version",   "2.1.0");
                    vnpParams.put("vnp_Command",    "pay");
                    vnpParams.put("vnp_TmnCode",    VNPayConfig.vnp_TmnCode);
                    vnpParams.put("vnp_Amount",     String.valueOf(amountVnpay));
                    vnpParams.put("vnp_CurrCode",   "VND");
                    vnpParams.put("vnp_TxnRef",     txnRef);
                    vnpParams.put("vnp_OrderInfo",  "Phu thu doi ve " + bookingId);
                    vnpParams.put("vnp_OrderType",  "other");
                    vnpParams.put("vnp_Locale",     "vn");
                    vnpParams.put("vnp_ReturnUrl",  VNPayConfig.getReturnUrl(req));
                    vnpParams.put("vnp_IpAddr",     VNPayConfig.getIpAddress(req));

                    Calendar cld = Calendar.getInstance(TimeZone.getTimeZone("Etc/GMT+7"));
                    SimpleDateFormat fmt = new SimpleDateFormat("yyyyMMddHHmmss");
                    vnpParams.put("vnp_CreateDate", fmt.format(cld.getTime()));
                    cld.add(Calendar.MINUTE, 15);
                    vnpParams.put("vnp_ExpireDate", fmt.format(cld.getTime()));

                    List<String> fieldNames = new ArrayList<>(vnpParams.keySet());
                    Collections.sort(fieldNames);
                    List<String> hashData = new ArrayList<>(), query = new ArrayList<>();
                    for (String name : fieldNames) {
                        String val = vnpParams.get(name);
                        if (val != null && !val.isEmpty()) {
                            String enc = URLEncoder.encode(val, StandardCharsets.UTF_8);
                            hashData.add(name + "=" + enc);
                            query.add(URLEncoder.encode(name, StandardCharsets.UTF_8) + "=" + enc);
                        }
                    }
                    String secureHash = VNPayConfig.hmacSHA512(VNPayConfig.secretKey, String.join("&", hashData));
                    String paymentUrl = VNPayConfig.vnp_PayUrl + "?" + String.join("&", query) + "&vnp_SecureHash=" + secureHash;

                    Payment extra = new Payment();
                    extra.setBookingId(bookingId);
                    extra.setPaymentMethod("VNPay");
                    extra.setAmount(seatSurcharge);
                    extra.setStatus("Pending");
                    extra.setTransactionRef(txnRef);
                    paymentDAO.create(extra);

                    resp.sendRedirect(paymentUrl);
                }
            } else {
                session.setAttribute("success", "Đổi vé #" + bookingId + " thành công.");
                if (isStaff) {
                    resp.sendRedirect(req.getContextPath() + "/staff/bookings");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/profile/bookings");
                }
            }

        } catch (DataAccessException e) {
            session.setAttribute("error", "Đổi vé thất bại: " + e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/profile/bookings");
        }
    }
}
