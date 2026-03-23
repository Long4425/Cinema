<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đặt vé tại quầy - Chọn ghế</title>
    <base href="${pageContext.request.contextPath}/">
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/header.css">
    <link rel="stylesheet" href="css/sidebar.css">
    <link rel="stylesheet" href="css/footer.css">
    <link rel="stylesheet" href="css/dashboard.css">
    <link rel="stylesheet" href="css/button.css">
    <link rel="stylesheet" href="css/message.css">
    <link rel="stylesheet" href="css/form.css">
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
                    <h1 class="page-title">Đặt vé tại quầy - Chọn ghế</h1>
                    <p class="page-subtitle">
                        <c:out value="${showtime.movie.title}"/> &ndash;
                        <c:out value="${showtime.room.roomName}"/> |
                        <fmt:formatNumber value="${showtime.startTime.hour}" minIntegerDigits="2"/>:<fmt:formatNumber value="${showtime.startTime.minute}" minIntegerDigits="2"/>
                        ${showtime.startTime.dayOfMonth}/${showtime.startTime.monthValue}/${showtime.startTime.year}
                    </p>
                </div>
            </div>

            <c:if test="${not empty error}">
                <div class="cinema-msg cinema-msg--error" style="margin-bottom:1rem;">${error}</div>
            </c:if>

            <div style="display:grid;grid-template-columns:1fr 320px;gap:1.5rem;align-items:flex-start;">

                <%-- Sơ đồ ghế --%>
                <div class="card" style="padding:1.5rem;">
                    <form method="post" action="counter/seat-selection" id="seatForm">
                        <input type="hidden" name="showtimeId" value="${showtime.showtimeId}">
                        <input type="hidden" name="seatIds" id="seatIdsInput">
                        <input type="hidden" name="customerId" id="customerIdInput" value="">

                        <div style="text-align:center;margin-bottom:1.25rem;">
                            <div style="display:inline-block;background:#cbd5e1;color:#475569;font-size:0.8rem;font-weight:600;padding:0.35rem 3rem;border-radius:4px 4px 0 0;letter-spacing:0.05em;">
                                MÀN HÌNH
                            </div>
                            <div style="height:4px;background:linear-gradient(90deg,transparent,#94a3b8,transparent);margin-bottom:1.25rem;"></div>
                        </div>

                        <div style="display:flex;flex-direction:column;gap:0.5rem;align-items:center;">
                            <c:set var="currentRow" value=""/>
                            <c:forEach items="${seats}" var="seat">
                                <c:if test="${seat.rowLabel != currentRow}">
                                    <c:if test="${currentRow != ''}"></div></c:if>
                                    <c:set var="currentRow" value="${seat.rowLabel}"/>
                                    <div style="display:flex;gap:0.4rem;align-items:center;">
                                    <span style="width:22px;text-align:right;font-size:0.8rem;font-weight:700;color:var(--text-muted);margin-right:0.3rem;">${seat.rowLabel}</span>
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
                            <c:if test="${not empty seats}"></div></c:if>
                        </div>

                        <div style="display:flex;justify-content:space-between;align-items:center;margin-top:1.5rem;flex-wrap:wrap;gap:0.75rem;">
                            <div style="display:flex;flex-wrap:wrap;gap:0.75rem;font-size:0.85rem;">
                                <span><span style="display:inline-block;width:14px;height:14px;border-radius:4px;background:var(--primary);margin-right:4px;"></span>Đang chọn</span>
                                <span><span style="display:inline-block;width:14px;height:14px;border-radius:4px;background:var(--bg-white);border:1px solid var(--border-light);margin-right:4px;"></span>Trống (Standard)</span>
                                <span><span style="display:inline-block;width:14px;height:14px;border-radius:4px;background:#fef3c7;border:1px solid #f59e0b;margin-right:4px;"></span>VIP</span>
                                <span><span style="display:inline-block;width:14px;height:14px;border-radius:4px;background:#e5e7eb;border:1px solid #d1d5db;margin-right:4px;"></span>Đã đặt</span>
                            </div>
                            <div style="display:flex;gap:0.5rem;align-items:center;">
                                <span id="selectedCount" style="font-size:0.9rem;color:var(--text-muted);">Chưa chọn ghế nào</span>
                                <button type="submit" class="btn btn-primary" id="submitBtn" disabled>
                                    Tiếp tục
                                </button>
                            </div>
                        </div>
                    </form>
                </div>

                <%-- Tìm kiếm khách hàng --%>
                <div style="display:flex;flex-direction:column;gap:1rem;">
                    <div class="card" style="padding:1.25rem;">
                        <h2 style="font-size:1rem;font-weight:700;margin-bottom:0.75rem;">Tìm khách hàng</h2>
                        <form method="get" action="counter/seat-selection" style="display:flex;flex-direction:column;gap:0.6rem;">
                            <input type="hidden" name="showtimeId" value="${showtime.showtimeId}">
                            <input type="text" name="search" value="${search}" class="form-input"
                                   placeholder="Email hoặc số điện thoại...">
                            <button type="submit" class="btn btn-secondary">Tìm kiếm</button>
                        </form>

                        <c:if test="${not empty searchMsg}">
                            <p style="font-size:0.85rem;color:#b91c1c;margin-top:0.5rem;">${searchMsg}</p>
                        </c:if>

                        <c:if test="${not empty foundCustomer}">
                            <div style="margin-top:0.75rem;border:1.5px solid #22c55e;border-radius:10px;padding:0.75rem;background:#f0fdf4;">
                                <div style="font-weight:700;color:#15803d;font-size:0.9rem;"><c:out value="${foundCustomer.fullName}"/></div>
                                <div style="font-size:0.8rem;color:var(--text-muted);"><c:out value="${foundCustomer.email}"/></div>
                                <c:if test="${not empty foundCustomer.phone}">
                                    <div style="font-size:0.8rem;color:var(--text-muted);">SĐT: <c:out value="${foundCustomer.phone}"/></div>
                                </c:if>
                                <div style="font-size:0.8rem;margin-top:0.3rem;">
                                    Điểm tích lũy: <strong style="color:var(--primary);">${foundCustomer.loyaltyPoint}</strong>
                                </div>
                                <button type="button" class="btn btn-sm btn-primary" style="margin-top:0.5rem;width:100%;"
                                        onclick="selectCustomer(${foundCustomer.userId}, '${foundCustomer.fullName}')">
                                    Chọn khách này
                                </button>
                            </div>
                        </c:if>

                        <div id="selectedCustomerBox" style="display:none;margin-top:0.75rem;border:1.5px solid var(--primary);border-radius:10px;padding:0.75rem;background:var(--primary-light);">
                            <div style="font-size:0.8rem;color:var(--text-muted);margin-bottom:0.25rem;">KHÁCH HÀNG ĐÃ CHỌN</div>
                            <div id="selectedCustomerName" style="font-weight:700;color:var(--primary);"></div>
                            <button type="button" class="btn btn-sm btn-secondary" style="margin-top:0.4rem;"
                                    onclick="clearCustomer()">Xóa lựa chọn</button>
                        </div>
                    </div>

                    <div class="card" style="padding:1.25rem;font-size:0.85rem;color:var(--text-muted);line-height:1.6;">
                        <strong style="color:var(--text-dark);">Lưu ý:</strong><br>
                        - Tìm khách theo email để áp dụng voucher cá nhân và tích điểm.<br>
                        - Nếu không tìm thấy, đặt vé vãng lai (không tích điểm).
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>

