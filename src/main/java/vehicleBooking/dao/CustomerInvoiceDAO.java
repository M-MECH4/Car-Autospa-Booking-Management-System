package vehicleBooking.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import vehicleBooking.ConnectionManager;
import vehicleBooking.bean.InvoiceBean;

public class CustomerInvoiceDAO {

    public static List<InvoiceBean> getCompletedInvoicesByCustomer(String custID, String customerName, String customerPhone) {

        List<InvoiceBean> invoiceList = new ArrayList<InvoiceBean>();

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql =
                "SELECT b.BOOKINGID, " +
                "       TO_CHAR(b.BOOKINGDATE, 'DD/MM/YYYY') AS BOOKINGDATE, " +
                "       TO_CHAR(b.BOOKINGDATE, 'DD/MM/YYYY') AS INVOICEDATE, " +
                "       b.BOOKINGSTATUS, " +
                "       v.VEHICLEPLATENUM, " +
                "       v.VEHICLEBRAND, " +
                "       v.VEHICLEMODEL, " +
                "       v.VEHICLEYEAR, " +
                "       p.PACKAGEID, " +
                "       p.PACKAGENAME, " +
                "       p.PACKAGEDESC, " +
                "       p.PACKAGEPRICE " +
                "FROM BOOKING b " +
                "JOIN VEHICLE v ON b.VEHICLEPLATENUM = v.VEHICLEPLATENUM " +
                "JOIN PACKAGE p ON b.PACKAGEID = p.PACKAGEID " +
                "WHERE v.CUSTID = ? " +
                "AND UPPER(b.BOOKINGSTATUS) = 'COMPLETED' " +
                "ORDER BY b.BOOKINGDATE DESC, b.BOOKINGTIME DESC";

        try {
            con = ConnectionManager.getConnection();

            ps = con.prepareStatement(sql);
            ps.setString(1, custID);

            rs = ps.executeQuery();

            while (rs.next()) {
                InvoiceBean inv = new InvoiceBean();

                String bookingID = rs.getString("BOOKINGID");

                inv.setBookingID(bookingID);
                inv.setInvoiceNo("INV-" + bookingID);
                inv.setBookingDate(rs.getString("BOOKINGDATE"));
                inv.setInvoiceDate(rs.getString("INVOICEDATE"));

                inv.setCustomerName(customerName);
                inv.setCustomerPhone(customerPhone);

                inv.setVehiclePlateNum(rs.getString("VEHICLEPLATENUM"));
                inv.setVehicleBrand(rs.getString("VEHICLEBRAND"));
                inv.setVehicleModel(rs.getString("VEHICLEMODEL"));
                inv.setVehicleYear(rs.getInt("VEHICLEYEAR"));

                inv.setPackageID(rs.getString("PACKAGEID"));
                inv.setPackageName(rs.getString("PACKAGENAME"));
                inv.setPackageDesc(rs.getString("PACKAGEDESC"));
                inv.setAmount(rs.getDouble("PACKAGEPRICE"));

                inv.setBookingStatus(rs.getString("BOOKINGSTATUS"));

                invoiceList.add(inv);
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(rs, ps, con);
        }

        return invoiceList;
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