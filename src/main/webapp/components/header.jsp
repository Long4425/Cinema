<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<header class="header">
    <div class="header__brand">
        <c:set var="roleCode" value="${user.role != null ? user.role.roleCode : ''}"/>
        <c:set var="homeUrl" value="${empty sessionScope.user ? '/home' : (roleCode == 'CUSTOMER' ? '/home' : '/dashboard')}"/>
        <a href="${pageContext.request.contextPath}${homeUrl}" class="header__logo">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="28"
                 height="28">
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
        <ul class="header__nav-list">
            <c:set var="activeTab" value="${requestScope.activeTab}"/>
            <c:set var="ctx" value="${pageContext.request.contextPath}"/>
            <c:if test="${empty sessionScope.user || roleCode == 'CUSTOMER'}">
                <li class="header__nav-item">
                    <a href="${ctx}/home"
                       class="header__nav-link ${activeTab == 'HOME' ? 'header__nav-link--active' : ''}">Trang chủ</a>
                </li>
                <li class="header__nav-item">
                    <a href="${ctx}/movies"
                       class="header__nav-link ${activeTab == 'MOVIES' ? 'header__nav-link--active' : ''}">Phim</a>
                </li>
                <c:if test="${not empty sessionScope.user}">
                    <li class="header__nav-item">
                        <a href="${ctx}/booking"
                           class="header__nav-link ${activeTab == 'BOOKING' ? 'header__nav-link--active' : ''}">Đặt vé</a>
                    </li>
                    <li class="header__nav-item">
                        <a href="${ctx}/bookings/history"
                           class="header__nav-link ${activeTab == 'HISTORY' ? 'header__nav-link--active' : ''}">Lịch sử đặt vé</a>
                    </li>
                    <li class="header__nav-item">
                        <a href="${ctx}/membership"
                           class="header__nav-link ${activeTab == 'MEMBERSHIP' ? 'header__nav-link--active' : ''}">Thành viên</a>
                    </li>
                </c:if>
            </c:if>
        </ul>
    </nav>

    <div class="header__actions">
        <c:choose>
            <c:when test="${not empty sessionScope.user}">
                <span class="header__user"><c:out value="${user.fullName}"/></span>
                <span class="header__role">
                    <c:out value="${user.role != null ? user.role.roleName : ''}"/>
                </span>
                <a href="${pageContext.request.contextPath}/profile" class="header__link">Hồ sơ</a>
                <a href="${pageContext.request.contextPath}/logout" class="header__link header__link--logout">Đăng xuất</a>
            </c:when>
            <c:otherwise>
                <a href="${pageContext.request.contextPath}/login" class="header__link">Đăng nhập</a>
            </c:otherwise>
        </c:choose>
    </div>
</header>