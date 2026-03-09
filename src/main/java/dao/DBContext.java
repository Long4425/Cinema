package dao;

/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */

/**
 *
 * @author knd
 */

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBContext {

    // Thông tin cấu hình Database
    private static final String SERVER_NAME = "localhost";
    private static final String DB_NAME = "CinemaDB";
    private static final String PORT = "1433";
    private static final String USER_ID = "sa";
    private static final String PASSWORD = "123456";

    public Connection getConnection() throws ClassNotFoundException, SQLException {
        // Cấu trúc chuỗi kết nối chuẩn cho SQL Server
        String url = "jdbc:sqlserver://" + SERVER_NAME + ":" + PORT + ";databaseName=" + DB_NAME
                + ";encrypt=true;trustServerCertificate=true;";
        // encrypt=true;trustServerCertificate=true;: Cần thiết cho Driver phiên bản mới
        // (10.x trở lên)

        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        return DriverManager.getConnection(url, USER_ID, PASSWORD);
    }

    // Hàm main để test kết nối ngay lập tức
    public static void main(String[] args) {
        try {
            DBContext db = new DBContext();
            Connection conn = db.getConnection();
            if (conn != null) {
                System.out.println("Ket noi thanh cong toi " + DB_NAME);
            } else {
                System.out.println("Ket noi that bai!");
            }
        } catch (Exception e) {
            System.out.println("Loi ket noi: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
