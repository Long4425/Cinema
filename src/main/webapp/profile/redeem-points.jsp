<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đổi điểm lấy voucher</title>
    <base href="${pageContext.request.contextPath}/">
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/header.css">
    <link rel="stylesheet" href="css/footer.css">
    <link rel="stylesheet" href="css/dashboard.css">
    <link rel="stylesheet" href="css/button.css">
    <link rel="stylesheet" href="css/message.css">
    <style>
        .redeem-layout {
            display: flex;
            gap: 1.5rem;
            align-items: flex-start;
            flex-wrap: wrap;
        }
        .redeem-main { flex: 1; min-width: 280px; }
        .redeem-side { width: 320px; min-width: 260px; }

        .points-hero {
            background: linear-gradient(135deg, #fffbeb 0%, #fef3c7 100%);
            border: 1px solid #fcd34d;
            border-radius: 14px;
            padding: 1.5rem 2rem;
            display: flex;
            align-items: center;
            gap: 1.25rem;
            margin-bottom: 1.5rem;
        }
        .points-hero__icon { font-size: 2.5rem; line-height: 1; }
        .points-hero__label { font-size: 0.85rem; color: #92400e; margin-bottom: 0.2rem; }
        .points-hero__value { font-size: 2.5rem; font-weight: 900; color: #78350f; line-height: 1; }
        .points-hero__unit { font-size: 1rem; font-weight: 600; color: #92400e; }

        .option-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 1rem;
        }
        .option-card {
            border: 2px solid var(--border-light);
            border-radius: 12px;
            padding: 1.25rem;
            text-align: center;
            cursor: pointer;
            transition: border-color .15s, box-shadow .15s, transform .1s;
            background: #fff;
        }
        .option-card:hover { border-color: var(--primary); box-shadow: 0 4px 16px rgba(0,0,0,.08); transform: translateY(-2px); }
        .option-card--disabled { opacity: 0.45; cursor: not-allowed; pointer-events: none; }
        .option-card__value {
            font-size: 1.6rem;
            font-weight: 800;
            color: var(--primary);
            margin-bottom: 0.3rem;
        }
        .option-card__cost {
            font-size: 0.85rem;
            color: var(--text-muted);
            margin-bottom: 1rem;
        }
        .option-card__cost strong { color: #d97706; }

        .voucher-list { display: flex; flex-direction: column; gap: 0.6rem; }
        .voucher-item {
            background: #fff;
            border: 1.5px dashed #22c55e;
            border-radius: 8px;
            padding: 0.65rem 1rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 0.5rem;
            flex-wrap: wrap;
        }
        .voucher-item__code {
            font-family: monospace;
            font-weight: 700;
            font-size: 0.9rem;
            color: #15803d;
            letter-spacing: 0.04em;
        }
        .voucher-item__val { font-weight: 600; color: #166534; white-space: nowrap; }
        .voucher-item__exp { font-size: 0.75rem; color: var(--text-muted); white-space: nowrap; }
    </style>
</head>
<body class="home-layout">
<jsp:include page="/components/header.jsp"/>

<main class="home-main">
    <div class="container container--lg">
        <div class="page-header">
            <div>
                <h1 class="page-title">Đổi điểm lấy voucher</h1>
                <p class="page-subtitle">Dùng điểm tích lũy để đổi voucher giảm giá cho lần đặt vé tiếp theo.</p>
            </div>
            <a href="profile/bookings" class="btn btn-secondary">Lịch sử đặt vé</a>
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

        <div class="redeem-layout">
            <%-- Cột trái: điểm hiện tại + bảng đổi --%>
            <div class="redeem-main">
                <%-- Điểm hiện tại --%>
                <div class="points-hero">
                    <div class="points-hero__icon">&#127775;</div>
                    <div>
                        <div class="points-hero__label">Điểm tích lũy của bạn</div>
                        <div>
                            <span class="points-hero__value">${sessionScope.user.loyaltyPoint}</span>
                            <span class="points-hero__unit"> điểm</span>
                        </div>
                        <div style="font-size:0.8rem;color:#92400e;margin-top:0.3rem;">
                            Mỗi 10.000₫ chi tiêu = 1 điểm
                        </div>
                    </div>
                </div>

                <%-- Bảng đổi điểm --%>
                <div class="card" style="padding:1.5rem;">
                    <h2 style="font-size:1rem;font-weight:700;margin-bottom:1.25rem;color:var(--text-dark);">Chọn mệnh giá voucher</h2>
                    <div class="option-grid">
                        <c:forEach items="${redeemOptions}" var="opt">
                            <c:set var="canAfford" value="${sessionScope.user.loyaltyPoint >= opt[0]}"/>
                            <div class="option-card ${canAfford ? '' : 'option-card--disabled'}">
                                <div class="option-card__value">
                                    <fmt:formatNumber value="${opt[1]}" type="number" maxFractionDigits="0"/>₫
                                </div>
                                <div class="option-card__cost">
                                    Cần <strong>${opt[0]} điểm</strong>
                                </div>
                                <form method="post" action="profile/redeem-points">
                                    <input type="hidden" name="points" value="${opt[0]}">
                                    <button type="submit" class="btn btn-primary" style="width:100%;">Đổi ngay</button>
                                </form>
                            </div>
                        </c:forEach>
                    </div>
                    <p style="margin-top:1.25rem;font-size:0.8rem;color:var(--text-muted);">
                        Voucher có hạn sử dụng 1 năm kể từ ngày đổi. Mỗi voucher chỉ dùng được 1 lần.
                    </p>
                </div>
            </div>

            <%-- Cột phải: voucher đã đổi còn hiệu lực --%>
            <div class="redeem-side">
                <div class="card" style="padding:1.25rem;">
                    <h2 style="font-size:1rem;font-weight:700;margin-bottom:1rem;color:var(--text-dark);">
                        Voucher của tôi
                        <c:if test="${not empty myVouchers}">
                            <span style="font-size:0.8rem;font-weight:400;color:var(--text-muted);">(${fn:length(myVouchers)} mã còn hiệu lực)</span>
                        </c:if>
                    </h2>
                    <c:choose>
                        <c:when test="${empty myVouchers}">
                            <p style="font-size:0.875rem;color:var(--text-muted);">Bạn chưa có voucher nào. Hãy đổi điểm để nhận!</p>
                        </c:when>
                        <c:otherwise>
                            <div class="voucher-list">
                                <c:forEach items="${myVouchers}" var="v">
                                    <div class="voucher-item">
                                        <span class="voucher-item__code">${v.code}</span>
                                        <span class="voucher-item__val">
                                            -<fmt:formatNumber value="${v.discountValue}" type="number" maxFractionDigits="0"/>₫
                                        </span>
                                        <span class="voucher-item__exp">
                                            HSD: ${v.expiredAt.dayOfMonth}/${v.expiredAt.monthValue}/${v.expiredAt.year}
                                        </span>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/components/footer.jsp"/>
</body>
</html>
