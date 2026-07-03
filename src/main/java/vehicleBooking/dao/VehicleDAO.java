package vehicleBooking.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import vehicleBooking.ConnectionManager;
import vehicleBooking.bean.VehicleBean;

public class VehicleDAO {

    public static int insertVehicle(VehicleBean vehicle) throws Exception {

        Connection con = null;
        PreparedStatement ps = null;

        String sql =
                "INSERT INTO VEHICLE " +
                "(VEHICLEPLATENUM, VEHICLEBRAND, VEHICLEMODEL, VEHICLEYEAR, CUSTID) " +
                "VALUES (?, ?, ?, ?, ?)";

        try {
            con = ConnectionManager.getConnection();
            ps = con.prepareStatement(sql);

            ps.setString(1, vehicle.getVehicleplatenum());
            ps.setString(2, vehicle.getVehiclebrand());
            ps.setString(3, vehicle.getVehiclemodel());
            ps.setInt(4, vehicle.getVehicleyear());
            ps.setString(5, vehicle.getCustID());

            System.out.println("INSERT VEHICLE CUSTID = " + vehicle.getCustID());
            System.out.println("INSERT VEHICLE PLATE = " + vehicle.getVehicleplatenum());

            int row = ps.executeUpdate();

            System.out.println("INSERT VEHICLE ROW = " + row);

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

    public static List<VehicleBean> getVehiclesByCustomer(String custID) throws Exception {

        List<VehicleBean> vehicleList = new ArrayList<>();

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql =
                "SELECT VEHICLEPLATENUM, VEHICLEBRAND, VEHICLEMODEL, VEHICLEYEAR, CUSTID " +
                "FROM VEHICLE " +
                "WHERE CUSTID = ? " +
                "ORDER BY VEHICLEPLATENUM";

        try {
            con = ConnectionManager.getConnection();
            ps = con.prepareStatement(sql);

            ps.setString(1, custID);

            System.out.println("GET VEHICLE BY CUSTID = " + custID);

            rs = ps.executeQuery();

            while (rs.next()) {
                VehicleBean vehicle = new VehicleBean();

                vehicle.setVehicleplatenum(rs.getString("VEHICLEPLATENUM"));
                vehicle.setVehiclebrand(rs.getString("VEHICLEBRAND"));
                vehicle.setVehiclemodel(rs.getString("VEHICLEMODEL"));
                vehicle.setVehicleyear(rs.getInt("VEHICLEYEAR"));
                vehicle.setCustID(rs.getString("CUSTID"));

                vehicleList.add(vehicle);
            }

            System.out.println("DAO VEHICLE FOUND = " + vehicleList.size());

            return vehicleList;

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

    public static List<VehicleBean> getAllVehiclesForStaff() throws Exception {

        List<VehicleBean> vehicles = new ArrayList<>();

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql =
                "SELECT v.VEHICLEPLATENUM, v.VEHICLEBRAND, v.VEHICLEMODEL, v.VEHICLEYEAR, v.CUSTID, " +
                "c.CUSTNAME, c.CUSTUSERNAME, c.CUSTEMAIL, c.CUSTPHONENUM " +
                "FROM VEHICLE v " +
                "LEFT JOIN CUSTOMER c ON v.CUSTID = c.CUSTID " +
                "ORDER BY v.VEHICLEPLATENUM";

        try {
            con = ConnectionManager.getConnection();
            ps = con.prepareStatement(sql);

            rs = ps.executeQuery();

            while (rs.next()) {
                VehicleBean vehicle = new VehicleBean();

                vehicle.setVehicleplatenum(rs.getString("VEHICLEPLATENUM"));
                vehicle.setVehiclebrand(rs.getString("VEHICLEBRAND"));
                vehicle.setVehiclemodel(rs.getString("VEHICLEMODEL"));
                vehicle.setVehicleyear(rs.getInt("VEHICLEYEAR"));
                vehicle.setCustID(rs.getString("CUSTID"));

                vehicle.setCustName(rs.getString("CUSTNAME"));
                vehicle.setCustUsername(rs.getString("CUSTUSERNAME"));
                vehicle.setCustEmail(rs.getString("CUSTEMAIL"));
                vehicle.setCustPhoneNum(rs.getString("CUSTPHONENUM"));

                vehicles.add(vehicle);
            }

            return vehicles;

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

    public static int updateVehicle(VehicleBean vehicle) throws Exception {

        Connection con = null;
        PreparedStatement ps = null;

        String sql =
                "UPDATE VEHICLE " +
                "SET VEHICLEBRAND = ?, VEHICLEMODEL = ?, VEHICLEYEAR = ? " +
                "WHERE VEHICLEPLATENUM = ? " +
                "AND CUSTID = ?";

        try {
            con = ConnectionManager.getConnection();
            ps = con.prepareStatement(sql);

            ps.setString(1, vehicle.getVehiclebrand());
            ps.setString(2, vehicle.getVehiclemodel());
            ps.setInt(3, vehicle.getVehicleyear());
            ps.setString(4, vehicle.getVehicleplatenum());
            ps.setString(5, vehicle.getCustID());

            int row = ps.executeUpdate();

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

    public static int deleteVehicle(String vehicleplatenum, String custID) throws Exception {

        Connection con = null;
        PreparedStatement ps = null;

        String sql =
                "DELETE FROM VEHICLE " +
                "WHERE VEHICLEPLATENUM = ? " +
                "AND CUSTID = ?";

        try {
            con = ConnectionManager.getConnection();
            ps = con.prepareStatement(sql);

            ps.setString(1, vehicleplatenum);
            ps.setString(2, custID);

            int row = ps.executeUpdate();

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
}