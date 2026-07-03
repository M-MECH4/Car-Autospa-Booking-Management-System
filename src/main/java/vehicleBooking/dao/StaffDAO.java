package vehicleBooking.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;

import vehicleBooking.ConnectionManager;
import vehicleBooking.bean.StaffBean;

public class StaffDAO {

    public static StaffBean getStaffByUsername(String staffUsername) {
        StaffBean staff = null;

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql =
                "SELECT STAFFID, STAFFNAME, STAFFEMAIL, STAFFUSERNAME, STAFFPASSWORD, STAFFPHONENUM, STAFFROLE, OWNERID " +
                "FROM STAFF " +
                "WHERE LOWER(TRIM(STAFFUSERNAME)) = LOWER(?)";

        try {
            con = ConnectionManager.getConnection();

            ps = con.prepareStatement(sql);
            ps.setString(1, staffUsername);

            rs = ps.executeQuery();

            if (rs.next()) {
                staff = new StaffBean();

                staff.setStaffID(rs.getString("STAFFID"));
                staff.setStaffName(rs.getString("STAFFNAME"));
                staff.setStaffEmail(rs.getString("STAFFEMAIL"));
                staff.setStaffUsername(rs.getString("STAFFUSERNAME"));
                staff.setStaffPassword(rs.getString("STAFFPASSWORD"));
                staff.setStaffPhoneNum(rs.getString("STAFFPHONENUM"));
                staff.setStaffRole(rs.getString("STAFFROLE"));
                staff.setOwnerID(rs.getString("OWNERID"));
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
                "SELECT STAFFID, STAFFNAME, STAFFEMAIL, STAFFUSERNAME, STAFFPASSWORD, STAFFPHONENUM, STAFFROLE, OWNERID " +
                "FROM STAFF " +
                "WHERE STAFFID = ?";

        try {
            con = ConnectionManager.getConnection();

            ps = con.prepareStatement(sql);
            ps.setString(1, staffID);

            rs = ps.executeQuery();

            if (rs.next()) {
                staff = new StaffBean();

                staff.setStaffID(rs.getString("STAFFID"));
                staff.setStaffName(rs.getString("STAFFNAME"));
                staff.setStaffEmail(rs.getString("STAFFEMAIL"));
                staff.setStaffUsername(rs.getString("STAFFUSERNAME"));
                staff.setStaffPassword(rs.getString("STAFFPASSWORD"));
                staff.setStaffPhoneNum(rs.getString("STAFFPHONENUM"));
                staff.setStaffRole(rs.getString("STAFFROLE"));
                staff.setOwnerID(rs.getString("OWNERID"));
            }

        } catch (Exception e) {
            e.printStackTrace();

        } finally {
            close(rs, ps, con);
        }

        return staff;
    }

    public static boolean isStaffUsernameTaken(String staffUsername, String staffID) {
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

    public static boolean updateStaffProfile(String staffID, String staffUsername, String staffPhoneNum) {
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

            return row > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;

        } finally {
            close(null, ps, con);
        }
    }

    public static int updateStaffPassword(String staffID, String currentPassword, String newPassword) {
        int row = 0;

        Connection con = null;
        PreparedStatement ps = null;

        String sql =
                "UPDATE STAFF " +
                "SET STAFFPASSWORD = ? " +
                "WHERE STAFFID = ? " +
                "AND TRIM(STAFFPASSWORD) = ?";

        try {
            con = ConnectionManager.getConnection();

            ps = con.prepareStatement(sql);
            ps.setString(1, newPassword);
            ps.setString(2, staffID);
            ps.setString(3, currentPassword);

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

    public static ArrayList<StaffBean> getAllStaff() throws Exception {
        ArrayList<StaffBean> staffList = new ArrayList<StaffBean>();

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql =
                "SELECT STAFFID, STAFFNAME, STAFFEMAIL, STAFFUSERNAME, STAFFPASSWORD, " +
                "STAFFPHONENUM, STAFFROLE, OWNERID " +
                "FROM STAFF " +
                "ORDER BY STAFFID";

        try {
            con = ConnectionManager.getConnection();

            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                StaffBean staff = new StaffBean();

                staff.setStaffID(rs.getString("STAFFID"));
                staff.setStaffName(rs.getString("STAFFNAME"));
                staff.setStaffEmail(rs.getString("STAFFEMAIL"));
                staff.setStaffUsername(rs.getString("STAFFUSERNAME"));
                staff.setStaffPassword(rs.getString("STAFFPASSWORD"));
                staff.setStaffPhoneNum(rs.getString("STAFFPHONENUM"));
                staff.setStaffRole(rs.getString("STAFFROLE"));
                staff.setOwnerID(rs.getString("OWNERID"));

                staffList.add(staff);
            }

        } finally {
            close(rs, ps, con);
        }

        return staffList;
    }

    public static int addStaff(StaffBean staff) throws Exception {
        Connection con = null;
        PreparedStatement ps = null;

        String sql =
                "INSERT INTO STAFF " +
                "(STAFFID, STAFFNAME, STAFFEMAIL, STAFFUSERNAME, STAFFPASSWORD, STAFFPHONENUM, STAFFROLE, OWNERID) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try {
            con = ConnectionManager.getConnection();

            ps = con.prepareStatement(sql);
            ps.setString(1, staff.getStaffID());
            ps.setString(2, staff.getStaffName());
            ps.setString(3, staff.getStaffEmail());
            ps.setString(4, staff.getStaffUsername());
            ps.setString(5, staff.getStaffPassword());
            ps.setString(6, staff.getStaffPhoneNum());
            ps.setString(7, staff.getStaffRole());
            ps.setString(8, staff.getOwnerID());

            return ps.executeUpdate();

        } finally {
            close(null, ps, con);
        }
    }

    public static int deleteStaff(String staffID) throws Exception {
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

            return ps.executeUpdate();

        } finally {
            close(null, ps, con);
        }
    }

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
    
    //MICROSERVICE
    
    public static String getStaffIdByEmail(String email) {
        String sql = "SELECT STAFFID FROM STAFF WHERE STAFFEMAIL=?";

        try (Connection con = ConnectionManager.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

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

    public static boolean updatePassword(String staffId, String newPassword) {
        String sql = "UPDATE STAFF SET STAFFPASSWORD=? WHERE STAFFID=?";

        try (Connection con = ConnectionManager.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, newPassword);
            ps.setString(2, staffId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }
}