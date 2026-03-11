package controller.admin;

import dao.AuditLogDAO;
import dao.UserDAO;
import model.Role;
import model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@WebServlet(name = "StaffManagementServlet", urlPatterns = {"/admin/staff"})
public class StaffManagementServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final AuditLogDAO auditLogDAO = new AuditLogDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        List<User> all = userDAO.findAllWithRoles();
        List<User> staff = all.stream()
                .filter(u -> u.getRole() != null
                        && !"CUSTOMER".equalsIgnoreCase(u.getRole().getRoleCode()))
                .collect(Collectors.toList());
        req.setAttribute("staff", staff);
        req.getRequestDispatcher("/admin/staff.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User current = (session != null) ? (User) session.getAttribute("user") : null;
        Integer adminId = current != null ? current.getUserId() : null;

        String action = req.getParameter("action");
        if ("create".equals(action)) {
            handleCreate(req, adminId);
        } else if ("toggle".equals(action)) {
            handleToggle(req, adminId);
        }
        resp.sendRedirect(req.getContextPath() + "/admin/staff");
    }

    private void handleCreate(HttpServletRequest req, Integer adminId) {
        try {
            String fullName = req.getParameter("fullName");
            String email = req.getParameter("email");
            String phone = req.getParameter("phone");
            String password = req.getParameter("password");
            String roleCode = req.getParameter("roleCode");

            if (fullName == null || fullName.isBlank()
                    || email == null || email.isBlank()
                    || password == null || password.isBlank()
                    || roleCode == null || roleCode.isBlank()) {
                return;
            }

            if (userDAO.existsByEmail(email.trim())) {
                return;
            }

            Role role = userDAO.getRoleByCode(roleCode.trim());
            if (role == null) {
                return;
            }

            User u = new User();
            u.setFullName(fullName.trim());
            u.setEmail(email.trim());
            u.setPhone(phone != null ? phone.trim() : null);
            // Ở đây demo: lưu plain hash (thực tế nên hash bằng BCrypt)
            u.setPasswordHash(password.trim());
            u.setRole(role);
            u.setMemberTier("Staff");
            u.setLoyaltyPoint(0);
            u.setActive(true);

            userDAO.create(u);
            auditLogDAO.log(adminId, "CREATE_STAFF", "Users", u.getUserId(),
                    "Tạo tài khoản nhân viên " + u.getEmail() + " với role " + role.getRoleCode());
        } catch (Exception ignored) {
        }
    }

    private void handleToggle(HttpServletRequest req, Integer adminId) {
        try {
            int userId = Integer.parseInt(req.getParameter("userId"));
            Optional<User> opt = userDAO.findById(userId);
            if (opt.isEmpty()) return;
            User u = opt.get();
            boolean newActive = !u.isActive();
            userDAO.updateActive(userId, newActive);
            auditLogDAO.log(adminId, "TOGGLE_STAFF", "Users", userId,
                    (newActive ? "Kích hoạt" : "Vô hiệu") + " tài khoản " + u.getEmail());
        } catch (Exception ignored) {
        }
    }
}

