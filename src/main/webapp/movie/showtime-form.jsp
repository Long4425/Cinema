<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${showtime != null ? 'Sửa suất chiếu' : 'Thêm suất chiếu'} | Cinema</title>
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
        <h1 style="font-size:1.5rem; font-weight:800; color:var(--text-dark); margin:0;">
            ${showtime != null ? 'Chỉnh sửa suất chiếu' : 'Thêm suất chiếu mới'}
        </h1>
        <a href="manager/showtimes" class="btn btn-secondary">Quay lại</a>
    </div>

    <c:if test="${not empty error}">
        <div class="cinema-msg cinema-msg--error" role="alert" style="margin-bottom:1rem;">${error}</div>
    </c:if>
    <c:if test="${not empty success}">
        <div class="cinema-msg cinema-msg--success" role="status" style="margin-bottom:1rem;">${success}</div>
    </c:if>

    <form action="manager/showtimes" method="post" class="profile-card" style="padding:1.5rem; border-radius:12px;">
        <input type="hidden" name="action" value="${showtime != null ? 'update' : 'create'}">
        <input type="hidden" name="id" value="${showtime.showtimeId}">

        <div class="form-group">
            <label for="movieId" class="form-label">Chọn phim</label>
            <select name="movieId" id="movieId" class="form-input" required>
                <c:forEach var="m" items="${movies}">
                    <option value="${m.movieId}" data-duration="${m.durationMins}"
                            ${showtime.movieId==m.movieId ? 'selected' : '' }>
                        ${m.title}
                    </option>
                </c:forEach>
            </select>
        </div>

        <div class="form-group">
            <label for="roomId" class="form-label">Chọn phòng</label>
            <select name="roomId" id="roomId" class="form-input" required>
                <c:forEach var="r" items="${rooms}">
                    <option value="${r.roomId}" ${showtime.roomId==r.roomId ? 'selected' : '' }>${r.roomName} (${r.roomType})</option>
                </c:forEach>
            </select>
        </div>

        <div style="display:grid; grid-template-columns: 1fr 1fr; gap: 1rem;">
            <div class="form-group">
                <label for="startTime" class="form-label">Thời gian bắt đầu</label>
                <input type="datetime-local" name="startTime" id="startTime" class="form-input" value="${showtime.startTime}" required>
            </div>
            <div class="form-group">
                <label for="endTime" class="form-label">Thời gian kết thúc</label>
                <input type="datetime-local" name="endTime" id="endTime" class="form-input" value="${showtime.endTime}" required readonly>
            </div>
        </div>

        <div class="form-group">
            <label for="basePrice" class="form-label">Giá cơ bản (₫)</label>
            <input type="number" name="basePrice" id="basePrice" class="form-input" value="${showtime.basePrice}" min="1" step="1000" required>
            <span class="form-hint">Giá phải lớn hơn 0.</span>
        </div>

        <div class="form-group">
            <label for="status" class="form-label">Trạng thái</label>
            <select name="status" id="status" class="form-input">
                <option value="Scheduled" ${showtime.status=='Scheduled' ? 'selected' : '' }>Scheduled</option>
                <option value="Ongoing" ${showtime.status=='Ongoing' ? 'selected' : '' }>Ongoing</option>
                <option value="Finished" ${showtime.status=='Finished' ? 'selected' : '' }>Finished</option>
                <option value="Cancelled" ${showtime.status=='Cancelled' ? 'selected' : '' }>Cancelled</option>
            </select>
        </div>

        <div class="btn-row" style="margin-top: 1.25rem;">
            <button type="submit" class="btn btn-primary">${showtime != null ? 'Cập nhật' : 'Thêm mới'}</button>
            <a href="manager/showtimes" class="btn btn-secondary">Hủy</a>
        </div>
    </form>
</main>

<jsp:include page="/components/footer.jsp"/>
<script>
    (function () {
        const movieSelect = document.getElementById('movieId');
        const startInput = document.getElementById('startTime');
        const endInput = document.getElementById('endTime');

        function calcEndTime() {
            if (!movieSelect || !startInput || !endInput) return;
            const opt = movieSelect.options[movieSelect.selectedIndex];
            if (!opt) return;
            const duration = parseInt(opt.getAttribute('data-duration') || '0', 10);
            const startVal = startInput.value;
            if (!startVal || !duration || isNaN(duration)) return;

            // datetime-local: "yyyy-MM-ddTHH:mm"
            const dt = new Date(startVal);
            if (isNaN(dt.getTime())) return;
            dt.setMinutes(dt.getMinutes() + duration);

            const pad = n => String(n).padStart(2, '0');
            const yyyy = dt.getFullYear();
            const MM = pad(dt.getMonth() + 1);
            const dd = pad(dt.getDate());
            const hh = pad(dt.getHours());
            const mm = pad(dt.getMinutes());
            endInput.value = `${yyyy}-${MM}-${dd}T${hh}:${mm}`;
        }

        movieSelect && movieSelect.addEventListener('change', calcEndTime);
        startInput && startInput.addEventListener('change', calcEndTime);
        // tính lần đầu khi mở form
        calcEndTime();
    })();
</script>
</body>
</html>