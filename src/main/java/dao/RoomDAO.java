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

    public List<Room> findAllIncludingInactive() {
        String sql = "SELECT * FROM Rooms ORDER BY IsActive DESC, RoomName ASC";
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

    public int create(Room room) {
        String sql = "INSERT INTO Rooms (RoomName, RoomType, TotalSeats, IsActive) VALUES (?, ?, ?, ?)";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, room.getRoomName());
            ps.setString(2, room.getRoomType());
            ps.setInt(3, room.getTotalSeats());
            ps.setBoolean(4, room.isActive());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
            return 0;
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi tạo phòng chiếu", e);
        }
    }

    public boolean update(Room room) {
        String sql = "UPDATE Rooms SET RoomName=?, RoomType=?, TotalSeats=?, IsActive=? WHERE RoomId=?";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, room.getRoomName());
            ps.setString(2, room.getRoomType());
            ps.setInt(3, room.getTotalSeats());
            ps.setBoolean(4, room.isActive());
            ps.setInt(5, room.getRoomId());
            return ps.executeUpdate() > 0;
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi cập nhật phòng chiếu", e);
        }
    }

    public boolean deactivate(int roomId) {
        String sql = "UPDATE Rooms SET IsActive = 0 WHERE RoomId = ?";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roomId);
            return ps.executeUpdate() > 0;
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi vô hiệu hóa phòng chiếu", e);
        }
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
