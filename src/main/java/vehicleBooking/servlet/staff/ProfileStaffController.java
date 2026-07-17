package vehicleBooking.servlet.staff;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import vehicleBooking.dao.StaffDAO;

@WebServlet("/ProfileStaffController")
public class ProfileStaffController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("staffID") == null || session.getAttribute("role") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String role = (String) session.getAttribute("role");

        if (!"staff".equalsIgnoreCase(role) && !"owner".equalsIgnoreCase(role)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String staffID = request.getParameter("staffID");
        String staffUsername = request.getParameter("staffUsername");
        String staffPhoneNum = request.getParameter("staffPhoneNum");

        if (staffPhoneNum == null || !staffPhoneNum.trim().matches("[0-9]+")) {
            redirectToProfile(request, response, role, "invalidPhone");
            return;
        }

        staffPhoneNum = staffPhoneNum.trim();

        boolean updated = StaffDAO.updateStaffProfile(staffID, staffUsername, staffPhoneNum);

        if (updated) {
            session.setAttribute("staffUsername", staffUsername);
            session.setAttribute("staffPhoneNum", staffPhoneNum);

            redirectToProfile(request, response, role, "success");
        } else {
            redirectToProfile(request, response, role, "failed");
        }
    }

    private void redirectToProfile(HttpServletRequest request, HttpServletResponse response,
            String role, String message) throws IOException {

        String page = "owner".equalsIgnoreCase(role)
                ? "/staff_owner/profile/ownerProfile.jsp"
                : "/staff_owner/profile/staffProfile.jsp";

        response.sendRedirect(request.getContextPath() + page + "?msg=" + message);
    }
}