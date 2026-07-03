package vehicleBooking.servlet;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import vehicleBooking.dao.CustDAO;
import vehicleBooking.dao.StaffDAO;
import vehicleBooking.util.OtpMicroserviceClient;

@WebServlet("/ForgotPasswordController")
public class ForgotPasswordController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.sendRedirect(request.getContextPath() + "/forgotPassword.jsp");
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String role = request.getParameter("role");

        if (email == null || email.trim().isEmpty()
                || role == null || role.trim().isEmpty()) {

            request.setAttribute("error", "Please enter your email and role.");
            request.getRequestDispatcher("/forgotPassword.jsp").forward(request, response);
            return;
        }

        email = email.trim();
        role = role.trim().toLowerCase();

        String userId = null;

        if ("customer".equalsIgnoreCase(role)) {
            userId = CustDAO.getCustIdByEmail(email);
        } else if ("staff".equalsIgnoreCase(role) || "owner".equalsIgnoreCase(role)) {
            userId = StaffDAO.getStaffIdByEmail(email);
        }

        if (userId == null) {
            request.setAttribute("error", "Email not found.");
            request.getRequestDispatcher("/forgotPassword.jsp").forward(request, response);
            return;
        }

        boolean sent = OtpMicroserviceClient.createOtp(userId, role, email);

        if (!sent) {
            request.setAttribute("error", "Failed to send OTP. Make sure otp-service is running.");
            request.getRequestDispatcher("/forgotPassword.jsp").forward(request, response);
            return;
        }

        HttpSession session = request.getSession();
        session.setAttribute("resetUserId", userId);
        session.setAttribute("resetRole", role);
        session.setAttribute("resetEmail", email);

        response.sendRedirect(request.getContextPath() + "/verifyResetOtp.jsp");
    }
}