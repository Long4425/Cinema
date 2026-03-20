package controller.manager;

import dao.ReportDAO;
import model.RevenueRow;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDate;
import java.util.List;

@WebServlet(name = "ReportExportServlet", urlPatterns = {"/manager/export"})
public class ReportExportServlet extends HttpServlet {

    private final ReportDAO reportDAO = new ReportDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        LocalDate to = parseDate(req.getParameter("toDate"), LocalDate.now());
        LocalDate from = parseDate(req.getParameter("fromDate"), to.minusDays(6));
        Integer movieId = parseInt(req.getParameter("movieId"));

        List<RevenueRow> rows = reportDAO.getRevenue(from, to, movieId);

        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("text/csv; charset=UTF-8");
        resp.setHeader("Content-Disposition",
                "attachment; filename=\"revenue-report-" + from + "-to-" + to + ".csv\"");

        try (PrintWriter out = resp.getWriter()) {
            out.println("\uFEFFDate,Movie,Room,Revenue,Tickets,ShowCount,RoomSeats,OccupancyPercent");
            for (RevenueRow r : rows) {
                String date = r.getDate() != null ? r.getDate().toString() : "";
                String movie = escapeCsv(r.getMovieTitle());
                String room = escapeCsv(r.getRoomName());
                String revenue = r.getRevenue() != null ? r.getRevenue().toPlainString() : "0";
                double occ = r.getOccupancyRate() * 100.0;
                out.printf("%s,%s,%s,%s,%d,%d,%d,%.2f%n",
                        date, movie, room, revenue, r.getTickets(), r.getShowCount(), r.getRoomSeats(), occ);
            }
        }
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

    private String escapeCsv(String s) {
        if (s == null) return "";
        String v = s.replace("\"", "\"\"");
        if (v.contains(",") || v.contains("\n") || v.contains("\r")) {
            return "\"" + v + "\"";
        }
        return v;
    }
}

