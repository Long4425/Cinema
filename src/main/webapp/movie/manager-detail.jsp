<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết phim (Manager) | Cinema</title>
    <base href="${pageContext.request.scheme}://${pageContext.request.serverName}:${pageContext.request.serverPort}${pageContext.request.contextPath}/">
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/header.css">
    <link rel="stylesheet" href="css/sidebar.css">
    <link rel="stylesheet" href="css/footer.css">
    <link rel="stylesheet" href="css/dashboard.css">
    <link rel="stylesheet" href="css/movies.css">
    <link rel="stylesheet" href="css/message.css">
    <link rel="stylesheet" href="css/button.css">
</head>

<body class="dashboard-layout">
<jsp:include page="/components/header.jsp"/>
<jsp:include page="/components/sidebar.jsp"/>

<main class="dashboard-main">
    <div style="display:flex; align-items:center; justify-content:space-between; gap:1rem; margin-bottom:1.5rem;">
        <div>
            <h1 style="font-size:1.5rem; font-weight:800; color:var(--text-dark); margin:0 0 4px 0;">
                Chi tiết phim (Quản lý)
            </h1>
            <p style="margin:0; font-size:0.9rem; color:var(--text-muted);">
                Xem thông tin phim và các suất chiếu hiện có.
            </p>
        </div>
        <div class="btn-row">
            <a href="manager/movies?action=edit&id=${movie.movieId}" class="btn btn-secondary btn-sm">Sửa phim</a>
            <a href="manager/movies" class="btn btn-ghost btn-sm">Quay lại danh sách</a>
        </div>
    </div>

    <div class="movie-detail-container">
        <div class="detail-poster">
            <c:choose>
                <c:when test="${not empty movie.posterUrl}">
                    <img src="images/${movie.posterUrl}" alt="${movie.title}" style="width: 100%; border-radius: 16px;">
                </c:when>
                <c:otherwise>
                    <img src="images/default.jpg" alt="${movie.title}" style="width: 100%; border-radius: 16px;">
                </c:otherwise>
            </c:choose>
        </div>

        <div class="detail-content">
            <h2 class="detail-title" style="color:var(--text-dark); font-size:2rem; margin-bottom:0.25rem;">
                ${movie.title}
            </h2>
            <p style="color: var(--movies-muted); font-weight: 500; font-size: 0.95rem; margin-bottom: 0.75rem;">
                ${movie.titleEN}
            </p>

            <div class="detail-meta-list" style="flex-wrap:wrap;">
                <span>⏱️ ${movie.durationMins} phút</span>
                <span>🎭 ${movie.genre}</span>
                <span>🗣️ ${movie.language}</span>
                <span style="color:#dc2626; font-weight:800;">🔞 ${movie.ageRating}</span>
                <span>
                    Trạng thái:
                    <strong>${movie.status}</strong>
                </span>
            </div>

            <p class="detail-desc" style="max-width: 640px;">${movie.description}</p>

            <c:if test="${not empty movie.trailerUrl}">
                <div class="trailer-section">
                    <a href="${movie.trailerUrl}" target="_blank" class="trailer-btn" rel="noopener noreferrer">
                        <svg viewBox="0 0 24 24" fill="currentColor" width="22" height="22">
                            <path d="M8 5v14l11-7z"/>
                        </svg>
                        Xem Trailer
                    </a>
                </div>
            </c:if>

            <div class="showtime-section" style="margin-top:32px;">
                <h3 style="font-size: 1.1rem; font-weight: 800; margin-bottom: 0.75rem; color:var(--text-dark);">
                    Lịch chiếu hiện tại
                </h3>
                <c:choose>
                    <c:when test="${not empty showtimes}">
                        <div class="showtime-grid">
                            <c:forEach var="s" items="${showtimes}">
                                <div class="showtime-item" style="text-align:left;">
                                    <fmt:parseDate value="${s.startTime}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedDate" type="both"/>
                                    <strong><fmt:formatDate value="${parsedDate}" pattern="dd/MM HH:mm"/></strong>
                                    <div style="font-size: 0.8rem; color: var(--text-muted); margin-top:4px;">
                                        Phòng: ${s.room.roomName} (${s.room.roomType})
                                    </div>
                                    <div style="font-size: 0.8rem; color: #047857; margin-top:4px;">
                                        Giá cơ bản:
                                        <fmt:formatNumber value="${s.basePrice}" type="currency" currencySymbol="₫"/>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="cinema-msg cinema-msg--info" style="margin-top:0.5rem;">
                            Hiện chưa có lịch chiếu nào được cấu hình cho phim này.
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/components/footer.jsp"/>
</body>
</html>

