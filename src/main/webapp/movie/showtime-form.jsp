<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8">
            <title>${showtime != null ? 'Sửa' : 'Thêm'} lịch chiếu - Admin Dashboard</title>
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
                    <h1 class="dashboard__title">${showtime != null ? 'Chỉnh sửa suất chiếu' : 'Thêm suất chiếu mới'}
                    </h1>

                    <c:if test="${not empty error}">
                        <div
                            style="background: #fee2e2; color: #dc2626; padding: 12px; border-radius: 8px; margin-bottom: 20px;">
                            ${error}
                        </div>
                    </c:if>

                    <div class="dashboard__card">
                        <form action="${pageContext.request.contextPath}/manager/showtimes" method="post" class="form">
                            <input type="hidden" name="action" value="${showtime != null ? 'update' : 'create'}">
                            <input type="hidden" name="id" value="${showtime.showtimeId}">

                            <div class="form__group">
                                <label for="movieId" class="form__label">Chọn phim</label>
                                <select name="movieId" id="movieId" class="form__input" required>
                                    <c:forEach var="m" items="${movies}">
                                        <option value="${m.movieId}" ${showtime.movieId==m.movieId ? 'selected' : '' }>
                                            ${m.title}</option>
                                    </c:forEach>
                                </select>
                            </div>

                            <div class="form__group">
                                <label for="roomId" class="form__label">Chọn phòng</label>
                                <select name="roomId" id="roomId" class="form__input" required>
                                    <c:forEach var="r" items="${rooms}">
                                        <option value="${r.roomId}" ${showtime.roomId==r.roomId ? 'selected' : '' }>
                                            ${r.roomName} (${r.roomType})</option>
                                    </c:forEach>
                                </select>
                            </div>

                            <div class="form__row" style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                                <div class="form__group">
                                    <label for="startTime" class="form__label">Thời gian bắt đầu</label>
                                    <input type="datetime-local" name="startTime" id="startTime" class="form__input"
                                        value="${showtime.startTime}" required>
                                </div>
                                <div class="form__group">
                                    <label for="endTime" class="form__label">Thời gian kết thúc</label>
                                    <input type="datetime-local" name="endTime" id="endTime" class="form__input"
                                        value="${showtime.endTime}" required>
                                </div>
                            </div>

                            <div class="form__group">
                                <label for="basePrice" class="form__label">Giá cơ bản (₫)</label>
                                <input type="number" name="basePrice" id="basePrice" class="form__input"
                                    value="${showtime.basePrice}" required>
                            </div>

                            <div class="form__group">
                                <label for="status" class="form__label">Trạng thái</label>
                                <select name="status" id="status" class="form__input">
                                    <option value="Scheduled" ${showtime.status=='Scheduled' ? 'selected' : '' }>
                                        Scheduled</option>
                                    <option value="Ongoing" ${showtime.status=='Ongoing' ? 'selected' : '' }>Ongoing
                                    </option>
                                    <option value="Finished" ${showtime.status=='Finished' ? 'selected' : '' }>Finished
                                    </option>
                                    <option value="Cancelled" ${showtime.status=='Cancelled' ? 'selected' : '' }>
                                        Cancelled</option>
                                </select>
                            </div>

                            <div class="form__actions">
                                <button type="submit" class="btn btn--primary">${showtime != null ? 'Cập nhật' : 'Thêm
                                    mới'}</button>
                                <a href="${pageContext.request.contextPath}/manager/showtimes"
                                    class="btn btn--secondary">Hủy</a>
                            </div>
                        </form>
                    </div>
                </main>
            </div>
        </body>

        </html>