package controller.room;

import dao.RoomDAO;
import dao.SeatDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Room;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "RoomManagementServlet", urlPatterns = {"/manager/rooms"})
public class RoomManagementServlet extends HttpServlet {

    private final RoomDAO roomDAO = new RoomDAO();
    private final SeatDAO seatDAO = new SeatDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        if (action == null) action = "list";

        switch (action) {
            case "list":
                listRooms(req, resp);
                break;
            case "edit":
                showEditForm(req, resp);
                break;
            case "delete":
                deleteRoom(req, resp);
                break;
            default:
                listRooms(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("create".equalsIgnoreCase(action)) {
            createRoom(req, resp);
        } else if ("update".equalsIgnoreCase(action)) {
            updateRoom(req, resp);
        } else {
            resp.sendRedirect(req.getContextPath() + "/manager/rooms");
        }
    }

    private void listRooms(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        List<Room> rooms = roomDAO.findAllIncludingInactive();
        req.setAttribute("rooms", rooms);
        req.getRequestDispatcher("/room/manage-rooms.jsp").forward(req, resp);
    }

    private void showEditForm(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String idStr = req.getParameter("id");
        if (idStr != null && !idStr.isBlank()) {
            int id = Integer.parseInt(idStr);
            Room room = roomDAO.findById(id);
            req.setAttribute("room", room);
            if (room != null) {
                req.setAttribute("seatCount", seatDAO.countByRoom(room.getRoomId()));
            }
        }
        req.getRequestDispatcher("/room/room-form.jsp").forward(req, resp);
    }

    private void createRoom(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            Room room = populateRoom(req);
            room.setActive(true);
            roomDAO.create(room);
            resp.sendRedirect(req.getContextPath() + "/manager/rooms");
        } catch (Exception e) {
            req.setAttribute("error", e.getMessage());
            showEditForm(req, resp);
        }
    }

    private void updateRoom(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            Room room = populateRoom(req);
            room.setRoomId(Integer.parseInt(req.getParameter("id")));
            roomDAO.update(room);
            resp.sendRedirect(req.getContextPath() + "/manager/rooms");
        } catch (Exception e) {
            req.setAttribute("error", e.getMessage());
            showEditForm(req, resp);
        }
    }

    private void deleteRoom(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String idStr = req.getParameter("id");
        if (idStr != null && !idStr.isBlank()) {
            int id = Integer.parseInt(idStr);
            roomDAO.deactivate(id);
        }
        resp.sendRedirect(req.getContextPath() + "/manager/rooms");
    }

    private Room populateRoom(HttpServletRequest req) {
        String name = req.getParameter("roomName");
        String type = req.getParameter("roomType");
        int totalSeats = Integer.parseInt(req.getParameter("totalSeats"));
        boolean isActive = "1".equals(req.getParameter("isActive")) || "on".equalsIgnoreCase(req.getParameter("isActive"));

        if (name == null || name.isBlank()) throw new IllegalArgumentException("Tên phòng không được để trống.");
        if (totalSeats <= 0) throw new IllegalArgumentException("Tổng số ghế phải lớn hơn 0.");
        if (!(type.equals("2D") || type.equals("3D") || type.equals("IMAX"))) {
            throw new IllegalArgumentException("Loại phòng không hợp lệ.");
        }

        Room r = new Room();
        r.setRoomName(name.trim());
        r.setRoomType(type);
        r.setTotalSeats(totalSeats);
        r.setActive(isActive);
        return r;
    }
}

