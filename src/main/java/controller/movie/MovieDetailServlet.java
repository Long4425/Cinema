package controller.movie;

import dao.MovieDAO;
import dao.ShowtimeDAO;
import model.Movie;
import model.Showtime;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * UC-05 | View movie detail
 * View trailer, detailed description, ratings, and age rating.
 * Plus view showtimes for this movie.
 */
@WebServlet(name = "MovieDetailServlet", urlPatterns = {"/movie-detail"})
public class MovieDetailServlet extends HttpServlet {

    private final MovieDAO movieDAO = new MovieDAO();
    private final ShowtimeDAO showtimeDAO = new ShowtimeDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String movieIdStr = req.getParameter("id");
        if (movieIdStr == null || movieIdStr.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/movies");
            return;
        }

        try {
            int movieId = Integer.parseInt(movieIdStr);
            Movie movie = movieDAO.findById(movieId);
            if (movie == null) {
                resp.sendRedirect(req.getContextPath() + "/movies");
                return;
            }

            List<Showtime> showtimes = showtimeDAO.findUpcomingWeekByMovie(movieId);

            // Group theo ngày, giữ thứ tự
            Map<LocalDate, List<Showtime>> showtimesByDate = new LinkedHashMap<>();
            for (Showtime s : showtimes) {
                LocalDate date = s.getStartTime().toLocalDate();
                showtimesByDate.computeIfAbsent(date, k -> new ArrayList<>()).add(s);
            }

            req.setAttribute("movie", movie);
            req.setAttribute("showtimesByDate", showtimesByDate);
            req.getRequestDispatcher("/movie/detail.jsp").forward(req, resp);
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/movies");
        }
    }
}
