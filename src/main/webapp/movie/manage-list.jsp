<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý phim | Cinema</title>
    <base href="${pageContext.request.scheme}://${pageContext.request.serverName}:${pageContext.request.serverPort}${pageContext.request.contextPath}/">
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/header.css">
    <link rel="stylesheet" href="css/sidebar.css">
    <link rel="stylesheet" href="css/footer.css">
    <link rel="stylesheet" href="css/dashboard.css">
    <link rel="stylesheet" href="css/table.css">
    <link rel="stylesheet" href="css/button.css">
    <link rel="stylesheet" href="css/badge.css">
</head>

<body class="dashboard-layout">
<jsp:include page="/components/header.jsp"/>
<jsp:include page="/components/sidebar.jsp"/>

<main class="dashboard-main">
    <div style="display:flex; align-items:center; justify-content:space-between; gap:1rem; margin-bottom:1rem;">
        <h1 style="font-size:1.5rem; font-weight:800; color:var(--text-dark); margin:0;">Quản lý phim</h1>
        <a href="manager/movies?action=edit" class="btn btn-primary">Thêm phim mới</a>
    </div>

    <div class="table-wrap">
        <table class="table">
            <thead>
            <tr>
                <th>ID</th>
                <th>Poster</th>
                <th>Tên phim</th>
                <th>Thời lượng</th>
                <th>Trạng thái</th>
                <th>Thao tác</th>
            </tr>
            </thead>
            <tbody>
            <c:forEach var="m" items="${movies}">
                <tr>
                    <td>${m.movieId}</td>
                    <td>
                        <c:choose>
                            <c:when test="${not empty m.posterUrl}">
                                <img src="images/${m.posterUrl}" alt="${m.title}"
                                     style="width:50px;height:75px;object-fit:cover;border-radius:8px;border:1px solid var(--border-light);">
                            </c:when>
                            <c:otherwise>
                                <img src="images/default.jpg" alt="${m.title}"
                                     style="width:50px;height:75px;object-fit:cover;border-radius:8px;border:1px solid var(--border-light); opacity:0.95;">
                            </c:otherwise>
                        </c:choose>
                    </td>
                    <td>
                        <strong>${m.title}</strong><br>
                        <span style="color:var(--text-muted); font-size:0.85rem;">${m.titleEN}</span>
                    </td>
                    <td>${m.durationMins} phút</td>
                    <td>
                        <c:choose>
                            <c:when test="${m.status == 'NowShowing'}"><span class="badge badge-success">NowShowing</span></c:when>
                            <c:when test="${m.status == 'ComingSoon'}"><span class="badge badge-info">ComingSoon</span></c:when>
                            <c:otherwise><span class="badge badge-warning">${m.status}</span></c:otherwise>
                        </c:choose>
                    </td>
                    <td>
                        <div class="table-actions">
                            <a href="manager/movie-detail?id=${m.movieId}" class="btn btn-sm btn-primary">Chi tiết</a>
                            <a href="manager/movies?action=edit&id=${m.movieId}" class="btn btn-sm btn-secondary">Sửa</a>
                            <a href="manager/movies?action=delete&id=${m.movieId}"
                               class="btn btn-sm btn-danger"
                               onclick="return confirm('Bạn có chắc chắn muốn xóa?')">Xóa</a>
                        </div>
                    </td>
                </tr>
            </c:forEach>
            <c:if test="${empty movies}">
                <tr>
                    <td colspan="6" class="table-empty">Chưa có phim nào.</td>
                </tr>
            </c:if>
            </tbody>
        </table>
    </div>
</main>

<jsp:include page="/components/footer.jsp"/>
</body>
</html>