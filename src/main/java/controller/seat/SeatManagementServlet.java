package controller.seat;

import dao.RoomDAO;
import dao.SeatDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Room;
import model.Seat;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "SeatManagementServlet", urlPatterns = {"/manager/seats"})
public class SeatManagementServlet extends HttpServlet {

    private final RoomDAO roomDAO = new RoomDAO();
    private final SeatDAO seatDAO = new SeatDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String roomIdStr = req.getParameter("roomId");
        int roomId = roomIdStr != null && !roomIdStr.isBlank() ? Integer.parseInt(roomIdStr) : 0;

        List<Room> rooms = roomDAO.findAllIncludingInactive();
        req.setAttribute("rooms", rooms);

        if (roomId > 0) {
            Room room = roomDAO.findById(roomId);
            req.setAttribute("room", room);
            req.setAttribute("seats", seatDAO.findByRoom(roomId));
        }

        req.getRequestDispatcher("/seat/manage-seats.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        if (action == null) action = "";

        switch (action) {
            case "generate":
                generate(req, resp);
                break;
            case "updateType":
                updateType(req, resp);
                break;
            default:
                resp.sendRedirect(req.getContextPath() + "/manager/seats");
        }
    }

    private void generate(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        try {
            int roomId = Integer.parseInt(req.getParameter("roomId"));
            int rows = Integer.parseInt(req.getParameter("rows"));
            int cols = Integer.parseInt(req.getParameter("cols"));
            int vipRows = Integer.parseInt(req.getParameter("vipRows"));

            if (rows <= 0 || cols <= 0) throw new IllegalArgumentException("Số hàng/cột phải lớn hơn 0.");
            if (rows > 26) throw new IllegalArgumentException("Tối đa 26 hàng (A-Z).");
            if (vipRows < 0 || vipRows > rows) throw new IllegalArgumentException("Số hàng VIP không hợp lệ.");

            Room room = roomDAO.findById(roomId);
            if (room == null) {
                throw new IllegalArgumentException("Phòng không tồn tại.");
            }
            int requestedSeats = rows * cols;
            if (requestedSeats > room.getTotalSeats()) {
                throw new IllegalArgumentException("Số ghế trong sơ đồ (" + requestedSeats +
                        ") vượt quá tổng ghế đã cấu hình cho phòng (" + room.getTotalSeats() + ").");
            }

            // Recreate full map
            seatDAO.deleteByRoom(roomId);

            List<Seat> batch = new ArrayList<>();
            for (int r = 1; r <= rows; r++) {
                String rowLabel = String.valueOf((char) ('A' + r - 1));
                String type = (r <= vipRows) ? "VIP" : "Standard";
                for (int c = 1; c <= cols; c++) {
                    Seat s = new Seat();
                    s.setRoomId(roomId);
                    s.setRowLabel(rowLabel);
                    s.setSeatNumber(c);
                    s.setSeatType(type);
                    batch.add(s);
                }
            }
            seatDAO.createBatch(batch);

            resp.sendRedirect(req.getContextPath() + "/manager/seats?roomId=" + roomId);
        } catch (Exception e) {
            req.setAttribute("error", e.getMessage());
            doGet(req, resp);
        }
    }

    private void updateType(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        try {
            int roomId = Integer.parseInt(req.getParameter("roomId"));
            String seatType = req.getParameter("seatType");
            if (!(seatType.equals("Standard") || seatType.equals("VIP") || seatType.equals("Couple"))) {
                throw new IllegalArgumentException("Loại ghế không hợp lệ.");
            }
            String seatIdsStr = req.getParameter("seatIds");
            if (seatIdsStr == null || seatIdsStr.isBlank()) {
                throw new IllegalArgumentException("Chưa chọn ghế nào.");
            }
            String[] parts = seatIdsStr.split(",");
            for (String p : parts) {
                if (p == null || p.isBlank()) continue;
                int seatId = Integer.parseInt(p.trim());
                seatDAO.updateSeatType(seatId, seatType);
            }
            resp.sendRedirect(req.getContextPath() + "/manager/seats?roomId=" + roomId);
        } catch (Exception e) {
            req.setAttribute("error", e.getMessage());
            doGet(req, resp);
        }
    }
}

