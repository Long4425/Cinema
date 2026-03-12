<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cấu hình giá vé</title>
    <base href="${pageContext.request.contextPath}/">
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/header.css">
    <link rel="stylesheet" href="css/sidebar.css">
    <link rel="stylesheet" href="css/footer.css">
    <link rel="stylesheet" href="css/dashboard.css">
    <link rel="stylesheet" href="css/table.css">
    <link rel="stylesheet" href="css/button.css">
</head>
<body class="dashboard-layout">
<jsp:include page="/components/header.jsp"/>

<div class="dashboard-body">
    <jsp:include page="/components/sidebar.jsp"/>

    <main class="dashboard-main">
        <div class="dashboard-main__inner">
            <div class="page-header">
                <div>
                    <h1 class="page-title">Cấu hình giá vé</h1>
                    <p class="page-subtitle">
                        Điều chỉnh <strong>BasePrice</strong> cho từng suất chiếu. Sau này có thể cộng thêm hệ số theo loại ghế/khung giờ.
                    </p>
                </div>
            </div>

            <div class="card" style="padding:1.25rem;">
                <c:if test="${empty showtimes}">
                    <p style="font-size:0.9rem;color:var(--text-muted);margin:0;">Chưa có suất chiếu nào.</p>
                </c:if>
                <c:if test="${not empty showtimes}">
                    <div class="table-wrap">
                        <table class="table">
                            <thead>
                            <tr>
                                <th>Phim</th>
                                <th>Phòng</th>
                                <th>Thời gian</th>
                                <th>Giá hiện tại</th>
                                <th style="width:180px;">Cập nhật</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:forEach items="${showtimes}" var="s">
                                <tr>
                                    <td><c:out value="${s.movieTitle}"/></td>
                                    <td><c:out value="${s.roomName}"/></td>
                                    <td>
                                        <fmt:formatDate value="${s.startTime}" pattern="HH:mm dd/MM/yyyy"/>
                                    </td>
                                    <td>
                                        <fmt:formatNumber value="${s.basePrice}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                    </td>
                                    <td>
                                        <form method="post" action="manager/pricing" class="table-actions" style="gap:0.4rem;">
                                            <input type="hidden" name="showtimeId" value="${s.showtimeId}">
                                            <input type="number" min="0" step="1000" name="basePrice"
                                                   class="form-input"
                                                   style="width:110px;padding-inline:0.4rem;"
                                                   placeholder="Giá mới">
                                            <button type="submit" class="btn btn-sm btn-primary">
                                                Lưu
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:if>
            </div>
        </div>
    </main>
</div>

<jsp:include page="/components/footer.jsp"/>
</body>
</html>

