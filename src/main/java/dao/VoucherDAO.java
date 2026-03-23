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
        String sql = SELECT_ALL
                + "WHERE Code = ? AND IsActive = 1 "
                + "AND (StartAt IS NULL OR StartAt <= GETDATE()) "
                + "AND ExpiredAt > GETDATE() "
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

    private static final String SELECT_ALL = "SELECT VoucherId, Code, DiscountType, DiscountValue, MinOrderValue, MaxUsage, UsedCount, StartAt, ExpiredAt, IsActive, CreatedBy, OwnedByUserId FROM Vouchers ";

    /**
     * Voucher công khai còn hiệu lực (hiển thị cho user chọn tại checkout).
     * Điều kiện: OwnedByUserId IS NULL, IsActive=1, còn lượt dùng,
     *            đã đến ngày bắt đầu (StartAt), chưa hết hạn.
     */
    public List<Voucher> findAllPublicActive() {
        String sql = SELECT_ALL
                + "WHERE OwnedByUserId IS NULL AND IsActive = 1 "
                + "AND (StartAt IS NULL OR StartAt <= GETDATE()) "
                + "AND ExpiredAt > GETDATE() "
                + "AND UsedCount < MaxUsage "
                + "ORDER BY DiscountValue DESC";
        List<Voucher> list = new ArrayList<>();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(map(rs));
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi lấy voucher công khai", e);
        }
        return list;
    }

    public List<Voucher> findAll() {
        String sql = SELECT_ALL + "ORDER BY CreatedBy, VoucherId DESC";
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
        String sql = "INSERT INTO Vouchers (Code, DiscountType, DiscountValue, MinOrderValue, MaxUsage, UsedCount, StartAt, ExpiredAt, IsActive, CreatedBy) "
                + "VALUES (?, ?, ?, ?, ?, 0, ?, ?, ?, ?)";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, v.getCode());
            ps.setString(2, v.getDiscountType());
            ps.setBigDecimal(3, v.getDiscountValue());
            ps.setBigDecimal(4, v.getMinOrderValue());
            ps.setInt(5, v.getMaxUsage());
            if (v.getStartAt() != null) {
                ps.setTimestamp(6, Timestamp.valueOf(v.getStartAt()));
            } else {
                ps.setNull(6, java.sql.Types.TIMESTAMP);
            }
            ps.setTimestamp(7, Timestamp.valueOf(v.getExpiredAt()));
            ps.setBoolean(8, v.isActive());
            if (v.getCreatedBy() != null) {
                ps.setInt(9, v.getCreatedBy());
            } else {
                ps.setNull(9, java.sql.Types.INTEGER);
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

    /**
     * Tạo voucher cá nhân cho user khi đổi điểm.
     * @param userId    user nhận voucher
     * @param value     mệnh giá voucher (VD: 20000, 50000, 100000, 200000)
     * @param pointCost số điểm đã trừ (dùng để sinh code dễ nhận biết)
     * Trả về code của voucher vừa tạo.
     */
    public String createForUser(int userId, int value, int pointCost) {
        String code = "POINT" + pointCost + "P-" + userId + "-" + System.currentTimeMillis();
        String sql = "INSERT INTO Vouchers (Code, DiscountType, DiscountValue, MinOrderValue, MaxUsage, UsedCount, ExpiredAt, IsActive, CreatedBy, OwnedByUserId) "
                + "VALUES (?, 'FixedAmount', ?, 0, 1, 0, ?, 1, NULL, ?)";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code);
            ps.setBigDecimal(2, new java.math.BigDecimal(value));
            ps.setTimestamp(3, Timestamp.valueOf(LocalDateTime.now().plusYears(1)));
            ps.setInt(4, userId);
            ps.executeUpdate();
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi tạo voucher đổi điểm", e);
        }
        return code;
    }

    /**
     * Lấy danh sách voucher cá nhân còn hiệu lực của user (đổi từ điểm).
     */
    public List<Voucher> findActiveByUser(int userId) {
        String sql = SELECT_ALL
                + "WHERE OwnedByUserId = ? AND IsActive = 1 AND ExpiredAt > GETDATE() AND UsedCount < MaxUsage ORDER BY ExpiredAt ASC";
        List<Voucher> list = new ArrayList<>();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi lấy voucher của user", e);
        }
        return list;
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
        Timestamp startAt = rs.getTimestamp("StartAt");
        v.setStartAt(startAt != null ? startAt.toLocalDateTime() : null);
        Timestamp expired = rs.getTimestamp("ExpiredAt");
        v.setExpiredAt(expired != null ? expired.toLocalDateTime() : LocalDateTime.now());
        v.setActive(rs.getBoolean("IsActive"));
        int createdBy = rs.getInt("CreatedBy");
        v.setCreatedBy(rs.wasNull() ? null : createdBy);
        int ownedBy = rs.getInt("OwnedByUserId");
        v.setOwnedByUserId(rs.wasNull() ? null : ownedBy);
        return v;
    }
}

