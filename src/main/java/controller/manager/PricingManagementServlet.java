package controller.manager;

import dao.ShowtimeDAO;
import exception.DataAccessException;
import model.Showtime;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

@WebServlet(name = "PricingManagementServlet", urlPatterns = {"/manager/pricing"})
public class PricingManagementServlet extends HttpServlet {

    private final ShowtimeDAO showtimeDAO = new ShowtimeDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        List<Showtime> showtimes = showtimeDAO.findAllGroupByMovie(); // tái sử dụng list để manager xem nhanh
        req.setAttribute("showtimes", showtimes);
        req.getRequestDispatcher("/manager/pricing.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String showtimeIdStr = req.getParameter("showtimeId");
        String basePriceStr = req.getParameter("basePrice");
        if (showtimeIdStr == null || basePriceStr == null || showtimeIdStr.isBlank() || basePriceStr.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/manager/pricing");
            return;
        }
        try {
            int showtimeId = Integer.parseInt(showtimeIdStr);
            BigDecimal basePrice = new BigDecimal(basePriceStr);
            Showtime s = showtimeDAO.findById(showtimeId);
            if (s == null) {
                resp.sendRedirect(req.getContextPath() + "/manager/pricing");
                return;
            }
            s.setBasePrice(basePrice);
            showtimeDAO.update(s);
            resp.sendRedirect(req.getContextPath() + "/manager/pricing");
        } catch (NumberFormatException | DataAccessException e) {
            resp.sendRedirect(req.getContextPath() + "/manager/pricing");
        }
    }
}

