<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết đơn đặt vé</title>
    <base href="${pageContext.request.contextPath}/">
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/header.css">
    <link rel="stylesheet" href="css/footer.css">
    <link rel="stylesheet" href="css/dashboard.css">
    <link rel="stylesheet" href="css/button.css">
    <link rel="stylesheet" href="css/table.css">
</head>
<body class="home-layout">
<jsp:include page="/components/header.jsp"/>

<main class="home-main">
    <div class="container" style="max-width: 780px;">
        <div class="page-header">
            <div>
                <h1 class="page-title">Chi tiết vé xem phim</h1>
                <p class="page-subtitle">
                    Mã đơn: #${booking.bookingId}
                    -
                    <c:choose>
                        <c:when test="${booking.status == 'Confirmed'}">
                            <span class="badge badge-success">Đã thanh toán</span>
                        </c:when>
                        <c:when test="${booking.status == 'Pending'}">
                            <span class="badge badge-warning">Chờ thanh toán / xác nhận</span>
                        </c:when>
                        <c:when test="${booking.status == 'Cancelled'}">
                            <span class="badge badge-danger">Đã hủy</span>
                        </c:when>
                        <c:otherwise>
                            <span class="badge badge-info">${booking.status}</span>
                        </c:otherwise>
                    </c:choose>
                </p>
            </div>
        </div>

        <div class="card" style="padding:1.5rem;display:flex;flex-direction:column;gap:1rem;">
            <div>
                <h2 style="font-size:1rem;margin-bottom:0.5rem;">Thông tin suất chiếu</h2>
                <p style="font-size:0.9rem;margin:0;">
                    <strong>Phim:</strong> <c:out value="${showtime.movieTitle}"/><br>
                    <strong>Phòng:</strong> <c:out value="${showtime.roomName}"/><br>
                    <strong>Thời gian:</strong>
                    <fmt:formatDate value="${showtime.startTime}" pattern="HH:mm dd/MM/yyyy"/>
                </p>
            </div>

            <div>
                <h2 style="font-size:1rem;margin-bottom:0.5rem;">Ghế đã đặt</h2>
                <p style="font-size:0.9rem;margin:0;">
                    <c:forEach items="${bookingSeats}" var="bs" varStatus="loop">
                        ${bs.seat.rowLabel}${bs.seat.seatNumber}<c:if test="${!loop.last}">, </c:if>
                    </c:forEach>
                </p>
            </div>

            <c:if test="${not empty bookingFoodItems}">
                <div>
                    <h2 style="font-size:1rem;margin-bottom:0.5rem;">Đồ ăn & thức uống</h2>
                    <div class="table-wrap">
                        <table class="table">
                            <thead>
                            <tr>
                                <th>Sản phẩm</th>
                                <th style="width:80px;">SL</th>
                                <th style="width:110px;">Đơn giá</th>
                                <th style="width:120px;">Thành tiền</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:set var="foodTotal" value="0"/>
                            <c:forEach items="${bookingFoodItems}" var="item">
                                <c:set var="lineTotal" value="${item.unitPrice * item.quantity}"/>
                                <c:set var="foodTotal" value="${foodTotal + lineTotal}"/>
                                <tr>
                                    <td>
                                        <strong><c:out value="${item.foodItem.name}"/></strong>
                                    </td>
                                    <td>${item.quantity}</td>
                                    <td>
                                        <fmt:formatNumber value="${item.unitPrice}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                    </td>
                                    <td>
                                        <fmt:formatNumber value="${lineTotal}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                    </td>
                                </tr>
                            </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </c:if>

            <div style="border-top:1px dashed var(--border-light);padding-top:0.75rem;">
                <h2 style="font-size:1rem;margin-bottom:0.5rem;">Thanh toán</h2>
                <div style="font-size:0.9rem;">
                    <div style="display:flex;justify-content:space-between;margin-bottom:0.25rem;">
                        <span>Tổng trước giảm</span>
                        <span>
                            <fmt:formatNumber value="${booking.subTotal}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                        </span>
                    </div>
                    <div style="display:flex;justify-content:space-between;margin-bottom:0.25rem;">
                        <span>Giảm giá</span>
                        <span>
                            -<fmt:formatNumber value="${booking.discountAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                        </span>
                    </div>
                    <div style="display:flex;justify-content:space-between;font-weight:600;margin-top:0.35rem;">
                        <span>Thành tiền</span>
                        <span>
                            <fmt:formatNumber value="${booking.totalAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                        </span>
                    </div>
                </div>
            </div>

            <div style="margin-top:1rem;display:flex;gap:0.75rem;flex-wrap:wrap;">
                <a href="movies" class="btn btn-primary">Đặt thêm vé khác</a>
                <a href="showtimes" class="btn btn-secondary">Xem lịch chiếu khác</a>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/components/footer.jsp"/>
</body>
</html>

