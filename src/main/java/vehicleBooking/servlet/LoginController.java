package vehicleBooking.servlet;

import java.io.IOException;
import java.security.MessageDigest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import vehicleBooking.ConnectionManager;
import vehicleBooking.bean.CustomerBean;
import vehicleBooking.dao.CustDAO;

@WebServlet("/LoginController")
public class LoginController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    public LoginController() {
        super();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.sendRedirect(request.getContextPath() + "/login.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String role = request.getParameter("role");
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        System.out.println("========== LOGIN DEBUG ==========");
        System.out.println("LOGIN ROLE = " + role);
        System.out.println("LOGIN USERNAME = " + username);
        System.out.println("LOGIN PASSWORD = " + password);
        System.out.println("=================================");

        if (isEmpty(role) || isEmpty(username) || isEmpty(password)) {
            request.getSession().setAttribute("errorMessage", "Please enter username, password, and role.");
            response.sendRedirect(request.getContextPath() + "/login.jsp");
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

            if ("staff".equals(role)) {
                loginStaffOrOwner(request, response, username, password, "staff");
                return;
            }

            if ("owner".equals(role)) {
                loginStaffOrOwner(request, response, username, password, "owner");
                return;
            }

            request.getSession().setAttribute("errorMessage", "Invalid username, password, or role.");
            response.sendRedirect(request.getContextPath() + "/login.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMessage", "Login error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/login.jsp");
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

            // New session attributes for festive package eligibility
            session.setAttribute("custRace", customer.getCustRace());
            session.setAttribute("custReligion", customer.getCustReligion());

            session.setAttribute("name", customer.getCustName());
            session.setAttribute("username", customer.getCustUsername());
            session.setAttribute("email", customer.getCustEmail());
            session.setAttribute("role", "customer");
            session.setAttribute("userType", "customer");

            System.out.println("CUSTOMER LOGIN SUCCESS");
            System.out.println("CUSTOMER ID = " + customer.getCustID());
            System.out.println("CUSTOMER USERNAME = " + customer.getCustUsername());
            System.out.println("CUSTOMER RACE = " + customer.getCustRace());
            System.out.println("CUSTOMER RELIGION = " + customer.getCustReligion());

            response.sendRedirect(request.getContextPath() + "/customer/customerDashboard.jsp");
            return;
        }

        System.out.println("CUSTOMER LOGIN FAILED");
        request.getSession().setAttribute("errorMessage", "Invalid username, password, or role.");
        response.sendRedirect(request.getContextPath() + "/login.jsp");
    }

    private void loginStaffOrOwner(HttpServletRequest request, HttpServletResponse response,
            String username, String password, String selectedRole) throws Exception {

        String hashedPasswordLower = md5(password).toLowerCase();
        String hashedPasswordUpper = md5(password).toUpperCase();

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql =
                "SELECT STAFFID, STAFFNAME, STAFFEMAIL, STAFFUSERNAME, STAFFPASSWORD, " +
                "STAFFPHONENUM, STAFFROLE, OWNERID " +
                "FROM STAFF " +
                "WHERE (LOWER(TRIM(STAFFUSERNAME)) = LOWER(TRIM(?)) " +
                "OR LOWER(TRIM(STAFFID)) = LOWER(TRIM(?)) " +
                "OR LOWER(TRIM(STAFFEMAIL)) = LOWER(TRIM(?))) " +
                "AND (TRIM(STAFFPASSWORD) = ? " +
                "OR TRIM(STAFFPASSWORD) = ? " +
                "OR TRIM(STAFFPASSWORD) = ?)";

        try {
            con = ConnectionManager.getConnection();

            ps = con.prepareStatement(sql);

            ps.setString(1, username);
            ps.setString(2, username);
            ps.setString(3, username);
            ps.setString(4, password);
            ps.setString(5, hashedPasswordLower);
            ps.setString(6, hashedPasswordUpper);

            rs = ps.executeQuery();

            if (rs.next()) {

                String dbStaffRole = rs.getString("STAFFROLE");
                boolean dbIsOwner = isOwnerRole(dbStaffRole);

                if ("owner".equalsIgnoreCase(selectedRole) && !dbIsOwner) {
                    request.getSession().setAttribute("errorMessage", "Invalid owner account.");
                    response.sendRedirect(request.getContextPath() + "/login.jsp");
                    return;
                }

                if ("staff".equalsIgnoreCase(selectedRole) && dbIsOwner) {
                    request.getSession().setAttribute("errorMessage", "Please login using Owner role.");
                    response.sendRedirect(request.getContextPath() + "/login.jsp");
                    return;
                }

                HttpSession session = request.getSession();

                session.setAttribute("staffID", rs.getString("STAFFID"));
                session.setAttribute("staffName", rs.getString("STAFFNAME"));
                session.setAttribute("staffEmail", rs.getString("STAFFEMAIL"));
                session.setAttribute("staffUsername", rs.getString("STAFFUSERNAME"));
                session.setAttribute("staffPhoneNum", rs.getString("STAFFPHONENUM"));
                session.setAttribute("staffRole", dbStaffRole);
                session.setAttribute("ownerID", rs.getString("OWNERID"));

                session.setAttribute("name", rs.getString("STAFFUSERNAME"));
                session.setAttribute("username", rs.getString("STAFFUSERNAME"));
                session.setAttribute("email", rs.getString("STAFFEMAIL"));

                if (dbIsOwner) {
                    session.setAttribute("role", "owner");
                    session.setAttribute("userType", "owner");

                    System.out.println("OWNER LOGIN SUCCESS");
                    System.out.println("OWNER ID = " + rs.getString("STAFFID"));
                    System.out.println("OWNER USERNAME = " + rs.getString("STAFFUSERNAME"));

                    response.sendRedirect(request.getContextPath() + "/staff_owner/ownerDashboard.jsp");
                    return;
                }

                session.setAttribute("role", "staff");
                session.setAttribute("userType", "staff");

                System.out.println("STAFF LOGIN SUCCESS");
                System.out.println("STAFF ID = " + rs.getString("STAFFID"));
                System.out.println("STAFF USERNAME = " + rs.getString("STAFFUSERNAME"));

                response.sendRedirect(request.getContextPath() + "/staff_owner/staffDashboard.jsp");
                return;
            }

            System.out.println("STAFF / OWNER LOGIN FAILED");
            request.getSession().setAttribute("errorMessage", "Invalid username, password, or role.");
            response.sendRedirect(request.getContextPath() + "/login.jsp");

        } finally {
            close(rs, ps, con);
        }
    }

    private boolean isOwnerRole(String staffRole) {
        if (staffRole == null) {
            return false;
        }

        String role = staffRole.trim();

        return "OWNER".equalsIgnoreCase(role)
                || "ADMIN".equalsIgnoreCase(role)
                || "MANAGER".equalsIgnoreCase(role);
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

    private void close(ResultSet rs, PreparedStatement ps, Connection con) {
        try {
            if (rs != null) {
                rs.close();
            }

            if (ps != null) {
                ps.close();
            }

            if (con != null) {
                con.close();
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}