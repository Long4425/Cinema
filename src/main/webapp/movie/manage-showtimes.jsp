<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý lịch chiếu | Cinema</title>
    <base href="${pageContext.request.scheme}://${pageContext.request.serverName}:${pageContext.request.serverPort}${pageContext.request.contextPath}/">
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/header.css">
    <link rel="stylesheet" href="css/sidebar.css">
    <link rel="stylesheet" href="css/footer.css">
    <link rel="stylesheet" href="css/dashboard.css">
    <link rel="stylesheet" href="css/table.css">
    <link rel="stylesheet" href="css/button.css">
    <link rel="stylesheet" href="css/message.css">
    <link rel="stylesheet" href="css/movies.css">
</head>

<body class="dashboard-layout">
<jsp:include page="/components/header.jsp"/>
<jsp:include page="/components/sidebar.jsp"/>

<main class="dashboard-main">
    <div style="display:flex; align-items:center; justify-content:space-between; gap:1rem; margin-bottom:1rem;">
        <h1 style="font-size:1.5rem; font-weight:800; color:var(--text-dark); margin:0;">Quản lý lịch chiếu</h1>
        <a href="manager/showtimes?action=edit" class="btn btn-primary">Thêm suất chiếu</a>
    </div>

    <form action="manager/showtimes" method="get" class="search-filter-section" style="margin-bottom:1.5rem;">
        <input type="hidden" name="action" value="list">
        <div class="filter-group" style="max-width:260px;">
            <label for="date-filter">Chọn ngày</label>
            <input type="date" id="date-filter" name="date" class="filter-input"
                   value="${not empty date ? date : ''}">
        </div>
        <div class="filter-actions">
            <button type="submit" class="search-btn">Lọc</button>
            <button type="button" class="search-btn" onclick="location.href='manager/showtimes?action=list'">Reset</button>
        </div>
    </form>

    <c:if test="${not empty error}">
        <div class="cinema-msg cinema-msg--error" role="alert" style="margin-bottom:1rem;">${error}</div>
    </c:if>
    <c:if test="${not empty success}">
        <div class="cinema-msg cinema-msg--success" role="status" style="margin-bottom:1rem;">${success}</div>
    </c:if>

    <div class="table-wrap">
        <table class="table">
            <thead>
            <tr>
                <th>ID</th>
                <th>Phòng</th>
                <th>Bắt đầu</th>
                <th>Kết thúc</th>
                <th>Giá cơ bản</th>
                <th>Thao tác</th>
            </tr>
            </thead>
            <tbody>
            <c:set var="currentMovieId" value="-1"/>
            <c:forEach var="s" items="${showtimes}">
                <c:if test="${currentMovieId != s.movieId}">
                    <c:set var="currentMovieId" value="${s.movieId}"/>
                    <tr>
                        <td colspan="6" style="background: var(--primary-light); color: var(--primary-dark); font-weight: 800;">
                            ${s.movie.title}
                            <span style="font-weight: 600; color: var(--text-muted); margin-left: 8px; font-size: 0.9rem;">
                                (${s.movie.titleEN})
                            </span>
                        </td>
                    </tr>
                </c:if>
                <tr>
                    <td>${s.showtimeId}</td>
                    <td>${s.room.roomName} (${s.room.roomType})</td>
                    <td>${s.startTime.toString().replace('T', ' ')}</td>
                    <td>${s.endTime.toString().replace('T', ' ')}</td>
                    <td><fmt:formatNumber value="${s.basePrice}" type="currency" currencySymbol="₫"/></td>
                    <td>
                        <div class="table-actions">
                            <a href="manager/showtimes?action=edit&id=${s.showtimeId}" class="btn btn-sm btn-secondary">Sửa</a>
                            <a href="manager/showtimes?action=delete&id=${s.showtimeId}"
                               class="btn btn-sm btn-danger"
                               onclick="return confirm('Bạn có chắc chắn muốn xóa?')">Xóa</a>
                        </div>
                    </td>
                </tr>
            </c:forEach>
            <c:if test="${empty showtimes}">
                <tr>
                    <td colspan="6" class="table-empty">Chưa có suất chiếu nào.</td>
                </tr>
            </c:if>
            </tbody>
        </table>
    </div>
</main>

<jsp:include page="/components/footer.jsp"/>
</body>
</html>