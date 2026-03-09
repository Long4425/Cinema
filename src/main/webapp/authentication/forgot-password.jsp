<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quên mật khẩu | Cinema</title>
    <base href="${pageContext.request.scheme}://${pageContext.request.serverName}:${pageContext.request.serverPort}${pageContext.request.contextPath}/">
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/form.css">
    <link rel="stylesheet" href="css/auth.css">
</head>
<body class="auth-page">
    <div class="auth-card">
        <div class="auth-brand">
            <div class="auth-brand__logo">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                    <rect x="2" y="2" width="20" height="20" rx="2"/>
                    <rect x="7" y="2" width="3" height="4"/>
                    <rect x="14" y="2" width="3" height="4"/>
                    <rect x="7" y="18" width="3" height="4"/>
                    <rect x="14" y="18" width="3" height="4"/>
                </svg>
            </div>
            <span class="auth-brand__name">Cinema</span>
        </div>
        <header class="auth-card__header">
            <h1 class="auth-card__title">Quên mật khẩu</h1>
            <p class="auth-card__subtitle">Nhập email để nhận link đặt lại mật khẩu</p>
        </header>

        <c:if test="${not empty error}">
            <div class="auth-msg auth-msg--error cinema-msg" role="alert">${error}</div>
        </c:if>
        <c:if test="${not empty success}">
            <div class="auth-msg auth-msg--success cinema-msg" role="status">${success}</div>
        </c:if>

        <form class="auth-form" action="<c:url value='/forgot-password'/>" method="post">
            <div class="form-group">
                <label class="form-label" for="email">Email</label>
                <input type="email" id="email" name="email" class="form-input" value="${email}"
                       placeholder="email@example.com" required autocomplete="email">
            </div>

            <button type="submit" class="btn btn-primary">Gửi link đặt lại mật khẩu</button>
        </form>

        <div class="auth-links">
            <a href="<c:url value='/login'/>">Quay lại đăng nhập</a>
        </div>
    </div>
    <script src="js/message-auto-hide.js"></script>
</body>
</html>
