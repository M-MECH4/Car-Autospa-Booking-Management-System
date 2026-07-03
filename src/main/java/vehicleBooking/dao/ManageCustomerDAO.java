package vehicleBooking.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import vehicleBooking.ConnectionManager;
import vehicleBooking.bean.ManageCustomerBean;

public class ManageCustomerDAO {

    public static List<ManageCustomerBean> getAllCustomers(String keyword) {

        List<ManageCustomerBean> customerList = new ArrayList<ManageCustomerBean>();

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        boolean hasKeyword = keyword != null && !keyword.trim().isEmpty();

        String sql;

        if (hasKeyword) {
            sql =
                    "SELECT CUSTID, CUSTNAME, CUSTEMAIL, CUSTUSERNAME, CUSTPHONENUM, CUSTRACE, CUSTRELIGION " +
                    "FROM CUSTOMER " +
                    "WHERE UPPER(CUSTID) LIKE UPPER(?) " +
                    "OR UPPER(CUSTNAME) LIKE UPPER(?) " +
                    "OR UPPER(CUSTEMAIL) LIKE UPPER(?) " +
                    "OR UPPER(CUSTUSERNAME) LIKE UPPER(?) " +
                    "OR UPPER(CUSTPHONENUM) LIKE UPPER(?) " +
                    "ORDER BY CUSTID";
        } else {
            sql =
                    "SELECT CUSTID, CUSTNAME, CUSTEMAIL, CUSTUSERNAME, CUSTPHONENUM, CUSTRACE, CUSTRELIGION " +
                    "FROM CUSTOMER " +
                    "ORDER BY CUSTID";
        }

        try {
            con = ConnectionManager.getConnection();
            ps = con.prepareStatement(sql);

            if (hasKeyword) {
                String search = "%" + keyword.trim() + "%";
                ps.setString(1, search);
                ps.setString(2, search);
                ps.setString(3, search);
                ps.setString(4, search);
                ps.setString(5, search);
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

                customerList.add(customer);
            }

        } catch (Exception e) {
            e.printStackTrace();

        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (con != null) con.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        return customerList;
    }

    public static int deleteCustomer(String custID) {

        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = ConnectionManager.getConnection();
            con.setAutoCommit(false);

            String deleteBookingSql =
                    "DELETE FROM BOOKING " +
                    "WHERE VEHICLEPLATENUM IN ( " +
                    "SELECT VEHICLEPLATENUM FROM VEHICLE WHERE CUSTID = ? " +
                    ")";

            ps = con.prepareStatement(deleteBookingSql);
            ps.setString(1, custID);
            ps.executeUpdate();
            ps.close();

            String deleteVehicleSql =
                    "DELETE FROM VEHICLE " +
                    "WHERE CUSTID = ?";

            ps = con.prepareStatement(deleteVehicleSql);
            ps.setString(1, custID);
            ps.executeUpdate();
            ps.close();

            String deleteCustomerSql =
                    "DELETE FROM CUSTOMER " +
                    "WHERE CUSTID = ?";

            ps = con.prepareStatement(deleteCustomerSql);
            ps.setString(1, custID);

            int row = ps.executeUpdate();

            con.commit();

            return row;

        } catch (Exception e) {
            e.printStackTrace();

            try {
                if (con != null) {
                    con.rollback();
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            }

            return 0;

        } finally {
            try {
                if (ps != null) ps.close();
                if (con != null) con.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}