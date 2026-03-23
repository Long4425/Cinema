IF EXISTS (SELECT name FROM sys.databases WHERE name = 'CinemaDB')
    DROP DATABASE CinemaDB;

CREATE DATABASE CinemaDB;
GO

USE CinemaDB;
GO

IF OBJECT_ID('AuditLogs', 'U') IS NOT NULL DROP TABLE AuditLogs;
IF OBJECT_ID('Payments', 'U') IS NOT NULL DROP TABLE Payments;
IF OBJECT_ID('BookingFoodItems', 'U') IS NOT NULL DROP TABLE BookingFoodItems;
IF OBJECT_ID('BookingSeats', 'U') IS NOT NULL DROP TABLE BookingSeats;
IF OBJECT_ID('Bookings', 'U') IS NOT NULL DROP TABLE Bookings;
IF OBJECT_ID('FoodItems', 'U') IS NOT NULL DROP TABLE FoodItems;
IF OBJECT_ID('Vouchers', 'U') IS NOT NULL DROP TABLE Vouchers;
IF OBJECT_ID('Showtimes', 'U') IS NOT NULL DROP TABLE Showtimes;
IF OBJECT_ID('Seats', 'U') IS NOT NULL DROP TABLE Seats;
IF OBJECT_ID('Rooms', 'U') IS NOT NULL DROP TABLE Rooms;
IF OBJECT_ID('Movies', 'U') IS NOT NULL DROP TABLE Movies;
IF OBJECT_ID('PasswordResetTokens', 'U') IS NOT NULL DROP TABLE PasswordResetTokens;
IF OBJECT_ID('Users', 'U') IS NOT NULL DROP TABLE Users;
IF OBJECT_ID('Roles', 'U') IS NOT NULL DROP TABLE Roles;


-- 1. ROLES (Vai trò người dùng & nhân viên)
CREATE TABLE Roles (
    RoleId      INT PRIMARY KEY IDENTITY,
    RoleCode    VARCHAR(50) NOT NULL UNIQUE,  -- CUSTOMER / CASHIER / MANAGER / ADMIN ...
    RoleName    NVARCHAR(100) NOT NULL,
    Description NVARCHAR(255) NULL
);

INSERT INTO Roles (RoleCode, RoleName, Description) VALUES
('CUSTOMER', N'Khách hàng', N'Đặt vé online hoặc tại quầy'),
('CASHIER', N'Thu ngân', N'POS, thanh toán, soát vé'),
('MANAGER', N'Quản lý rạp', N'Quản lý phim, lịch chiếu, phê duyệt'),
('ADMIN', N'Quản trị hệ thống', N'Quản lý tài khoản, phân quyền');

-- 2. USERS (Gộp khách hàng & nhân viên)
CREATE TABLE Users (
    UserId        INT PRIMARY KEY IDENTITY,
    FullName      NVARCHAR(100) NOT NULL,
    Email         VARCHAR(150) NOT NULL UNIQUE,
    PasswordHash  VARCHAR(255) NULL,          -- NULL nếu đăng nhập Google
    GoogleId      VARCHAR(100) NULL,
    Phone         VARCHAR(20) NULL,
    MemberTier    VARCHAR(20) DEFAULT 'Standard', -- Standard / Silver / Gold / Diamond (áp dụng cho CUSTOMER)
    LoyaltyPoint  INT DEFAULT 0,
    RoleId        INT NOT NULL REFERENCES Roles(RoleId),
    IsActive      BIT DEFAULT 1,
    CreatedAt     DATETIME DEFAULT GETDATE()
);

