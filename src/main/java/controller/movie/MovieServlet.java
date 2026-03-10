package controller.movie;

import dao.MovieDAO;
import model.Movie;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

/**
 * UC-04 | View movie list
 * Displays movie list with search and filter functionality.
 */
@WebServlet(name = "MovieServlet", urlPatterns = {"/movies"})
public class MovieServlet extends HttpServlet {

    private final MovieDAO movieDAO = new MovieDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String query = req.getParameter("query");
        String genre = req.getParameter("genre");
        String language = req.getParameter("language");
        String ageRating = req.getParameter("ageRating");

        List<Movie> movies;
        if (query == null && genre == null && language == null && ageRating == null) {
            movies = movieDAO.findAll();
        } else {
            movies = movieDAO.search(query, genre, language, ageRating);
        }

        req.setAttribute("movies", movies);
        req.setAttribute("query", query);
        req.setAttribute("genre", genre);
        req.setAttribute("language", language);
        req.setAttribute("ageRating", ageRating);

        req.getRequestDispatcher("/movie/list.jsp").forward(req, resp);
    }
}
