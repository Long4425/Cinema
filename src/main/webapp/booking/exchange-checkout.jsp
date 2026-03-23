<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Xác nhận đổi vé</title>
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
                <h1 class="page-title">Xác nhận đổi vé #${booking.bookingId}</h1>
                <p class="page-subtitle">Chọn đồ ăn và voucher cho suất mới (nếu muốn).</p>
            </div>
        </div>

        <c:if test="${not empty voucherError}">
            <div class="cinema-msg cinema-msg--error" style="margin-bottom:1rem;">${voucherError}</div>
        </c:if>

        <form method="post" action="booking/exchange-checkout" id="checkoutForm">
            <div style="display:grid; grid-template-columns:1fr 380px; gap:1.5rem; align-items:flex-start;">

                <%-- LEFT --%>
                <div style="display:flex; flex-direction:column; gap:1rem;">

                    <%-- So sánh suất cũ / mới --%>
                    <div class="card" style="padding:1.25rem;">
                        <h2 style="font-size:1rem; font-weight:700; margin-bottom:0.75rem;">Thay đổi suất chiếu</h2>
                        <div style="display:grid; grid-template-columns:1fr 1fr; gap:1rem; font-size:0.9rem;">
                            <div style="background:var(--bg-light); border-radius:10px; padding:0.85rem;">
                                <div style="font-size:0.75rem; color:var(--text-muted); font-weight:600; margin-bottom:0.4rem;">SUẤT CŨ</div>
                                <div style="font-weight:700;"><c:out value="${oldShowtime.room.roomName}"/> <span style="font-size:0.75rem; color:var(--text-muted);">${oldShowtime.room.roomType}</span></div>
                                <div style="color:var(--text-muted);">
                                    <fmt:formatNumber value="${oldShowtime.startTime.hour}" minIntegerDigits="2"/>:<fmt:formatNumber value="${oldShowtime.startTime.minute}" minIntegerDigits="2"/>
                                    ${oldShowtime.startTime.dayOfMonth}/${oldShowtime.startTime.monthValue}/${oldShowtime.startTime.year}
                                </div>
                                <div style="margin-top:0.4rem; font-size:0.8rem;">
                                    Ghế:
                                    <c:forEach items="${oldSeats}" var="bs" varStatus="l">
                                        <strong>${bs.seat.rowLabel}${bs.seat.seatNumber}</strong><c:if test="${!l.last}">, </c:if>
                                    </c:forEach>
                                </div>
                                <div style="margin-top:0.3rem; color:var(--text-muted); font-size:0.8rem;">
                                    <fmt:formatNumber value="${oldSeatPrice}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>/ghế
                                </div>
                            </div>
                            <div style="background:#eff6ff; border:1px solid #bfdbfe; border-radius:10px; padding:0.85rem;">
                                <div style="font-size:0.75rem; color:#1d4ed8; font-weight:600; margin-bottom:0.4rem;">SUẤT MỚI</div>
                                <div style="font-weight:700;"><c:out value="${newShowtime.room.roomName}"/> <span style="font-size:0.75rem; color:var(--text-muted);">${newShowtime.room.roomType}</span></div>
                                <div style="color:var(--text-muted);">
                                    <fmt:formatNumber value="${newShowtime.startTime.hour}" minIntegerDigits="2"/>:<fmt:formatNumber value="${newShowtime.startTime.minute}" minIntegerDigits="2"/>
                                    ${newShowtime.startTime.dayOfMonth}/${newShowtime.startTime.monthValue}/${newShowtime.startTime.year}
                                </div>
                                <div style="margin-top:0.4rem; font-size:0.8rem;">
                                    Ghế đã chọn: <strong>${seatCount}</strong> ghế
                                </div>
                                <div style="margin-top:0.3rem; color:var(--text-muted); font-size:0.8rem;">
                                    <fmt:formatNumber value="${newSeatPrice}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>/ghế
                                </div>
                            </div>
                        </div>
                        <c:set var="seatDiff" value="${newSeatPrice - oldSeatPrice}"/>
                        <c:if test="${seatDiff > 0}">
                            <div class="cinema-msg cinema-msg--warning" style="margin-top:0.75rem; font-size:0.85rem;">
                                Chênh lệch giá ghế: +<fmt:formatNumber value="${seatDiff * seatCount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                <c:choose>
                                    <c:when test="${sessionScope.user.role.roleCode == 'CUSTOMER'}"> — sẽ thanh toán qua VNPay.</c:when>
                                    <c:otherwise> — thu tại quầy.</c:otherwise>
                                </c:choose>
                            </div>
                        </c:if>
                    </div>

                    <%-- Food selection --%>
                    <div class="card" style="padding:1.5rem;">
                        <h2 style="font-size:1.05rem; font-weight:700; margin-bottom:1rem;">
                            Đồ ăn & thức uống <span style="font-size:0.8rem; color:var(--text-muted); font-weight:400;">(tuỳ chọn — thay thế combo cũ)</span>
                        </h2>
                        <c:if test="${empty allFoodItems}">
                            <p style="font-size:0.9rem; color:var(--text-muted);">Hiện chưa có sản phẩm đồ ăn nào.</p>
                        </c:if>
                        <c:if test="${not empty allFoodItems}">
                            <div style="display:grid; grid-template-columns:repeat(auto-fill,minmax(200px,1fr)); gap:0.75rem;">
                                <c:forEach items="${allFoodItems}" var="f">
                                    <c:set var="oldQty" value="${oldFoodQtyMap[f.foodItemId]}"/>
                                    <c:set var="initQty" value="${oldQty != null ? oldQty : 0}"/>
                                    <div style="border:1px solid var(--border-light); border-radius:12px; padding:1rem; display:flex; flex-direction:column; gap:0.6rem; background:var(--bg-white);">
                                        <div style="width:100%; height:92px; border-radius:10px; overflow:hidden; background:var(--bg-hover); border:1px solid var(--border-light);">
                                            <img src="images/food.jpg" alt="${f.name}" style="width:100%; height:100%; object-fit:contain; display:block;">
                                        </div>
                                        <div style="text-align:center;">
                                            <div style="font-weight:700; font-size:0.9rem;"><c:out value="${f.name}"/></div>
                                            <c:if test="${not empty f.description}">
                                                <div style="font-size:0.78rem; color:var(--text-muted);"><c:out value="${f.description}"/></div>
                                            </c:if>
                                        </div>
                                        <div style="text-align:center; font-weight:700; color:var(--primary); font-size:0.95rem;">
                                            <fmt:formatNumber value="${f.price}" type="number" maxFractionDigits="0"/>₫
                                        </div>
                                        <div style="display:flex; align-items:center; justify-content:center; gap:0.5rem;">
                                            <button type="button" onclick="changeQty(this,-1)" style="width:30px; height:30px; border-radius:50%; border:1px solid var(--border-light); background:var(--bg-light); cursor:pointer; font-size:1.1rem; font-weight:700; display:flex; align-items:center; justify-content:center;">−</button>
                                            <input type="number" name="qty_${f.foodItemId}" min="0" max="20"
                                                   value="${initQty}" data-price="${f.price}" class="qty-input"
                                                   style="width:46px; text-align:center; border:1px solid var(--border-light); border-radius:8px; padding:0.3rem; font-size:0.95rem; font-weight:600;">
                                            <button type="button" onclick="changeQty(this,1)" style="width:30px; height:30px; border-radius:50%; border:1px solid var(--border-light); background:var(--bg-light); cursor:pointer; font-size:1.1rem; font-weight:700; display:flex; align-items:center; justify-content:center;">+</button>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:if>
                    </div>
                </div>

                <%-- RIGHT: summary --%>
                <div class="card" style="padding:1.5rem; display:flex; flex-direction:column; gap:1rem; position:sticky; top:calc(var(--header-height) + 1rem);">
                    <h2 style="font-size:1.05rem; font-weight:700;">Tóm tắt đơn hàng</h2>

                    <div style="font-size:0.9rem; display:flex; flex-direction:column; gap:0.4rem;">
                        <div style="display:flex; justify-content:space-between;">
                            <span style="color:var(--text-body);">Tiền vé mới</span>
                            <span id="ticketDisplay" style="font-weight:600;">
                                <fmt:formatNumber value="${newTicketSubTotal}" type="number" maxFractionDigits="0"/>₫
                            </span>
                        </div>
                        <div style="display:flex; justify-content:space-between;">
                            <span style="color:var(--text-body);">Đồ ăn & thức uống</span>
                            <span id="foodTotalDisplay" style="font-weight:600;">0₫</span>
                        </div>
                        <div style="display:flex; justify-content:space-between;">
                            <span style="color:var(--text-body);">Giảm giá voucher</span>
                            <span id="discountDisplay" style="color:#16a34a; font-weight:600;">-0₫</span>
                        </div>
                        <div style="display:flex; justify-content:space-between; padding-top:0.5rem; border-top:2px solid var(--border-light); font-size:1.05rem; font-weight:800; color:var(--text-dark);">
                            <span>Tổng mới</span>
                            <span id="grandTotalDisplay">
                                <fmt:formatNumber value="${newTicketSubTotal}" type="number" maxFractionDigits="0"/>₫
                            </span>
                        </div>
                        <c:set var="seatSurcharge" value="${(newSeatPrice - oldSeatPrice) * seatCount}"/>
                        <c:if test="${seatSurcharge > 0}">
                            <div style="display:flex; justify-content:space-between; padding-top:0.4rem; font-size:0.88rem; color:#d97706; font-weight:600;">
                                <span>Phụ thu chênh lệch ghế</span>
                                <span id="surchargeDisplay">+<fmt:formatNumber value="${seatSurcharge}" type="number" maxFractionDigits="0"/>₫</span>
                            </div>
                        </c:if>
                    </div>

                    <%-- Voucher --%>
                    <div style="background:var(--bg-white); border:1px solid var(--border-light); border-radius:14px; padding:0.95rem 1rem;">
                        <div style="display:flex; align-items:center; gap:0.55rem; font-size:0.85rem; font-weight:700; color:var(--text-dark); margin-bottom:0.75rem;">
                            <span>🏷️ Mã giảm giá</span>
                        </div>

                        <%-- Voucher cá nhân từ điểm --%>
                        <c:if test="${not empty myVouchers}">
                            <div style="margin-bottom:0.75rem;">
                                <div style="font-size:0.78rem;color:var(--text-muted);font-weight:600;margin-bottom:0.4rem;">VOUCHER CỦA BẠN</div>
                                <div style="display:flex;flex-direction:column;gap:0.4rem;">
                                    <c:forEach items="${myVouchers}" var="v">
                                        <button type="button" class="voucher-pick-item" data-code="${v.code}"
                                                style="width:100%;display:flex;align-items:center;justify-content:space-between;gap:0.5rem;border:1.5px dashed #22c55e;border-radius:8px;padding:0.5rem 0.75rem;cursor:pointer;background:#fff;transition:background .15s;text-align:left;">
                                            <span style="font-family:monospace;font-weight:700;font-size:0.9rem;color:#15803d;">${v.code}</span>
                                            <span style="font-weight:600;color:#166534;white-space:nowrap;">
                                                -<fmt:formatNumber value="${v.discountValue}" type="number" maxFractionDigits="0"/>₫
                                            </span>
                                        </button>
                                    </c:forEach>
                                </div>
                            </div>
                        </c:if>

                        <%-- Nhập mã thủ công --%>
                        <div style="font-size:0.78rem;color:var(--text-muted);font-weight:600;margin-bottom:0.4rem;">
                            <c:choose>
                                <c:when test="${not empty myVouchers}">HOẶC NHẬP MÃ KHÁC</c:when>
                                <c:otherwise>NHẬP MÃ VOUCHER</c:otherwise>
                            </c:choose>
                        </div>
                        <input type="text" id="voucherCode" name="voucherCode" class="form-input"
                               placeholder="Nhập mã voucher..." value="${param.voucherCode}">

                        <c:if test="${not empty voucherError}">
                            <p style="color:#b91c1c; font-size:0.85rem; margin-top:0.45rem; background:rgba(185,28,28,0.08); border:1px solid rgba(185,28,28,0.18); padding:0.45rem 0.6rem; border-radius:10px;">
                                ⚠️ ${voucherError}
                            </p>
                        </c:if>
                    </div>

                    <div style="display:flex; flex-direction:column; gap:0.6rem; margin-top:0.25rem;">
                        <c:choose>
                            <c:when test="${sessionScope.user.role.roleCode == 'CUSTOMER'}">
                                <button type="submit" name="payAction" value="online" class="btn btn-primary" style="font-size:1rem; padding:0.85rem;">
                                    Xác nhận đổi vé
                                    <c:if test="${seatSurcharge > 0}"> + Thanh toán VNPay</c:if>
                                </button>
                            </c:when>
                            <c:otherwise>
                                <button type="submit" name="payAction" value="counter" class="btn btn-primary" style="font-size:1rem; padding:0.85rem;">
                                    Xác nhận đổi vé
                                    <c:if test="${seatSurcharge > 0}"> + Thu tiền mặt</c:if>
                                </button>
                            </c:otherwise>
                        </c:choose>
                        <a href="booking/exchange?bookingId=${booking.bookingId}" class="btn btn-secondary" style="text-align:center;">Huỷ</a>
                    </div>
                </div>
            </div>
        </form>
    </div>
