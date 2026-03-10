package controller.movie;

import dao.MovieDAO;
import jakarta.servlet.annotation.MultipartConfig;
import model.Movie;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.Part;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.util.List;

/**
 * UC-07 | Manage movies
 * Add/Edit/Delete movies, upload posters/trailers (logic for filenames), age rating.
 */
@WebServlet(name = "MovieManagementServlet", urlPatterns = {"/manager/movies"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,     // 1MB
        maxFileSize = 5 * 1024 * 1024,       // 5MB
        maxRequestSize = 10 * 1024 * 1024    // 10MB
)
public class MovieManagementServlet extends HttpServlet {

    private final MovieDAO movieDAO = new MovieDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        if (action == null) action = "list";

        switch (action) {
            case "list":
                listMovies(req, resp);
                break;
            case "edit":
                showEditForm(req, resp);
                break;
            case "delete":
                deleteMovie(req, resp);
                break;
            default:
                listMovies(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("create".equalsIgnoreCase(action)) {
            createMovie(req, resp);
        } else if ("update".equalsIgnoreCase(action)) {
            updateMovie(req, resp);
        }
    }

    private void listMovies(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        List<Movie> movies = movieDAO.findAll();
        req.setAttribute("movies", movies);
        req.getRequestDispatcher("/movie/manage-list.jsp").forward(req, resp);
    }

    private void showEditForm(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String idStr = req.getParameter("id");
        if (idStr != null) {
            int id = Integer.parseInt(idStr);
            Movie movie = movieDAO.findById(id);
            req.setAttribute("movie", movie);
        }
        req.getRequestDispatcher("/movie/movie-form.jsp").forward(req, resp);
    }

    private void createMovie(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Movie movie = populateMovie(req);
        HttpSession session = req.getSession(false);
        User user = (User) session.getAttribute("user");
        movie.setCreatedBy(user.getUserId());
        
        movieDAO.create(movie);
        resp.sendRedirect(req.getContextPath() + "/manager/movies");
    }

    private void updateMovie(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Movie movie = populateMovie(req);
        movie.setMovieId(Integer.parseInt(req.getParameter("id")));
        
        movieDAO.update(movie);
        resp.sendRedirect(req.getContextPath() + "/manager/movies");
    }

    private void deleteMovie(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int id = Integer.parseInt(req.getParameter("id"));
        movieDAO.delete(id);
        resp.sendRedirect(req.getContextPath() + "/manager/movies");
    }

    private Movie populateMovie(HttpServletRequest req) {
        Movie m = new Movie();
        m.setTitle(req.getParameter("title"));
        m.setTitleEN(req.getParameter("titleEN"));
        m.setDescription(req.getParameter("description"));
        m.setGenre(req.getParameter("genre"));
        m.setLanguage(req.getParameter("language"));
        m.setAgeRating(req.getParameter("ageRating"));
        m.setDurationMins(Integer.parseInt(req.getParameter("durationMins")));
        String existingPoster = req.getParameter("existingPosterUrl");
        String uploadedPoster = trySavePoster(req);
        m.setPosterUrl(uploadedPoster != null ? uploadedPoster : existingPoster);
        m.setTrailerUrl(req.getParameter("trailerUrl"));
        m.setStatus(req.getParameter("status"));
        return m;
    }

    private String trySavePoster(HttpServletRequest req) {
        try {
            Part posterPart = req.getPart("posterFile");
            if (posterPart == null || posterPart.getSize() == 0) return null;

            String submittedName = Paths.get(posterPart.getSubmittedFileName()).getFileName().toString();
            if (submittedName.isBlank()) return null;

            String ext = "";
            int dot = submittedName.lastIndexOf('.');
            if (dot >= 0) ext = submittedName.substring(dot).toLowerCase();
            if (!(ext.equals(".jpg") || ext.equals(".jpeg") || ext.equals(".png") || ext.equals(".webp"))) {
                return null;
            }

            String safeBase = submittedName.substring(0, dot >= 0 ? dot : submittedName.length())
                    .replaceAll("[^a-zA-Z0-9-_]", "_");
            String fileName = safeBase + "_" + System.currentTimeMillis() + ext;

            String imagesDirPath = req.getServletContext().getRealPath("/images");
            if (imagesDirPath == null) return null;

            File imagesDir = new File(imagesDirPath);
            if (!imagesDir.exists() && !imagesDir.mkdirs()) return null;

            File dest = new File(imagesDir, fileName);
            posterPart.write(dest.getAbsolutePath());
            return fileName;
        } catch (Exception ignored) {
            return null;
        }
    }
}
