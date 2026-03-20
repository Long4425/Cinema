package controller.booking;

import dao.BookingDAO;
import dao.BookingSeatDAO;
import dao.ShowtimeDAO;
import model.Booking;
import model.BookingSeat;
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
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "CustomerBookingHistoryServlet", urlPatterns = {"/profile/bookings"})
public class CustomerBookingHistoryServlet extends HttpServlet {

    private final BookingDAO bookingDAO = new BookingDAO();
    private final ShowtimeDAO showtimeDAO = new ShowtimeDAO();
    private final BookingSeatDAO bookingSeatDAO = new BookingSeatDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        User user = (User) session.getAttribute("user");

        List<Booking> bookings = bookingDAO.findByUser(user.getUserId());
        Map<Integer, Showtime> showtimeMap = new HashMap<>();
        Map<Integer, List<BookingSeat>> seatsMap = new HashMap<>();
        Map<Integer, Boolean> cancellableMap = new HashMap<>();

        LocalDateTime now = LocalDateTime.now();

        for (Booking b : bookings) {
            Showtime s = showtimeMap.computeIfAbsent(b.getShowtimeId(), showtimeDAO::findById);
            seatsMap.put(b.getBookingId(), bookingSeatDAO.findByBookingWithSeat(b.getBookingId()));

            boolean futureShow = s != null && s.getStartTime() != null && s.getStartTime().isAfter(now);
            boolean statusAllow = "Confirmed".equalsIgnoreCase(b.getStatus()) || "Pending".equalsIgnoreCase(b.getStatus());
            cancellableMap.put(b.getBookingId(), futureShow && statusAllow);
        }

        req.setAttribute("bookings", bookings);
        req.setAttribute("showtimeMap", showtimeMap);
        req.setAttribute("seatsMap", seatsMap);
        req.setAttribute("cancellableMap", cancellableMap);

        req.getRequestDispatcher("/profile/booking-history.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        doGet(req, resp);
    }
}