-- 3. MOVIES (Phim)
CREATE TABLE Movies (
    MovieId       INT PRIMARY KEY IDENTITY,
    Title         NVARCHAR(200) NOT NULL,
    TitleEN       NVARCHAR(200) NULL,
    Description   NVARCHAR(MAX) NULL,
    Genre         NVARCHAR(100) NULL,         -- Action, Comedy, ...
    Language      NVARCHAR(50) NULL,          -- Vietnamese / English / Subtitled
    AgeRating     VARCHAR(10) NULL,           -- P / C13 / C16 / C18
    DurationMins  INT NOT NULL,
    PosterUrl     VARCHAR(500) NULL,
    TrailerUrl    VARCHAR(500) NULL,
    Status        VARCHAR(20) DEFAULT 'NowShowing', -- ComingSoon / NowShowing / Ended
    CreatedBy     INT REFERENCES Users(UserId),
    CreatedAt     DATETIME DEFAULT GETDATE()
);

-- 4. ROOMS (Phòng chiếu)
CREATE TABLE Rooms (
    RoomId        INT PRIMARY KEY IDENTITY,
    RoomName      NVARCHAR(50) NOT NULL,
    RoomType      VARCHAR(20) NOT NULL,       -- 2D / 3D / IMAX
    TotalSeats    INT NOT NULL,
    IsActive      BIT DEFAULT 1
);

-- 5. SEATS (Ghế — định nghĩa cố định theo phòng)
CREATE TABLE Seats (
    SeatId        INT PRIMARY KEY IDENTITY,
    RoomId        INT NOT NULL REFERENCES Rooms(RoomId),
    RowLabel      CHAR(2) NOT NULL,           -- A, B, C...
    SeatNumber    INT NOT NULL,               -- 1, 2, 3...
    SeatType      VARCHAR(20) DEFAULT 'Standard', -- Standard / VIP / Couple
    UNIQUE (RoomId, RowLabel, SeatNumber)
);

-- 6. SHOWTIMES (Suất chiếu)
CREATE TABLE Showtimes (
    ShowtimeId    INT PRIMARY KEY IDENTITY,
    MovieId       INT NOT NULL REFERENCES Movies(MovieId),
    RoomId        INT NOT NULL REFERENCES Rooms(RoomId),
    StartTime     DATETIME NOT NULL,
    EndTime       DATETIME NOT NULL,
    BasePrice     DECIMAL(10,2) NOT NULL,     -- Giá cơ bản, biến động theo SeatType
    Status        VARCHAR(20) DEFAULT 'Scheduled' -- Scheduled / Ongoing / Finished / Cancelled
);

-- 7. VOUCHERS (Mã giảm giá)
CREATE TABLE Vouchers (
    VoucherId     INT PRIMARY KEY IDENTITY,
    Code          VARCHAR(50) NOT NULL UNIQUE,
    DiscountType  VARCHAR(20) NOT NULL,       -- Percent / FixedAmount
    DiscountValue DECIMAL(10,2) NOT NULL,
    MinOrderValue DECIMAL(10,2) DEFAULT 0,
    MaxUsage      INT DEFAULT 1,
    UsedCount     INT DEFAULT 0,
    StartAt       DATETIME NULL,                -- NULL = áp dụng ngay; có giá trị = Flash Sale bắt đầu từ thời điểm này
    ExpiredAt     DATETIME NOT NULL,
    IsActive      BIT DEFAULT 1,
    CreatedBy     INT REFERENCES Users(UserId),
    OwnedByUserId INT NULL REFERENCES Users(UserId)  -- NULL = voucher công khai, có giá trị = voucher cá nhân đổi từ điểm
);

-- 8. FOOD ITEMS (Đồ ăn & thức uống)
CREATE TABLE FoodItems (
    FoodItemId    INT PRIMARY KEY IDENTITY,
    Name          NVARCHAR(100) NOT NULL,
    Description   NVARCHAR(200) NULL,
    Price         DECIMAL(10,2) NOT NULL,
    ImageUrl      VARCHAR(500) NULL,
    IsAvailable   BIT DEFAULT 1
);

