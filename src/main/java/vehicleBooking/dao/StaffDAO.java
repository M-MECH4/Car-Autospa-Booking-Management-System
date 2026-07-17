package vehicleBooking.dao;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLIntegrityConstraintViolationException;
import java.util.ArrayList;

import vehicleBooking.ConnectionManager;
import vehicleBooking.bean.StaffBean;

public class StaffDAO {

    public static String generateStaffID() throws Exception {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String newStaffID = "S001";

        String sql =
                "SELECT 'S' || LPAD(NVL(MAX(TO_NUMBER(SUBSTR(STAFFID, 2))), 0) + 1, 3, '0') AS NEWID " +
                "FROM STAFF " +
                "WHERE REGEXP_LIKE(STAFFID, '^S[0-9]+$')";

        try {
            con = ConnectionManager.getConnection();

            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();

            if (rs.next()) {
                newStaffID = rs.getString("NEWID");
            }

            if (newStaffID == null || newStaffID.trim().isEmpty()) {
                newStaffID = "S001";
            }

            return newStaffID;

        } finally {
            close(rs, ps, con);
        }
    }

    public static StaffBean getStaffByUsername(String staffUsername) {
        StaffBean staff = null;

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql =
                "SELECT STAFFID, STAFFNAME, STAFFEMAIL, STAFFUSERNAME, " +
                "STAFFPASSWORD, STAFFPHONENUM, STAFFROLE, OWNERID " +
                "FROM STAFF " +
                "WHERE LOWER(TRIM(STAFFUSERNAME)) = LOWER(?)";

        try {
            con = ConnectionManager.getConnection();

            ps = con.prepareStatement(sql);
            ps.setString(1, staffUsername);

            rs = ps.executeQuery();

            if (rs.next()) {
                staff = mapStaff(rs);
            }

        } catch (Exception e) {
            e.printStackTrace();

        } finally {
            close(rs, ps, con);
        }

        return staff;
    }

    public static StaffBean getStaffByID(String staffID) {
        StaffBean staff = null;

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql =
                "SELECT STAFFID, STAFFNAME, STAFFEMAIL, STAFFUSERNAME, " +
                "STAFFPASSWORD, STAFFPHONENUM, STAFFROLE, OWNERID " +
                "FROM STAFF " +
                "WHERE STAFFID = ?";

        try {
            con = ConnectionManager.getConnection();

            ps = con.prepareStatement(sql);
            ps.setString(1, staffID);

            rs = ps.executeQuery();

            if (rs.next()) {
                staff = mapStaff(rs);
            }

        } catch (Exception e) {
            e.printStackTrace();

        } finally {
            close(rs, ps, con);
        }

        return staff;
    }

    public static boolean isStaffUsernameTaken(
            String staffUsername,
            String staffID) {

        boolean taken = false;

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql =
                "SELECT STAFFUSERNAME " +
                "FROM STAFF " +
                "WHERE LOWER(TRIM(STAFFUSERNAME)) = LOWER(?) " +
                "AND STAFFID <> ?";

        try {
            con = ConnectionManager.getConnection();

            ps = con.prepareStatement(sql);
            ps.setString(1, staffUsername);
            ps.setString(2, staffID);

            rs = ps.executeQuery();

            if (rs.next()) {
                taken = true;
            }

        } catch (Exception e) {
            e.printStackTrace();

        } finally {
            close(rs, ps, con);
        }

        return taken;
    }

    public static int updateStaffProfile(StaffBean staff) {
        int row = 0;

        Connection con = null;
        PreparedStatement ps = null;

        String sql =
                "UPDATE STAFF " +
                "SET STAFFUSERNAME = ?, STAFFPHONENUM = ? " +
                "WHERE STAFFID = ?";

        try {
            con = ConnectionManager.getConnection();

            ps = con.prepareStatement(sql);
            ps.setString(1, staff.getStaffUsername());
            ps.setString(2, staff.getStaffPhoneNum());
            ps.setString(3, staff.getStaffID());

            row = ps.executeUpdate();

            if (!con.getAutoCommit()) {
                con.commit();
            }

        } catch (Exception e) {
            e.printStackTrace();

        } finally {
            close(null, ps, con);
        }

        return row;
    }

