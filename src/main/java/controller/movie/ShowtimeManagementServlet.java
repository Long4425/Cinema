package controller.movie;

import dao.MovieDAO;
import dao.RoomDAO;
import dao.ShowtimeDAO;
import model.Movie;
import model.Room;
import model.Showtime;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

/**
 * UC-08 | Manage showtimes
 * Create showtimes, avoid overlaps, set rooms.
 */
@WebServlet(name = "ShowtimeManagementServlet", urlPatterns = {"/manager/showtimes"})
public class ShowtimeManagementServlet extends HttpServlet {

    private final ShowtimeDAO showtimeDAO = new ShowtimeDAO();
    private final MovieDAO movieDAO = new MovieDAO();
    private final RoomDAO roomDAO = new RoomDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        if (action == null) action = "list";

        switch (action) {
            case "list":
                listShowtimes(req, resp);
                break;
            case "edit":
                showEditForm(req, resp);
                break;
            case "delete":
                deleteShowtime(req, resp);
                break;
            default:
                listShowtimes(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("create".equalsIgnoreCase(action)) {
            createShowtime(req, resp);
        } else if ("update".equalsIgnoreCase(action)) {
            updateShowtime(req, resp);
        }
    }

    private void listShowtimes(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String dateStr = req.getParameter("date");
        LocalDate date = null;
        if (dateStr != null && !dateStr.isEmpty()) {
            try {
                date = LocalDate.parse(dateStr);
            } catch (Exception ignored) {
                date = null;
            }
        }

        List<Showtime> showtimes = (date == null)
                ? showtimeDAO.findAllGroupByMovie()
                : showtimeDAO.findByDateGroupByMovie(date);
        req.setAttribute("showtimes", showtimes);
        req.setAttribute("date", date);
        req.getRequestDispatcher("/movie/manage-showtimes.jsp").forward(req, resp);
    }

    private void showEditForm(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String idStr = req.getParameter("id");
        if (idStr != null && !idStr.isBlank()) {
            int id = Integer.parseInt(idStr);
            Showtime s = showtimeDAO.findById(id);
            req.setAttribute("showtime", s);
        }
        req.setAttribute("movies", movieDAO.findAll());
        req.setAttribute("rooms", roomDAO.findAll());
        req.getRequestDispatcher("/movie/showtime-form.jsp").forward(req, resp);
    }

    private void createShowtime(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Showtime s = populateShowtime(req);
        try {
            showtimeDAO.create(s);
            resp.sendRedirect(req.getContextPath() + "/manager/showtimes");
        } catch (Exception e) {
            req.setAttribute("error", e.getMessage());
            showEditForm(req, resp);
        }
    }

    private void updateShowtime(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Showtime s = populateShowtime(req);
        s.setShowtimeId(Integer.parseInt(req.getParameter("id")));
        try {
            showtimeDAO.update(s);
            resp.sendRedirect(req.getContextPath() + "/manager/showtimes");
        } catch (Exception e) {
            req.setAttribute("error", e.getMessage());
            showEditForm(req, resp);
        }
    }

    private void deleteShowtime(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int id = Integer.parseInt(req.getParameter("id"));
        showtimeDAO.delete(id);
        resp.sendRedirect(req.getContextPath() + "/manager/showtimes");
    }

    private Showtime populateShowtime(HttpServletRequest req) {
        Showtime s = new Showtime();
        s.setMovieId(Integer.parseInt(req.getParameter("movieId")));
        s.setRoomId(Integer.parseInt(req.getParameter("roomId")));
        s.setStartTime(LocalDateTime.parse(req.getParameter("startTime")));
        s.setEndTime(LocalDateTime.parse(req.getParameter("endTime")));

        String priceStr = req.getParameter("basePrice");
        BigDecimal price = new BigDecimal(priceStr);
        if (price.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Giá cơ bản phải lớn hơn 0.");
        }
        s.setBasePrice(price);
        s.setStatus(req.getParameter("status"));
        return s;
    }
}
