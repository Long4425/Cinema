<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nhật ký hoạt động</title>
    <base href="${pageContext.request.contextPath}/">
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/header.css">
    <link rel="stylesheet" href="css/sidebar.css">
    <link rel="stylesheet" href="css/footer.css">
    <link rel="stylesheet" href="css/dashboard.css">
    <link rel="stylesheet" href="css/table.css">
    <link rel="stylesheet" href="css/button.css">
</head>
<body class="dashboard-layout">
<jsp:include page="/components/header.jsp"/>

<div class="dashboard-body">
    <jsp:include page="/components/sidebar.jsp"/>

    <main class="dashboard-main">
        <div class="dashboard-main__inner">
            <div class="page-header">
                <div>
                    <h1 class="page-title">Nhật ký hoạt động</h1>
                    <p class="page-subtitle">Theo dõi các hành động quan trọng trong hệ thống.</p>
                </div>
            </div>

            <div class="card" style="padding:1.25rem;margin-bottom:1rem;">
                <form method="get" action="admin/audit" class="search-filter-section" style="margin:0;">
                    <div class="filter-group">
                        <label class="form-label" for="fromDate">Từ ngày</label>
                        <input type="date" id="fromDate" name="fromDate" class="form-input" value="${fromDate}">
                    </div>
                    <div class="filter-group">
                        <label class="form-label" for="toDate">Đến ngày</label>
                        <input type="date" id="toDate" name="toDate" class="form-input" value="${toDate}">
                    </div>
                    <div class="filter-group">
                        <label class="form-label" for="actionFilter">Hành động</label>
                        <input type="text" id="actionFilter" name="actionFilter" class="form-input"
                               value="${actionFilter}" placeholder="VD: CREATE_STAFF, CANCEL_BOOKING">
                    </div>
                    <div style="display:flex;align-items:flex-end;gap:0.5rem;">
                        <button type="submit" class="btn btn-primary">Lọc</button>
                    </div>
                </form>
            </div>

            <div class="card" style="padding:1.25rem;">
                <c:if test="${empty logs}">
                    <p style="font-size:0.9rem;color:var(--text-muted);margin:0;">Chưa có log nào trong khoảng thời gian này.</p>
                </c:if>
                <c:if test="${not empty logs}">
                    <div class="table-wrap">
                        <table class="table">
                            <thead>
                            <tr>
                                <th>ID</th>
                                <th>Thời gian</th>
                                <th>UserId</th>
                                <th>Action</th>
                                <th>Đối tượng</th>
                                <th>Chi tiết</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:forEach items="${logs}" var="l">
                                <tr>
                                    <td>${l.logId}</td>
                                    <td>
                                        <fmt:formatDate value="${l.createdAt}" pattern="HH:mm:ss dd/MM/yyyy"/>
                                    </td>
                                    <td>${l.userId}</td>
                                    <td>${l.action}</td>
                                    <td>${l.targetTable} #${l.targetId}</td>
                                    <td><c:out value="${l.detail}"/></td>
                                </tr>
                            </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:if>
            </div>
        </div>
    </main>
</div>

<jsp:include page="/components/footer.jsp"/>
</body>
</html>

