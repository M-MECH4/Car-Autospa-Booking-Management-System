package vehicleBooking.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;

import vehicleBooking.ConnectionManager;
import vehicleBooking.bean.BookingBean;
import vehicleBooking.bean.PackageBean;
import vehicleBooking.bean.CustomerBean;

public class ReportDAO {

    public static ArrayList<BookingBean> getAllBookings(String period) {

        ArrayList<BookingBean> list = new ArrayList<BookingBean>();

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String dateFilter = "";

        if ("weekly".equalsIgnoreCase(period)) {
            dateFilter =
                    "WHERE b.BOOKINGDATE >= TRUNC(SYSDATE, 'IW') " +
                    "AND b.BOOKINGDATE < TRUNC(SYSDATE, 'IW') + 7 ";
        } else if ("monthly".equalsIgnoreCase(period)) {
            dateFilter =
                    "WHERE b.BOOKINGDATE >= TRUNC(SYSDATE, 'MM') " +
                    "AND b.BOOKINGDATE < ADD_MONTHS(TRUNC(SYSDATE, 'MM'), 1) ";
        }

        String sql =
                "SELECT b.BOOKINGID, " +
                "TO_CHAR(b.BOOKINGDATE, 'YYYY-MM-DD') AS BOOKINGDATE, " +
                "TO_CHAR(b.BOOKINGTIME, 'HH24:MI') AS BOOKINGTIME, " +
                "b.BOOKINGSTATUS, " +
                "b.PACKAGEID, " +
                "p.PACKAGENAME, " +
                "p.PACKAGEPRICE, " +
                "b.VEHICLEPLATENUM, " +
                "v.VEHICLEBRAND, " +
                "v.VEHICLEMODEL, " +
                "v.VEHICLEYEAR, " +
                "c.CUSTID, " +
                "c.CUSTNAME, " +
                "c.CUSTUSERNAME, " +
                "c.CUSTEMAIL, " +
                "c.CUSTPHONENUM " +
                "FROM BOOKING b " +
                "JOIN VEHICLE v ON b.VEHICLEPLATENUM = v.VEHICLEPLATENUM " +
                "JOIN CUSTOMER c ON v.CUSTID = c.CUSTID " +
                "JOIN PACKAGE p ON b.PACKAGEID = p.PACKAGEID " +
                dateFilter +
                "ORDER BY b.BOOKINGDATE DESC, b.BOOKINGTIME DESC";

        try {
            con = ConnectionManager.getConnection();
            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                BookingBean b = new BookingBean();

                b.setBookingID(rs.getString("BOOKINGID"));
                b.setBookingDate(rs.getString("BOOKINGDATE"));
                b.setBookingTime(rs.getString("BOOKINGTIME"));
                b.setBookingStatus(rs.getString("BOOKINGSTATUS"));

                b.setPackageID(rs.getString("PACKAGEID"));
                b.setPackageName(rs.getString("PACKAGENAME"));
                b.setPackagePrice(rs.getDouble("PACKAGEPRICE"));

                b.setVehiclePlateNum(rs.getString("VEHICLEPLATENUM"));
                b.setVehicleBrand(rs.getString("VEHICLEBRAND"));
                b.setVehicleModel(rs.getString("VEHICLEMODEL"));
                b.setVehicleYear(rs.getInt("VEHICLEYEAR"));

                b.setCustID(rs.getString("CUSTID"));
                b.setCustName(rs.getString("CUSTNAME"));
                b.setCustUsername(rs.getString("CUSTUSERNAME"));
                b.setCustEmail(rs.getString("CUSTEMAIL"));
                b.setCustPhoneNum(rs.getString("CUSTPHONENUM"));

                list.add(b);
            }

        } catch (Exception e) {
            e.printStackTrace();

        } finally {
            close(rs, ps, con);
        }

        return list;
    }

    public static ArrayList<PackageBean> getAllPackages() {

        ArrayList<PackageBean> list = new ArrayList<PackageBean>();

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql =
                "SELECT PACKAGEID, PACKAGENAME, PACKAGEPRICE, PACKAGEDESC, SERVICENAME, PACKAGESTATUS " +
                "FROM PACKAGE " +
                "ORDER BY PACKAGEID";

        try {
            con = ConnectionManager.getConnection();
            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                PackageBean p = new PackageBean();

                p.setPackageID(rs.getString("PACKAGEID"));
                p.setPackageName(rs.getString("PACKAGENAME"));
                p.setPackagePrice(rs.getDouble("PACKAGEPRICE"));
                p.setPackageDesc(rs.getString("PACKAGEDESC"));
                p.setServiceName(rs.getString("SERVICENAME"));
                p.setPackageStatus(rs.getString("PACKAGESTATUS"));

                list.add(p);
            }

        } catch (Exception e) {
            e.printStackTrace();

        } finally {
            close(rs, ps, con);
        }

        return list;
    }

    public static ArrayList<CustomerBean> getAllCustomers() {

        ArrayList<CustomerBean> list = new ArrayList<CustomerBean>();

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql =
                "SELECT CUSTID, CUSTNAME, CUSTEMAIL, CUSTUSERNAME, CUSTPASSWORD, " +
                "CUSTPHONENUM, CUSTRACE, CUSTRELIGION " +
                "FROM CUSTOMER " +
                "ORDER BY CUSTID";

        try {
            con = ConnectionManager.getConnection();
            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                CustomerBean c = new CustomerBean();

                c.setCustID(rs.getString("CUSTID"));
                c.setCustName(rs.getString("CUSTNAME"));
                c.setCustEmail(rs.getString("CUSTEMAIL"));
                c.setCustUsername(rs.getString("CUSTUSERNAME"));
                c.setCustPassword(rs.getString("CUSTPASSWORD"));
                c.setCustPhoneNum(rs.getString("CUSTPHONENUM"));
                c.setCustRace(rs.getString("CUSTRACE"));
                c.setCustReligion(rs.getString("CUSTRELIGION"));

                list.add(c);
            }

        } catch (Exception e) {
            e.printStackTrace();

        } finally {
            close(rs, ps, con);
        }

        return list;
    }


    public static int getTotalReports() {
        int totalReports = 0;

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql =
                "SELECT COUNT(*) AS TOTALREPORTS " +
                "FROM BOOKING";

        try {
            con = ConnectionManager.getConnection();

            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();

            if (rs.next()) {
                totalReports = rs.getInt("TOTALREPORTS");
            }

        } catch (Exception e) {
            e.printStackTrace();

        } finally {
            close(rs, ps, con);
        }

        return totalReports;
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