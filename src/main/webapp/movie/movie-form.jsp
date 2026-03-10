<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8">
            <title>${movie != null ? 'Sửa phim' : 'Thêm phim'} - Admin Dashboard</title>
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css">
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/dashboard.css">
        </head>

        <body class="dashboard">
            <jsp:include page="/components/header.jsp" />
            <div class="dashboard__container">
                <jsp:include page="/components/sidebar.jsp" />
                <main class="dashboard__content">
                    <h1 class="dashboard__title">${movie != null ? 'Chỉnh sửa phim: ' + movie.title : 'Thêm phim mới'}
                    </h1>

                    <div class="dashboard__card">
                        <form action="${pageContext.request.contextPath}/manager/movies" method="post" class="form">
                            <input type="hidden" name="action" value="${movie != null ? 'update' : 'create'}">
                            <input type="hidden" name="id" value="${movie.movieId}">

                            <div class="form__group">
                                <label for="title" class="form__label">Tiêu đề (Tiếng Việt)</label>
                                <input type="text" name="title" id="title" class="form__input" value="${movie.title}"
                                    required>
                            </div>

                            <div class="form__group">
                                <label for="titleEN" class="form__label">Tiêu đề (Tiếng Anh)</label>
                                <input type="text" name="titleEN" id="titleEN" class="form__input"
                                    value="${movie.titleEN}" required>
                            </div>

                            <div class="form__group">
                                <label for="description" class="form__label">Mô tả</label>
                                <textarea name="description" id="description" class="form__input"
                                    rows="4">${movie.description}</textarea>
                            </div>

                            <div class="form__row" style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                                <div class="form__group">
                                    <label for="genre" class="form__label">Thể loại</label>
                                    <input type="text" name="genre" id="genre" class="form__input"
                                        value="${movie.genre}">
                                </div>
                                <div class="form__group">
                                    <label for="language" class="form__label">Ngôn ngữ</label>
                                    <input type="text" name="language" id="language" class="form__input"
                                        value="${movie.language}">
                                </div>
                            </div>

                            <div class="form__row" style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                                <div class="form__group">
                                    <label for="ageRating" class="form__label">Phân loại lứa tuổi</label>
                                    <select name="ageRating" id="ageRating" class="form__input">
                                        <option value="P" ${movie.ageRating=='P' ? 'selected' : '' }>P</option>
                                        <option value="C13" ${movie.ageRating=='C13' ? 'selected' : '' }>C13</option>
                                        <option value="C16" ${movie.ageRating=='C16' ? 'selected' : '' }>C16</option>
                                        <option value="C18" ${movie.ageRating=='C18' ? 'selected' : '' }>C18</option>
                                    </select>
                                </div>
                                <div class="form__group">
                                    <label for="durationMins" class="form__label">Thời lượng (phút)</label>
                                    <input type="number" name="durationMins" id="durationMins" class="form__input"
                                        value="${movie.durationMins}" required>
                                </div>
                            </div>

                            <div class="form__group">
                                <label for="posterUrl" class="form__label">Poster filename (lưu trong thư mục
                                    images)</label>
                                <input type="text" name="posterUrl" id="posterUrl" class="form__input"
                                    value="${movie.posterUrl}" placeholder="VD: movie1.jpg">
                            </div>

                            <div class="form__group">
                                <label for="trailerUrl" class="form__label">Trailer URL</label>
                                <input type="text" name="trailerUrl" id="trailerUrl" class="form__input"
                                    value="${movie.trailerUrl}">
                            </div>

                            <div class="form__group">
                                <label for="status" class="form__label">Trạng thái</label>
                                <select name="status" id="status" class="form__input">
                                    <option value="NowShowing" ${movie.status=='NowShowing' ? 'selected' : '' }>
                                        NowShowing</option>
                                    <option value="ComingSoon" ${movie.status=='ComingSoon' ? 'selected' : '' }>
                                        ComingSoon</option>
                                    <option value="Ended" ${movie.status=='Ended' ? 'selected' : '' }>Ended</option>
                                </select>
                            </div>

                            <div class="form__actions">
                                <button type="submit" class="btn btn--primary">${movie != null ? 'Cập nhật' : 'Thêm
                                    mới'}</button>
                                <a href="${pageContext.request.contextPath}/manager/movies"
                                    class="btn btn--secondary">Hủy</a>
                            </div>
                        </form>
                    </div>
                </main>
            </div>
        </body>

        </html>