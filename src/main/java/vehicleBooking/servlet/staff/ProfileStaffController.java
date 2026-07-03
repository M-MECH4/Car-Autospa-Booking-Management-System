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

        boolean updated = StaffDAO.updateStaffProfile(staffID, staffUsername, staffPhoneNum);

        if (updated) {
            session.setAttribute("staffUsername", staffUsername);
            session.setAttribute("staffPhoneNum", staffPhoneNum);

            if ("owner".equalsIgnoreCase(role)) {
                response.sendRedirect(request.getContextPath() + "/staff_owner/profile/ownerProfile.jsp?msg=success");
            } else {
                response.sendRedirect(request.getContextPath() + "/staff_owner/profile/staffProfile.jsp?msg=success");
            }

        } else {
            if ("owner".equalsIgnoreCase(role)) {
                response.sendRedirect(request.getContextPath() + "/staff_owner/profile/ownerProfile.jsp?msg=failed");
            } else {
                response.sendRedirect(request.getContextPath() + "/staff_owner/profile/staffProfile.jsp?msg=failed");
            }
        }
    }
}