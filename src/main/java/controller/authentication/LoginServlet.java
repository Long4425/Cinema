package controller.authentication;

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
 * UC-02 | Login - Đăng nhập bằng email/mật khẩu hoặc Google OAuth
 */
@WebServlet(name = "LoginServlet", urlPatterns = {"/login", "/auth/login"})
public class LoginServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String success = (String) req.getSession().getAttribute("success");
        if (success != null) {
            req.getSession().removeAttribute("success");
            req.setAttribute("success", success);
        }
        String msg = req.getParameter("msg");
        if (msg != null && !msg.isBlank()) {
            req.setAttribute("warning", msg);
        }
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            User user = (User) session.getAttribute("user");
            String roleCode = (user.getRole() != null) ? user.getRole().getRoleCode() : "";
            if ("CUSTOMER".equalsIgnoreCase(roleCode)) {
                resp.sendRedirect(req.getContextPath() + "/home");
            } else {
                resp.sendRedirect(req.getContextPath() + "/dashboard");
            }
            return;
        }
        String clientId = getInitParameter("google.client.id");
        if (clientId == null) clientId = System.getenv("GOOGLE_CLIENT_ID");
        if (clientId != null) {
            String baseUrl = req.getScheme() + "://" + req.getServerName();
            if (req.getServerPort() != 80 && req.getServerPort() != 443) {
                baseUrl += ":" + req.getServerPort();
            }
            String redirectUri = baseUrl + req.getContextPath() + "/auth/google/callback";
            String googleAuthUrl = "https://accounts.google.com/o/oauth2/v2/auth?response_type=code&client_id="
                    + clientId + "&redirect_uri=" + java.net.URLEncoder.encode(redirectUri, java.nio.charset.StandardCharsets.UTF_8)
                    + "&scope=email%20profile";
            req.setAttribute("googleAuthUrl", googleAuthUrl);
        } else {
            req.setAttribute("googleAuthUrl", "#");
        }
        req.getRequestDispatcher("/authentication/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String email = req.getParameter("email");
        String password = req.getParameter("password");

        if (email == null || email.trim().isEmpty() || password == null || password.isEmpty()) {
            req.setAttribute("error", "Vui lòng nhập email và mật khẩu.");
            req.getRequestDispatcher("/authentication/login.jsp").forward(req, resp);
            return;
        }

        var userOpt = userDAO.findByEmail(email.trim());
        if (userOpt.isEmpty()) {
            req.setAttribute("error", Message.NO_EXITING);
            req.setAttribute("email", email);
            req.getRequestDispatcher("/authentication/login.jsp").forward(req, resp);
            return;
        }

        User user = userOpt.get();
        if (!user.isActive()) {
            req.setAttribute("error", "Tài khoản đã bị vô hiệu hóa.");
            req.setAttribute("email", email);
            req.getRequestDispatcher("/authentication/login.jsp").forward(req, resp);
            return;
        }

        if (user.getPasswordHash() == null || user.getPasswordHash().isEmpty()) {
            req.setAttribute("error", "Tài khoản này đăng ký bằng Google. Vui lòng đăng nhập bằng Google.");
            req.setAttribute("email", email);
            req.getRequestDispatcher("/authentication/login.jsp").forward(req, resp);
            return;
        }

        if (!PasswordUtil.verify(password, user.getPasswordHash())) {
            req.setAttribute("error", Message.ERROR_PASS);
            req.setAttribute("email", email);
            req.getRequestDispatcher("/authentication/login.jsp").forward(req, resp);
            return;
        }

        HttpSession session = req.getSession(true);
        session.setAttribute("user", user);

        String roleCode = (user.getRole() != null) ? user.getRole().getRoleCode() : null;
        if (roleCode != null && roleCode.equalsIgnoreCase("CUSTOMER")) {
            resp.sendRedirect(req.getContextPath() + "/home");
        } else {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
        }
    }
}
