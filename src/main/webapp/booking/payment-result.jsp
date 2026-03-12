<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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
    <link rel="stylesheet" href="css/dashboard.css">
    <link rel="stylesheet" href="css/button.css">
    <link rel="stylesheet" href="css/message.css">
</head>
<body class="home-layout">
<jsp:include page="/components/header.jsp"/>

<main class="home-main">
    <div class="container" style="max-width: 720px;">
        <div class="page-header">
            <h1 class="page-title">Kết quả thanh toán</h1>
        </div>

        <c:choose>
            <c:when test="${paymentStatus == 'success'}">
                <div class="cinema-msg cinema-msg--success" style="margin-bottom: 1rem;">
                    ${message}
                </div>
            </c:when>
            <c:otherwise>
                <div class="cinema-msg cinema-msg--error" style="margin-bottom: 1rem;">
                    ${message}
                </div>
            </c:otherwise>
        </c:choose>

        <div class="card" style="padding: 1.5rem;">
            <h2 style="font-size: 1rem; margin-bottom: 0.75rem;">Thông tin giao dịch</h2>
            <ul style="list-style: none; padding: 0; margin: 0; font-size: 0.9rem;">
                <li><strong>Mã giao dịch:</strong> ${vnp_TransactionNo}</li>
                <li><strong>Mã tham chiếu:</strong> ${vnp_TxnRef}</li>
                <li><strong>Ngân hàng:</strong> ${vnp_BankCode}</li>
                <li><strong>Số tiền:</strong> ${vnp_Amount}</li>
                <li><strong>Trạng thái từ VNPay:</strong> ${vnp_ResponseCode}</li>
            </ul>

            <div style="margin-top:1.5rem;display:flex;gap:0.75rem;flex-wrap:wrap;">
                <a href="booking/summary?bookingId=${bookingId}" class="btn btn-primary">
                    Xem vé / chi tiết đơn
                </a>
                <a href="movies" class="btn btn-secondary">
                    Đặt thêm vé khác
                </a>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/components/footer.jsp"/>
</body>
</html>

