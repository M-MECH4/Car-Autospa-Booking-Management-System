package vehicleBooking.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

import vehicleBooking.ConnectionManager;
import vehicleBooking.bean.BookingBean;
import vehicleBooking.bean.PackageBean;

public class BookingDAO {

    private static final int MAX_BOOKING_PER_DAY = 1;

    // =========================
    // CUSTOMER: CREATE BOOKING
    // =========================
    public static int createBooking(BookingBean booking) throws SQLException {

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String newBookingID = null;

        String getIdSql =
                "SELECT 'B' || LPAD(NVL(MAX(TO_NUMBER(SUBSTR(BOOKINGID, 2))), 0) + 1, 3, '0') AS NEWID " +
                "FROM BOOKING " +
                "WHERE REGEXP_LIKE(BOOKINGID, '^B[0-9]+$')";

        String insertSql =
                "INSERT INTO BOOKING " +
                "(BOOKINGID, VEHICLEPLATENUM, PACKAGEID, BOOKINGDATE, BOOKINGTIME, BOOKINGSTATUS, NOTIFICATIONSENT) " +
                "VALUES " +
                "(?, ?, ?, TO_DATE(?, 'YYYY-MM-DD'), TO_TIMESTAMP(? || ' ' || ?, 'YYYY-MM-DD HH24:MI'), 'BOOKED', 'N')";

        try {
            con = ConnectionManager.getConnection();

            ps = con.prepareStatement(getIdSql);
            rs = ps.executeQuery();

            if (rs.next()) {
                newBookingID = rs.getString("NEWID");
            }

            if (rs != null) {
                rs.close();
                rs = null;
            }

            if (ps != null) {
                ps.close();
                ps = null;
            }

            if (newBookingID == null || newBookingID.trim().isEmpty()) {
                newBookingID = "B001";
            }

            ps = con.prepareStatement(insertSql);

            ps.setString(1, newBookingID);
            ps.setString(2, booking.getVehiclePlateNum());
            ps.setString(3, booking.getPackageID());
            ps.setString(4, booking.getBookingDate());
            ps.setString(5, booking.getBookingDate());
            ps.setString(6, booking.getBookingTime());

            System.out.println("========== CREATE BOOKING DEBUG ==========");
            System.out.println("NEW BOOKINGID = " + newBookingID);
            System.out.println("VEHICLE = " + booking.getVehiclePlateNum());
            System.out.println("PACKAGE = " + booking.getPackageID());
            System.out.println("DATE = " + booking.getBookingDate());
            System.out.println("TIME = " + booking.getBookingTime());
            System.out.println("==========================================");

            int row = ps.executeUpdate();

            if (!con.getAutoCommit()) {
                con.commit();
            }

            System.out.println("INSERT BOOKING ROW = " + row);

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
    // CUSTOMER: VIEW OWN BOOKING
    // =========================
    public static ArrayList<BookingBean> getBookingByCustomer(String custID) throws SQLException {

        ArrayList<BookingBean> bookingList = new ArrayList<BookingBean>();

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql =
                "SELECT b.BOOKINGID, " +
                "TO_CHAR(b.BOOKINGDATE, 'YYYY-MM-DD') AS BOOKINGDATE, " +
                "TO_CHAR(b.BOOKINGTIME, 'HH24:MI') AS BOOKINGTIMEONLY, " +
                "b.BOOKINGSTATUS, " +
                "b.PACKAGEID, " +
                "p.PACKAGENAME, " +
                "p.PACKAGEPRICE, " +
                "v.VEHICLEPLATENUM, " +
                "v.VEHICLEBRAND, " +
                "v.VEHICLEMODEL, " +
                "v.VEHICLEYEAR, " +
                "NVL(b.NOTIFICATIONSENT, 'N') AS NOTIFICATIONSENT " +
                "FROM BOOKING b " +
                "INNER JOIN VEHICLE v ON b.VEHICLEPLATENUM = v.VEHICLEPLATENUM " +
                "INNER JOIN CUSTOMER c ON v.CUSTID = c.CUSTID " +
                "INNER JOIN PACKAGE p ON b.PACKAGEID = p.PACKAGEID " +
                "WHERE c.CUSTID = ? " +
                "ORDER BY b.BOOKINGDATE DESC, b.BOOKINGTIME DESC";

        try {
            con = ConnectionManager.getConnection();

            ps = con.prepareStatement(sql);
            ps.setString(1, custID);

            rs = ps.executeQuery();

            while (rs.next()) {
                BookingBean booking = new BookingBean();

                booking.setBookingID(rs.getString("BOOKINGID"));
                booking.setBookingDate(rs.getString("BOOKINGDATE"));
                booking.setBookingTime(rs.getString("BOOKINGTIMEONLY"));
                booking.setBookingStatus(rs.getString("BOOKINGSTATUS"));

                booking.setPackageID(rs.getString("PACKAGEID"));
                booking.setPackageName(rs.getString("PACKAGENAME"));
                booking.setPackagePrice(rs.getDouble("PACKAGEPRICE"));

                booking.setVehiclePlateNum(rs.getString("VEHICLEPLATENUM"));
                booking.setVehicleBrand(rs.getString("VEHICLEBRAND"));
                booking.setVehicleModel(rs.getString("VEHICLEMODEL"));
                booking.setVehicleYear(rs.getInt("VEHICLEYEAR"));

                booking.setNotificationSent(rs.getString("NOTIFICATIONSENT"));

                bookingList.add(booking);
            }

            return bookingList;

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
    // CUSTOMER: UPDATE BOOKING
    // =========================
    public static int updateBooking(BookingBean booking, String custID) throws SQLException {

        Connection con = null;
        PreparedStatement ps = null;

        String sql =
                "UPDATE BOOKING b " +
                "SET b.BOOKINGDATE = TO_DATE(?, 'YYYY-MM-DD'), " +
                "b.BOOKINGTIME = TO_TIMESTAMP(? || ' ' || ?, 'YYYY-MM-DD HH24:MI'), " +
                "b.PACKAGEID = ?, " +
                "b.VEHICLEPLATENUM = ? " +
                "WHERE b.BOOKINGID = ? " +
                "AND UPPER(b.BOOKINGSTATUS) = 'BOOKED' " +
                "AND EXISTS ( " +
                "    SELECT 1 " +
                "    FROM VEHICLE oldv " +
                "    INNER JOIN CUSTOMER oldc ON oldv.CUSTID = oldc.CUSTID " +
                "    WHERE oldv.VEHICLEPLATENUM = b.VEHICLEPLATENUM " +
                "    AND oldc.CUSTID = ? " +
                ") " +
                "AND EXISTS ( " +
                "    SELECT 1 " +
                "    FROM VEHICLE newv " +
                "    INNER JOIN CUSTOMER newc ON newv.CUSTID = newc.CUSTID " +
                "    WHERE newv.VEHICLEPLATENUM = ? " +
                "    AND newc.CUSTID = ? " +
                ")";

        try {
            con = ConnectionManager.getConnection();

            ps = con.prepareStatement(sql);

            ps.setString(1, booking.getBookingDate());
            ps.setString(2, booking.getBookingDate());
            ps.setString(3, booking.getBookingTime());
            ps.setString(4, booking.getPackageID());
            ps.setString(5, booking.getVehiclePlateNum());
            ps.setString(6, booking.getBookingID());
            ps.setString(7, custID);
            ps.setString(8, booking.getVehiclePlateNum());
            ps.setString(9, custID);

            int row = ps.executeUpdate();

            if (!con.getAutoCommit()) {
                con.commit();
            }

            return row;

        } finally {
            if (ps != null) {
                ps.close();
            }

            if (con != null) {
                con.close();
            }
        }
    }

    // =========================
    // CUSTOMER: DELETE BOOKING
    // =========================
    public static int deleteBooking(String bookingID, String custID) throws SQLException {

        Connection con = null;
        PreparedStatement ps = null;

        String sql =
                "DELETE FROM BOOKING b " +
                "WHERE b.BOOKINGID = ? " +
                "AND UPPER(b.BOOKINGSTATUS) = 'BOOKED' " +
                "AND EXISTS ( " +
                "    SELECT 1 " +
                "    FROM VEHICLE v " +
                "    INNER JOIN CUSTOMER c ON v.CUSTID = c.CUSTID " +
                "    WHERE v.VEHICLEPLATENUM = b.VEHICLEPLATENUM " +
                "    AND c.CUSTID = ? " +
                ")";

        try {
            con = ConnectionManager.getConnection();

            ps = con.prepareStatement(sql);
            ps.setString(1, bookingID);
            ps.setString(2, custID);

            int row = ps.executeUpdate();

            if (!con.getAutoCommit()) {
                con.commit();
            }

            return row;

        } finally {
            if (ps != null) {
                ps.close();
            }

            if (con != null) {
                con.close();
            }
        }
    }

    // =========================
    // PACKAGE LIST
    // =========================
    public static ArrayList<PackageBean> getPackageList() throws SQLException {

        ArrayList<PackageBean> packageList = new ArrayList<PackageBean>();

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql =
                "SELECT PACKAGEID, PACKAGENAME, PACKAGEPRICE, PACKAGEDESC " +
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

                packageList.add(p);
            }

            return packageList;

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
    // GET UNAVAILABLE DATE LIST
    // =========================
    public static ArrayList<String> getUnavailableDateList() throws SQLException {

        ArrayList<String> unavailableDateList = new ArrayList<String>();

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql =
                "SELECT TO_CHAR(TRUNC(BOOKINGDATE), 'YYYY-MM-DD') AS UNAVAILABLE_DATE " +
                "FROM BOOKING " +
                "WHERE UPPER(BOOKINGSTATUS) IN ('BOOKED', 'IN PROGRESS') " +
                "GROUP BY TRUNC(BOOKINGDATE) " +
                "HAVING COUNT(*) >= ? " +
                "ORDER BY TRUNC(BOOKINGDATE)";

        try {
            con = ConnectionManager.getConnection();

            ps = con.prepareStatement(sql);
            ps.setInt(1, MAX_BOOKING_PER_DAY);

            rs = ps.executeQuery();

            while (rs.next()) {
                unavailableDateList.add(rs.getString("UNAVAILABLE_DATE"));
            }

            return unavailableDateList;

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
    // CHECK DATE AVAILABLE FOR CREATE
    // =========================
    public static boolean isDateAvailableForCreate(String bookingDate) throws SQLException {

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql =
                "SELECT COUNT(*) AS TOTAL_BOOKING " +
                "FROM BOOKING " +
                "WHERE TRUNC(BOOKINGDATE) = TO_DATE(?, 'YYYY-MM-DD') " +
                "AND UPPER(BOOKINGSTATUS) IN ('BOOKED', 'IN PROGRESS')";

        try {
            con = ConnectionManager.getConnection();

            ps = con.prepareStatement(sql);
            ps.setString(1, bookingDate);

            rs = ps.executeQuery();

            if (rs.next()) {
                int total = rs.getInt("TOTAL_BOOKING");
                return total < MAX_BOOKING_PER_DAY;
            }

            return false;

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
    // CHECK DATE AVAILABLE FOR UPDATE
    // =========================
    public static boolean isDateAvailableForUpdate(String bookingDate, String bookingID) throws SQLException {

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql =
                "SELECT COUNT(*) AS TOTAL_BOOKING " +
                "FROM BOOKING " +
                "WHERE TRUNC(BOOKINGDATE) = TO_DATE(?, 'YYYY-MM-DD') " +
                "AND UPPER(BOOKINGSTATUS) IN ('BOOKED', 'IN PROGRESS') " +
                "AND BOOKINGID <> ?";

        try {
            con = ConnectionManager.getConnection();

            ps = con.prepareStatement(sql);
            ps.setString(1, bookingDate);
            ps.setString(2, bookingID);

            rs = ps.executeQuery();

            if (rs.next()) {
                int total = rs.getInt("TOTAL_BOOKING");
                return total < MAX_BOOKING_PER_DAY;
            }

            return false;

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
    // CHECK DATE TIME AVAILABLE FOR CREATE
    // Important: no status filter because BOOKINGTIME has unique constraint.
    // =========================
    public static boolean isDateTimeAvailableForCreate(String bookingDate, String bookingTime) throws SQLException {

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql =
                "SELECT COUNT(*) AS TOTAL_BOOKING " +
                "FROM BOOKING " +
                "WHERE BOOKINGTIME = TO_TIMESTAMP(? || ' ' || ?, 'YYYY-MM-DD HH24:MI')";

        try {
            con = ConnectionManager.getConnection();

            ps = con.prepareStatement(sql);
            ps.setString(1, bookingDate);
            ps.setString(2, bookingTime);

            rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt("TOTAL_BOOKING") == 0;
            }

            return false;

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
    // CHECK DATE TIME AVAILABLE FOR UPDATE
    // Important: no status filter because BOOKINGTIME has unique constraint.
    // =========================
    public static boolean isDateTimeAvailableForUpdate(String bookingDate, String bookingTime, String bookingID)
            throws SQLException {

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql =
                "SELECT COUNT(*) AS TOTAL_BOOKING " +
                "FROM BOOKING " +
                "WHERE BOOKINGTIME = TO_TIMESTAMP(? || ' ' || ?, 'YYYY-MM-DD HH24:MI') " +
                "AND BOOKINGID <> ?";

        try {
            con = ConnectionManager.getConnection();

            ps = con.prepareStatement(sql);
            ps.setString(1, bookingDate);
            ps.setString(2, bookingTime);
            ps.setString(3, bookingID);

            rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt("TOTAL_BOOKING") == 0;
            }

            return false;

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
    // CHECK VEHICLE BELONGS TO CUSTOMER
    // =========================
    public static boolean isCustomerVehicle(String vehiclePlateNum, String custID) throws SQLException {

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql =
                "SELECT v.VEHICLEPLATENUM " +
                "FROM VEHICLE v " +
                "INNER JOIN CUSTOMER c ON v.CUSTID = c.CUSTID " +
                "WHERE v.VEHICLEPLATENUM = ? " +
                "AND c.CUSTID = ?";

        try {
            con = ConnectionManager.getConnection();

            ps = con.prepareStatement(sql);
            ps.setString(1, vehiclePlateNum);
            ps.setString(2, custID);

            rs = ps.executeQuery();

            return rs.next();

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
    // STAFF: VIEW ALL BOOKINGS
    // =========================
    public static ArrayList<BookingBean> getAllBookingsForStaff() throws SQLException {

        ArrayList<BookingBean> bookingList = new ArrayList<BookingBean>();

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql =
                "SELECT b.BOOKINGID, " +
                "TO_CHAR(b.BOOKINGDATE, 'YYYY-MM-DD') AS BOOKINGDATE, " +
                "TO_CHAR(b.BOOKINGTIME, 'HH24:MI') AS BOOKINGTIMEONLY, " +
                "b.BOOKINGSTATUS, " +
                "b.PACKAGEID, " +
                "NVL(b.NOTIFICATIONSENT, 'N') AS NOTIFICATIONSENT, " +
                "p.PACKAGENAME, " +
                "p.PACKAGEPRICE, " +
                "v.VEHICLEPLATENUM, " +
                "v.VEHICLEBRAND, " +
                "v.VEHICLEMODEL, " +
                "v.VEHICLEYEAR, " +
                "c.CUSTID, " +
                "c.CUSTNAME, " +
                "c.CUSTUSERNAME, " +
                "c.CUSTEMAIL, " +
                "c.CUSTPHONENUM " +
                "FROM BOOKING b " +
                "INNER JOIN VEHICLE v ON b.VEHICLEPLATENUM = v.VEHICLEPLATENUM " +
                "INNER JOIN CUSTOMER c ON v.CUSTID = c.CUSTID " +
                "INNER JOIN PACKAGE p ON b.PACKAGEID = p.PACKAGEID " +
                "ORDER BY b.BOOKINGDATE DESC, b.BOOKINGTIME DESC";

        try {
            con = ConnectionManager.getConnection();

            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                BookingBean booking = new BookingBean();

                booking.setBookingID(rs.getString("BOOKINGID"));
                booking.setBookingDate(rs.getString("BOOKINGDATE"));
                booking.setBookingTime(rs.getString("BOOKINGTIMEONLY"));
                booking.setBookingStatus(rs.getString("BOOKINGSTATUS"));

                booking.setPackageID(rs.getString("PACKAGEID"));
                booking.setPackageName(rs.getString("PACKAGENAME"));
                booking.setPackagePrice(rs.getDouble("PACKAGEPRICE"));

                booking.setVehiclePlateNum(rs.getString("VEHICLEPLATENUM"));
                booking.setVehicleBrand(rs.getString("VEHICLEBRAND"));
                booking.setVehicleModel(rs.getString("VEHICLEMODEL"));
                booking.setVehicleYear(rs.getInt("VEHICLEYEAR"));

                booking.setCustID(rs.getString("CUSTID"));
                booking.setCustName(rs.getString("CUSTNAME"));
                booking.setCustUsername(rs.getString("CUSTUSERNAME"));
                booking.setCustEmail(rs.getString("CUSTEMAIL"));
                booking.setCustPhoneNum(rs.getString("CUSTPHONENUM"));

                booking.setNotificationSent(rs.getString("NOTIFICATIONSENT"));

                bookingList.add(booking);
            }

            return bookingList;

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
    // STAFF: UPDATE SERVICE PROGRESS
    // This will also save which staff handled the booking.
    // Notification will NOT automatically become Sent.
    // Sent only happens when staff clicks Send.
    // =========================
    public static int updateServiceProgress(String bookingID, String bookingStatus, String staffID) throws SQLException {

        Connection con = null;
        PreparedStatement ps = null;

        bookingStatus = normalizeStatus(bookingStatus);

        String sql;

        if ("COMPLETED".equalsIgnoreCase(bookingStatus)) {
            sql =
                    "UPDATE BOOKING " +
                    "SET BOOKINGSTATUS = ?, " +
                    "STAFFID = ? " +
                    "WHERE BOOKINGID = ? " +
                    "AND UPPER(BOOKINGSTATUS) IN ('BOOKED', 'IN PROGRESS')";
        } else if ("IN PROGRESS".equalsIgnoreCase(bookingStatus)) {
            sql =
                    "UPDATE BOOKING " +
                    "SET BOOKINGSTATUS = ?, " +
                    "STAFFID = ? " +
                    "WHERE BOOKINGID = ? " +
                    "AND UPPER(BOOKINGSTATUS) = 'BOOKED'";
        } else {
            sql =
                    "UPDATE BOOKING " +
                    "SET BOOKINGSTATUS = ?, " +
                    "STAFFID = ? " +
                    "WHERE BOOKINGID = ? " +
                    "AND UPPER(BOOKINGSTATUS) = 'BOOKED'";
        }

        try {
            con = ConnectionManager.getConnection();

            ps = con.prepareStatement(sql);
            ps.setString(1, bookingStatus);
            ps.setString(2, staffID);
            ps.setString(3, bookingID);

            int row = ps.executeUpdate();

            if (!con.getAutoCommit()) {
                con.commit();
            }

            System.out.println("UPDATE PROGRESS ROW = " + row);
            System.out.println("BOOKING ID = " + bookingID);
            System.out.println("NEW STATUS = " + bookingStatus);
            System.out.println("UPDATED BY STAFFID = " + staffID);

            return row;

        } finally {
            if (ps != null) {
                ps.close();
            }

            if (con != null) {
                con.close();
            }
        }
    }

    // =========================
    // STAFF: MANUAL SEND NOTIFICATION
    // =========================
    public static int sendNotification(String bookingID, String notificationMessage) throws SQLException {

        Connection con = null;
        PreparedStatement ps = null;

        String sql =
                "UPDATE BOOKING " +
                "SET NOTIFICATIONSENT = 'Y' " +
                "WHERE BOOKINGID = ?";

        try {
            con = ConnectionManager.getConnection();

            ps = con.prepareStatement(sql);
            ps.setString(1, bookingID);

            int row = ps.executeUpdate();

            if (!con.getAutoCommit()) {
                con.commit();
            }

            System.out.println("SEND NOTIFICATION ROW = " + row);
            System.out.println("BOOKING ID = " + bookingID);

            return row;

        } finally {
            if (ps != null) {
                ps.close();
            }

            if (con != null) {
                con.close();
            }
        }
    }

    private static String normalizeStatus(String status) {

        if (status == null) {
            return "BOOKED";
        }

        status = status.trim().toUpperCase();

        if ("BOOKED".equals(status)) {
            return "BOOKED";
        }

        if ("IN_PROGRESS".equals(status)) {
            return "IN PROGRESS";
        }

        if ("IN PROGRESS".equals(status)) {
            return "IN PROGRESS";
        }

        if ("COMPLETED".equals(status)) {
            return "COMPLETED";
        }

        return "BOOKED";
    }
}