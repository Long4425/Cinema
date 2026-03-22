<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>${movie.title} | Cinema</title>
                <base
                    href="${pageContext.request.scheme}://${pageContext.request.serverName}:${pageContext.request.serverPort}${pageContext.request.contextPath}/">
                <link rel="stylesheet" href="css/style.css">
                <link rel="stylesheet" href="css/header.css">
                <link rel="stylesheet" href="css/footer.css">
                <link rel="stylesheet" href="css/movies.css">
                <link rel="stylesheet" href="css/message.css">
                <link rel="stylesheet" href="css/button.css">
            </head>

            <body class="home-layout">
                <jsp:include page="/components/header.jsp" />

                <main class="home-main">
                    <div class="movie-detail-container">
                        <div style="grid-column:1/-1; margin-bottom:0.5rem;">
                            <a href="${pageContext.request.contextPath}/movies" class="btn btn-secondary" style="display:inline-flex;align-items:center;gap:0.4rem;">
                                &#8592; Quay lại danh sách phim
                            </a>
                        </div>
                        <div class="detail-poster">
                            <c:choose>
                                <c:when test="${not empty movie.posterUrl}">
                                    <img src="images/${movie.posterUrl}" alt="${movie.title}"
                                        style="width: 100%;">
                                </c:when>
                                <c:otherwise>
                                    <img src="images/default.jpg" alt="${movie.title}"
                                        style="width: 100%;">
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <div class="detail-content">
                            <h1 class="detail-title" style="color:var(--text-dark);">${movie.title}</h1>
                            <h3
                                style="color: var(--text-muted); font-weight: 500; font-size: 1.1rem; margin-bottom: 1rem;">
                                ${movie.titleEN}
                            </h3>

                            <div class="detail-meta-list">
                                <span>⏱️ ${movie.durationMins} phút</span>
                                <span>🎭 ${movie.genre}</span>
                                <span style="color:#dc2626; font-weight:800;">🔞 ${movie.ageRating}</span>
                                <span>🗣️ ${movie.language}</span>
                            </div>

                            <p class="detail-desc">${movie.description}</p>

                            <c:if test="${not empty movie.trailerUrl}">
                                <div class="trailer-section">
                                    <a href="${movie.trailerUrl}" target="_blank" class="trailer-btn"
                                        rel="noopener noreferrer">
                                        <svg viewBox="0 0 24 24" fill="currentColor" width="22" height="22">
                                            <path d="M8 5v14l11-7z" />
                                        </svg>
                                        Xem Trailer
                                    </a>
                                </div>
                            </c:if>

                            <div class="showtime-section">
                                <h2
                                    style="font-size: 1.25rem; font-weight: 800; margin-bottom: 0.75rem; color:var(--text-dark);">
                                    Lịch chiếu
                                </h2>
                                <c:choose>
                                    <c:when test="${not empty showtimes}">
                                        <div class="showtime-grid">
                                            <c:forEach var="s" items="${showtimes}">
                                                <button type="button"
                                                    class="showtime-item"
                                                    onclick="location.href='${pageContext.request.contextPath}/booking/seat-selection?id=${s.showtimeId}'">
                                                    <strong><fmt:formatNumber value="${s.startTime.hour}" minIntegerDigits="2"/>:<fmt:formatNumber value="${s.startTime.minute}" minIntegerDigits="2"/></strong>
                                                    <div style="font-size: 0.75rem; color: var(--text-muted); font-weight: 500; margin-top:0.25rem;">
                                                        ${s.room.roomName} (${s.room.roomType})
                                                    </div>
                                                </button>
                                            </c:forEach>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="cinema-msg cinema-msg--info" style="margin-top:0.5rem;">
                                            Hôm nay chưa có lịch chiếu cho phim này.
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                </main>


                <jsp:include page="/components/footer.jsp" />
            </body>

            </html>