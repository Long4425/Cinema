<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Báo cáo doanh thu</title>
    <base href="${pageContext.request.contextPath}/">
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/header.css">
    <link rel="stylesheet" href="css/sidebar.css">
    <link rel="stylesheet" href="css/footer.css">
    <link rel="stylesheet" href="css/dashboard.css">
    <link rel="stylesheet" href="css/table.css">
    <link rel="stylesheet" href="css/button.css">
    <link rel="stylesheet" href="css/badge.css">
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
                    <h1 class="page-title">Báo cáo doanh thu</h1>
                    <p class="page-subtitle">Xem doanh thu theo ngày / phim / phòng và tỷ lệ lấp đầy ghế.</p>
                </div>
            </div>

            <%-- Quick date range --%>
            <div class="card" style="padding:0.75rem 1.25rem;margin-bottom:0.5rem;display:flex;align-items:center;gap:0.5rem;flex-wrap:wrap;">
                <span class="form-label" style="margin:0;white-space:nowrap;">Chọn nhanh:</span>
                <button type="button" class="btn btn-secondary" onclick="setRange('today')">Hôm nay</button>
                <button type="button" class="btn btn-secondary" onclick="setRange('7days')">7 ngày</button>
                <button type="button" class="btn btn-secondary" onclick="setRange('30days')">30 ngày</button>
                <button type="button" class="btn btn-secondary" onclick="setRange('thisMonth')">Tháng này</button>
                <button type="button" class="btn btn-secondary" onclick="setRange('lastMonth')">Tháng trước</button>
                <button type="button" class="btn btn-secondary" onclick="setRange('thisQuarter')">Quý này</button>
            </div>

            <%-- Filter bar --%>
            <div class="card" style="padding:1.25rem;margin-bottom:1rem;">
                <form id="reportForm" method="get" action="manager/reports" class="search-filter-bar">
                    <div class="filter-field filter-field--fixed">
                        <label class="form-label" for="fromDate">Từ ngày</label>
                        <input type="date" id="fromDate" name="fromDate" class="form-input" value="${fromDate}">
                    </div>
                    <div class="filter-field filter-field--fixed">
                        <label class="form-label" for="toDate">Đến ngày</label>
                        <input type="date" id="toDate" name="toDate" class="form-input" value="${toDate}">
                    </div>
                    <div class="filter-field filter-field--fixed">
                        <label class="form-label" for="movieId">Phim</label>
                        <select id="movieId" name="movieId" class="form-input">
                            <option value="">Tất cả phim</option>
                            <c:forEach items="${movies}" var="m">
                                <option value="${m.movieId}" ${movieId != null && movieId == m.movieId ? 'selected' : ''}>
                                    <c:out value="${m.title}"/>
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="filter-field filter-field--fixed">
                        <label class="form-label" for="roomId">Phòng chiếu</label>
                        <select id="roomId" name="roomId" class="form-input">
                            <option value="">Tất cả phòng</option>
                            <c:forEach items="${rooms}" var="rm">
                                <option value="${rm.roomId}" ${roomId != null && roomId == rm.roomId ? 'selected' : ''}>
                                    <c:out value="${rm.roomName}"/>
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="filter-actions">
                        <button type="submit" class="btn btn-primary">Lọc</button>
                        <button type="button" class="btn btn-secondary" onclick="exportExcel()">Xuất Excel</button>
                        <a href="manager/reports" class="btn btn-secondary">Reset</a>
                    </div>
                </form>
            </div>

            <script>
            function setRange(range) {
                const today = new Date();
                let from, to;
                const fmt = d => d.toISOString().slice(0, 10);
                if (range === 'today') {
                    from = to = fmt(today);
                } else if (range === '7days') {
                    const f = new Date(today); f.setDate(f.getDate() - 6);
                    from = fmt(f); to = fmt(today);
                } else if (range === '30days') {
                    const f = new Date(today); f.setDate(f.getDate() - 29);
                    from = fmt(f); to = fmt(today);
                } else if (range === 'thisMonth') {
                    from = fmt(new Date(today.getFullYear(), today.getMonth(), 1));
                    to = fmt(new Date(today.getFullYear(), today.getMonth() + 1, 0));
                } else if (range === 'lastMonth') {
                    from = fmt(new Date(today.getFullYear(), today.getMonth() - 1, 1));
                    to = fmt(new Date(today.getFullYear(), today.getMonth(), 0));
                } else if (range === 'thisQuarter') {
                    const q = Math.floor(today.getMonth() / 3);
                    from = fmt(new Date(today.getFullYear(), q * 3, 1));
                    to = fmt(new Date(today.getFullYear(), q * 3 + 3, 0));
                }
                document.getElementById('fromDate').value = from;
                document.getElementById('toDate').value = to;
                document.getElementById('reportForm').submit();
            }
            function exportExcel() {
                const from = document.getElementById('fromDate').value;
                const to   = document.getElementById('toDate').value;
                const mid  = document.getElementById('movieId').value;
                const rid  = document.getElementById('roomId').value;
                let url = 'manager/export?fromDate=' + from + '&toDate=' + to;
                if (mid) url += '&movieId=' + mid;
                if (rid) url += '&roomId=' + rid;
                window.location.href = url;
            }
            </script>

            <div class="card" style="padding:1.25rem;">
                <c:if test="${empty rows}">
                    <p style="font-size:0.9rem;color:var(--text-muted);margin:0;">Chưa có dữ liệu doanh thu trong khoảng đã chọn.</p>
                </c:if>
                <c:if test="${not empty rows}">
                    <div class="table-wrap">
                        <table class="table">
                            <thead>
                            <tr>
                                <th>Ngày</th>
                                <th>Phim</th>
                                <th>Phòng</th>
                                <th>Doanh thu</th>
                                <th>Số vé</th>
                                <th>Số suất</th>
                                <th>Tỷ lệ lấp đầy</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:set var="sumRevenue" value="0"/>
                            <c:set var="sumTickets" value="0"/>
                            <c:forEach items="${rows}" var="r">
                                <c:set var="sumRevenue" value="${sumRevenue + r.revenue}"/>
                                <c:set var="sumTickets" value="${sumTickets + r.tickets}"/>
                                <tr>
                                    <td>${r.date}</td>
                                    <td><c:out value="${r.movieTitle}"/></td>
                                    <td><c:out value="${r.roomName}"/></td>
                                    <td>
                                        <fmt:formatNumber value="${r.revenue}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                    </td>
                                    <td>${r.tickets}</td>
                                    <td>${r.showCount}</td>
                                    <td>
                                        <fmt:formatNumber value="${r.occupancyRate * 100}" maxFractionDigits="2"/>%
                                    </td>
                                </tr>
                            </c:forEach>
                            </tbody>
                            <tfoot>
                            <tr>
                                <td colspan="3" style="font-weight:700;">Tổng</td>
                                <td style="font-weight:700;">
                                    <fmt:formatNumber value="${sumRevenue}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                </td>
                                <td style="font-weight:700;">${sumTickets}</td>
                                <td colspan="2"></td>
                            </tr>
                            </tfoot>
                        </table>
                    </div>
                </c:if>
            </div>
        </div>
    </main>
</div>

<jsp:include page="/components/footer.jsp"/>
</body>
</html>

