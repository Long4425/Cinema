package dao;

import exception.DataAccessException;
import model.Room;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RoomDAO {
    private final DBContext dbContext = new DBContext();

    public List<Room> findAll() {
        String sql = "SELECT * FROM Rooms WHERE IsActive = 1";
        List<Room> rooms = new ArrayList<>();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                rooms.add(mapRoom(rs));
            }
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi lấy danh sách phòng", e);
        }
        return rooms;
    }

    public Room findById(int id) {
        String sql = "SELECT * FROM Rooms WHERE RoomId = ?";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRoom(rs);
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi tìm phòng theo ID", e);
        }
        return null;
    }

    private Room mapRoom(ResultSet rs) throws SQLException {
        Room r = new Room();
        r.setRoomId(rs.getInt("RoomId"));
        r.setRoomName(rs.getString("RoomName"));
        r.setRoomType(rs.getString("RoomType"));
        r.setTotalSeats(rs.getInt("TotalSeats"));
        r.setActive(rs.getBoolean("IsActive"));
        return r;
    }
}