    public static boolean updateStaffProfile(
            String staffID,
            String staffUsername,
            String staffPhoneNum) {

        Connection con = null;
        PreparedStatement ps = null;

        String sql =
                "UPDATE STAFF " +
                "SET STAFFUSERNAME = ?, STAFFPHONENUM = ? " +
                "WHERE STAFFID = ?";

        try {
            con = ConnectionManager.getConnection();

            ps = con.prepareStatement(sql);
            ps.setString(1, staffUsername);
            ps.setString(2, staffPhoneNum);
            ps.setString(3, staffID);

            int row = ps.executeUpdate();

            if (!con.getAutoCommit()) {
                con.commit();
            }

            return row > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;

        } finally {
            close(null, ps, con);
        }
    }

    /*
     * Updates the staff password.
     *
     * The current password can be either:
     * 1. An older plain-text password, or
     * 2. An MD5-hashed password.
     *
     * The new password is always saved as an MD5 hash.
     */
    public static int updateStaffPassword(
            String staffID,
            String currentPassword,
            String newPassword) {

        int row = 0;

        Connection con = null;
        PreparedStatement ps = null;

        String sql =
                "UPDATE STAFF " +
                "SET STAFFPASSWORD = ? " +
                "WHERE STAFFID = ? " +
                "AND (" +
                "LOWER(TRIM(STAFFPASSWORD)) = ? " +
                "OR TRIM(STAFFPASSWORD) = ?" +
                ")";

        try {
            con = ConnectionManager.getConnection();

            String currentPlainPassword =
                    currentPassword.trim();

            String hashedCurrentPassword =
                    hashPassword(currentPlainPassword);

            String hashedNewPassword =
                    hashPassword(newPassword.trim());

            ps = con.prepareStatement(sql);

            ps.setString(1, hashedNewPassword);
            ps.setString(2, staffID);
            ps.setString(3, hashedCurrentPassword);
            ps.setString(4, currentPlainPassword);

            row = ps.executeUpdate();

            if (!con.getAutoCommit()) {
                con.commit();
            }

        } catch (Exception e) {
            e.printStackTrace();

        } finally {
            close(null, ps, con);
        }

        return row;
    }

    public static ArrayList<StaffBean> getAllStaff()
            throws Exception {

        return getAllStaff(null);
    }

    public static ArrayList<StaffBean> getAllStaff(
            String keyword) throws Exception {

        ArrayList<StaffBean> staffList =
                new ArrayList<StaffBean>();

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        boolean hasKeyword =
                keyword != null &&
                !keyword.trim().isEmpty();

        String sql;

        if (hasKeyword) {
            sql =
                    "SELECT s.STAFFID, s.STAFFNAME, s.STAFFEMAIL, " +
                    "s.STAFFUSERNAME, s.STAFFPASSWORD, " +
                    "s.STAFFPHONENUM, s.STAFFROLE, s.OWNERID, " +

                    "(SELECT COUNT(*) " +
                    "FROM BOOKING b " +
                    "WHERE b.STAFFID = s.STAFFID) " +
                    "AS RELATEDRECORDCOUNT " +

                    "FROM STAFF s " +

                    "WHERE UPPER(s.STAFFID) LIKE UPPER(?) " +
                    "OR UPPER(s.STAFFNAME) LIKE UPPER(?) " +
                    "OR UPPER(s.STAFFEMAIL) LIKE UPPER(?) " +
                    "OR UPPER(s.STAFFUSERNAME) LIKE UPPER(?) " +
                    "OR UPPER(s.STAFFPHONENUM) LIKE UPPER(?) " +
                    "OR UPPER(s.STAFFROLE) LIKE UPPER(?) " +

                    "ORDER BY s.STAFFID";

        } else {
            sql =
                    "SELECT s.STAFFID, s.STAFFNAME, s.STAFFEMAIL, " +
                    "s.STAFFUSERNAME, s.STAFFPASSWORD, " +
                    "s.STAFFPHONENUM, s.STAFFROLE, s.OWNERID, " +

                    "(SELECT COUNT(*) " +
                    "FROM BOOKING b " +
                    "WHERE b.STAFFID = s.STAFFID) " +
                    "AS RELATEDRECORDCOUNT " +

                    "FROM STAFF s " +
                    "ORDER BY s.STAFFID";
        }

        try {
            con = ConnectionManager.getConnection();

            ps = con.prepareStatement(sql);

            if (hasKeyword) {
                String search =
                        "%" + keyword.trim() + "%";

                ps.setString(1, search);
                ps.setString(2, search);
                ps.setString(3, search);
                ps.setString(4, search);
                ps.setString(5, search);
                ps.setString(6, search);
            }

            rs = ps.executeQuery();

            while (rs.next()) {
                StaffBean staff = mapStaff(rs);

                staff.setRelatedRecordCount(
                        rs.getInt("RELATEDRECORDCOUNT")
                );

                staffList.add(staff);
            }

        } finally {
            close(rs, ps, con);
        }

        return staffList;
    }

