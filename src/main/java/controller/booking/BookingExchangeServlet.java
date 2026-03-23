package controller.booking;

import dao.BookingDAO;
import dao.BookingSeatDAO;
import dao.PaymentDAO;
import dao.ShowtimeDAO;
import exception.DataAccessException;
import model.Booking;
import model.BookingSeat;
import model.Payment;
import model.Role;
import model.Showtime;
import model.User;
import util.VNPayConfig;
import java.time.LocalDate;

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
import java.util.TimeZone;

/**
 * Đổi vé / Chuyển suất
 * GET  /booking/exchange?bookingId=X          — hiển thị danh sách suất mới + phụ thu
 * POST /booking/exchange                       — xác nhận đổi suất
 *
 * Luồng:
 *  1. Kiểm tra booking hợp lệ (Confirmed, chưa chiếu, đúng chủ hoặc staff)
 *  2. GET: liệt kê các suất cùng phim còn trống, tính phụ thu từng suất
 *  3. POST: chuyển ShowtimeId, cập nhật BookingSeats sang suất mới,
 *           nếu phụ thu > 0 thì tạo Payment thêm (tiền mặt tại quầy)
 */
@WebServlet(name = "BookingExchangeServlet", urlPatterns = {"/booking/exchange"})
public class BookingExchangeServlet extends HttpServlet {

    private final BookingDAO bookingDAO = new BookingDAO();
    private final BookingSeatDAO bookingSeatDAO = new BookingSeatDAO();
    private final ShowtimeDAO showtimeDAO = new ShowtimeDAO();
    private final PaymentDAO paymentDAO = new PaymentDAO();

    // -----------------------------------------------------------------------
    // GET — trang chọn suất mới
    // -----------------------------------------------------------------------
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        User user = (User) session.getAttribute("user");

        String bookingIdStr = req.getParameter("bookingId");
        if (bookingIdStr == null || bookingIdStr.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/profile/bookings");
            return;
        }

