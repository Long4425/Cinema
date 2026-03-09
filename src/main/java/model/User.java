package model;

import java.time.LocalDateTime;

/**
 * Model User - Khách hàng & nhân viên
 */
public class User {
    private int userId;
    private String fullName;
    private String email;
    private String passwordHash;
    private String googleId;
    private String phone;
    private String memberTier;
    private int loyaltyPoint;
    private Role role;
    private boolean isActive;
    private LocalDateTime createdAt;

    public User() {
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    public String getGoogleId() {
        return googleId;
    }

    public void setGoogleId(String googleId) {
        this.googleId = googleId;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getMemberTier() {
        return memberTier;
    }

    public void setMemberTier(String memberTier) {
        this.memberTier = memberTier;
    }

    public int getLoyaltyPoint() {
        return loyaltyPoint;
    }

    public void setLoyaltyPoint(int loyaltyPoint) {
        this.loyaltyPoint = loyaltyPoint;
    }

    public Role getRole() {
        return role;
    }

    public void setRole(Role role) {
        this.role = role;
    }

    public boolean isActive() {
        return isActive;
    }

    public void setActive(boolean active) {
        isActive = active;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    /**
     * Kiểm tra user có mật khẩu (không phải tài khoản Google)
     */
    public boolean isHasPassword() {
        return passwordHash != null && !passwordHash.isEmpty();
    }

    /**
     * Kiểm tra user đăng nhập bằng Google
     */
    public boolean isGoogleUser() {
        return googleId != null && !googleId.isEmpty();
    }
}
