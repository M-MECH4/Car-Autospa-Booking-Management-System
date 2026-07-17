package vehicleBooking.dao;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;

import vehicleBooking.ConnectionManager;
import vehicleBooking.bean.FestivalBean;
import vehicleBooking.bean.PackageBean;
import vehicleBooking.bean.RoutineBean;

public class PackageDAO {

    private static PackageBean mapPackage(
            ResultSet rs
    ) throws SQLException {

        PackageBean p;

        if (rs.getString("FESTIVALNAME") != null) {

            FestivalBean f =
                    new FestivalBean();

            f.setFestivalName(
                    rs.getString("FESTIVALNAME")
            );

            f.setStartDate(
                    rs.getString("STARTDATE")
            );

            f.setEndDate(
                    rs.getString("ENDDATE")
            );

            f.setDiscountRate(
                    rs.getDouble("DISCOUNTRATE")
            );

            f.setTargetRace(
                    rs.getString("TARGETRACE")
            );

            f.setTargetReligion(
                    rs.getString("TARGETRELIGION")
            );

            p = f;

        } else if (rs.getString("ENTRYMETHOD") != null) {

            RoutineBean r =
                    new RoutineBean();

            r.setEntryMethod(
                    rs.getString("ENTRYMETHOD")
            );

            p = r;

        } else {

            p = new PackageBean();
        }

        p.setPackageID(
                rs.getString("PACKAGEID")
        );

        p.setPackageName(
                rs.getString("PACKAGENAME")
        );

        p.setPackagePrice(
                rs.getDouble("PACKAGEPRICE")
        );

        p.setPackageDesc(
                rs.getString("PACKAGEDESC")
        );

        p.setServiceName(
                rs.getString("SERVICENAME")
        );

        p.setPackageStatus(
                rs.getString("PACKAGESTATUS")
        );

        return p;
    }

    private static String normalizeEligibility(
            String value
    ) {

        if (value == null
                || value.trim().isEmpty()) {

            return "ALL";
        }

        return value.trim().toUpperCase();
    }

    private static void validateDiscountRate(
            double discountRate
    ) throws SQLException {

        if (Double.isNaN(discountRate)
                || Double.isInfinite(discountRate)
                || discountRate < 0
                || discountRate > 100) {

            throw new SQLException(
                    "Discount rate must be "
                    + "between 0 and 100."
            );
        }
    }

