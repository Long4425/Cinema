<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lịch sử đặt vé</title>
    <base href="${pageContext.request.contextPath}/">
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/header.css">
    <link rel="stylesheet" href="css/footer.css">
    <link rel="stylesheet" href="css/dashboard.css">
    <link rel="stylesheet" href="css/table.css">
    <link rel="stylesheet" href="css/button.css">
    <link rel="stylesheet" href="css/badge.css">
</head>
<body class="home-layout">
<jsp:include page="/components/header.jsp"/>

<main class="home-main">
    <div class="container" style="max-width: 960px;">
        <div class="page-header">
            <div>
                <h1 class="page-title">Lịch sử đặt vé</h1>
                <p class="page-subtitle">Xem lại các đơn đặt vé, tình trạng và truy xuất vé.</p>
            </div>
        </div>

        <div class="card" style="padding:1.25rem;">
            <c:if test="${empty bookings}">
                <p style="font-size:0.9rem;color:var(--text-muted);margin:0;">Bạn chưa có đơn đặt vé nào.</p>
            </c:if>
            <c:if test="${not empty bookings}">
                <div class="table-wrap">
                    <table class="table">
                        <thead>
                        <tr>
                            <th>Mã đơn</th>
                            <th>Phim</th>
                            <th>Suất chiếu</th>
                            <th>Ghế</th>
                            <th>Trạng thái</th>
                            <th>Tổng tiền</th>
                            <th style="width:170px;">Thao tác</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach items="${bookings}" var="b">
                            <c:set var="s" value="${showtimeMap[b.showtimeId]}"/>
                            <c:set var="seats" value="${seatsMap[b.bookingId]}"/>
                            <tr>
                                <td>#${b.bookingId}</td>
                                <td>
                                    <c:out value="${s.movieTitle}"/>
                                </td>
                                <td>
                                    <fmt:formatDate value="${s.startTime}" pattern="HH:mm dd/MM/yyyy"/>
                                </td>
                                <td>
                                    <c:forEach items="${seats}" var="bs" varStatus="loop">
                                        ${bs.seat.rowLabel}${bs.seat.seatNumber}<c:if test="${!loop.last}">, </c:if>
                                    </c:forEach>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${b.status == 'Confirmed'}">
                                            <span class="badge badge-success">Đã thanh toán</span>
                                        </c:when>
                                        <c:when test="${b.status == 'Pending'}">
                                            <span class="badge badge-warning">Chờ thanh toán</span>
                                        </c:when>
                                        <c:when test="${b.status == 'Cancelled'}">
                                            <span class="badge badge-danger">Đã hủy</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge badge-info">${b.status}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <fmt:formatNumber value="${b.totalAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                </td>
                                <td>
                                    <div class="table-actions">
                                        <a href="booking/summary?bookingId=${b.bookingId}" class="btn btn-sm btn-secondary">
                                            Xem vé
                                        </a>
                                        <c:if test="${cancellableMap[b.bookingId]}">
                                            <form method="post" action="booking/cancel" style="display:inline;">
                                                <input type="hidden" name="bookingId" value="${b.bookingId}">
                                                <button type="submit" class="btn btn-sm btn-danger"
                                                        onclick="return confirm('Bạn chắc chắn muốn hủy vé và hoàn tiền?');">
                                                    Hủy vé
                                                </button>
                                            </form>
                                            <form method="post" action="booking/exchange" style="display:inline;">
                                                <input type="hidden" name="bookingId" value="${b.bookingId}">
                                                <button type="submit" class="btn btn-sm btn-primary" style="margin-left:4px;">
                                                    Đổi suất chiếu
                                                </button>
                                            </form>
                                        </c:if>
                                    </div>
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

<jsp:include page="/components/footer.jsp"/>
</body>
</html>

