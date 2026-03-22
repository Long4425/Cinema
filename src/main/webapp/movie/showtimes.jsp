<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lịch chiếu | Cinema</title>
    <base href="${pageContext.request.scheme}://${pageContext.request.serverName}:${pageContext.request.serverPort}${pageContext.request.contextPath}/">
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/header.css">
    <link rel="stylesheet" href="css/footer.css">
    <link rel="stylesheet" href="css/movies.css">
    <link rel="stylesheet" href="css/message.css">
</head>

<body class="home-layout">
<jsp:include page="/components/header.jsp"/>

<main class="home-main">
    <div class="container container--xl">
        <h1 class="movies-page-title">
            Lịch chiếu
        </h1>

        <form class="search-filter-section" action="showtimes" method="get" style="justify-content: center; margin-bottom: 2rem;">
            <div class="filter-group" style="max-width: 320px;">
                <label for="date-filter">Chọn ngày</label>
                <input type="date" id="date-filter" name="date" value="${date}" class="filter-input">
            </div>
            <div class="filter-group" style="max-width: 380px;">
                <label for="movie-filter">Chọn phim</label>
                <select id="movie-filter" name="movieId" class="filter-input">
                    <option value="">Tất cả phim</option>
                    <c:forEach var="m" items="${movies}">
                        <option value="${m.movieId}" ${movieId != null && movieId == m.movieId ? 'selected' : '' }>${m.title}</option>
                    </c:forEach>
                </select>
            </div>
            <div class="filter-actions">
                <button type="submit" class="search-btn">Lọc</button>
                <button type="button" class="search-btn" onclick="location.href='showtimes'">Reset</button>
            </div>
        </form>

        <c:choose>
            <c:when test="${not empty showtimes}">
                <div class="movie-grid">
                    <c:forEach var="s" items="${showtimes}">
                        <div class="movie-card" onclick="location.href='booking/seat-selection?id=${s.showtimeId}'">
                            <div class="poster-container" style="height: 250px;">
                                <c:choose>
                                    <c:when test="${not empty s.movie.posterUrl}">
                                        <img src="images/${s.movie.posterUrl}" alt="${s.movie.title}" class="poster-img">
                                    </c:when>
                                    <c:otherwise>
                                        <img src="images/default.jpg" alt="${s.movie.title}" class="poster-img">
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <div class="movie-info">
                                <h3 class="movie-title">${s.movie.title}</h3>
                                <div class="movie-title-en">${s.movie.titleEN}</div>
                                <div class="movie-meta" style="flex-direction: column; gap: 8px; align-items:flex-start;">
                                    <span style="font-weight: 800; color: var(--text-dark); font-size: 1.1rem;">
                                        ⌚ ${s.startTime.toString().substring(11, 16)}
                                    </span>
                                    <span>🏛️ ${s.room.roomName} (${s.room.roomType})</span>
                                    <span style="color: #047857; font-weight: 800;">
                                        💰 <fmt:formatNumber value="${s.basePrice}" type="currency" currencySymbol="₫"/>
                                    </span>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <div class="cinema-msg cinema-msg--info" style="max-width:640px; margin:1.25rem auto 0; text-align:center;">
                    Không có lịch chiếu nào cho ngày được chọn.
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</main>

<jsp:include page="/components/footer.jsp"/>
</body>
</html>