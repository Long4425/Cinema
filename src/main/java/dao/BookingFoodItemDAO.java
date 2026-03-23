package dao;

import exception.DataAccessException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import model.BookingFoodItem;
import model.FoodItem;

public class BookingFoodItemDAO {

    private final DBContext dbContext = new DBContext();

    public void createBatch(List<BookingFoodItem> items) {
        if (items == null || items.isEmpty()) {
            return;
        }
        String sql = "INSERT INTO BookingFoodItems (BookingId, FoodItemId, Quantity, UnitPrice) "
                + "VALUES (?, ?, ?, ?)";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            for (BookingFoodItem i : items) {
                ps.setInt(1, i.getBookingId());
                ps.setInt(2, i.getFoodItemId());
                ps.setInt(3, i.getQuantity());
                ps.setBigDecimal(4, i.getUnitPrice());
                ps.addBatch();
            }
            ps.executeBatch();
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi lưu đồ ăn trong booking", e);
        }
    }

    public void deleteByBooking(int bookingId) {
        String sql = "DELETE FROM BookingFoodItems WHERE BookingId = ?";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookingId);
            ps.executeUpdate();
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi xóa đồ ăn của booking", e);
        }
    }

    public List<BookingFoodItem> findByBookingWithFood(int bookingId) {
        String sql = "SELECT bfi.*, f.Name, f.Description, f.Price "
                + "FROM BookingFoodItems bfi "
                + "JOIN FoodItems f ON bfi.FoodItemId = f.FoodItemId "
                + "WHERE bfi.BookingId = ? "
                + "ORDER BY f.Name";
        List<BookingFoodItem> list = new ArrayList<>();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BookingFoodItem item = new BookingFoodItem();
                    item.setBookingFoodId(rs.getInt("BookingFoodId"));
                    item.setBookingId(rs.getInt("BookingId"));
                    item.setFoodItemId(rs.getInt("FoodItemId"));
                    item.setQuantity(rs.getInt("Quantity"));
                    item.setUnitPrice(rs.getBigDecimal("UnitPrice"));

                    FoodItem food = new FoodItem();
                    food.setFoodItemId(rs.getInt("FoodItemId"));
                    food.setName(rs.getString("Name"));
                    food.setDescription(rs.getString("Description"));
                    food.setPrice(rs.getBigDecimal("Price"));
                    item.setFoodItem(food);

                    list.add(item);
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi lấy đồ ăn theo booking", e);
        }
        return list;
    }
}

