package controller.booking;

import dao.BookingDAO;
import dao.BookingSeatDAO;
import dao.SeatDAO;
import dao.ShowtimeDAO;
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
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * GET  /booking/exchange-seats?bookingId=X&newShowtimeId=Y  — trang chọn ghế cho suất mới
 * POST /booking/exchange-seats                               — xác nhận ghế, lưu vào session rồi chuyển sang exchange-checkout
 */
@WebServlet(name = "ExchangeSeatSelectionServlet", urlPatterns = {"/booking/exchange-seats"})
public class ExchangeSeatSelectionServlet extends HttpServlet {

    private final BookingDAO bookingDAO = new BookingDAO();
    private final BookingSeatDAO bookingSeatDAO = new BookingSeatDAO();
    private final SeatDAO seatDAO = new SeatDAO();
    private final ShowtimeDAO showtimeDAO = new ShowtimeDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        User user = (User) session.getAttribute("user");

        String bookingIdStr     = req.getParameter("bookingId");
        String newShowtimeIdStr = req.getParameter("newShowtimeId");
        if (bookingIdStr == null || newShowtimeIdStr == null) {
            resp.sendRedirect(req.getContextPath() + "/profile/bookings");
            return;
        }

        try {
            int bookingId     = Integer.parseInt(bookingIdStr);
            int newShowtimeId = Integer.parseInt(newShowtimeIdStr);

            Booking booking = bookingDAO.findById(bookingId);
            if (booking == null || !canExchange(booking, user)) {
                resp.sendRedirect(req.getContextPath() + "/profile/bookings");
                return;
            }
            if (!"Confirmed".equalsIgnoreCase(booking.getStatus())) {
                resp.sendRedirect(req.getContextPath() + "/profile/bookings");
                return;
            }

            Showtime newShowtime = showtimeDAO.findById(newShowtimeId);
            if (newShowtime == null || !newShowtime.getStartTime().isAfter(LocalDateTime.now().plusMinutes(30))) {
                session.setAttribute("error", "Suất chiếu không hợp lệ.");
                resp.sendRedirect(req.getContextPath() + "/booking/exchange?bookingId=" + bookingId);
                return;
            }

            // Ghế của phòng suất mới
            List<Seat> seats = seatDAO.findByRoom(newShowtime.getRoomId());

            // Ghế đã bị chiếm ở suất mới (trừ ghế của booking hiện tại nếu cùng phòng)
            List<BookingSeat> activeSeats = bookingSeatDAO.findActiveByShowtime(newShowtimeId);
            Set<Integer> takenSeatIds = new HashSet<>();
            for (BookingSeat bs : activeSeats) {
                takenSeatIds.add(bs.getSeatId());
            }

            // Ghế hiện tại của booking để pre-select (gợi ý)
            List<BookingSeat> currentSeats = bookingSeatDAO.findByBookingWithSeat(bookingId);
            Set<Integer> currentSeatIds = new HashSet<>();
            for (BookingSeat bs : currentSeats) {
                currentSeatIds.add(bs.getSeatId());
                // Nếu suất mới cùng phòng với suất cũ, ghế cũ của booking này không bị coi là "taken"
                takenSeatIds.remove(bs.getSeatId());
            }

            req.setAttribute("booking", booking);
            req.setAttribute("newShowtime", newShowtime);
            req.setAttribute("seats", seats);
            req.setAttribute("takenSeatIds", takenSeatIds);
            req.setAttribute("currentSeatIds", currentSeatIds);
            req.setAttribute("seatCount", currentSeats.size());
            req.getRequestDispatcher("/booking/exchange-seat-selection.jsp").forward(req, resp);

        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/profile/bookings");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        User user = (User) session.getAttribute("user");

        String bookingIdStr     = req.getParameter("bookingId");
        String newShowtimeIdStr = req.getParameter("newShowtimeId");
        String seatIdsRaw       = req.getParameter("seatIds");

        if (bookingIdStr == null || newShowtimeIdStr == null || seatIdsRaw == null || seatIdsRaw.isBlank()) {
            req.setAttribute("error", "Vui lòng chọn ghế.");
            doGet(req, resp);
            return;
        }

        try {
            int bookingId     = Integer.parseInt(bookingIdStr);
            int newShowtimeId = Integer.parseInt(newShowtimeIdStr);

            Booking booking = bookingDAO.findById(bookingId);
            if (booking == null || !canExchange(booking, user)) {
                resp.sendRedirect(req.getContextPath() + "/profile/bookings");
                return;
            }

            Showtime newShowtime = showtimeDAO.findById(newShowtimeId);
            if (newShowtime == null || !newShowtime.getStartTime().isAfter(LocalDateTime.now().plusMinutes(30))) {
                session.setAttribute("error", "Suất chiếu không còn hợp lệ.");
                resp.sendRedirect(req.getContextPath() + "/booking/exchange?bookingId=" + bookingId);
                return;
            }

            // Parse seat IDs
            String[] parts = seatIdsRaw.split(",");
            Set<Integer> chosenSeatIds = new HashSet<>();
            for (String p : parts) {
                try { chosenSeatIds.add(Integer.parseInt(p.trim())); } catch (NumberFormatException ignore) {}
            }

            // Phải chọn đúng số ghế ban đầu
            List<BookingSeat> currentSeats = bookingSeatDAO.findByBookingWithSeat(bookingId);
            if (chosenSeatIds.isEmpty()) {
                req.setAttribute("error", "Vui lòng chọn ít nhất 1 ghế.");
                doGet(req, resp);
                return;
            }

            // Kiểm tra ghế không bị chiếm (loại trừ ghế cũ của booking)
            List<BookingSeat> activeSeats = bookingSeatDAO.findActiveByShowtime(newShowtimeId);
            Set<Integer> takenSeatIds = new HashSet<>();
            for (BookingSeat bs : activeSeats) {
                takenSeatIds.add(bs.getSeatId());
            }
            for (BookingSeat bs : currentSeats) {
                takenSeatIds.remove(bs.getSeatId());
            }
            for (int seatId : chosenSeatIds) {
                if (takenSeatIds.contains(seatId)) {
                    req.setAttribute("error", "Một số ghế đã được đặt bởi người khác, vui lòng chọn lại.");
                    doGet(req, resp);
                    return;
                }
            }

            // Lưu vào session để dùng ở bước checkout
            session.setAttribute("exchangeBookingId",     bookingId);
            session.setAttribute("exchangeNewShowtimeId", newShowtimeId);
            session.setAttribute("exchangeSeatIds",       chosenSeatIds);

            resp.sendRedirect(req.getContextPath() + "/booking/exchange-checkout");

        } catch (NumberFormatException | DataAccessException e) {
            req.setAttribute("error", "Lỗi: " + e.getMessage());
            doGet(req, resp);
        }
    }

    private boolean canExchange(Booking booking, User user) {
        boolean isOwner = booking.getUserId() != null && booking.getUserId().equals(user.getUserId());
        boolean isStaff = user.getRole() != null && !"CUSTOMER".equalsIgnoreCase(user.getRole().getRoleCode());
        return isOwner || isStaff;
    }
}