        try {
            int bookingId = Integer.parseInt(bookingIdStr);
            Booking booking = bookingDAO.findById(bookingId);
            if (booking == null) {
                session.setAttribute("error", "Không tìm thấy đơn đặt vé.");
                resp.sendRedirect(req.getContextPath() + "/profile/bookings");
                return;
            }

            if (!canExchange(booking, user)) {
                session.setAttribute("error", "Bạn không có quyền đổi vé này.");
                resp.sendRedirect(req.getContextPath() + "/profile/bookings");
                return;
            }

            Showtime currentShowtime = showtimeDAO.findById(booking.getShowtimeId());
            if (currentShowtime == null || !isExchangeable(currentShowtime.getStartTime())) {
                session.setAttribute("error", "Chỉ có thể đổi vé trước giờ chiếu ít nhất 30 phút.");
                resp.sendRedirect(req.getContextPath() + "/profile/bookings");
                return;
            }

            if (!"Confirmed".equalsIgnoreCase(booking.getStatus())) {
                session.setAttribute("error", "Chỉ có thể đổi vé đã thanh toán.");
                resp.sendRedirect(req.getContextPath() + "/profile/bookings");
                return;
            }

            // Ghế hiện tại của booking
            List<BookingSeat> currentSeats = bookingSeatDAO.findByBookingWithSeat(bookingId);
            int seatCount = currentSeats.size();
            BigDecimal oldSeatPrice = currentSeats.isEmpty()
                    ? currentShowtime.getBasePrice()
                    : currentSeats.get(0).getSeatPrice();

            // Danh sách ngày có suất chiếu để hiển thị date picker
            List<LocalDate> availableDates = showtimeDAO.findAvailableDatesByMovie(
                    currentShowtime.getMovieId(), currentShowtime.getShowtimeId());

            // Nếu user đã chọn ngày, lấy suất của ngày đó; nếu chưa chọn thì không hiển thị suất
            String dateParam = req.getParameter("date");
            List<Showtime> showtimesForDate = null;
            LocalDate selectedDate = null;
            if (dateParam != null && !dateParam.isBlank()) {
                try {
                    selectedDate = LocalDate.parse(dateParam);
                    showtimesForDate = showtimeDAO.findUpcomingByMovieAndDate(
                            currentShowtime.getMovieId(), currentShowtime.getShowtimeId(), selectedDate);
                } catch (Exception ignored) {}
            }

            req.setAttribute("booking", booking);
            req.setAttribute("currentShowtime", currentShowtime);
            req.setAttribute("currentSeats", currentSeats);
            req.setAttribute("seatCount", seatCount);
            req.setAttribute("oldSeatPrice", oldSeatPrice);
            req.setAttribute("availableDates", availableDates);
            req.setAttribute("selectedDate", selectedDate != null ? selectedDate.toString() : "");
            req.setAttribute("showtimesForDate", showtimesForDate);
            req.getRequestDispatcher("/booking/exchange.jsp").forward(req, resp);

        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/profile/bookings");
        }
    }

    // -----------------------------------------------------------------------
    // POST — thực hiện đổi suất
    // -----------------------------------------------------------------------
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        User user = (User) session.getAttribute("user");

        String bookingIdStr    = req.getParameter("bookingId");
        String newShowtimeIdStr = req.getParameter("newShowtimeId");

        if (bookingIdStr == null || bookingIdStr.isBlank()
                || newShowtimeIdStr == null || newShowtimeIdStr.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/profile/bookings");
            return;
        }

        try {
            int bookingId     = Integer.parseInt(bookingIdStr);
            int newShowtimeId = Integer.parseInt(newShowtimeIdStr);

            Booking booking = bookingDAO.findById(bookingId);
            if (booking == null || !canExchange(booking, user)) {
                session.setAttribute("error", "Không thể đổi vé này.");
                resp.sendRedirect(req.getContextPath() + "/profile/bookings");
                return;
            }

            if (!"Confirmed".equalsIgnoreCase(booking.getStatus())) {
                session.setAttribute("error", "Chỉ có thể đổi vé đã thanh toán.");
                resp.sendRedirect(req.getContextPath() + "/profile/bookings");
                return;
            }

            Showtime oldShowtime = showtimeDAO.findById(booking.getShowtimeId());
            Showtime newShowtime = showtimeDAO.findById(newShowtimeId);

            if (oldShowtime == null || newShowtime == null) {
                session.setAttribute("error", "Suất chiếu không hợp lệ.");
                resp.sendRedirect(req.getContextPath() + "/profile/bookings");
                return;
            }
            if (!isExchangeable(oldShowtime.getStartTime())) {
                session.setAttribute("error", "Chỉ có thể đổi vé trước giờ chiếu ít nhất 30 phút.");
                resp.sendRedirect(req.getContextPath() + "/profile/bookings");
                return;
            }
            if (!newShowtime.getStartTime().isAfter(LocalDateTime.now())) {
                session.setAttribute("error", "Suất chiếu mới đã qua.");
                resp.sendRedirect(req.getContextPath() + "/profile/bookings");
                return;
            }
            if (newShowtime.getMovieId() != oldShowtime.getMovieId()) {
                session.setAttribute("error", "Chỉ có thể đổi sang suất cùng phim.");
                resp.sendRedirect(req.getContextPath() + "/profile/bookings");
                return;
            }

            // Ghế hiện tại
            List<BookingSeat> currentSeats = bookingSeatDAO.findByBookingWithSeat(bookingId);
            int seatCount = currentSeats.size();
            BigDecimal oldSeatPrice = currentSeats.isEmpty()
                    ? oldShowtime.getBasePrice()
                    : currentSeats.get(0).getSeatPrice();
            BigDecimal newSeatPrice = newShowtime.getBasePrice();

            // Tính phụ thu
            BigDecimal surcharge = BigDecimal.ZERO;
            if (newSeatPrice.compareTo(oldSeatPrice) > 0) {
                surcharge = newSeatPrice.subtract(oldSeatPrice)
                        .multiply(BigDecimal.valueOf(seatCount));
            }

            // Cập nhật BookingSeats: đổi ShowtimeId và SeatPrice
            bookingSeatDAO.updateShowtimeForBooking(bookingId, newShowtimeId, newSeatPrice);

            // Cập nhật Booking: đổi ShowtimeId, cập nhật SubTotal và TotalAmount
            BigDecimal newSubTotal = newSeatPrice.multiply(BigDecimal.valueOf(seatCount));
            BigDecimal newTotal    = booking.getTotalAmount().add(surcharge);
            bookingDAO.updateShowtime(bookingId, newShowtimeId, newSubTotal, newTotal);

            if (surcharge.compareTo(BigDecimal.ZERO) > 0) {
                if (isStaff(user)) {
                    // Staff thu tiền mặt tại quầy → ghi payment CASH ngay
                    Payment extra = new Payment();
                    extra.setBookingId(bookingId);
                    extra.setPaymentMethod("CASH");
                    extra.setAmount(surcharge);
                    extra.setStatus("Paid");
                    extra.setTransactionRef("EXCH_CASH_" + bookingId + "_" + System.currentTimeMillis());
                    extra.setPaidAt(LocalDateTime.now());
                    paymentDAO.create(extra);

                    session.setAttribute("success", "Đổi vé #" + bookingId + " thành công. Phụ thu "
                            + String.format("%,.0f", surcharge) + " ₫ đã thu tại quầy.");
                    resp.sendRedirect(req.getContextPath() + "/staff/bookings");
                } else {
                    // Customer → chuyển sang VNPay thanh toán phụ thu
                    String txnRef = "EXCH" + bookingId + "_" + VNPayConfig.getRandomNumber(6);
                    long amountVnpay = surcharge.setScale(0, RoundingMode.HALF_UP).longValue() * 100L;

                    Map<String, String> vnpParams = new HashMap<>();
                    vnpParams.put("vnp_Version",    "2.1.0");
                    vnpParams.put("vnp_Command",     "pay");
                    vnpParams.put("vnp_TmnCode",     VNPayConfig.vnp_TmnCode);
                    vnpParams.put("vnp_Amount",      String.valueOf(amountVnpay));
                    vnpParams.put("vnp_CurrCode",    "VND");
                    vnpParams.put("vnp_TxnRef",      txnRef);
                    vnpParams.put("vnp_OrderInfo",   "Phu thu doi ve " + bookingId);
                    vnpParams.put("vnp_OrderType",   "other");
                    vnpParams.put("vnp_Locale",      "vn");
                    vnpParams.put("vnp_ReturnUrl",   VNPayConfig.getReturnUrl(req));
                    vnpParams.put("vnp_IpAddr",      VNPayConfig.getIpAddress(req));

                    Calendar cld = Calendar.getInstance(TimeZone.getTimeZone("Etc/GMT+7"));
                    SimpleDateFormat fmt = new SimpleDateFormat("yyyyMMddHHmmss");
                    vnpParams.put("vnp_CreateDate", fmt.format(cld.getTime()));
                    cld.add(Calendar.MINUTE, 15);
                    vnpParams.put("vnp_ExpireDate", fmt.format(cld.getTime()));

                    List<String> fieldNames = new ArrayList<>(vnpParams.keySet());
                    Collections.sort(fieldNames);
                    List<String> hashData  = new ArrayList<>();
                    List<String> query     = new ArrayList<>();
                    for (String name : fieldNames) {
                        String val = vnpParams.get(name);
                        if (val != null && !val.isEmpty()) {
                            String enc = URLEncoder.encode(val, StandardCharsets.UTF_8);
                            hashData.add(name + "=" + enc);
                            query.add(URLEncoder.encode(name, StandardCharsets.UTF_8) + "=" + enc);
                        }
                    }
                    String secureHash = VNPayConfig.hmacSHA512(VNPayConfig.secretKey,
                            String.join("&", hashData));
                    String paymentUrl = VNPayConfig.vnp_PayUrl + "?"
                            + String.join("&", query) + "&vnp_SecureHash=" + secureHash;

                    // Lưu payment Pending cho phụ thu
                    Payment extra = new Payment();
                    extra.setBookingId(bookingId);
                    extra.setPaymentMethod("VNPay");
                    extra.setAmount(surcharge);
                    extra.setStatus("Pending");
                    extra.setTransactionRef(txnRef);
                    paymentDAO.create(extra);

                    resp.sendRedirect(paymentUrl);
                }
            } else {
                // Không có phụ thu → xong luôn
                session.setAttribute("success", "Đổi vé #" + bookingId + " thành công.");
                if (isStaff(user)) {
                    resp.sendRedirect(req.getContextPath() + "/staff/bookings");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/profile/bookings");
                }
            }

        } catch (NumberFormatException | DataAccessException e) {
            session.setAttribute("error", "Đổi vé thất bại: " + e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/profile/bookings");
        }
    }

    // -----------------------------------------------------------------------
    // Helpers
    // -----------------------------------------------------------------------
    /** Chỉ cho phép đổi nếu còn ít nhất 30 phút trước giờ chiếu. */
    private boolean isExchangeable(LocalDateTime startTime) {
        return startTime != null && startTime.isAfter(LocalDateTime.now().plusMinutes(30));
    }

    private boolean canExchange(Booking booking, User user) {
        boolean isOwner = booking.getUserId() != null
                && booking.getUserId().equals(user.getUserId());
        return isOwner || isStaff(user);
    }

    private boolean isStaff(User user) {
        Role role = user.getRole();
        return role != null && !"CUSTOMER".equalsIgnoreCase(role.getRoleCode());
    }
}
