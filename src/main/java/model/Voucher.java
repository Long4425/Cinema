package model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class Voucher {
    private int voucherId;
    private String code;
    private String discountType;     // Percent / FixedAmount
    private BigDecimal discountValue;
    private BigDecimal minOrderValue;
    private int maxUsage;
    private int usedCount;
    private LocalDateTime startAt;   // NULL = áp dụng ngay; có giá trị = Flash Sale bắt đầu từ thời điểm này
    private LocalDateTime expiredAt;
    private boolean active;
    private Integer createdBy;
    private Integer ownedByUserId; // NULL = công khai, có giá trị = voucher cá nhân đổi từ điểm

    public int getVoucherId() {
        return voucherId;
    }

    public void setVoucherId(int voucherId) {
        this.voucherId = voucherId;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getDiscountType() {
        return discountType;
    }

    public void setDiscountType(String discountType) {
        this.discountType = discountType;
    }

    public BigDecimal getDiscountValue() {
        return discountValue;
    }

    public void setDiscountValue(BigDecimal discountValue) {
        this.discountValue = discountValue;
    }

    public BigDecimal getMinOrderValue() {
        return minOrderValue;
    }

    public void setMinOrderValue(BigDecimal minOrderValue) {
        this.minOrderValue = minOrderValue;
    }

    public int getMaxUsage() {
        return maxUsage;
    }

    public void setMaxUsage(int maxUsage) {
        this.maxUsage = maxUsage;
    }

    public int getUsedCount() {
        return usedCount;
    }

    public void setUsedCount(int usedCount) {
        this.usedCount = usedCount;
    }

    public LocalDateTime getStartAt() {
        return startAt;
    }

    public void setStartAt(LocalDateTime startAt) {
        this.startAt = startAt;
    }

    public LocalDateTime getExpiredAt() {
        return expiredAt;
    }

    public void setExpiredAt(LocalDateTime expiredAt) {
        this.expiredAt = expiredAt;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public Integer getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(Integer createdBy) {
        this.createdBy = createdBy;
    }

    public Integer getOwnedByUserId() {
        return ownedByUserId;
    }

    public void setOwnedByUserId(Integer ownedByUserId) {
        this.ownedByUserId = ownedByUserId;
    }
}

