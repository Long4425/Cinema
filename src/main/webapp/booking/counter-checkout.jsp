<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đặt vé tại quầy - Thanh toán</title>
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
                    <h1 class="page-title">Đặt vé tại quầy - Xác nhận &amp; Thanh toán</h1>
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

            <%-- Thông tin khách hàng (nếu có) --%>
            <c:if test="${not empty customer}">
                <div class="card" style="padding:1rem;margin-bottom:1rem;display:flex;align-items:center;gap:1rem;">
                    <div style="width:40px;height:40px;border-radius:50%;background:var(--primary-light);display:flex;align-items:center;justify-content:center;font-size:1.2rem;font-weight:700;color:var(--primary);">
                        ${customer.fullName.substring(0,1).toUpperCase()}
                    </div>
                    <div>
                        <div style="font-weight:700;"><c:out value="${customer.fullName}"/></div>
                        <div style="font-size:0.85rem;color:var(--text-muted);">
                            <c:out value="${customer.email}"/>
                            <c:if test="${not empty customer.phone}"> &bull; <c:out value="${customer.phone}"/></c:if>
                        </div>
                        <div style="font-size:0.8rem;margin-top:0.2rem;">
                            Điểm tích lũy hiện tại: <strong style="color:var(--primary);">${customer.loyaltyPoint}</strong>
                        </div>
                    </div>
                </div>
            </c:if>

            <form method="post" action="counter/checkout" id="counterCheckoutForm">
                <div style="display:grid;grid-template-columns:1fr 380px;gap:1.5rem;align-items:flex-start;">

                    <%-- Đồ ăn --%>
                    <div class="card" style="padding:1.5rem;">
                        <h2 style="font-size:1.05rem;font-weight:700;margin-bottom:1rem;">Đồ ăn &amp; thức uống <span style="font-size:0.8rem;color:var(--text-muted);font-weight:400;">(tuỳ chọn)</span></h2>
                        <c:if test="${empty foodItems}">
                            <p style="font-size:0.9rem;color:var(--text-muted);">Hiện chưa có sản phẩm đồ ăn nào.</p>
                        </c:if>
                        <c:if test="${not empty foodItems}">
                            <div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(180px,1fr));gap:0.75rem;">
                                <c:forEach items="${foodItems}" var="f">
                                    <div class="food-card" style="border:1px solid var(--border-light);border-radius:12px;padding:1rem;display:flex;flex-direction:column;gap:0.6rem;background:var(--bg-white);">
                                        <div style="width:100%;height:80px;border-radius:10px;overflow:hidden;background:var(--bg-hover);border:1px solid var(--border-light);">
                                            <img src="images/food.jpg" alt="${f.name}" style="width:100%;height:100%;object-fit:contain;display:block;">
                                        </div>
                                        <div style="text-align:center;">
                                            <div style="font-weight:700;font-size:0.9rem;"><c:out value="${f.name}"/></div>
                                            <c:if test="${not empty f.description}">
                                                <div style="font-size:0.78rem;color:var(--text-muted);"><c:out value="${f.description}"/></div>
                                            </c:if>
                                        </div>
                                        <div style="text-align:center;font-weight:700;color:var(--primary);font-size:0.95rem;">
                                            <fmt:formatNumber value="${f.price}" type="number" maxFractionDigits="0"/>₫
                                        </div>
                                        <div style="display:flex;align-items:center;justify-content:center;gap:0.5rem;">
                                            <button type="button" onclick="changeQty(this,-1)" style="width:30px;height:30px;border-radius:50%;border:1px solid var(--border-light);background:var(--bg-light);cursor:pointer;font-size:1.1rem;font-weight:700;display:flex;align-items:center;justify-content:center;">&#8722;</button>
                                            <input type="number" name="qty_${f.foodItemId}" min="0" max="20" value="0"
                                                   data-price="${f.price}" class="qty-input"
                                                   style="width:46px;text-align:center;border:1px solid var(--border-light);border-radius:8px;padding:0.3rem;font-size:0.95rem;font-weight:600;">
                                            <button type="button" onclick="changeQty(this,1)" style="width:30px;height:30px;border-radius:50%;border:1px solid var(--border-light);background:var(--bg-light);cursor:pointer;font-size:1.1rem;font-weight:700;display:flex;align-items:center;justify-content:center;">+</button>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:if>
                    </div>

                    <%-- Tóm tắt + Voucher + Thanh toán --%>
                    <div class="card" style="padding:1.5rem;display:flex;flex-direction:column;gap:1rem;position:sticky;top:calc(var(--header-height) + 1rem);">
                        <h2 style="font-size:1.05rem;font-weight:700;">Tóm tắt đơn hàng</h2>

                        <%-- Ghế đã chọn --%>
                        <div style="font-size:0.9rem;background:var(--bg-light);border-radius:8px;padding:0.75rem;">
                            <div style="font-weight:600;margin-bottom:0.35rem;">Ghế đã chọn</div>
                            <div style="display:flex;flex-wrap:wrap;gap:0.35rem;">
                                <c:forEach items="${bookingSeats}" var="bs">
                                    <span style="background:var(--primary-light);color:var(--primary);font-weight:700;padding:0.2rem 0.55rem;border-radius:6px;font-size:0.85rem;">
                                        ${bs.seat.rowLabel}${bs.seat.seatNumber}
                                    </span>
                                </c:forEach>
                            </div>
                        </div>

                        <%-- Tiền tính --%>
                        <div style="font-size:0.9rem;display:flex;flex-direction:column;gap:0.4rem;">
                            <div style="display:flex;justify-content:space-between;">
                                <span>Tiền vé</span>
                                <span style="font-weight:600;">
                                    <fmt:formatNumber value="${booking.subTotal}" type="number" maxFractionDigits="0"/>₫
                                </span>
                            </div>
                            <div style="display:flex;justify-content:space-between;">
                                <span>Đồ ăn &amp; thức uống</span>
                                <span id="foodTotalDisplay" style="font-weight:600;">0₫</span>
                            </div>
                            <div style="display:flex;justify-content:space-between;">
                                <span>Giảm giá voucher</span>
                                <span id="discountDisplay" style="color:#16a34a;font-weight:600;">-0₫</span>
                            </div>
                            <div style="display:flex;justify-content:space-between;padding-top:0.5rem;border-top:2px solid var(--border-light);font-size:1.05rem;font-weight:800;color:var(--text-dark);">
                                <span>Tổng thanh toán</span>
                                <span id="grandTotalDisplay"><fmt:formatNumber value="${booking.totalAmount}" type="number" maxFractionDigits="0"/>₫</span>
                            </div>
                        </div>

                        <%-- Voucher --%>
                        <div style="background:var(--bg-white);border:1px solid var(--border-light);border-radius:14px;padding:0.95rem 1rem;">
                            <div style="font-size:0.85rem;font-weight:700;color:var(--text-dark);margin-bottom:0.75rem;">Mã giảm giá</div>

                            <c:if test="${not empty myVouchers}">
                                <div style="margin-bottom:0.75rem;">
                                    <div style="font-size:0.78rem;color:var(--text-muted);font-weight:600;margin-bottom:0.4rem;">VOUCHER CÁ NHÂN CỦA KHÁCH</div>
                                    <div style="display:flex;flex-direction:column;gap:0.4rem;">
                                        <c:forEach items="${myVouchers}" var="v">
                                            <button type="button" class="voucher-pick-item" data-code="${v.code}"
                                                    style="width:100%;display:flex;align-items:center;justify-content:space-between;gap:0.5rem;border:1.5px dashed #22c55e;border-radius:8px;padding:0.5rem 0.75rem;cursor:pointer;background:#fff;text-align:left;">
                                                <span style="font-family:monospace;font-weight:700;font-size:0.9rem;color:#15803d;">${v.code}</span>
                                                <span style="font-weight:600;color:#166534;white-space:nowrap;">
                                                    -<fmt:formatNumber value="${v.discountValue}" type="number" maxFractionDigits="0"/>₫
                                                </span>
                                            </button>
                                        </c:forEach>
                                    </div>
                                </div>
                            </c:if>

                            <div style="font-size:0.78rem;color:var(--text-muted);font-weight:600;margin-bottom:0.4rem;">
                                <c:choose>
                                    <c:when test="${not empty myVouchers}">HOẶC NHẬP MÃ KHÁC</c:when>
                                    <c:otherwise>NHẬP MÃ VOUCHER</c:otherwise>
                                </c:choose>
                            </div>
                            <div style="display:flex;gap:0.5rem;align-items:center;">
                                <input type="text" id="voucherCode" name="voucherCode" class="form-input"
                                       placeholder="Nhập mã voucher..."
                                       value="${not empty appliedVoucherCode ? appliedVoucherCode : param.voucherCode}"
                                       style="flex:1;">
                                <button type="button" id="applyVoucherBtn"
                                        style="white-space:nowrap;padding:0.5rem 0.9rem;border-radius:8px;border:1px solid var(--primary);background:var(--primary-light);color:var(--primary);font-weight:700;font-size:0.85rem;cursor:pointer;">
                                    Áp dụng
                                </button>
                            </div>

                            <c:if test="${not empty appliedVoucherCode}">
                                <p style="color:#166534;font-size:0.85rem;margin-top:0.45rem;background:#f0fdf4;border:1px solid #86efac;padding:0.45rem 0.6rem;border-radius:10px;">
                                    ✓ Áp dụng thành công: giảm <strong><fmt:formatNumber value="${appliedVoucherDiscount}" type="number" maxFractionDigits="0"/>₫</strong>
                                </p>
                            </c:if>
                            <c:if test="${not empty voucherError}">
                                <p style="color:#b91c1c;font-size:0.85rem;margin-top:0.45rem;background:rgba(185,28,28,0.08);border:1px solid rgba(185,28,28,0.18);padding:0.45rem 0.6rem;border-radius:10px;">
                                    ${voucherError}
                                </p>
                            </c:if>
                        </div>

                        <%-- Nút thanh toán tiền mặt --%>
                        <div style="display:flex;flex-direction:column;gap:0.6rem;margin-top:0.25rem;">
                            <div style="background:#f0fdf4;border:1px solid #86efac;border-radius:10px;padding:0.75rem 1rem;font-size:0.85rem;color:#166534;">
                                Phương thức: <strong>Tiền mặt tại quầy</strong>
                            </div>
                            <button type="submit" class="btn btn-primary" style="font-size:1rem;padding:0.85rem;">
                                Xác nhận thu tiền mặt
                            </button>
                            <a href="counter/seat-selection?showtimeId=${booking.showtimeId}" class="btn btn-secondary">
                                Quay lại chọn ghế
                            </a>
                        </div>
                    </div>
                </div>
            </form>
        </div>
    </main>
