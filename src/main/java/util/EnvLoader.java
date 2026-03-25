package util;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.nio.file.Paths;

@WebListener
public class EnvLoader implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        // Tìm file .env ở thư mục gốc project (nơi chạy Tomcat)
        String[] candidates = {
            ".env",
            System.getProperty("user.dir") + "/.env",
            sce.getServletContext().getRealPath("/") + "../../../.env"
        };

        for (String path : candidates) {
            if (loadEnvFile(path)) {
                sce.getServletContext().log("EnvLoader: loaded " + Paths.get(path).toAbsolutePath());
                return;
            }
        }

        sce.getServletContext().log("EnvLoader: .env file not found, using existing system properties or context.xml values");
    }

    private boolean loadEnvFile(String path) {
        try (BufferedReader reader = new BufferedReader(new FileReader(path))) {
            String line;
            while ((line = reader.readLine()) != null) {
                line = line.trim();
                if (line.isEmpty() || line.startsWith("#")) continue;
                int eq = line.indexOf('=');
                if (eq < 1) continue;
                String key = line.substring(0, eq).trim();
                String value = line.substring(eq + 1).trim();
                System.setProperty(key, value);
            }
            return true;
        } catch (IOException e) {
            return false;
        }
    }
}
