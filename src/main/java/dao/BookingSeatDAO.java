package dao;

import exception.DataAccessException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import model.BookingSeat;
import model.Seat;

public class BookingSeatDAO {

    private final DBContext dbContext = new DBContext();

    public void createBatch(List<BookingSeat> seats) {
        if (seats == null || seats.isEmpty()) {
            return;
        }
        String sql = "INSERT INTO BookingSeats (BookingId, SeatId, ShowtimeId, SeatPrice, Status, HeldUntil) "
                + "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            for (BookingSeat s : seats) {
                ps.setInt(1, s.getBookingId());
                ps.setInt(2, s.getSeatId());
                ps.setInt(3, s.getShowtimeId());
                ps.setBigDecimal(4, defaultIfNull(s.getSeatPrice()));
                ps.setString(5, s.getStatus());
                if (s.getHeldUntil() != null) {
                    ps.setTimestamp(6, Timestamp.valueOf(s.getHeldUntil()));
                } else {
                    ps.setNull(6, java.sql.Types.TIMESTAMP);
                }
                ps.addBatch();
            }
            ps.executeBatch();
            // not strictly needed to read generated ids here
        } catch (ClassNotFoundException | SQLException e) {
            String detail = e.getMessage() != null ? e.getMessage() : e.getClass().getSimpleName();
            throw new DataAccessException("Lỗi tạo booking seats: " + detail, e);
        }
    }

    public List<BookingSeat> findActiveByShowtime(int showtimeId) {
        String sql = "SELECT * FROM BookingSeats "
                + "WHERE ShowtimeId = ? "
                + "AND (Status = 'Confirmed' OR (Status = 'Held' AND (HeldUntil IS NULL OR HeldUntil > GETDATE())))";
        List<BookingSeat> list = new ArrayList<>();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, showtimeId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(map(rs));
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi lấy ghế đã giữ/đã đặt cho suất chiếu", e);
        }
        return list;
    }

    public void cancelHeldByBooking(int bookingId) {
        String sql = "UPDATE BookingSeats SET Status = 'Cancelled', HeldUntil = NULL "
                + "WHERE BookingId = ? AND Status = 'Held'";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookingId);
            ps.executeUpdate();
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi hủy ghế Held theo booking", e);
        }
    }

    public void updateStatusByBooking(int bookingId, String status) {
        String sql = "UPDATE BookingSeats SET Status = ?, HeldUntil = NULL WHERE BookingId = ?";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, bookingId);
            ps.executeUpdate();
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi cập nhật trạng thái ghế theo booking", e);
        }
    }

    public List<BookingSeat> findByBookingWithSeat(int bookingId) {
        String sql = "SELECT bs.*, s.RowLabel, s.SeatNumber "
                + "FROM BookingSeats bs "
                + "JOIN Seats s ON bs.SeatId = s.SeatId "
                + "WHERE bs.BookingId = ? "
                + "ORDER BY s.RowLabel, s.SeatNumber";
        List<BookingSeat> list = new ArrayList<>();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BookingSeat bs = map(rs);
                    Seat seat = new Seat();
                    seat.setSeatId(rs.getInt("SeatId"));
                    seat.setRowLabel(rs.getString("RowLabel"));
                    seat.setSeatNumber(rs.getInt("SeatNumber"));
                    bs.setSeat(seat);
                    list.add(bs);
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi lấy ghế theo booking", e);
        }
        return list;
    }

    private BookingSeat map(ResultSet rs) throws SQLException {
        BookingSeat bs = new BookingSeat();
        bs.setBookingSeatsId(rs.getInt("BookingSeatsId"));
        bs.setBookingId(rs.getInt("BookingId"));
        bs.setSeatId(rs.getInt("SeatId"));
        bs.setShowtimeId(rs.getInt("ShowtimeId"));
        bs.setSeatPrice(rs.getBigDecimal("SeatPrice"));
        bs.setStatus(rs.getString("Status"));
        Timestamp held = rs.getTimestamp("HeldUntil");
        bs.setHeldUntil(held != null ? held.toLocalDateTime() : null);
        return bs;
    }

    private BigDecimal defaultIfNull(BigDecimal value) {
        return value != null ? value : BigDecimal.ZERO;
    }
}

