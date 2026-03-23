<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý đặt vé | Cinema</title>
    <base href="${pageContext.request.contextPath}/">
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/header.css">
    <link rel="stylesheet" href="css/sidebar.css">
    <link rel="stylesheet" href="css/dashboard.css">
    <link rel="stylesheet" href="css/table.css">
    <link rel="stylesheet" href="css/button.css">
    <link rel="stylesheet" href="css/badge.css">
    <link rel="stylesheet" href="css/message.css">
    <link rel="stylesheet" href="css/form.css">
    <link rel="stylesheet" href="css/filter.css">
    <link rel="stylesheet" href="css/paging.css">
</head>
<body class="dashboard-layout">
<jsp:include page="/components/header.jsp"/>
<div class="dashboard-body">
    <jsp:include page="/components/sidebar.jsp"/>

    <main class="dashboard-main">
        <div class="page-header">
            <div>
                <h1 class="page-title">Quản lý đặt vé</h1>
                <p class="page-subtitle">Tìm kiếm, hủy vé và xác nhận hoàn tiền cho khách hàng.</p>
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

        <%-- Filter / Search --%>
        <div class="card" style="padding:1.25rem; margin-bottom:1rem;">
            <form method="get" action="staff/bookings" class="search-filter-bar">
                <div class="filter-field filter-field--grow">
                    <label class="form-label">Tìm kiếm</label>
                    <input type="text" name="keyword" value="${keyword}" class="form-input"
                           placeholder="Tên khách, email hoặc mã đơn...">
                </div>
                <div class="filter-field filter-field--fixed">
                    <label class="form-label">Trạng thái</label>
                    <select name="status" class="form-input">
                        <option value="">Tất cả</option>
                        <option value="Confirmed"  ${filterStatus == 'Confirmed'  ? 'selected' : ''}>Đã thanh toán</option>
                        <option value="Cancelled"  ${filterStatus == 'Cancelled'  ? 'selected' : ''}>Đã hủy</option>
                        <option value="Pending"    ${filterStatus == 'Pending'    ? 'selected' : ''}>Chờ thanh toán</option>
                    </select>
                </div>
                <div class="filter-field filter-field--fixed">
                    <label class="form-label">Ngày chiếu</label>
                    <input type="date" name="date" value="${filterDate}" class="form-input">
                </div>
                <div class="filter-actions">
                    <button type="submit" class="btn btn-primary">Lọc</button>
                    <a href="staff/bookings" class="btn btn-secondary">Reset</a>
                </div>
            </form>
        </div>

        <%-- Table --%>
        <div class="card" style="padding:1.25rem;">
            <c:choose>
                <c:when test="${empty rows}">
                    <p style="font-size:0.9rem; color:var(--text-muted); margin:0;">Không tìm thấy đơn đặt vé nào.</p>
                </c:when>
                <c:otherwise>
                    <%-- Info tổng số kết quả --%>
                    <div class="paging" style="padding-top:0; padding-bottom:0.75rem;">
                        <span class="paging-info">
                            Hiển thị ${(currentPage-1)*pageSize + 1}–${(currentPage-1)*pageSize + rows.size()} / ${totalRows} kết quả
                        </span>
                    </div>
                    <div class="table-wrap">
                        <table class="table">
                            <thead>
                            <tr>
                                <th>Mã đơn</th>
                                <th>Khách hàng</th>
                                <th>Phim</th>
                                <th>Suất chiếu</th>
                                <th>Loại</th>
                                <th>Trạng thái</th>
                                <th>Tổng tiền</th>
                                <th>Ngày đặt</th>
                                <th style="width:180px;">Thao tác</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:forEach var="row" items="${rows}">
                                <tr>
                                    <td>#${row.bookingId}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty row.userFullName}">
                                                <div style="font-weight:600;">${row.userFullName}</div>
                                                <div style="font-size:0.8rem; color:var(--text-muted);">${row.userEmail}</div>
                                            </c:when>
                                            <c:otherwise>
                                                <span style="color:var(--text-muted);">Khách vãng lai</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>${row.movieTitle}</td>
                                    <td>
                                        <fmt:formatNumber value="${row.startTime.hour}"   minIntegerDigits="2"/>:<fmt:formatNumber value="${row.startTime.minute}" minIntegerDigits="2"/>
                                        ${row.startTime.dayOfMonth}/${row.startTime.monthValue}/${row.startTime.year}
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${row.bookingType == 'ONLINE'}"><span class="badge badge-info">Online</span></c:when>
                                            <c:otherwise><span class="badge badge-secondary">Quầy</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${row.status == 'Confirmed'}"><span class="badge badge-success">Đã thanh toán</span></c:when>
                                            <c:when test="${row.status == 'Pending'}"><span class="badge badge-warning">Chờ thanh toán</span></c:when>
                                            <c:when test="${row.status == 'Cancelled'}"><span class="badge badge-danger">Đã hủy</span></c:when>
                                            <c:when test="${row.status == 'Refunded'}"><span class="badge badge-info">Đã hoàn tiền</span></c:when>
                                            <c:otherwise><span class="badge">${row.status}</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <fmt:formatNumber value="${row.totalAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                    </td>
                                    <td>
                                        ${row.createdAt.dayOfMonth}/${row.createdAt.monthValue}/${row.createdAt.year}
                                    </td>
                                    <td>
                                        <div class="table-actions">
                                            <a href="booking/summary?bookingId=${row.bookingId}" class="btn btn-sm btn-secondary">Xem vé</a>

                                            <%-- Nút Hủy vé: chỉ khi Confirmed/Pending VÀ chưa tới giờ chiếu --%>
                                            <c:if test="${(row.status == 'Confirmed' || row.status == 'Pending') && row.beforeShowtime}">
                                                <button type="button" class="btn btn-sm btn-danger"
                                                        onclick="showCancelModal(${row.bookingId})">Hủy vé</button>
                                            </c:if>

                                            <%-- Nút Hoàn tiền: chỉ khi đã Cancelled (customer tự hủy chờ staff xác nhận) --%>
                                            <c:if test="${row.status == 'Cancelled'}">
                                                <button type="button" class="btn btn-sm btn-primary"
                                                        onclick="showRefundModal(${row.bookingId})">Xác nhận hoàn tiền</button>
                                            </c:if>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                            </tbody>
                        </table>
                    </div>

                    <%-- Phân trang --%>
                    <c:if test="${totalPages > 1}">
                        <c:set var="kw"   value="${not empty keyword     ? '&keyword='.concat(keyword)         : ''}"/>
                        <c:set var="st"   value="${not empty filterStatus ? '&status='.concat(filterStatus)     : ''}"/>
                        <c:set var="dt"   value="${not empty filterDate   ? '&date='.concat(filterDate)         : ''}"/>
                        <c:set var="base" value="staff/bookings?page="/>

                        <div class="paging" style="padding-top:1rem;">
                            <span class="paging-info">Trang ${currentPage} / ${totalPages}</span>
                            <nav class="paging-nav">
                                <%-- Prev --%>
                                <c:choose>
                                    <c:when test="${currentPage <= 1}">
                                        <span class="paging-btn is-disabled">&#8249;</span>
                                    </c:when>
                                    <c:otherwise>
                                        <a class="paging-btn" href="${base}${currentPage-1}${kw}${st}${dt}">&#8249;</a>
                                    </c:otherwise>
                                </c:choose>

                                <%-- Trang đầu --%>
                                <c:if test="${currentPage > 3}">
                                    <a class="paging-btn" href="${base}1${kw}${st}${dt}">1</a>
                                    <c:if test="${currentPage > 4}">
                                        <span class="paging-ellipsis">…</span>
                                    </c:if>
                                </c:if>

                                <%-- Vùng xung quanh trang hiện tại --%>
                                <c:forEach var="p" begin="${currentPage-2}" end="${currentPage+2}">
                                    <c:if test="${p >= 1 && p <= totalPages}">
                                        <c:choose>
                                            <c:when test="${p == currentPage}">
                                                <span class="paging-btn is-active">${p}</span>
                                            </c:when>
                                            <c:otherwise>
                                                <a class="paging-btn" href="${base}${p}${kw}${st}${dt}">${p}</a>
                                            </c:otherwise>
                                        </c:choose>
                                    </c:if>
                                </c:forEach>

                                <%-- Trang cuối --%>
                                <c:if test="${currentPage < totalPages - 2}">
                                    <c:if test="${currentPage < totalPages - 3}">
                                        <span class="paging-ellipsis">…</span>
                                    </c:if>
                                    <a class="paging-btn" href="${base}${totalPages}${kw}${st}${dt}">${totalPages}</a>
                                </c:if>

                                <%-- Next --%>
                                <c:choose>
                                    <c:when test="${currentPage >= totalPages}">
                                        <span class="paging-btn is-disabled">&#8250;</span>
                                    </c:when>
                                    <c:otherwise>
                                        <a class="paging-btn" href="${base}${currentPage+1}${kw}${st}${dt}">&#8250;</a>
                                    </c:otherwise>
                                </c:choose>
                            </nav>
                        </div>
                    </c:if>
                </c:otherwise>
            </c:choose>
        </div>
    </main>
