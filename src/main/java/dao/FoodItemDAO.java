package dao;

import exception.DataAccessException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.FoodItem;

public class FoodItemDAO {

    private final DBContext dbContext = new DBContext();

    public List<FoodItem> findAvailable() {
        String sql = "SELECT * FROM FoodItems WHERE IsAvailable = 1 ORDER BY Name ASC";
        List<FoodItem> list = new ArrayList<>();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(map(rs));
            }
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi lấy danh sách đồ ăn đang bán", e);
        }
        return list;
    }

    public FoodItem findById(int id) {
        String sql = "SELECT * FROM FoodItems WHERE FoodItemId = ?";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return map(rs);
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            throw new DataAccessException("Lỗi tìm đồ ăn theo ID", e);
        }
        return null;
    }

    private FoodItem map(ResultSet rs) throws SQLException {
        FoodItem f = new FoodItem();
        f.setFoodItemId(rs.getInt("FoodItemId"));
        f.setName(rs.getString("Name"));
        f.setDescription(rs.getString("Description"));
        f.setPrice(rs.getBigDecimal("Price"));
        f.setImageUrl(rs.getString("ImageUrl"));
        f.setAvailable(rs.getBoolean("IsAvailable"));
        return f;
    }
}

