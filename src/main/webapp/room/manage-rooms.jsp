<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý phòng chiếu | Cinema</title>
    <base href="${pageContext.request.scheme}://${pageContext.request.serverName}:${pageContext.request.serverPort}${pageContext.request.contextPath}/">
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/header.css">
    <link rel="stylesheet" href="css/sidebar.css">
    <link rel="stylesheet" href="css/footer.css">
    <link rel="stylesheet" href="css/dashboard.css">
    <link rel="stylesheet" href="css/table.css">
    <link rel="stylesheet" href="css/button.css">
    <link rel="stylesheet" href="css/badge.css">
    <link rel="stylesheet" href="css/message.css">
</head>
<body class="dashboard-layout">
<jsp:include page="/components/header.jsp"/>
<jsp:include page="/components/sidebar.jsp"/>

<main class="dashboard-main">
    <div style="display:flex; align-items:center; justify-content:space-between; gap:1rem; margin-bottom:1rem;">
        <h1 style="font-size:1.5rem; font-weight:800; color:var(--text-dark); margin:0;">Quản lý phòng chiếu</h1>
        <a href="manager/rooms?action=edit" class="btn btn-primary">Thêm phòng</a>
    </div>

    <c:if test="${not empty error}">
        <div class="cinema-msg cinema-msg--error" style="margin-bottom:1rem;">${error}</div>
    </c:if>

    <div class="table-wrap">
        <table class="table">
            <thead>
            <tr>
                <th>ID</th>
                <th>Tên phòng</th>
                <th>Loại</th>
                <th>Tổng ghế</th>
                <th>Trạng thái</th>
                <th>Thao tác</th>
            </tr>
            </thead>
            <tbody>
            <c:forEach var="r" items="${rooms}">
                <tr>
                    <td>${r.roomId}</td>
                    <td><strong>${r.roomName}</strong></td>
                    <td>${r.roomType}</td>
                    <td>${r.totalSeats}</td>
                    <td>
                        <c:choose>
                            <c:when test="${r.active}"><span class="badge badge-success">Active</span></c:when>
                            <c:otherwise><span class="badge badge-warning">Inactive</span></c:otherwise>
                        </c:choose>
                    </td>
                    <td>
                        <div class="table-actions">
                            <a href="manager/seats?roomId=${r.roomId}" class="btn btn-sm btn-primary">Sơ đồ ghế</a>
                            <a href="manager/rooms?action=edit&id=${r.roomId}" class="btn btn-sm btn-secondary">Sửa</a>
                            <c:if test="${r.active}">
                                <a href="manager/rooms?action=delete&id=${r.roomId}"
                                   class="btn btn-sm btn-danger"
                                   onclick="return confirm('Vô hiệu hóa phòng này?')">Vô hiệu</a>
                            </c:if>
                        </div>
                    </td>
                </tr>
            </c:forEach>
            <c:if test="${empty rooms}">
                <tr><td colspan="6" class="table-empty">Chưa có phòng chiếu nào.</td></tr>
            </c:if>
            </tbody>
        </table>
    </div>
</main>

<jsp:include page="/components/footer.jsp"/>
</body>
</html>