    /*
     * Creates a new staff account.
     *
     * The password received from ManageStaffController is plain text.
     * It is converted into an MD5 hash before being inserted.
     */
    public static int addStaff(StaffBean staff)
            throws Exception {

        Connection con = null;
        PreparedStatement ps = null;

        String sql =
                "INSERT INTO STAFF " +
                "(" +
                "STAFFID, " +
                "STAFFNAME, " +
                "STAFFEMAIL, " +
                "STAFFUSERNAME, " +
                "STAFFPASSWORD, " +
                "STAFFPHONENUM, " +
                "STAFFROLE, " +
                "OWNERID" +
                ") " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try {
            con = ConnectionManager.getConnection();

            String hashedPassword =
                    hashPassword(
                            staff.getStaffPassword().trim()
                    );

            ps = con.prepareStatement(sql);

            ps.setString(1, staff.getStaffID());
            ps.setString(2, staff.getStaffName());
            ps.setString(3, staff.getStaffEmail());
            ps.setString(4, staff.getStaffUsername());

            // Save the hashed password, not the plain password
            ps.setString(5, hashedPassword);

            ps.setString(6, staff.getStaffPhoneNum());
            ps.setString(7, staff.getStaffRole());
            ps.setString(8, staff.getOwnerID());

            int row = ps.executeUpdate();

            if (!con.getAutoCommit()) {
                con.commit();
            }

            return row;

        } finally {
            close(null, ps, con);
        }
    }

    public static int updateStaffByOwner(
            String staffID,
            String staffName,
            String staffEmail,
            String staffUsername,
            String staffPhoneNum) throws Exception {

        Connection con = null;
        PreparedStatement ps = null;

        String sql =
                "UPDATE STAFF " +
                "SET STAFFNAME = ?, " +
                "STAFFEMAIL = ?, " +
                "STAFFUSERNAME = ?, " +
                "STAFFPHONENUM = ? " +
                "WHERE STAFFID = ? " +
                "AND UPPER(STAFFROLE) <> 'OWNER'";

        try {
            con = ConnectionManager.getConnection();

            ps = con.prepareStatement(sql);

            ps.setString(1, staffName);
            ps.setString(2, staffEmail);
            ps.setString(3, staffUsername);
            ps.setString(4, staffPhoneNum);
            ps.setString(5, staffID);

            int row = ps.executeUpdate();

            if (!con.getAutoCommit()) {
                con.commit();
            }

            return row;

        } finally {
            close(null, ps, con);
        }
    }

