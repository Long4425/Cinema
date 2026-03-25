package controller.authentication;

import constant.Message;
import dao.UserDAO;
import util.EmailUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.security.SecureRandom;
import java.sql.Timestamp;
import java.util.Base64;

/**
 * UC-03 | Forgot password - Gửi link đặt lại mật khẩu qua email
 */
@WebServlet(name = "ForgotPasswordServlet", urlPatterns = {"/forgot-password", "/auth/forgot-password"})
public class ForgotPasswordServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private static final SecureRandom RANDOM = new SecureRandom();
    private static final int TOKEN_BYTES = 48;
    private static final int EXPIRE_HOURS = 1;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/authentication/forgot-password.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String email = req.getParameter("email");
        if (email == null || email.trim().isEmpty()) {
            req.setAttribute("error", "Vui lòng nhập email.");
            req.getRequestDispatcher("/authentication/forgot-password.jsp").forward(req, resp);
            return;
        }

        var userOpt = userDAO.findByEmail(email.trim());
        if (userOpt.isEmpty()) {
            req.setAttribute("error", Message.NO_EXITING);
            req.setAttribute("email", email);
            req.getRequestDispatcher("/authentication/forgot-password.jsp").forward(req, resp);
            return;
        }

        var user = userOpt.get();
        if (user.getPasswordHash() == null || user.getPasswordHash().isEmpty()) {
            req.setAttribute("error", "Tài khoản này đăng ký bằng Google. Vui lòng đăng nhập bằng Google.");
            req.setAttribute("email", email);
            req.getRequestDispatcher("/authentication/forgot-password.jsp").forward(req, resp);
            return;
        }

        String token = generateToken();
        Timestamp expiresAt = new Timestamp(System.currentTimeMillis() + EXPIRE_HOURS * 60 * 60 * 1000L);
        userDAO.createPasswordResetToken(token, user.getUserId(), expiresAt);

        String baseUrl = req.getScheme() + "://" + req.getServerName();
        if (req.getServerPort() != 80 && req.getServerPort() != 443) {
            baseUrl += ":" + req.getServerPort();
        }
        baseUrl += req.getContextPath();
        String resetLink = baseUrl + "/reset-password?token=" + token;

        boolean sent = EmailUtil.sendPasswordResetEmail(user.getEmail(), resetLink, getServletContext());
        if (!sent) {
            String mailErr = (String) getServletContext().getAttribute("mail.error");
            req.setAttribute("error", (mailErr != null && !mailErr.isBlank())
                    ? mailErr
                    : "Không thể gửi email. Vui lòng kiểm tra cấu hình SMTP hoặc thử lại sau.");
            req.setAttribute("email", email);
            req.getRequestDispatcher("/authentication/forgot-password.jsp").forward(req, resp);
            return;
        }

        req.setAttribute("success", Message.FORGOT_PASSWORD_SENT);
        req.getRequestDispatcher("/authentication/forgot-password.jsp").forward(req, resp);
    }

    private String generateToken() {
        byte[] bytes = new byte[TOKEN_BYTES];
        RANDOM.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }
}
