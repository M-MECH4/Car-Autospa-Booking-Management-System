package vehicleBooking.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import vehicleBooking.ConnectionManager;
import vehicleBooking.bean.StaffDashboardBookingBean;

public class StaffDashboardDAO {

    public static int getTodayBookings() {
        int total = 0;

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql =
                "SELECT COUNT(*) AS TOTAL " +
                "FROM BOOKING " +
                "WHERE TRUNC(BOOKINGDATE) = TRUNC(SYSDATE)";

        try {
            con = ConnectionManager.getConnection();
            ps = con.prepareStatement(sql);
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

    public static int getYesterdayBookings() {
        int total = 0;

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql =
                "SELECT COUNT(*) AS TOTAL " +
                "FROM BOOKING " +
                "WHERE TRUNC(BOOKINGDATE) = TRUNC(SYSDATE - 1)";

        try {
            con = ConnectionManager.getConnection();
            ps = con.prepareStatement(sql);
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

    public static int getVehiclesServicedThisMonth() {
        int total = 0;

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql =
                "SELECT COUNT(*) AS TOTAL " +
                "FROM BOOKING " +
                "WHERE UPPER(BOOKINGSTATUS) = 'COMPLETED' " +
                "AND TRUNC(BOOKINGDATE, 'MM') = TRUNC(SYSDATE, 'MM')";

        try {
            con = ConnectionManager.getConnection();
            ps = con.prepareStatement(sql);
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

    public static double getRevenueThisWeek() {
        double total = 0.0;

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql =
                "SELECT NVL(SUM(p.PACKAGEPRICE), 0) AS TOTAL " +
                "FROM BOOKING b " +
                "JOIN PACKAGE p ON b.PACKAGEID = p.PACKAGEID " +
                "WHERE UPPER(b.BOOKINGSTATUS) = 'COMPLETED' " +
                "AND TRUNC(b.BOOKINGDATE) >= TRUNC(SYSDATE, 'IW') " +
                "AND TRUNC(b.BOOKINGDATE) < TRUNC(SYSDATE, 'IW') + 7";

        try {
            con = ConnectionManager.getConnection();
            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();

            if (rs.next()) {
                total = rs.getDouble("TOTAL");
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(rs, ps, con);
        }

        return total;
    }

    public static List<StaffDashboardBookingBean> getRecentBookings() {
        List<StaffDashboardBookingBean> list = new ArrayList<StaffDashboardBookingBean>();

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql =
                "SELECT * FROM ( " +
                "    SELECT b.BOOKINGID, " +
                "           TO_CHAR(b.BOOKINGDATE, 'DD/MM/YYYY') AS BOOKINGDATE, " +
                "           TO_CHAR(b.BOOKINGTIME, 'HH24:MI') AS BOOKINGTIME, " +
                "           b.BOOKINGSTATUS, " +
                "           c.CUSTNAME, " +
                "           v.VEHICLEPLATENUM, " +
                "           v.VEHICLEBRAND, " +
                "           v.VEHICLEMODEL, " +
                "           p.PACKAGENAME " +
                "    FROM BOOKING b " +
                "    JOIN VEHICLE v ON b.VEHICLEPLATENUM = v.VEHICLEPLATENUM " +
                "    JOIN CUSTOMER c ON v.CUSTID = c.CUSTID " +
                "    JOIN PACKAGE p ON b.PACKAGEID = p.PACKAGEID " +
                "    ORDER BY b.BOOKINGDATE DESC, b.BOOKINGTIME DESC " +
                ") WHERE ROWNUM <= 5";

        try {
            con = ConnectionManager.getConnection();
            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                StaffDashboardBookingBean b = new StaffDashboardBookingBean();

                b.setBookingID(rs.getString("BOOKINGID"));
                b.setBookingDate(rs.getString("BOOKINGDATE"));
                b.setBookingTime(rs.getString("BOOKINGTIME"));
                b.setBookingStatus(rs.getString("BOOKINGSTATUS"));
                b.setCustomerName(rs.getString("CUSTNAME"));
                b.setVehiclePlateNum(rs.getString("VEHICLEPLATENUM"));
                b.setVehicleBrand(rs.getString("VEHICLEBRAND"));
                b.setVehicleModel(rs.getString("VEHICLEMODEL"));
                b.setPackageName(rs.getString("PACKAGENAME"));

                list.add(b);
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