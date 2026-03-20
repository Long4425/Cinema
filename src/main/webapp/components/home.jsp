<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Trang chủ | Cinema</title>
            <base
                href="${pageContext.request.scheme}://${pageContext.request.serverName}:${pageContext.request.serverPort}${pageContext.request.contextPath}/">
            <link rel="stylesheet" href="css/style.css">
            <link rel="stylesheet" href="css/header.css">
            <link rel="stylesheet" href="css/footer.css">
            <link rel="stylesheet" href="css/dashboard.css">
            <link rel="stylesheet" href="css/button.css">
        </head>

        <body class="home-layout">
            <jsp:include page="header.jsp" />

            <main style="flex:1 0 auto;">
                <!-- Hero Banner Section -->
                <section style="position: relative; margin-top: var(--header-height);">
                    <img src="images/cinema_hero_banner.png" alt="Cinema Banner" class="hero-banner__img"
                         style="width:100%; display:block;">
                    <a href="movies"
                       class="btn btn-primary"
                       style="position:absolute; left:5%; top:15%; padding:1.1rem 2.5rem; font-size:1.35rem; font-weight:800; letter-spacing:0.04em; border-radius:14px; box-shadow:0 6px 32px rgba(0,0,0,0.5); text-transform:uppercase; background:#f97316; border-color:#f97316; color:#fff;">
                        🎬 Đặt vé xem phim
                    </a>
                </section>
            </main>

            <jsp:include page="footer.jsp" />
        </body>

        </html>