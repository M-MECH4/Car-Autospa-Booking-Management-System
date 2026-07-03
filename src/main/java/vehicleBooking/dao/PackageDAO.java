package vehicleBooking.dao;

import java.sql.*;
import java.util.ArrayList;

import vehicleBooking.ConnectionManager;
import vehicleBooking.bean.*;

public class PackageDAO {

    private static PackageBean mapPackage(ResultSet rs) throws SQLException {

        PackageBean p;

        if (rs.getString("FESTIVALNAME") != null) {
            FestivalBean f = new FestivalBean();
            f.setFestivalName(rs.getString("FESTIVALNAME"));
            f.setStartDate(rs.getString("STARTDATE"));
            f.setEndDate(rs.getString("ENDDATE"));
            f.setDiscountRate(rs.getDouble("DISCOUNTRATE"));
            p = f;

        } else if (rs.getString("ENTRYMETHOD") != null) {
            RoutineBean r = new RoutineBean();
            r.setEntryMethod(rs.getString("ENTRYMETHOD"));
            p = r;

        } else {
            p = new PackageBean();
        }

        p.setPackageID(rs.getString("PACKAGEID"));
        p.setPackageName(rs.getString("PACKAGENAME"));
        p.setPackagePrice(rs.getDouble("PACKAGEPRICE"));
        p.setPackageDesc(rs.getString("PACKAGEDESC"));
        p.setServiceName(rs.getString("SERVICENAME"));
        p.setPackageStatus(rs.getString("PACKAGESTATUS"));

        return p;
    }

    public static ArrayList<PackageBean> getAllPackage() {

        ArrayList<PackageBean> list = new ArrayList<>();

        String sql =
            "SELECT p.PACKAGEID, p.PACKAGENAME, p.PACKAGEPRICE, p.PACKAGEDESC, p.SERVICENAME, p.PACKAGESTATUS, " +
            "r.ENTRYMETHOD, f.FESTIVALNAME, f.STARTDATE, f.ENDDATE, f.DISCOUNTRATE " +
            "FROM PACKAGE p " +
            "LEFT JOIN ROUTINE r ON p.PACKAGEID = r.PACKAGEID " +
            "LEFT JOIN FESTIVE f ON p.PACKAGEID = f.PACKAGEID " +
            "ORDER BY p.PACKAGESTATUS, p.PACKAGEID";

        try {
            Connection con = ConnectionManager.getConnection();
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapPackage(rs));
            }

            rs.close();
            ps.close();
            con.close();

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public static ArrayList<PackageBean> getCustomerPackage() {

        ArrayList<PackageBean> list = new ArrayList<>();

        String sql =
        	    "SELECT p.PACKAGEID, p.PACKAGENAME, p.PACKAGEPRICE, p.PACKAGEDESC, p.SERVICENAME, p.PACKAGESTATUS, " +
        	    "r.ENTRYMETHOD, f.FESTIVALNAME, f.STARTDATE, f.ENDDATE, f.DISCOUNTRATE " +
        	    "FROM PACKAGE p " +
        	    "LEFT JOIN ROUTINE r ON p.PACKAGEID = r.PACKAGEID " +
        	    "LEFT JOIN FESTIVE f ON p.PACKAGEID = f.PACKAGEID " +
        	    "WHERE NVL(p.PACKAGESTATUS, 'AVAILABLE') = 'AVAILABLE' " +
        	    "AND (f.PACKAGEID IS NULL OR f.ENDDATE >= TRUNC(SYSDATE)) " +
        	    "ORDER BY p.PACKAGEID";

        try {
            Connection con = ConnectionManager.getConnection();
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapPackage(rs));
            }

            rs.close();
            ps.close();
            con.close();

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public static PackageBean getPackageById(String packageID) {

        PackageBean p = null;

        String sql =
            "SELECT p.PACKAGEID, p.PACKAGENAME, p.PACKAGEPRICE, p.PACKAGEDESC, p.SERVICENAME, p.PACKAGESTATUS, " +
            "r.ENTRYMETHOD, f.FESTIVALNAME, f.STARTDATE, f.ENDDATE, f.DISCOUNTRATE " +
            "FROM PACKAGE p " +
            "LEFT JOIN ROUTINE r ON p.PACKAGEID = r.PACKAGEID " +
            "LEFT JOIN FESTIVE f ON p.PACKAGEID = f.PACKAGEID " +
            "WHERE p.PACKAGEID=?";

        try {
            Connection con = ConnectionManager.getConnection();
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, packageID);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                p = mapPackage(rs);
            }

