package vehicleBooking.servlet.staff;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

import vehicleBooking.dao.StaffDAO;

@WebServlet("/StaffpasswordController")
public class StaffpasswordController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public StaffpasswordController() {
        super();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.sendRedirect(request.getContextPath() + "/staff_owner/profile/staffPassword.jsp");
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            HttpSession session = request.getSession(false);

            if (session == null || session.getAttribute("staffID") == null) {
                response.sendRedirect(request.getContextPath() + "/login.jsp");
                return;
            }

            String role = (String) session.getAttribute("role");

            if (role == null || !"staff".equalsIgnoreCase(role)) {
                response.sendRedirect(request.getContextPath() + "/login.jsp");
                return;
            }

            String staffID = (String) session.getAttribute("staffID");

            String currentPassword = request.getParameter("currentPassword");
            String newPassword = request.getParameter("newPassword");
            String confirmPassword = request.getParameter("confirmPassword");

            if (currentPassword == null || newPassword == null || confirmPassword == null
                    || currentPassword.trim().isEmpty()
                    || newPassword.trim().isEmpty()
                    || confirmPassword.trim().isEmpty()) {

                request.setAttribute("errorMessage", "Please fill in all password fields.");
                request.getRequestDispatcher("/staff_owner/profile/staffPassword.jsp").forward(request, response);
                return;
            }

            currentPassword = currentPassword.trim();
            newPassword = newPassword.trim();
            confirmPassword = confirmPassword.trim();

            if (!newPassword.equals(confirmPassword)) {
                request.setAttribute("errorMessage", "New password and confirm password do not match.");
                request.getRequestDispatcher("/staff_owner/profile/staffPassword.jsp").forward(request, response);
                return;
            }

            if (!isStrongPassword(newPassword)) {
                request.setAttribute("errorMessage",
                        "Password must contain at least 8 characters, one uppercase letter, one lowercase letter, one number, and one special character (!@#$%^&*).");
                request.getRequestDispatcher("/staff_owner/profile/staffPassword.jsp").forward(request, response);
                return;
            }

            int row = StaffDAO.updateStaffPassword(staffID, currentPassword, newPassword);

            if (row > 0) {
                request.setAttribute("successMessage", "Password updated successfully in database.");
                request.getRequestDispatcher("/staff_owner/profile/staffPassword.jsp").forward(request, response);
                return;
            }

            request.setAttribute("errorMessage", "Current password is incorrect. Database was not updated.");
            request.getRequestDispatcher("/staff_owner/profile/staffPassword.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();

            request.setAttribute("errorMessage", "Error: " + e.getMessage());
            request.getRequestDispatcher("/staff_owner/profile/staffPassword.jsp").forward(request, response);
        }
    }

    private boolean isStrongPassword(String password) {
        String passwordPattern = "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)(?=.*[!@#$%^&*]).{8,}$";
        return password.matches(passwordPattern);
    }
}