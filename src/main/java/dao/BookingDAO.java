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
import model.Movie;
import model.Showtime;
import model.User;

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

    public void updateShowtime(int bookingId, int newShowtimeId, BigDecimal newSubTotal, BigDecimal newTotalAmount) {
        String sql = "UPDATE Bookings SET ShowtimeId = ?, SubTotal = ?, TotalAmount = ? WHERE BookingId = ?";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, newShowtimeId);
            ps.setBigDecimal(2, defaultIfNull(newSubTotal));
            ps.setBigDecimal(3, defaultIfNull(newTotalAmount));
            ps.setInt(4, bookingId);
            ps.executeUpdate();
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi cập nhật suất chiếu cho booking", e);
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

    /**
     * Đếm tổng số booking thỏa filter (dùng để tính tổng trang).
     */
    public int countFiltered(String keyword, String status, String dateStr) {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) "
            + "FROM Bookings b "
            + "LEFT JOIN Users u ON b.UserId = u.UserId "
            + "JOIN Showtimes s ON b.ShowtimeId = s.ShowtimeId "
            + "JOIN Movies m ON s.MovieId = m.MovieId "
            + "WHERE 1=1 "
        );
        List<Object> params = new ArrayList<>();
        if (keyword != null && !keyword.isBlank()) {
            sql.append("AND (u.FullName LIKE ? OR u.Email LIKE ? OR CAST(b.BookingId AS NVARCHAR) = ?) ");
            params.add("%" + keyword.trim() + "%");
            params.add("%" + keyword.trim() + "%");
            params.add(keyword.trim());
        }
        if (status != null && !status.isBlank()) {
            sql.append("AND b.Status = ? ");
            params.add(status);
        }
        if (dateStr != null && !dateStr.isBlank()) {
            sql.append("AND CAST(s.StartTime AS DATE) = ? ");
            params.add(dateStr);
        }
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi đếm booking", e);
        }
    }

    /**
     * Search bookings for staff with optional filters + pagination.
     * page bắt đầu từ 1.
     */
    public List<BookingRow> findAllFiltered(String keyword, String status, String dateStr,
                                             int page, int pageSize) {
        StringBuilder sql = new StringBuilder(
            "SELECT b.BookingId, b.Status, b.BookingType, b.TotalAmount, b.CreatedAt, "
            + "u.UserId, u.FullName, u.Email, "
            + "s.ShowtimeId, s.StartTime, m.Title AS MovieTitle "
            + "FROM Bookings b "
            + "LEFT JOIN Users u ON b.UserId = u.UserId "
            + "JOIN Showtimes s ON b.ShowtimeId = s.ShowtimeId "
            + "JOIN Movies m ON s.MovieId = m.MovieId "
            + "WHERE 1=1 "
        );
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.isBlank()) {
            sql.append("AND (u.FullName LIKE ? OR u.Email LIKE ? OR CAST(b.BookingId AS NVARCHAR) = ?) ");
            params.add("%" + keyword.trim() + "%");
            params.add("%" + keyword.trim() + "%");
            params.add(keyword.trim());
        }
        if (status != null && !status.isBlank()) {
            sql.append("AND b.Status = ? ");
            params.add(status);
        }
        if (dateStr != null && !dateStr.isBlank()) {
            sql.append("AND CAST(s.StartTime AS DATE) = ? ");
            params.add(dateStr);
        }
        int offset = (page - 1) * pageSize;
        sql.append("ORDER BY b.CreatedAt DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add(offset);
        params.add(pageSize);

        List<BookingRow> list = new ArrayList<>();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BookingRow row = new BookingRow();
                    row.bookingId = rs.getInt("BookingId");
                    row.status = rs.getString("Status");
                    row.bookingType = rs.getString("BookingType");
                    row.totalAmount = rs.getBigDecimal("TotalAmount");
                    Timestamp ca = rs.getTimestamp("CreatedAt");
                    row.createdAt = ca != null ? ca.toLocalDateTime() : null;
                    int uid = rs.getInt("UserId");
                    row.userId = rs.wasNull() ? null : uid;
                    row.userFullName = rs.getString("FullName");
                    row.userEmail = rs.getString("Email");
                    row.showtimeId = rs.getInt("ShowtimeId");
                    Timestamp st = rs.getTimestamp("StartTime");
                    row.startTime = st != null ? st.toLocalDateTime() : null;
                    row.movieTitle = rs.getString("MovieTitle");
                    list.add(row);
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi tìm kiếm booking", e);
        }
        return list;
    }

    public static class BookingRow {
        public int bookingId;
        public String status;
        public String bookingType;
        public BigDecimal totalAmount;
        public LocalDateTime createdAt;
        public Integer userId;
        public String userFullName;
        public String userEmail;
        public int showtimeId;
        public LocalDateTime startTime;
        public String movieTitle;

        public int getBookingId() { return bookingId; }
        public String getStatus() { return status; }
        public String getBookingType() { return bookingType; }
        public BigDecimal getTotalAmount() { return totalAmount; }
        public LocalDateTime getCreatedAt() { return createdAt; }
        public Integer getUserId() { return userId; }
        public String getUserFullName() { return userFullName; }
        public String getUserEmail() { return userEmail; }
        public int getShowtimeId() { return showtimeId; }
        public LocalDateTime getStartTime() { return startTime; }
        public String getMovieTitle() { return movieTitle; }
        /** true nếu suất chiếu chưa bắt đầu (có thể hủy vé) */
        public boolean isBeforeShowtime() {
            return startTime != null && startTime.isAfter(java.time.LocalDateTime.now());
        }
    }

    public void updatePointsEarned(int bookingId, int points) {
        String sql = "UPDATE Bookings SET PointsEarned = ? WHERE BookingId = ?";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, points);
            ps.setInt(2, bookingId);
            ps.executeUpdate();
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi cập nhật điểm tích lũy cho booking", e);
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

