package dao;

import exception.DataAccessException;
import model.Movie;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class MovieDAO {

    private final DBContext dbContext = new DBContext();

    /**
     * Lấy danh sách phim đang chiếu (Status = 'NowShowing')
     * giới hạn số lượng trả về theo tham số limit.
     */
    public List<Movie> findNowShowing(int limit) {
        String sql = "SELECT MovieId, Title, TitleEN, Description, Genre, Language, AgeRating, " +
                "DurationMins, PosterUrl, TrailerUrl, Status, CreatedBy, CreatedAt " +
                "FROM Movies " +
                "WHERE Status = 'NowShowing' " +
                "ORDER BY CreatedAt DESC " +
                "OFFSET 0 ROWS FETCH NEXT ? ROWS ONLY";

        List<Movie> movies = new ArrayList<>();

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, limit);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    movies.add(mapMovie(rs));
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi lấy danh sách phim đang chiếu", e);
        }

        return movies;
    }

    public Movie findById(int id) {
        String sql = "SELECT * FROM Movies WHERE MovieId = ?";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapMovie(rs);
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi tìm phim theo ID", e);
        }
        return null;
    }

    public List<Movie> findAll() {
        String sql = "SELECT * FROM Movies ORDER BY CreatedAt DESC";
        List<Movie> movies = new ArrayList<>();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                movies.add(mapMovie(rs));
            }
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi lấy toàn bộ danh sách phim", e);
        }
        return movies;
    }

    public List<Movie> search(String query, String genre, String language, String ageRating) {
        StringBuilder sql = new StringBuilder("SELECT * FROM Movies WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (query != null && !query.trim().isEmpty()) {
            sql.append(" AND (Title LIKE ? OR TitleEN LIKE ?)");
            params.add("%" + query.trim() + "%");
            params.add("%" + query.trim() + "%");
        }
        if (genre != null && !genre.trim().isEmpty()) {
            sql.append(" AND Genre LIKE ?");
            params.add("%" + genre.trim() + "%");
        }
        if (language != null && !language.trim().isEmpty()) {
            sql.append(" AND Language = ?");
            params.add(language);
        }
        if (ageRating != null && !ageRating.trim().isEmpty()) {
            sql.append(" AND AgeRating = ?");
            params.add(ageRating);
        }

        sql.append(" ORDER BY CreatedAt DESC");

        List<Movie> movies = new ArrayList<>();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    movies.add(mapMovie(rs));
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi tìm kiếm phim", e);
        }
        return movies;
    }

    public boolean create(Movie movie) {
        String sql = "INSERT INTO Movies (Title, TitleEN, Description, Genre, Language, AgeRating, DurationMins, PosterUrl, TrailerUrl, Status, CreatedBy) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, movie.getTitle());
            ps.setString(2, movie.getTitleEN());
            ps.setString(3, movie.getDescription());
            ps.setString(4, movie.getGenre());
            ps.setString(5, movie.getLanguage());
            ps.setString(6, movie.getAgeRating());
            ps.setInt(7, movie.getDurationMins());
            ps.setString(8, movie.getPosterUrl());
            ps.setString(9, movie.getTrailerUrl());
            ps.setString(10, movie.getStatus());
            if (movie.getCreatedBy() != null) ps.setInt(11, movie.getCreatedBy()); else ps.setNull(11, java.sql.Types.INTEGER);

            return ps.executeUpdate() > 0;
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi thêm phim mới", e);
        }
    }

    public boolean update(Movie movie) {
        String sql = "UPDATE Movies SET Title=?, TitleEN=?, Description=?, Genre=?, Language=?, AgeRating=?, DurationMins=?, PosterUrl=?, TrailerUrl=?, Status=? WHERE MovieId=?";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, movie.getTitle());
            ps.setString(2, movie.getTitleEN());
            ps.setString(3, movie.getDescription());
            ps.setString(4, movie.getGenre());
            ps.setString(5, movie.getLanguage());
            ps.setString(6, movie.getAgeRating());
            ps.setInt(7, movie.getDurationMins());
            ps.setString(8, movie.getPosterUrl());
            ps.setString(9, movie.getTrailerUrl());
            ps.setString(10, movie.getStatus());
            ps.setInt(11, movie.getMovieId());

            return ps.executeUpdate() > 0;
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi cập nhật phim", e);
        }
    }

    public boolean delete(int id) {
        String sql = "DELETE FROM Movies WHERE MovieId = ?";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi xóa phim", e);
        }
    }

    private Movie mapMovie(ResultSet rs) throws SQLException {
        Movie m = new Movie();
        m.setMovieId(rs.getInt("MovieId"));
        m.setTitle(rs.getString("Title"));
        m.setTitleEN(rs.getString("TitleEN"));
        m.setDescription(rs.getString("Description"));
        m.setGenre(rs.getString("Genre"));
        m.setLanguage(rs.getString("Language"));
        m.setAgeRating(rs.getString("AgeRating"));
        m.setDurationMins(rs.getInt("DurationMins"));
        m.setPosterUrl(rs.getString("PosterUrl"));
        m.setTrailerUrl(rs.getString("TrailerUrl"));
        m.setStatus(rs.getString("Status"));
        int createdBy = rs.getInt("CreatedBy");
        m.setCreatedBy(rs.wasNull() ? null : createdBy);
        Timestamp ts = rs.getTimestamp("CreatedAt");
        m.setCreatedAt(ts != null ? ts.toLocalDateTime() : null);
        return m;
    }
}