<jsp:include page="/components/footer.jsp"/>

<script>
    let selectedCustomerId = '';
    let selectedCustomerName = '';

    function selectCustomer(id, name) {
        selectedCustomerId = id;
        selectedCustomerName = name;
        document.getElementById('customerIdInput').value = id;
        document.getElementById('selectedCustomerName').textContent = name;
        document.getElementById('selectedCustomerBox').style.display = 'block';
    }

    function clearCustomer() {
        selectedCustomerId = '';
        document.getElementById('customerIdInput').value = '';
        document.getElementById('selectedCustomerBox').style.display = 'none';
    }

    const seatIdsInput = document.getElementById('seatIdsInput');
    const submitBtn = document.getElementById('submitBtn');
    const selectedCount = document.getElementById('selectedCount');

    function updateHiddenInput() {
        const selected = Array.from(document.querySelectorAll('.seat-tile--selected'));
        seatIdsInput.value = selected.map(b => b.getAttribute('data-seat-id')).join(',');
        if (selected.length === 0) {
            selectedCount.textContent = 'Chưa chọn ghế nào';
            submitBtn.disabled = true;
        } else {
            selectedCount.textContent = 'Đã chọn ' + selected.length + ' ghế';
            submitBtn.disabled = false;
        }
    }

    document.querySelectorAll('.seat-tile:not(.seat-tile--taken)').forEach(btn => {
        btn.addEventListener('click', function () {
            this.classList.toggle('seat-tile--selected');
            updateHiddenInput();
        });
    });
</script>

<style>
    .seat-tile { width:40px;height:40px;border-radius:8px;border:1px solid var(--border-light);background:var(--bg-white);color:var(--text-dark);font-size:0.8rem;font-weight:600;display:inline-flex;align-items:center;justify-content:center;cursor:pointer;transition:background-color 0.15s,border-color 0.15s,color 0.15s,transform 0.05s; }
    .seat-tile--selected { background:var(--primary);border-color:var(--primary);color:#fff;transform:translateY(1px); }
    .seat-tile--vip { background:#fef3c7;border-color:#f59e0b;color:#92400e; }
    .seat-tile--vip.seat-tile--selected { background:var(--primary);border-color:var(--primary);color:#fff; }
    .seat-tile--taken { background:#e5e7eb;border-color:#d1d5db;color:#6b7280;cursor:not-allowed; }
    .seat-tile:disabled { cursor:not-allowed; }
</style>
</body>
</html>
