package controller.manager;

import dao.VoucherDAO;
import model.Voucher;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeParseException;
import java.util.List;

@WebServlet(name = "PromotionManagementServlet", urlPatterns = {"/manager/promotions"})
public class PromotionManagementServlet extends HttpServlet {

    private final VoucherDAO voucherDAO = new VoucherDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        List<Voucher> vouchers = voucherDAO.findAll();
        req.setAttribute("vouchers", vouchers);
        req.getRequestDispatcher("/manager/promotions.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("create".equals(action)) {
            handleCreate(req);
        } else if ("toggle".equals(action)) {
            handleToggle(req);
        }
        resp.sendRedirect(req.getContextPath() + "/manager/promotions");
    }

    private void handleCreate(HttpServletRequest req) {
        try {
            String code = req.getParameter("code");
            String type = req.getParameter("discountType");
            BigDecimal value = new BigDecimal(req.getParameter("discountValue"));
            BigDecimal minOrder = new BigDecimal(req.getParameter("minOrderValue"));
            int maxUsage = Integer.parseInt(req.getParameter("maxUsage"));
            String expiredStr = req.getParameter("expiredAt");

            if (code == null || code.isBlank()) {
                return;
            }

            LocalDateTime expiredAt = LocalDateTime.parse(expiredStr + "T23:59:59");

            Voucher v = new Voucher();
            v.setCode(code.trim().toUpperCase());
            v.setDiscountType(type);
            v.setDiscountValue(value);
            v.setMinOrderValue(minOrder);
            v.setMaxUsage(maxUsage);
            v.setExpiredAt(expiredAt);
            v.setActive(true);

            voucherDAO.create(v);
        } catch (NumberFormatException | DateTimeParseException ignored) {
        }
    }

    private void handleToggle(HttpServletRequest req) {
        try {
            int voucherId = Integer.parseInt(req.getParameter("voucherId"));
            boolean active = Boolean.parseBoolean(req.getParameter("active"));
            voucherDAO.updateActive(voucherId, !active);
        } catch (NumberFormatException ignored) {
        }
    }
}

