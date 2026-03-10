<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <title>Lịch chiếu - Cinema</title>
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/movies.css">
                <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap"
                    rel="stylesheet">
            </head>

            <body>
                <jsp:include page="/components/header.jsp" />

                <div class="movies-container">
                    <h1 style="font-size: 2.5rem; font-weight: 800; margin-bottom: 40px; text-align: center;">📅 Lịch
                        Chiếu</h1>

                    <div class="search-filter-section" style="justify-content: center; margin-bottom: 50px;">
                        <div class="filter-group">
                            <label for="date-filter">Chọn ngày</label>
                            <input type="date" id="date-filter" value="${date}" class="filter-input"
                                onchange="location.href='${pageContext.request.contextPath}/showtimes?date=' + this.value">
                        </div>
                    </div>

                    <c:choose>
                        <c:when test="${not empty showtimes}">
                            <div class="movie-grid">
                                <c:forEach var="s" items="${showtimes}">
                                    <div class="movie-card"
                                        onclick="location.href='${pageContext.request.contextPath}/booking/seat-selection?id=${s.showtimeId}'">
                                        <div class="poster-container" style="height: 250px;">
                                            <c:choose>
                                                <c:when test="${not empty s.movie.posterUrl}">
                                                    <img src="${pageContext.request.contextPath}/images/${s.movie.posterUrl}"
                                                        alt="${s.movie.title}" class="poster-img">
                                                </c:when>
                                                <c:otherwise>
                                                    <img src="https://via.placeholder.com/300x450?text=No+Poster"
                                                        alt="${s.movie.title}" class="poster-img">
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                        <div class="movie-info">
                                            <h3 class="movie-title">${s.movie.title}</h3>
                                            <div class="movie-title-en">${s.movie.titleEN}</div>
                                            <div class="movie-meta" style="flex-direction: column; gap: 8px;">
                                                <span style="font-weight: 700; color: #f8fafc; font-size: 1.25rem;">⌚
                                                    ${s.startTime.toString().substring(11, 16)}</span>
                                                <span>🏛️ ${s.room.roomName} (${s.room.roomType})</span>
                                                <span style="color: #10b981;">💰
                                                    <fmt:formatNumber value="${s.basePrice}" type="currency"
                                                        currencySymbol="₫" />
                                                </span>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div
                                style="text-align: center; color: var(--text-gray); font-size: 1.25rem; margin-top: 50px;">
                                <p>Không có lịch chiếu nào cho ngày được chọn.</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <jsp:include page="/components/footer.jsp" />
            </body>

            </html>