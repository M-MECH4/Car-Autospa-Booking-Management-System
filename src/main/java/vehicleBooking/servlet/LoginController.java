package vehicleBooking.servlet;

import java.io.IOException;
import java.security.MessageDigest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import vehicleBooking.ConnectionManager;
import vehicleBooking.bean.CustomerBean;
import vehicleBooking.dao.CustDAO;

@WebServlet("/LoginController")
public class LoginController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String role = request.getParameter("role");
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (isEmpty(role) || isEmpty(username) || isEmpty(password)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=empty");
            return;
        }

        role = role.trim().toLowerCase();
        username = username.trim();
        password = password.trim();

        try {
            if ("customer".equals(role)) {
                loginCustomer(request, response, username, password);
                return;
            }

            if ("staff".equals(role) || "owner".equals(role)) {
                loginStaffOrOwner(request, response, username, password, role);
                return;
            }

            response.sendRedirect(request.getContextPath() + "/login.jsp?error=invalid");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=invalid");
        }
    }

    private void loginCustomer(HttpServletRequest request, HttpServletResponse response,
            String username, String password) throws Exception {

        CustomerBean customer = new CustomerBean();
        customer.setCustUsername(username);
        customer.setCustPassword(password);

        customer = CustDAO.login(customer);

        if (customer != null && customer.isLoggedIn()) {
            HttpSession session = request.getSession();

            session.setAttribute("custID", customer.getCustID());
            session.setAttribute("custName", customer.getCustName());
            session.setAttribute("custUsername", customer.getCustUsername());
            session.setAttribute("custEmail", customer.getCustEmail());
            session.setAttribute("custPhoneNum", customer.getCustPhoneNum());

            session.setAttribute("name", customer.getCustName());
            session.setAttribute("username", customer.getCustUsername());
            session.setAttribute("email", customer.getCustEmail());
            session.setAttribute("role", "customer");
            session.setAttribute("userType", "customer");

            response.sendRedirect(request.getContextPath() + "/customer/customerDashboard.jsp");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/login.jsp?error=invalid");
    }

    private void loginStaffOrOwner(HttpServletRequest request, HttpServletResponse response,
            String username, String password, String selectedRole) throws Exception {

        String hashedLower = md5(password).toLowerCase();
        String hashedUpper = md5(password).toUpperCase();

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql =
            "SELECT STAFFID, STAFFUSERNAME, STAFFPASSWORD, STAFFPHONENUM, STAFFROLE, OWNERID " +
            "FROM STAFF " +
            "WHERE (LOWER(TRIM(STAFFUSERNAME)) = LOWER(TRIM(?)) " +
            "OR LOWER(TRIM(STAFFID)) = LOWER(TRIM(?))) " +
            "AND (TRIM(STAFFPASSWORD) = ? " +
            "OR TRIM(STAFFPASSWORD) = ? " +
            "OR TRIM(STAFFPASSWORD) = ?)";

        try {
            con = ConnectionManager.getConnection();
            ps = con.prepareStatement(sql);

            ps.setString(1, username);
            ps.setString(2, username);
            ps.setString(3, password);
            ps.setString(4, hashedLower);
            ps.setString(5, hashedUpper);

            rs = ps.executeQuery();

            if (rs.next()) {
                String dbStaffRole = rs.getString("STAFFROLE");

                boolean isOwnerAccount = dbStaffRole != null &&
                        dbStaffRole.trim().equalsIgnoreCase("Owner");

                if ("owner".equals(selectedRole) && !isOwnerAccount) {
                    response.sendRedirect(request.getContextPath() + "/login.jsp?error=invalid");
                    return;
                }

                if ("staff".equals(selectedRole) && isOwnerAccount) {
                    response.sendRedirect(request.getContextPath() + "/login.jsp?error=invalid");
                    return;
                }

                HttpSession session = request.getSession();

                session.setAttribute("staffID", rs.getString("STAFFID"));
                session.setAttribute("staffUsername", rs.getString("STAFFUSERNAME"));
                session.setAttribute("staffPhoneNum", rs.getString("STAFFPHONENUM"));
                session.setAttribute("staffRole", dbStaffRole);
                session.setAttribute("ownerID", rs.getString("OWNERID"));

                session.setAttribute("name", rs.getString("STAFFUSERNAME"));
                session.setAttribute("username", rs.getString("STAFFUSERNAME"));
                session.setAttribute("role", selectedRole);
                session.setAttribute("userType", selectedRole);

                if ("owner".equals(selectedRole)) {
                	response.sendRedirect(request.getContextPath() + "/staff_owner/ownerDashboard.jsp");
                } else {
                    response.sendRedirect(request.getContextPath() + "/staff_owner/staffDashboard.jsp");
                }
                return;
            }

            response.sendRedirect(request.getContextPath() + "/login.jsp?error=invalid");

        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            if (con != null) con.close();
        }
    }

    private String md5(String input) {
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            byte[] bytes = md.digest(input.getBytes("UTF-8"));

            StringBuilder sb = new StringBuilder();

            for (byte b : bytes) {
                sb.append(String.format("%02x", b & 0xff));
            }

            return sb.toString();

        } catch (Exception e) {
            e.printStackTrace();
            return input;
        }
    }

    private boolean isEmpty(String value) {
        return value == null || value.trim().isEmpty();
    }
}