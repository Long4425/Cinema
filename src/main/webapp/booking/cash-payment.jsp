<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Xác nhận thanh toán tại quầy</title>
    <base href="${pageContext.request.contextPath}/">
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/header.css">
    <link rel="stylesheet" href="css/sidebar.css">
    <link rel="stylesheet" href="css/footer.css">
    <link rel="stylesheet" href="css/dashboard.css">
    <link rel="stylesheet" href="css/button.css">
    <link rel="stylesheet" href="css/table.css">
</head>
<body class="dashboard-layout">
<jsp:include page="/components/header.jsp"/>

<div class="dashboard-body">
    <jsp:include page="/components/sidebar.jsp"/>

    <main class="dashboard-main">
        <div class="dashboard-main__inner">
            <div class="page-header">
                <div>
                    <h1 class="page-title">Xác nhận thanh toán tại quầy</h1>
                    <p class="page-subtitle">
                        Mã đơn: #${booking.bookingId}
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
                        <fmt:formatNumber value="${showtime.startTime.hour}" minIntegerDigits="2"/>:<fmt:formatNumber value="${showtime.startTime.minute}" minIntegerDigits="2"/>
                        ${showtime.startTime.dayOfMonth}/${showtime.startTime.monthValue}/${showtime.startTime.year}
                    </p>
                </div>

                <div>
                    <h2 style="font-size:1rem;margin-bottom:0.5rem;">Ghế khách chọn</h2>
                    <p style="font-size:0.9rem;margin:0;">
                        <c:forEach items="${bookingSeats}" var="bs" varStatus="loop">
                            ${bs.seat.rowLabel}${bs.seat.seatNumber}<c:if test="${!loop.last}">, </c:if>
                        </c:forEach>
                    </p>
                </div>

                <div style="border-top:1px dashed var(--border-light);padding-top:0.75rem;">
                    <h2 style="font-size:1rem;margin-bottom:0.5rem;">Số tiền cần thu</h2>
                    <p style="font-size:1rem;font-weight:600;margin:0;">
                        <fmt:formatNumber value="${booking.totalAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                    </p>
                </div>

                <form method="post" action="manager/booking/cash-payment" style="margin-top:1rem;display:flex;gap:0.75rem;flex-wrap:wrap;align-items:center;">
                    <input type="hidden" name="bookingId" value="${booking.bookingId}">
                    <button type="submit" class="btn btn-primary">
                        Xác nhận đã thu tiền mặt
                    </button>
                    <a href="dashboard" class="btn btn-secondary">Hủy và quay lại</a>
                </form>
            </div>
        </div>
    </main>
</div>

<jsp:include page="/components/footer.jsp"/>
</body>
</html>

