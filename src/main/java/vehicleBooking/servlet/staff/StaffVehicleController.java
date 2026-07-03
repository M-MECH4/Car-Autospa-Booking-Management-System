package vehicleBooking.servlet.staff;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

import vehicleBooking.bean.VehicleBean;
import vehicleBooking.dao.VehicleDAO;

@WebServlet("/StaffVehicleController")
public class StaffVehicleController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public StaffVehicleController() {
        super();
        System.out.println("STAFF VEHICLE CONTROLLER LOADED");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("STAFF VEHICLE CONTROLLER GET RUNNING");

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("role") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String role = (String) session.getAttribute("role");

        if (!"staff".equalsIgnoreCase(role) && !"owner".equalsIgnoreCase(role)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        try {
            List<VehicleBean> vehicles = VehicleDAO.getAllVehiclesForStaff();

            request.setAttribute("vehicles", vehicles);

            request.getRequestDispatcher("/staff_owner/vehicle/staffVehicle.jsp")
                   .forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();

            request.setAttribute("errorMessage", "Error: " + e.getMessage());

            request.getRequestDispatcher("/staff_owner/vehicle/staffVehicle.jsp")
                   .forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        doGet(request, response);
    }
}