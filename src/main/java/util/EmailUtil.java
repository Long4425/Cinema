package util;

import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

import java.util.Properties;

/**
 * Utility gửi email - UC-03 Forgot Password
 * Cấu hình SMTP qua JNDI hoặc properties (sửa trong context.xml / web.xml)
 */
public class EmailUtil {

    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final String SMTP_PORT = "587";
    private static final String SMTP_USER = System.getenv("CINEMA_SMTP_USER"); // hoặc đặt trong config
    private static final String SMTP_PASS = System.getenv("CINEMA_SMTP_PASS");

    public static boolean sendPasswordResetEmail(String toEmail, String resetLink) {
        if (SMTP_USER == null || SMTP_PASS == null) {
            System.err.println("CINEMA_SMTP_USER / CINEMA_SMTP_PASS chưa được cấu hình. Bỏ qua gửi email.");
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
                    return new PasswordAuthentication(SMTP_USER, SMTP_PASS);
                }
            });

            MimeMessage msg = new MimeMessage(session);
            msg.setFrom(new InternetAddress(SMTP_USER, "Cinema System"));
            msg.setRecipient(Message.RecipientType.TO, new InternetAddress(toEmail));
            msg.setSubject("Đặt lại mật khẩu - Cinema");
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
            System.err.println("Lỗi gửi email: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}
