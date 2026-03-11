package controller.admin;

import dao.AuditLogDAO;
import model.AuditLog;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

@WebServlet(name = "AuditLogServlet", urlPatterns = {"/admin/audit"})
public class AuditLogServlet extends HttpServlet {

    private final AuditLogDAO auditLogDAO = new AuditLogDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        LocalDate to = parseDate(req.getParameter("toDate"), LocalDate.now());
        LocalDate from = parseDate(req.getParameter("fromDate"), to.minusDays(7));
        String action = req.getParameter("actionFilter");

        List<AuditLog> logs = auditLogDAO.findByDateRangeAndAction(from, to, action);
        req.setAttribute("logs", logs);
        req.setAttribute("fromDate", from.toString());
        req.setAttribute("toDate", to.toString());
        req.setAttribute("actionFilter", action);

        req.getRequestDispatcher("/admin/audit.jsp").forward(req, resp);
    }

    private LocalDate parseDate(String s, LocalDate fallback) {
        try {
            if (s == null || s.isBlank()) return fallback;
            return LocalDate.parse(s.trim());
        } catch (Exception e) {
            return fallback;
        }
    }
}

