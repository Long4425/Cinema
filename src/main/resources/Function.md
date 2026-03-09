
### 👥 Danh sách Actor (Người dùng/Hệ thống)
*   **Customer** (Khách hàng): Đặt vé online hoặc trực tiếp tại quầy.
*   **Cashier** (Thu ngân): Thao tác POS, xử lý thanh toán tiền mặt, soát vé.
*   **Cinema Manager** (Quản lý rạp): Quản lý phim, lịch chiếu, giá vé, phê duyệt hoàn vé, xem báo cáo.
*   **System Admin** (Admin hệ thống): Quản lý tài khoản nhân viên, phân quyền, audit log.
*   **Payment Gateway** (Hệ thống thanh toán): Xử lý giao dịch VNPay, callback, hoàn tiền.

---

### F1. Account Management (Quản lý tài khoản)
*   **UC-01 | Register account**
    *   Actor: Customer
    *   Mô tả: Khách hàng tạo tài khoản qua form đăng ký hoặc đăng nhập bằng Google.
*   **UC-02 | Login**
    *   Actor: Customer, Cashier, Cinema Manager, System Admin
    *   Mô tả: Đăng nhập bằng email/mật khẩu hoặc Google OAuth.
*   **UC-03 | Forgot password**
    *   Actor: Customer, Cashier, Cinema Manager, System Admin
    *   Mô tả: Gửi link đặt lại mật khẩu qua email, thiết lập mật khẩu mới.

### F2. Movie & Showtime Management (Quản lý phim & Lịch chiếu)
*   **UC-04 | View movie list**
    *   Actor: Customer, Cashier, Cinema Manager, System Admin
    *   Mô tả: Hiển thị danh sách phim với chức năng tìm kiếm và lọc theo thể loại/ngôn ngữ/độ tuổi.
*   **UC-05 | View movie detail**
    *   Actor: Customer, Cashier, Cinema Manager, System Admin
    *   Mô tả: Xem trailer, mô tả chi tiết, đánh giá và phân loại độ tuổi của phim.
*   **UC-06 | View showtimes**
    *   Actor: Customer, Cashier, Cinema Manager, System Admin
    *   Mô tả: Lọc lịch chiếu theo ngày, rạp, loại phòng (2D/3D/IMAX).
*   **UC-07 | Manage movies**
    *   Actor: Cinema Manager
    *   Mô tả: Thêm/sửa/xóa phim, tải lên poster, trailer, phân loại độ tuổi.
*   **UC-08 | Manage showtimes**
    *   Actor: Cinema Manager
    *   Mô tả: Xếp lịch chiếu vào phòng, đảm bảo không bị trùng lịch.

### F3. Room & Seat Map Management (Quản lý phòng & Sơ đồ ghế)
*   **UC-09 | Manage screening rooms**
    *   Actor: Cinema Manager
    *   Mô tả: Cấu hình loại phòng (2D/3D/IMAX), sức chứa, trang thiết bị.
*   **UC-10 | Configure seat map**
    *   Actor: Cinema Manager
    *   Mô tả: Định nghĩa các loại ghế (thường/VIP/couple) và vị trí trong phòng.

### F4. Booking (Đặt vé)
*   **UC-11 | Select showtime**
    *   Actor: Customer, Cashier
    *   Mô tả: Chọn ngày, giờ, loại phòng; kiểm tra tình trạng ghế trống.
*   **UC-12 | Select seats**
    *   Actor: Customer, Cashier
    *   Mô tả: Hiển thị sơ đồ ghế thời gian thực, chọn tối đa 8 ghế, ghế được giữ tạm trong quá trình đặt.
*   **UC-13 | Select food & drink combo**
    *   Actor: Customer, Cashier
    *   Mô tả: Thêm bắp/nước/combo vào đơn hàng, có thể bỏ qua bước này.
*   **UC-14 | Apply voucher**
    *   Actor: Customer, Cashier
    *   Mô tả: Nhập mã voucher, hệ thống kiểm tra điều kiện và áp dụng giảm giá.

