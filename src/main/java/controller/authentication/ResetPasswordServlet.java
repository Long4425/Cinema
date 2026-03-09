package controller.authentication;

import constant.Message;
import dao.UserDAO;
import util.PasswordUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * UC-03 | Reset password - Thiết lập mật khẩu mới từ link email
 */
@WebServlet(name = "ResetPasswordServlet", urlPatterns = {"/reset-password", "/auth/reset-password"})
public class ResetPasswordServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String token = req.getParameter("token");
        if (token == null || token.isEmpty()) {
            req.setAttribute("error", "Link không hợp lệ.");
            req.getRequestDispatcher("/authentication/reset-password.jsp").forward(req, resp);
            return;
        }
        var userIdOpt = userDAO.findUserIdByToken(token);
        if (userIdOpt.isEmpty()) {
            req.setAttribute("error", Message.TOKEN_EXPIRED);
            req.getRequestDispatcher("/authentication/reset-password.jsp").forward(req, resp);
            return;
        }
        req.setAttribute("token", token);
        req.getRequestDispatcher("/authentication/reset-password.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String token = req.getParameter("token");
        String password = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");

        if (token == null || token.isEmpty()) {
            req.setAttribute("error", "Link không hợp lệ.");
            req.getRequestDispatcher("/authentication/reset-password.jsp").forward(req, resp);
            return;
        }

        var userIdOpt = userDAO.findUserIdByToken(token);
        if (userIdOpt.isEmpty()) {
            req.setAttribute("error", Message.TOKEN_EXPIRED);
            req.getRequestDispatcher("/authentication/reset-password.jsp").forward(req, resp);
            return;
        }

        if (password == null || password.length() < 6) {
            req.setAttribute("error", "Mật khẩu phải có ít nhất 6 ký tự.");
            req.setAttribute("token", token);
            req.getRequestDispatcher("/authentication/reset-password.jsp").forward(req, resp);
            return;
        }
        if (!password.equals(confirmPassword)) {
            req.setAttribute("error", "Mật khẩu xác nhận không khớp.");
            req.setAttribute("token", token);
            req.getRequestDispatcher("/authentication/reset-password.jsp").forward(req, resp);
            return;
        }

        int userId = userIdOpt.get();
        userDAO.updatePassword(userId, PasswordUtil.hash(password));
        userDAO.deleteToken(token);

        req.getSession().setAttribute("success", Message.RESET_PASSWORD_SUCCESS);
        resp.sendRedirect(req.getContextPath() + "/login");
    }
}
