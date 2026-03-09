package model;

/**
 * Model Role - Vai trò người dùng (CUSTOMER, CASHIER, MANAGER, ADMIN)
 */
public class Role {
    private int roleId;
    private String roleCode;
    private String roleName;
    private String description;

    public Role() {
    }

    public Role(int roleId, String roleCode, String roleName, String description) {
        this.roleId = roleId;
        this.roleCode = roleCode;
        this.roleName = roleName;
        this.description = description;
    }

    public int getRoleId() {
        return roleId;
    }

    public void setRoleId(int roleId) {
        this.roleId = roleId;
    }

    public String getRoleCode() {
        return roleCode;
    }

    public void setRoleCode(String roleCode) {
        this.roleCode = roleCode;
    }

    public String getRoleName() {
        return roleName;
    }

    public void setRoleName(String roleName) {
        this.roleName = roleName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
}
