package vehicleBooking.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import vehicleBooking.ConnectionManager;
import vehicleBooking.bean.InvoiceBean;

public class StaffInvoiceDAO {

    public static List<InvoiceBean> getCompletedInvoicesForStaff() {

        List<InvoiceBean> invoiceList = new ArrayList<InvoiceBean>();

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql =
                "SELECT " +
                "'INV-' || b.BOOKINGID AS INVOICENO, " +
                "TO_CHAR(SYSDATE, 'DD/MM/YYYY') AS INVOICEDATE, " +
                "b.BOOKINGID, " +
                "TO_CHAR(b.BOOKINGDATE, 'DD/MM/YYYY') AS BOOKINGDATE, " +
                "b.BOOKINGSTATUS, " +

                "c.CUSTNAME, " +
                "c.CUSTPHONENUM, " +

                "v.VEHICLEPLATENUM, " +
                "v.VEHICLEBRAND, " +
                "v.VEHICLEMODEL, " +
                "v.VEHICLEYEAR, " +

                "p.PACKAGEID, " +
                "p.PACKAGENAME, " +
                "p.PACKAGEDESC, " +
                "p.PACKAGEPRICE AS AMOUNT " +

                "FROM BOOKING b " +
                "INNER JOIN VEHICLE v ON b.VEHICLEPLATENUM = v.VEHICLEPLATENUM " +
                "INNER JOIN CUSTOMER c ON v.CUSTID = c.CUSTID " +
                "INNER JOIN PACKAGE p ON b.PACKAGEID = p.PACKAGEID " +
                "WHERE UPPER(b.BOOKINGSTATUS) = 'COMPLETED' " +
                "ORDER BY b.BOOKINGDATE DESC, b.BOOKINGTIME DESC";

        try {
            con = ConnectionManager.getConnection();

            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                InvoiceBean invoice = new InvoiceBean();

                invoice.setInvoiceNo(rs.getString("INVOICENO"));
                invoice.setInvoiceDate(rs.getString("INVOICEDATE"));
                invoice.setBookingID(rs.getString("BOOKINGID"));
                invoice.setBookingDate(rs.getString("BOOKINGDATE"));
                invoice.setBookingStatus(rs.getString("BOOKINGSTATUS"));

                invoice.setCustomerName(rs.getString("CUSTNAME"));
                invoice.setCustomerPhone(rs.getString("CUSTPHONENUM"));

                invoice.setVehiclePlateNum(rs.getString("VEHICLEPLATENUM"));
                invoice.setVehicleBrand(rs.getString("VEHICLEBRAND"));
                invoice.setVehicleModel(rs.getString("VEHICLEMODEL"));
                invoice.setVehicleYear(rs.getInt("VEHICLEYEAR"));

                invoice.setPackageID(rs.getString("PACKAGEID"));
                invoice.setPackageName(rs.getString("PACKAGENAME"));
                invoice.setPackageDesc(rs.getString("PACKAGEDESC"));
                invoice.setAmount(rs.getDouble("AMOUNT"));

                invoiceList.add(invoice);
            }

        } catch (Exception e) {
            e.printStackTrace();

        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (con != null) con.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        return invoiceList;
    }
}