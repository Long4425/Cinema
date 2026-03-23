package controller.booking;

import dao.UserDAO;
import dao.VoucherDAO;
import model.User;
import model.Voucher;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "RedeemPointsServlet", urlPatterns = {"/profile/redeem-points"})
public class RedeemPointsServlet extends HttpServlet {

    // Bảng đổi điểm: điểm cần → mệnh giá voucher (VNĐ)
    // 10.000đ = 1 điểm; 20 điểm = voucher 20.000đ
    public static final int[][] REDEEM_OPTIONS = {
        { 20,  20_000},
        { 50,  50_000},
        {100, 100_000},
        {200, 200_000},
    };

    private final UserDAO userDAO = new UserDAO();
    private final VoucherDAO voucherDAO = new VoucherDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        User user = (User) session.getAttribute("user");

        // Reload điểm mới nhất từ DB
        userDAO.findById(user.getUserId()).ifPresent(fresh -> {
            user.setLoyaltyPoint(fresh.getLoyaltyPoint());
            session.setAttribute("user", user);
        });

        List<Voucher> myVouchers = voucherDAO.findActiveByUser(user.getUserId());
        req.setAttribute("myVouchers", myVouchers);
        req.setAttribute("redeemOptions", REDEEM_OPTIONS);
        req.setAttribute("activeTab", "REDEEM");
        req.getRequestDispatcher("/profile/redeem-points.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        User user = (User) session.getAttribute("user");

        String pointsStr = req.getParameter("points");
        int pointCost;
        try {
            pointCost = Integer.parseInt(pointsStr);
        } catch (NumberFormatException e) {
            session.setAttribute("error", "Lựa chọn không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/profile/redeem-points");
            return;
        }

        // Tìm mệnh giá tương ứng trong bảng đổi
        int voucherValue = -1;
        for (int[] opt : REDEEM_OPTIONS) {
            if (opt[0] == pointCost) {
                voucherValue = opt[1];
                break;
            }
        }
        if (voucherValue < 0) {
            session.setAttribute("error", "Lựa chọn đổi điểm không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/profile/redeem-points");
            return;
        }

        // Reload điểm hiện tại từ DB
        User fresh = userDAO.findById(user.getUserId()).orElse(null);
        if (fresh == null || fresh.getLoyaltyPoint() < pointCost) {
            session.setAttribute("error", "Bạn không đủ điểm để đổi voucher này.");
            resp.sendRedirect(req.getContextPath() + "/profile/redeem-points");
            return;
        }

        // Trừ điểm & tạo voucher
        userDAO.deductLoyaltyPoints(user.getUserId(), pointCost);
        String code = voucherDAO.createForUser(user.getUserId(), voucherValue, pointCost);

        // Cập nhật lại điểm trong session
        user.setLoyaltyPoint(fresh.getLoyaltyPoint() - pointCost);
        session.setAttribute("user", user);

        session.setAttribute("success", "Đổi thành công! Mã voucher của bạn: " + code);
        resp.sendRedirect(req.getContextPath() + "/profile/redeem-points");
    }
}
