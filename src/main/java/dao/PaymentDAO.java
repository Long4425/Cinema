package dao;

import exception.DataAccessException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import model.Payment;

public class PaymentDAO {

    private final DBContext dbContext = new DBContext();

    public int create(Payment payment) {
        String sql = "INSERT INTO Payments (BookingId, PaymentMethod, Amount, Status, TransactionRef, PaidAt) "
                + "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, java.sql.Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, payment.getBookingId());
            ps.setString(2, payment.getPaymentMethod());
            ps.setBigDecimal(3, defaultIfNull(payment.getAmount()));
            ps.setString(4, payment.getStatus());
            ps.setString(5, payment.getTransactionRef());
            LocalDateTime paidAt = payment.getPaidAt();
            if (paidAt != null) {
                ps.setTimestamp(6, Timestamp.valueOf(paidAt));
            } else {
                ps.setNull(6, java.sql.Types.TIMESTAMP);
            }
            int affected = ps.executeUpdate();
            if (affected == 0) {
                throw new DataAccessException("Không thể tạo payment");
            }
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    int id = rs.getInt(1);
                    payment.setPaymentId(id);
                    return id;
                }
            }
            throw new DataAccessException("Không lấy được ID payment vừa tạo");
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi tạo payment", e);
        }
    }

    public void updateStatus(int paymentId, String status, LocalDateTime paidAt) {
        String sql = "UPDATE Payments SET Status = ?, PaidAt = ? WHERE PaymentId = ?";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            if (paidAt != null) {
                ps.setTimestamp(2, Timestamp.valueOf(paidAt));
            } else {
                ps.setNull(2, java.sql.Types.TIMESTAMP);
            }
            ps.setInt(3, paymentId);
            ps.executeUpdate();
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi cập nhật trạng thái payment", e);
        }
    }

    public Payment findByTransactionRef(String transactionRef) {
        String sql = "SELECT TOP 1 * FROM Payments WHERE TransactionRef = ? ORDER BY PaymentId DESC";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, transactionRef);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Payment p = new Payment();
                    p.setPaymentId(rs.getInt("PaymentId"));
                    p.setBookingId(rs.getInt("BookingId"));
                    p.setPaymentMethod(rs.getString("PaymentMethod"));
                    p.setAmount(rs.getBigDecimal("Amount"));
                    p.setStatus(rs.getString("Status"));
                    p.setTransactionRef(rs.getString("TransactionRef"));
                    Timestamp paidAt = rs.getTimestamp("PaidAt");
                    p.setPaidAt(paidAt != null ? paidAt.toLocalDateTime() : null);
                    Timestamp refundedAt = rs.getTimestamp("RefundedAt");
                    p.setRefundedAt(refundedAt != null ? refundedAt.toLocalDateTime() : null);
                    int refundedBy = rs.getInt("RefundedBy");
                    p.setRefundedBy(rs.wasNull() ? null : refundedBy);
                    return p;
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi lấy payment theo TransactionRef", e);
        }
        return null;
    }

    public Payment findLatestByBooking(int bookingId) {
        String sql = "SELECT TOP 1 * FROM Payments WHERE BookingId = ? ORDER BY PaymentId DESC";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Payment p = new Payment();
                    p.setPaymentId(rs.getInt("PaymentId"));
                    p.setBookingId(rs.getInt("BookingId"));
                    p.setPaymentMethod(rs.getString("PaymentMethod"));
                    p.setAmount(rs.getBigDecimal("Amount"));
                    p.setStatus(rs.getString("Status"));
                    p.setTransactionRef(rs.getString("TransactionRef"));
                    Timestamp paidAt = rs.getTimestamp("PaidAt");
                    p.setPaidAt(paidAt != null ? paidAt.toLocalDateTime() : null);
                    Timestamp refundedAt = rs.getTimestamp("RefundedAt");
                    p.setRefundedAt(refundedAt != null ? refundedAt.toLocalDateTime() : null);
                    int refundedBy = rs.getInt("RefundedBy");
                    p.setRefundedBy(rs.wasNull() ? null : refundedBy);
                    return p;
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi lấy payment theo booking", e);
        }
        return null;
    }

    public void markRefunded(int paymentId, Integer refundedBy) {
        String sql = "UPDATE Payments SET Status = 'Refunded', RefundedAt = ?, RefundedBy = ? WHERE PaymentId = ?";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            LocalDateTime now = LocalDateTime.now();
            ps.setTimestamp(1, Timestamp.valueOf(now));
            if (refundedBy != null) {
                ps.setInt(2, refundedBy);
            } else {
                ps.setNull(2, java.sql.Types.INTEGER);
            }
            ps.setInt(3, paymentId);
            ps.executeUpdate();
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi đánh dấu hoàn tiền", e);
        }
    }

    private BigDecimal defaultIfNull(BigDecimal value) {
        return value != null ? value : BigDecimal.ZERO;
    }
}

