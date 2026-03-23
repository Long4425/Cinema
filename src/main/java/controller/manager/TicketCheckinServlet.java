package controller.manager;

import dao.BookingDAO;
import dao.BookingSeatDAO;
import dao.ShowtimeDAO;
import dao.UserDAO;
import model.Booking;
import model.BookingSeat;
import model.Showtime;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@WebServlet(name = "TicketCheckinServlet", urlPatterns = {"/manager/ticket-checkin"})
public class TicketCheckinServlet extends HttpServlet {

    private static final String VIEW = "/booking/ticket-checkin.jsp";
    private static final String ATTR_ERROR = "error";
    private static final String ATTR_KEYWORD = "keyword";

    private final BookingDAO bookingDAO = new BookingDAO();
    private final BookingSeatDAO bookingSeatDAO = new BookingSeatDAO();
    private final ShowtimeDAO showtimeDAO = new ShowtimeDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String bookingIdParam = req.getParameter("bookingId");
        if (bookingIdParam != null && !bookingIdParam.isBlank()) {
            lookup(req, resp, bookingIdParam.trim());
        } else {
            req.getRequestDispatcher(VIEW).forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String keyword = req.getParameter(ATTR_KEYWORD);
        if (keyword == null || keyword.isBlank()) {
            req.setAttribute(ATTR_ERROR, "Vui lòng nhập mã đơn hoặc email khách hàng.");
            req.getRequestDispatcher(VIEW).forward(req, resp);
            return;
        }
        lookup(req, resp, keyword.trim());
    }

    private void lookup(HttpServletRequest req, HttpServletResponse resp, String keyword)
            throws ServletException, IOException {
        Booking booking = null;
        User user = null;

        try {
            int bookingId = Integer.parseInt(keyword);
            booking = bookingDAO.findById(bookingId);
        } catch (NumberFormatException ignored) {
            Optional<User> userOpt = userDAO.findByEmail(keyword);
            if (userOpt.isPresent()) {
                user = userOpt.get();
                List<Booking> userBookings = bookingDAO.findByUser(user.getUserId());
                if (!userBookings.isEmpty()) {
                    booking = userBookings.get(0);
                }
            }
        }

        if (booking == null) {
            req.setAttribute(ATTR_ERROR, "Không tìm thấy đơn đặt vé phù hợp.");
            req.getRequestDispatcher(VIEW).forward(req, resp);
            return;
        }

        Showtime showtime = showtimeDAO.findById(booking.getShowtimeId());
        List<BookingSeat> seats = bookingSeatDAO.findByBookingWithSeat(booking.getBookingId());

        LocalDateTime now = LocalDateTime.now();
        boolean isValid;
        String reason;

        if (!"Confirmed".equalsIgnoreCase(booking.getStatus())) {
            isValid = false;
            reason = "Đơn chưa thanh toán hoặc đã bị hủy (trạng thái: " + booking.getStatus() + ").";
        } else if (showtime == null || showtime.getStartTime() == null) {
            isValid = false;
            reason = "Không xác định được thời gian suất chiếu.";
        } else if (showtime.getStartTime().isBefore(now.minusMinutes(15))) {
            isValid = false;
            reason = "Suất chiếu đã qua quá lâu, vé không còn hợp lệ.";
        } else if (showtime.getStartTime().isAfter(now.plusHours(4))) {
            isValid = false;
            reason = "Vé chỉ được check-in trong khoảng gần giờ chiếu.";
        } else {
            isValid = true;
            reason = "Vé hợp lệ để check-in.";
        }

        req.setAttribute(ATTR_KEYWORD, keyword);
        req.setAttribute("booking", booking);
        req.setAttribute("showtime", showtime);
        req.setAttribute("bookingSeats", seats);
        req.setAttribute("customer", user);
        req.setAttribute("isValid", isValid);
        req.setAttribute("reason", reason);
        req.getRequestDispatcher(VIEW).forward(req, resp);
    }
}
