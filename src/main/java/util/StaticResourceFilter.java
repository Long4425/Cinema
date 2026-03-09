package util;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;

/**
 * Phục vụ CSS, JS, images trực tiếp - chạy trước mọi filter khác, tránh bị redirect 302.
 * Filter mapping trong web.xml - phục vụ /css/*, /js/*, /images/* trực tiếp.
 */
public class StaticResourceFilter implements Filter {

    private static final String[] MIME_TYPES = {
        "css", "text/css",
        "js", "application/javascript",
        "png", "image/png",
        "jpg", "image/jpeg",
        "jpeg", "image/jpeg",
        "gif", "image/gif",
        "ico", "image/x-icon",
        "svg", "image/svg+xml",
        "woff", "font/woff",
        "woff2", "font/woff2"
    };

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        String path = req.getServletPath();
        if (path == null || path.isEmpty()) {
            path = req.getPathInfo();
        }
        if (path == null) {
            path = req.getRequestURI();
            String ctx = req.getContextPath();
            if (ctx != null && !ctx.isEmpty() && path.startsWith(ctx)) {
                path = path.substring(ctx.length());
            }
        }

        InputStream in = req.getServletContext().getResourceAsStream(path);
        if (in == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String contentType = getContentType(path);
        if (contentType != null) {
            resp.setContentType(contentType);
        }
        resp.setCharacterEncoding(StandardCharsets.UTF_8.name());

        try (OutputStream out = resp.getOutputStream()) {
            byte[] buf = new byte[8192];
            int n;
            while ((n = in.read(buf)) > 0) {
                out.write(buf, 0, n);
            }
        } finally {
            in.close();
        }
    }

    private String getContentType(String path) {
        if (path == null) return "application/octet-stream";
        int dot = path.lastIndexOf('.');
        if (dot < 0) return "application/octet-stream";
        String ext = path.substring(dot + 1).toLowerCase();
        for (int i = 0; i < MIME_TYPES.length; i += 2) {
            if (MIME_TYPES[i].equals(ext)) {
                return MIME_TYPES[i + 1];
            }
        }
        return "application/octet-stream";
    }
}
