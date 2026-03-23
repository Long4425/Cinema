<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cấu hình giá vé</title>
    <base href="${pageContext.request.contextPath}/">
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/header.css">
    <link rel="stylesheet" href="css/sidebar.css">
    <link rel="stylesheet" href="css/footer.css">
    <link rel="stylesheet" href="css/dashboard.css">
    <link rel="stylesheet" href="css/table.css">
    <link rel="stylesheet" href="css/button.css">
    <link rel="stylesheet" href="css/form.css">
    <style>
        .pricing-inline-form {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        .pricing-input-wrap {
            width: 160px;
            flex-shrink: 0;
        }
        .pricing-input-wrap .form-input {
            padding: 0.45rem 0.75rem;
            font-size: 0.9rem;
        }
    </style>
</head>
<body class="dashboard-layout">
<jsp:include page="/components/header.jsp"/>

<div class="dashboard-body">
    <jsp:include page="/components/sidebar.jsp"/>

    <main class="dashboard-main">
        <div class="dashboard-main__inner">
            <div class="page-header">
                <div>
                    <h1 class="page-title">Cấu hình giá vé</h1>
                    <p class="page-subtitle">
                        Nhập <strong>BasePrice</strong> cho từng suất chiếu — giá thực tế tự động nhân hệ số theo loại ghế và ngày chiếu.
                    </p>
                </div>
            </div>

            <%-- Bảng hệ số giá --%>
            <div class="card" style="padding:1.25rem;margin-bottom:1.25rem;">
                <h2 style="font-size:1rem;margin-bottom:0.75rem;">Hệ số giá áp dụng tự động</h2>
                <div class="table-wrap">
                    <table class="table">
                        <thead>
                        <tr>
                            <th>Loại ghế</th>
                            <th>Hệ số</th>
                            <th>Ngày thường (T2 – T6)</th>
                            <th>Cuối tuần (T7 – CN, +20%)</th>
                        </tr>
                        </thead>
                        <tbody>
                        <tr>
                            <td><strong>Standard</strong></td>
                            <td>× 1.0</td>
                            <td>= BasePrice</td>
                            <td>= BasePrice × 1.2</td>
                        </tr>
                        <tr>
                            <td><strong>VIP</strong></td>
                            <td>× 1.5</td>
                            <td>= BasePrice × 1.5</td>
                            <td>= BasePrice × 1.8</td>
                        </tr>
                        <tr>
                            <td><strong>Couple</strong></td>
                            <td>× 2.0</td>
                            <td>= BasePrice × 2.0</td>
                            <td>= BasePrice × 2.4</td>
                        </tr>
                        </tbody>
                    </table>
                </div>
                <p style="font-size:0.82rem;color:var(--text-muted);margin-top:0.5rem;">
                    Loại ghế đã được cấu hình cố định theo phòng chiếu. Giá làm tròn đến bội số 1.000 ₫.
                </p>
            </div>

            <%-- Bảng cập nhật BasePrice theo suất chiếu --%>
            <div class="card" style="padding:1.25rem;">
                <div style="display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:0.75rem;margin-bottom:1rem;">
                    <h2 style="font-size:1rem;margin:0;">Cập nhật BasePrice theo suất chiếu</h2>
                    <c:if test="${not empty showtimes}">
                        <div class="pricing-input-wrap" style="width:280px;">
                            <input type="search" id="movieFilter" class="form-input"
                                   placeholder="Tìm theo tên phim..."
                                   oninput="filterByMovie(this.value)">
                        </div>
                    </c:if>
                </div>
                <c:if test="${empty showtimes}">
                    <p style="font-size:0.9rem;color:var(--text-muted);margin:0;">Chưa có suất chiếu nào.</p>
                </c:if>
                <c:if test="${not empty showtimes}">
                    <p id="noResult" style="display:none;font-size:0.9rem;color:var(--text-muted);margin:0;">Không tìm thấy suất chiếu nào khớp.</p>
                    <div class="table-wrap">
                        <table class="table" id="pricingTable">
                            <thead>
                            <tr>
                                <th>Phim</th>
                                <th>Phòng</th>
                                <th>Thời gian</th>
                                <th>BasePrice hiện tại</th>
                                <th colspan="2">Cập nhật BasePrice</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:forEach items="${showtimes}" var="s">
                                <tr data-movie="${s.movie.title}">
                                    <td><c:out value="${s.movie.title}"/></td>
                                    <td><c:out value="${s.room.roomName}"/></td>
                                    <td style="white-space:nowrap;">
                                        <fmt:formatNumber value="${s.startTime.hour}" minIntegerDigits="2"/>:<fmt:formatNumber value="${s.startTime.minute}" minIntegerDigits="2"/>
                                        ${s.startTime.dayOfMonth}/${s.startTime.monthValue}/${s.startTime.year}
                                    </td>
                                    <td style="font-weight:600;">
                                        <fmt:formatNumber value="${s.basePrice}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                    </td>
                                    <td colspan="2">
                                        <form method="post" action="manager/pricing"
                                              class="pricing-inline-form"
                                              onsubmit="return confirmPrice(this)">
                                            <input type="hidden" name="showtimeId" value="${s.showtimeId}">
                                            <div class="pricing-input-wrap">
                                                <input type="number" min="0" step="1000" name="basePrice"
                                                       class="form-input"
                                                       placeholder="Nhập giá mới (₫)"
                                                       data-current="${s.basePrice}">
                                            </div>
                                            <button type="submit" class="btn btn-sm btn-primary">Lưu</button>
                                        </form>
                                    </td>
                                </tr>
                            </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:if>
            </div>
        </div>
    </main>
</div>

<jsp:include page="/components/footer.jsp"/>
<script>
function filterByMovie(q) {
    const rows = document.querySelectorAll('#pricingTable tbody tr');
    const kw = q.trim().toLowerCase();
    let visible = 0;
    rows.forEach(row => {
        const match = !kw || row.dataset.movie.toLowerCase().includes(kw);
        row.style.display = match ? '' : 'none';
        if (match) visible++;
    });
    document.getElementById('noResult').style.display = visible === 0 ? '' : 'none';
}

function confirmPrice(form) {
    const input = form.querySelector('input[name="basePrice"]');
    const val = parseInt(input.value, 10);
    if (!val || val <= 0) {
        alert('Vui lòng nhập giá hợp lệ.');
        return false;
    }
    const current = parseInt(input.dataset.current, 10);
    if (val === current) {
        alert('Giá mới giống giá hiện tại, không cần cập nhật.');
        return false;
    }
    const fmt = new Intl.NumberFormat('vi-VN');
    return confirm(
        'Cập nhật BasePrice thành ' + fmt.format(val) + ' ₫?\n\n' +
        'Giá ghế sẽ tự tính:\n' +
        '  Standard: ' + fmt.format(Math.round(val / 1000) * 1000) + ' ₫\n' +
        '  VIP: '      + fmt.format(Math.round(val * 1.5 / 1000) * 1000) + ' ₫\n' +
        '  Couple: '   + fmt.format(Math.round(val * 2.0 / 1000) * 1000) + ' ₫'
    );
}
</script>
</body>
</html>