</main>

<jsp:include page="/components/footer.jsp"/>

<script>
    const newTicketSubTotal = ${newTicketSubTotal};
    const voucherInput = document.getElementById('voucherCode');

    const knownVouchers = {
        'WELCOME10': { type: 'Percent',     value: 10 },
        'SUMMER50K': { type: 'FixedAmount', value: 50000 }
    };
    <c:forEach items="${myVouchers}" var="v">
    knownVouchers['${v.code}'] = { type: '${v.discountType}', value: ${v.discountValue} };
    </c:forEach>

    function fmt(n) {
        return new Intl.NumberFormat('vi-VN').format(Math.round(n)) + '₫';
    }

    function changeQty(btn, delta) {
        const input = btn.parentElement.querySelector('.qty-input');
        input.value = Math.max(0, Math.min(20, (parseInt(input.value) || 0) + delta));
        recalc();
    }

    function recalc() {
        let foodTotal = 0;
        document.querySelectorAll('.qty-input').forEach(input => {
            foodTotal += (parseInt(input.value) || 0) * (parseFloat(input.dataset.price) || 0);
        });
        const subTotal = newTicketSubTotal + foodTotal;

        let discount = 0;
        const code = (voucherInput?.value || '').trim().toUpperCase();
        const v = knownVouchers[code];
        if (v) {
            discount = v.type === 'Percent' ? subTotal * v.value / 100 : v.value;
        }
        discount = Math.max(0, Math.min(discount, subTotal));

        document.getElementById('foodTotalDisplay').textContent = fmt(foodTotal);
        document.getElementById('discountDisplay').textContent = '-' + fmt(discount);
        document.getElementById('grandTotalDisplay').textContent = fmt(subTotal - discount);
    }

    document.querySelectorAll('.qty-input').forEach(i => i.addEventListener('input', recalc));
    if (voucherInput) voucherInput.addEventListener('input', recalc);

    // Voucher picker: click chọn/bỏ chọn voucher cá nhân
    document.querySelectorAll('.voucher-pick-item').forEach(btn => {
        btn.addEventListener('click', function() {
            const code = this.dataset.code;
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
                voucherInput.value = code;
            } else {
                voucherInput.value = '';
            }
            recalc();
        });
    });

    recalc();
</script>
</body>
</html>
