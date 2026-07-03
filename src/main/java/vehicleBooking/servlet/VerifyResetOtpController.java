package vehicleBooking.servlet;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import vehicleBooking.util.OtpMicroserviceClient;

@WebServlet("/VerifyResetOtpController")
public class VerifyResetOtpController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("resetUserId") == null) {
            response.sendRedirect(request.getContextPath() + "/forgotPassword.jsp");
            return;
        }

        String otp = request.getParameter("otp");
        String userId = (String) session.getAttribute("resetUserId");
        String role = (String) session.getAttribute("resetRole");

        if (otp == null || otp.trim().isEmpty()) {
            request.setAttribute("error", "Please enter OTP.");
            request.getRequestDispatcher("/verifyResetOtp.jsp").forward(request, response);
            return;
        }

        boolean valid = OtpMicroserviceClient.verifyOtp(userId, role, otp.trim());

        if (valid) {
            session.setAttribute("resetVerified", true);
            response.sendRedirect(request.getContextPath() + "/resetPassword.jsp");
        } else {
            request.setAttribute("error", "Invalid or expired OTP.");
            request.getRequestDispatcher("/verifyResetOtp.jsp").forward(request, response);
        }
    }
}