</div>

<%-- Modal hủy vé --%>
<div id="cancelModal" style="display:none; position:fixed; inset:0; background:rgba(0,0,0,0.45); z-index:1000; align-items:center; justify-content:center;">
    <div style="background:#fff; border-radius:12px; padding:2rem; max-width:440px; width:90%; box-shadow:0 8px 32px rgba(0,0,0,0.18);">
        <h2 style="font-size:1.1rem; font-weight:800; margin-bottom:0.75rem;">Xác nhận hủy vé</h2>
        <p style="font-size:0.9rem; color:var(--text-muted); margin-bottom:1.25rem;">
            Hủy vé sẽ giải phóng ghế và đánh dấu hoàn tiền ngay. Bạn có chắc chắn?
        </p>
        <div style="display:flex; gap:0.75rem; justify-content:flex-end;">
            <button type="button" class="btn btn-secondary" onclick="closeModals()">Quay lại</button>
            <form id="cancelForm" method="post" action="staff/bookings" style="display:inline;">
                <input type="hidden" name="action" value="cancel">
                <input type="hidden" name="bookingId" id="cancelBookingId">
                <input type="hidden" name="filterStatus" value="${filterStatus}">
                <input type="hidden" name="filterDate" value="${filterDate}">
                <input type="hidden" name="keyword" value="${keyword}">
                <button type="submit" class="btn btn-danger">Xác nhận hủy</button>
            </form>
        </div>
    </div>
