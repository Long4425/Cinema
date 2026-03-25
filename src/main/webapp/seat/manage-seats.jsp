<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cấu hình sơ đồ ghế | Cinema</title>
    <base href="${pageContext.request.scheme}://${pageContext.request.serverName}:${pageContext.request.serverPort}${pageContext.request.contextPath}/">
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/header.css">
    <link rel="stylesheet" href="css/sidebar.css">
    <link rel="stylesheet" href="css/footer.css">
    <link rel="stylesheet" href="css/dashboard.css">
    <link rel="stylesheet" href="css/form.css">
    <link rel="stylesheet" href="css/button.css">
    <link rel="stylesheet" href="css/message.css">
</head>
<body class="dashboard-layout">
<jsp:include page="/components/header.jsp"/>
<jsp:include page="/components/sidebar.jsp"/>

<main class="dashboard-main">
    <div style="display:flex; align-items:center; justify-content:space-between; gap:1rem; margin-bottom:1rem;">
        <h1 style="font-size:1.5rem; font-weight:800; color:var(--text-dark); margin:0;">Cấu hình sơ đồ ghế</h1>
        <a href="manager/rooms" class="btn btn-secondary">Quay lại phòng</a>
    </div>

    <c:if test="${not empty error}">
        <div class="cinema-msg cinema-msg--error" style="margin-bottom:1rem;">${error}</div>
    </c:if>

    <form method="get" action="manager/seats" class="profile-card" style="padding:1rem; border-radius:12px; margin-bottom:1rem;">
        <div style="display:flex; gap:12px; flex-wrap:wrap; align-items:flex-end;">
            <div class="form-group" style="min-width:320px; margin:0;">
                <label class="form-label" for="roomId">Chọn phòng</label>
                <select id="roomId" name="roomId" class="form-input" onchange="this.form.submit()">
                    <option value="">-- Chọn phòng --</option>
                    <c:forEach var="r" items="${rooms}">
                        <option value="${r.roomId}" ${room != null && room.roomId == r.roomId ? 'selected' : ''}>
                            ${r.roomName} (${r.roomType}) ${!r.active ? '[Inactive]' : ''}
                        </option>
                    </c:forEach>
                </select>
            </div>
        </div>
    </form>

    <c:if test="${room != null}">
        <div class="profile-card" style="padding:1rem; border-radius:12px; margin-bottom:1rem;">
            <h3 style="margin:0 0 0.75rem 0; color:var(--text-dark); font-weight:800;">Tạo lại sơ đồ ghế</h3>
            <form method="post" action="manager/seats" style="display:flex; gap:12px; flex-wrap:wrap; align-items:flex-end;">
                <input type="hidden" name="action" value="generate">
                <input type="hidden" name="roomId" value="${room.roomId}">
                <div class="form-group" style="min-width:160px; margin:0;">
                    <label class="form-label" for="rows">Số hàng</label>
                    <input id="rows" name="rows" type="number" min="1" max="26" class="form-input" value="8" required>
                </div>
                <div class="form-group" style="min-width:160px; margin:0;">
                    <label class="form-label" for="cols">Số cột</label>
                    <input id="cols" name="cols" type="number" min="1" max="30" class="form-input" value="10" required>
                </div>
                <div class="form-group" style="min-width:180px; margin:0;">
                    <label class="form-label" for="vipRows">Hàng VIP (từ A)</label>
                    <input id="vipRows" name="vipRows" type="number" min="0" max="26" class="form-input" value="2" required>
                </div>
                <div class="btn-row" style="margin:0;">
                    <button type="submit" class="btn btn-danger">Tạo lại</button>
                    <span class="form-hint">Tạo lại sẽ xóa toàn bộ ghế hiện có của phòng này.</span>
                </div>
            </form>
        </div>

        <div class="profile-card" style="padding:1rem; border-radius:12px;">
            <div style="display:flex; justify-content:space-between; align-items:center; gap:1rem; margin-bottom:0.75rem;">
                <h3 style="margin:0; color:var(--text-dark); font-weight:800;">Sơ đồ ghế</h3>
                <form method="post" action="manager/seats" id="bulkSeatForm" style="display:flex; gap:8px; align-items:center;">
                    <input type="hidden" name="action" value="updateType">
                    <input type="hidden" name="roomId" value="${room.roomId}">
                    <input type="hidden" name="seatIds" id="bulkSeatIds">
                    <select name="seatType" id="bulkSeatType" class="form-input" style="padding:6px 10px; min-width:130px;">
                        <option value="Standard">Standard</option>
                        <option value="VIP">VIP</option>
                        <option value="Couple">Couple</option>
                    </select>
                    <button type="submit" class="btn btn-primary btn-sm">Áp dụng cho ghế chọn</button>
                </form>
            </div>
            <div style="margin-bottom:0.5rem; font-size:0.85rem; color:var(--text-muted);">
                Click để chọn/bỏ chọn ghế. Giữ chuột và kéo để chọn nhiều ghế, sau đó chọn loại ghế và bấm "Áp dụng cho ghế chọn".
            </div>

            <div id="seatGrid" class="seat-grid" data-room-id="${room.roomId}"
                 style="display:grid; grid-template-columns: repeat(auto-fill, minmax(44px, 1fr)); gap:6px; max-width:640px;">
                <c:forEach var="s" items="${seats}">
                    <button type="button"
                            class="seat-tile seat-tile--${s.seatType}"
                            data-seat-id="${s.seatId}"
                            data-seat-type="${s.seatType}">
                        ${s.rowLabel}${s.seatNumber}
                    </button>
                </c:forEach>
                <c:if test="${empty seats}">
                    <div class="cinema-msg cinema-msg--info" style="grid-column:1/-1;">Phòng này chưa có ghế. Hãy tạo lại sơ đồ ghế.</div>
                </c:if>
            </div>
        </div>
    </c:if>
