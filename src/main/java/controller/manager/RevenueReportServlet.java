package controller.manager;

import dao.MovieDAO;
import dao.ReportDAO;
import model.Movie;
import model.RevenueRow;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

@WebServlet(name = "RevenueReportServlet", urlPatterns = {"/manager/reports"})
public class RevenueReportServlet extends HttpServlet {

    private final ReportDAO reportDAO = new ReportDAO();
    private final MovieDAO movieDAO = new MovieDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        LocalDate to = parseDate(req.getParameter("toDate"), LocalDate.now());
        LocalDate from = parseDate(req.getParameter("fromDate"), to.minusDays(6));
        Integer movieId = parseInt(req.getParameter("movieId"));

        List<RevenueRow> rows = reportDAO.getRevenue(from, to, movieId);
        List<Movie> movies = movieDAO.findAll();

        req.setAttribute("rows", rows);
        req.setAttribute("movies", movies);
        req.setAttribute("fromDate", from.toString());
        req.setAttribute("toDate", to.toString());
        req.setAttribute("movieId", movieId);

        req.getRequestDispatcher("/manager/reports.jsp").forward(req, resp);
    }

    private LocalDate parseDate(String s, LocalDate fallback) {
        try {
            if (s == null || s.isBlank()) return fallback;
            return LocalDate.parse(s.trim());
        } catch (Exception e) {
            return fallback;
        }
    }

    private Integer parseInt(String s) {
        try {
            if (s == null || s.isBlank()) return null;
            return Integer.parseInt(s.trim());
        } catch (Exception e) {
            return null;
        }
    }
}

