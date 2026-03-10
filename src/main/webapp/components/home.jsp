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
        </head>

        <body class="home-layout">
            <jsp:include page="header.jsp" />

            <main class="home-main">
                <!-- Hero Banner Section -->
                <section class="hero-banner">
                    <img src="images/cinema_hero_banner.png" alt="Cinema Banner" class="hero-banner__img">
                </section>



                
            </main>

            <jsp:include page="footer.jsp" />
        </body>

        </html>