</div>

<jsp:include page="/components/footer.jsp"/>

<script>
    const ticketSubTotal = ${booking.subTotal != null ? booking.subTotal : 0};
    const voucherInput = document.getElementById('voucherCode');

    const knownVouchers = {};
    <c:forEach items="${myVouchers}" var="v">
    knownVouchers['${v.code}'] = { type: '${v.discountType}', value: ${v.discountValue} };
    </c:forEach>

    // Discount đã được server validate (voucher công khai hoặc voucher không có trong knownVouchers)
    let serverAppliedCode = '${not empty appliedVoucherCode ? appliedVoucherCode : ""}';
    let serverAppliedType = '${not empty appliedVoucherType ? appliedVoucherType : ""}';
    let serverAppliedValue = ${not empty appliedVoucherValue ? appliedVoucherValue : 0};

    function fmt(n) {
        return new Intl.NumberFormat('vi-VN').format(Math.round(n)) + '₫';
    }

    function changeQty(btn, delta) {
        const input = btn.parentElement.querySelector('.qty-input');
        let val = Math.max(0, Math.min(20, (parseInt(input.value) || 0) + delta));
        input.value = val;
        recalc();
    }

    function recalc() {
        let foodTotal = 0;
        document.querySelectorAll('.qty-input').forEach(input => {
            const qty = parseInt(input.value) || 0;
            const price = parseFloat(input.dataset.price) || 0;
            foodTotal += qty * price;
        });
        const subtotal = (Number(ticketSubTotal) || 0) + foodTotal;
        let discount = 0;
        const code = (voucherInput ? voucherInput.value.trim().toUpperCase() : '');
        const knownKey = Object.keys(knownVouchers).find(k => k.toUpperCase() === code);
        if (knownKey) {
            const v = knownVouchers[knownKey];
            discount = v.type === 'Percent' ? subtotal * v.value / 100 : v.value;
        } else if (serverAppliedCode && code === serverAppliedCode.toUpperCase()) {
            // Dùng discount đã được server validate
            discount = serverAppliedType === 'Percent' ? subtotal * serverAppliedValue / 100 : serverAppliedValue;
        }
        discount = Math.max(0, Math.min(discount, subtotal));
        document.getElementById('foodTotalDisplay').textContent = fmt(foodTotal);
        document.getElementById('discountDisplay').textContent = '-' + fmt(discount);
        document.getElementById('grandTotalDisplay').textContent = fmt(subtotal - discount);
    }

    document.querySelectorAll('.qty-input').forEach(i => i.addEventListener('input', recalc));
    if (voucherInput) {
        voucherInput.addEventListener('input', function() {
            // Xóa server discount nếu user thay đổi mã
            if (serverAppliedCode && this.value.trim().toUpperCase() !== serverAppliedCode.toUpperCase()) {
                serverAppliedCode = '';
                serverAppliedValue = 0;
            }
            recalc();
        });
    }

    document.querySelectorAll('.voucher-pick-item').forEach(btn => {
        btn.addEventListener('click', function () {
            const isSelected = this.classList.contains('selected');
            document.querySelectorAll('.voucher-pick-item').forEach(b => {
                b.classList.remove('selected');
                b.style.background = '#fff';
                b.style.borderStyle = 'dashed';
            });
            if (!isSelected) {
                this.classList.add('selected');
                this.style.background = '#f0fdf4';
                this.style.borderStyle = 'solid';
                voucherInput.value = this.dataset.code;
            } else {
                voucherInput.value = '';
            }
            serverAppliedCode = '';
            serverAppliedValue = 0;
            recalc();
        });
    });

    // Nút Áp dụng: submit GET để server validate voucher
    const applyBtn = document.getElementById('applyVoucherBtn');
    if (applyBtn) {
        applyBtn.addEventListener('click', function () {
            const code = voucherInput ? voucherInput.value.trim() : '';
            if (!code) return;
            const url = new URL(window.location.href);
            url.searchParams.set('voucherCode', code);
            window.location.href = url.toString();
        });
    }

    recalc();
</script>
</body>
</html>
