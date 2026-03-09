package filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import model.User;

/**
 * RoleFilter
 * ------------------------------------
 * Kiểm soát quyền truy cập theo vai trò cho các URL nội bộ.
 *
 * Quy ước roleCode (Users.RoleCode):
 *  - CUSTOMER
 *  - CASHIER
 *  - MANAGER
 *  - ADMIN
 *
 * Mapping URL chính:
 *  - /admin/**     -> ADMIN
 *  - /manager/**   -> MANAGER, ADMIN
 *  - /counter/**   -> CASHIER, MANAGER
 *  - /request/**   -> MANAGER, ADMIN (quản lý / báo cáo nội bộ)
 *  - /movies, /showtimes, /booking/** -> CUSTOMER, CASHIER, MANAGER, ADMIN
 *  - /components/**, /authentication/** -> mọi role đã đăng nhập
 *  - Các URL công khai (login, register, static) được bỏ qua kiểm tra.
 */
/**
 * Filter mapping trong web.xml - KHÔNG áp dụng cho /css/*, /js/*, /images/*
 * để tài nguyên tĩnh luôn được phục vụ trực tiếp.
 */
public class RoleFilter implements Filter {

    private static final List<String> PUBLIC_PREFIXES = List.of(
            "/login",
            "/register",
            "/forgot-password",
            "/reset-password",
            "/auth/google/callback",
            "/api/check-email",
            "/css",
            "/js",
            "/images",
            "/webjars",
            "/index.html",
            "/favicon"
    );

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Không cần cấu hình đặc biệt
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        String contextPath = req.getContextPath();
        String path = req.getRequestURI();
        if (contextPath != null && !contextPath.isEmpty() && path.startsWith(contextPath)) {
            path = path.substring(contextPath.length());
        }
        if (path == null || path.isEmpty()) {
            path = "/";
        }
        path = path.replaceAll("/+", "/");

        // Cho phép các tài nguyên / URL công khai
        if (isPublicPath(path)) {
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            // Chưa đăng nhập -> chuyển về trang login
            resp.sendRedirect(contextPath + "/login");
            return;
        }

        String roleCode = (user.getRole() != null) ? user.getRole().getRoleCode() : null;

        if (!isAuthorized(path, roleCode)) {
            // Không đủ quyền -> 403 Forbidden
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập chức năng này.");
            return;
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // Không cần dọn dẹp gì đặc biệt
    }

    private boolean isPublicPath(String path) {
        if (path == null || path.isEmpty() || "/".equals(path)) {
            return true;
        }
        // Cho phép tài nguyên tĩnh (CSS, JS, images) - kiểm tra theo nhiều cách
        if (path.contains("/css/") || path.contains("/js/") || path.contains("/images/")
                || path.endsWith(".css") || path.endsWith(".js") || path.endsWith(".png")
                || path.endsWith(".jpg") || path.endsWith(".ico") || path.endsWith(".svg")) {
            return true;
        }
        for (String prefix : PUBLIC_PREFIXES) {
            if (path.startsWith(prefix)) {
                return true;
            }
        }
        return false;
    }

    private boolean isAuthorized(String path, String roleCode) {
        if (roleCode == null) {
            return false;
        }

        // Khu vực Admin
        if (path.startsWith("/admin")) {
            return "ADMIN".equals(roleCode);
        }

        // Khu vực Manager
        if (path.startsWith("/manager") || path.startsWith("/request")) {
            return "MANAGER".equals(roleCode) || "ADMIN".equals(roleCode);
        }

        // Khu vực quầy Cashier
        if (path.startsWith("/counter")) {
            return "CASHIER".equals(roleCode) || "MANAGER".equals(roleCode);
        }

        // Module đặt vé / xem phim
        if (path.startsWith("/movies")
                || path.startsWith("/showtimes")
                || path.startsWith("/booking")) {
            return Arrays.asList("CUSTOMER", "CASHIER", "MANAGER", "ADMIN").contains(roleCode);
        }

        // Trang nội bộ (dashboard, auth JSPs, components, profile)
        if (path.startsWith("/components")
                || path.startsWith("/authentication")
                || path.startsWith("/home")
                || path.startsWith("/dashboard")
                || path.startsWith("/profile")) {
            return true;
        }

        // Mặc định: cho phép với mọi role đã đăng nhập
        return true;
    }
}

