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
import java.util.List;

/**
 * UC-06 | View showtimes
 * Filter showtimes by date.
 */
@WebServlet(name = "ShowtimeServlet", urlPatterns = {"/showtimes"})
public class ShowtimeServlet extends HttpServlet {

    private final ShowtimeDAO showtimeDAO = new ShowtimeDAO();
    private final MovieDAO movieDAO = new MovieDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String dateStr = req.getParameter("date");
        String movieIdStr = req.getParameter("movieId");
        LocalDate date;
        if (dateStr == null || dateStr.isEmpty()) {
            date = LocalDate.now();
        } else {
            try {
                date = LocalDate.parse(dateStr);
            } catch (Exception e) {
                date = LocalDate.now();
            }
        }

        Integer movieId = null;
        if (movieIdStr != null && !movieIdStr.isEmpty()) {
            try {
                movieId = Integer.parseInt(movieIdStr);
            } catch (Exception ignored) {
                movieId = null;
            }
        }

        List<Showtime> showtimes = (movieId == null)
                ? showtimeDAO.findByDate(date)
                : showtimeDAO.findByDateAndMovie(date, movieId);
        List<Movie> movies = movieDAO.findAll();

        req.setAttribute("showtimes", showtimes);
        req.setAttribute("date", date);
        req.setAttribute("movies", movies);
        req.setAttribute("movieId", movieId);
        req.getRequestDispatcher("/movie/showtimes.jsp").forward(req, resp);
    }
}
