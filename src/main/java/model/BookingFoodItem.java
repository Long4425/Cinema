package model;

import java.math.BigDecimal;

public class BookingFoodItem {
    private int bookingFoodId;
    private int bookingId;
    private int foodItemId;
    private int quantity;
    private BigDecimal unitPrice;

    private FoodItem foodItem;

    public int getBookingFoodId() {
        return bookingFoodId;
    }

    public void setBookingFoodId(int bookingFoodId) {
        this.bookingFoodId = bookingFoodId;
    }

    public int getBookingId() {
        return bookingId;
    }

    public void setBookingId(int bookingId) {
        this.bookingId = bookingId;
    }

    public int getFoodItemId() {
        return foodItemId;
    }

    public void setFoodItemId(int foodItemId) {
        this.foodItemId = foodItemId;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public BigDecimal getUnitPrice() {
        return unitPrice;
    }

    public void setUnitPrice(BigDecimal unitPrice) {
        this.unitPrice = unitPrice;
    }

    public FoodItem getFoodItem() {
        return foodItem;
    }

    public void setFoodItem(FoodItem foodItem) {
        this.foodItem = foodItem;
    }
}

