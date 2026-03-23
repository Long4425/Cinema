package controller.booking;

import dao.BookingDAO;
import dao.BookingDAO.BookingRow;
import dao.BookingSeatDAO;
import dao.PaymentDAO;
import dao.ShowtimeDAO;
import model.Booking;
import model.Payment;
import model.Showtime;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.List;

/**
 * Quản lý booking cho staff (CASHIER, MANAGER).
 * GET  /staff/bookings          - danh sách, filter/search
 * POST /staff/bookings?action=cancel  - hủy vé + đánh dấu hoàn tiền
 * POST /staff/bookings?action=refund  - chỉ đánh dấu hoàn tiền (booking đã Cancelled)
 */
@WebServlet(name = "StaffBookingManagementServlet", urlPatterns = {"/staff/bookings"})
public class StaffBookingManagementServlet extends HttpServlet {

    private final BookingDAO bookingDAO = new BookingDAO();
    private final BookingSeatDAO bookingSeatDAO = new BookingSeatDAO();
    private final PaymentDAO paymentDAO = new PaymentDAO();
    private final ShowtimeDAO showtimeDAO = new ShowtimeDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String keyword = req.getParameter("keyword");
        String status  = req.getParameter("status");
        String date    = req.getParameter("date");

        final int PAGE_SIZE = 20;
        int page = 1;
        try {
            String p = req.getParameter("page");
            if (p != null) page = Math.max(1, Integer.parseInt(p));
        } catch (NumberFormatException ignored) {}

        int totalRows  = bookingDAO.countFiltered(keyword, status, date);
        int totalPages = Math.max(1, (int) Math.ceil((double) totalRows / PAGE_SIZE));
        if (page > totalPages) page = totalPages;

        List<BookingRow> rows = bookingDAO.findAllFiltered(keyword, status, date, page, PAGE_SIZE);

        req.setAttribute("rows", rows);
        req.setAttribute("keyword", keyword);
        req.setAttribute("filterStatus", status);
        req.setAttribute("filterDate", date);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalRows", totalRows);
        req.setAttribute("pageSize", PAGE_SIZE);
        req.setAttribute("activeTab", "STAFF_BOOKINGS");
        req.getRequestDispatcher("/booking/staff-booking-list.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        User staff = (User) session.getAttribute("user");

        String action      = req.getParameter("action");
        String bookingIdStr = req.getParameter("bookingId");
        if (bookingIdStr == null || bookingIdStr.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/staff/bookings");
            return;
        }

        try {
            int bookingId = Integer.parseInt(bookingIdStr);
            Booking booking = bookingDAO.findById(bookingId);
            if (booking == null) {
                resp.sendRedirect(req.getContextPath() + "/staff/bookings");
                return;
            }

            if ("cancel".equals(action)) {
                handleCancel(req, resp, booking, staff);
            } else if ("refund".equals(action)) {
                handleRefund(req, resp, booking, staff);
            } else {
                resp.sendRedirect(req.getContextPath() + "/staff/bookings");
            }
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/staff/bookings");
        }
    }

    private void handleCancel(HttpServletRequest req, HttpServletResponse resp,
                               Booking booking, User staff) throws IOException {
        HttpSession session = req.getSession(false);

        if ("Cancelled".equalsIgnoreCase(booking.getStatus())
                || "Refunded".equalsIgnoreCase(booking.getStatus())) {
            session.setAttribute("error", "Vé này đã được hủy trước đó.");
            resp.sendRedirect(req.getContextPath() + "/staff/bookings" + buildQuery(req));
            return;
        }

        Showtime showtime = showtimeDAO.findById(booking.getShowtimeId());
        if (showtime == null || showtime.getStartTime() == null
                || !showtime.getStartTime().isAfter(LocalDateTime.now())) {
            session.setAttribute("error", "Vé đã quá giờ chiếu, không thể hủy.");
            resp.sendRedirect(req.getContextPath() + "/staff/bookings" + buildQuery(req));
            return;
        }

        bookingSeatDAO.updateStatusByBooking(booking.getBookingId(), "Cancelled");

        // Đánh dấu hoàn tiền ngay nếu đã có payment, đồng thời đặt booking thành Refunded
        Payment payment = paymentDAO.findLatestByBooking(booking.getBookingId());
        if (payment != null && !"Refunded".equalsIgnoreCase(payment.getStatus())) {
            paymentDAO.markRefunded(payment.getPaymentId(), staff.getUserId());
            bookingDAO.updateStatus(booking.getBookingId(), "Refunded");
        } else {
            bookingDAO.updateStatus(booking.getBookingId(), "Cancelled");
        }

        session.setAttribute("success", "Đã hủy và hoàn tiền vé #" + booking.getBookingId() + " thành công.");
        resp.sendRedirect(req.getContextPath() + "/staff/bookings" + buildQuery(req));
    }

    private void handleRefund(HttpServletRequest req, HttpServletResponse resp,
                               Booking booking, User staff) throws IOException {
        HttpSession session = req.getSession(false);

        if (!"Cancelled".equalsIgnoreCase(booking.getStatus())) {
            session.setAttribute("error", "Chỉ có thể đánh dấu hoàn tiền cho vé đã hủy.");
            resp.sendRedirect(req.getContextPath() + "/staff/bookings" + buildQuery(req));
            return;
        }

        Payment payment = paymentDAO.findLatestByBooking(booking.getBookingId());
        if (payment == null) {
            session.setAttribute("error", "Không tìm thấy thông tin thanh toán cho vé này.");
            resp.sendRedirect(req.getContextPath() + "/staff/bookings" + buildQuery(req));
            return;
        }
        if ("Refunded".equalsIgnoreCase(payment.getStatus())) {
            session.setAttribute("error", "Vé này đã được đánh dấu hoàn tiền trước đó.");
            resp.sendRedirect(req.getContextPath() + "/staff/bookings" + buildQuery(req));
            return;
        }

        paymentDAO.markRefunded(payment.getPaymentId(), staff.getUserId());
        bookingDAO.updateStatus(booking.getBookingId(), "Refunded");
        session.setAttribute("success", "Đã đánh dấu hoàn tiền cho vé #" + booking.getBookingId() + ".");
        resp.sendRedirect(req.getContextPath() + "/staff/bookings" + buildQuery(req));
    }

    /** Giữ lại filter params sau khi POST để trang reload đúng filter. */
    private String buildQuery(HttpServletRequest req) {
        StringBuilder sb = new StringBuilder("?");
        String keyword = req.getParameter("keyword");
        String status  = req.getParameter("filterStatus");
        String date    = req.getParameter("filterDate");
        if (keyword != null && !keyword.isBlank()) sb.append("keyword=").append(keyword).append("&");
        if (status  != null && !status.isBlank())  sb.append("status=").append(status).append("&");
        if (date    != null && !date.isBlank())     sb.append("date=").append(date).append("&");
        return sb.length() > 1 ? sb.toString() : "";
    }
}
