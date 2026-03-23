<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
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
    <style>
        .loyalty-panel {
            display: flex;
            gap: 1rem;
            margin-bottom: 1.25rem;
            flex-wrap: wrap;
        }
        .loyalty-card {
            flex: 1;
            min-width: 220px;
            border-radius: 12px;
            padding: 1.1rem 1.4rem;
            display: flex;
            align-items: center;
            gap: 1rem;
        }
        .loyalty-card--points {
            background: linear-gradient(135deg, #fffbeb 0%, #fef3c7 100%);
            border: 1px solid #fcd34d;
        }
        .loyalty-card--vouchers {
            background: linear-gradient(135deg, #f0fdf4 0%, #dcfce7 100%);
            border: 1px solid #86efac;
        }
        .loyalty-card__icon {
            font-size: 2rem;
            line-height: 1;
        }
        .loyalty-card__label {
            font-size: 0.78rem;
            color: var(--text-muted);
            margin-bottom: 0.15rem;
        }
        .loyalty-card__value {
            font-size: 1.5rem;
            font-weight: 800;
            color: var(--text-dark);
            line-height: 1.1;
        }
        .loyalty-card__hint {
            font-size: 0.75rem;
            color: var(--text-muted);
            margin-top: 0.2rem;
        }
        .voucher-list {
            margin-top: 0.75rem;
        }
        .voucher-item {
            display: flex;
            align-items: center;
            justify-content: space-between;
            background: #fff;
            border: 1.5px dashed #22c55e;
            border-radius: 8px;
            padding: 0.5rem 0.9rem;
            margin-bottom: 0.5rem;
            font-size: 0.875rem;
        }
        .voucher-item__code {
            font-family: monospace;
            font-weight: 700;
            font-size: 0.95rem;
            color: #15803d;
            letter-spacing: 0.04em;
        }
        .voucher-item__value {
            font-weight: 600;
            color: #166534;
        }
        .voucher-item__exp {
            font-size: 0.75rem;
            color: var(--text-muted);
        }
    </style>
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
            <a href="profile/redeem-points" class="btn btn-primary">
                &#127775; Đổi điểm (${sessionScope.user.loyaltyPoint} điểm)
            </a>
        </div>

        <%-- UC-24/25: Panel điểm tích lũy & voucher --%>
        <div class="loyalty-panel">
            <div class="loyalty-card loyalty-card--points">
                <div class="loyalty-card__icon">&#127775;</div>
                <div>
                    <div class="loyalty-card__label">Điểm tích lũy</div>
                    <div class="loyalty-card__value">${sessionScope.user.loyaltyPoint}</div>
                    <div class="loyalty-card__hint">10 điểm = voucher giảm 20.000₫</div>
                </div>
            </div>
            <div class="loyalty-card loyalty-card--vouchers">
                <div class="loyalty-card__icon">&#127873;</div>
                <div style="flex:1;">
                    <div class="loyalty-card__label">Voucher từ điểm</div>
                    <c:choose>
                        <c:when test="${empty myVouchers}">
                            <div class="loyalty-card__value">0</div>
                            <div class="loyalty-card__hint">Chưa có voucher nào</div>
                        </c:when>
                        <c:otherwise>
                            <div class="loyalty-card__value">${fn:length(myVouchers)}</div>
                            <div class="voucher-list">
                                <c:forEach items="${myVouchers}" var="v">
                                    <div class="voucher-item">
                                        <span class="voucher-item__code">${v.code}</span>
                                        <span class="voucher-item__value">-20.000₫</span>
                                        <span class="voucher-item__exp">HSD: ${v.expiredAt.dayOfMonth}/${v.expiredAt.monthValue}/${v.expiredAt.year}</span>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
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
                                <th>Điểm +</th>
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
                                        <c:choose>
                                            <c:when test="${b.status == 'Confirmed' and b.pointsEarned > 0}">
                                                <span style="color:#d97706; font-weight:600;">+${b.pointsEarned}</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span style="color:var(--text-muted);">—</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div class="table-actions">
                                            <a href="booking/summary?bookingId=${b.bookingId}" class="btn btn-sm btn-secondary">Xem vé</a>
                                            <c:if test="${exchangeableMap[b.bookingId]}">
                                                <a href="booking/exchange?bookingId=${b.bookingId}" class="btn btn-sm btn-primary">Đổi suất</a>
                                            </c:if>
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

