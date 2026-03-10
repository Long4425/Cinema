package controller.movie;

import dao.MovieDAO;
import dao.ShowtimeDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Movie;
import model.Showtime;

import java.io.IOException;
import java.util.List;

/**
 * Manager view for movie detail.
 * Reuses the same data as MovieDetailServlet but exposed under /manager/movie-detail.
 */
@WebServlet(name = "ManagerMovieDetailServlet", urlPatterns = {"/manager/movie-detail"})
public class ManagerMovieDetailServlet extends HttpServlet {

    private final MovieDAO movieDAO = new MovieDAO();
    private final ShowtimeDAO showtimeDAO = new ShowtimeDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String movieIdStr = req.getParameter("id");
        if (movieIdStr == null || movieIdStr.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/manager/movies");
            return;
        }

        try {
            int movieId = Integer.parseInt(movieIdStr);
            Movie movie = movieDAO.findById(movieId);
            if (movie == null) {
                resp.sendRedirect(req.getContextPath() + "/manager/movies");
                return;
            }

            List<Showtime> showtimes = showtimeDAO.findByMovie(movieId);

            req.setAttribute("movie", movie);
            req.setAttribute("showtimes", showtimes);
            req.getRequestDispatcher("/movie/manager-detail.jsp").forward(req, resp);
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/manager/movies");
        }
    }
}

