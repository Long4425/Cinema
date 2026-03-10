<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8">
            <title>Quản lý phim - Admin Dashboard</title>
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css">
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/dashboard.css">
            <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap"
                rel="stylesheet">
        </head>

        <body class="dashboard">
            <jsp:include page="/components/header.jsp" />
            <div class="dashboard__container">
                <jsp:include page="/components/sidebar.jsp" />
                <main class="dashboard__content">
                    <div class="dashboard__header">
                        <h1 class="dashboard__title">Quản lý phim</h1>
                        <a href="${pageContext.request.contextPath}/manager/movies?action=edit"
                            class="btn btn--primary">Thêm phim mới</a>
                    </div>

                    <div class="dashboard__card">
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
                                            <img src="${pageContext.request.contextPath}/images/${m.posterUrl}"
                                                alt="${m.title}"
                                                style="width: 50px; height: 75px; object-fit: cover; border-radius: 4px;">
                                        </td>
                                        <td>
                                            <strong>${m.title}</strong><br>
                                            <small>${m.titleEN}</small>
                                        </td>
                                        <td>${m.durationMins} phút</td>
                                        <td>
                                            <span
                                                class="badge badge--${m.status == 'NowShowing' ? 'success' : 'warning'}">${m.status}</span>
                                        </td>
                                        <td>
                                            <a href="${pageContext.request.contextPath}/manager/movies?action=edit&id=${m.movieId}"
                                                class="btn btn--small btn--info">Sửa</a>
                                            <a href="${pageContext.request.contextPath}/manager/movies?action=delete&id=${m.movieId}"
                                                class="btn btn--small btn--danger"
                                                onclick="return confirm('Bạn có chắc chắn muốn xóa?')">Xóa</a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </main>
            </div>
        </body>

        </html>