<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thanh toán - Đặt vé</title>
    <base href="${pageContext.request.contextPath}/">
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/header.css">
    <link rel="stylesheet" href="css/footer.css">
    <link rel="stylesheet" href="css/dashboard.css">
    <link rel="stylesheet" href="css/button.css">
    <link rel="stylesheet" href="css/table.css">
    <link rel="stylesheet" href="css/message.css">
    <link rel="stylesheet" href="css/form.css">
</head>
<body class="home-layout">
<jsp:include page="/components/header.jsp"/>

<main class="home-main">
    <div class="container container--lg">
        <div class="page-header">
            <div>
                <h1 class="page-title">Xác nhận đơn hàng</h1>
                <p class="page-subtitle">
                    <c:out value="${showtime.movie.title}"/> -
                    <c:out value="${showtime.room.roomName}"/> |
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

        <form method="post" action="booking/checkout" id="checkoutForm">
            <div style="display:grid;grid-template-columns:1fr 380px;gap:1.5rem;align-items:flex-start;">

                <%-- LEFT: Food selection --%>
                <div style="display:flex;flex-direction:column;gap:1rem;">
                    <div class="card" style="padding:1.5rem;">
                        <h2 style="font-size:1.05rem;font-weight:700;margin-bottom:1rem;display:flex;align-items:center;gap:0.5rem;">
                            🍿 Đồ ăn & thức uống <span style="font-size:0.8rem;color:var(--text-muted);font-weight:400;">(tuỳ chọn)</span>
                        </h2>
                        <c:if test="${empty foodItems}">
                            <p style="font-size:0.9rem;color:var(--text-muted);">Hiện chưa có sản phẩm đồ ăn nào.</p>
                        </c:if>
                        <c:if test="${not empty foodItems}">
                            <div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(200px,1fr));gap:0.75rem;">
                                <c:forEach items="${foodItems}" var="f">
                                    <div class="food-card" style="border:1px solid var(--border-light);border-radius:12px;padding:1rem;display:flex;flex-direction:column;gap:0.6rem;background:var(--bg-white);transition:box-shadow 0.2s;">
                                        <div style="width:100%;height:92px;border-radius:10px;overflow:hidden;background:var(--bg-hover);border:1px solid var(--border-light);">
                                            <img
                                                    src="images/food.jpg"
                                                    alt="${f.name}"
                                                    style="width:100%;height:100%;object-fit:contain;display:block;">
                                        </div>
                                        <div style="text-align:center;">
                                            <div style="font-weight:700;font-size:0.9rem;color:var(--text-dark);"><c:out value="${f.name}"/></div>
                                            <c:if test="${not empty f.description}">
                                                <div style="font-size:0.78rem;color:var(--text-muted);margin-top:0.15rem;"><c:out value="${f.description}"/></div>
                                            </c:if>
                                        </div>
                                        <div style="text-align:center;font-weight:700;color:var(--primary);font-size:0.95rem;">
                                            <fmt:formatNumber value="${f.price}" type="number" maxFractionDigits="0"/>₫
                                        </div>
                                        <div style="display:flex;align-items:center;justify-content:center;gap:0.5rem;">
                                            <button type="button" class="qty-btn" onclick="changeQty(this,-1)" style="width:30px;height:30px;border-radius:50%;border:1px solid var(--border-light);background:var(--bg-light);cursor:pointer;font-size:1.1rem;font-weight:700;display:flex;align-items:center;justify-content:center;">−</button>
                                            <input type="number"
                                                   name="qty_${f.foodItemId}"
                                                   min="0" max="20" value="0"
                                                   data-price="${f.price}"
                                                   class="qty-input"
                                                   style="width:46px;text-align:center;border:1px solid var(--border-light);border-radius:8px;padding:0.3rem;font-size:0.95rem;font-weight:600;">
                                            <button type="button" class="qty-btn" onclick="changeQty(this,1)" style="width:30px;height:30px;border-radius:50%;border:1px solid var(--border-light);background:var(--bg-light);cursor:pointer;font-size:1.1rem;font-weight:700;display:flex;align-items:center;justify-content:center;">+</button>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:if>
                    </div>
                </div>

                <%-- RIGHT: Order summary --%>
                <div class="card" style="padding:1.5rem;display:flex;flex-direction:column;gap:1rem;position:sticky;top:calc(var(--header-height) + 1rem);">
                    <h2 style="font-size:1.05rem;font-weight:700;">🎟️ Tóm tắt đơn hàng</h2>

                    <%-- Ghế đã chọn --%>
                    <div style="font-size:0.9rem;background:var(--bg-light);border-radius:8px;padding:0.75rem;">
                        <div style="font-weight:600;margin-bottom:0.35rem;color:var(--text-dark);">Ghế đã chọn</div>
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
                            <span style="color:var(--text-body);">Tiền vé</span>
                            <span style="font-weight:600;">
                                <fmt:formatNumber value="${booking.subTotal}" type="number" maxFractionDigits="0"/>₫
                            </span>
                        </div>
                        <div style="display:flex;justify-content:space-between;">
                            <span style="color:var(--text-body);">Đồ ăn & thức uống</span>
                            <span id="foodTotalDisplay" style="font-weight:600;">0₫</span>
                        </div>
                        <div style="display:flex;justify-content:space-between;">
                            <span style="color:var(--text-body);">Giảm giá voucher</span>
                            <span id="discountDisplay" style="color:#16a34a;font-weight:600;">-0₫</span>
                        </div>
                        <div style="display:flex;justify-content:space-between;padding-top:0.5rem;border-top:2px solid var(--border-light);font-size:1.05rem;font-weight:800;color:var(--text-dark);">
                            <span>Tổng thanh toán</span>
                            <span id="grandTotalDisplay"><fmt:formatNumber value="${booking.totalAmount}" type="number" maxFractionDigits="0"/>₫</span>
                        </div>
                    </div>

                    <%-- Voucher --%>
                    <div style="background:var(--bg-white);border:1px solid var(--border-light);border-radius:14px;padding:0.95rem 1rem;">
                        <div style="display:flex;align-items:center;gap:0.55rem;font-size:0.85rem;font-weight:700;color:var(--text-dark);margin-bottom:0.75rem;">
                            <span style="display:inline-flex;align-items:center;justify-content:center;width:28px;height:28px;border-radius:10px;background:var(--primary-light);color:var(--primary);font-size:1rem;line-height:1;">🏷️</span>
                            <span>Mã giảm giá</span>
                        </div>

                        <%-- Voucher cá nhân từ điểm --%>
                        <c:if test="${not empty myVouchers}">
                            <div style="margin-bottom:0.75rem;">
                                <div style="font-size:0.78rem;color:var(--text-muted);font-weight:600;margin-bottom:0.4rem;letter-spacing:0.04em;">VOUCHER CỦA BẠN</div>
                                <div style="display:flex;flex-direction:column;gap:0.4rem;">
                                    <c:forEach items="${myVouchers}" var="v">
                                        <button type="button" class="voucher-pick-item"
                                                data-code="${v.code}"
                                                data-type="${v.discountType}"
                                                data-value="${v.discountValue}"
                                                style="width:100%;display:flex;align-items:center;justify-content:space-between;gap:0.5rem;border:1.5px dashed #22c55e;border-radius:8px;padding:0.5rem 0.75rem;cursor:pointer;background:#fff;transition:background .15s;text-align:left;">
                                            <div>
                                                <div style="font-family:monospace;font-weight:700;font-size:0.9rem;color:#15803d;">${v.code}</div>
                                                <div style="font-size:0.75rem;color:var(--text-muted);">Hết hạn: ${v.expiredAt.dayOfMonth}/${v.expiredAt.monthValue}/${v.expiredAt.year}</div>
                                            </div>
                                            <span style="font-weight:700;color:#166534;white-space:nowrap;font-size:0.9rem;">
                                                -<fmt:formatNumber value="${v.discountValue}" type="number" maxFractionDigits="0"/>₫
                                            </span>
                                        </button>
                                    </c:forEach>
                                </div>
                            </div>
                        </c:if>

                        <%-- Voucher công khai + Flash Sale --%>
                        <c:if test="${not empty publicVouchers}">
                            <div style="margin-bottom:0.75rem;">
                                <div style="font-size:0.78rem;color:var(--text-muted);font-weight:600;margin-bottom:0.4rem;letter-spacing:0.04em;">
                                    <c:choose>
                                        <c:when test="${not empty myVouchers}">HOẶC CHỌN MÃ KHUYẾN MÃI</c:when>
                                        <c:otherwise>CHỌN MÃ KHUYẾN MÃI</c:otherwise>
                                    </c:choose>
                                </div>
                                <div style="display:flex;flex-direction:column;gap:0.4rem;">
                                    <c:forEach items="${publicVouchers}" var="v">
                                        <button type="button" class="voucher-pick-item"
                                                data-code="${v.code}"
                                                data-type="${v.discountType}"
                                                data-value="${v.discountValue}"
                                                style="width:100%;display:flex;align-items:center;justify-content:space-between;gap:0.5rem;border:1.5px dashed var(--primary);border-radius:8px;padding:0.5rem 0.75rem;cursor:pointer;background:#fff;transition:background .15s;text-align:left;">
                                            <div>
                                                <div style="display:flex;align-items:center;gap:0.4rem;">
                                                    <span style="font-family:monospace;font-weight:700;font-size:0.9rem;color:var(--primary);">${v.code}</span>
                                                    <c:if test="${not empty v.startAt}">
                                                        <span style="font-size:0.68rem;font-weight:700;background:#fef9c3;color:#854d0e;border-radius:4px;padding:0.1rem 0.35rem;">FLASH SALE</span>
                                                    </c:if>
                                                </div>
                                                <div style="font-size:0.75rem;color:var(--text-muted);">
                                                    Còn ${v.maxUsage - v.usedCount} lượt &nbsp;·&nbsp; HSD: ${v.expiredAt.dayOfMonth}/${v.expiredAt.monthValue}/${v.expiredAt.year}
                                                </div>
                                            </div>
                                            <span style="font-weight:700;color:var(--primary);white-space:nowrap;font-size:0.9rem;">
                                                <c:choose>
                                                    <c:when test="${v.discountType == 'Percent'}">-${v.discountValue}%</c:when>
                                                    <c:otherwise>-<fmt:formatNumber value="${v.discountValue}" type="number" maxFractionDigits="0"/>₫</c:otherwise>
                                                </c:choose>
                                            </span>
                                        </button>
                                    </c:forEach>
                                </div>
                            </div>
                        </c:if>

                        <%-- Nhập mã thủ công --%>
                        <div style="font-size:0.78rem;color:var(--text-muted);font-weight:600;margin-bottom:0.4rem;letter-spacing:0.04em;">HOẶC NHẬP MÃ THỦ CÔNG</div>
                        <input type="text"
                               id="voucherCode"
                               name="voucherCode"
                               class="form-input"
                               placeholder="Nhập mã voucher..."
                               value="${param.voucherCode}"
                               style="text-transform:uppercase;">

                        <c:if test="${not empty voucherError}">
                            <p style="color:#b91c1c;font-size:0.85rem;margin-top:0.45rem;background:rgba(185,28,28,0.08);border:1px solid rgba(185,28,28,0.18);padding:0.45rem 0.6rem;border-radius:10px;">
                                ⚠️ ${voucherError}
                            </p>
                        </c:if>
                    </div>

                    <%-- Buttons --%>
                    <div style="display:flex;flex-direction:column;gap:0.6rem;margin-top:0.25rem;">
                        <button type="submit" name="payAction" value="online" class="btn btn-primary" style="font-size:1rem;padding:0.85rem;">
                            💳 Thanh toán VNPay
                        </button>
                        <button type="submit" name="payAction" value="counter" class="btn btn-secondary">
                            🏧 Thanh toán tại quầy
                        </button>
                    </div>
                </div>
            </div>
        </form>
    </div>
