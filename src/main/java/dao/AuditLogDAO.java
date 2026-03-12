package dao;

import exception.DataAccessException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import model.AuditLog;

public class AuditLogDAO {

    private final DBContext dbContext = new DBContext();

    public void log(Integer userId, String action, String targetTable, Integer targetId, String detail) {
        String sql = "INSERT INTO AuditLogs (UserId, Action, TargetTable, TargetId, Detail) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (userId != null) {
                ps.setInt(1, userId);
            } else {
                ps.setNull(1, java.sql.Types.INTEGER);
            }
            ps.setString(2, action);
            ps.setString(3, targetTable);
            if (targetId != null) {
                ps.setInt(4, targetId);
            } else {
                ps.setNull(4, java.sql.Types.INTEGER);
            }
            ps.setString(5, detail);
            ps.executeUpdate();
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi ghi audit log", e);
        }
    }

    public List<AuditLog> findByDateRangeAndAction(LocalDate from, LocalDate toInclusive, String actionFilter) {
        String sql = "SELECT * FROM AuditLogs WHERE CreatedAt >= ? AND CreatedAt < ? "
                + (actionFilter != null && !actionFilter.isBlank() ? "AND Action = ? " : "")
                + "ORDER BY LogId DESC";
        List<AuditLog> list = new ArrayList<>();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            java.time.LocalDateTime fromDt = from.atStartOfDay();
            java.time.LocalDateTime toExclusive = toInclusive.plusDays(1).atStartOfDay();
            ps.setTimestamp(1, java.sql.Timestamp.valueOf(fromDt));
            ps.setTimestamp(2, java.sql.Timestamp.valueOf(toExclusive));
            if (actionFilter != null && !actionFilter.isBlank()) {
                ps.setString(3, actionFilter);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    AuditLog log = new AuditLog();
                    log.setLogId(rs.getInt("LogId"));
                    int uid = rs.getInt("UserId");
                    log.setUserId(rs.wasNull() ? null : uid);
                    log.setAction(rs.getString("Action"));
                    log.setTargetTable(rs.getString("TargetTable"));
                    int tid = rs.getInt("TargetId");
                    log.setTargetId(rs.wasNull() ? null : tid);
                    log.setDetail(rs.getString("Detail"));
                    java.sql.Timestamp ts = rs.getTimestamp("CreatedAt");
                    log.setCreatedAt(ts != null ? ts.toLocalDateTime() : null);
                    list.add(log);
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi đọc audit log", e);
        }
        return list;
    }
}

