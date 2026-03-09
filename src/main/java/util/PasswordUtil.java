package util;

import org.mindrot.jbcrypt.BCrypt;

/**
 * Utility cho hash và verify mật khẩu (BCrypt)
 */
public class PasswordUtil {

    private static final int WORK_FACTOR = 10;

    public static String hash(String plainPassword) {
        return BCrypt.hashpw(plainPassword, BCrypt.gensalt(WORK_FACTOR));
    }

    public static boolean verify(String plainPassword, String hashedPassword) {
        if (hashedPassword == null || hashedPassword.isEmpty()) {
            return false;
        }
        return BCrypt.checkpw(plainPassword, hashedPassword);
    }
}