</main>

<jsp:include page="/components/footer.jsp"/>
<style>
    .seat-tile {
        border-radius: 8px;
        border: 1px solid var(--border-light);
        background: var(--bg-white);
        padding: 6px 4px;
        font-size: 0.8rem;
        cursor: pointer;
        text-align: center;
        user-select: none;
    }
    .seat-tile--Standard { background: #e5f3ff; border-color: #bfdbfe; }
    .seat-tile--VIP { background: #fef3c7; border-color: #fcd34d; }
    .seat-tile--Couple { background: #fee2e2; border-color: #fecaca; }
    .seat-tile.seat-tile--selected {
        outline: 2px solid var(--primary);
        outline-offset: 0;
        box-shadow: 0 0 0 1px #2563eb;
    }
</style>
<script>
    (function () {
        const grid = document.getElementById('seatGrid');
        const bulkInput = document.getElementById('bulkSeatIds');
        if (!grid || !bulkInput) return;

        const selected = new Set();
        let isDragging = false;
        let dragMoved = false;
        let dragAdd = true;

        function updateBulkInput() {
            bulkInput.value = Array.from(selected).join(',');
        }

        function toggleSeat(seatEl, add) {
            const id = seatEl.getAttribute('data-seat-id');
            if (!id) return;
            if (add) {
                selected.add(id);
                seatEl.classList.add('seat-tile--selected');
            } else {
                selected.delete(id);
                seatEl.classList.remove('seat-tile--selected');
            }
        }

        grid.addEventListener('mousedown', function (e) {
            const seat = e.target.closest('.seat-tile');
            if (!seat) return;
            isDragging = true;
            dragMoved = false;
            const currentlySelected = seat.classList.contains('seat-tile--selected');
            dragAdd = !currentlySelected;
            toggleSeat(seat, dragAdd);
            updateBulkInput();
            e.preventDefault();
        });

        grid.addEventListener('mouseover', function (e) {
            if (!isDragging) return;
            const seat = e.target.closest('.seat-tile');
            if (!seat) return;
            dragMoved = true;
            toggleSeat(seat, dragAdd);
            updateBulkInput();
        });

        document.addEventListener('mouseup', function () {
            isDragging = false;
        });
    })();
</script>
</body>
</html>

