<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8">
            <title>Danh sách phim - Cinema</title>
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/movies.css">
            <link rel="preconnect" href="https://fonts.googleapis.com">
            <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
            <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap"
                rel="stylesheet">
        </head>

        <body>
            <jsp:include page="/components/header.jsp" />

            <div class="movies-container">
                <h1 style="font-size: 2.5rem; font-weight: 800; margin-bottom: 40px; text-align: center;">🎬 Khám Phá
                    Phim</h1>

                <form action="${pageContext.request.contextPath}/movies" method="get" class="search-filter-section">
                    <div class="filter-group">
                        <label for="query">Tìm phim</label>
                        <input type="text" name="query" id="query" value="${query}" class="filter-input"
                            placeholder="Tên phim...">
                    </div>
                    <div class="filter-group">
                        <label for="genre">Thể loại</label>
                        <select name="genre" id="genre" class="filter-input">
                            <option value="">Tất cả thể loại</option>
                            <option value="Hành động" ${genre=='Hành động' ? 'selected' : '' }>Hành động</option>
                            <option value="Kinh dị" ${genre=='Kinh dị' ? 'selected' : '' }>Kinh dị</option>
                            <option value="Hài" ${genre=='Hài' ? 'selected' : '' }>Hài</option>
                            <option value="Khoa học viễn tưởng" ${genre=='Khoa học viễn tưởng' ? 'selected' : '' }>Khoa
                                học viễn tưởng</option>
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
                    <button type="submit" class="search-btn">Tìm kiếm</button>
                </form>

                <div class="movie-grid">
                    <c:forEach var="movie" items="${movies}">
                        <div class="movie-card"
                            onclick="location.href='${pageContext.request.contextPath}/movie-detail?id=${movie.movieId}'">
                            <div class="poster-container">
                                <c:choose>
                                    <c:when test="${not empty movie.posterUrl}">
                                        <img src="${pageContext.request.contextPath}/images/${movie.posterUrl}"
                                            alt="${movie.title}" class="poster-img">
                                    </c:when>
                                    <c:otherwise>
                                        <img src="https://via.placeholder.com/300x450?text=No+Poster"
                                            alt="${movie.title}" class="poster-img">
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
                    <div style="text-align: center; color: var(--text-gray); font-size: 1.25rem; margin-top: 50px;">
                        <p>Không tìm thấy phim nào phù hợp.</p>
                    </div>
                </c:if>
            </div>

            <jsp:include page="/components/footer.jsp" />
        </body>

        </html>