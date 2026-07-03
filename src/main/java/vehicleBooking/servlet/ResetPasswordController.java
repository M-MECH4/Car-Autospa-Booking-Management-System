package vehicleBooking.servlet;

import java.io.IOException;
import java.security.MessageDigest;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import vehicleBooking.dao.CustDAO;
import vehicleBooking.dao.StaffDAO;

@WebServlet("/ResetPasswordController")
public class ResetPasswordController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("resetVerified") == null) {
            response.sendRedirect(request.getContextPath() + "/forgotPassword.jsp");
            return;
        }

        String userId = (String) session.getAttribute("resetUserId");
        String role = (String) session.getAttribute("resetRole");

        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        if (newPassword == null || confirmPassword == null
                || newPassword.trim().isEmpty()
                || confirmPassword.trim().isEmpty()) {

            request.setAttribute("error", "Please enter password.");
            request.getRequestDispatcher("/resetPassword.jsp").forward(request, response);
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match.");
            request.getRequestDispatcher("/resetPassword.jsp").forward(request, response);
            return;
        }

        String hashedPassword = md5(newPassword);

        boolean updated;

        if ("customer".equalsIgnoreCase(role)) {
            updated = CustDAO.updatePassword(userId, hashedPassword);
        } else {
            updated = StaffDAO.updatePassword(userId, hashedPassword);
        }

        if (updated) {
            session.removeAttribute("resetUserId");
            session.removeAttribute("resetRole");
            session.removeAttribute("resetEmail");
            session.removeAttribute("resetVerified");

            response.sendRedirect(request.getContextPath() + "/login.jsp?reset=success");
        } else {
            request.setAttribute("error", "Failed to reset password.");
            request.getRequestDispatcher("/resetPassword.jsp").forward(request, response);
        }
    }

    private String md5(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            md.update(password.getBytes());

            byte[] byteData = md.digest();

            StringBuilder sb = new StringBuilder();

            for (byte b : byteData) {
                sb.append(String.format("%02x", b & 0xff));
            }

            return sb.toString();

        } catch (Exception e) {
            e.printStackTrace();
        }

        return password;
    }
}