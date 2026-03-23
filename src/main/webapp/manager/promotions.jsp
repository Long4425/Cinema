<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Khuyến mãi & Voucher</title>
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
    <style>
        .select-wrap {
            position: relative;
        }
        .select-wrap::after {
            content: '▾';
            position: absolute;
            right: 0.75rem;
            top: 50%;
            transform: translateY(-50%);
            pointer-events: none;
            color: var(--text-muted);
            font-size: 0.8rem;
        }
        .select-wrap select.form-input {
            appearance: none;
            -webkit-appearance: none;
            padding-right: 2rem;
            cursor: pointer;
        }
        .form-hint {
            font-size: 0.8rem;
            color: var(--text-muted);
            margin-top: 0.3rem;
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
                    <h1 class="page-title">Khuyến mãi & Mã giảm giá</h1>
                    <p class="page-subtitle">
                        Tạo và quản lý các voucher dùng tại bước checkout (UC-27).
                    </p>
                </div>
            </div>

            <div class="grid" style="display:grid;grid-template-columns:1.2fr 2fr;gap:1.5rem;align-items:flex-start;">
                <div class="card" style="padding:1.25rem;">
                    <h2 style="font-size:1rem;margin-bottom:0.75rem;">Tạo voucher mới</h2>
                    <form method="post" action="manager/promotions">
                        <input type="hidden" name="action" value="create">
                        <div class="form-group">
                            <label class="form-label" for="code">Mã voucher</label>
                            <input type="text" id="code" name="code" class="form-input"
                                   placeholder="VD: WEEKEND20" required
                                   style="text-transform:uppercase;">
                            <span class="form-hint">Chỉ dùng chữ hoa, số và dấu gạch ngang.</span>
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="discountType">Loại giảm giá</label>
                            <div class="select-wrap">
                                <select id="discountType" name="discountType" class="form-input"
                                        onchange="updateDiscountHint(this)">
                                    <option value="Percent">Phần trăm (%)</option>
                                    <option value="FixedAmount">Số tiền cố định (₫)</option>
                                </select>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="discountValue">Giá trị giảm</label>
                            <input type="number" step="1" min="0" id="discountValue" name="discountValue"
                                   class="form-input" placeholder="VD: 20 (%) hoặc 50000 (₫)" required>
                            <span class="form-hint" id="discountHint">Nhập số phần trăm, ví dụ: 10 = giảm 10%.</span>
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="minOrderValue">Đơn hàng tối thiểu (₫)</label>
                            <input type="number" step="1000" min="0" id="minOrderValue" name="minOrderValue"
                                   class="form-input" placeholder="VD: 100000" required>
                            <span class="form-hint">Voucher chỉ áp dụng khi tổng đơn ≥ mức này.</span>
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="maxUsage">Số lần dùng tối đa</label>
                            <input type="number" min="1" id="maxUsage" name="maxUsage"
                                   class="form-input" value="100" required>
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="startAt">Ngày bắt đầu</label>
                            <input type="date" id="startAt" name="startAt" class="form-input">
                            <span class="form-hint">Để trống = áp dụng ngay. Có giá trị = Flash Sale.</span>
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="expiredAt">Ngày hết hạn</label>
                            <input type="date" id="expiredAt" name="expiredAt" class="form-input" required>
                        </div>
                        <button type="submit" class="btn btn-primary" style="width:100%;">Tạo voucher</button>
                    </form>
                </div>

                <div class="card" style="padding:1.25rem;">
                    <h2 style="font-size:1rem;margin-bottom:0.75rem;">Danh sách voucher</h2>
                    <c:if test="${empty vouchers}">
                        <p style="font-size:0.9rem;color:var(--text-muted);margin:0;">Chưa có voucher nào.</p>
                    </c:if>
                    <c:if test="${not empty vouchers}">
                        <div class="table-wrap">
                            <table class="table">
                                <thead>
                                <tr>
                                    <th>Mã</th>
                                    <th>Loại</th>
                                    <th>Giá trị</th>
                                    <th>Đơn tối thiểu</th>
                                    <th>Từ ngày</th>
                                    <th>HSD</th>
                                    <th>Đã dùng / Tối đa</th>
                                    <th>Trạng thái</th>
                                    <th style="width:120px;">Thao tác</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:forEach items="${vouchers}" var="v">
                                    <tr>
                                        <td><strong>${v.code}</strong></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${v.discountType == 'Percent'}">%</c:when>
                                                <c:otherwise>Số tiền</c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${v.discountType == 'Percent'}">
                                                    ${v.discountValue}%
                                                </c:when>
                                                <c:otherwise>
                                                    <fmt:formatNumber value="${v.discountValue}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <fmt:formatNumber value="${v.minOrderValue}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty v.startAt}">
                                                    ${v.startAt.dayOfMonth}/${v.startAt.monthValue}/${v.startAt.year}
                                                    <span class="badge badge-warning" style="font-size:0.7rem;margin-left:0.25rem;">Flash Sale</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="color:var(--text-muted);font-size:0.85rem;">Ngay</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            ${v.expiredAt.dayOfMonth}/${v.expiredAt.monthValue}/${v.expiredAt.year}
                                        </td>
                                        <td>${v.usedCount} / ${v.maxUsage}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${v.active}">
                                                    <span class="badge badge-success">Đang kích hoạt</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-danger">Đã tắt</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <form method="post" action="manager/promotions" style="display:inline;">
                                                <input type="hidden" name="action" value="toggle">
                                                <input type="hidden" name="voucherId" value="${v.voucherId}">
                                                <input type="hidden" name="active" value="${v.active}">
                                                <button type="submit" class="btn btn-sm btn-secondary">
                                                    <c:choose>
                                                        <c:when test="${v.active}">Tắt</c:when>
                                                        <c:otherwise>Bật</c:otherwise>
                                                    </c:choose>
                                                </button>
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
        </div>
    </main>
</div>

<jsp:include page="/components/footer.jsp"/>
<script>
function updateDiscountHint(select) {
    const hint = document.getElementById('discountHint');
    const input = document.getElementById('discountValue');
    if (select.value === 'Percent') {
        hint.textContent = 'Nhập số phần trăm, ví dụ: 10 = giảm 10%.';
        input.placeholder = 'VD: 10 (%)';
        input.step = '1';
    } else {
        hint.textContent = 'Nhập số tiền, ví dụ: 50000 = giảm 50.000 ₫.';
        input.placeholder = 'VD: 50000 (₫)';
        input.step = '1000';
    }
}
</script>
</body>
</html>

