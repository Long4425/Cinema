package controller.authentication;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;

/**
 * API kiểm tra email tồn tại - dùng cho real-time check khi đăng ký
 */
@WebServlet(name = "CheckEmailServlet", urlPatterns = {"/api/check-email"})
public class CheckEmailServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String email = req.getParameter("email");
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        if (email == null || email.trim().isEmpty()) {
            writeJson(resp, false, "invalid");
            return;
        }

        String trimmed = email.trim().toLowerCase();
        if (!isValidEmail(trimmed)) {
            writeJson(resp, false, "invalid");
            return;
        }

        boolean exists = userDAO.existsByEmail(trimmed);
        writeJson(resp, exists, exists ? "exists" : "available");
    }

    private void writeJson(HttpServletResponse resp, boolean exists, String status) throws IOException {
        PrintWriter out = resp.getWriter();
        out.print("{\"exists\":" + exists + ",\"status\":\"" + status + "\"}");
        out.flush();
    }

    private boolean isValidEmail(String email) {
        return email != null && email.matches("^[^@]+@[^@]+\\.[^@]+$");
    }
}
