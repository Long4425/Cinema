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
</head>
<body class="home-layout">
<jsp:include page="/components/header.jsp"/>

<main class="home-main">
    <div class="container" style="max-width: 1100px;">
        <div class="page-header">
            <div>
                <h1 class="page-title">Xác nhận đơn hàng</h1>
                <p class="page-subtitle">
                    <c:out value="${showtime.movieTitle}"/> -
                    <c:out value="${showtime.roomName}"/> |
                    <fmt:formatDate value="${showtime.startTime}" pattern="HH:mm dd/MM/yyyy"/>
                </p>
            </div>
        </div>

        <c:if test="${not empty error}">
            <div class="cinema-msg cinema-msg--error" style="margin-bottom: 1rem;">
                ${error}
            </div>
        </c:if>

        <div class="grid" style="display:grid;grid-template-columns:2fr 1.3fr;gap:1.5rem;align-items:flex-start;">
            <div class="card" style="padding:1.5rem;">
                <h2 style="font-size:1.05rem;margin-bottom:0.75rem;">Chọn đồ ăn & thức uống (tuỳ chọn)</h2>
                <c:if test="${empty foodItems}">
                    <p style="font-size:0.9rem;color:var(--text-muted);">Hiện chưa có sản phẩm đồ ăn nào.</p>
                </c:if>
                <c:if test="${not empty foodItems}">
                    <div class="table-wrap">
                        <table class="table">
                            <thead>
                            <tr>
                                <th>Sản phẩm</th>
                                <th style="width:100px;">Giá</th>
                                <th style="width:90px;">Số lượng</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:forEach items="${foodItems}" var="f">
                                <tr>
                                    <td>
                                        <div style="display:flex;flex-direction:column;gap:0.1rem;">
                                            <span style="font-weight:600;"><c:out value="${f.name}"/></span>
                                            <c:if test="${not empty f.description}">
                                                <span style="font-size:0.85rem;color:var(--text-muted);">
                                                    <c:out value="${f.description}"/>
                                                </span>
                                            </c:if>
                                        </div>
                                    </td>
                                    <td>
                                        <fmt:formatNumber value="${f.price}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                    </td>
                                    <td>
                                        <input type="number"
                                               name="qty_${f.foodItemId}"
                                               min="0"
                                               max="20"
                                               value="0"
                                               class="form-input"
                                               style="width:80px;padding-inline:0.4rem;text-align:center;">
                                    </td>
                                </tr>
                            </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:if>
            </div>

            <form method="post" action="booking/checkout" class="card" style="padding:1.5rem;display:flex;flex-direction:column;gap:1rem;">
                <h2 style="font-size:1.05rem;">Tóm tắt đơn hàng</h2>

                <div style="font-size:0.9rem;">
                    <div style="margin-bottom:0.4rem;"><strong>Ghế đã chọn:</strong></div>
                    <c:forEach items="${bookingSeats}" var="bs" varStatus="loop">
                        <span>
                            ${bs.seat.rowLabel}${bs.seat.seatNumber}<c:if test="${!loop.last}">, </c:if>
                        </span>
                    </c:forEach>
                </div>

                <div style="border-top:1px dashed var(--border-light);padding-top:0.75rem;font-size:0.9rem;">
                    <div style="display:flex;justify-content:space-between;margin-bottom:0.25rem;">
                        <span>Tiền vé</span>
                        <span>
                            <fmt:formatNumber value="${booking.subTotal}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                        </span>
                    </div>
                    <div style="display:flex;justify-content:space-between;margin-bottom:0.25rem;">
                        <span>Tiền đồ ăn (ước tính)</span>
                        <span id="foodTotalDisplay">₫0</span>
                    </div>
                    <div style="display:flex;justify-content:space-between;margin-bottom:0.25rem;">
                        <span>Giảm giá</span>
                        <span id="discountDisplay">-₫0</span>
                    </div>
                    <div style="display:flex;justify-content:space-between;font-weight:600;margin-top:0.35rem;">
                        <span>Tổng thanh toán</span>
                        <span id="grandTotalDisplay">
                            <fmt:formatNumber value="${booking.totalAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                        </span>
                    </div>
                </div>

                <div>
                    <label for="voucherCode" class="form-label">Mã voucher</label>
                    <input type="text" id="voucherCode" name="voucherCode" class="form-input" placeholder="Nhập mã giảm giá (nếu có)">
                    <c:if test="${not empty voucherError}">
                        <p style="color:#b91c1c;font-size:0.85rem;margin-top:0.25rem;">${voucherError}</p>
                    </c:if>
                </div>

                <div style="display:flex;flex-direction:column;gap:0.5rem;margin-top:0.5rem;">
                    <button type="submit" name="payAction" value="online" class="btn btn-primary">
                        Thanh toán online VNPay
                    </button>
                    <button type="submit" name="payAction" value="counter" class="btn btn-secondary">
                        Thanh toán tại quầy
                    </button>
                </div>
            </form>
        </div>
    </div>
</main>

<jsp:include page="/components/footer.jsp"/>

<script>
    (function () {
        const foodRows = document.querySelectorAll('input[name^="qty_"]');
        const foodTotalDisplay = document.getElementById('foodTotalDisplay');
        const voucherInput = document.getElementById('voucherCode');
        const discountDisplay = document.getElementById('discountDisplay');
        const grandTotalDisplay = document.getElementById('grandTotalDisplay');
        const ticketSubTotal = ${booking.subTotal != null ? booking.subTotal : 0};

        function parsePrice(text) {
            return Number(String(text).replace(/[^0-9.-]/g, '')) || 0;
        }

        function formatCurrency(vnd) {
            return new Intl.NumberFormat('vi-VN', {style: 'currency', currency: 'VND', maximumFractionDigits: 0}).format(vnd);
        }

        function recalcEstimate() {
            let foodTotal = 0;
            foodRows.forEach(input => {
                const qty = Number(input.value) || 0;
                if (qty <= 0) return;
                const row = input.closest('tr');
                if (!row) return;
                const priceCell = row.querySelector('td:nth-child(2)');
                if (!priceCell) return;
                const price = parsePrice(priceCell.textContent);
                foodTotal += price * qty;
            });

            foodTotalDisplay.textContent = formatCurrency(foodTotal);

            // Chỉ estimate đơn giản ở client, discount chính xác sẽ tính ở server
            discountDisplay.textContent = '-₫0';
            const grand = ticketSubTotal + foodTotal;
            grandTotalDisplay.textContent = formatCurrency(grand);
        }

        foodRows.forEach(input => {
            input.addEventListener('change', recalcEstimate);
            input.addEventListener('input', recalcEstimate);
        });

        voucherInput.addEventListener('input', function () {
            // chỉ reset hiển thị discount, server sẽ tính chính xác sau submit
            discountDisplay.textContent = '-₫0';
        });
    })();
</script>

</body>
</html>

