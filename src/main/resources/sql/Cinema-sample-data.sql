-- ============================================================
-- Cinema - Sample Data
-- Chạy SAU khi chạy Cinema.sql (schema đã tạo)
-- Mật khẩu tất cả tài khoản: 123456
-- ============================================================

USE CinemaDB;
GO

-- BCrypt hash cho "123456" (sinh bởi util.HashGenerator)
DECLARE @pwdHash VARCHAR(255) = '$2a$10$utghSGUBOLHU7jYnOKM3L.3//wwqW3hmOLG7VsXaQrJWfkhDd64ra';

-- USERS (RoleId: 1=CUSTOMER, 2=CASHIER, 3=MANAGER, 4=ADMIN)
INSERT INTO Users (FullName, Email, PasswordHash, GoogleId, Phone, MemberTier, LoyaltyPoint, RoleId, IsActive) VALUES
(N'Nguyễn Văn Admin', 'admin@cinema.vn', @pwdHash, NULL, '0901234567', 'Standard', 0, 4, 1),
(N'Trần Thị Quản Lý', 'manager@cinema.vn', @pwdHash, NULL, '0901234568', 'Standard', 0, 3, 1),
(N'Lê Văn Thu Ngân', 'cashier@cinema.vn', @pwdHash, NULL, '0901234569', 'Standard', 0, 2, 1),
(N'Phạm Minh Khách', 'customer@cinema.vn', @pwdHash, NULL, '0901234570', 'Silver', 150, 1, 1),
(N'Hoàng Thị Lan', 'lan@cinema.vn', @pwdHash, NULL, '0901234571', 'Standard', 50, 1, 1),
(N'Võ Đức Anh', 'anh@cinema.vn', @pwdHash, NULL, NULL, 'Standard', 0, 1, 1);

-- MOVIES
INSERT INTO Movies (Title, TitleEN, Description, Genre, Language, AgeRating, DurationMins, PosterUrl, TrailerUrl, Status, CreatedBy) VALUES
(N'Làm Giàu Với Ma', 'How to Get Rich with Ghosts', N'Phim kinh dị hài về một nhóm bạn trẻ vô tình gặp ma và tìm cách kiếm tiền từ đó.', N'Kinh dị, Hài', N'Tiếng Việt', 'C16', 110, NULL, NULL, 'NowShowing', 1),
(N'Dune: Hành Tinh Cát - Phần 2', 'Dune: Part Two', N'Paul Atreides hợp nhất với người Fremen để trả thù những kẻ đã hủy hoại gia đình.', N'Khoa học viễn tưởng, Phiêu lưu', N'Tiếng Anh - Phụ đề', 'C13', 166, NULL, NULL, 'NowShowing', 1),
(N'Kẻ Trộm Mặt Trăng 4', 'Despicable Me 4', N'Gru và gia đình đối mặt với kẻ thù mới trong phần tiếp theo hài hước.', N'Hoạt hình, Hài', N'Tiếng Anh - Lồng tiếng', 'P', 94, NULL, NULL, 'NowShowing', 1),
(N'Quỷ Ám', 'The Conjuring: Last Rites', N'Ed và Lorraine Warren đối mặt với vụ án kinh hoàng nhất trong sự nghiệp.', N'Kinh dị', N'Tiếng Anh - Phụ đề', 'C18', 120, NULL, NULL, 'ComingSoon', 1);

-- ROOMS
INSERT INTO Rooms (RoomName, RoomType, TotalSeats, IsActive) VALUES
(N'Phòng 1', '2D', 80, 1),
(N'Phòng 2', '3D', 60, 1),
(N'Phòng 3', 'IMAX', 120, 1);

-- SEATS (Phòng 1: 8 hàng x 10 ghế)
DECLARE @room1 INT = 1, @room2 INT = 2, @room3 INT = 3;
DECLARE @r INT = 1, @s INT;
WHILE @r <= 8
BEGIN
    SET @s = 1;
    WHILE @s <= 10
    BEGIN
        INSERT INTO Seats (RoomId, RowLabel, SeatNumber, SeatType)
        VALUES (@room1, CHAR(64 + @r), @s, CASE WHEN @r <= 2 THEN 'VIP' ELSE 'Standard' END);
        SET @s = @s + 1;
    END
    SET @r = @r + 1;
END;

