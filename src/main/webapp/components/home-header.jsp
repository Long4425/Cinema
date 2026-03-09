<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<header class="header header--home">
    <div class="header__brand">
        <a href="${pageContext.request.contextPath}/home" class="header__logo">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="28" height="28">
                <rect x="2" y="2" width="20" height="20" rx="2"/>
                <rect x="7" y="2" width="3" height="4"/>
                <rect x="14" y="2" width="3" height="4"/>
                <rect x="7" y="18" width="3" height="4"/>
                <rect x="14" y="18" width="3" height="4"/>
            </svg>
            <span class="header__name">Cinema</span>
        </a>
    </div>
    <nav class="header__nav">
        <a href="${pageContext.request.contextPath}/movies" class="header__nav-link">Phim</a>
        <a href="${pageContext.request.contextPath}/showtimes" class="header__nav-link">Lịch chiếu</a>
        <a href="${pageContext.request.contextPath}/booking" class="header__nav-link">Đặt vé</a>
    </nav>
    <div class="header__actions">
        <a href="${pageContext.request.contextPath}/profile" class="header__link">Hồ sơ</a>
        <a href="${pageContext.request.contextPath}/logout" class="header__link header__link--logout">Đăng xuất</a>
    </div>
</header>
