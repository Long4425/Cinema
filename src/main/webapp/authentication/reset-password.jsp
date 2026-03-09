<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đặt lại mật khẩu | Cinema</title>
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
            <h1 class="auth-card__title">Đặt lại mật khẩu</h1>
            <p class="auth-card__subtitle">Nhập mật khẩu mới cho tài khoản của bạn</p>
        </header>

        <c:if test="${not empty error}">
            <div class="auth-msg auth-msg--error cinema-msg" role="alert">${error}</div>
        </c:if>
        <c:if test="${not empty success}">
            <div class="auth-msg auth-msg--success cinema-msg" role="status">${success}</div>
        </c:if>

        <c:if test="${not empty token}">
        <form class="auth-form" action="<c:url value='/reset-password'/>" method="post">
            <input type="hidden" name="token" value="${token}">
            <div class="form-group">
                <label class="form-label" for="password">Mật khẩu mới</label>
                <input type="password" id="password" name="password" class="form-input"
                       placeholder="Ít nhất 6 ký tự" required autocomplete="new-password">
            </div>
            <div class="form-group">
                <label class="form-label" for="confirmPassword">Xác nhận mật khẩu</label>
                <input type="password" id="confirmPassword" name="confirmPassword" class="form-input"
                       placeholder="Nhập lại mật khẩu" required autocomplete="new-password">
            </div>

            <button type="submit" class="btn btn-primary">Đặt lại mật khẩu</button>
        </form>
        </c:if>

        <div class="auth-links">
            <a href="<c:url value='/login'/>">Quay lại đăng nhập</a>
            <span class="auth-links__separator">•</span>
            <a href="<c:url value='/forgot-password'/>">Gửi lại link</a>
        </div>
    </div>
    <script src="js/message-auto-hide.js"></script>
</body>
</html>
