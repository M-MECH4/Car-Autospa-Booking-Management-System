package vehicleBooking.servlet.customer;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import vehicleBooking.bean.VehicleBean;
import vehicleBooking.dao.VehicleDAO;

@WebServlet("/custVehicleController")
public class custVehicleController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public custVehicleController() {
        super();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("custID") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");

        try {
            if (action == null || action.trim().isEmpty() || "list".equalsIgnoreCase(action)) {
                listVehicle(request, response, session);
                return;
            }

            if ("delete".equalsIgnoreCase(action)) {
                deleteVehicle(request, response, session);
                return;
            }

            session.setAttribute("errorMessage", "Invalid vehicle action.");
            response.sendRedirect(request.getContextPath() + "/custVehicleController?action=list");

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "Error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/custVehicleController?action=list");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("custID") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");

        try {
            if ("insert".equalsIgnoreCase(action) || "add".equalsIgnoreCase(action) || "create".equalsIgnoreCase(action)) {
                insertVehicle(request, response, session);
                return;
            }

            if ("update".equalsIgnoreCase(action)) {
                updateVehicle(request, response, session);
                return;
            }

            if ("delete".equalsIgnoreCase(action)) {
                deleteVehicle(request, response, session);
                return;
            }

            session.setAttribute("errorMessage", "Invalid vehicle action.");
            response.sendRedirect(request.getContextPath() + "/custVehicleController?action=list");

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "Error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/custVehicleController?action=list");
        }
    }

    private void listVehicle(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws Exception {

        String custID = (String) session.getAttribute("custID");

        List<VehicleBean> vehicleList = VehicleDAO.getVehiclesByCustomer(custID);

        request.setAttribute("vehicleList", vehicleList);
        request.setAttribute("vehicles", vehicleList);

        request.getRequestDispatcher("/customer/vehicle/vehicleList.jsp").forward(request, response);
    }

    private void insertVehicle(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws Exception {

        String custID = (String) session.getAttribute("custID");

        String vehicleplatenum = request.getParameter("vehicleplatenum");
        String vehiclebrand = request.getParameter("vehiclebrand");
        String vehiclemodel = request.getParameter("vehiclemodel");
        String vehicleyearStr = request.getParameter("vehicleyear");

        if (isEmpty(vehicleplatenum) || isEmpty(vehiclebrand) || isEmpty(vehiclemodel) || isEmpty(vehicleyearStr)) {
            session.setAttribute("errorMessage", "Please fill in all vehicle fields.");
            response.sendRedirect(request.getContextPath() + "/customer/vehicle/custVehicle.jsp");
            return;
        }

        if (!isValidVehicleYear(vehicleyearStr)) {
            session.setAttribute("errorMessage", "Vehicle year must be 4 digits and more than 1900.");
            response.sendRedirect(request.getContextPath() + "/customer/vehicle/custVehicle.jsp");
            return;
        }

        int vehicleyear = Integer.parseInt(vehicleyearStr.trim());

        VehicleBean vehicle = new VehicleBean();

        vehicle.setVehicleplatenum(vehicleplatenum.trim().toUpperCase());
        vehicle.setVehiclebrand(vehiclebrand.trim());
        vehicle.setVehiclemodel(vehiclemodel.trim());
        vehicle.setVehicleyear(vehicleyear);
        vehicle.setCustID(custID);

        int row = VehicleDAO.insertVehicle(vehicle);

        if (row > 0) {
            session.setAttribute("successMessage", "Vehicle added successfully.");
            response.sendRedirect(request.getContextPath() + "/custVehicleController?action=list");
            return;
        }

        session.setAttribute("errorMessage", "Vehicle failed to add.");
        response.sendRedirect(request.getContextPath() + "/customer/vehicle/custVehicle.jsp");
    }

    private void updateVehicle(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws Exception {

        String custID = (String) session.getAttribute("custID");

        String vehicleplatenum = request.getParameter("vehicleplatenum");
        String vehiclebrand = request.getParameter("vehiclebrand");
        String vehiclemodel = request.getParameter("vehiclemodel");
        String vehicleyearStr = request.getParameter("vehicleyear");

        if (isEmpty(vehicleplatenum) || isEmpty(vehiclebrand) || isEmpty(vehiclemodel) || isEmpty(vehicleyearStr)) {
            session.setAttribute("errorMessage", "Please fill in all vehicle fields.");
            response.sendRedirect(request.getContextPath() + "/custVehicleController?action=list");
            return;
        }

        if (!isValidVehicleYear(vehicleyearStr)) {
            session.setAttribute("errorMessage", "Vehicle year must be 4 digits and more than 1900.");
            response.sendRedirect(request.getContextPath() + "/custVehicleController?action=list");
            return;
        }

        int vehicleyear = Integer.parseInt(vehicleyearStr.trim());

        VehicleBean vehicle = new VehicleBean();

        vehicle.setVehicleplatenum(vehicleplatenum.trim().toUpperCase());
        vehicle.setVehiclebrand(vehiclebrand.trim());
        vehicle.setVehiclemodel(vehiclemodel.trim());
        vehicle.setVehicleyear(vehicleyear);
        vehicle.setCustID(custID);

        int row = VehicleDAO.updateVehicle(vehicle);

        if (row > 0) {
            session.setAttribute("successMessage", "Vehicle updated successfully.");
        } else {
            session.setAttribute("errorMessage", "Vehicle failed to update.");
        }

        response.sendRedirect(request.getContextPath() + "/custVehicleController?action=list");
    }

    private void deleteVehicle(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws Exception {

        String custID = (String) session.getAttribute("custID");

        String vehicleplatenum = request.getParameter("vehicleplatenum");

        if (isEmpty(vehicleplatenum)) {
            vehicleplatenum = request.getParameter("vehiclePlateNum");
        }

        if (isEmpty(vehicleplatenum)) {
            session.setAttribute("errorMessage", "Invalid vehicle plate number.");
            response.sendRedirect(request.getContextPath() + "/custVehicleController?action=list");
            return;
        }

        vehicleplatenum = vehicleplatenum.trim().toUpperCase();

        if (VehicleDAO.hasBookingConstraint(vehicleplatenum)) {
            session.setAttribute(
                    "errorMessage",
                    "This vehicle cannot be deleted because it is linked to an existing booking."
            );
            response.sendRedirect(request.getContextPath() + "/custVehicleController?action=list");
            return;
        }

        int row = VehicleDAO.deleteVehicle(vehicleplatenum, custID);

        if (row > 0) {
            session.setAttribute("successMessage", "Vehicle deleted successfully.");
        } else {
            session.setAttribute("errorMessage", "Vehicle failed to delete.");
        }

        response.sendRedirect(request.getContextPath() + "/custVehicleController?action=list");
    }

    private boolean isValidVehicleYear(String vehicleyearStr) {

        if (vehicleyearStr == null || vehicleyearStr.trim().isEmpty()) {
            return false;
        }

        vehicleyearStr = vehicleyearStr.trim();

        if (!vehicleyearStr.matches("\\d{4}")) {
            return false;
        }

        int year = Integer.parseInt(vehicleyearStr);

        return year > 1900;
    }

    private boolean isEmpty(String value) {
        return value == null || value.trim().isEmpty();
    }
}