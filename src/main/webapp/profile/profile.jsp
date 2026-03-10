<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hồ sơ cá nhân | Cinema</title>
    <base href="${pageContext.request.scheme}://${pageContext.request.serverName}:${pageContext.request.serverPort}${pageContext.request.contextPath}/">
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/form.css">
    <link rel="stylesheet" href="css/auth.css">
    <link rel="stylesheet" href="css/profile.css">
</head>
<body class="profile-page">
    <div class="profile-container">
        <div class="profile-header">
            <a href="<c:url value='/'/>" class="profile-back">
                <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M19 12H5M12 19l-7-7 7-7"/>
                </svg>
                Quay lại
            </a>
            <div class="profile-brand">
                <div class="profile-brand__logo">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <rect x="2" y="2" width="20" height="20" rx="2"/>
                        <rect x="7" y="2" width="3" height="4"/>
                        <rect x="14" y="2" width="3" height="4"/>
                        <rect x="7" y="18" width="3" height="4"/>
                        <rect x="14" y="18" width="3" height="4"/>
                    </svg>
                </div>
                <span class="profile-brand__name">Hồ sơ cá nhân</span>
            </div>
        </div>

        <c:if test="${not empty error}">
            <div class="auth-msg auth-msg--error cinema-msg" role="alert">${error}</div>
        </c:if>
        <c:if test="${not empty success}">
            <div class="auth-msg auth-msg--success cinema-msg" role="status">${success}</div>
        </c:if>

        <div class="profile-card">
            <div class="profile-grid">
                <aside class="profile-sidebar">
                    <div class="profile-info">
                        <div class="profile-avatar">
                            <span class="profile-avatar__initials">${user.fullName != null && !user.fullName.isEmpty() ? user.fullName.substring(0, 1).toUpperCase() : '?'}</span>
                        </div>
                        <div class="profile-meta">
                            <h2 class="profile-name">${user.fullName}</h2>
                            <p class="profile-email">${user.email}</p>
                            <c:if test="${user.role != null}">
                                <span class="profile-badge profile-badge--${user.role.roleCode}">${user.role.roleName}</span>
                            </c:if>
                            <c:if test="${user.memberTier != null && !user.memberTier.isEmpty()}">
                                <span class="profile-tier">Hạng: ${user.memberTier}</span>
                            </c:if>
                            <c:if test="${user.loyaltyPoint > 0}">
                                <span class="profile-points">${user.loyaltyPoint} điểm tích lũy</span>
                            </c:if>
                        </div>
                    </div>

                    <div class="profile-footer">
                        <a href="<c:url value='/logout'/>" class="profile-logout">Đăng xuất</a>
                    </div>
                </aside>

                <section class="profile-content">
                    <form class="profile-form" action="<c:url value='/profile'/>" method="post">
                        <div class="profile-section-header">
                            <h3 class="profile-form__title">Thông tin cá nhân</h3>
                            <c:if test="${user.hasPassword}">
                                <a class="btn btn-secondary profile-change-password" href="<c:url value='/profile/change-password'/>">Đổi mật khẩu</a>
                            </c:if>
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="fullName">Họ và tên</label>
                            <input type="text" id="fullName" name="fullName" class="form-input" value="${user.fullName}"
                                   placeholder="Nguyễn Văn A" required autocomplete="name">
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="email">Email</label>
                            <input type="email" id="email" class="form-input" value="${user.email}"
                                   disabled readonly title="Email không thể thay đổi">
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="phone">Số điện thoại</label>
                            <input type="tel" id="phone" name="phone" class="form-input" value="${user.phone}"
                                   placeholder="0912345678" autocomplete="tel">
                        </div>
                        <button type="submit" class="btn btn-primary">Cập nhật thông tin</button>
                    </form>

                    <c:if test="${user.googleUser}">
                    <div class="profile-google-notice">
                        <p>Tài khoản đăng nhập bằng Google. Để thay đổi mật khẩu, vui lòng cập nhật trong tài khoản Google của bạn.</p>
                    </div>
                    </c:if>
                </section>
            </div>
        </div>
    </div>
    <script src="js/message-auto-hide.js"></script>
</body>
</html>
