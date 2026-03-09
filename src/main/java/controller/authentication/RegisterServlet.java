package controller.authentication;

import constant.Message;
import dao.UserDAO;
import model.Role;
import model.User;
import util.PasswordUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * UC-01 | Register account - Khách hàng tạo tài khoản qua form đăng ký
 */
@WebServlet(name = "RegisterServlet", urlPatterns = {"/register", "/auth/register"})
public class RegisterServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        setGoogleAuthUrl(req);
        req.getRequestDispatcher("/authentication/register.jsp").forward(req, resp);
    }

    private void setGoogleAuthUrl(HttpServletRequest req) {
        String clientId = getInitParameter("google.client.id");
        if (clientId == null) clientId = System.getenv("GOOGLE_CLIENT_ID");
        if (clientId != null) {
            String baseUrl = req.getScheme() + "://" + req.getServerName();
            if (req.getServerPort() != 80 && req.getServerPort() != 443) {
                baseUrl += ":" + req.getServerPort();
            }
            String redirectUri = baseUrl + req.getContextPath() + "/auth/google/callback";
            req.setAttribute("googleAuthUrl", "https://accounts.google.com/o/oauth2/v2/auth?response_type=code&client_id="
                    + clientId + "&redirect_uri=" + java.net.URLEncoder.encode(redirectUri, java.nio.charset.StandardCharsets.UTF_8)
                    + "&scope=email%20profile");
        } else {
            req.setAttribute("googleAuthUrl", "#");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String fullName = req.getParameter("fullName");
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");

        if (fullName == null || fullName.trim().isEmpty()) {
            req.setAttribute("error", "Vui lòng nhập họ tên.");
            forwardWithData(req, resp, fullName, email, null);
            return;
        }
        if (email == null || email.trim().isEmpty()) {
            req.setAttribute("error", "Vui lòng nhập email.");
            forwardWithData(req, resp, fullName, email, "Vui lòng nhập email.");
            return;
        }
        if (password == null || password.length() < 6) {
            req.setAttribute("error", "Mật khẩu phải có ít nhất 6 ký tự.");
            forwardWithData(req, resp, fullName, email, null);
            return;
        }
        if (!password.equals(confirmPassword)) {
            req.setAttribute("error", "Mật khẩu xác nhận không khớp.");
            forwardWithData(req, resp, fullName, email, null);
            return;
        }

        if (userDAO.existsByEmail(email.trim())) {
            req.setAttribute("error", Message.EMAIL_EXISTS);
            forwardWithData(req, resp, fullName, email, Message.EMAIL_EXISTS);
            return;
        }

        Role customerRole = userDAO.getRoleByCode("CUSTOMER");
        if (customerRole == null) {
            req.setAttribute("error", "Lỗi hệ thống. Vui lòng thử lại sau.");
            forwardWithData(req, resp, fullName, email, null);
            return;
        }

        User user = new User();
        user.setFullName(fullName.trim());
        user.setEmail(email.trim().toLowerCase());
        user.setPasswordHash(PasswordUtil.hash(password));
        user.setRole(customerRole);
        user.setMemberTier("Standard");
        user.setLoyaltyPoint(0);
        user.setActive(true);

        userDAO.create(user);
        req.getSession().setAttribute("success", Message.REGISTER_SUCCESS);
        resp.sendRedirect(req.getContextPath() + "/login");
    }

    private void forwardWithData(HttpServletRequest req, HttpServletResponse resp, String fullName, String email, String emailError)
            throws ServletException, IOException {
        req.setAttribute("fullName", fullName);
        req.setAttribute("email", email);
        req.setAttribute("emailError", emailError);
        req.getRequestDispatcher("/authentication/register.jsp").forward(req, resp);
    }
}
