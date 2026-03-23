<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chọn ghế - Đổi vé</title>
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
                    <c:out value="${newShowtime.movie.title}"/> —
                    <c:out value="${newShowtime.room.roomName}"/> —
                    <fmt:formatNumber value="${newShowtime.startTime.hour}" minIntegerDigits="2"/>:<fmt:formatNumber value="${newShowtime.startTime.minute}" minIntegerDigits="2"/>
                    ${newShowtime.startTime.dayOfMonth}/${newShowtime.startTime.monthValue}/${newShowtime.startTime.year}
                </p>
            </div>
            <a href="booking/exchange?bookingId=${booking.bookingId}" class="btn btn-secondary">Quay lại</a>
        </div>

        <c:if test="${not empty error}">
            <div class="cinema-msg cinema-msg--error" style="margin-bottom:1rem;">${error}</div>
        </c:if>

        <div class="card" style="padding:1.5rem;">
            <%-- Gợi ý ghế cũ --%>
            <div style="font-size:0.85rem; color:var(--text-muted); margin-bottom:1rem;">
                Ghế hiện tại của bạn: <strong>
                <c:forEach items="${oldSeats}" var="bs" varStatus="loop">
                    ${bs.seat.rowLabel}${bs.seat.seatNumber}<c:if test="${!loop.last}">, </c:if>
                </c:forEach></strong>
                — ghế tương đương đã được chọn sẵn (nếu còn trống). Bạn có thể chọn lại.
            </div>

            <form method="post" action="booking/exchange-seats" id="seatForm">
                <input type="hidden" name="bookingId" value="${booking.bookingId}">
                <input type="hidden" name="newShowtimeId" value="${newShowtime.showtimeId}">

                <%-- Màn hình --%>
                <div style="text-align:center; margin-bottom:1.25rem;">
                    <div style="display:inline-block; background:#cbd5e1; color:#475569; font-size:0.8rem; font-weight:600; padding:0.35rem 3rem; border-radius:4px 4px 0 0; letter-spacing:0.05em;">MÀN HÌNH</div>
                    <div style="height:4px; background:linear-gradient(90deg,transparent,#94a3b8,transparent); margin-bottom:1.25rem;"></div>
                </div>

                <%-- Sơ đồ ghế --%>
                <div style="display:flex; flex-direction:column; gap:0.5rem; align-items:center;">
                    <c:set var="currentRow" value=""/>
                    <c:forEach items="${seats}" var="seat">
                        <c:if test="${seat.rowLabel != currentRow}">
                            <c:if test="${currentRow != ''}"></div></c:if>
                            <c:set var="currentRow" value="${seat.rowLabel}"/>
                            <div style="display:flex; gap:0.4rem; align-items:center;">
                            <span style="width:22px; text-align:right; font-size:0.8rem; font-weight:700; color:var(--text-muted); margin-right:0.3rem;">${seat.rowLabel}</span>
                        </c:if>
                        <c:set var="taken"   value="${takenSeatIds.contains(seat.seatId)}"/>
                        <c:set var="presel"  value="${currentSeatIds.contains(seat.seatId)}"/>
                        <button type="button"
                                class="seat-tile
                                       ${taken  ? 'seat-tile--taken'    : ''}
                                       ${presel ? 'seat-tile--selected' : ''}
                                       ${seat.seatType == 'VIP' ? 'seat-tile--vip' : ''}"
                                data-seat-id="${seat.seatId}"
                                title="${seat.rowLabel}${seat.seatNumber} (${seat.seatType})"
                                ${taken ? 'disabled' : ''}>
                            ${seat.seatNumber}
                        </button>
                    </c:forEach>
                    <c:if test="${not empty seats}"></div></c:if>
                </div>

                <input type="hidden" name="seatIds" id="seatIdsInput">

                <div style="display:flex; justify-content:space-between; align-items:center; margin-top:1.5rem; flex-wrap:wrap; gap:0.75rem;">
                    <div style="display:flex; flex-wrap:wrap; gap:0.75rem; font-size:0.85rem;">
                        <span><span style="display:inline-block;width:14px;height:14px;border-radius:4px;background:var(--primary);margin-right:4px;"></span>Đang chọn</span>
                        <span><span style="display:inline-block;width:14px;height:14px;border-radius:4px;background:var(--bg-white);border:1px solid var(--border-light);margin-right:4px;"></span>Trống</span>
                        <span><span style="display:inline-block;width:14px;height:14px;border-radius:4px;background:#fef3c7;border:1px solid #f59e0b;margin-right:4px;"></span>VIP</span>
                        <span><span style="display:inline-block;width:14px;height:14px;border-radius:4px;background:#e5e7eb;border:1px solid #d1d5db;margin-right:4px;"></span>Đã đặt</span>
                    </div>
                    <div style="display:flex; align-items:center; gap:1rem;">
                        <span id="selectedCount" style="font-size:0.9rem; color:var(--text-muted);">Đã chọn: <strong>0</strong> ghế</span>
                        <button type="submit" class="btn btn-primary">Tiếp tục</button>
                    </div>
                </div>
            </form>
        </div>
    </div>
</main>

<jsp:include page="/components/footer.jsp"/>

<script>
    const seatIdsInput   = document.getElementById('seatIdsInput');
    const selectedCount  = document.getElementById('selectedCount');
    const preSelectedIds = [<c:forEach items="${currentSeatIds}" var="id" varStatus="s">${id}<c:if test="${!s.last}">,</c:if></c:forEach>];

    function syncInput() {
        const selected = Array.from(document.querySelectorAll('.seat-tile--selected'))
            .map(b => b.getAttribute('data-seat-id'));
        seatIdsInput.value = selected.join(',');
        selectedCount.innerHTML = 'Đã chọn: <strong>' + selected.length + '</strong> ghế';
    }

    document.querySelectorAll('.seat-tile:not(.seat-tile--taken)').forEach(btn => {
        btn.addEventListener('click', function () {
            this.classList.toggle('seat-tile--selected');
            syncInput();
        });
    });

    // Init: sync hidden input từ ghế đã pre-select
    syncInput();

    document.getElementById('seatForm').addEventListener('submit', function (e) {
        if (!seatIdsInput.value) {
            e.preventDefault();
            alert('Vui lòng chọn ít nhất 1 ghế.');
        }
    });
</script>

<style>
    .seat-tile { width:40px; height:40px; border-radius:8px; border:1px solid var(--border-light); background:var(--bg-white); color:var(--text-dark); font-size:0.8rem; font-weight:600; display:inline-flex; align-items:center; justify-content:center; cursor:pointer; transition:background-color 0.15s,border-color 0.15s,color 0.15s,transform 0.05s; }
    .seat-tile--selected { background:var(--primary); border-color:var(--primary); color:#fff; transform:translateY(1px); }
    .seat-tile--vip { background:#fef3c7; border-color:#f59e0b; color:#92400e; }
    .seat-tile--vip.seat-tile--selected { background:var(--primary); border-color:var(--primary); color:#fff; }
    .seat-tile--taken { background:#e5e7eb; border-color:#d1d5db; color:#6b7280; cursor:not-allowed; }
</style>
</body>
</html>
