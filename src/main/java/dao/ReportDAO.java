package dao;

import exception.DataAccessException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import model.RevenueRow;

public class ReportDAO {

    private final DBContext dbContext = new DBContext();

    public List<RevenueRow> getRevenue(LocalDate fromDate, LocalDate toDateInclusive, Integer movieId, Integer roomId) {
        LocalDateTime from = fromDate.atStartOfDay();
        LocalDateTime toExclusive = toDateInclusive.plusDays(1).atStartOfDay();

        // Tách riêng 2 tập:
        //   pay_agg: tổng doanh thu theo (ngày, phim, phòng) — chỉ tính 1 lần mỗi payment
        //   seat_agg: đếm vé + suất chiếu — tính từ BookingSeats
        // Tránh fan-out khi JOIN Payments ↔ BookingSeats (1 payment nhiều ghế → SUM bị nhân bội)
        String sql = "SELECT "
                + "  base.RevenueDate, "
                + "  base.MovieTitle, "
                + "  base.RoomName, "
                + "  base.Revenue, "
                + "  base.ShowCount, "
                + "  base.RoomSeats, "
                + "  ISNULL(sa.Tickets, 0) AS Tickets "
                + "FROM ( "
                + "  SELECT "
                + "    CONVERT(date, p.PaidAt) AS RevenueDate, "
                + "    m.Title AS MovieTitle, "
                + "    r.RoomName AS RoomName, "
                + "    SUM(p.Amount) AS Revenue, "
                + "    COUNT(DISTINCT b.ShowtimeId) AS ShowCount, "
                + "    MAX(r.TotalSeats) AS RoomSeats "
                + "  FROM Payments p "
                + "  JOIN Bookings b ON p.BookingId = b.BookingId "
                + "  JOIN Showtimes s ON b.ShowtimeId = s.ShowtimeId "
                + "  JOIN Movies m ON s.MovieId = m.MovieId "
                + "  JOIN Rooms r ON s.RoomId = r.RoomId "
                + "  WHERE p.Status = 'Success' "
                + "  AND p.PaidAt >= ? AND p.PaidAt < ? "
                + (movieId != null ? "  AND m.MovieId = ? " : "")
                + (roomId != null ? "  AND r.RoomId = ? " : "")
                + "  GROUP BY CONVERT(date, p.PaidAt), m.Title, r.RoomName, r.RoomId "
                + ") base "
                + "LEFT JOIN ( "
                + "  SELECT "
                + "    CONVERT(date, p2.PaidAt) AS RevenueDate, "
                + "    m2.Title AS MovieTitle, "
                + "    r2.RoomName AS RoomName, "
                + "    COUNT(bs.BookingSeatsId) AS Tickets "
                + "  FROM BookingSeats bs "
                + "  JOIN Bookings b2 ON bs.BookingId = b2.BookingId "
                + "  JOIN Payments p2 ON p2.BookingId = b2.BookingId AND p2.Status = 'Success' "
                + "  JOIN Showtimes s2 ON b2.ShowtimeId = s2.ShowtimeId "
                + "  JOIN Movies m2 ON s2.MovieId = m2.MovieId "
                + "  JOIN Rooms r2 ON s2.RoomId = r2.RoomId "
                + "  WHERE bs.Status = 'Confirmed' "
                + "  AND p2.PaidAt >= ? AND p2.PaidAt < ? "
                + (movieId != null ? "  AND m2.MovieId = ? " : "")
                + (roomId != null ? "  AND r2.RoomId = ? " : "")
                + "  GROUP BY CONVERT(date, p2.PaidAt), m2.Title, r2.RoomName "
                + ") sa ON sa.RevenueDate = base.RevenueDate "
                + "      AND sa.MovieTitle = base.MovieTitle "
                + "      AND sa.RoomName = base.RoomName "
                + "ORDER BY base.RevenueDate DESC, base.MovieTitle";

        List<RevenueRow> rows = new ArrayList<>();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            int idx = 1;
            // params cho subquery pay_agg
            ps.setTimestamp(idx++, java.sql.Timestamp.valueOf(from));
            ps.setTimestamp(idx++, java.sql.Timestamp.valueOf(toExclusive));
            if (movieId != null) ps.setInt(idx++, movieId);
            if (roomId != null) ps.setInt(idx++, roomId);
            // params cho subquery seat_agg (lặp lại)
            ps.setTimestamp(idx++, java.sql.Timestamp.valueOf(from));
            ps.setTimestamp(idx++, java.sql.Timestamp.valueOf(toExclusive));
            if (movieId != null) ps.setInt(idx++, movieId);
            if (roomId != null) ps.setInt(idx++, roomId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    RevenueRow r = new RevenueRow();
                    java.sql.Date d = rs.getDate("RevenueDate");
                    r.setDate(d != null ? d.toLocalDate() : null);
                    r.setMovieTitle(rs.getString("MovieTitle"));
                    r.setRoomName(rs.getString("RoomName"));
                    r.setRevenue(rs.getBigDecimal("Revenue"));
                    r.setTickets(rs.getInt("Tickets"));
                    r.setShowCount(rs.getInt("ShowCount"));
                    r.setRoomSeats(rs.getInt("RoomSeats"));
                    rows.add(r);
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi lấy báo cáo doanh thu", e);
        }
        return rows;
    }
}