-- Seats Phòng 2
SET @r = 1;
WHILE @r <= 6
BEGIN
    SET @s = 1;
    WHILE @s <= 10
    BEGIN
        INSERT INTO Seats (RoomId, RowLabel, SeatNumber, SeatType)
        VALUES (@room2, CHAR(64 + @r), @s, 'Standard');
        SET @s = @s + 1;
    END
    SET @r = @r + 1;
END;

-- Seats Phòng 3 (IMAX)
SET @r = 1;
WHILE @r <= 10
BEGIN
    SET @s = 1;
    WHILE @s <= 12
    BEGIN
        INSERT INTO Seats (RoomId, RowLabel, SeatNumber, SeatType)
        VALUES (@room3, CHAR(64 + @r), @s, CASE WHEN @r <= 2 THEN 'VIP' ELSE 'Standard' END);
        SET @s = @s + 1;
    END
    SET @r = @r + 1;
END;

-- SHOWTIMES (vài suất mẫu)
DECLARE @m1 INT = (SELECT TOP 1 MovieId FROM Movies WHERE Title = N'Làm Giàu Với Ma' ORDER BY MovieId DESC);
DECLARE @m2 INT = (SELECT TOP 1 MovieId FROM Movies WHERE Title = N'Dune: Hành Tinh Cát - Phần 2' ORDER BY MovieId DESC);
DECLARE @m3 INT = (SELECT TOP 1 MovieId FROM Movies WHERE Title = N'Kẻ Trộm Mặt Trăng 4' ORDER BY MovieId DESC);
DECLARE @m4 INT = (SELECT TOP 1 MovieId FROM Movies WHERE Title = N'Quỷ Ám' ORDER BY MovieId DESC);

DECLARE @today DATE = CAST(GETDATE() AS DATE);
DECLARE @fixedToday DATE = '2026-03-10';

INSERT INTO Showtimes (MovieId, RoomId, StartTime, EndTime, BasePrice, Status) VALUES
-- Today (the day you run the script)
(@m1, 1, DATEADD(HOUR, 9, CAST(@today AS DATETIME2)),  DATEADD(MINUTE, 110, DATEADD(HOUR, 9, CAST(@today AS DATETIME2))),  65000,  'Scheduled'),
(@m1, 2, DATEADD(HOUR, 13, CAST(@today AS DATETIME2)), DATEADD(MINUTE, 110, DATEADD(HOUR, 13, CAST(@today AS DATETIME2))), 85000,  'Scheduled'),
(@m2, 3, DATEADD(HOUR, 10, CAST(@today AS DATETIME2)), DATEADD(MINUTE, 166, DATEADD(HOUR, 10, CAST(@today AS DATETIME2))), 120000, 'Scheduled'),
(@m3, 1, DATEADD(HOUR, 15, CAST(@today AS DATETIME2)), DATEADD(MINUTE, 94,  DATEADD(HOUR, 15, CAST(@today AS DATETIME2))), 75000,  'Scheduled'),

-- Fixed sample date: 10/03/2026 (để luôn có lịch chiếu đúng "hôm nay" theo yêu cầu)
(@m1, 1, CAST('2026-03-10T08:30:00' AS DATETIME2), DATEADD(MINUTE, 110, CAST('2026-03-10T08:30:00' AS DATETIME2)), 65000,  'Scheduled'),
(@m1, 2, CAST('2026-03-10T19:10:00' AS DATETIME2), DATEADD(MINUTE, 110, CAST('2026-03-10T19:10:00' AS DATETIME2)), 85000,  'Scheduled'),
(@m2, 3, CAST('2026-03-10T09:15:00' AS DATETIME2), DATEADD(MINUTE, 166, CAST('2026-03-10T09:15:00' AS DATETIME2)), 120000, 'Scheduled'),
(@m2, 3, CAST('2026-03-10T20:00:00' AS DATETIME2), DATEADD(MINUTE, 166, CAST('2026-03-10T20:00:00' AS DATETIME2)), 120000, 'Scheduled'),
(@m3, 1, CAST('2026-03-10T11:00:00' AS DATETIME2), DATEADD(MINUTE, 94,  CAST('2026-03-10T11:00:00' AS DATETIME2)), 75000,  'Scheduled'),
(@m3, 2, CAST('2026-03-10T16:40:00' AS DATETIME2), DATEADD(MINUTE, 94,  CAST('2026-03-10T16:40:00' AS DATETIME2)), 85000,  'Scheduled'),

