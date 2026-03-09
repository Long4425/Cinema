package controller.authentication;

import dao.UserDAO;
import model.Role;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Scanner;

/**
 * UC-01, UC-02 | Google OAuth callback - Xử lý đăng nhập/đăng ký bằng Google
 * Cấu hình: GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET trong biến môi trường hoặc context
 */
@WebServlet(name = "GoogleCallbackServlet", urlPatterns = {"/auth/google/callback"})
public class GoogleCallbackServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private static final String GOOGLE_TOKEN_URL = "https://oauth2.googleapis.com/token";
    private static final String GOOGLE_USERINFO_URL = "https://www.googleapis.com/oauth2/v2/userinfo";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String code = req.getParameter("code");
        String error = req.getParameter("error");

        if (error != null) {
            req.setAttribute("error", "Đăng nhập Google thất bại: " + error);
            req.getRequestDispatcher("/authentication/login.jsp").forward(req, resp);
            return;
        }

        if (code == null || code.isEmpty()) {
            req.setAttribute("error", "Không nhận được mã xác thực từ Google.");
            req.getRequestDispatcher("/authentication/login.jsp").forward(req, resp);
            return;
        }

        String clientId = getInitParameter("google.client.id");
        if (clientId == null) clientId = System.getenv("GOOGLE_CLIENT_ID");
        String clientSecret = getInitParameter("google.client.secret");
        if (clientSecret == null) clientSecret = System.getenv("GOOGLE_CLIENT_SECRET");

        if (clientId == null || clientSecret == null) {
            req.setAttribute("error", "Google OAuth chưa được cấu hình. Vui lòng đăng nhập bằng email/mật khẩu.");
            req.getRequestDispatcher("/authentication/login.jsp").forward(req, resp);
            return;
        }

        String redirectUri = getRedirectUri(req);
        String accessToken = exchangeCodeForToken(code, clientId, clientSecret, redirectUri);
        if (accessToken == null) {
            req.setAttribute("error", "Không thể xác thực với Google.");
            req.getRequestDispatcher("/authentication/login.jsp").forward(req, resp);
            return;
        }

        GoogleUserInfo userInfo = fetchUserInfo(accessToken);
        if (userInfo == null) {
            req.setAttribute("error", "Không thể lấy thông tin từ Google.");
            req.getRequestDispatcher("/authentication/login.jsp").forward(req, resp);
            return;
        }

        var existingOpt = userDAO.findByGoogleId(userInfo.id);
        User user;
        if (existingOpt.isPresent()) {
            user = existingOpt.get();
        } else {
            var byEmailOpt = userDAO.findByEmail(userInfo.email);
            if (byEmailOpt.isPresent()) {
                req.setAttribute("error", "Email này đã tồn tại. Vui lòng đăng nhập bằng mật khẩu.");
                req.getRequestDispatcher("/authentication/login.jsp").forward(req, resp);
                return;
            }
            Role customerRole = userDAO.getRoleByCode("CUSTOMER");
            if (customerRole == null) {
                req.setAttribute("error", "Lỗi hệ thống.");
                req.getRequestDispatcher("/authentication/login.jsp").forward(req, resp);
                return;
            }
            user = new User();
            user.setFullName(userInfo.name);
            user.setEmail(userInfo.email);
            user.setGoogleId(userInfo.id);
            user.setRole(customerRole);
            user.setMemberTier("Standard");
            user.setLoyaltyPoint(0);
            user.setActive(true);
            userDAO.create(user);
        }

        if (!user.isActive()) {
            req.setAttribute("error", "Tài khoản đã bị vô hiệu hóa.");
            req.getRequestDispatcher("/authentication/login.jsp").forward(req, resp);
            return;
        }

        HttpSession session = req.getSession(true);
        session.setAttribute("user", user);
        String roleCode = (user.getRole() != null) ? user.getRole().getRoleCode() : null;
        if ("CUSTOMER".equalsIgnoreCase(roleCode)) {
            resp.sendRedirect(req.getContextPath() + "/home");
        } else {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
        }
    }

    private String getRedirectUri(HttpServletRequest req) {
        String baseUrl = req.getScheme() + "://" + req.getServerName();
        if (req.getServerPort() != 80 && req.getServerPort() != 443) {
            baseUrl += ":" + req.getServerPort();
        }
        return baseUrl + req.getContextPath() + "/auth/google/callback";
    }

    private String exchangeCodeForToken(String code, String clientId, String clientSecret, String redirectUri) throws IOException {
        String body = "code=" + URLEncoder.encode(code, StandardCharsets.UTF_8)
                + "&client_id=" + URLEncoder.encode(clientId, StandardCharsets.UTF_8)
                + "&client_secret=" + URLEncoder.encode(clientSecret, StandardCharsets.UTF_8)
                + "&redirect_uri=" + URLEncoder.encode(redirectUri, StandardCharsets.UTF_8)
                + "&grant_type=authorization_code";

        HttpURLConnection conn = (HttpURLConnection) new URL(GOOGLE_TOKEN_URL).openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
        conn.setDoOutput(true);
        try (OutputStream os = conn.getOutputStream()) {
            os.write(body.getBytes(StandardCharsets.UTF_8));
        }
        int responseCode = conn.getResponseCode();
        if (responseCode != 200) {
            return null;
        }
        String json = new Scanner(conn.getInputStream(), StandardCharsets.UTF_8).useDelimiter("\\A").next();
        return extractJsonString(json, "access_token");
    }

    private GoogleUserInfo fetchUserInfo(String accessToken) throws IOException {
        HttpURLConnection conn = (HttpURLConnection) new URL(GOOGLE_USERINFO_URL).openConnection();
        conn.setRequestProperty("Authorization", "Bearer " + accessToken);
        int responseCode = conn.getResponseCode();
        if (responseCode != 200) return null;
        String json = new Scanner(conn.getInputStream(), StandardCharsets.UTF_8).useDelimiter("\\A").next();
        String id = extractJsonString(json, "id");
        String email = extractJsonString(json, "email");
        String name = extractJsonString(json, "name");
        if (id == null || email == null) return null;
        return new GoogleUserInfo(id, email, name != null ? name : email);
    }

    private String extractJsonString(String json, String key) {
        String search = "\"" + key + "\":\"";
        int start = json.indexOf(search);
        if (start == -1) return null;
        start += search.length();
        int end = json.indexOf("\"", start);
        return end > start ? json.substring(start, end) : null;
    }

    private static class GoogleUserInfo {
        final String id, email, name;
        GoogleUserInfo(String id, String email, String name) {
            this.id = id;
            this.email = email;
            this.name = name;
        }
    }
}