</div>

<%-- Modal hoàn tiền --%>
<div id="refundModal" style="display:none; position:fixed; inset:0; background:rgba(0,0,0,0.45); z-index:1000; align-items:center; justify-content:center;">
    <div style="background:#fff; border-radius:12px; padding:2rem; max-width:440px; width:90%; box-shadow:0 8px 32px rgba(0,0,0,0.18);">
        <h2 style="font-size:1.1rem; font-weight:800; margin-bottom:0.75rem;">Xác nhận hoàn tiền</h2>
        <p style="font-size:0.9rem; color:var(--text-muted); margin-bottom:1.25rem;">
            Xác nhận rằng bạn đã hoàn tiền mặt cho khách hàng tại quầy.
        </p>
        <div style="display:flex; gap:0.75rem; justify-content:flex-end;">
            <button type="button" class="btn btn-secondary" onclick="closeModals()">Quay lại</button>
            <form id="refundForm" method="post" action="staff/bookings" style="display:inline;">
                <input type="hidden" name="action" value="refund">
                <input type="hidden" name="bookingId" id="refundBookingId">
                <input type="hidden" name="filterStatus" value="${filterStatus}">
                <input type="hidden" name="filterDate" value="${filterDate}">
                <input type="hidden" name="keyword" value="${keyword}">
                <button type="submit" class="btn btn-primary">Đã hoàn tiền</button>
            </form>
        </div>
    </div>
</div>

<jsp:include page="/components/footer.jsp"/>

<script>
    function showCancelModal(bookingId) {
        document.getElementById('cancelBookingId').value = bookingId;
        document.getElementById('cancelModal').style.display = 'flex';
    }
    function showRefundModal(bookingId) {
        document.getElementById('refundBookingId').value = bookingId;
        document.getElementById('refundModal').style.display = 'flex';
    }
    function closeModals() {
        document.getElementById('cancelModal').style.display = 'none';
        document.getElementById('refundModal').style.display = 'none';
    }
    document.getElementById('cancelModal').addEventListener('click', function(e) { if (e.target === this) closeModals(); });
    document.getElementById('refundModal').addEventListener('click', function(e) { if (e.target === this) closeModals(); });
</script>
</body>
</html>
