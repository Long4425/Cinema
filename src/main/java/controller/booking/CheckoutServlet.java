package controller.booking;

import dao.BookingDAO;
import dao.BookingFoodItemDAO;
import dao.BookingSeatDAO;
import dao.FoodItemDAO;
import dao.ShowtimeDAO;
import dao.VoucherDAO;
import exception.DataAccessException;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.Booking;
import model.BookingFoodItem;
import model.BookingSeat;
import model.FoodItem;
import model.Showtime;
import model.Voucher;

@WebServlet(name = "CheckoutServlet", urlPatterns = {"/booking/checkout"})
public class CheckoutServlet extends HttpServlet {

    private final BookingDAO bookingDAO = new BookingDAO();
    private final BookingSeatDAO bookingSeatDAO = new BookingSeatDAO();
    private final FoodItemDAO foodItemDAO = new FoodItemDAO();
    private final BookingFoodItemDAO bookingFoodItemDAO = new BookingFoodItemDAO();
    private final VoucherDAO voucherDAO = new VoucherDAO();
    private final ShowtimeDAO showtimeDAO = new ShowtimeDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null) {
            resp.sendRedirect(req.getContextPath() + "/showtimes");
            return;
        }
        Integer bookingId = (Integer) session.getAttribute("currentBookingId");
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

        req.setAttribute("booking", booking);
        req.setAttribute("bookingSeats", bookingSeats);
        req.setAttribute("foodItems", foodItems);
        req.setAttribute("showtime", showtime);

        req.getRequestDispatcher("/booking/checkout.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null) {
            resp.sendRedirect(req.getContextPath() + "/showtimes");
            return;
        }
        Integer bookingId = (Integer) session.getAttribute("currentBookingId");
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
            if (qtyStr == null || qtyStr.isBlank()) {
                continue;
            }
            try {
                int qty = Integer.parseInt(qtyStr);
                if (qty <= 0) {
                    continue;
                }
                BookingFoodItem bfi = new BookingFoodItem();
                bfi.setBookingId(bookingId);
                bfi.setFoodItemId(f.getFoodItemId());
                bfi.setQuantity(qty);
                bfi.setUnitPrice(f.getPrice());
                chosenItems.add(bfi);

                foodTotal = foodTotal.add(f.getPrice().multiply(BigDecimal.valueOf(qty)));
            } catch (NumberFormatException ignore) {
                // skip invalid quantity
            }
        }

        String voucherCode = req.getParameter("voucherCode");
        Voucher appliedVoucher = null;
        BigDecimal discountAmount = BigDecimal.ZERO;

        BigDecimal ticketSubTotal = booking.getSubTotal(); // hiện đang chỉ là tiền vé
        BigDecimal newSubTotal = ticketSubTotal.add(foodTotal);

        if (voucherCode != null && !voucherCode.isBlank()) {
            voucherCode = voucherCode.trim();
            Voucher v = voucherDAO.findValidByCode(voucherCode, newSubTotal);
            if (v == null) {
                req.setAttribute("voucherError", "Mã voucher không hợp lệ hoặc không đáp ứng điều kiện.");
            } else {
                appliedVoucher = v;
                if ("Percent".equalsIgnoreCase(v.getDiscountType())) {
                    discountAmount = newSubTotal.multiply(v.getDiscountValue())
                            .divide(BigDecimal.valueOf(100));
                } else {
                    discountAmount = v.getDiscountValue();
                }
                if (discountAmount.compareTo(newSubTotal) > 0) {
                    discountAmount = newSubTotal;
                }
            }
        }

        BigDecimal totalAmount = newSubTotal.subtract(discountAmount);

        try {
            // lưu đồ ăn (nếu có)
            bookingFoodItemDAO.createBatch(chosenItems);

            // cập nhật tiền + voucher cho booking
            Integer voucherId = appliedVoucher != null ? appliedVoucher.getVoucherId() : null;
            bookingDAO.updateAmountsAndVoucher(bookingId, newSubTotal, discountAmount, totalAmount, voucherId);

            if (appliedVoucher != null) {
                voucherDAO.increaseUsedCount(appliedVoucher.getVoucherId());
            }

            // cập nhật giá trị ngay trên object booking để hiển thị lại
            booking.setSubTotal(newSubTotal);
            booking.setDiscountAmount(discountAmount);
            booking.setTotalAmount(totalAmount);
            if (appliedVoucher != null) {
                booking.setVoucherId(appliedVoucher.getVoucherId());
            }

            String payAction = req.getParameter("payAction");
            if ("counter".equals(payAction)) {
                // Thanh toán tại quầy: tạm thời chỉ redirect tới trang xác nhận đơn, phần UC-16/17 sẽ xử lý tiếp
                resp.sendRedirect(req.getContextPath() + "/booking/summary");
            } else {
                // Mặc định: chuyển sang thanh toán online VNPay (sẽ cài ở bước sau)
                resp.sendRedirect(req.getContextPath() + "/payment/vnpay?bookingId=" + bookingId);
            }
        } catch (DataAccessException e) {
            req.setAttribute("error", e.getMessage());
            req.setAttribute("booking", booking);
            req.setAttribute("bookingSeats", bookingSeatDAO.findByBookingWithSeat(bookingId));
            req.setAttribute("foodItems", foodItems);
            req.getRequestDispatcher("/booking/checkout.jsp").forward(req, resp);
        }
    }
}

