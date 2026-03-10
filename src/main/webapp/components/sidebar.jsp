<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <c:set var="uri"
            value="${requestScope['jakarta.servlet.forward.request_uri'] != null ? requestScope['jakarta.servlet.forward.request_uri'] : pageContext.request.requestURI}" />
        <c:set var="ctx" value="${pageContext.request.contextPath}" />

        <aside class="sidebar">
            <nav class="sidebar__nav">
                <c:set var="roleCode" value="${user.role != null ? user.role.roleCode : ''}" />

                <%-- Tổng quan: Cho tất cả nhân viên --%>
                    <c:if test="${roleCode != 'CUSTOMER'}">
                        <div class="sidebar__group">
                            <ul class="sidebar__menu">
                                <li>
                                    <a href="${ctx}/dashboard"
                                        class="sidebar__link ${uri.endsWith('/dashboard') ? 'sidebar__link--active' : ''}">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                                            class="sidebar__icon">
                                            <rect x="3" y="3" width="7" height="7" rx="1" />
                                            <rect x="14" y="3" width="7" height="7" rx="1" />
                                            <rect x="14" y="14" width="7" height="7" rx="1" />
                                            <rect x="3" y="14" width="7" height="7" rx="1" />
                                        </svg>
                                        Tổng quan
                                    </a>
                                </li>
                            </ul>
                        </div>
                    </c:if>

                    <%-- CASHIER: Đặt vé, Thanh toán, Xuất vé, Quản lý đặt chỗ --%>
                        <c:if test="${roleCode == 'CASHIER'}">
                            <div class="sidebar__group">
                                <span class="sidebar__group-title">Quầy bán vé</span>
                                <ul class="sidebar__menu">
                                    <li>
                                        <a href="${ctx}/counter/booking"
                                            class="sidebar__link ${uri.contains('/counter/booking') ? 'sidebar__link--active' : ''}">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                                                class="sidebar__icon">
                                                <path d="M15 5l-10 10l-2 2l2 2l2 -2l10 -10l-2 -2z" />
                                                <path d="M19 7l2 2l-2 2l-2 -2z" />
                                                <path d="M9 11l-4 4" />
                                            </svg>
                                            Đặt vé
                                        </a>
                                    </li>
                                    <li>
                                        <a href="${ctx}/counter/payment"
                                            class="sidebar__link ${uri.contains('/counter/payment') ? 'sidebar__link--active' : ''}">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                                                class="sidebar__icon">
                                                <rect x="3" y="5" width="18" height="14" rx="3" />
                                                <line x1="3" y1="10" x2="21" y2="10" />
                                                <line x1="7" y1="15" x2="7.01" y2="15" />
                                                <line x1="11" y1="15" x2="13" y2="15" />
                                            </svg>
                                            Thanh toán tiền mặt
                                        </a>
                                    </li>
                                    <li>
                                        <a href="${ctx}/counter/checkin"
                                            class="sidebar__link ${uri.contains('/counter/checkin') ? 'sidebar__link--active' : ''}">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                                                class="sidebar__icon">
                                                <path d="M5 12l5 5l10 -10" />
                                            </svg>
                                            Xuất vé / Soát vé
                                        </a>
                                    </li>
                                    <li>
                                        <a href="${ctx}/counter/bookings"
                                            class="sidebar__link ${uri.contains('/counter/bookings') ? 'sidebar__link--active' : ''}">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                                                class="sidebar__icon">
                                                <rect x="4" y="4" width="16" height="16" rx="2" />
                                                <line x1="9" y1="12" x2="15" y2="12" />
                                                <line x1="9" y1="16" x2="15" y2="16" />
                                                <line x1="9" y1="8" x2="15" y2="8" />
                                            </svg>
                                            Quản lý đặt chỗ
                                        </a>
                                    </li>
                                </ul>
                            </div>
                        </c:if>

                        <%-- MANAGER: Phim, Lịch chiếu, Phòng, Ghế, Giá vé, Khuyến mãi, Báo cáo --%>
                            <c:if test="${roleCode == 'MANAGER' || roleCode == 'ADMIN'}">
                                <div class="sidebar__group">
                                    <span class="sidebar__group-title">Phim & Lịch chiếu</span>
                                    <ul class="sidebar__menu">
                                        <li>
                                            <a href="${ctx}/movies"
                                                class="sidebar__link ${uri.endsWith('/movies') ? 'sidebar__link--active' : ''}">
                                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                                    stroke-width="2" class="sidebar__icon">
                                                    <rect x="4" y="4" width="16" height="16" rx="2" />
                                                    <line x1="8" y1="4" x2="8" y2="20" />
                                                    <line x1="16" y1="4" x2="16" y2="20" />
                                                    <line x1="4" y1="8" x2="8" y2="8" />
                                                    <line x1="4" y1="16" x2="8" y2="16" />
                                                    <line x1="16" y1="8" x2="20" y2="8" />
                                                    <line x1="16" y1="16" x2="20" y2="16" />
                                                </svg>
                                                Danh sách phim
                                            </a>
                                        </li>
                                        <li>
                                            <a href="${ctx}/showtimes"
                                                class="sidebar__link ${uri.endsWith('/showtimes') ? 'sidebar__link--active' : ''}">
                                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                                    stroke-width="2" class="sidebar__icon">
                                                    <rect x="4" y="5" width="16" height="16" rx="2" />
                                                    <line x1="16" y1="3" x2="16" y2="7" />
                                                    <line x1="8" y1="3" x2="8" y2="7" />
                                                    <line x1="4" y1="11" x2="20" y2="11" />
                                                </svg>
                                                Lịch chiếu (Khách)
                                            </a>
                                        </li>
                                        <li>
                                            <a href="${ctx}/manager/movies"
                                                class="sidebar__link ${uri.contains('/manager/movies') ? 'sidebar__link--active' : ''}">
                                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                                    stroke-width="2" class="sidebar__icon">
                                                    <path
                                                        d="M12 15l8.385 -8.415a4.408 4.408 0 1 0 -6.235 -6.235l-8.415 8.385a4.408 4.408 0 1 0 6.235 6.235z" />
                                                    <path d="M16 5l3 3" />
                                                    <path d="M9 12l3 3" />
                                                    <path d="M8 10l-1 .5" />
                                                </svg>
                                                Quản lý phim
                                            </a>
                                        </li>
                                        <li>
                                            <a href="${ctx}/manager/showtimes"
                                                class="sidebar__link ${uri.contains('/manager/showtimes') ? 'sidebar__link--active' : ''}">
                                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                                    stroke-width="2" class="sidebar__icon">
                                                    <rect x="4" y="5" width="16" height="16" rx="2" />
                                                    <line x1="16" y1="3" x2="16" y2="7" />
                                                    <line x1="8" y1="3" x2="8" y2="7" />
                                                    <line x1="4" y1="11" x2="20" y2="11" />
                                                    <rect x="8" y="15" width="2" height="2" />
                                                </svg>
                                                Quản lý lịch chiếu
                                            </a>
                                        </li>
                                    </ul>
                                </div>
                                <div class="sidebar__group">
                                    <span class="sidebar__group-title">Phòng & Ghế</span>
                                    <ul class="sidebar__menu">
                                        <li>
                                            <a href="${ctx}/manager/rooms"
                                                class="sidebar__link ${uri.contains('/manager/rooms') ? 'sidebar__link--active' : ''}">
                                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                                    stroke-width="2" class="sidebar__icon">
                                                    <path d="M3 21v-13l9 -4l9 4v13" />
                                                    <path d="M13 21v-4a1 1 0 0 0 -1 -1h-2a1 1 0 0 0 -1 1v4" />
                                                </svg>
                                                Quản lý phòng chiếu
                                            </a>
                                        </li>
                                        <li>
                                            <a href="${ctx}/manager/seats"
                                                class="sidebar__link ${uri.contains('/manager/seats') ? 'sidebar__link--active' : ''}">
                                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                                    stroke-width="2" class="sidebar__icon">
                                                    <rect x="4" y="4" width="16" height="16" rx="2" />
                                                    <path d="M4 12h16" />
                                                    <path d="M12 4v16" />
                                                </svg>
                                                Cấu hình sơ đồ ghế
                                            </a>
                                        </li>
                                    </ul>
                                </div>
                                <div class="sidebar__group">
                                    <span class="sidebar__group-title">Giá & Khuyến mãi</span>
                                    <ul class="sidebar__menu">
                                        <li>
                                            <a href="${ctx}/manager/pricing"
                                                class="sidebar__link ${uri.contains('/manager/pricing') ? 'sidebar__link--active' : ''}">
                                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                                    stroke-width="2" class="sidebar__icon">
                                                    <path
                                                        d="M16.7 8a3 3 0 0 0 -2.7 -2h-4a3 3 0 0 0 0 6h4a3 3 0 0 1 0 6h-4a3 3 0 0 1 -2.7 -2" />
                                                    <path d="M12 3v3m0 12v3" />
                                                </svg>
                                                Cấu hình giá vé
                                            </a>
                                        </li>
                                        <li>
                                            <a href="${ctx}/manager/promotions"
                                                class="sidebar__link ${uri.contains('/manager/promotions') ? 'sidebar__link--active' : ''}">
                                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                                    stroke-width="2" class="sidebar__icon">
                                                    <path
                                                        d="M4 9a2 2 0 0 1 2 -2h11l3 3v7a2 2 0 0 1 -2 2h-12a2 2 0 0 1 -2 -2z" />
                                                    <path d="M9 15l6 -6" />
                                                    <circle cx="9.5" cy="9.5" r=".5" fill="currentColor" />
                                                    <circle cx="14.5" cy="14.5" r=".5" fill="currentColor" />
                                                </svg>
                                                Khuyến mãi
                                            </a>
                                        </li>
                                    </ul>
                                </div>
                                <div class="sidebar__group">
                                    <span class="sidebar__group-title">Báo cáo</span>
                                    <ul class="sidebar__menu">
                                        <li>
                                            <a href="${ctx}/manager/reports"
                                                class="sidebar__link ${uri.contains('/manager/reports') ? 'sidebar__link--active' : ''}">
                                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                                    stroke-width="2" class="sidebar__icon">
                                                    <path d="M3 3v18h18" />
                                                    <path d="M20 18l-4 -4l-3 3l-4 -4" />
                                                </svg>
                                                Báo cáo doanh thu
                                            </a>
                                        </li>
                                        <li>
                                            <a href="${ctx}/manager/export"
                                                class="sidebar__link ${uri.contains('/manager/export') ? 'sidebar__link--active' : ''}">
                                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                                    stroke-width="2" class="sidebar__icon">
                                                    <path d="M4 17v2a2 2 0 0 0 2 2h12a2 2 0 0 0 2 -2v-2" />
                                                    <polyline points="7 11 12 16 17 11" />
                                                    <line x1="12" y1="4" x2="12" y2="16" />
                                                </svg>
                                                Xuất báo cáo
                                            </a>
                                        </li>
                                    </ul>
                                </div>
                                <div class="sidebar__group">
                                    <span class="sidebar__group-title">Đặt chỗ</span>
                                    <ul class="sidebar__menu">
                                        <li>
                                            <a href="${ctx}/manager/bookings"
                                                class="sidebar__link ${uri.contains('/manager/bookings') ? 'sidebar__link--active' : ''}">
                                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                                    stroke-width="2" class="sidebar__icon">
                                                    <path d="M9 5h10l2 2l-2 2h-10a2 2 0 0 1 -2 -2v-0a2 2 0 0 1 2 -2z" />
                                                    <path d="M13 13h7l2 2l-2 2h-7a2 2 0 0 1 -2 -2v-0a2 2 0 0 1 2 -2z" />
                                                    <path d="M7 5v14" />
                                                </svg>
                                                Quản lý đặt chỗ / Hoàn vé
                                            </a>
                                        </li>
                                    </ul>
                                </div>
                            </c:if>

                            <%-- ADMIN: Quản lý nhân viên, Phân quyền --%>
                                <c:if test="${roleCode == 'ADMIN'}">
                                    <div class="sidebar__group">
                                        <span class="sidebar__group-title">Hệ thống</span>
                                        <ul class="sidebar__menu">
                                            <li>
                                                <a href="${ctx}/admin/staff"
                                                    class="sidebar__link ${uri.contains('/admin/staff') ? 'sidebar__link--active' : ''}">
                                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                                        stroke-width="2" class="sidebar__icon">
                                                        <path d="M9 7m-4 0a4 4 0 1 0 8 0a4 4 0 1 0 -8 0" />
                                                        <path d="M3 21v-2a4 4 0 0 1 4 -4h4a4 4 0 0 1 4 4v2" />
                                                        <path d="M16 3.13a4 4 0 0 1 0 7.75" />
                                                        <path d="M21 21v-2a4 4 0 0 0 -3 -3.85" />
                                                    </svg>
                                                    Quản lý nhân viên
                                                </a>
                                            </li>
                                            <li>
                                                <a href="${ctx}/admin/roles"
                                                    class="sidebar__link ${uri.contains('/admin/roles') ? 'sidebar__link--active' : ''}">
                                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                                        stroke-width="2" class="sidebar__icon">
                                                        <path
                                                            d="M12 3a12 12 0 0 0 8.5 3a12 12 0 0 1 -8.5 15a12 12 0 0 1 -8.5 -15a12 12 0 0 0 8.5 -3" />
                                                        <circle cx="12" cy="11" r="2" />
                                                        <path d="M12 13v4" />
                                                    </svg>
                                                    Phân quyền
                                                </a>
                                            </li>
                                            <li>
                                                <a href="${ctx}/admin/audit"
                                                    class="sidebar__link ${uri.contains('/admin/audit') ? 'sidebar__link--active' : ''}">
                                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                                        stroke-width="2" class="sidebar__icon">
                                                        <path d="M3 12h4l3 8l4 -16l3 8h4" />
                                                    </svg>
                                                    Nhật ký hoạt động
                                                </a>
                                            </li>
                                        </ul>
                                    </div>
                                </c:if>

                                <%-- Chung: Hồ sơ --%>
                                    <div class="sidebar__group sidebar__group--bottom">
                                        <ul class="sidebar__menu">
                                            <li>
                                                <a href="${ctx}/profile"
                                                    class="sidebar__link ${uri.contains('/profile') ? 'sidebar__link--active' : ''}">
                                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                                        stroke-width="2" class="sidebar__icon">
                                                        <circle cx="12" cy="7" r="4" />
                                                        <path d="M6 21v-2a4 4 0 0 1 4 -4h4a4 4 0 0 1 4 4v2" />
                                                    </svg>
                                                    Hồ sơ cá nhân
                                                </a>
                                            </li>
                                        </ul>
                                    </div>

            </nav>
        </aside>