package controller.booking;

import dao.BookingDAO;
import dao.BookingSeatDAO;
import dao.SeatDAO;
import dao.ShowtimeDAO;
import exception.DataAccessException;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.Booking;
import model.BookingSeat;
import model.Seat;
import model.Showtime;
import model.User;

@WebServlet(name = "SeatSelectionServlet", urlPatterns = {"/booking/seat-selection"})
public class SeatSelectionServlet extends HttpServlet {

    private final ShowtimeDAO showtimeDAO = new ShowtimeDAO();
    private final SeatDAO seatDAO = new SeatDAO();
    private final BookingDAO bookingDAO = new BookingDAO();
    private final BookingSeatDAO bookingSeatDAO = new BookingSeatDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
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
            for (BookingSeat bs : activeSeats) {
                takenSeatIds.add(bs.getSeatId());
            }
            req.setAttribute("showtime", showtime);
            req.setAttribute("seats", seats);
            req.setAttribute("takenSeatIds", takenSeatIds);
            req.getRequestDispatcher("/booking/seat-selection.jsp").forward(req, resp);
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/showtimes");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String showtimeIdStr = req.getParameter("showtimeId");
        String[] seatIdParams = req.getParameterValues("seatIds");
        if (showtimeIdStr == null || showtimeIdStr.isBlank() || seatIdParams == null || seatIdParams.length == 0) {
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

            // Tạm thời tính giá ghế = BasePrice của suất chiếu, sau này có thể nhân hệ số theo loại ghế
            BigDecimal basePrice = showtime.getBasePrice();
            List<Integer> seatIds = new ArrayList<>();
            for (String s : seatIdParams) {
                try {
                    seatIds.add(Integer.parseInt(s));
                } catch (NumberFormatException ignore) {
                }
            }
            if (seatIds.isEmpty()) {
                req.setAttribute("error", "Vui lòng chọn ít nhất 1 ghế hợp lệ.");
                doGet(req, resp);
                return;
            }

            // Kiểm tra lại ghế còn trống (đề phòng cạnh tranh)
            List<BookingSeat> activeSeats = bookingSeatDAO.findActiveByShowtime(showtimeId);
            Set<Integer> takenSeatIds = new HashSet<>();
            for (BookingSeat bs : activeSeats) {
                takenSeatIds.add(bs.getSeatId());
            }
            for (Integer id : seatIds) {
                if (takenSeatIds.contains(id)) {
                    req.setAttribute("error", "Một số ghế bạn chọn đã được giữ/đặt bởi người khác, vui lòng chọn lại.");
                    doGet(req, resp);
                    return;
                }
            }

            // Tạo booking ở trạng thái Pending, loại ONLINE
            HttpSession session = req.getSession(false);
            Integer userId = null;
            if (session != null) {
                User user = (User) session.getAttribute("user");
                if (user != null) {
                    userId = user.getUserId();
                }
            }

            Booking booking = new Booking();
            booking.setUserId(userId);
            booking.setShowtimeId(showtimeId);
            booking.setBookingType("ONLINE");
            booking.setStatus("Pending");
            BigDecimal subTotal = basePrice.multiply(BigDecimal.valueOf(seatIds.size()));
            booking.setSubTotal(subTotal);
            booking.setDiscountAmount(BigDecimal.ZERO);
            booking.setTotalAmount(subTotal);
            booking.setCreatedAt(LocalDateTime.now());

            int bookingId = bookingDAO.create(booking);

            // Giữ ghế trong một khoảng thời gian (ví dụ 15 phút)
            LocalDateTime heldUntil = LocalDateTime.now().plusMinutes(15);
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

            // Lưu bookingId vào session để dùng cho bước checkout / thanh toán
            if (session == null) {
                session = req.getSession(true);
            }
            session.setAttribute("currentBookingId", bookingId);

            resp.sendRedirect(req.getContextPath() + "/booking/checkout");
        } catch (NumberFormatException e) {
            req.setAttribute("error", "Dữ liệu không hợp lệ.");
            doGet(req, resp);
        } catch (DataAccessException e) {
            req.setAttribute("error", e.getMessage());
            doGet(req, resp);
        }
    }
}

