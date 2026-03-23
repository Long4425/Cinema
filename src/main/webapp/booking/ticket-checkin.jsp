<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Soát vé / Check-in</title>
    <base href="${pageContext.request.contextPath}/">
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/header.css">
    <link rel="stylesheet" href="css/sidebar.css">
    <link rel="stylesheet" href="css/footer.css">
    <link rel="stylesheet" href="css/dashboard.css">
    <link rel="stylesheet" href="css/button.css">
    <link rel="stylesheet" href="css/table.css">
    <link rel="stylesheet" href="css/message.css">
    <link rel="stylesheet" href="css/form.css">
    <link rel="stylesheet" href="css/filter.css">
</head>
<body class="dashboard-layout">
<jsp:include page="/components/header.jsp"/>

<div class="dashboard-body">
    <jsp:include page="/components/sidebar.jsp"/>

    <main class="dashboard-main">
        <div class="dashboard-main__inner">
            <div class="page-header">
                <div>
                    <h1 class="page-title">Soát vé / Ticket check-in</h1>
                    <p class="page-subtitle">Tra cứu theo <strong>mã đơn</strong> hoặc <strong>email khách hàng</strong>.</p>
                </div>
            </div>

            <div class="card" style="padding:1.25rem;margin-bottom:1rem;">
                <form method="post" action="manager/ticket-checkin" class="search-filter-bar">
                    <div class="filter-field filter-field--grow">
                        <label for="keyword" class="form-label">Mã đơn / Email</label>
                        <input type="text" id="keyword" name="keyword"
                               value="${keyword}"
                               class="form-input" placeholder="VD: 123 hoặc customer@example.com">
                    </div>
                    <div class="filter-actions">
                        <button type="submit" class="btn btn-primary">Kiểm tra</button>
                    </div>
                </form>
            </div>

            <c:if test="${not empty error}">
                <div class="cinema-msg cinema-msg--error" style="margin-bottom:1rem;">
                    ${error}
                </div>
            </c:if>

            <c:if test="${not empty booking}">
                <div class="card" style="padding:1.5rem;display:flex;flex-direction:column;gap:1rem;">
                    <div style="display:flex;justify-content:space-between;align-items:center;gap:1rem;flex-wrap:wrap;">
                        <div>
                            <h2 style="font-size:1rem;margin-bottom:0.35rem;">
                                Đơn #${booking.bookingId}
                            </h2>
                            <p style="font-size:0.9rem;margin:0;">
                                <c:if test="${not empty customer}">
                                    <strong>Khách hàng:</strong> <c:out value="${customer.fullName}"/> - <c:out value="${customer.email}"/><br>
                                </c:if>
                                <strong>Trạng thái đơn:</strong> ${booking.status}
                            </p>
                        </div>
                        <div>
                            <c:choose>
                                <c:when test="${isValid}">
                                    <span class="badge badge-success">Vé hợp lệ</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge badge-danger">Vé không hợp lệ</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <p style="font-size:0.9rem;margin:0;color:var(--text-muted);">
                        ${reason}
                    </p>

                    <div>
                        <h3 style="font-size:0.95rem;margin-bottom:0.35rem;">Thông tin suất chiếu</h3>
                        <p style="font-size:0.9rem;margin:0;">
                            <strong>Phim:</strong> <c:out value="${showtime.movieTitle}"/><br>
                            <strong>Phòng:</strong> <c:out value="${showtime.roomName}"/><br>
                            <strong>Giờ chiếu:</strong>
                            <fmt:formatDate value="${showtime.startTime}" pattern="HH:mm dd/MM/yyyy"/>
                        </p>
                    </div>

                    <div>
                        <h3 style="font-size:0.95rem;margin-bottom:0.35rem;">Ghế</h3>
                        <p style="font-size:0.9rem;margin:0;">
                            <c:forEach items="${bookingSeats}" var="bs" varStatus="loop">
                                ${bs.seat.rowLabel}${bs.seat.seatNumber}<c:if test="${!loop.last}">, </c:if>
                            </c:forEach>
                        </p>
                    </div>

                    <c:if test="${booking.status == 'Pending'}">
                        <div style="border-top:1px dashed var(--border-light);padding-top:0.75rem;">
                            <p style="font-size:0.9rem;margin-bottom:0.5rem;color:var(--text-muted);">
                                Đơn này đang chờ thanh toán. Nếu khách thanh toán tại quầy, bạn có thể mở màn hình xác nhận thu tiền.
                            </p>
                            <form method="get" action="manager/booking/cash-payment" style="display:inline;">
                                <input type="hidden" name="bookingId" value="${booking.bookingId}">
                                <button type="submit" class="btn btn-secondary">
                                    Mở màn hình thanh toán tại quầy
                                </button>
                            </form>
                        </div>
                    </c:if>
                </div>
            </c:if>
        </div>
    </main>
</div>

<jsp:include page="/components/footer.jsp"/>
</body>
</html>

