package controller.profile;

import constant.Message;
import dao.UserDAO;
import model.User;
import util.PasswordUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Đổi mật khẩu - Chỉ áp dụng cho tài khoản có mật khẩu (không phải Google)
 */
@WebServlet(name = "ChangePasswordServlet", urlPatterns = {"/profile/change-password"})
public class ChangePasswordServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = getCurrentUser(req);
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // Tài khoản Google không có mật khẩu
        if (user.getPasswordHash() == null || user.getPasswordHash().isEmpty()) {
            req.getSession().setAttribute("error", Message.PASSWORD_GOOGLE_USER);
            resp.sendRedirect(req.getContextPath() + "/profile");
            return;
        }

        String currentPassword = req.getParameter("currentPassword");
        String newPassword = req.getParameter("newPassword");
        String confirmPassword = req.getParameter("confirmPassword");

        if (currentPassword == null || currentPassword.isEmpty()) {
            req.getSession().setAttribute("error", "Vui lòng nhập mật khẩu hiện tại.");
            resp.sendRedirect(req.getContextPath() + "/profile");
            return;
        }
        if (newPassword == null || newPassword.length() < 6) {
            req.getSession().setAttribute("error", "Mật khẩu mới phải có ít nhất 6 ký tự.");
            resp.sendRedirect(req.getContextPath() + "/profile");
            return;
        }
        if (!newPassword.equals(confirmPassword)) {
            req.getSession().setAttribute("error", "Mật khẩu xác nhận không khớp.");
            resp.sendRedirect(req.getContextPath() + "/profile");
            return;
        }

        if (!PasswordUtil.verify(currentPassword, user.getPasswordHash())) {
            req.getSession().setAttribute("error", Message.PASSWORD_CURRENT_INVALID);
            resp.sendRedirect(req.getContextPath() + "/profile");
            return;
        }

        userDAO.updatePassword(user.getUserId(), PasswordUtil.hash(newPassword));
        req.getSession().setAttribute("success", Message.PASSWORD_CHANGE_SUCCESS);
        resp.sendRedirect(req.getContextPath() + "/profile");
    }

    private User getCurrentUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return (session != null) ? (User) session.getAttribute("user") : null;
    }
}
