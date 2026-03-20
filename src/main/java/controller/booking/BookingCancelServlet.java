package controller.booking;

import dao.BookingDAO;
import dao.BookingSeatDAO;
import dao.PaymentDAO;
import dao.ShowtimeDAO;
import model.Booking;
import model.Payment;
import model.Role;
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

@WebServlet(name = "BookingCancelServlet", urlPatterns = {"/booking/cancel"})
public class BookingCancelServlet extends HttpServlet {

    private final BookingDAO bookingDAO = new BookingDAO();
    private final BookingSeatDAO bookingSeatDAO = new BookingSeatDAO();
    private final PaymentDAO paymentDAO = new PaymentDAO();
    private final ShowtimeDAO showtimeDAO = new ShowtimeDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        User user = (User) session.getAttribute("user");
        Role role = user.getRole();
        String bookingIdStr = req.getParameter("bookingId");
        if (bookingIdStr == null || bookingIdStr.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/profile/bookings");
            return;
        }
        try {
            int bookingId = Integer.parseInt(bookingIdStr);
            Booking booking = bookingDAO.findById(bookingId);
            if (booking == null) {
                resp.sendRedirect(req.getContextPath() + "/profile/bookings");
                return;
            }

            boolean isOwner = booking.getUserId() != null && booking.getUserId() == user.getUserId();
            boolean isStaff = role != null && !"CUSTOMER".equalsIgnoreCase(role.getRoleCode());
            if (!isOwner && !isStaff) {
                resp.sendRedirect(req.getContextPath() + "/profile/bookings");
                return;
            }

            Showtime showtime = showtimeDAO.findById(booking.getShowtimeId());
            LocalDateTime now = LocalDateTime.now();
            if (showtime == null || showtime.getStartTime() == null
                    || !showtime.getStartTime().isAfter(now)) {
                session.setAttribute("error", "Vé đã quá giờ chiếu, không thể hủy.");
                resp.sendRedirect(req.getContextPath() + "/profile/bookings");
                return;
            }

            if ("Cancelled".equalsIgnoreCase(booking.getStatus())
                    || "Refunded".equalsIgnoreCase(booking.getStatus())) {
                resp.sendRedirect(req.getContextPath() + "/profile/bookings");
                return;
            }

            // Xử lý hoàn tiền nội bộ (không gọi API VNPay)
            Payment payment = paymentDAO.findLatestByBooking(bookingId);
            if (payment != null && !"Refunded".equalsIgnoreCase(payment.getStatus())) {
                Integer refundedBy = isStaff ? user.getUserId() : null;
                paymentDAO.markRefunded(payment.getPaymentId(), refundedBy);
            }

            bookingDAO.updateStatus(bookingId, "Cancelled");
            bookingSeatDAO.updateStatusByBooking(bookingId, "Cancelled");

            session.setAttribute("success", "Đã hủy vé và hoàn tiền (nếu có) thành công.");
            resp.sendRedirect(req.getContextPath() + "/profile/bookings");
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/profile/bookings");
        }
    }
}