### F5. Payment (Thanh toán)
*   **UC-15 | Online payment**
    *   Actor: Customer, Payment Gateway
    *   Mô tả: Thanh toán qua VNPay; ghế được giữ trong 10 phút chờ xác nhận.
*   **UC-16 | Counter payment**
    *   Actor: Cashier, Payment Gateway
    *   Mô tả: Thu ngân thu tiền mặt; xác nhận thủ công sau khi nhận đủ tiền.
*   **UC-17 | Handle payment failure**
    *   Actor: Customer, Cashier, Payment Gateway
    *   Mô tả: Tự động nhả ghế nếu hết thời gian chờ hoặc giao dịch thất bại.

### F6. Ticketing & Check-in (Xuất vé & Soát vé)
*   **UC-18 | View ticket after payment**
    *   Actor: Customer
    *   Mô tả: Hiển thị vé trên màn hình sau khi thanh toán online thành công.
*   **UC-19 | Confirm & hand over paper ticket**
    *   Actor: Cashier
    *   Mô tả: Thu ngân xác nhận đã nhận tiền mặt và in vé giấy giao cho khách.
*   **UC-20 | Ticket check-in**
    *   Actor: Cashier
    *   Mô tả: Tra cứu vé theo tên/mã đơn, xác nhận tính hợp lệ trước giờ chiếu.

### F7. Booking Management (Quản lý đặt chỗ)
*   **UC-21 | View booking history**
    *   Actor: Customer
    *   Mô tả: Xem danh sách đơn hàng cũ, trạng thái đơn, truy xuất lại vé.
*   **UC-22 | Cancel ticket & refund**
    *   Actor: Customer, Cashier, Cinema Manager
    *   Mô tả: Hủy vé trước giờ chiếu; đơn Online hoàn tiền qua VNPay, đơn tại quầy cần Cinema Manager phê duyệt và hoàn tiền mặt.
*   **UC-23 | Exchange ticket / change showtime**
    *   Actor: Customer, Cashier
    *   Mô tả: Đổi sang suất chiếu khác, phụ thu nếu có chênh lệch giá.

### F8. Membership & Loyalty Points (Thành viên & Tích điểm)
*   **UC-24 | Earn points after transaction**
    *   Actor: Customer
    *   Mô tả: Tự động cộng điểm sau mỗi lần đặt vé thành công.
*   **UC-25 | Redeem points for ticket / voucher**
    *   Actor: Customer
    *   Mô tả: Dùng điểm tích lũy để đổi vé hoặc mã giảm giá.

### F9. Pricing & Promotions (Giá vé & Khuyến mãi)
*   **UC-26 | Configure ticket pricing**
    *   Actor: Cinema Manager
    *   Mô tả: Thiết lập giá theo loại ghế, khung giờ, ngày thường/cuối tuần.
*   **UC-27 | Create promotion**
    *   Actor: Cinema Manager
    *   Mô tả: Tạo chương trình flash sale, combo, voucher với các điều kiện áp dụng.

### F10. Reports & Analytics (Báo cáo & Phân tích)
*   **UC-28 | View revenue report**
    *   Actor: Cinema Manager, System Admin
    *   Mô tả: Xem doanh thu theo ngày/phim/rạp, tỷ lệ lấp đầy ghế.
*   **UC-29 | Export report**
    *   Actor: Cinema Manager, System Admin
    *   Mô tả: Xuất báo cáo Excel/PDF cho khoảng thời gian đã chọn.

### F11. User & Permission Management (Quản lý người dùng & Phân quyền)
*   **UC-30 | Manage staff accounts**
    *   Actor: System Admin
    *   Mô tả: Tạo/vô hiệu hóa tài khoản cho thu ngân và quản lý.
*   **UC-31 | Role-based access control**
    *   Actor: System Admin
    *   Mô tả: Phân quyền truy cập theo vai trò (RBAC), xem nhật ký hoạt động (audit log).