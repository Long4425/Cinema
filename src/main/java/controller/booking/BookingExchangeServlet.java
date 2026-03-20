package controller.booking;

import dao.BookingDAO;
import dao.ShowtimeDAO;
import model.Booking;
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

@WebServlet(name = "BookingExchangeServlet", urlPatterns = {"/booking/exchange"})
public class BookingExchangeServlet extends HttpServlet {

    private final BookingDAO bookingDAO = new BookingDAO();
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
            if (showtime == null) {
                resp.sendRedirect(req.getContextPath() + "/profile/bookings");
                return;
            }

            // Đơn giản: hướng người dùng tới trang /showtimes filter theo phim để đặt lại,
            // phần phụ thu chênh lệch giá xử lý thủ công bởi nhân viên.
            String redirectUrl = req.getContextPath() + "/showtimes?movieId=" + showtime.getMovieId();
            resp.sendRedirect(redirectUrl);
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/profile/bookings");
        }
    }
}

