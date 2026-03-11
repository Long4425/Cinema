package controller.booking;

import dao.BookingDAO;
import dao.BookingSeatDAO;
import dao.PaymentDAO;
import dao.ShowtimeDAO;
import model.Booking;
import model.BookingSeat;
import model.Payment;
import model.Showtime;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@WebServlet(name = "CashPaymentServlet", urlPatterns = {"/manager/booking/cash-payment"})
public class CashPaymentServlet extends HttpServlet {

    private final BookingDAO bookingDAO = new BookingDAO();
    private final BookingSeatDAO bookingSeatDAO = new BookingSeatDAO();
    private final PaymentDAO paymentDAO = new PaymentDAO();
    private final ShowtimeDAO showtimeDAO = new ShowtimeDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String bookingIdStr = req.getParameter("bookingId");
        if (bookingIdStr == null || bookingIdStr.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }
        try {
            int bookingId = Integer.parseInt(bookingIdStr);
            Booking booking = bookingDAO.findById(bookingId);
            if (booking == null) {
                resp.sendRedirect(req.getContextPath() + "/dashboard");
                return;
            }
            Showtime showtime = showtimeDAO.findById(booking.getShowtimeId());
            List<BookingSeat> seats = bookingSeatDAO.findByBookingWithSeat(bookingId);

            req.setAttribute("booking", booking);
            req.setAttribute("showtime", showtime);
            req.setAttribute("bookingSeats", seats);

            req.getRequestDispatcher("/booking/cash-payment.jsp").forward(req, resp);
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String bookingIdStr = req.getParameter("bookingId");
        if (bookingIdStr == null || bookingIdStr.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }
        try {
            int bookingId = Integer.parseInt(bookingIdStr);
            Booking booking = bookingDAO.findById(bookingId);
            if (booking == null) {
                resp.sendRedirect(req.getContextPath() + "/dashboard");
                return;
            }

            // Tạo payment kiểu tiền mặt
            Payment payment = new Payment();
            payment.setBookingId(bookingId);
            payment.setPaymentMethod("Cash");
            payment.setAmount(booking.getTotalAmount() != null ? booking.getTotalAmount() : BigDecimal.ZERO);
            payment.setStatus("Success");
            payment.setPaidAt(LocalDateTime.now());
            paymentDAO.create(payment);

            // Cập nhật trạng thái booking + ghế
            bookingDAO.updateStatus(bookingId, "Confirmed");
            bookingSeatDAO.updateStatusByBooking(bookingId, "Confirmed");

            resp.sendRedirect(req.getContextPath() + "/booking/summary?bookingId=" + bookingId);
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
        }
    }
}

