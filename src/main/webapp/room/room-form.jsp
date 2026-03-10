<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${room != null ? 'Sửa phòng' : 'Thêm phòng'} | Cinema</title>
    <base href="${pageContext.request.scheme}://${pageContext.request.serverName}:${pageContext.request.serverPort}${pageContext.request.contextPath}/">
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/header.css">
    <link rel="stylesheet" href="css/sidebar.css">
    <link rel="stylesheet" href="css/footer.css">
    <link rel="stylesheet" href="css/dashboard.css">
    <link rel="stylesheet" href="css/form.css">
    <link rel="stylesheet" href="css/button.css">
    <link rel="stylesheet" href="css/message.css">
</head>
<body class="dashboard-layout">
<jsp:include page="/components/header.jsp"/>
<jsp:include page="/components/sidebar.jsp"/>

<main class="dashboard-main">
    <div style="display:flex; align-items:center; justify-content:space-between; gap:1rem; margin-bottom:1rem;">
        <h1 style="font-size:1.5rem; font-weight:800; color:var(--text-dark); margin:0;">
            ${room != null ? 'Chỉnh sửa phòng' : 'Thêm phòng mới'}
        </h1>
        <a href="manager/rooms" class="btn btn-secondary">Quay lại</a>
    </div>

    <c:if test="${not empty error}">
        <div class="cinema-msg cinema-msg--error" role="alert" style="margin-bottom:1rem;">${error}</div>
    </c:if>

    <form action="manager/rooms" method="post" class="profile-card" style="padding:1.5rem; border-radius:12px;">
        <input type="hidden" name="action" value="${room != null ? 'update' : 'create'}">
        <input type="hidden" name="id" value="${room.roomId}">

        <div class="form-group">
            <label for="roomName" class="form-label">Tên phòng</label>
            <input type="text" id="roomName" name="roomName" class="form-input" value="${room.roomName}" required>
        </div>

        <div style="display:grid; grid-template-columns: 1fr 1fr; gap: 1rem;">
            <div class="form-group">
                <label for="roomType" class="form-label">Loại phòng</label>
                <select id="roomType" name="roomType" class="form-input" required>
                    <option value="2D" ${room.roomType=='2D' ? 'selected' : ''}>2D</option>
                    <option value="3D" ${room.roomType=='3D' ? 'selected' : ''}>3D</option>
                    <option value="IMAX" ${room.roomType=='IMAX' ? 'selected' : ''}>IMAX</option>
                </select>
            </div>
            <div class="form-group">
                <label for="totalSeats" class="form-label">Tổng số ghế</label>
                <input type="number" id="totalSeats" name="totalSeats" class="form-input" min="1" value="${room.totalSeats}" required>
                <c:if test="${not empty seatCount}">
                    <div class="form-hint">Hiện có ${seatCount} ghế đã cấu hình. Nếu đổi tổng ghế, hãy cấu hình lại sơ đồ ghế.</div>
                </c:if>
            </div>
        </div>

        <div class="form-group">
            <label class="form-label">Trạng thái</label>
            <label style="display:flex; align-items:center; gap:8px;">
                <input type="checkbox" name="isActive" value="1" ${room == null || room.active ? 'checked' : ''}>
                Kích hoạt phòng
            </label>
        </div>

        <div class="btn-row" style="margin-top:1.25rem;">
            <button type="submit" class="btn btn-primary">${room != null ? 'Cập nhật' : 'Tạo phòng'}</button>
            <a href="manager/rooms" class="btn btn-secondary">Hủy</a>
        </div>
    </form>
</main>

<jsp:include page="/components/footer.jsp"/>
</body>
</html>

