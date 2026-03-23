package dao;

import exception.DataAccessException;
import model.Seat;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SeatDAO {
    private final DBContext dbContext = new DBContext();

    public List<Seat> findByRoom(int roomId) {
        String sql = "SELECT * FROM Seats WHERE RoomId = ? ORDER BY RowLabel ASC, SeatNumber ASC";
        List<Seat> seats = new ArrayList<>();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roomId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    seats.add(mapSeat(rs));
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi lấy danh sách ghế theo phòng", e);
        }
        return seats;
    }

    public int countByRoom(int roomId) {
        String sql = "SELECT COUNT(*) FROM Seats WHERE RoomId = ?";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roomId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi đếm ghế theo phòng", e);
        }
        return 0;
    }

    public boolean deleteByRoom(int roomId) {
        String sql = "DELETE FROM Seats WHERE RoomId = ?";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roomId);
            return ps.executeUpdate() >= 0;
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi xóa ghế theo phòng", e);
        }
    }

    public void createBatch(List<Seat> seats) {
        if (seats == null || seats.isEmpty()) return;
        String sql = "INSERT INTO Seats (RoomId, RowLabel, SeatNumber, SeatType) VALUES (?, ?, ?, ?)";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            conn.setAutoCommit(false);
            for (Seat s : seats) {
                ps.setInt(1, s.getRoomId());
                ps.setString(2, s.getRowLabel());
                ps.setInt(3, s.getSeatNumber());
                ps.setString(4, s.getSeatType());
                ps.addBatch();
            }
            ps.executeBatch();
            conn.commit();
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi tạo ghế hàng loạt", e);
        }
    }

    public List<Seat> findByIds(List<Integer> seatIds) {
        if (seatIds == null || seatIds.isEmpty()) return new ArrayList<>();
        StringBuilder sb = new StringBuilder("SELECT * FROM Seats WHERE SeatId IN (");
        for (int i = 0; i < seatIds.size(); i++) {
            sb.append(i == 0 ? "?" : ",?");
        }
        sb.append(")");
        List<Seat> seats = new ArrayList<>();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sb.toString())) {
            for (int i = 0; i < seatIds.size(); i++) {
                ps.setInt(i + 1, seatIds.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) seats.add(mapSeat(rs));
            }
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi lấy danh sách ghế theo ID", e);
        }
        return seats;
    }

    public boolean updateSeatType(int seatId, String seatType) {
        String sql = "UPDATE Seats SET SeatType = ? WHERE SeatId = ?";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, seatType);
            ps.setInt(2, seatId);
            return ps.executeUpdate() > 0;
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi cập nhật loại ghế", e);
        }
    }

    private Seat mapSeat(ResultSet rs) throws SQLException {
        Seat s = new Seat();
        s.setSeatId(rs.getInt("SeatId"));
        s.setRoomId(rs.getInt("RoomId"));
        s.setRowLabel(rs.getString("RowLabel"));
        s.setSeatNumber(rs.getInt("SeatNumber"));
        s.setSeatType(rs.getString("SeatType"));
        return s;
    }
}