            rs.close();
            ps.close();
            con.close();

        } catch (Exception e) {
            e.printStackTrace();
        }

        return p;
    }

    public static void addRoutine(RoutineBean p) throws SQLException {

        Connection con = ConnectionManager.getConnection();

        String packageID;

        CallableStatement cs = con.prepareCall(
            "BEGIN " +
            "INSERT INTO PACKAGE (PACKAGENAME, PACKAGEPRICE, PACKAGEDESC, SERVICENAME, PACKAGESTATUS) " +
            "VALUES (?, ?, ?, ?, 'AVAILABLE') RETURNING PACKAGEID INTO ?; " +
            "END;"
        );

        cs.setString(1, p.getPackageName());
        cs.setDouble(2, p.getPackagePrice());
        cs.setString(3, p.getPackageDesc());
        cs.setString(4, p.getServiceName());
        cs.registerOutParameter(5, Types.VARCHAR);
        cs.execute();

        packageID = cs.getString(5);

        PreparedStatement ps2 = con.prepareStatement(
            "INSERT INTO ROUTINE (PACKAGEID, ENTRYMETHOD) VALUES (?, ?)"
        );

        ps2.setString(1, packageID);
        ps2.setString(2, p.getEntryMethod());
        ps2.executeUpdate();

        cs.close();
        ps2.close();
        con.close();
    }

    public static void addFestive(FestivalBean p) throws SQLException {

        Connection con = null;
        CallableStatement cs = null;
        PreparedStatement ps2 = null;

        try {
            con = ConnectionManager.getConnection();

            cs = con.prepareCall(
                "BEGIN " +
                "INSERT INTO PACKAGE (PACKAGENAME, PACKAGEPRICE, PACKAGEDESC, SERVICENAME, PACKAGESTATUS) " +
                "VALUES (?, ?, ?, ?, 'AVAILABLE') RETURNING PACKAGEID INTO ?; " +
                "END;"
            );

            cs.setString(1, p.getPackageName());
            cs.setDouble(2, p.getPackagePrice());
            cs.setString(3, p.getPackageDesc());
            cs.setString(4, p.getServiceName());
            cs.registerOutParameter(5, Types.VARCHAR);

            cs.execute();

            String packageID = cs.getString(5);

            ps2 = con.prepareStatement(
                "INSERT INTO FESTIVE (PACKAGEID, FESTIVALNAME, STARTDATE, ENDDATE, DISCOUNTRATE) " +
                "VALUES (?, ?, TO_DATE(?, 'YYYY-MM-DD'), TO_DATE(?, 'YYYY-MM-DD'), ?)"
            );

            ps2.setString(1, packageID);
            ps2.setString(2, p.getFestivalName());
            ps2.setString(3, p.getStartDate());
            ps2.setString(4, p.getEndDate());
            ps2.setDouble(5, p.getDiscountRate());

            ps2.executeUpdate();

            if (!con.getAutoCommit()) {
                con.commit();
            }

        } finally {
            if (ps2 != null) ps2.close();
            if (cs != null) cs.close();
            if (con != null) con.close();
        }
    }

    public static void updateRoutine(RoutineBean p) throws SQLException {

        Connection con = ConnectionManager.getConnection();

        PreparedStatement ps1 = con.prepareStatement(
            "UPDATE PACKAGE SET PACKAGENAME=?, PACKAGEPRICE=?, PACKAGEDESC=?, SERVICENAME=?, PACKAGESTATUS='AVAILABLE' WHERE PACKAGEID=?"
        );

        ps1.setString(1, p.getPackageName());
        ps1.setDouble(2, p.getPackagePrice());
        ps1.setString(3, p.getPackageDesc());
        ps1.setString(4, p.getServiceName());
        ps1.setString(5, p.getPackageID());
        ps1.executeUpdate();

        PreparedStatement psDeleteFestive = con.prepareStatement(
            "DELETE FROM FESTIVE WHERE PACKAGEID=?"
        );
        psDeleteFestive.setString(1, p.getPackageID());
        psDeleteFestive.executeUpdate();

        PreparedStatement ps2 = con.prepareStatement(
            "UPDATE ROUTINE SET ENTRYMETHOD=? WHERE PACKAGEID=?"
        );

        ps2.setString(1, p.getEntryMethod());
        ps2.setString(2, p.getPackageID());

        int row = ps2.executeUpdate();

        if (row == 0) {
            PreparedStatement ps3 = con.prepareStatement(
                "INSERT INTO ROUTINE (PACKAGEID, ENTRYMETHOD) VALUES (?, ?)"
            );

            ps3.setString(1, p.getPackageID());
            ps3.setString(2, p.getEntryMethod());
            ps3.executeUpdate();
            ps3.close();
        }

        ps1.close();
        psDeleteFestive.close();
        ps2.close();
        con.close();
    }

    public static void updateFestive(FestivalBean p) throws SQLException {

        Connection con = ConnectionManager.getConnection();

        PreparedStatement ps1 = con.prepareStatement(
        		"UPDATE FESTIVE SET FESTIVALNAME=?, STARTDATE=TO_DATE(?, 'YYYY-MM-DD'), ENDDATE=TO_DATE(?, 'YYYY-MM-DD'), DISCOUNTRATE=? WHERE PACKAGEID=?"
        );

        ps1.setString(1, p.getPackageName());
        ps1.setDouble(2, p.getPackagePrice());
        ps1.setString(3, p.getPackageDesc());
        ps1.setString(4, p.getServiceName());
        ps1.setString(5, p.getPackageID());
        ps1.executeUpdate();

        PreparedStatement psDeleteRoutine = con.prepareStatement(
            "DELETE FROM ROUTINE WHERE PACKAGEID=?"
        );
        psDeleteRoutine.setString(1, p.getPackageID());
        psDeleteRoutine.executeUpdate();

        PreparedStatement ps2 = con.prepareStatement(
            "UPDATE FESTIVE SET FESTIVALNAME=?, STARTDATE=?, ENDDATE=?, DISCOUNTRATE=? WHERE PACKAGEID=?"
        );

        ps2.setString(1, p.getFestivalName());
        ps2.setString(2, p.getStartDate());
        ps2.setString(3, p.getEndDate());
        ps2.setDouble(4, p.getDiscountRate());
        ps2.setString(5, p.getPackageID());

        int row = ps2.executeUpdate();

        if (row == 0) {
            PreparedStatement ps3 = con.prepareStatement(
            		"INSERT INTO FESTIVE (PACKAGEID, FESTIVALNAME, STARTDATE, ENDDATE, DISCOUNTRATE) " +
            				"VALUES (?, ?, TO_DATE(?, 'YYYY-MM-DD'), TO_DATE(?, 'YYYY-MM-DD'), ?)"
            );

            ps3.setString(1, p.getPackageID());
            ps3.setString(2, p.getFestivalName());
            ps3.setString(3, p.getStartDate());
            ps3.setString(4, p.getEndDate());
            ps3.setDouble(5, p.getDiscountRate());
            ps3.executeUpdate();
            ps3.close();
        }

        ps1.close();
        psDeleteRoutine.close();
        ps2.close();
        con.close();
    }

    public static void deletePackage(String packageID) throws SQLException {

        Connection con = ConnectionManager.getConnection();

        PreparedStatement ps = con.prepareStatement(
            "UPDATE PACKAGE SET PACKAGESTATUS = 'UNAVAILABLE' WHERE PACKAGEID = ?"
        );

        ps.setString(1, packageID);
        ps.executeUpdate();

        ps.close();
        con.close();
    }

    public static void restorePackage(String packageID) throws SQLException {

        Connection con = ConnectionManager.getConnection();

        PreparedStatement ps = con.prepareStatement(
            "UPDATE PACKAGE SET PACKAGESTATUS='AVAILABLE' WHERE PACKAGEID=?"
        );

        ps.setString(1, packageID);
        ps.executeUpdate();

        ps.close();
        con.close();
    }
    
    public static boolean hasBooking(String packageID) {

        boolean found = false;

        try {
            Connection con = ConnectionManager.getConnection();

            String sql = "SELECT COUNT(*) FROM BOOKING WHERE PACKAGEID=?";

            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, packageID);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                found = rs.getInt(1) > 0;
            }

            rs.close();
            ps.close();
            con.close();

        } catch (Exception e) {
            e.printStackTrace();
        }

        return found;
    }

    public static void hardDeletePackage(String packageID) throws SQLException {

        Connection con = ConnectionManager.getConnection();

        PreparedStatement ps1 =
            con.prepareStatement("DELETE FROM ROUTINE WHERE PACKAGEID=?");
        ps1.setString(1, packageID);
        ps1.executeUpdate();

        PreparedStatement ps2 =
            con.prepareStatement("DELETE FROM FESTIVE WHERE PACKAGEID=?");
        ps2.setString(1, packageID);
        ps2.executeUpdate();

        PreparedStatement ps3 =
            con.prepareStatement("DELETE FROM PACKAGE WHERE PACKAGEID=?");
        ps3.setString(1, packageID);
        ps3.executeUpdate();

        ps1.close();
        ps2.close();
        ps3.close();
        con.close();
    }
}