<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý nhân viên</title>
    <base href="${pageContext.request.contextPath}/">
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/header.css">
    <link rel="stylesheet" href="css/sidebar.css">
    <link rel="stylesheet" href="css/footer.css">
    <link rel="stylesheet" href="css/dashboard.css">
    <link rel="stylesheet" href="css/table.css">
    <link rel="stylesheet" href="css/button.css">
    <link rel="stylesheet" href="css/badge.css">
    <link rel="stylesheet" href="css/form.css">
    <link rel="stylesheet" href="css/message.css">
</head>
<body class="dashboard-layout">
<jsp:include page="/components/header.jsp"/>

<div class="dashboard-body">
    <jsp:include page="/components/sidebar.jsp"/>

    <main class="dashboard-main">
        <div class="dashboard-main__inner">

            <div class="page-header">
                <div>
                    <h1 class="page-title">Quản lý nhân viên</h1>
                    <p class="page-subtitle">Tạo và vô hiệu hóa tài khoản thu ngân / quản lý / admin.</p>
                </div>
            </div>

            <c:if test="${not empty successMsg}">
                <div class="cinema-msg cinema-msg--success">${successMsg}</div>
            </c:if>
            <c:if test="${not empty errorMsg}">
                <div class="cinema-msg cinema-msg--error">${errorMsg}</div>
            </c:if>

            <div class="staff-layout">

                <%-- Create form --%>
                <div class="card">
                    <h2 class="card-section-title">Tạo tài khoản nhân viên</h2>
                    <form method="post" action="admin/staff">
                        <input type="hidden" name="action" value="create">
                        <div class="form-group">
                            <label class="form-label" for="fullName">Họ tên</label>
                            <input type="text" id="fullName" name="fullName" class="form-input" required>
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="email">Email đăng nhập</label>
                            <input type="email" id="email" name="email" class="form-input" required>
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="phone">Số điện thoại</label>
                            <input type="text" id="phone" name="phone" class="form-input">
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="password">Mật khẩu tạm</label>
                            <input type="password" id="password" name="password" class="form-input" required>
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="roleCode">Vai trò</label>
                            <select id="roleCode" name="roleCode" class="form-input">
                                <option value="CASHIER">Thu ngân (CASHIER)</option>
                                <option value="MANAGER">Quản lý rạp (MANAGER)</option>
                                <option value="ADMIN">Quản trị hệ thống (ADMIN)</option>
                            </select>
                        </div>
                        <button type="submit" class="btn btn-primary">Tạo tài khoản</button>
                    </form>
                </div>

                <%-- Staff list --%>
                <div class="card">
                    <h2 class="card-section-title">Danh sách nhân viên</h2>
                    <c:choose>
                        <c:when test="${empty staff}">
                            <p class="table-empty">Chưa có tài khoản nhân viên nào.</p>
                        </c:when>
                        <c:otherwise>
                            <div class="table-wrap">
                                <table class="table">
                                    <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Họ tên</th>
                                        <th>Email</th>
                                        <th>Vai trò</th>
                                        <th>Trạng thái</th>
                                        <th class="col-actions">Thao tác</th>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    <c:forEach items="${staff}" var="u">
                                        <tr>
                                            <td>${u.userId}</td>
                                            <td><strong><c:out value="${u.fullName}"/></strong></td>
                                            <td><c:out value="${u.email}"/></td>
                                            <td>
                                                <span class="badge badge-info">${u.role.roleCode}</span>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${u.active}">
                                                        <span class="badge badge-success">Đang hoạt động</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge badge-danger">Đã vô hiệu</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <form method="post" action="admin/staff">
                                                    <input type="hidden" name="action" value="toggle">
                                                    <input type="hidden" name="userId" value="${u.userId}">
                                                    <button type="submit" class="btn btn-sm btn-secondary">
                                                        <c:choose>
                                                            <c:when test="${u.active}">Vô hiệu</c:when>
                                                            <c:otherwise>Kích hoạt</c:otherwise>
                                                        </c:choose>
                                                    </button>
                                                </form>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

            </div><%-- /.staff-layout --%>

        </div>
    </main>
</div>

<jsp:include page="/components/footer.jsp"/>
</body>
</html>
