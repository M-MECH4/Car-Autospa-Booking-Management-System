package vehicleBooking.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import vehicleBooking.ConnectionManager;
import vehicleBooking.bean.DashboardBookingBean;

public class CustomerDashboardDAO {

    public static int getTotalBookings(String custID) {
        int total = 0;

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql =
                "SELECT COUNT(*) AS TOTAL " +
                "FROM BOOKING b " +
                "JOIN VEHICLE v ON b.VEHICLEPLATENUM = v.VEHICLEPLATENUM " +
                "WHERE v.CUSTID = ?";

        try {
            con = ConnectionManager.getConnection();

            ps = con.prepareStatement(sql);
            ps.setString(1, custID);

            rs = ps.executeQuery();

            if (rs.next()) {
                total = rs.getInt("TOTAL");
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(rs, ps, con);
        }

        return total;
    }

    public static int getCompletedBookings(String custID) {
        int total = 0;

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql =
                "SELECT COUNT(*) AS TOTAL " +
                "FROM BOOKING b " +
                "JOIN VEHICLE v ON b.VEHICLEPLATENUM = v.VEHICLEPLATENUM " +
                "WHERE v.CUSTID = ? " +
                "AND UPPER(b.BOOKINGSTATUS) = 'COMPLETED'";

        try {
            con = ConnectionManager.getConnection();

            ps = con.prepareStatement(sql);
            ps.setString(1, custID);

            rs = ps.executeQuery();

            if (rs.next()) {
                total = rs.getInt("TOTAL");
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(rs, ps, con);
        }

        return total;
    }

    public static int getTotalVehicles(String custID) {
        int total = 0;

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql =
                "SELECT COUNT(*) AS TOTAL " +
                "FROM VEHICLE " +
                "WHERE CUSTID = ?";

        try {
            con = ConnectionManager.getConnection();

            ps = con.prepareStatement(sql);
            ps.setString(1, custID);

            rs = ps.executeQuery();

            if (rs.next()) {
                total = rs.getInt("TOTAL");
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(rs, ps, con);
        }

        return total;
    }

    public static String getFirstVehiclePlate(String custID) {
        String plate = "-";

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql =
                "SELECT VEHICLEPLATENUM " +
                "FROM VEHICLE " +
                "WHERE CUSTID = ? " +
                "ORDER BY VEHICLEPLATENUM";

        try {
            con = ConnectionManager.getConnection();

            ps = con.prepareStatement(sql);
            ps.setString(1, custID);

            rs = ps.executeQuery();

            if (rs.next()) {
                plate = rs.getString("VEHICLEPLATENUM");
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(rs, ps, con);
        }

        return plate;
    }

    public static int getTotalInvoices(String custID) {
        /*
         * For now, invoice count is based on completed bookings.
         * If later you already have INVOICE table, this method can be changed
         * to count from INVOICE table.
         */
        return getCompletedBookings(custID);
    }

    public static List<DashboardBookingBean> getRecentBookings(String custID) {
        List<DashboardBookingBean> list = new ArrayList<DashboardBookingBean>();

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql =
                "SELECT * FROM ( " +
                "    SELECT TO_CHAR(b.BOOKINGDATE, 'DD/MM/YYYY') AS BOOKINGDATE, " +
                "           v.VEHICLEPLATENUM, " +
                "           p.PACKAGENAME, " +
                "           b.BOOKINGSTATUS, " +
                "           p.PACKAGEPRICE " +
                "    FROM BOOKING b " +
                "    JOIN VEHICLE v ON b.VEHICLEPLATENUM = v.VEHICLEPLATENUM " +
                "    JOIN PACKAGE p ON b.PACKAGEID = p.PACKAGEID " +
                "    WHERE v.CUSTID = ? " +
                "    ORDER BY b.BOOKINGDATE DESC, b.BOOKINGTIME DESC " +
                ") WHERE ROWNUM <= 5";

        try {
            con = ConnectionManager.getConnection();

            ps = con.prepareStatement(sql);
            ps.setString(1, custID);

            rs = ps.executeQuery();

            while (rs.next()) {
                DashboardBookingBean booking = new DashboardBookingBean();

                booking.setBookingDate(rs.getString("BOOKINGDATE"));
                booking.setVehiclePlateNum(rs.getString("VEHICLEPLATENUM"));
                booking.setPackageName(rs.getString("PACKAGENAME"));
                booking.setBookingStatus(rs.getString("BOOKINGSTATUS"));
                booking.setAmount(rs.getDouble("PACKAGEPRICE"));

                list.add(booking);
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(rs, ps, con);
        }

        return list;
    }

    private static void close(ResultSet rs, PreparedStatement ps, Connection con) {
        try {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            if (con != null) con.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}