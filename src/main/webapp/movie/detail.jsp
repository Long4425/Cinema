<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <title>${movie.title} - Cinema</title>
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/movies.css">
                <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap"
                    rel="stylesheet">
            </head>

            <body>
                <jsp:include page="/components/header.jsp" />

                <div class="movie-detail-container">
                    <div class="detail-poster">
                        <c:choose>
                            <c:when test="${not empty movie.posterUrl}">
                                <img src="${pageContext.request.contextPath}/images/${movie.posterUrl}"
                                    alt="${movie.title}" style="width: 100%; border-radius: 16px;">
                            </c:when>
                            <c:otherwise>
                                <img src="https://via.placeholder.com/300x450?text=No+Poster" alt="${movie.title}"
                                    style="width: 100%; border-radius: 16px;">
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <div class="detail-content">
                        <h1 class="detail-title">${movie.title}</h1>
                        <h3 style="color: var(--text-gray); font-weight: 500; font-size: 1.25rem; margin-bottom: 24px;">
                            ${movie.titleEN}</h3>

                        <div class="detail-meta-list">
                            <span>⏱️ ${movie.durationMins} phút</span>
                            <span>🎭 ${movie.genre}</span>
                            <span style="color: #ef4444; font-weight: 700;">🔞 ${movie.ageRating}</span>
                            <span>🗣️ ${movie.language}</span>
                        </div>

                        <p class="detail-desc">${movie.description}</p>

                        <c:if test="${not empty movie.trailerUrl}">
                            <div class="trailer-section">
                                <a href="${movie.trailerUrl}" target="_blank" class="trailer-btn">
                                    <svg viewBox="0 0 24 24" fill="currentColor" width="24" height="24">
                                        <path d="M8 5v14l11-7z" />
                                    </svg>
                                    Xem Trailer
                                </a>
                            </div>
                        </c:if>

                        <div class="showtime-section">
                            <h2 style="font-size: 1.5rem; font-weight: 700; margin-bottom: 20px;">🎬 Lịch Chiếu</h2>
                            <c:choose>
                                <c:when test="${not empty showtimes}">
                                    <div class="showtime-grid">
                                        <c:forEach var="s" items="${showtimes}">
                                            <a href="${pageContext.request.contextPath}/booking/seat-selection?id=${s.showtimeId}"
                                                class="showtime-item">
                                                <fmt:parseDate value="${s.startTime}" pattern="yyyy-MM-dd'T'HH:mm"
                                                    var="parsedDate" type="both" />
                                                <fmt:formatDate value="${parsedDate}" pattern="HH:mm" />
                                                <div style="font-size: 0.7rem; color: #94a3b8; font-weight: 400;">
                                                    ${s.room.roomName} (${s.room.roomType})</div>
                                            </a>
                                        </c:forEach>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <p style="color: var(--text-gray);">Hiện chưa có lịch chiếu cho phim này.</p>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>

                <jsp:include page="/components/footer.jsp" />
            </body>

            </html>