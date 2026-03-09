package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

import model.User;

/**
 * Trang home - Dành cho Customer.
 * Staff (CASHIER, MANAGER, ADMIN) sẽ được redirect sang /dashboard.
 */
public class HomeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        String roleCode = (user.getRole() != null) ? user.getRole().getRoleCode() : null;

        if (!"CUSTOMER".equalsIgnoreCase(roleCode)) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }

        req.setAttribute("activeTab", "HOME");
        req.getRequestDispatcher("/components/home.jsp").forward(req, resp);
    }
}
