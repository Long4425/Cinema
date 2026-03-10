<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${movie != null ? 'Sửa phim' : 'Thêm phim'} | Cinema</title>
    <base href="${pageContext.request.scheme}://${pageContext.request.serverName}:${pageContext.request.serverPort}${pageContext.request.contextPath}/">
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/header.css">
    <link rel="stylesheet" href="css/sidebar.css">
    <link rel="stylesheet" href="css/footer.css">
    <link rel="stylesheet" href="css/dashboard.css">
    <link rel="stylesheet" href="css/form.css">
    <link rel="stylesheet" href="css/button.css">
    <link rel="stylesheet" href="css/message.css">
</head>

<body class="dashboard-layout">
<jsp:include page="/components/header.jsp"/>
<jsp:include page="/components/sidebar.jsp"/>

<main class="dashboard-main">
    <div style="display:flex; align-items:center; justify-content:space-between; gap:1rem; margin-bottom:1rem;">
        <h1 style="font-size:1.5rem; font-weight:800; color:var(--text-dark); margin:0;">
            ${movie != null ? 'Chỉnh sửa phim' : 'Thêm phim mới'}
        </h1>
        <a href="manager/movies" class="btn btn-secondary">Quay lại</a>
    </div>

    <c:if test="${not empty error}">
        <div class="cinema-msg cinema-msg--error" role="alert" style="margin-bottom:1rem;">${error}</div>
    </c:if>
    <c:if test="${not empty success}">
        <div class="cinema-msg cinema-msg--success" role="status" style="margin-bottom:1rem;">${success}</div>
    </c:if>

    <form action="manager/movies" method="post" enctype="multipart/form-data" class="profile-card" style="padding:1.5rem; border-radius:12px;">
        <input type="hidden" name="action" value="${movie != null ? 'update' : 'create'}">
        <input type="hidden" name="id" value="${movie.movieId}">
        <input type="hidden" name="existingPosterUrl" value="${movie.posterUrl}">

        <div class="form-group">
            <label for="title" class="form-label">Tiêu đề (Tiếng Việt)</label>
            <input type="text" name="title" id="title" class="form-input" value="${movie.title}" required>
        </div>

        <div class="form-group">
            <label for="titleEN" class="form-label">Tiêu đề (Tiếng Anh)</label>
            <input type="text" name="titleEN" id="titleEN" class="form-input" value="${movie.titleEN}" required>
        </div>

        <div class="form-group">
            <label for="description" class="form-label">Mô tả</label>
            <textarea name="description" id="description" class="form-input" rows="4">${movie.description}</textarea>
        </div>

        <div style="display:grid; grid-template-columns: 1fr 1fr; gap: 1rem;">
            <div class="form-group">
                <label for="genre" class="form-label">Thể loại</label>
                <select name="genre" id="genre" class="form-input">
                    <option value="" ${empty movie.genre ? 'selected' : ''}>-- Chọn thể loại --</option>
                    <option value="Hành động" ${movie.genre != null && movie.genre.contains('Hành động') ? 'selected' : ''}>Hành động</option>
                    <option value="Kinh dị" ${movie.genre != null && movie.genre.contains('Kinh dị') ? 'selected' : ''}>Kinh dị</option>
                    <option value="Hài" ${movie.genre != null && movie.genre.contains('Hài') ? 'selected' : ''}>Hài</option>
                    <option value="Khoa học viễn tưởng" ${movie.genre != null && movie.genre.contains('Khoa học viễn tưởng') ? 'selected' : ''}>Khoa học viễn tưởng</option>
                    <option value="Phiêu lưu" ${movie.genre != null && movie.genre.contains('Phiêu lưu') ? 'selected' : ''}>Phiêu lưu</option>
                    <option value="Hoạt hình" ${movie.genre != null && movie.genre.contains('Hoạt hình') ? 'selected' : ''}>Hoạt hình</option>
                    <option value="Tình cảm" ${movie.genre != null && movie.genre.contains('Tình cảm') ? 'selected' : ''}>Tình cảm</option>
                    <option value="Tâm lý" ${movie.genre != null && movie.genre.contains('Tâm lý') ? 'selected' : ''}>Tâm lý</option>
                </select>
                <div class="form-hint">Nếu phim có nhiều thể loại, bạn có thể chỉnh tay sau trong DB.</div>
            </div>
            <div class="form-group">
                <label for="language" class="form-label">Ngôn ngữ</label>
                <select name="language" id="language" class="form-input">
                    <option value="" ${empty movie.language ? 'selected' : ''}>-- Chọn ngôn ngữ --</option>
                    <option value="Tiếng Việt" ${movie.language=='Tiếng Việt' ? 'selected' : ''}>Tiếng Việt</option>
                    <option value="Tiếng Anh - Phụ đề" ${movie.language=='Tiếng Anh - Phụ đề' ? 'selected' : ''}>Tiếng Anh - Phụ đề</option>
                    <option value="Tiếng Anh - Lồng tiếng" ${movie.language=='Tiếng Anh - Lồng tiếng' ? 'selected' : ''}>Tiếng Anh - Lồng tiếng</option>
                    <option value="Tiếng Hàn - Phụ đề" ${movie.language=='Tiếng Hàn - Phụ đề' ? 'selected' : ''}>Tiếng Hàn - Phụ đề</option>
                    <option value="Tiếng Nhật - Phụ đề" ${movie.language=='Tiếng Nhật - Phụ đề' ? 'selected' : ''}>Tiếng Nhật - Phụ đề</option>
                </select>
            </div>
        </div>

        <div style="display:grid; grid-template-columns: 1fr 1fr; gap: 1rem;">
            <div class="form-group">
                <label for="ageRating" class="form-label">Phân loại lứa tuổi</label>
                <select name="ageRating" id="ageRating" class="form-input">
                    <option value="P" ${movie.ageRating=='P' ? 'selected' : '' }>P (Mọi lứa tuổi)</option>
                    <option value="C13" ${movie.ageRating=='C13' ? 'selected' : '' }>C13 (Trên 13 tuổi)</option>
                    <option value="C16" ${movie.ageRating=='C16' ? 'selected' : '' }>C16 (Trên 16 tuổi)</option>
                    <option value="C18" ${movie.ageRating=='C18' ? 'selected' : '' }>C18 (Trên 18 tuổi)</option>
                </select>
            </div>
            <div class="form-group">
                <label for="durationMins" class="form-label">Thời lượng (phút)</label>
                <input type="number" name="durationMins" id="durationMins" class="form-input" value="${movie.durationMins}" required>
            </div>
        </div>

        <div class="form-group">
            <label class="form-label">Poster phim</label>
            <div style="display:grid; grid-template-columns: 140px 1fr; gap: 1rem; align-items:start;">
                <div>
                    <c:set var="posterSrc" value="${not empty movie.posterUrl ? 'images/'.concat(movie.posterUrl) : 'images/default.jpg'}"/>
                    <img id="posterPreview" src="${posterSrc}" alt="Poster preview"
                         style="width:140px; height:210px; object-fit:cover; border-radius:12px; border:1px solid var(--border-light); background: var(--bg-white);">
                </div>
                <div>
                    <input type="file" name="posterFile" id="posterFile" class="form-input" accept="image/*">
                    <div class="form-hint">
                        Upload ảnh poster. Nếu không chọn ảnh mới, hệ thống giữ poster hiện tại.
                    </div>
                </div>
            </div>
        </div>

        <div class="form-group">
            <label for="trailerUrl" class="form-label">Trailer URL</label>
            <input type="text" name="trailerUrl" id="trailerUrl" class="form-input" value="${movie.trailerUrl}">
        </div>

        <div class="form-group">
            <label for="status" class="form-label">Trạng thái</label>
            <select name="status" id="status" class="form-input">
                <option value="NowShowing" ${movie.status=='NowShowing' ? 'selected' : '' }>NowShowing</option>
                <option value="ComingSoon" ${movie.status=='ComingSoon' ? 'selected' : '' }>ComingSoon</option>
                <option value="Ended" ${movie.status=='Ended' ? 'selected' : '' }>Ended</option>
            </select>
        </div>

        <div class="btn-row" style="margin-top: 1.25rem;">
            <button type="submit" class="btn btn-primary">${movie != null ? 'Cập nhật' : 'Thêm mới'}</button>
            <a href="manager/movies" class="btn btn-secondary">Hủy</a>
        </div>
    </form>
</main>

<jsp:include page="/components/footer.jsp"/>
<script>
    (function () {
        const input = document.getElementById('posterFile');
        const img = document.getElementById('posterPreview');
        if (!input || !img) return;
        input.addEventListener('change', function () {
            const file = input.files && input.files[0];
            if (!file) return;
            const url = URL.createObjectURL(file);
            img.src = url;
        });
    })();
</script>
</body>
</html>