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
    <link rel="stylesheet" href="css/message.css">
</head>
<body class="home-layout">
<jsp:include page="/components/header.jsp"/>

<main class="home-main">
    <div class="container container--lg">
        <div class="page-header">
            <div>
                <h1 class="page-title">Lịch sử đặt vé</h1>
                <p class="page-subtitle">Xem lại các đơn đặt vé, tình trạng và truy xuất vé.</p>
            </div>
        </div>

        <%-- Flash messages --%>
        <c:if test="${not empty sessionScope.success}">
            <div class="cinema-msg cinema-msg--success" style="margin-bottom:1rem;">${sessionScope.success}</div>
            <c:remove var="success" scope="session"/>
        </c:if>
        <c:if test="${not empty sessionScope.error}">
            <div class="cinema-msg cinema-msg--error" style="margin-bottom:1rem;">${sessionScope.error}</div>
            <c:remove var="error" scope="session"/>
        </c:if>

        <div class="card" style="padding:1.25rem;">
            <c:choose>
                <c:when test="${empty bookings}">
                    <p style="font-size:0.9rem;color:var(--text-muted);margin:0;">Bạn chưa có đơn đặt vé nào.</p>
                </c:when>
                <c:otherwise>
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
                                <th style="width:120px;">Thao tác</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:forEach items="${bookings}" var="b">
                                <c:set var="s" value="${showtimeMap[b.showtimeId]}"/>
                                <c:set var="seats" value="${seatsMap[b.bookingId]}"/>
                                <tr>
                                    <td>#${b.bookingId}</td>
                                    <td><c:out value="${s.movie.title}"/></td>
                                    <td>
                                        <fmt:formatNumber value="${s.startTime.hour}" minIntegerDigits="2"/>:<fmt:formatNumber value="${s.startTime.minute}" minIntegerDigits="2"/>
                                        ${s.startTime.dayOfMonth}/${s.startTime.monthValue}/${s.startTime.year}
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
                                            <c:when test="${b.status == 'Refunded'}">
                                                <span class="badge badge-info">Đã hoàn tiền</span>
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
                                            <a href="booking/summary?bookingId=${b.bookingId}" class="btn btn-sm btn-secondary">Xem vé</a>
                                            <c:if test="${cancellableMap[b.bookingId]}">
                                                <button type="button" class="btn btn-sm btn-danger"
                                                        onclick="showCancelWarning(${b.bookingId})">Hủy vé</button>
                                            </c:if>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</main>

<%-- Modal cảnh báo hủy vé --%>
<div id="cancelModal" style="display:none; position:fixed; inset:0; background:rgba(0,0,0,0.45); z-index:1000; align-items:center; justify-content:center;">
    <div style="background:#fff; border-radius:12px; padding:2rem; max-width:480px; width:90%; box-shadow:0 8px 32px rgba(0,0,0,0.18);">
        <h2 style="font-size:1.15rem; font-weight:800; margin-bottom:0.75rem; color:var(--text-dark);">Xác nhận hủy vé</h2>
        <div class="cinema-msg cinema-msg--warning" style="margin-bottom:1.25rem;">
            ⚠️ Vé sau khi hủy sẽ <strong>không được hoàn tiền online</strong>. Vui lòng mang mã đơn đến <strong>quầy rạp</strong> để nhận lại tiền. Nhân viên sẽ xác nhận và hoàn tiền cho bạn tại chỗ.
        </div>
        <p style="font-size:0.9rem; color:var(--text-muted); margin-bottom:1.5rem;">Bạn có chắc chắn muốn hủy vé này không?</p>
        <div style="display:flex; gap:0.75rem; justify-content:flex-end;">
            <button type="button" class="btn btn-secondary" onclick="closeCancelModal()">Quay lại</button>
            <form id="cancelForm" method="post" action="booking/cancel" style="display:inline;">
                <input type="hidden" name="bookingId" id="cancelBookingId">
                <button type="submit" class="btn btn-danger">Xác nhận hủy</button>
            </form>
        </div>
    </div>
</div>

<jsp:include page="/components/footer.jsp"/>

<script>
    function showCancelWarning(bookingId) {
        document.getElementById('cancelBookingId').value = bookingId;
        var modal = document.getElementById('cancelModal');
        modal.style.display = 'flex';
    }
    function closeCancelModal() {
        document.getElementById('cancelModal').style.display = 'none';
    }
    document.getElementById('cancelModal').addEventListener('click', function(e) {
        if (e.target === this) closeCancelModal();
    });
</script>
</body>
</html>

