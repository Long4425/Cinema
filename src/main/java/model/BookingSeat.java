package model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class BookingSeat {
    private int bookingSeatsId;
    private int bookingId;
    private int seatId;
    private int showtimeId;
    private BigDecimal seatPrice;
    private String status;       // Held / Confirmed / Cancelled
    private LocalDateTime heldUntil;

    // Optional joins
    private Seat seat;

    public int getBookingSeatsId() {
        return bookingSeatsId;
    }

    public void setBookingSeatsId(int bookingSeatsId) {
        this.bookingSeatsId = bookingSeatsId;
    }

    public int getBookingId() {
        return bookingId;
    }

    public void setBookingId(int bookingId) {
        this.bookingId = bookingId;
    }

    public int getSeatId() {
        return seatId;
    }

    public void setSeatId(int seatId) {
        this.seatId = seatId;
    }

    public int getShowtimeId() {
        return showtimeId;
    }

    public void setShowtimeId(int showtimeId) {
        this.showtimeId = showtimeId;
    }

    public BigDecimal getSeatPrice() {
        return seatPrice;
    }

    public void setSeatPrice(BigDecimal seatPrice) {
        this.seatPrice = seatPrice;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LocalDateTime getHeldUntil() {
        return heldUntil;
    }

    public void setHeldUntil(LocalDateTime heldUntil) {
        this.heldUntil = heldUntil;
    }

    public Seat getSeat() {
        return seat;
    }

    public void setSeat(Seat seat) {
        this.seat = seat;
    }
}

