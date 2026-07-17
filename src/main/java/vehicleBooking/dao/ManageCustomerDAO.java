package vehicleBooking.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import vehicleBooking.ConnectionManager;
import vehicleBooking.bean.ManageCustomerBean;

public class ManageCustomerDAO {

    // =========================
    // GET ALL CUSTOMERS
    // Includes race, religion, and related booking count.
    // =========================
    public static List<ManageCustomerBean> getAllCustomers(String keyword) {

        List<ManageCustomerBean> customerList = new ArrayList<ManageCustomerBean>();

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = ConnectionManager.getConnection();

            String sql =
                    "SELECT c.CUSTID, c.CUSTNAME, c.CUSTEMAIL, c.CUSTUSERNAME, c.CUSTPHONENUM, "
                    + "c.CUSTRACE, c.CUSTRELIGION, "
                    + "(SELECT COUNT(*) "
                    + " FROM VEHICLE v "
                    + " INNER JOIN BOOKING b ON b.VEHICLEPLATENUM = v.VEHICLEPLATENUM "
                    + " WHERE v.CUSTID = c.CUSTID) AS RELATEDRECORDCOUNT "
                    + "FROM CUSTOMER c "
                    + "WHERE 1 = 1 ";

            if (keyword != null && !keyword.trim().isEmpty()) {
                sql +=
                        "AND (LOWER(c.CUSTID) LIKE LOWER(?) "
                        + "OR LOWER(c.CUSTNAME) LIKE LOWER(?) "
                        + "OR LOWER(c.CUSTEMAIL) LIKE LOWER(?) "
                        + "OR LOWER(c.CUSTUSERNAME) LIKE LOWER(?) "
                        + "OR LOWER(c.CUSTPHONENUM) LIKE LOWER(?) "
                        + "OR LOWER(c.CUSTRACE) LIKE LOWER(?) "
                        + "OR LOWER(c.CUSTRELIGION) LIKE LOWER(?)) ";
            }

            sql += "ORDER BY c.CUSTID";

            ps = con.prepareStatement(sql);

            if (keyword != null && !keyword.trim().isEmpty()) {
                String search = "%" + keyword.trim() + "%";

                ps.setString(1, search);
                ps.setString(2, search);
                ps.setString(3, search);
                ps.setString(4, search);
                ps.setString(5, search);
                ps.setString(6, search);
                ps.setString(7, search);
            }

            rs = ps.executeQuery();

            while (rs.next()) {
                ManageCustomerBean customer = new ManageCustomerBean();

                customer.setCustID(rs.getString("CUSTID"));
                customer.setCustName(rs.getString("CUSTNAME"));
                customer.setCustEmail(rs.getString("CUSTEMAIL"));
                customer.setCustUsername(rs.getString("CUSTUSERNAME"));
                customer.setCustPhoneNum(rs.getString("CUSTPHONENUM"));
                customer.setCustRace(rs.getString("CUSTRACE"));
                customer.setCustReligion(rs.getString("CUSTRELIGION"));
                customer.setRelatedRecordCount(rs.getInt("RELATEDRECORDCOUNT"));

                customerList.add(customer);
            }

        } catch (Exception e) {
            e.printStackTrace();

        } finally {
            close(rs, ps, con);
        }

        return customerList;
    }

    // =========================
    // COUNT CUSTOMER BOOKINGS
    // =========================
    public static int countCustomerBooking(String custID) {

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        int totalBooking = 0;

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
                totalBooking = rs.getInt("TOTALBOOKING");
            }

        } catch (Exception e) {
            e.printStackTrace();

        } finally {
            close(rs, ps, con);
        }

        return totalBooking;
    }

    // =========================
    // DELETE CUSTOMER WITH NO BOOKING
    // Deletes vehicle first, then customer.
    // =========================
    public static int deleteCustomerNoBooking(String custID) {

        Connection con = null;
        PreparedStatement psDeleteVehicle = null;
        PreparedStatement psDeleteCustomer = null;

        int row = 0;

        String deleteVehicleSql =
                "DELETE FROM VEHICLE "
                + "WHERE CUSTID = ?";

        String deleteCustomerSql =
                "DELETE FROM CUSTOMER "
                + "WHERE CUSTID = ?";

        try {
            con = ConnectionManager.getConnection();

            if (con.getAutoCommit()) {
                con.setAutoCommit(false);
            }

            psDeleteVehicle = con.prepareStatement(deleteVehicleSql);
            psDeleteVehicle.setString(1, custID);
            psDeleteVehicle.executeUpdate();

            psDeleteCustomer = con.prepareStatement(deleteCustomerSql);
            psDeleteCustomer.setString(1, custID);

            row = psDeleteCustomer.executeUpdate();

            con.commit();

        } catch (Exception e) {
            e.printStackTrace();

            try {
                if (con != null) {
                    con.rollback();
                }
            } catch (Exception rollbackError) {
                rollbackError.printStackTrace();
            }

        } finally {
            try {
                if (psDeleteVehicle != null) {
                    psDeleteVehicle.close();
                }

                if (psDeleteCustomer != null) {
                    psDeleteCustomer.close();
                }

                if (con != null) {
                    con.close();
                }

            } catch (Exception closeError) {
                closeError.printStackTrace();
            }
        }

        return row;
    }

    // =========================
    // DELETE CUSTOMER
    // Only customers with no connected booking data can be deleted.
    // =========================
    public static int deleteCustomer(String custID) {

        if (custID == null || custID.trim().isEmpty()) {
            return 0;
        }

        custID = custID.trim();

        if (hasBooking(custID)) {
            return -1;
        }

        return deleteCustomerNoBooking(custID);
    }

    // =========================
    // CHECK CUSTOMER HAS BOOKING
    // =========================
    public static boolean hasBooking(String custID) {

        if (custID == null || custID.trim().isEmpty()) {
            return false;
        }

        return countCustomerBooking(custID.trim()) > 0;
    }

    // =========================
    // CLOSE RESOURCES
    // =========================
    private static void close(ResultSet rs, PreparedStatement ps, Connection con) {

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
