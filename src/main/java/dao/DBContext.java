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

    public Connection getConnection() throws ClassNotFoundException, SQLException {
        String server = System.getProperty("DB_SERVER", "localhost");
        String port   = System.getProperty("DB_PORT",   "1433");
        String dbName = System.getProperty("DB_NAME",   "CinemaDB");
        String user   = System.getProperty("DB_USER",   "sa");
        String pass   = System.getProperty("DB_PASS",   "123456");

        String url = "jdbc:sqlserver://" + server + ":" + port + ";databaseName=" + dbName
                + ";encrypt=true;trustServerCertificate=true;";
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        return DriverManager.getConnection(url, user, pass);
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
