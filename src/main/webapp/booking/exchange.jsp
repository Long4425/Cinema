<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đổi vé / Chuyển suất</title>
    <base href="${pageContext.request.contextPath}/">
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/header.css">
    <link rel="stylesheet" href="css/footer.css">
    <link rel="stylesheet" href="css/dashboard.css">
    <link rel="stylesheet" href="css/table.css">
    <link rel="stylesheet" href="css/button.css">
    <link rel="stylesheet" href="css/badge.css">
    <link rel="stylesheet" href="css/message.css">
    <link rel="stylesheet" href="css/form.css">
</head>
<body class="home-layout">
<jsp:include page="/components/header.jsp"/>

<main class="home-main">
    <div class="container container--lg">
        <div class="page-header">
            <div>
                <h1 class="page-title">Đổi vé / Chuyển suất</h1>
                <p class="page-subtitle">Chọn ngày và suất chiếu mới cho đơn #${booking.bookingId}.</p>
            </div>
            <a href="profile/bookings" class="btn btn-secondary">Quay lại</a>
        </div>

        <c:if test="${not empty sessionScope.error}">
            <div class="cinema-msg cinema-msg--error" style="margin-bottom:1rem;">${sessionScope.error}</div>
            <c:remove var="error" scope="session"/>
        </c:if>

        <%-- Thông tin suất hiện tại --%>
        <div class="card" style="padding:1.25rem; margin-bottom:1.25rem;">
            <h2 style="font-size:1rem; font-weight:700; margin-bottom:0.75rem;">Suất chiếu hiện tại</h2>
            <div style="display:flex; flex-wrap:wrap; gap:1.5rem; font-size:0.9rem;">
                <div><span style="color:var(--text-muted);">Phim: </span><strong><c:out value="${currentShowtime.movie.title}"/></strong></div>
                <div><span style="color:var(--text-muted);">Phòng: </span><strong><c:out value="${currentShowtime.room.roomName}"/></strong></div>
                <div>
                    <span style="color:var(--text-muted);">Giờ chiếu: </span>
                    <strong>
                        <fmt:formatNumber value="${currentShowtime.startTime.hour}" minIntegerDigits="2"/>:<fmt:formatNumber value="${currentShowtime.startTime.minute}" minIntegerDigits="2"/>
                        ${currentShowtime.startTime.dayOfMonth}/${currentShowtime.startTime.monthValue}/${currentShowtime.startTime.year}
                    </strong>
                </div>
                <div><span style="color:var(--text-muted);">Số ghế: </span><strong>${seatCount}</strong></div>
                <div>
                    <span style="color:var(--text-muted);">Giá/ghế: </span>
                    <strong><fmt:formatNumber value="${oldSeatPrice}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></strong>
                </div>
            </div>
            <div style="margin-top:0.75rem; font-size:0.85rem; color:var(--text-muted);">
                Ghế:
                <c:forEach items="${currentSeats}" var="bs" varStatus="loop">
                    <strong>${bs.seat.rowLabel}${bs.seat.seatNumber}</strong><c:if test="${!loop.last}">, </c:if>
                </c:forEach>
            </div>
        </div>

        <%-- Bước 1: Chọn ngày --%>
        <div class="card" style="padding:1.25rem; margin-bottom:1.25rem;">
            <h2 style="font-size:1rem; font-weight:700; margin-bottom:1rem;">Chọn ngày</h2>

            <c:choose>
                <c:when test="${empty availableDates}">
                    <div class="cinema-msg cinema-msg--warning">
                        Hiện không có suất chiếu nào khác của phim này trong thời gian tới.
                    </div>
                </c:when>
                <c:otherwise>
                    <div style="display:flex; flex-wrap:wrap; gap:0.6rem;">
                        <c:forEach items="${availableDates}" var="d">
                            <%-- Format ngày hiển thị --%>
                            <c:set var="dStr" value="${d}"/>
                            <a href="booking/exchange?bookingId=${booking.bookingId}&date=${dStr}"
                               class="btn ${selectedDate == dStr ? 'btn-primary' : 'btn-secondary'}"
                               style="min-width:110px; text-align:center;">
                                ${d.dayOfMonth}/${d.monthValue}/${d.year}
                            </a>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <%-- Bước 2: Danh sách suất của ngày đã chọn --%>
        <c:if test="${not empty selectedDate}">
            <div class="card" style="padding:1.25rem;">
                <h2 style="font-size:1rem; font-weight:700; margin-bottom:1rem;">
                    Suất chiếu ngày
                    <c:forEach items="${availableDates}" var="d">
                        <c:if test="${d.toString() == selectedDate}">
                            ${d.dayOfMonth}/${d.monthValue}/${d.year}
                        </c:if>
                    </c:forEach>
                </h2>

                <c:choose>
                    <c:when test="${empty showtimesForDate}">
                        <div class="cinema-msg cinema-msg--warning">
                            Không còn suất nào hợp lệ trong ngày này (cần trước giờ chiếu ít nhất 30 phút).
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="table-wrap">
                            <table class="table">
                                <thead>
                                <tr>
                                    <th>Giờ chiếu</th>
                                    <th>Phòng</th>
                                    <th>Giá/ghế</th>
                                    <th>Phụ thu</th>
                                    <th style="width:130px;"></th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:forEach items="${showtimesForDate}" var="s">
                                    <c:set var="diff" value="${s.basePrice - oldSeatPrice}"/>
                                    <c:set var="surcharge" value="${diff > 0 ? diff * seatCount : 0}"/>
                                    <tr>
                                        <td style="font-weight:600;">
                                            <fmt:formatNumber value="${s.startTime.hour}" minIntegerDigits="2"/>:<fmt:formatNumber value="${s.startTime.minute}" minIntegerDigits="2"/>
                                        </td>
                                        <td>
                                            <c:out value="${s.room.roomName}"/>
                                            <span class="badge badge-secondary" style="font-size:0.72rem; margin-left:4px;">${s.room.roomType}</span>
                                        </td>
                                        <td>
                                            <fmt:formatNumber value="${s.basePrice}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                            <c:if test="${diff > 0}">
                                                <span class="badge badge-warning" style="font-size:0.72rem; margin-left:4px;">
                                                    +<fmt:formatNumber value="${diff}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                                </span>
                                            </c:if>
                                            <c:if test="${diff < 0}">
                                                <span class="badge badge-success" style="font-size:0.72rem; margin-left:4px;">
                                                    <fmt:formatNumber value="${diff}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                                </span>
                                            </c:if>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${surcharge > 0}">
                                                    <span style="color:#d97706; font-weight:600;">
                                                        +<fmt:formatNumber value="${surcharge}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                                    </span>
                                                    <c:choose>
                                                        <c:when test="${sessionScope.user.role.roleCode == 'CUSTOMER'}">
                                                            <div style="font-size:0.75rem; color:var(--text-muted);">Thanh toán VNPay</div>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <div style="font-size:0.75rem; color:var(--text-muted);">Thu tại quầy</div>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="color:#16a34a; font-weight:600;">Miễn phụ thu</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <a href="booking/exchange-seats?bookingId=${booking.bookingId}&newShowtimeId=${s.showtimeId}"
                                               class="btn btn-sm btn-primary">
                                                Chọn suất này
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </c:if>
    </div>
</main>

<jsp:include page="/components/footer.jsp"/>
</body>
</html>