-- More diverse dates around 10/03/2026 (09/03, 11/03, 12/03) to avoid "only one day" schedules
(@m1, 1, CAST('2026-03-09T18:20:00' AS DATETIME2), DATEADD(MINUTE, 110, CAST('2026-03-09T18:20:00' AS DATETIME2)), 65000,  'Scheduled'),
(@m2, 2, CAST('2026-03-09T21:10:00' AS DATETIME2), DATEADD(MINUTE, 166, CAST('2026-03-09T21:10:00' AS DATETIME2)), 105000, 'Scheduled'),
(@m3, 1, CAST('2026-03-09T09:30:00' AS DATETIME2), DATEADD(MINUTE, 94,  CAST('2026-03-09T09:30:00' AS DATETIME2)), 70000,  'Scheduled'),

(@m1, 3, CAST('2026-03-11T10:05:00' AS DATETIME2), DATEADD(MINUTE, 110, CAST('2026-03-11T10:05:00' AS DATETIME2)), 110000, 'Scheduled'),
(@m2, 3, CAST('2026-03-11T14:10:00' AS DATETIME2), DATEADD(MINUTE, 166, CAST('2026-03-11T14:10:00' AS DATETIME2)), 120000, 'Scheduled'),
(@m3, 2, CAST('2026-03-11T18:45:00' AS DATETIME2), DATEADD(MINUTE, 94,  CAST('2026-03-11T18:45:00' AS DATETIME2)), 85000,  'Scheduled'),

(@m1, 2, CAST('2026-03-12T12:30:00' AS DATETIME2), DATEADD(MINUTE, 110, CAST('2026-03-12T12:30:00' AS DATETIME2)), 85000,  'Scheduled'),
(@m2, 1, CAST('2026-03-12T17:00:00' AS DATETIME2), DATEADD(MINUTE, 166, CAST('2026-03-12T17:00:00' AS DATETIME2)), 90000,  'Scheduled'),
(@m3, 1, CAST('2026-03-12T20:10:00' AS DATETIME2), DATEADD(MINUTE, 94,  CAST('2026-03-12T20:10:00' AS DATETIME2)), 75000,  'Scheduled'),

-- ComingSoon movie: add showtimes after fixedToday to keep reasonable
(@m4, 2, CAST('2026-03-15T18:30:00' AS DATETIME2), DATEADD(MINUTE, 120, CAST('2026-03-15T18:30:00' AS DATETIME2)), 95000,  'Scheduled'),
(@m4, 3, CAST('2026-03-16T20:15:00' AS DATETIME2), DATEADD(MINUTE, 120, CAST('2026-03-16T20:15:00' AS DATETIME2)), 135000, 'Scheduled');

-- FOOD ITEMS
INSERT INTO FoodItems (Name, Description, Price, ImageUrl, IsAvailable) VALUES
(N'Bắp rang bơ', N'Bắp rang bơ size M', 35000, NULL, 1),
(N'Bắp rang bơ size L', N'Bắp rang bơ size L', 45000, NULL, 1),
(N'Pepsi', N'Nước ngọt Pepsi 32oz', 25000, NULL, 1),
(N'Combo 1', N'1 Bắp M + 1 Pepsi', 55000, NULL, 1),
(N'Combo 2', N'2 Bắp M + 2 Pepsi', 100000, NULL, 1);

-- VOUCHERS
INSERT INTO Vouchers (Code, DiscountType, DiscountValue, MinOrderValue, MaxUsage, UsedCount, ExpiredAt, IsActive, CreatedBy) VALUES
('WELCOME10', 'Percent', 10, 100000, 100, 0, DATEADD(MONTH, 3, GETDATE()), 1, 1),
('SUMMER50K', 'FixedAmount', 50000, 200000, 50, 0, DATEADD(MONTH, 2, GETDATE()), 1, 1);

PRINT N'Sample data đã được thêm. Mật khẩu tất cả tài khoản: 123456';
PRINT N'Admin: admin@cinema.vn | Manager: manager@cinema.vn | Cashier: cashier@cinema.vn';
PRINT N'Customer: customer@cinema.vn, lan@cinema.vn, anh@cinema.vn';
