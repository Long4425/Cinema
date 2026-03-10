<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Danh sách phim | Cinema</title>
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
    <div class="movies-container">
        <h1 class="movies-page-title" style="font-size:2.25rem; font-weight:800; margin-bottom:1.5rem; text-align:center; color:var(--text-dark);">
            Danh sách phim
        </h1>

        <form action="movies" method="get" class="search-filter-section">
            <div class="filter-group">
                <label for="query">Tìm phim</label>
                <input type="text" name="query" id="query" value="${query}" class="filter-input" placeholder="Tên phim...">
            </div>
            <div class="filter-group">
                <label for="genre">Thể loại</label>
                <select name="genre" id="genre" class="filter-input">
                    <option value="">Tất cả thể loại</option>
                    <option value="Hành động" ${genre=='Hành động' ? 'selected' : '' }>Hành động</option>
                    <option value="Kinh dị" ${genre=='Kinh dị' ? 'selected' : '' }>Kinh dị</option>
                    <option value="Hài" ${genre=='Hài' ? 'selected' : '' }>Hài</option>
                    <option value="Khoa học viễn tưởng" ${genre=='Khoa học viễn tưởng' ? 'selected' : '' }>Khoa học viễn tưởng</option>
                    <option value="Hoạt hình" ${genre=='Hoạt hình' ? 'selected' : '' }>Hoạt hình</option>
                </select>
            </div>
            <div class="filter-group">
                <label for="ageRating">Độ tuổi</label>
                <select name="ageRating" id="ageRating" class="filter-input">
                    <option value="">Tất cả</option>
                    <option value="P" ${ageRating=='P' ? 'selected' : '' }>P (Mọi lứa tuổi)</option>
                    <option value="C13" ${ageRating=='C13' ? 'selected' : '' }>C13 (Trên 13 tuổi)</option>
                    <option value="C16" ${ageRating=='C16' ? 'selected' : '' }>C16 (Trên 16 tuổi)</option>
                    <option value="C18" ${ageRating=='C18' ? 'selected' : '' }>C18 (Trên 18 tuổi)</option>
                </select>
            </div>
            <div class="filter-actions">
                <button type="submit" class="search-btn">Tìm kiếm</button>
                <button type="button" class="search-btn" onclick="location.href='movies'">Reset</button>
            </div>
        </form>

        <div class="movie-grid">
            <c:forEach var="movie" items="${movies}">
                <div class="movie-card" onclick="location.href='movie-detail?id=${movie.movieId}'">
                    <div class="poster-container">
                        <c:choose>
                            <c:when test="${not empty movie.posterUrl}">
                                <img src="images/${movie.posterUrl}" alt="${movie.title}" class="poster-img">
                            </c:when>
                            <c:otherwise>
                                <img src="images/default.jpg" alt="${movie.title}" class="poster-img">
                            </c:otherwise>
                        </c:choose>
                        <div class="age-rating-badge">${movie.ageRating}</div>
                    </div>
                    <div class="movie-info">
                        <h3 class="movie-title">${movie.title}</h3>
                        <div class="movie-title-en">${movie.titleEN}</div>
                        <div class="movie-meta">
                            <span class="movie-genre">${movie.genre}</span>
                            <span>${movie.durationMins} phút</span>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>

        <c:if test="${empty movies}">
            <div class="cinema-msg cinema-msg--info" style="max-width:640px; margin:1.25rem auto 0; text-align:center;">
                Không tìm thấy phim nào phù hợp.
            </div>
        </c:if>
    </div>
</main>

<jsp:include page="/components/footer.jsp"/>
</body>
</html>