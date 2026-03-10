<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <title>Quản lý lịch chiếu - Admin Dashboard</title>
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css">
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/dashboard.css">
            </head>

            <body class="dashboard">
                <jsp:include page="/components/header.jsp" />
                <div class="dashboard__container">
                    <jsp:include page="/components/sidebar.jsp" />
                    <main class="dashboard__content">
                        <div class="dashboard__header">
                            <h1 class="dashboard__title">Quản lý lịch chiếu</h1>
                            <a href="${pageContext.request.contextPath}/manager/showtimes?action=edit"
                                class="btn btn--primary">Thêm suất chiếu</a>
                        </div>

                        <div class="dashboard__card">
                            <table class="table">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Phim</th>
                                        <th>Phòng</th>
                                        <th>Thời gian bắt đầu</th>
                                        <th>Thời gian kết thúc</th>
                                        <th>Giá cơ bản</th>
                                        <th>Thao tác</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="s" items="${showtimes}">
                                        <tr>
                                            <td>${s.showtimeId}</td>
                                            <td>${s.movie.title}</td>
                                            <td>${s.room.roomName} (${s.room.roomType})</td>
                                            <td>${s.startTime.toString().replace('T', ' ')}</td>
                                            <td>${s.endTime.toString().replace('T', ' ')}</td>
                                            <td>
                                                <fmt:formatNumber value="${s.basePrice}" type="currency"
                                                    currencySymbol="₫" />
                                            </td>
                                            <td>
                                                <a href="${pageContext.request.contextPath}/manager/showtimes?action=edit&id=${s.showtimeId}"
                                                    class="btn btn--small btn--info">Sửa</a>
                                                <a href="${pageContext.request.contextPath}/manager/showtimes?action=delete&id=${s.showtimeId}"
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