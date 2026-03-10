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
import java.util.List;

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

            List<Showtime> showtimes = showtimeDAO.findByMovie(movieId);

            req.setAttribute("movie", movie);
            req.setAttribute("showtimes", showtimes);
            req.getRequestDispatcher("/movie/detail.jsp").forward(req, resp);
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/movies");
        }
    }
}
