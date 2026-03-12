package dao;

import exception.DataAccessException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import model.Voucher;

public class VoucherDAO {

    private final DBContext dbContext = new DBContext();

    public Voucher findValidByCode(String code, BigDecimal orderTotal) {
        String sql = "SELECT * FROM Vouchers "
                + "WHERE Code = ? AND IsActive = 1 AND ExpiredAt > GETDATE() "
                + "AND UsedCount < MaxUsage AND MinOrderValue <= ?";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code);
            ps.setBigDecimal(2, orderTotal);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return map(rs);
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi kiểm tra voucher", e);
        }
        return null;
    }

    public void increaseUsedCount(int voucherId) {
        String sql = "UPDATE Vouchers SET UsedCount = UsedCount + 1 WHERE VoucherId = ?";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, voucherId);
            ps.executeUpdate();
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi tăng số lần sử dụng voucher", e);
        }
    }

    public List<Voucher> findAll() {
        String sql = "SELECT * FROM Vouchers ORDER BY CreatedBy, VoucherId DESC";
        List<Voucher> list = new ArrayList<>();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(map(rs));
            }
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi lấy danh sách voucher", e);
        }
        return list;
    }

    public void create(Voucher v) {
        String sql = "INSERT INTO Vouchers (Code, DiscountType, DiscountValue, MinOrderValue, MaxUsage, UsedCount, ExpiredAt, IsActive, CreatedBy) "
                + "VALUES (?, ?, ?, ?, ?, 0, ?, ?, ?)";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, v.getCode());
            ps.setString(2, v.getDiscountType());
            ps.setBigDecimal(3, v.getDiscountValue());
            ps.setBigDecimal(4, v.getMinOrderValue());
            ps.setInt(5, v.getMaxUsage());
            ps.setTimestamp(6, Timestamp.valueOf(v.getExpiredAt()));
            ps.setBoolean(7, v.isActive());
            if (v.getCreatedBy() != null) {
                ps.setInt(8, v.getCreatedBy());
            } else {
                ps.setNull(8, java.sql.Types.INTEGER);
            }
            ps.executeUpdate();
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi tạo voucher", e);
        }
    }

    public void updateActive(int voucherId, boolean active) {
        String sql = "UPDATE Vouchers SET IsActive = ? WHERE VoucherId = ?";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, active);
            ps.setInt(2, voucherId);
            ps.executeUpdate();
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi cập nhật trạng thái voucher", e);
        }
    }

    private Voucher map(ResultSet rs) throws SQLException {
        Voucher v = new Voucher();
        v.setVoucherId(rs.getInt("VoucherId"));
        v.setCode(rs.getString("Code"));
        v.setDiscountType(rs.getString("DiscountType"));
        v.setDiscountValue(rs.getBigDecimal("DiscountValue"));
        v.setMinOrderValue(rs.getBigDecimal("MinOrderValue"));
        v.setMaxUsage(rs.getInt("MaxUsage"));
        v.setUsedCount(rs.getInt("UsedCount"));
        Timestamp expired = rs.getTimestamp("ExpiredAt");
        v.setExpiredAt(expired != null ? expired.toLocalDateTime() : LocalDateTime.now());
        v.setActive(rs.getBoolean("IsActive"));
        int createdBy = rs.getInt("CreatedBy");
        v.setCreatedBy(rs.wasNull() ? null : createdBy);
        return v;
    }
}

