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
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Booking;
import model.BookingSeat;
import model.Seat;
import model.Showtime;
import model.User;
import util.PricingUtil;

@WebServlet(name = "SeatSelectionServlet", urlPatterns = {"/booking/seat-selection"})
public class SeatSelectionServlet extends HttpServlet {

    private final ShowtimeDAO showtimeDAO = new ShowtimeDAO();
    private final SeatDAO seatDAO = new SeatDAO();
    private final BookingDAO bookingDAO = new BookingDAO();
    private final BookingSeatDAO bookingSeatDAO = new BookingSeatDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Hủy booking Pending cũ (nếu user back về mà chưa thanh toán)
        HttpSession session = req.getSession(false);
        if (session != null) {
            Integer pendingBookingId = (Integer) session.getAttribute("currentBookingId");
            if (pendingBookingId != null) {
                try {
                    bookingSeatDAO.cancelHeldByBooking(pendingBookingId);
                    bookingDAO.updateStatus(pendingBookingId, "Cancelled");
                } catch (Exception ignored) {
                }
                session.removeAttribute("currentBookingId");
            }
        }

        String showtimeIdStr = req.getParameter("showtimeId");
        if (showtimeIdStr == null || showtimeIdStr.isBlank()) {
            showtimeIdStr = req.getParameter("id");
        }
        if (showtimeIdStr == null || showtimeIdStr.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/movies");
            return;
        }
        try {
            int showtimeId = Integer.parseInt(showtimeIdStr);
            Showtime showtime = showtimeDAO.findById(showtimeId);
            if (showtime == null) {
                resp.sendRedirect(req.getContextPath() + "/movies");
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
            resp.sendRedirect(req.getContextPath() + "/movies");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login?msg="
                    + java.net.URLEncoder.encode("Xin hãy đăng nhập để tiếp tục đặt vé xem phim.", "UTF-8"));
            return;
        }

        String showtimeIdStr = req.getParameter("showtimeId");
        if (showtimeIdStr == null || showtimeIdStr.isBlank()) {
            showtimeIdStr = req.getParameter("id");
        }
        // seatIds từ JS là 1 string comma-separated: "1,2,3"
        String seatIdsRaw = req.getParameter("seatIds");
        if (showtimeIdStr == null || showtimeIdStr.isBlank() || seatIdsRaw == null || seatIdsRaw.isBlank()) {
            req.setAttribute("error", "Vui lòng chọn ít nhất 1 ghế.");
            doGet(req, resp);
            return;
        }
        String[] seatIdParams = seatIdsRaw.split(",");
        try {
            int showtimeId = Integer.parseInt(showtimeIdStr);
            Showtime showtime = showtimeDAO.findById(showtimeId);
            if (showtime == null) {
                resp.sendRedirect(req.getContextPath() + "/movies");
                return;
            }

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

            // Lấy thông tin ghế để tính giá theo SeatType và ngày cuối tuần
            List<Seat> seatList = seatDAO.findByIds(seatIds);
            Map<Integer, Seat> seatMap = new HashMap<>();
            for (Seat seat : seatList) {
                seatMap.put(seat.getSeatId(), seat);
            }

            // Tạo booking ở trạng thái Pending, loại ONLINE
            User user = (User) session.getAttribute("user");
            int userId = user.getUserId();

            // Tính subTotal theo giá từng ghế (SeatType + cuối tuần)
            BigDecimal subTotal = BigDecimal.ZERO;
            for (Integer seatId : seatIds) {
                Seat seat = seatMap.get(seatId);
                String seatType = (seat != null) ? seat.getSeatType() : "Standard";
                subTotal = subTotal.add(PricingUtil.calcSeatPrice(basePrice, seatType, showtime.getStartTime()));
            }

            Booking booking = new Booking();
            booking.setUserId(userId);
            booking.setShowtimeId(showtimeId);
            booking.setBookingType("ONLINE");
            booking.setStatus("Pending");
            booking.setSubTotal(subTotal);
            booking.setDiscountAmount(BigDecimal.ZERO);
            booking.setTotalAmount(subTotal);
            booking.setCreatedAt(LocalDateTime.now());

            int bookingId = bookingDAO.create(booking);

            // Giữ ghế trong một khoảng thời gian (ví dụ 15 phút)
            LocalDateTime heldUntil = LocalDateTime.now().plusMinutes(15);
            List<BookingSeat> bookingSeats = new ArrayList<>();
            for (Integer seatId : seatIds) {
                Seat seat = seatMap.get(seatId);
                String seatType = (seat != null) ? seat.getSeatType() : "Standard";
                BigDecimal seatPrice = PricingUtil.calcSeatPrice(basePrice, seatType, showtime.getStartTime());
                BookingSeat bs = new BookingSeat();
                bs.setBookingId(bookingId);
                bs.setSeatId(seatId);
                bs.setShowtimeId(showtimeId);
                bs.setSeatPrice(seatPrice);
                bs.setStatus("Held");
                bs.setHeldUntil(heldUntil);
                bookingSeats.add(bs);
            }
            bookingSeatDAO.createBatch(bookingSeats);

            // Lưu bookingId vào session để dùng cho bước checkout / thanh toán
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

