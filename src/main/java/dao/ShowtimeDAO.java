package dao;

import exception.DataAccessException;
import model.Movie;
import model.Room;
import model.Showtime;

import java.sql.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class ShowtimeDAO {
    private final DBContext dbContext = new DBContext();

    public List<Showtime> findByDate(LocalDate date) {
        String sql = "SELECT s.*, m.Title, m.TitleEN, m.PosterUrl, r.RoomName, r.RoomType " +
                     "FROM Showtimes s " +
                     "JOIN Movies m ON s.MovieId = m.MovieId " +
                     "JOIN Rooms r ON s.RoomId = r.RoomId " +
                     "WHERE CAST(s.StartTime AS DATE) = ? " +
                     "ORDER BY s.StartTime ASC";
        List<Showtime> showtimes = new ArrayList<>();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(date));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    showtimes.add(mapShowtime(rs));
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi lấy lịch chiếu theo ngày", e);
        }
        return showtimes;
    }

    public List<Showtime> findByDateGroupByMovie(LocalDate date) {
        String sql = "SELECT s.*, m.Title, m.TitleEN, m.PosterUrl, r.RoomName, r.RoomType " +
                "FROM Showtimes s " +
                "JOIN Movies m ON s.MovieId = m.MovieId " +
                "JOIN Rooms r ON s.RoomId = r.RoomId " +
                "WHERE CAST(s.StartTime AS DATE) = ? " +
                "ORDER BY m.Title ASC, s.StartTime ASC";
        List<Showtime> showtimes = new ArrayList<>();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(date));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    showtimes.add(mapShowtime(rs));
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi lấy lịch chiếu theo ngày (gom nhóm theo phim)", e);
        }
        return showtimes;
    }

    public List<Showtime> findAllGroupByMovie() {
        String sql = "SELECT s.*, m.Title, m.TitleEN, m.PosterUrl, r.RoomName, r.RoomType " +
                "FROM Showtimes s " +
                "JOIN Movies m ON s.MovieId = m.MovieId " +
                "JOIN Rooms r ON s.RoomId = r.RoomId " +
                "ORDER BY m.Title ASC, s.StartTime ASC";
        List<Showtime> showtimes = new ArrayList<>();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                showtimes.add(mapShowtime(rs));
            }
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi lấy toàn bộ lịch chiếu (gom nhóm theo phim)", e);
        }
        return showtimes;
    }

    public List<Showtime> findByDateAndMovie(LocalDate date, int movieId) {
        String sql = "SELECT s.*, m.Title, m.TitleEN, m.PosterUrl, r.RoomName, r.RoomType " +
                "FROM Showtimes s " +
                "JOIN Movies m ON s.MovieId = m.MovieId " +
                "JOIN Rooms r ON s.RoomId = r.RoomId " +
                "WHERE CAST(s.StartTime AS DATE) = ? AND s.MovieId = ? " +
                "ORDER BY s.StartTime ASC";
        List<Showtime> showtimes = new ArrayList<>();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(date));
            ps.setInt(2, movieId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    showtimes.add(mapShowtime(rs));
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi lấy lịch chiếu theo ngày và phim", e);
        }
        return showtimes;
    }

    public List<Showtime> findByMovie(int movieId) {
        String sql = "SELECT s.*, m.Title, m.TitleEN, m.PosterUrl, r.RoomName, r.RoomType " +
                     "FROM Showtimes s " +
                     "JOIN Movies m ON s.MovieId = m.MovieId " +
                     "JOIN Rooms r ON s.RoomId = r.RoomId " +
                     "WHERE s.MovieId = ? AND CAST(s.StartTime AS DATE) = CAST(GETDATE() AS DATE) AND s.StartTime >= GETDATE() " +
                     "ORDER BY s.StartTime ASC";
        List<Showtime> showtimes = new ArrayList<>();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, movieId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    showtimes.add(mapShowtime(rs));
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi lấy lịch chiếu theo phim", e);
        }
        return showtimes;
    }

    public Showtime findById(int id) {
        String sql = "SELECT s.*, m.Title, m.TitleEN, m.PosterUrl, r.RoomName, r.RoomType " +
                     "FROM Showtimes s " +
                     "JOIN Movies m ON s.MovieId = m.MovieId " +
                     "JOIN Rooms r ON s.RoomId = r.RoomId " +
                     "WHERE s.ShowtimeId = ?";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapShowtime(rs);
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi tìm suất chiếu theo ID", e);
        }
        return null;
    }

    public boolean create(Showtime s) {
        if (isOverlapping(s.getRoomId(), s.getStartTime(), s.getEndTime(), 0)) {
            throw new DataAccessException("Phòng đã có lịch chiếu khác trong khoảng thời gian này");
        }
        String sql = "INSERT INTO Showtimes (MovieId, RoomId, StartTime, EndTime, BasePrice, Status) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, s.getMovieId());
            ps.setInt(2, s.getRoomId());
            ps.setTimestamp(3, Timestamp.valueOf(s.getStartTime()));
            ps.setTimestamp(4, Timestamp.valueOf(s.getEndTime()));
            ps.setBigDecimal(5, s.getBasePrice());
            ps.setString(6, s.getStatus());
            return ps.executeUpdate() > 0;
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi tạo suất chiếu", e);
        }
    }

    public boolean update(Showtime s) {
        if (isOverlapping(s.getRoomId(), s.getStartTime(), s.getEndTime(), s.getShowtimeId())) {
            throw new DataAccessException("Phòng đã có lịch chiếu khác trong khoảng thời gian này");
        }
        String sql = "UPDATE Showtimes SET MovieId=?, RoomId=?, StartTime=?, EndTime=?, BasePrice=?, Status=? WHERE ShowtimeId=?";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, s.getMovieId());
            ps.setInt(2, s.getRoomId());
            ps.setTimestamp(3, Timestamp.valueOf(s.getStartTime()));
            ps.setTimestamp(4, Timestamp.valueOf(s.getEndTime()));
            ps.setBigDecimal(5, s.getBasePrice());
            ps.setString(6, s.getStatus());
            ps.setInt(7, s.getShowtimeId());
            return ps.executeUpdate() > 0;
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi cập nhật suất chiếu", e);
        }
    }

    public boolean delete(int id) {
        String sql = "DELETE FROM Showtimes WHERE ShowtimeId = ?";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi xóa suất chiếu", e);
        }
    }

    private boolean isOverlapping(int roomId, LocalDateTime start, LocalDateTime end, int excludeId) {
        String sql = "SELECT COUNT(*) FROM Showtimes " +
                     "WHERE RoomId = ? AND ShowtimeId <> ? " +
                     "AND ((StartTime <= ? AND EndTime > ?) OR (StartTime < ? AND EndTime >= ?) OR (StartTime >= ? AND EndTime <= ?))";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roomId);
            ps.setInt(2, excludeId);
            ps.setTimestamp(3, Timestamp.valueOf(start));
            ps.setTimestamp(4, Timestamp.valueOf(start));
            ps.setTimestamp(5, Timestamp.valueOf(end));
            ps.setTimestamp(6, Timestamp.valueOf(end));
            ps.setTimestamp(7, Timestamp.valueOf(start));
            ps.setTimestamp(8, Timestamp.valueOf(end));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi kiểm tra trùng lịch", e);
        }
        return false;
    }

    private Showtime mapShowtime(ResultSet rs) throws SQLException {
        Showtime s = new Showtime();
        s.setShowtimeId(rs.getInt("ShowtimeId"));
        s.setMovieId(rs.getInt("MovieId"));
        s.setRoomId(rs.getInt("RoomId"));
        s.setStartTime(rs.getTimestamp("StartTime").toLocalDateTime());
        s.setEndTime(rs.getTimestamp("EndTime").toLocalDateTime());
        s.setBasePrice(rs.getBigDecimal("BasePrice"));
        s.setStatus(rs.getString("Status"));

        Movie m = new Movie();
        m.setTitle(rs.getString("Title"));
        m.setTitleEN(rs.getString("TitleEN"));
        m.setPosterUrl(rs.getString("PosterUrl"));
        s.setMovie(m);

        Room r = new Room();
        r.setRoomId(rs.getInt("RoomId"));
        r.setRoomName(rs.getString("RoomName"));
        r.setRoomType(rs.getString("RoomType"));
        s.setRoom(r);

        return s;
    }
}