    // =========================
    // STAFF / OWNER VIEW ALL
    // =========================
    public static ArrayList<PackageBean>
            getAllPackage() {

        ArrayList<PackageBean> list =
                new ArrayList<>();

        String sql =
                "SELECT p.PACKAGEID, "
                + "p.PACKAGENAME, "
                + "p.PACKAGEPRICE, "
                + "p.PACKAGEDESC, "
                + "p.SERVICENAME, "
                + "p.PACKAGESTATUS, "
                + "r.ENTRYMETHOD, "
                + "f.FESTIVALNAME, "
                + "TO_CHAR(f.STARTDATE, "
                + "'YYYY-MM-DD') AS STARTDATE, "
                + "TO_CHAR(f.ENDDATE, "
                + "'YYYY-MM-DD') AS ENDDATE, "
                + "f.DISCOUNTRATE, "
                + "NVL(f.TARGETRACE, 'ALL') "
                + "AS TARGETRACE, "
                + "NVL(f.TARGETRELIGION, 'ALL') "
                + "AS TARGETRELIGION "
                + "FROM PACKAGE p "
                + "LEFT JOIN ROUTINE r "
                + "ON p.PACKAGEID = r.PACKAGEID "
                + "LEFT JOIN FESTIVE f "
                + "ON p.PACKAGEID = f.PACKAGEID "
                + "ORDER BY p.PACKAGESTATUS, "
                + "p.PACKAGEID";

        try (
            Connection con =
                    ConnectionManager.getConnection();

            PreparedStatement ps =
                    con.prepareStatement(sql);

            ResultSet rs =
                    ps.executeQuery()
        ) {

            while (rs.next()) {
                list.add(mapPackage(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    // =========================
    // CUSTOMER VIEW WITHOUT FILTER
    // =========================
    public static ArrayList<PackageBean>
            getCustomerPackage() {

        ArrayList<PackageBean> list =
                new ArrayList<>();

        String sql =
                "SELECT p.PACKAGEID, "
                + "p.PACKAGENAME, "
                + "p.PACKAGEPRICE, "
                + "p.PACKAGEDESC, "
                + "p.SERVICENAME, "
                + "p.PACKAGESTATUS, "
                + "r.ENTRYMETHOD, "
                + "f.FESTIVALNAME, "
                + "TO_CHAR(f.STARTDATE, "
                + "'YYYY-MM-DD') AS STARTDATE, "
                + "TO_CHAR(f.ENDDATE, "
                + "'YYYY-MM-DD') AS ENDDATE, "
                + "f.DISCOUNTRATE, "
                + "NVL(f.TARGETRACE, 'ALL') "
                + "AS TARGETRACE, "
                + "NVL(f.TARGETRELIGION, 'ALL') "
                + "AS TARGETRELIGION "
                + "FROM PACKAGE p "
                + "LEFT JOIN ROUTINE r "
                + "ON p.PACKAGEID = r.PACKAGEID "
                + "LEFT JOIN FESTIVE f "
                + "ON p.PACKAGEID = f.PACKAGEID "
                + "WHERE NVL(UPPER(TRIM("
                + "p.PACKAGESTATUS)), "
                + "'AVAILABLE') = 'AVAILABLE' "
                + "AND (f.PACKAGEID IS NULL "
                + "OR f.ENDDATE >= TRUNC(SYSDATE)) "
                + "ORDER BY p.PACKAGEID";

        try (
            Connection con =
                    ConnectionManager.getConnection();

            PreparedStatement ps =
                    con.prepareStatement(sql);

            ResultSet rs =
                    ps.executeQuery()
        ) {

            while (rs.next()) {
                list.add(mapPackage(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    // =========================
    // CUSTOMER VIEW WITH FILTER
    // =========================
    public static ArrayList<PackageBean>
            getCustomerPackage(String custID) {

        ArrayList<PackageBean> list =
                new ArrayList<>();

        String sql =
                "SELECT p.PACKAGEID, "
                + "p.PACKAGENAME, "
                + "p.PACKAGEPRICE, "
                + "p.PACKAGEDESC, "
                + "p.SERVICENAME, "
                + "p.PACKAGESTATUS, "
                + "r.ENTRYMETHOD, "
                + "f.FESTIVALNAME, "
                + "TO_CHAR(f.STARTDATE, "
                + "'YYYY-MM-DD') AS STARTDATE, "
                + "TO_CHAR(f.ENDDATE, "
                + "'YYYY-MM-DD') AS ENDDATE, "
                + "f.DISCOUNTRATE, "
                + "NVL(f.TARGETRACE, 'ALL') "
                + "AS TARGETRACE, "
                + "NVL(f.TARGETRELIGION, 'ALL') "
                + "AS TARGETRELIGION "
                + "FROM PACKAGE p "
                + "LEFT JOIN ROUTINE r "
                + "ON p.PACKAGEID = r.PACKAGEID "
                + "LEFT JOIN FESTIVE f "
                + "ON p.PACKAGEID = f.PACKAGEID "
                + "LEFT JOIN CUSTOMER c "
                + "ON c.CUSTID = ? "
                + "WHERE NVL(UPPER(TRIM("
                + "p.PACKAGESTATUS)), "
                + "'AVAILABLE') = 'AVAILABLE' "
                + "AND (f.PACKAGEID IS NULL "
                + "OR f.ENDDATE >= TRUNC(SYSDATE)) "
                + "AND ("
                + "f.PACKAGEID IS NULL "
                + "OR ("
                + "(NVL(UPPER(TRIM("
                + "f.TARGETRACE)), 'ALL') = 'ALL' "
                + "OR NVL(UPPER(TRIM("
                + "f.TARGETRACE)), 'ALL') = "
                + "NVL(UPPER(TRIM(c.CUSTRACE)), "
                + "'OTHER')) "
                + "AND "
                + "(NVL(UPPER(TRIM("
                + "f.TARGETRELIGION)), 'ALL') "
                + "= 'ALL' "
                + "OR NVL(UPPER(TRIM("
                + "f.TARGETRELIGION)), 'ALL') = "
                + "NVL(UPPER(TRIM("
                + "c.CUSTRELIGION)), 'OTHER'))"
                + ")"
                + ") "
                + "ORDER BY p.PACKAGEID";

        try (
            Connection con =
                    ConnectionManager.getConnection();

            PreparedStatement ps =
                    con.prepareStatement(sql)
        ) {

            ps.setString(1, custID);

            try (ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    list.add(mapPackage(rs));
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    // =========================
    // GET PACKAGE BY ID
    // =========================
    public static PackageBean getPackageById(
            String packageID
    ) {

        PackageBean p = null;

        String sql =
                "SELECT p.PACKAGEID, "
                + "p.PACKAGENAME, "
                + "p.PACKAGEPRICE, "
                + "p.PACKAGEDESC, "
                + "p.SERVICENAME, "
                + "p.PACKAGESTATUS, "
                + "r.ENTRYMETHOD, "
                + "f.FESTIVALNAME, "
                + "TO_CHAR(f.STARTDATE, "
                + "'YYYY-MM-DD') AS STARTDATE, "
                + "TO_CHAR(f.ENDDATE, "
                + "'YYYY-MM-DD') AS ENDDATE, "
                + "f.DISCOUNTRATE, "
                + "NVL(f.TARGETRACE, 'ALL') "
                + "AS TARGETRACE, "
                + "NVL(f.TARGETRELIGION, 'ALL') "
                + "AS TARGETRELIGION "
                + "FROM PACKAGE p "
                + "LEFT JOIN ROUTINE r "
                + "ON p.PACKAGEID = r.PACKAGEID "
                + "LEFT JOIN FESTIVE f "
                + "ON p.PACKAGEID = f.PACKAGEID "
                + "WHERE p.PACKAGEID = ?";

        try (
            Connection con =
                    ConnectionManager.getConnection();

            PreparedStatement ps =
                    con.prepareStatement(sql)
        ) {

            ps.setString(1, packageID);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {
                    p = mapPackage(rs);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return p;
    }

    // =========================
    // ADD ROUTINE PACKAGE
    // =========================
    public static void addRoutine(
            RoutineBean p
    ) throws SQLException {

        Connection con = null;
        CallableStatement cs = null;
        PreparedStatement ps2 = null;

        try {

            con = ConnectionManager.getConnection();

            cs = con.prepareCall(
                    "BEGIN "
                    + "INSERT INTO PACKAGE "
                    + "(PACKAGENAME, PACKAGEPRICE, "
                    + "PACKAGEDESC, SERVICENAME, "
                    + "PACKAGESTATUS) "
                    + "VALUES (?, ?, ?, ?, 'AVAILABLE') "
                    + "RETURNING PACKAGEID INTO ?; "
                    + "END;"
            );

            cs.setString(
                    1,
                    p.getPackageName()
            );

            cs.setDouble(
                    2,
                    p.getPackagePrice()
            );

            cs.setString(
                    3,
                    p.getPackageDesc()
            );

            cs.setString(
                    4,
                    p.getServiceName()
            );

            cs.registerOutParameter(
                    5,
                    Types.VARCHAR
            );

            cs.execute();

            String packageID =
                    cs.getString(5);

            ps2 = con.prepareStatement(
                    "INSERT INTO ROUTINE "
                    + "(PACKAGEID, ENTRYMETHOD) "
                    + "VALUES (?, ?)"
            );

            ps2.setString(1, packageID);
            ps2.setString(
                    2,
                    p.getEntryMethod()
            );

            ps2.executeUpdate();

            if (!con.getAutoCommit()) {
                con.commit();
            }

        } finally {

            if (ps2 != null) {
                ps2.close();
            }

            if (cs != null) {
                cs.close();
            }

            if (con != null) {
                con.close();
            }
        }
    }

    // =========================
    // ADD FESTIVE PACKAGE
    // =========================
    public static void addFestive(
            FestivalBean p
    ) throws SQLException {

        validateDiscountRate(
                p.getDiscountRate()
        );

        Connection con = null;
        CallableStatement cs = null;
        PreparedStatement ps2 = null;

        try {

            con = ConnectionManager.getConnection();

            cs = con.prepareCall(
                    "BEGIN "
                    + "INSERT INTO PACKAGE "
                    + "(PACKAGENAME, PACKAGEPRICE, "
                    + "PACKAGEDESC, SERVICENAME, "
                    + "PACKAGESTATUS) "
                    + "VALUES (?, ?, ?, ?, 'AVAILABLE') "
                    + "RETURNING PACKAGEID INTO ?; "
                    + "END;"
            );

            cs.setString(
                    1,
                    p.getPackageName()
            );

            cs.setDouble(
                    2,
                    p.getPackagePrice()
            );

            cs.setString(
                    3,
                    p.getPackageDesc()
            );

            cs.setString(
                    4,
                    p.getServiceName()
            );

            cs.registerOutParameter(
                    5,
                    Types.VARCHAR
            );

            cs.execute();

            String packageID =
                    cs.getString(5);

            ps2 = con.prepareStatement(
                    "INSERT INTO FESTIVE "
                    + "(PACKAGEID, FESTIVALNAME, "
                    + "STARTDATE, ENDDATE, "
                    + "DISCOUNTRATE, TARGETRACE, "
                    + "TARGETRELIGION) "
                    + "VALUES (?, ?, "
                    + "TO_DATE(?, 'YYYY-MM-DD'), "
                    + "TO_DATE(?, 'YYYY-MM-DD'), "
                    + "?, ?, ?)"
            );

            ps2.setString(1, packageID);

            ps2.setString(
                    2,
                    p.getFestivalName()
            );

            ps2.setString(
                    3,
                    p.getStartDate()
            );

            ps2.setString(
                    4,
                    p.getEndDate()
            );

            ps2.setDouble(
                    5,
                    p.getDiscountRate()
            );

            ps2.setString(
                    6,
                    normalizeEligibility(
                            p.getTargetRace()
                    )
            );

            ps2.setString(
                    7,
                    normalizeEligibility(
                            p.getTargetReligion()
                    )
            );

            ps2.executeUpdate();

            if (!con.getAutoCommit()) {
                con.commit();
            }

        } finally {

            if (ps2 != null) {
                ps2.close();
            }

            if (cs != null) {
                cs.close();
            }

            if (con != null) {
                con.close();
            }
        }
    }

    // =========================
    // UPDATE ROUTINE PACKAGE
    // =========================
    public static void updateRoutine(
            RoutineBean p
    ) throws SQLException {

        Connection con = null;
        PreparedStatement ps1 = null;
        PreparedStatement psDeleteFestive = null;
        PreparedStatement ps2 = null;
        PreparedStatement ps3 = null;

        try {

            con = ConnectionManager.getConnection();

            ps1 = con.prepareStatement(
                    "UPDATE PACKAGE "
                    + "SET PACKAGENAME = ?, "
                    + "PACKAGEPRICE = ?, "
                    + "PACKAGEDESC = ?, "
                    + "SERVICENAME = ?, "
                    + "PACKAGESTATUS = 'AVAILABLE' "
                    + "WHERE PACKAGEID = ?"
            );

            ps1.setString(
                    1,
                    p.getPackageName()
            );

            ps1.setDouble(
                    2,
                    p.getPackagePrice()
            );

            ps1.setString(
                    3,
                    p.getPackageDesc()
            );

            ps1.setString(
                    4,
                    p.getServiceName()
            );

            ps1.setString(
                    5,
                    p.getPackageID()
            );

            ps1.executeUpdate();

            psDeleteFestive =
                    con.prepareStatement(
                            "DELETE FROM FESTIVE "
                            + "WHERE PACKAGEID = ?"
                    );

            psDeleteFestive.setString(
                    1,
                    p.getPackageID()
            );

            psDeleteFestive.executeUpdate();

            ps2 = con.prepareStatement(
                    "UPDATE ROUTINE "
                    + "SET ENTRYMETHOD = ? "
                    + "WHERE PACKAGEID = ?"
            );

            ps2.setString(
                    1,
                    p.getEntryMethod()
            );

            ps2.setString(
                    2,
                    p.getPackageID()
            );

            int row = ps2.executeUpdate();

            if (row == 0) {

                ps3 = con.prepareStatement(
                        "INSERT INTO ROUTINE "
                        + "(PACKAGEID, ENTRYMETHOD) "
                        + "VALUES (?, ?)"
                );

                ps3.setString(
                        1,
                        p.getPackageID()
                );

                ps3.setString(
                        2,
                        p.getEntryMethod()
                );

                ps3.executeUpdate();
            }

            if (!con.getAutoCommit()) {
                con.commit();
            }

        } finally {

            if (ps3 != null) {
                ps3.close();
            }

            if (ps2 != null) {
                ps2.close();
            }

            if (psDeleteFestive != null) {
                psDeleteFestive.close();
            }

            if (ps1 != null) {
                ps1.close();
            }

            if (con != null) {
                con.close();
            }
        }
    }

    // =========================
    // UPDATE FESTIVE PACKAGE
    // =========================
    public static void updateFestive(
            FestivalBean p
    ) throws SQLException {

        validateDiscountRate(
                p.getDiscountRate()
        );

        Connection con = null;
        PreparedStatement ps1 = null;
        PreparedStatement psDeleteRoutine = null;
        PreparedStatement ps2 = null;
        PreparedStatement ps3 = null;

        try {

            con = ConnectionManager.getConnection();

            ps1 = con.prepareStatement(
                    "UPDATE PACKAGE "
                    + "SET PACKAGENAME = ?, "
                    + "PACKAGEPRICE = ?, "
                    + "PACKAGEDESC = ?, "
                    + "SERVICENAME = ?, "
                    + "PACKAGESTATUS = 'AVAILABLE' "
                    + "WHERE PACKAGEID = ?"
            );

            ps1.setString(
                    1,
                    p.getPackageName()
            );

            ps1.setDouble(
                    2,
                    p.getPackagePrice()
            );

            ps1.setString(
                    3,
                    p.getPackageDesc()
            );

            ps1.setString(
                    4,
                    p.getServiceName()
            );

            ps1.setString(
                    5,
                    p.getPackageID()
            );

            ps1.executeUpdate();

            psDeleteRoutine =
                    con.prepareStatement(
                            "DELETE FROM ROUTINE "
                            + "WHERE PACKAGEID = ?"
                    );

            psDeleteRoutine.setString(
                    1,
                    p.getPackageID()
            );

            psDeleteRoutine.executeUpdate();

            ps2 = con.prepareStatement(
                    "UPDATE FESTIVE "
                    + "SET FESTIVALNAME = ?, "
                    + "STARTDATE = "
                    + "TO_DATE(?, 'YYYY-MM-DD'), "
                    + "ENDDATE = "
                    + "TO_DATE(?, 'YYYY-MM-DD'), "
                    + "DISCOUNTRATE = ?, "
                    + "TARGETRACE = ?, "
                    + "TARGETRELIGION = ? "
                    + "WHERE PACKAGEID = ?"
            );

            ps2.setString(
                    1,
                    p.getFestivalName()
            );

            ps2.setString(
                    2,
                    p.getStartDate()
            );

            ps2.setString(
                    3,
                    p.getEndDate()
            );

            ps2.setDouble(
                    4,
                    p.getDiscountRate()
            );

            ps2.setString(
                    5,
                    normalizeEligibility(
                            p.getTargetRace()
                    )
            );

            ps2.setString(
                    6,
                    normalizeEligibility(
                            p.getTargetReligion()
                    )
            );

            ps2.setString(
                    7,
                    p.getPackageID()
            );

            int row = ps2.executeUpdate();

            if (row == 0) {

                ps3 = con.prepareStatement(
                        "INSERT INTO FESTIVE "
                        + "(PACKAGEID, FESTIVALNAME, "
                        + "STARTDATE, ENDDATE, "
                        + "DISCOUNTRATE, TARGETRACE, "
                        + "TARGETRELIGION) "
                        + "VALUES (?, ?, "
                        + "TO_DATE(?, 'YYYY-MM-DD'), "
                        + "TO_DATE(?, 'YYYY-MM-DD'), "
                        + "?, ?, ?)"
                );

                ps3.setString(
                        1,
                        p.getPackageID()
                );

                ps3.setString(
                        2,
                        p.getFestivalName()
                );

                ps3.setString(
                        3,
                        p.getStartDate()
                );

                ps3.setString(
                        4,
                        p.getEndDate()
                );

                ps3.setDouble(
                        5,
                        p.getDiscountRate()
                );

                ps3.setString(
                        6,
                        normalizeEligibility(
                                p.getTargetRace()
                        )
                );

                ps3.setString(
                        7,
                        normalizeEligibility(
                                p.getTargetReligion()
                        )
                );

                ps3.executeUpdate();
            }

            if (!con.getAutoCommit()) {
                con.commit();
            }

        } finally {

            if (ps3 != null) {
                ps3.close();
            }

            if (ps2 != null) {
                ps2.close();
            }

            if (psDeleteRoutine != null) {
                psDeleteRoutine.close();
            }

            if (ps1 != null) {
                ps1.close();
            }

            if (con != null) {
                con.close();
            }
        }
    }

    // =========================
    // DELETE WITH CONSTRAINT CHECK
    // =========================
    public static boolean
            deletePackageWithConstraintCheck(
                    String packageID
            ) throws SQLException {

        Connection con = null;
        PreparedStatement psLock = null;
        PreparedStatement psBooking = null;
        PreparedStatement psRoutine = null;
        PreparedStatement psFestive = null;
        PreparedStatement psPackage = null;
        ResultSet rsLock = null;
        ResultSet rsBooking = null;

        try {

            con = ConnectionManager.getConnection();

            if (con == null) {
                throw new SQLException(
                        "Unable to connect "
                        + "to the database."
                );
            }

            con.setAutoCommit(false);

            psLock = con.prepareStatement(
                    "SELECT PACKAGEID "
                    + "FROM PACKAGE "
                    + "WHERE PACKAGEID = ? "
                    + "FOR UPDATE"
            );

            psLock.setString(
                    1,
                    packageID
            );

            rsLock = psLock.executeQuery();

            if (!rsLock.next()) {

                throw new SQLException(
                        "Package not found: "
                        + packageID
                );
            }

            psBooking = con.prepareStatement(
                    "SELECT COUNT(*) "
                    + "FROM BOOKING "
                    + "WHERE PACKAGEID = ?"
            );

            psBooking.setString(
                    1,
                    packageID
            );

            rsBooking =
                    psBooking.executeQuery();

            boolean hasBooking =
                    rsBooking.next()
                    && rsBooking.getInt(1) > 0;

            if (hasBooking) {

                psPackage = con.prepareStatement(
                        "UPDATE PACKAGE "
                        + "SET PACKAGESTATUS = "
                        + "'UNAVAILABLE' "
                        + "WHERE PACKAGEID = ?"
                );

                psPackage.setString(
                        1,
                        packageID
                );

                psPackage.executeUpdate();

                con.commit();

                return false;
            }

            psRoutine = con.prepareStatement(
                    "DELETE FROM ROUTINE "
                    + "WHERE PACKAGEID = ?"
            );

            psRoutine.setString(
                    1,
                    packageID
            );

            psRoutine.executeUpdate();

            psFestive = con.prepareStatement(
                    "DELETE FROM FESTIVE "
                    + "WHERE PACKAGEID = ?"
            );

            psFestive.setString(
                    1,
                    packageID
            );

            psFestive.executeUpdate();

            psPackage = con.prepareStatement(
                    "DELETE FROM PACKAGE "
                    + "WHERE PACKAGEID = ?"
            );

            psPackage.setString(
                    1,
                    packageID
            );

            psPackage.executeUpdate();

            con.commit();

            return true;

        } catch (SQLException e) {

            if (con != null) {

                try {
                    con.rollback();

                } catch (
                    SQLException rollbackException
                ) {

                    e.addSuppressed(
                            rollbackException
                    );
                }
            }

            throw e;

        } finally {

            if (rsBooking != null) {
                rsBooking.close();
            }

            if (rsLock != null) {
                rsLock.close();
            }

            if (psPackage != null) {
                psPackage.close();
            }

            if (psFestive != null) {
                psFestive.close();
            }

            if (psRoutine != null) {
                psRoutine.close();
            }

            if (psBooking != null) {
                psBooking.close();
            }

            if (psLock != null) {
                psLock.close();
            }

            if (con != null) {
                con.close();
            }
        }
    }

    // =========================
    // SET PACKAGE UNAVAILABLE
    // =========================
    public static void deletePackage(
            String packageID
    ) throws SQLException {

        Connection con = null;
        PreparedStatement ps = null;

        try {

            con = ConnectionManager.getConnection();

            ps = con.prepareStatement(
                    "UPDATE PACKAGE "
                    + "SET PACKAGESTATUS = "
                    + "'UNAVAILABLE' "
                    + "WHERE PACKAGEID = ?"
            );

            ps.setString(
                    1,
                    packageID
            );

            ps.executeUpdate();

            if (!con.getAutoCommit()) {
                con.commit();
            }

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
    // RESTORE PACKAGE
    // =========================
    public static void restorePackage(
            String packageID
    ) throws SQLException {

        Connection con = null;
        PreparedStatement ps = null;

        try {

            con = ConnectionManager.getConnection();

            ps = con.prepareStatement(
                    "UPDATE PACKAGE "
                    + "SET PACKAGESTATUS = "
                    + "'AVAILABLE' "
                    + "WHERE PACKAGEID = ?"
            );

            ps.setString(
                    1,
                    packageID
            );

            ps.executeUpdate();

            if (!con.getAutoCommit()) {
                con.commit();
            }

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
    // CHECK PACKAGE HAS BOOKING
    // =========================
    public static boolean hasBooking(
            String packageID
    ) {

        boolean found = false;

        String sql =
                "SELECT COUNT(*) "
                + "FROM BOOKING "
                + "WHERE PACKAGEID = ?";

        try (
            Connection con =
                    ConnectionManager.getConnection();

            PreparedStatement ps =
                    con.prepareStatement(sql)
        ) {

            ps.setString(
                    1,
                    packageID
            );

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {
                    found = rs.getInt(1) > 0;
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return found;
    }

    // =========================
    // PERMANENT DELETE PACKAGE
    // =========================
    public static void hardDeletePackage(
            String packageID
    ) throws SQLException {

        Connection con = null;
        PreparedStatement ps1 = null;
        PreparedStatement ps2 = null;
        PreparedStatement ps3 = null;

        try {

            con = ConnectionManager.getConnection();

            ps1 = con.prepareStatement(
                    "DELETE FROM ROUTINE "
                    + "WHERE PACKAGEID = ?"
            );

            ps1.setString(
                    1,
                    packageID
            );

            ps1.executeUpdate();

            ps2 = con.prepareStatement(
                    "DELETE FROM FESTIVE "
                    + "WHERE PACKAGEID = ?"
            );

            ps2.setString(
                    1,
                    packageID
            );

            ps2.executeUpdate();

            ps3 = con.prepareStatement(
                    "DELETE FROM PACKAGE "
                    + "WHERE PACKAGEID = ?"
            );

            ps3.setString(
                    1,
                    packageID
            );

            ps3.executeUpdate();

            if (!con.getAutoCommit()) {
                con.commit();
            }

        } finally {

            if (ps3 != null) {
                ps3.close();
            }

            if (ps2 != null) {
                ps2.close();
            }

            if (ps1 != null) {
                ps1.close();
            }

            if (con != null) {
                con.close();
            }
        }
    }
}