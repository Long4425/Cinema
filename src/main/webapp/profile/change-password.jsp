<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đổi mật khẩu | Cinema</title>
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
            <h1 class="auth-card__title">Đổi mật khẩu</h1>
            <p class="auth-card__subtitle">Cập nhật mật khẩu đăng nhập của bạn</p>
        </header>

        <c:if test="${not empty error}">
            <div class="auth-msg auth-msg--error cinema-msg" role="alert">${error}</div>
        </c:if>
        <c:if test="${not empty success}">
            <div class="auth-msg auth-msg--success cinema-msg" role="status">${success}</div>
        </c:if>

        <form class="auth-form" action="<c:url value='/profile/change-password'/>" method="post">
            <div class="form-group">
                <label class="form-label" for="currentPassword">Mật khẩu hiện tại</label>
                <input type="password" id="currentPassword" name="currentPassword" class="form-input"
                       placeholder="Nhập mật khẩu hiện tại" required autocomplete="current-password">
            </div>
            <div class="form-group">
                <label class="form-label" for="newPassword">Mật khẩu mới</label>
                <input type="password" id="newPassword" name="newPassword" class="form-input"
                       placeholder="Ít nhất 6 ký tự" required minlength="6" autocomplete="new-password">
            </div>
            <div class="form-group">
                <label class="form-label" for="confirmPassword">Xác nhận mật khẩu mới</label>
                <input type="password" id="confirmPassword" name="confirmPassword" class="form-input"
                       placeholder="Nhập lại mật khẩu mới" required minlength="6" autocomplete="new-password">
            </div>

            <button type="submit" class="btn btn-primary">Đổi mật khẩu</button>
        </form>

        <div class="auth-links">
            <a href="<c:url value='/profile'/>">Quay lại hồ sơ</a>
        </div>
    </div>
    <script src="js/message-auto-hide.js"></script>
</body>
</html>

