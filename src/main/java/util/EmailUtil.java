package util;

import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import jakarta.servlet.ServletContext;

import java.nio.charset.StandardCharsets;
import java.util.Properties;

/**
 * Utility gửi email - UC-03 Forgot Password
 * Cấu hình SMTP qua context.xml (Parameter smtp.user / smtp.pass)
 */
public class EmailUtil {

    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final String SMTP_PORT = "587";

    public static boolean sendPasswordResetEmail(String toEmail, String resetLink, ServletContext ctx) {
        String smtpUser = ctx.getInitParameter("smtp.user");
        String smtpPass = ctx.getInitParameter("smtp.pass");

        // Clear error info from previous attempts.
        ctx.setAttribute("mail.error", null);

        if (smtpUser == null || smtpUser.isBlank() || smtpPass == null || smtpPass.isBlank()) {
            String msg = "Chưa cấu hình SMTP: thiếu smtp.user hoặc smtp.pass trong context.xml.";
            System.err.println(msg);
            ctx.setAttribute("mail.error", msg);
            return false;
        }
        if ("YOUR_GMAIL@gmail.com".equalsIgnoreCase(smtpUser.trim())) {
            String msg = "Chưa cập nhật smtp.user (đang để 'YOUR_GMAIL@gmail.com') trong context.xml.";
            System.err.println(msg);
            ctx.setAttribute("mail.error", msg);
            return false;
        }
        try {
            Properties props = new Properties();
            props.put("mail.smtp.host", SMTP_HOST);
            props.put("mail.smtp.port", SMTP_PORT);
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");

            Session session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(smtpUser, smtpPass);
                }
            });

            MimeMessage msg = new MimeMessage(session);
            // Chỉ định charset để tránh lỗi hiển thị tiếng Việt ở Gmail.
            msg.setFrom(new InternetAddress(smtpUser, "Cinema", StandardCharsets.UTF_8.name()));
            msg.setRecipient(Message.RecipientType.TO, new InternetAddress(toEmail));
            msg.setSubject("Đặt lại mật khẩu - Cinema", StandardCharsets.UTF_8.name());
            msg.setContent(
                    "<h2>Đặt lại mật khẩu</h2>" +
                            "<p>Bạn đã yêu cầu đặt lại mật khẩu. Nhấn vào link dưới đây (có hiệu lực 1 giờ):</p>" +
                            "<p><a href=\"" + resetLink + "\">" + resetLink + "</a></p>" +
                            "<p>Nếu bạn không yêu cầu, hãy bỏ qua email này.</p>",
                    "text/html; charset=UTF-8"
            );
            Transport.send(msg);
            return true;
        } catch (Exception e) {
            String err = "Lỗi gửi email: " + (e.getMessage() != null ? e.getMessage() : e.toString());
            System.err.println(err);
            ctx.setAttribute("mail.error", err);
            return false;
        }
    }
}