-- 9. BOOKINGS (Đơn đặt vé — đầu mối trung tâm)
CREATE TABLE Bookings (
    BookingId      INT PRIMARY KEY IDENTITY,
    UserId         INT NULL REFERENCES Users(UserId), -- NULL nếu khách vãng lai tại quầy
    ShowtimeId     INT NOT NULL REFERENCES Showtimes(ShowtimeId),
    BookingType    VARCHAR(10) NOT NULL,       -- ONLINE / COUNTER
    Status         VARCHAR(20) DEFAULT 'Pending', -- Pending / Confirmed / Cancelled / Refunded
    SubTotal       DECIMAL(10,2) NOT NULL,     -- Tiền vé + đồ ăn trước giảm giá
    DiscountAmount DECIMAL(10,2) DEFAULT 0,
    TotalAmount    DECIMAL(10,2) NOT NULL,
    VoucherId      INT NULL REFERENCES Vouchers(VoucherId),
    PointsEarned   INT DEFAULT 0,
    PointsUsed     INT DEFAULT 0,
    Note           NVARCHAR(300) NULL,
    CreatedBy      INT NULL REFERENCES Users(UserId), -- NULL nếu online
    CreatedAt      DATETIME DEFAULT GETDATE()
);

-- 10. BOOKING SEATS (Ghế trong đơn)
CREATE TABLE BookingSeats (
    BookingSeatsId INT PRIMARY KEY IDENTITY,
    BookingId      INT NOT NULL REFERENCES Bookings(BookingId),
    SeatId         INT NOT NULL REFERENCES Seats(SeatId),
    ShowtimeId     INT NOT NULL REFERENCES Showtimes(ShowtimeId),
    SeatPrice      DECIMAL(10,2) NOT NULL,     -- Giá thực tế tại thời điểm đặt
    Status         VARCHAR(20) DEFAULT 'Held', -- Held / Confirmed / Cancelled
    HeldUntil      DATETIME NULL,              -- Timeout giữ ghế
    UNIQUE (SeatId, ShowtimeId)               -- Không double booking
);

-- 11. BOOKING FOOD ITEMS (Đồ ăn trong đơn)
CREATE TABLE BookingFoodItems (
    BookingFoodId INT PRIMARY KEY IDENTITY,
    BookingId     INT NOT NULL REFERENCES Bookings(BookingId),
    FoodItemId    INT NOT NULL REFERENCES FoodItems(FoodItemId),
    Quantity      INT NOT NULL DEFAULT 1,
    UnitPrice     DECIMAL(10,2) NOT NULL      -- Giá tại thời điểm đặt
);

-- 12. PAYMENTS (Thanh toán)
CREATE TABLE Payments (
    PaymentId         INT PRIMARY KEY IDENTITY,
    BookingId         INT NOT NULL REFERENCES Bookings(BookingId),
    PaymentMethod     VARCHAR(20) NOT NULL,   -- VNPay / Cash
    Amount            DECIMAL(10,2) NOT NULL,
    Status            VARCHAR(20) DEFAULT 'Pending', -- Pending / Success / Failed / Refunded
    TransactionRef    VARCHAR(100) NULL,      -- Mã giao dịch VNPay
    PaidAt            DATETIME NULL,
    RefundedAt        DATETIME NULL,
    RefundedBy        INT NULL REFERENCES Users(UserId)
);

-- 13. AUDIT LOGS (Nhật ký hoạt động)
CREATE TABLE AuditLogs (
    LogId         INT PRIMARY KEY IDENTITY,
    UserId        INT NULL REFERENCES Users(UserId), -- Actor (nhân viên hoặc khách)
    Action        NVARCHAR(100) NOT NULL,     -- LOGIN / CANCEL_BOOKING / REFUND ...
    TargetTable   VARCHAR(50) NULL,           -- Bookings / Payments / ...
    TargetId      INT NULL,
    Detail        NVARCHAR(500) NULL,
    CreatedAt     DATETIME DEFAULT GETDATE()
);

-- 14. PASSWORD RESET TOKENS (UC-03 Forgot Password)
CREATE TABLE PasswordResetTokens (
    Token     VARCHAR(64) PRIMARY KEY,
    UserId    INT NOT NULL REFERENCES Users(UserId),
    ExpiresAt DATETIME NOT NULL
);