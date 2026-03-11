package model;

import java.math.BigDecimal;
import java.time.LocalDate;

public class RevenueRow {
    private LocalDate date;
    private String movieTitle;
    private String roomName;
    private BigDecimal revenue;
    private int tickets;
    private int showCount;
    private int roomSeats;

    public LocalDate getDate() {
        return date;
    }

    public void setDate(LocalDate date) {
        this.date = date;
    }

    public String getMovieTitle() {
        return movieTitle;
    }

    public void setMovieTitle(String movieTitle) {
        this.movieTitle = movieTitle;
    }

    public String getRoomName() {
        return roomName;
    }

    public void setRoomName(String roomName) {
        this.roomName = roomName;
    }

    public BigDecimal getRevenue() {
        return revenue;
    }

    public void setRevenue(BigDecimal revenue) {
        this.revenue = revenue;
    }

    public int getTickets() {
        return tickets;
    }

    public void setTickets(int tickets) {
        this.tickets = tickets;
    }

    public int getShowCount() {
        return showCount;
    }

    public void setShowCount(int showCount) {
        this.showCount = showCount;
    }

    public int getRoomSeats() {
        return roomSeats;
    }

    public void setRoomSeats(int roomSeats) {
        this.roomSeats = roomSeats;
    }

    public double getOccupancyRate() {
        int denom = roomSeats * showCount;
        if (denom <= 0) {
            return 0.0;
        }
        return (double) tickets / (double) denom;
    }
}

