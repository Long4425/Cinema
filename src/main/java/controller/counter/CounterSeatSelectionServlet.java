package controller.counter;

import dao.BookingDAO;
import dao.BookingSeatDAO;
import dao.SeatDAO;
import dao.ShowtimeDAO;
import dao.UserDAO;
import exception.DataAccessException;
import model.Booking;
import model.BookingSeat;
import model.Seat;
import model.Showtime;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;

/**
 * Thu ngân đặt vé tại quầy cho khách.
 * GET  /counter/seat-selection?showtimeId=X              – hiển thị sơ đồ ghế + form tìm khách
 * GET  /counter/seat-selection?showtimeId=X&search=email – tìm kiếm khách theo email / phone
 * POST /counter/seat-selection                           – xác nhận chọn ghế, tạo booking COUNTER, chuyển sang checkout
 */
@WebServlet(name = "CounterSeatSelectionServlet", urlPatterns = {"/counter/seat-selection"})
public class CounterSeatSelectionServlet extends HttpServlet {

    private final ShowtimeDAO showtimeDAO = new ShowtimeDAO();
    private final SeatDAO seatDAO = new SeatDAO();
    private final BookingDAO bookingDAO = new BookingDAO();
    private final BookingSeatDAO bookingSeatDAO = new BookingSeatDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        // Huỷ booking COUNTER pending cũ nếu thu ngân quay lại
        if (session != null) {
            Integer pendingId = (Integer) session.getAttribute("counterBookingId");
            if (pendingId != null) {
                try {
                    bookingSeatDAO.cancelHeldByBooking(pendingId);
                    bookingDAO.updateStatus(pendingId, "Cancelled");
                } catch (Exception ignored) {}
                session.removeAttribute("counterBookingId");
            }
        }

        String showtimeIdStr = req.getParameter("showtimeId");
        if (showtimeIdStr == null || showtimeIdStr.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/showtimes");
            return;
        }
        try {
            int showtimeId = Integer.parseInt(showtimeIdStr);
            Showtime showtime = showtimeDAO.findById(showtimeId);
            if (showtime == null) {
                resp.sendRedirect(req.getContextPath() + "/showtimes");
                return;
            }
            List<Seat> seats = seatDAO.findByRoom(showtime.getRoomId());
            List<BookingSeat> activeSeats = bookingSeatDAO.findActiveByShowtime(showtimeId);
            Set<Integer> takenSeatIds = new HashSet<>();
            for (BookingSeat bs : activeSeats) takenSeatIds.add(bs.getSeatId());

            // Tìm kiếm khách theo email / phone (optional)
            String search = req.getParameter("search");
            if (search != null && !search.isBlank()) {
                Optional<User> found = userDAO.findByEmail(search.trim());
                if (found.isPresent()) {
                    req.setAttribute("foundCustomer", found.get());
                } else {
                    req.setAttribute("searchMsg", "Không tìm thấy khách hàng với email/SĐT đã nhập.");
                }
                req.setAttribute("search", search);
            }

            req.setAttribute("showtime", showtime);
            req.setAttribute("seats", seats);
            req.setAttribute("takenSeatIds", takenSeatIds);
            req.getRequestDispatcher("/booking/counter-seat-selection.jsp").forward(req, resp);
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/showtimes");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        User staff = (User) session.getAttribute("user");

        String showtimeIdStr = req.getParameter("showtimeId");
        String seatIdsRaw = req.getParameter("seatIds");
        String customerIdStr = req.getParameter("customerId");

        if (showtimeIdStr == null || showtimeIdStr.isBlank() || seatIdsRaw == null || seatIdsRaw.isBlank()) {
            req.setAttribute("error", "Vui lòng chọn ít nhất 1 ghế.");
            doGet(req, resp);
            return;
        }

        try {
            int showtimeId = Integer.parseInt(showtimeIdStr);
            Showtime showtime = showtimeDAO.findById(showtimeId);
            if (showtime == null) {
                resp.sendRedirect(req.getContextPath() + "/showtimes");
                return;
            }

            List<Integer> seatIds = new ArrayList<>();
            for (String s : seatIdsRaw.split(",")) {
                try { seatIds.add(Integer.parseInt(s.trim())); } catch (NumberFormatException ignore) {}
            }
            if (seatIds.isEmpty()) {
                req.setAttribute("error", "Vui lòng chọn ít nhất 1 ghế hợp lệ.");
                doGet(req, resp);
                return;
            }

            // Kiểm tra ghế còn trống
            List<BookingSeat> activeSeats = bookingSeatDAO.findActiveByShowtime(showtimeId);
            Set<Integer> takenSeatIds = new HashSet<>();
            for (BookingSeat bs : activeSeats) takenSeatIds.add(bs.getSeatId());
            for (Integer id : seatIds) {
                if (takenSeatIds.contains(id)) {
                    req.setAttribute("error", "Một số ghế đã được đặt, vui lòng chọn lại.");
                    doGet(req, resp);
                    return;
                }
            }

            // Khách hàng (tuỳ chọn – có thể null nếu khách vãng lai)
            Integer customerId = null;
            if (customerIdStr != null && !customerIdStr.isBlank()) {
                try { customerId = Integer.parseInt(customerIdStr); } catch (NumberFormatException ignore) {}
            }

            BigDecimal basePrice = showtime.getBasePrice();
            BigDecimal subTotal = basePrice.multiply(BigDecimal.valueOf(seatIds.size()));

            Booking booking = new Booking();
            booking.setUserId(customerId);
            booking.setShowtimeId(showtimeId);
            booking.setBookingType("COUNTER");
            booking.setStatus("Pending");
            booking.setSubTotal(subTotal);
            booking.setDiscountAmount(BigDecimal.ZERO);
            booking.setTotalAmount(subTotal);
            booking.setCreatedBy(staff.getUserId());
            booking.setCreatedAt(LocalDateTime.now());

            int bookingId = bookingDAO.create(booking);

            LocalDateTime heldUntil = LocalDateTime.now().plusMinutes(30);
            List<BookingSeat> bookingSeats = new ArrayList<>();
            for (Integer seatId : seatIds) {
                BookingSeat bs = new BookingSeat();
                bs.setBookingId(bookingId);
                bs.setSeatId(seatId);
                bs.setShowtimeId(showtimeId);
                bs.setSeatPrice(basePrice);
                bs.setStatus("Held");
                bs.setHeldUntil(heldUntil);
                bookingSeats.add(bs);
            }
            bookingSeatDAO.createBatch(bookingSeats);

            session.setAttribute("counterBookingId", bookingId);
            resp.sendRedirect(req.getContextPath() + "/counter/checkout");
        } catch (NumberFormatException e) {
            req.setAttribute("error", "Dữ liệu không hợp lệ.");
            doGet(req, resp);
        } catch (DataAccessException e) {
            req.setAttribute("error", e.getMessage());
            doGet(req, resp);
        }
    }
}
