package dao;

import exception.DataAccessException;
import model.Role;
import model.User;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.Optional;

/**
 * DAO cho User - UC-01, UC-02, UC-03
 */
public class UserDAO {
    private final DBContext dbContext = new DBContext();

    public Optional<User> findByEmail(String email) {
        String sql = "SELECT u.UserId, u.FullName, u.Email, u.PasswordHash, u.GoogleId, u.Phone, " +
                "u.MemberTier, u.LoyaltyPoint, u.RoleId, u.IsActive, u.CreatedAt, " +
                "r.RoleId as rRoleId, r.RoleCode, r.RoleName, r.Description " +
                "FROM Users u INNER JOIN Roles r ON u.RoleId = r.RoleId WHERE u.Email = ?";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapUser(rs));
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi tìm user theo email", e);
        }
        return Optional.empty();
    }

    public Optional<User> findById(int userId) {
        String sql = "SELECT u.UserId, u.FullName, u.Email, u.PasswordHash, u.GoogleId, u.Phone, " +
                "u.MemberTier, u.LoyaltyPoint, u.RoleId, u.IsActive, u.CreatedAt, " +
                "r.RoleId as rRoleId, r.RoleCode, r.RoleName, r.Description " +
                "FROM Users u INNER JOIN Roles r ON u.RoleId = r.RoleId WHERE u.UserId = ?";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapUser(rs));
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi tìm user theo id", e);
        }
        return Optional.empty();
    }

    public Optional<User> findByGoogleId(String googleId) {
        String sql = "SELECT u.UserId, u.FullName, u.Email, u.PasswordHash, u.GoogleId, u.Phone, " +
                "u.MemberTier, u.LoyaltyPoint, u.RoleId, u.IsActive, u.CreatedAt, " +
                "r.RoleId as rRoleId, r.RoleCode, r.RoleName, r.Description " +
                "FROM Users u INNER JOIN Roles r ON u.RoleId = r.RoleId WHERE u.GoogleId = ?";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, googleId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapUser(rs));
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi tìm user theo GoogleId", e);
        }
        return Optional.empty();
    }

    public boolean existsByEmail(String email) {
        return findByEmail(email).isPresent();
    }

    public User create(User user) {
        String sql = "INSERT INTO Users (FullName, Email, PasswordHash, GoogleId, Phone, MemberTier, LoyaltyPoint, RoleId, IsActive) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPasswordHash());
            ps.setString(4, user.getGoogleId());
            ps.setString(5, user.getPhone());
            ps.setString(6, user.getMemberTier() != null ? user.getMemberTier() : "Standard");
            ps.setInt(7, user.getLoyaltyPoint());
            ps.setInt(8, user.getRole().getRoleId());
            ps.setBoolean(9, user.isActive());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    user.setUserId(rs.getInt(1));
                    return user;
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi tạo user", e);
        }
        throw new DataAccessException("Không lấy được ID sau khi tạo user");
    }

    public void updatePassword(int userId, String passwordHash) {
        String sql = "UPDATE Users SET PasswordHash = ? WHERE UserId = ?";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, passwordHash);
            ps.setInt(2, userId);
            ps.executeUpdate();
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi cập nhật mật khẩu", e);
        }
    }

    /**
     * Cập nhật thông tin profile (FullName, Phone) - không đổi email
     */
    public void updateProfile(int userId, String fullName, String phone) {
        String sql = "UPDATE Users SET FullName = ?, Phone = ? WHERE UserId = ?";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, fullName);
            ps.setString(2, phone != null && !phone.trim().isEmpty() ? phone.trim() : null);
            ps.setInt(3, userId);
            ps.executeUpdate();
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi cập nhật profile", e);
        }
    }

    public void createPasswordResetToken(String token, int userId, java.sql.Timestamp expiresAt) {
        String sql = "INSERT INTO PasswordResetTokens (Token, UserId, ExpiresAt) VALUES (?, ?, ?)";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token);
            ps.setInt(2, userId);
            ps.setTimestamp(3, expiresAt);
            ps.executeUpdate();
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi tạo token reset mật khẩu", e);
        }
    }

    public Optional<Integer> findUserIdByToken(String token) {
        String sql = "SELECT UserId FROM PasswordResetTokens WHERE Token = ? AND ExpiresAt > GETDATE()";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(rs.getInt("UserId"));
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi kiểm tra token", e);
        }
        return Optional.empty();
    }

    public void deleteToken(String token) {
        String sql = "DELETE FROM PasswordResetTokens WHERE Token = ?";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token);
            ps.executeUpdate();
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi xóa token", e);
        }
    }

    public Role getRoleByCode(String roleCode) {
        String sql = "SELECT RoleId, RoleCode, RoleName, Description FROM Roles WHERE RoleCode = ?";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, roleCode);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Role(
                            rs.getInt("RoleId"),
                            rs.getString("RoleCode"),
                            rs.getString("RoleName"),
                            rs.getString("Description")
                    );
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi lấy role", e);
        }
        return null;
    }

    private User mapUser(ResultSet rs) throws SQLException {
        User u = new User();
        u.setUserId(rs.getInt("UserId"));
        u.setFullName(rs.getString("FullName"));
        u.setEmail(rs.getString("Email"));
        u.setPasswordHash(rs.getString("PasswordHash"));
        u.setGoogleId(rs.getString("GoogleId"));
        u.setPhone(rs.getString("Phone"));
        u.setMemberTier(rs.getString("MemberTier"));
        u.setLoyaltyPoint(rs.getInt("LoyaltyPoint"));
        u.setActive(rs.getBoolean("IsActive"));
        Timestamp ts = rs.getTimestamp("CreatedAt");
        u.setCreatedAt(ts != null ? ts.toLocalDateTime() : null);
        Role r = new Role();
        r.setRoleId(rs.getInt("rRoleId"));
        r.setRoleCode(rs.getString("RoleCode"));
        r.setRoleName(rs.getString("RoleName"));
        r.setDescription(rs.getString("Description"));
        u.setRole(r);
        return u;
    }
}
