<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chọn ghế - Đặt vé</title>
    <base href="${pageContext.request.contextPath}/">
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/header.css">
    <link rel="stylesheet" href="css/footer.css">
    <link rel="stylesheet" href="css/dashboard.css">
    <link rel="stylesheet" href="css/button.css">
    <link rel="stylesheet" href="css/message.css">
</head>
<body class="home-layout">
<jsp:include page="/components/header.jsp"/>

<main class="home-main">
    <div class="container container--lg">
        <div class="page-header">
            <div>
                <h1 class="page-title">Chọn ghế</h1>
                <p class="page-subtitle">
                    <c:out value="${showtime.movie.title}"/>
                    -
                    <c:out value="${showtime.room.roomName}"/>
                    -
                    <fmt:formatNumber value="${showtime.startTime.hour}" minIntegerDigits="2"/>:<fmt:formatNumber value="${showtime.startTime.minute}" minIntegerDigits="2"/>
                    <c:out value="${showtime.startTime.dayOfMonth}"/>/<c:out value="${showtime.startTime.monthValue}"/>/<c:out value="${showtime.startTime.year}"/>
                </p>
            </div>
        </div>

        <c:if test="${not empty error}">
            <div class="cinema-msg cinema-msg--error" style="margin-bottom: 1rem;">
                ${error}
            </div>
        </c:if>

        <div class="card" style="padding: 1.5rem;">
            <form method="post" action="booking/seat-selection">
                <input type="hidden" name="showtimeId" value="${showtime.showtimeId}">

                <div class="seat-map-hint" style="margin-bottom: 0.75rem; font-size: 0.9rem; color: var(--text-muted);">
                    Nhấp để chọn/bỏ chọn ghế. Ghế đã có người đặt sẽ bị khóa.
                </div>

                <%-- Màn hình (screen indicator) --%>
                <div style="text-align:center; margin-bottom:1.25rem;">
                    <div style="display:inline-block; background:#cbd5e1; color:#475569; font-size:0.8rem; font-weight:600; padding:0.35rem 3rem; border-radius:4px 4px 0 0; letter-spacing:0.05em;">
                        MÀN HÌNH
                    </div>
                    <div style="height:4px; background:linear-gradient(90deg,transparent,#94a3b8,transparent); margin-bottom:1.25rem;"></div>
                </div>

                <%-- Group ghế theo từng hàng (rowLabel) --%>
                <div class="seat-map-grid" style="display:flex; flex-direction:column; gap:0.5rem; align-items:center;">
                    <c:set var="currentRow" value=""/>
                    <c:forEach items="${seats}" var="seat">
                        <c:if test="${seat.rowLabel != currentRow}">
                            <c:if test="${currentRow != ''}">
                                </div>
                            </c:if>
                            <c:set var="currentRow" value="${seat.rowLabel}"/>
                            <div style="display:flex; gap:0.4rem; align-items:center;">
                            <span style="width:22px; text-align:right; font-size:0.8rem; font-weight:700; color:var(--text-muted); margin-right:0.3rem;">${seat.rowLabel}</span>
                        </c:if>
                        <c:set var="taken" value="${takenSeatIds.contains(seat.seatId)}"/>
                        <button type="button"
                                class="seat-tile ${taken ? 'seat-tile--taken' : ''} ${seat.seatType == 'VIP' ? 'seat-tile--vip' : ''}"
                                data-seat-id="${seat.seatId}"
                                title="${seat.rowLabel}${seat.seatNumber} (${seat.seatType})"
                                ${taken ? 'disabled' : ''}>
                            ${seat.seatNumber}
                        </button>
                    </c:forEach>
                    <c:if test="${not empty seats}">
                        </div>
                    </c:if>
                </div>

                <input type="hidden" name="seatIds" id="seatIdsInput">

                <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 1.5rem; flex-wrap: wrap; gap: 0.75rem;">
                    <div class="seat-legend" style="display: flex; flex-wrap: wrap; gap: 0.75rem; font-size: 0.85rem;">
                        <span><span style="display:inline-block;width:14px;height:14px;border-radius:4px;background:var(--primary);margin-right:4px;"></span>Đang chọn</span>
                        <span><span style="display:inline-block;width:14px;height:14px;border-radius:4px;background:var(--bg-white);border:1px solid var(--border-light);margin-right:4px;"></span>Trống (Standard)</span>
                        <span><span style="display:inline-block;width:14px;height:14px;border-radius:4px;background:#fef3c7;border:1px solid #f59e0b;margin-right:4px;"></span>VIP</span>
                        <span><span style="display:inline-block;width:14px;height:14px;border-radius:4px;background:#e5e7eb;border:1px solid #d1d5db;margin-right:4px;"></span>Đã đặt</span>
                    </div>
                    <c:choose>
                        <c:when test="${not empty sessionScope.user}">
                            <button type="submit" class="btn btn-primary">
                                Tiếp tục
                            </button>
                        </c:when>
                        <c:otherwise>
                            <a id="loginBtn" href="#" class="btn btn-primary">
                                Đăng nhập để đặt vé
                            </a>
                        </c:otherwise>
                    </c:choose>
                </div>
            </form>
        </div>
    </div>
</main>

<jsp:include page="/components/footer.jsp"/>

<script>
    (function () {
        const loginBtn = document.getElementById('loginBtn');
        if (loginBtn) {
            loginBtn.href = '${pageContext.request.contextPath}/login?msg='
                + encodeURIComponent('Xin hãy đăng nhập để tiếp tục đặt vé xem phim.');
        }

        const seatButtons = document.querySelectorAll('.seat-tile:not(.seat-tile--taken)');
        const seatIdsInput = document.getElementById('seatIdsInput');

        function updateHiddenInput() {
            const selectedIds = Array.from(document.querySelectorAll('.seat-tile--selected'))
                .map(btn => btn.getAttribute('data-seat-id'));
            seatIdsInput.value = selectedIds.join(',');
        }

        seatButtons.forEach(btn => {
            btn.addEventListener('click', function () {
                this.classList.toggle('seat-tile--selected');
                updateHiddenInput();
            });
        });
    })();
</script>

<style>
    .seat-tile {
        width: 40px;
        height: 40px;
        border-radius: 8px;
        border: 1px solid var(--border-light);
        background: var(--bg-white);
        color: var(--text-dark);
        font-size: 0.8rem;
        font-weight: 600;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        transition: background-color 0.15s, border-color 0.15s, color 0.15s, transform 0.05s;
    }

    .seat-tile--selected {
        background: var(--primary);
        border-color: var(--primary);
        color: #fff;
        transform: translateY(1px);
    }

    .seat-tile--vip {
        background: #fef3c7;
        border-color: #f59e0b;
        color: #92400e;
    }

    .seat-tile--vip.seat-tile--selected {
        background: var(--primary);
        border-color: var(--primary);
        color: #fff;
    }

    .seat-tile--taken {
        background: #e5e7eb;
        border-color: #d1d5db;
        color: #6b7280;
        cursor: not-allowed;
    }

    .seat-tile:disabled {
        cursor: not-allowed;
    }
</style>

</body>
</html>

