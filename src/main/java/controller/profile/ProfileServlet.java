package controller.profile;

import constant.Message;
import dao.UserDAO;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Quản lý profile - Xem và cập nhật thông tin cá nhân
 */
@WebServlet(name = "ProfileServlet", urlPatterns = {"/profile", "/profile/edit"})
public class ProfileServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = getCurrentUser(req);
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        // Lấy user mới nhất từ DB (đồng bộ session)
        var userOpt = userDAO.findById(user.getUserId());
        if (userOpt.isPresent()) {
            req.setAttribute("user", userOpt.get());
        } else {
            req.setAttribute("user", user);
        }
        forwardMessages(req);
        req.getRequestDispatcher("/profile/profile.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = getCurrentUser(req);
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String fullName = req.getParameter("fullName");
        String phone = req.getParameter("phone");

        if (fullName == null || fullName.trim().isEmpty()) {
            req.setAttribute("error", "Vui lòng nhập họ tên.");
            req.setAttribute("user", user);
            req.getRequestDispatcher("/profile/profile.jsp").forward(req, resp);
            return;
        }

        userDAO.updateProfile(user.getUserId(), fullName.trim(), phone);
        User updated = userDAO.findById(user.getUserId()).orElse(user);
        updated.setFullName(fullName.trim());
        updated.setPhone(phone != null && !phone.trim().isEmpty() ? phone.trim() : null);

        HttpSession session = req.getSession(true);
        session.setAttribute("user", updated);

        req.getSession().setAttribute("success", Message.PROFILE_UPDATE_SUCCESS);
        resp.sendRedirect(req.getContextPath() + "/profile");
    }

    private User getCurrentUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return (session != null) ? (User) session.getAttribute("user") : null;
    }

    private void forwardMessages(HttpServletRequest req) {
        String success = (String) req.getSession().getAttribute("success");
        String error = (String) req.getSession().getAttribute("error");
        if (success != null) {
            req.getSession().removeAttribute("success");
            req.setAttribute("success", success);
        }
        if (error != null) {
            req.getSession().removeAttribute("error");
            req.setAttribute("error", error);
        }
    }
}
