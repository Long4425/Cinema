package controller.manager;

import dao.BookingDAO;
import dao.BookingSeatDAO;
import dao.ShowtimeDAO;
import dao.UserDAO;
import model.Booking;
import model.BookingSeat;
import model.Showtime;
import model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

@WebServlet(name = "TicketCheckinServlet", urlPatterns = {"/manager/ticket-checkin"})
public class TicketCheckinServlet extends HttpServlet {

    private final BookingDAO bookingDAO = new BookingDAO();
    private final BookingSeatDAO bookingSeatDAO = new BookingSeatDAO();
    private final ShowtimeDAO showtimeDAO = new ShowtimeDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/booking/ticket-checkin.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String keyword = req.getParameter("keyword");
        if (keyword == null || keyword.isBlank()) {
            req.setAttribute("error", "Vui lòng nhập mã đơn hoặc email khách hàng.");
            req.getRequestDispatcher("/booking/ticket-checkin.jsp").forward(req, resp);
            return;
        }
        keyword = keyword.trim();

        Booking booking = null;
        User user = null;

        // Ưu tiên: nếu là số -> tra cứu theo BookingId
        try {
            int bookingId = Integer.parseInt(keyword);
            booking = bookingDAO.findById(bookingId);
        } catch (NumberFormatException ignored) {
            // không phải số -> thử tìm theo email
            Optional<User> userOpt = userDAO.findByEmail(keyword);
            if (userOpt.isPresent()) {
                user = userOpt.get();
                // đơn giản: lấy booking mới nhất của user
                List<Booking> userBookings = bookingDAO.findByUser(user.getUserId());
                if (!userBookings.isEmpty()) {
                    booking = userBookings.get(0);
                }
            }
        }

        if (booking == null) {
            req.setAttribute("error", "Không tìm thấy đơn đặt vé phù hợp.");
            req.getRequestDispatcher("/booking/ticket-checkin.jsp").forward(req, resp);
            return;
        }

        Showtime showtime = showtimeDAO.findById(booking.getShowtimeId());
        List<BookingSeat> seats = bookingSeatDAO.findByBookingWithSeat(booking.getBookingId());

        boolean isValid = false;
        String reason = "";
        LocalDateTime now = LocalDateTime.now();

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

        req.setAttribute("keyword", keyword);
        req.setAttribute("booking", booking);
        req.setAttribute("showtime", showtime);
        req.setAttribute("bookingSeats", seats);
        req.setAttribute("customer", user);
        req.setAttribute("isValid", isValid);
        req.setAttribute("reason", reason);

        req.getRequestDispatcher("/booking/ticket-checkin.jsp").forward(req, resp);
    }
}

