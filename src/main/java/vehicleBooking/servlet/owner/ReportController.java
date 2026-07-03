package vehicleBooking.servlet.owner;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.ArrayList;

import vehicleBooking.bean.BookingBean;
import vehicleBooking.bean.PackageBean;
import vehicleBooking.bean.CustomerBean;
import vehicleBooking.dao.ReportDAO;

@WebServlet("/ReportController")
public class ReportController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

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

        String period = request.getParameter("period");

        ArrayList<BookingBean> bookingList = new ArrayList<BookingBean>();
        ArrayList<PackageBean> packageList = new ArrayList<PackageBean>();
        ArrayList<CustomerBean> customerList = new ArrayList<CustomerBean>();

        boolean generated = false;
        String reportTitle = "Please select report type";

        if (period != null && !period.trim().isEmpty()) {
            period = period.trim().toLowerCase();

            if ("weekly".equalsIgnoreCase(period) || "monthly".equalsIgnoreCase(period)) {
                bookingList = ReportDAO.getAllBookings(period);
                packageList = ReportDAO.getAllPackages();
                customerList = ReportDAO.getAllCustomers();

                generated = true;

                if ("weekly".equalsIgnoreCase(period)) {
                    reportTitle = "Weekly Sales Report";
                } else {
                    reportTitle = "Monthly Sales Report";
                }
            }
        } else {
            period = "";
        }

        request.setAttribute("bookingList", bookingList);
        request.setAttribute("packageList", packageList);
        request.setAttribute("customerList", customerList);
        request.setAttribute("period", period);
        request.setAttribute("generated", generated);
        request.setAttribute("reportTitle", reportTitle);

        RequestDispatcher rd = request.getRequestDispatcher("/staff_owner/report/staffReport.jsp");
        rd.forward(request, response);
    }
}