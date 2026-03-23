<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kết quả thanh toán</title>
    <base href="${pageContext.request.contextPath}/">
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/header.css">
    <link rel="stylesheet" href="css/footer.css">
    <link rel="stylesheet" href="css/button.css">
    <style>
        .result-wrapper {
            display: flex;
            align-items: flex-start;
            justify-content: center;
            padding: 3rem 1.25rem 4rem;
        }
        .result-card {
            background: var(--bg-white);
            border: 1px solid var(--border-light);
            border-radius: 16px;
            box-shadow: 0 4px 24px rgba(0,0,0,.08);
            width: 100%;
            max-width: 560px;
            overflow: hidden;
        }
        .result-card__banner {
            padding: 2.5rem 2rem 2rem;
            text-align: center;
        }
        .result-card__banner--success { background: linear-gradient(135deg, #ecfdf5 0%, #d1fae5 100%); }
        .result-card__banner--failed  { background: linear-gradient(135deg, #fef2f2 0%, #fee2e2 100%); }

        .result-icon {
            width: 64px;
            height: 64px;
            border-radius: 50%;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 2rem;
            margin-bottom: 1rem;
        }
        .result-icon--success { background: #10b981; color: #fff; }
        .result-icon--failed  { background: #ef4444; color: #fff; }

        .result-card__title {
            font-size: 1.375rem;
            font-weight: 700;
            margin-bottom: 0.35rem;
        }
        .result-card__title--success { color: #065f46; }
        .result-card__title--failed  { color: #991b1b; }

        .result-card__subtitle {
            font-size: 0.9rem;
            color: var(--text-muted);
        }

        .result-card__body {
            padding: 1.5rem 2rem 2rem;
        }

        .txn-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 0.875rem;
        }
        .txn-table tr {
            border-bottom: 1px solid var(--border-light);
        }
        .txn-table tr:last-child { border-bottom: none; }
        .txn-table td {
            padding: 0.65rem 0;
            vertical-align: top;
        }
        .txn-table td:first-child {
            color: var(--text-muted);
            width: 45%;
            white-space: nowrap;
        }
        .txn-table td:last-child {
            font-weight: 500;
            color: var(--text-dark);
            word-break: break-all;
        }
        .txn-amount {
            font-size: 1.1rem;
            font-weight: 700;
            color: var(--primary);
        }

        .result-actions {
            display: flex;
            gap: 0.75rem;
            flex-wrap: wrap;
            margin-top: 1.75rem;
        }
        .result-actions .btn { flex: 1; text-align: center; }

        .points-banner {
            background: linear-gradient(135deg, #fffbeb 0%, #fef3c7 100%);
            border: 1px solid #fcd34d;
            border-radius: 10px;
            padding: 1rem 1.25rem;
            margin-bottom: 1rem;
            font-size: 0.875rem;
            color: #92400e;
        }
        .points-banner__title {
            font-weight: 700;
            font-size: 0.95rem;
            margin-bottom: 0.3rem;
            color: #78350f;
        }
        .voucher-banner {
            background: linear-gradient(135deg, #f0fdf4 0%, #dcfce7 100%);
            border: 1px solid #86efac;
            border-radius: 10px;
            padding: 1rem 1.25rem;
            margin-bottom: 1rem;
            font-size: 0.875rem;
            color: #166534;
        }
        .voucher-banner__title {
            font-weight: 700;
            font-size: 0.95rem;
            margin-bottom: 0.5rem;
            color: #14532d;
        }
        .voucher-code {
            display: inline-block;
            background: #fff;
            border: 1.5px dashed #22c55e;
            border-radius: 6px;
            padding: 0.3rem 0.75rem;
            font-family: monospace;
            font-size: 0.95rem;
            font-weight: 700;
            color: #15803d;
            margin: 0.2rem 0;
            letter-spacing: 0.04em;
        }
    </style>
</head>
<body class="home-layout">
<jsp:include page="/components/header.jsp"/>

<main class="home-main">
    <div class="result-wrapper">
        <div class="result-card">
            <%-- Banner --%>
            <c:choose>
                <c:when test="${paymentStatus == 'success'}">
                    <div class="result-card__banner result-card__banner--success">
                        <div class="result-icon result-icon--success">&#10003;</div>
                        <div class="result-card__title result-card__title--success">Thanh toán thành công</div>
                        <div class="result-card__subtitle">Vé của bạn đã được xác nhận. Chúc bạn xem phim vui vẻ!</div>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="result-card__banner result-card__banner--failed">
                        <div class="result-icon result-icon--failed">&#10007;</div>
                        <div class="result-card__title result-card__title--failed">Thanh toán thất bại</div>
                        <div class="result-card__subtitle">${message}</div>
                    </div>
                </c:otherwise>
            </c:choose>

            <%-- Transaction details --%>
            <div class="result-card__body">
                <%-- UC-24: Thông báo điểm tích lũy --%>
                <c:if test="${paymentStatus == 'success' and not empty pointsEarned and pointsEarned > 0}">
                    <div class="points-banner">
                        <div class="points-banner__title">&#127775; Điểm tích lũy</div>
                        Bạn vừa nhận được <strong>+${pointsEarned} điểm</strong> từ giao dịch này.
                        Tổng điểm hiện tại: <strong>${totalPoints} điểm</strong>.
                        <br>Tích đủ <strong>10 điểm</strong> để nhận voucher giảm 20.000₫.
                    </div>
                </c:if>
                <%-- UC-25: Gợi ý đổi điểm nếu tích lũy đủ --%>
                <c:if test="${paymentStatus == 'success' and not empty totalPoints and totalPoints >= 10}">
                    <div class="voucher-banner">
                        <div class="voucher-banner__title">&#127873; Bạn có thể đổi voucher!</div>
                        Bạn đang có <strong>${totalPoints} điểm</strong> — đủ để đổi voucher giảm giá.
                        <div style="margin-top:0.75rem;">
                            <a href="profile/redeem-points" class="btn btn-primary" style="font-size:0.875rem; padding:0.5rem 1.25rem;">
                                Đổi điểm ngay
                            </a>
                        </div>
                    </div>
                </c:if>
                <table class="txn-table">
                    <c:if test="${not empty vnp_TransactionNo}">
                    <tr>
                        <td>Mã giao dịch VNPay</td>
                        <td>${vnp_TransactionNo}</td>
                    </tr>
                    </c:if>
                    <tr>
                        <td>Mã tham chiếu</td>
                        <td>${vnp_TxnRef}</td>
                    </tr>
                    <c:if test="${not empty vnp_BankCode}">
                    <tr>
                        <td>Ngân hàng</td>
                        <td>${vnp_BankCode}</td>
                    </tr>
                    </c:if>
                    <c:if test="${not empty vnp_Amount}">
                    <tr>
                        <td>Số tiền</td>
                        <td class="txn-amount">
                            <fmt:formatNumber value="${vnp_Amount / 100}" type="number" maxFractionDigits="0"/> ₫
                        </td>
                    </tr>
                    </c:if>
                    <c:if test="${not empty vnp_PayDate}">
                    <tr>
                        <td>Thời gian</td>
                        <td>${fn:substring(vnp_PayDate,6,8)}/${fn:substring(vnp_PayDate,4,6)}/${fn:substring(vnp_PayDate,0,4)}
                            ${fn:substring(vnp_PayDate,8,10)}:${fn:substring(vnp_PayDate,10,12)}</td>
                    </tr>
                    </c:if>
                </table>

                <div class="result-actions">
                    <c:choose>
                        <c:when test="${paymentStatus == 'success'}">
                            <a href="booking/summary?bookingId=${bookingId}" class="btn btn-primary">
                                Xem chi tiết vé
                            </a>
                            <a href="movies" class="btn btn-secondary">
                                Đặt thêm vé
                            </a>
                        </c:when>
                        <c:otherwise>
                            <a href="movies" class="btn btn-primary">
                                Chọn phim khác
                            </a>
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
