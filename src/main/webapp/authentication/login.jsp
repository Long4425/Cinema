<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng nhập | Cinema</title>
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
            <h1 class="auth-card__title">Đăng nhập</h1>
            <p class="auth-card__subtitle">Nhập thông tin để đăng nhập vào tài khoản</p>
        </header>

        <c:if test="${not empty error}">
            <div class="auth-msg auth-msg--error cinema-msg" role="alert">${error}</div>
        </c:if>
        <c:if test="${not empty success}">
            <div class="auth-msg auth-msg--success cinema-msg" role="status">${success}</div>
        </c:if>

        <form class="auth-form" action="<c:url value='/login'/>" method="post">
            <div class="form-group">
                <label class="form-label" for="email">Email</label>
                <input type="email" id="email" name="email" class="form-input" value="${email}"
                       placeholder="email@example.com" required autocomplete="email">
            </div>
            <div class="form-group">
                <label class="form-label" for="password">Mật khẩu</label>
                <input type="password" id="password" name="password" class="form-input"
                       placeholder="Nhập mật khẩu" required autocomplete="current-password">
            </div>

            <button type="submit" class="btn btn-primary">Đăng nhập</button>

            <c:if test="${not empty googleAuthUrl && googleAuthUrl != '#'}">
            <div class="auth-divider"><span>hoặc</span></div>
            <a href="${googleAuthUrl}" class="btn btn-google" role="button">
                <svg viewBox="0 0 24 24" width="18" height="18"><path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/><path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/><path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/><path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/></svg>
                Đăng nhập với Google
            </a>
            </c:if>
        </form>

        <div class="auth-links">
            <a href="<c:url value='/forgot-password'/>">Quên mật khẩu?</a>
            <span class="auth-links__separator">•</span>
            <a href="<c:url value='/register'/>">Đăng ký tài khoản</a>
        </div>
    </div>
    <script src="js/message-auto-hide.js"></script>
</body>
</html>
