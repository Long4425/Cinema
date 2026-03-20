package controller.booking;

import dao.BookingDAO;
import dao.BookingFoodItemDAO;
import dao.BookingSeatDAO;
import dao.ShowtimeDAO;
import model.Booking;
import model.BookingSeat;
import model.BookingFoodItem;
import model.Showtime;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "BookingSummaryServlet", urlPatterns = {"/booking/summary"})
public class BookingSummaryServlet extends HttpServlet {

    private final BookingDAO bookingDAO = new BookingDAO();
    private final BookingSeatDAO bookingSeatDAO = new BookingSeatDAO();
    private final BookingFoodItemDAO bookingFoodItemDAO = new BookingFoodItemDAO();
    private final ShowtimeDAO showtimeDAO = new ShowtimeDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String bookingIdStr = req.getParameter("bookingId");
        if (bookingIdStr == null || bookingIdStr.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/movies");
            return;
        }
        try {
            int bookingId = Integer.parseInt(bookingIdStr);
            Booking booking = bookingDAO.findById(bookingId);
            if (booking == null) {
                resp.sendRedirect(req.getContextPath() + "/movies");
                return;
            }
            Showtime showtime = showtimeDAO.findById(booking.getShowtimeId());
            List<BookingSeat> seats = bookingSeatDAO.findByBookingWithSeat(bookingId);
            List<BookingFoodItem> foodItems = bookingFoodItemDAO.findByBookingWithFood(bookingId);

            req.setAttribute("booking", booking);
            req.setAttribute("showtime", showtime);
            req.setAttribute("bookingSeats", seats);
            req.setAttribute("bookingFoodItems", foodItems);

            req.getRequestDispatcher("/booking/summary.jsp").forward(req, resp);
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/movies");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        doGet(req, resp);
    }
}

