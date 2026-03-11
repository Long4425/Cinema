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
import model.Booking;

public class BookingDAO {

    private final DBContext dbContext = new DBContext();

    public int create(Booking booking) {
        String sql = "INSERT INTO Bookings (UserId, ShowtimeId, BookingType, Status, "
                + "SubTotal, DiscountAmount, TotalAmount, VoucherId, PointsEarned, PointsUsed, "
                + "Note, CreatedBy, CreatedAt) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            if (booking.getUserId() != null) {
                ps.setInt(1, booking.getUserId());
            } else {
                ps.setNull(1, java.sql.Types.INTEGER);
            }
            ps.setInt(2, booking.getShowtimeId());
            ps.setString(3, booking.getBookingType());
            ps.setString(4, booking.getStatus());
            ps.setBigDecimal(5, defaultIfNull(booking.getSubTotal()));
            ps.setBigDecimal(6, defaultIfNull(booking.getDiscountAmount()));
            ps.setBigDecimal(7, defaultIfNull(booking.getTotalAmount()));
            if (booking.getVoucherId() != null) {
                ps.setInt(8, booking.getVoucherId());
            } else {
                ps.setNull(8, java.sql.Types.INTEGER);
            }
            ps.setInt(9, booking.getPointsEarned());
            ps.setInt(10, booking.getPointsUsed());
            ps.setString(11, booking.getNote());
            if (booking.getCreatedBy() != null) {
                ps.setInt(12, booking.getCreatedBy());
            } else {
                ps.setNull(12, java.sql.Types.INTEGER);
            }
            LocalDateTime createdAt = booking.getCreatedAt() != null
                    ? booking.getCreatedAt()
                    : LocalDateTime.now();
            ps.setTimestamp(13, Timestamp.valueOf(createdAt));

            int affected = ps.executeUpdate();
            if (affected == 0) {
                throw new DataAccessException("Không thể tạo booking, không có dòng nào bị ảnh hưởng");
            }
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    int id = rs.getInt(1);
                    booking.setBookingId(id);
                    booking.setCreatedAt(createdAt);
                    return id;
                }
            }
            throw new DataAccessException("Không lấy được ID của booking vừa tạo");
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi tạo booking", e);
        }
    }

    public Booking findById(int id) {
        String sql = "SELECT * FROM Bookings WHERE BookingId = ?";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return map(rs);
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi tìm booking theo ID", e);
        }
        return null;
    }

    public void updateStatus(int bookingId, String status) {
        String sql = "UPDATE Bookings SET Status = ? WHERE BookingId = ?";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, bookingId);
            ps.executeUpdate();
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi cập nhật trạng thái booking", e);
        }
    }

    public void updateAmountsAndVoucher(int bookingId, BigDecimal subTotal, BigDecimal discountAmount,
                                        BigDecimal totalAmount, Integer voucherId) {
        String sql = "UPDATE Bookings SET SubTotal = ?, DiscountAmount = ?, TotalAmount = ?, VoucherId = ? "
                + "WHERE BookingId = ?";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBigDecimal(1, defaultIfNull(subTotal));
            ps.setBigDecimal(2, defaultIfNull(discountAmount));
            ps.setBigDecimal(3, defaultIfNull(totalAmount));
            if (voucherId != null) {
                ps.setInt(4, voucherId);
            } else {
                ps.setNull(4, java.sql.Types.INTEGER);
            }
            ps.setInt(5, bookingId);
            ps.executeUpdate();
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi cập nhật tiền và voucher cho booking", e);
        }
    }

    public List<Booking> findByUser(int userId) {
        String sql = "SELECT * FROM Bookings WHERE UserId = ? ORDER BY CreatedAt DESC";
        List<Booking> list = new ArrayList<>();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(map(rs));
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi lấy danh sách booking theo người dùng", e);
        }
        return list;
    }

    private Booking map(ResultSet rs) throws SQLException {
        Booking b = new Booking();
        b.setBookingId(rs.getInt("BookingId"));
        int userId = rs.getInt("UserId");
        b.setUserId(rs.wasNull() ? null : userId);
        b.setShowtimeId(rs.getInt("ShowtimeId"));
        b.setBookingType(rs.getString("BookingType"));
        b.setStatus(rs.getString("Status"));
        b.setSubTotal(rs.getBigDecimal("SubTotal"));
        b.setDiscountAmount(rs.getBigDecimal("DiscountAmount"));
        b.setTotalAmount(rs.getBigDecimal("TotalAmount"));
        int voucherId = rs.getInt("VoucherId");
        b.setVoucherId(rs.wasNull() ? null : voucherId);
        b.setPointsEarned(rs.getInt("PointsEarned"));
        b.setPointsUsed(rs.getInt("PointsUsed"));
        b.setNote(rs.getString("Note"));
        int createdBy = rs.getInt("CreatedBy");
        b.setCreatedBy(rs.wasNull() ? null : createdBy);
        Timestamp createdAt = rs.getTimestamp("CreatedAt");
        b.setCreatedAt(createdAt != null ? createdAt.toLocalDateTime() : null);
        return b;
    }

    private BigDecimal defaultIfNull(BigDecimal value) {
        return value != null ? value : BigDecimal.ZERO;
    }
}

