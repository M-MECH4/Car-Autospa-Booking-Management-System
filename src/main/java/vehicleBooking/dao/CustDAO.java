package vehicleBooking.dao;

import java.security.MessageDigest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import vehicleBooking.ConnectionManager;
import vehicleBooking.bean.CustomerBean;

public class CustDAO {

    // Customer login:
    // 1. Accepts MD5 hashed password OR old plain password
    private static final String SELECT_CUST_LOGIN =
            "SELECT * FROM CUSTOMER "
            + "WHERE LOWER(TRIM(CUSTUSERNAME)) = LOWER(TRIM(?)) "
            + "AND (LOWER(TRIM(CUSTPASSWORD)) = ? OR CUSTPASSWORD = ?)";

    // =========================
    // HASH PASSWORD USING MD5
    // =========================
    private static String hashPassword(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            byte[] messageDigest = md.digest(password.getBytes("UTF-8"));

            StringBuilder sb = new StringBuilder();

            for (byte b : messageDigest) {
                sb.append(String.format("%02x", b & 0xff));
            }

            return sb.toString();

        } catch (Exception e) {
            throw new RuntimeException("Error hashing password", e);
        }
    }

    // =========================
    // CUSTOMER LOGIN
    // =========================
    public static CustomerBean login(CustomerBean customer) throws SQLException {

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = ConnectionManager.getConnection();

            String username = customer.getCustUsername().trim();
            String password = customer.getCustPassword().trim();
            String hashedPassword = hashPassword(password);

            System.out.println("========== CUSTOMER LOGIN DEBUG ==========");
            System.out.println("Username entered: " + username);
            System.out.println("Password entered: " + password);
            System.out.println("MD5 hashed password: " + hashedPassword);
            System.out.println("==========================================");

            ps = con.prepareStatement(SELECT_CUST_LOGIN);

            ps.setString(1, username);
            ps.setString(2, hashedPassword);
            ps.setString(3, password);

            rs = ps.executeQuery();

            if (rs.next()) {
                customer.setCustID(rs.getString("CUSTID"));
                customer.setCustName(rs.getString("CUSTNAME"));
                customer.setCustPhoneNum(rs.getString("CUSTPHONENUM"));
                customer.setCustEmail(rs.getString("CUSTEMAIL"));
                customer.setCustUsername(rs.getString("CUSTUSERNAME"));
                customer.setCustPassword(rs.getString("CUSTPASSWORD"));
                customer.setCustRace(rs.getString("CUSTRACE"));
                customer.setCustReligion(rs.getString("CUSTRELIGION"));
                customer.setLoggedIn(true);

                System.out.println("Login success for customer: " + customer.getCustUsername());

                String dbPassword = rs.getString("CUSTPASSWORD");

                // If old customer password is still plain text, update it to MD5 automatically
                if (dbPassword != null && dbPassword.length() != 32) {
                    updatePasswordToHash(customer.getCustID(), hashedPassword);
                    System.out.println("Plain password upgraded to MD5 hash.");
                }

            } else {
                customer.setLoggedIn(false);
                System.out.println("Login failed. Username/password wrong.");
            }

        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            if (con != null) con.close();
        }

        return customer;
    }

    // =========================
    // GET CUSTOMER BY ID
    // =========================
    public static CustomerBean getCustomerById(String custID) throws SQLException {

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql = "SELECT CUSTID, CUSTNAME, CUSTEMAIL, CUSTUSERNAME, "
                + "CUSTPHONENUM, CUSTRACE, CUSTRELIGION "
                + "FROM CUSTOMER "
                + "WHERE CUSTID = ?";

        try {
            con = ConnectionManager.getConnection();

            ps = con.prepareStatement(sql);
            ps.setString(1, custID);

            rs = ps.executeQuery();

            if (rs.next()) {
                CustomerBean customer = new CustomerBean();

                customer.setCustID(rs.getString("CUSTID"));
                customer.setCustName(rs.getString("CUSTNAME"));
                customer.setCustEmail(rs.getString("CUSTEMAIL"));
                customer.setCustUsername(rs.getString("CUSTUSERNAME"));
                customer.setCustPhoneNum(rs.getString("CUSTPHONENUM"));
                customer.setCustRace(rs.getString("CUSTRACE"));
                customer.setCustReligion(rs.getString("CUSTRELIGION"));

                return customer;
            }

            return null;

        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            if (con != null) con.close();
        }
    }

    // =========================
    // GET TOTAL BOOKING BY CUSTOMER
    // =========================
    public static int getTotalBookingByCustomer(String custID) throws SQLException {

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql =
                "SELECT COUNT(*) AS TOTALBOOKING "
                + "FROM BOOKING b "
                + "INNER JOIN VEHICLE v ON b.VEHICLEPLATENUM = v.VEHICLEPLATENUM "
                + "WHERE v.CUSTID = ?";

        try {
            con = ConnectionManager.getConnection();

            ps = con.prepareStatement(sql);
            ps.setString(1, custID);

            rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt("TOTALBOOKING");
            }

            return 0;

        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            if (con != null) con.close();
        }
    }

    // =========================
    // GET COMPLETED BOOKING BY CUSTOMER
    // =========================
    public static int getCompletedBookingByCustomer(String custID) throws SQLException {

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql =
                "SELECT COUNT(*) AS COMPLETEDBOOKING "
                + "FROM BOOKING b "
                + "INNER JOIN VEHICLE v ON b.VEHICLEPLATENUM = v.VEHICLEPLATENUM "
                + "WHERE v.CUSTID = ? "
                + "AND UPPER(TRIM(b.BOOKINGSTATUS)) = 'COMPLETED'";

        try {
            con = ConnectionManager.getConnection();

            ps = con.prepareStatement(sql);
            ps.setString(1, custID);

            rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt("COMPLETEDBOOKING");
            }

            return 0;

        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            if (con != null) con.close();
        }
    }

    // =========================
    // GET LOYALTY POINTS BY CUSTOMER
    // 1 completed booking = 10 points
    // =========================
    public static int getLoyaltyPointsByCustomer(String custID) throws SQLException {

        int completedBooking = getCompletedBookingByCustomer(custID);
        int pointsPerCompletedBooking = 10;

        return completedBooking * pointsPerCompletedBooking;
    }

    // =========================
    // AUTO UPDATE PLAIN PASSWORD TO HASH
    // =========================
    private static void updatePasswordToHash(String custID, String hashedPassword) throws SQLException {

        Connection con = null;
        PreparedStatement ps = null;

        String sql = "UPDATE CUSTOMER SET CUSTPASSWORD = ? WHERE CUSTID = ?";

        try {
            con = ConnectionManager.getConnection();

            ps = con.prepareStatement(sql);
            ps.setString(1, hashedPassword);
            ps.setString(2, custID);

            ps.executeUpdate();

            if (!con.getAutoCommit()) {
                con.commit();
            }

        } finally {
            if (ps != null) ps.close();
            if (con != null) con.close();
        }
    }

    // =========================
    // REGISTER CUSTOMER
    // =========================
    public static int addCustomer(CustomerBean customer) throws Exception {

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String newCustID = null;

        String getIdSql =
                "SELECT 'C' || LPAD(NVL(MAX(TO_NUMBER(SUBSTR(CUSTID, 2))), 0) + 1, 3, '0') AS NEWID "
                + "FROM CUSTOMER "
                + "WHERE REGEXP_LIKE(CUSTID, '^C[0-9]+$')";

        String insertSql =
                "INSERT INTO CUSTOMER "
                + "(CUSTID, CUSTNAME, CUSTEMAIL, CUSTUSERNAME, CUSTPASSWORD, "
                + "CUSTPHONENUM, CUSTRACE, CUSTRELIGION) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try {
            con = ConnectionManager.getConnection();

            ps = con.prepareStatement(getIdSql);
            rs = ps.executeQuery();

            if (rs.next()) {
                newCustID = rs.getString("NEWID");
            }

            if (rs != null) {
                rs.close();
                rs = null;
            }

            if (ps != null) {
                ps.close();
                ps = null;
            }

            if (newCustID == null || newCustID.trim().isEmpty()) {
                newCustID = "C001";
            }

            ps = con.prepareStatement(insertSql);

            ps.setString(1, newCustID);
            ps.setString(2, customer.getCustName());
            ps.setString(3, customer.getCustEmail());
            ps.setString(4, customer.getCustUsername());
            ps.setString(5, hashPassword(customer.getCustPassword().trim()));
            ps.setString(6, customer.getCustPhoneNum());
            ps.setString(7, customer.getCustRace());
            ps.setString(8, customer.getCustReligion());

            System.out.println("========== INSERT CUSTOMER DEBUG ==========");
            System.out.println("NEW CUSTID = " + newCustID);
            System.out.println("NAME = " + customer.getCustName());
            System.out.println("EMAIL = " + customer.getCustEmail());
            System.out.println("USERNAME = " + customer.getCustUsername());
            System.out.println("PHONE = " + customer.getCustPhoneNum());
            System.out.println("RACE = " + customer.getCustRace());
            System.out.println("RELIGION = " + customer.getCustReligion());
            System.out.println("===========================================");

            int row = ps.executeUpdate();

            if (!con.getAutoCommit()) {
                con.commit();
            }

            System.out.println("INSERT CUSTOMER ROW = " + row);

            return row;

        } finally {
            if (rs != null) {
                rs.close();
            }

            if (ps != null) {
                ps.close();
            }

            if (con != null) {
                con.close();
            }
        }
    }

    // =========================
    // UPDATE CUSTOMER PROFILE
    // =========================
    public static int updateCustomerProfile(CustomerBean customer) throws SQLException {

        Connection con = null;
        PreparedStatement ps = null;

        String sql = "UPDATE CUSTOMER "
                + "SET CUSTNAME = ?, CUSTUSERNAME = ?, CUSTEMAIL = ?, CUSTPHONENUM = ? "
                + "WHERE CUSTID = ?";

        try {
            con = ConnectionManager.getConnection();

            ps = con.prepareStatement(sql);

            ps.setString(1, customer.getCustName());
            ps.setString(2, customer.getCustUsername());
            ps.setString(3, customer.getCustEmail());
            ps.setString(4, customer.getCustPhoneNum());
            ps.setString(5, customer.getCustID());

            System.out.println("UPDATE CUSTOMER PROFILE SQL: " + ps);

            int row = ps.executeUpdate();

            if (!con.getAutoCommit()) {
                con.commit();
            }

            return row;

        } finally {
            if (ps != null) ps.close();
            if (con != null) con.close();
        }
    }

    // =========================
    // UPDATE CUSTOMER PASSWORD
    // =========================
    public static int Custpassword(String custID, String currentPassword, String newPassword) throws SQLException {

        Connection con = null;
        PreparedStatement ps = null;

        String sql = "UPDATE CUSTOMER "
                + "SET CUSTPASSWORD = ? "
                + "WHERE CUSTID = ? "
                + "AND (LOWER(TRIM(CUSTPASSWORD)) = ? OR CUSTPASSWORD = ?)";

        try {
            con = ConnectionManager.getConnection();

            String currentPlain = currentPassword.trim();
            String newPlain = newPassword.trim();

            String hashedCurrentPassword = hashPassword(currentPlain);
            String hashedNewPassword = hashPassword(newPlain);

            System.out.println("========== UPDATE PASSWORD DEBUG ==========");
            System.out.println("Customer ID: " + custID);
            System.out.println("Current password hash: " + hashedCurrentPassword);
            System.out.println("New password hash: " + hashedNewPassword);
            System.out.println("===========================================");

            ps = con.prepareStatement(sql);

            ps.setString(1, hashedNewPassword);
            ps.setString(2, custID);
            ps.setString(3, hashedCurrentPassword);
            ps.setString(4, currentPlain);

            int row = ps.executeUpdate();

            if (!con.getAutoCommit()) {
                con.commit();
            }

            return row;

        } finally {
            if (ps != null) ps.close();
            if (con != null) con.close();
        }
    }

    // =========================
    // CHECK EMAIL EXISTS
    // =========================
    public static boolean emailExists(String email) throws SQLException {

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql = "SELECT CUSTEMAIL FROM CUSTOMER WHERE LOWER(CUSTEMAIL) = LOWER(?)";

        try {
            con = ConnectionManager.getConnection();

            ps = con.prepareStatement(sql);
            ps.setString(1, email);

            rs = ps.executeQuery();

            return rs.next();

        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            if (con != null) con.close();
        }
    }

    // =========================
    // CHECK EMAIL EXISTS FOR OTHER CUSTOMER
    // =========================
    public static boolean emailExistsForOtherCustomer(String email, String custID) throws SQLException {

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql = "SELECT CUSTEMAIL FROM CUSTOMER "
                + "WHERE LOWER(CUSTEMAIL) = LOWER(?) "
                + "AND CUSTID <> ?";

        try {
            con = ConnectionManager.getConnection();

            ps = con.prepareStatement(sql);
            ps.setString(1, email);
            ps.setString(2, custID);

            rs = ps.executeQuery();

            return rs.next();

        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            if (con != null) con.close();
        }
    }

    // =========================
    // MICROSERVICE - GET CUSTOMER ID BY EMAIL
    // =========================
    public static String getCustIdByEmail(String email) {

        String sql = "SELECT CUSTID FROM CUSTOMER WHERE LOWER(CUSTEMAIL) = LOWER(?)";

        try (Connection con = ConnectionManager.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, email);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getString("CUSTID");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    // =========================
    // MICROSERVICE - UPDATE PASSWORD
    // Note:
    // ResetPasswordController already sends hashed password.
    // So this method saves the password exactly as received.
    // =========================
    public static boolean updatePassword(String custId, String newPassword) {

        String sql = "UPDATE CUSTOMER SET CUSTPASSWORD = ? WHERE CUSTID = ?";

        try (Connection con = ConnectionManager.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, newPassword);
            ps.setString(2, custId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }
}