package controller.counter;

import dao.BookingDAO;
import dao.BookingFoodItemDAO;
import dao.BookingSeatDAO;
import dao.FoodItemDAO;
import dao.PaymentDAO;
import dao.UserDAO;
import dao.VoucherDAO;
import exception.DataAccessException;
import model.Booking;
import model.BookingFoodItem;
import model.BookingSeat;
import model.FoodItem;
import model.Payment;
import model.Showtime;
import model.Voucher;
import dao.ShowtimeDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Thu ngân hoàn tất đặt vé tại quầy: chọn đồ ăn, áp voucher, thanh toán tiền mặt, tích điểm.
 * GET  /counter/checkout  – hiển thị trang checkout
 * POST /counter/checkout  – xử lý thanh toán tiền mặt
 */
@WebServlet(name = "CounterCheckoutServlet", urlPatterns = {"/counter/checkout"})
public class CounterCheckoutServlet extends HttpServlet {

    private static final int POINTS_PER_VND = 10_000; // 10.000đ = 1 điểm

    private final BookingDAO bookingDAO = new BookingDAO();
    private final BookingSeatDAO bookingSeatDAO = new BookingSeatDAO();
    private final FoodItemDAO foodItemDAO = new FoodItemDAO();
    private final BookingFoodItemDAO bookingFoodItemDAO = new BookingFoodItemDAO();
    private final VoucherDAO voucherDAO = new VoucherDAO();
    private final ShowtimeDAO showtimeDAO = new ShowtimeDAO();
    private final PaymentDAO paymentDAO = new PaymentDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null) {
            resp.sendRedirect(req.getContextPath() + "/showtimes");
            return;
        }
        Integer bookingId = (Integer) session.getAttribute("counterBookingId");
        if (bookingId == null) {
            resp.sendRedirect(req.getContextPath() + "/showtimes");
            return;
        }

        Booking booking = bookingDAO.findById(bookingId);
        if (booking == null) {
            resp.sendRedirect(req.getContextPath() + "/showtimes");
            return;
        }

        List<BookingSeat> bookingSeats = bookingSeatDAO.findByBookingWithSeat(bookingId);
        List<FoodItem> foodItems = foodItemDAO.findAvailable();
        Showtime showtime = showtimeDAO.findById(booking.getShowtimeId());

        // Voucher cá nhân của khách (nếu có)
        if (booking.getUserId() != null) {
            req.setAttribute("myVouchers", voucherDAO.findActiveByUser(booking.getUserId()));
            userDAO.findById(booking.getUserId()).ifPresent(c -> req.setAttribute("customer", c));
        }

        // Validate voucher nếu có param (dùng cho preview discount)
        String voucherCode = req.getParameter("voucherCode");
        if (voucherCode != null && !voucherCode.isBlank()) {
            voucherCode = voucherCode.trim();
            BigDecimal subTotal = booking.getSubTotal() != null ? booking.getSubTotal() : BigDecimal.ZERO;
            Voucher v = voucherDAO.findValidByCode(voucherCode, subTotal);
            if (v == null) {
                req.setAttribute("voucherError", "Mã voucher không hợp lệ hoặc không đáp ứng điều kiện.");
            } else {
                BigDecimal discount;
                if ("Percent".equalsIgnoreCase(v.getDiscountType())) {
                    discount = subTotal.multiply(v.getDiscountValue())
                            .divide(BigDecimal.valueOf(100), 0, RoundingMode.HALF_UP);
                } else {
                    discount = v.getDiscountValue().setScale(0, RoundingMode.HALF_UP);
                }
                if (discount.compareTo(subTotal) > 0) discount = subTotal;
                req.setAttribute("appliedVoucherCode", voucherCode);
                req.setAttribute("appliedVoucherDiscount", discount);
                req.setAttribute("appliedVoucherType", v.getDiscountType());
                req.setAttribute("appliedVoucherValue", v.getDiscountValue());
            }
        }

        req.setAttribute("booking", booking);
        req.setAttribute("bookingSeats", bookingSeats);
        req.setAttribute("foodItems", foodItems);
        req.setAttribute("showtime", showtime);
        req.getRequestDispatcher("/booking/counter-checkout.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null) {
            resp.sendRedirect(req.getContextPath() + "/showtimes");
            return;
        }
        Integer bookingId = (Integer) session.getAttribute("counterBookingId");
        if (bookingId == null) {
            resp.sendRedirect(req.getContextPath() + "/showtimes");
            return;
        }

        Booking booking = bookingDAO.findById(bookingId);
        if (booking == null) {
            resp.sendRedirect(req.getContextPath() + "/showtimes");
            return;
        }

        List<FoodItem> foodItems = foodItemDAO.findAvailable();
        List<BookingFoodItem> chosenItems = new ArrayList<>();
        BigDecimal foodTotal = BigDecimal.ZERO;

        for (FoodItem f : foodItems) {
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
                chosenItems.add(bfi);
                foodTotal = foodTotal.add(f.getPrice().multiply(BigDecimal.valueOf(qty)));
            } catch (NumberFormatException ignore) {}
        }

        BigDecimal ticketSubTotal = booking.getSubTotal() != null ? booking.getSubTotal() : BigDecimal.ZERO;
        foodTotal = foodTotal.setScale(0, RoundingMode.HALF_UP);
        BigDecimal newSubTotal = ticketSubTotal.add(foodTotal).setScale(0, RoundingMode.HALF_UP);

        // Áp voucher
        String voucherCode = req.getParameter("voucherCode");
        Voucher appliedVoucher = null;
        BigDecimal discountAmount = BigDecimal.ZERO;

        if (voucherCode != null && !voucherCode.isBlank()) {
            voucherCode = voucherCode.trim();
            Voucher v = voucherDAO.findValidByCode(voucherCode, newSubTotal);
            if (v == null) {
                req.setAttribute("voucherError", "Mã voucher không hợp lệ hoặc không đáp ứng điều kiện.");
                loadGetAttributes(req, booking, bookingId, foodItems);
                req.getRequestDispatcher("/booking/counter-checkout.jsp").forward(req, resp);
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

        BigDecimal totalAmount = newSubTotal.subtract(discountAmount).setScale(0, RoundingMode.HALF_UP);

        try {
            bookingFoodItemDAO.createBatch(chosenItems);

            Integer voucherId = appliedVoucher != null ? appliedVoucher.getVoucherId() : null;
            bookingDAO.updateAmountsAndVoucher(bookingId, newSubTotal, discountAmount, totalAmount, voucherId);

            if (appliedVoucher != null) {
                voucherDAO.increaseUsedCount(appliedVoucher.getVoucherId());
            }

            // Thanh toán tiền mặt
            Payment payment = new Payment();
            payment.setBookingId(bookingId);
            payment.setPaymentMethod("Cash");
            payment.setAmount(totalAmount);
            payment.setStatus("Success");
            payment.setPaidAt(LocalDateTime.now());
            paymentDAO.create(payment);

            // Xác nhận booking + ghế
            bookingDAO.updateStatus(bookingId, "Confirmed");
            bookingSeatDAO.updateStatusByBooking(bookingId, "Confirmed");

            // Tích điểm cho khách (nếu có tài khoản)
            if (booking.getUserId() != null) {
                long totalVnd = totalAmount.longValue();
                int earned = (int) (totalVnd / POINTS_PER_VND);
                if (earned > 0) {
                    userDAO.addLoyaltyPoints(booking.getUserId(), earned);
                    bookingDAO.updatePointsEarned(bookingId, earned);
                }
            }

            session.removeAttribute("counterBookingId");
            resp.sendRedirect(req.getContextPath() + "/booking/summary?bookingId=" + bookingId);
        } catch (DataAccessException e) {
            req.setAttribute("error", e.getMessage());
            loadGetAttributes(req, booking, bookingId, foodItems);
            req.getRequestDispatcher("/booking/counter-checkout.jsp").forward(req, resp);
        }
    }

    private void loadGetAttributes(HttpServletRequest req, Booking booking, int bookingId, List<FoodItem> foodItems) {
        req.setAttribute("booking", booking);
        req.setAttribute("bookingSeats", bookingSeatDAO.findByBookingWithSeat(bookingId));
        req.setAttribute("foodItems", foodItems);
        req.setAttribute("showtime", showtimeDAO.findById(booking.getShowtimeId()));
        if (booking.getUserId() != null) {
            req.setAttribute("myVouchers", voucherDAO.findActiveByUser(booking.getUserId()));
            userDAO.findById(booking.getUserId()).ifPresent(c -> req.setAttribute("customer", c));
        }
    }
}