    public static int countStaffBooking(String staffID)
            throws Exception {

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql =
                "SELECT COUNT(*) AS TOTALBOOKING " +
                "FROM BOOKING " +
                "WHERE STAFFID = ?";

        try {
            con = ConnectionManager.getConnection();

            ps = con.prepareStatement(sql);
            ps.setString(1, staffID);

            rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt("TOTALBOOKING");
            }

            return 0;

        } finally {
            close(rs, ps, con);
        }
    }

    public static boolean hasRelatedData(String staffID)
            throws Exception {

        if (staffID == null ||
                staffID.trim().isEmpty()) {

            return false;
        }

        return countStaffBooking(
                staffID.trim().toUpperCase()
        ) > 0;
    }

    public static int deleteStaff(String staffID)
            throws Exception {

        if (hasRelatedData(staffID)) {
            return -1;
        }

        Connection con = null;
        PreparedStatement ps = null;

        String sql =
                "DELETE FROM STAFF " +
                "WHERE STAFFID = ? " +
                "AND UPPER(STAFFROLE) <> 'OWNER'";

        try {
            con = ConnectionManager.getConnection();

            ps = con.prepareStatement(sql);
            ps.setString(1, staffID);

            int row = ps.executeUpdate();

            if (!con.getAutoCommit()) {
                con.commit();
            }

            return row;

        } catch (SQLIntegrityConstraintViolationException e) {
            return -1;

        } finally {
            close(null, ps, con);
        }
    }

    public static String getStaffIdByEmail(String email) {
        String sql =
                "SELECT STAFFID " +
                "FROM STAFF " +
                "WHERE STAFFEMAIL = ?";

        try (
            Connection con =
                    ConnectionManager.getConnection();

            PreparedStatement ps =
                    con.prepareStatement(sql)
        ) {
            ps.setString(1, email);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getString("STAFFID");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    /*
     * ResetPasswordController already hashes the password
     * before calling this method.
     *
     * Therefore, this method saves the value exactly as received
     * to prevent hashing it twice.
     */
    public static boolean updatePassword(
            String staffId,
            String newPassword) {

        String sql =
                "UPDATE STAFF " +
                "SET STAFFPASSWORD = ? " +
                "WHERE STAFFID = ?";

        try (
            Connection con =
                    ConnectionManager.getConnection();

            PreparedStatement ps =
                    con.prepareStatement(sql)
        ) {
            ps.setString(1, newPassword);
            ps.setString(2, staffId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public static int getTotalStaff() {
        int totalStaff = 0;

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql =
                "SELECT COUNT(*) AS TOTALSTAFF " +
                "FROM STAFF " +
                "WHERE NVL(" +
                "UPPER(TRIM(STAFFROLE)), " +
                "'STAFF'" +
                ") <> 'OWNER'";

        try {
            con = ConnectionManager.getConnection();

            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();

            if (rs.next()) {
                totalStaff =
                        rs.getInt("TOTALSTAFF");
            }

        } catch (Exception e) {
            e.printStackTrace();

        } finally {
            close(rs, ps, con);
        }

        return totalStaff;
    }

    /*
     * Converts a plain-text password into a
     * 32-character lowercase MD5 hash.
     */
    private static String hashPassword(String password) {
        if (password == null) {
            throw new IllegalArgumentException(
                    "Password cannot be null."
            );
        }

        try {
            MessageDigest md =
                    MessageDigest.getInstance("MD5");

            byte[] digest =
                    md.digest(
                            password.getBytes(
                                    StandardCharsets.UTF_8
                            )
                    );

            StringBuilder hashedPassword =
                    new StringBuilder();

            for (byte value : digest) {
                hashedPassword.append(
                        String.format(
                                "%02x",
                                value & 0xff
                        )
                );
            }

            return hashedPassword.toString();

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Unable to hash staff password.",
                    e
            );
        }
    }

    private static StaffBean mapStaff(ResultSet rs)
            throws Exception {

        StaffBean staff = new StaffBean();

        staff.setStaffID(
                rs.getString("STAFFID")
        );

        staff.setStaffName(
                rs.getString("STAFFNAME")
        );

        staff.setStaffEmail(
                rs.getString("STAFFEMAIL")
        );

        staff.setStaffUsername(
                rs.getString("STAFFUSERNAME")
        );

        staff.setStaffPassword(
                rs.getString("STAFFPASSWORD")
        );

        staff.setStaffPhoneNum(
                rs.getString("STAFFPHONENUM")
        );

        staff.setStaffRole(
                rs.getString("STAFFROLE")
        );

        staff.setOwnerID(
                rs.getString("OWNERID")
        );

        return staff;
    }

    private static void close(
            ResultSet rs,
            PreparedStatement ps,
            Connection con) {

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