</main>

<jsp:include page="/components/footer.jsp"/>

<script>
    const ticketSubTotal = ${booking.subTotal != null ? booking.subTotal : 0};
    const voucherInput = document.getElementById('voucherCode');

    // Map code → {type, value} — build từ data attributes của picker buttons (không hardcode)
    const knownVouchers = {};
    document.querySelectorAll('.voucher-pick-item').forEach(btn => {
        knownVouchers[btn.dataset.code] = { type: btn.dataset.type, value: parseFloat(btn.dataset.value) };
    });

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
        const code = (voucherInput?.value || '').trim().toUpperCase();
        const v = knownVouchers[code];
        if (v) {
            discount = v.type === 'Percent' ? subtotal * v.value / 100 : v.value;
        }
        discount = Math.max(0, Math.min(discount, subtotal));

        document.getElementById('foodTotalDisplay').textContent = fmt(foodTotal);
        document.getElementById('discountDisplay').textContent = '-' + fmt(discount);
        document.getElementById('grandTotalDisplay').textContent = fmt(subtotal - discount);
    }

    document.querySelectorAll('.qty-input').forEach(input => {
        input.addEventListener('input', recalc);
    });

    if (voucherInput) {
        voucherInput.addEventListener('input', recalc);
    }

    // Voucher picker: click chọn/bỏ chọn voucher cá nhân
    document.querySelectorAll('.voucher-pick-item').forEach(btn => {
        btn.addEventListener('click', function() {
            const code = this.dataset.code;
            const isSelected = this.classList.contains('selected');
            // Bỏ chọn tất cả
            document.querySelectorAll('.voucher-pick-item').forEach(b => {
                b.classList.remove('selected');
                b.style.background = '#fff';
                b.style.borderStyle = 'dashed';
            });
            if (!isSelected) {
                this.classList.add('selected');
                this.style.background = '#f0fdf4';
                this.style.borderStyle = 'solid';
                voucherInput.value = code;
            } else {
                voucherInput.value = '';
            }
            recalc();
        });
    });

    // Init hiển thị theo voucher hiện có (nếu có).
    recalc();
</script>

</body>
</html>

