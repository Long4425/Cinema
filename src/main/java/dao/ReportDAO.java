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

    public List<RevenueRow> getRevenue(LocalDate fromDate, LocalDate toDateInclusive, Integer movieId) {
        LocalDateTime from = fromDate.atStartOfDay();
        LocalDateTime toExclusive = toDateInclusive.plusDays(1).atStartOfDay();

        String sql = "SELECT "
                + "CONVERT(date, p.PaidAt) AS RevenueDate, "
                + "m.Title AS MovieTitle, "
                + "r.RoomName AS RoomName, "
                + "SUM(p.Amount) AS Revenue, "
                + "COUNT(DISTINCT bs.BookingSeatsId) AS Tickets, "
                + "COUNT(DISTINCT s.ShowtimeId) AS ShowCount, "
                + "MAX(r.TotalSeats) AS RoomSeats "
                + "FROM Payments p "
                + "JOIN Bookings b ON p.BookingId = b.BookingId "
                + "JOIN BookingSeats bs ON b.BookingId = bs.BookingId AND bs.Status = 'Confirmed' "
                + "JOIN Showtimes s ON b.ShowtimeId = s.ShowtimeId "
                + "JOIN Movies m ON s.MovieId = m.MovieId "
                + "JOIN Rooms r ON s.RoomId = r.RoomId "
                + "WHERE p.Status = 'Success' "
                + "AND p.PaidAt >= ? AND p.PaidAt < ? "
                + (movieId != null ? "AND m.MovieId = ? " : "")
                + "GROUP BY CONVERT(date, p.PaidAt), m.Title, r.RoomName "
                + "ORDER BY RevenueDate DESC, m.Title";

        List<RevenueRow> rows = new ArrayList<>();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setTimestamp(1, java.sql.Timestamp.valueOf(from));
            ps.setTimestamp(2, java.sql.Timestamp.valueOf(toExclusive));
            if (movieId != null) {
                ps.setInt(3, movieId);
            }
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

