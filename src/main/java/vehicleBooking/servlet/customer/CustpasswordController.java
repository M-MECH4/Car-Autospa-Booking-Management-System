package vehicleBooking.servlet.customer;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

import vehicleBooking.dao.CustDAO;

@WebServlet("/CustpasswordController")
public class CustpasswordController extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		response.sendRedirect(request.getContextPath() + "/customer/custPassword.jsp");
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		try {
			HttpSession session = request.getSession(false);

			if (session == null || session.getAttribute("custID") == null) {
				response.sendRedirect(request.getContextPath() + "/login.jsp");
				return;
			}

			String custID = request.getParameter("custID");
			String currentPassword = request.getParameter("currentPassword");
			String newPassword = request.getParameter("newPassword");
			String confirmPassword = request.getParameter("confirmPassword");

			if (custID == null || currentPassword == null || newPassword == null || confirmPassword == null
					|| custID.trim().isEmpty()
					|| currentPassword.trim().isEmpty()
					|| newPassword.trim().isEmpty()
					|| confirmPassword.trim().isEmpty()) {

				request.setAttribute("errorMessage", "Please fill in all password fields.");
				request.getRequestDispatcher("/customer/custPassword.jsp").forward(request, response);
				return;
			}

			if (!newPassword.equals(confirmPassword)) {
				request.setAttribute("errorMessage", "New password and confirm password do not match.");
				request.getRequestDispatcher("/customer/custPassword.jsp").forward(request, response);
				return;
			}

			if (!isStrongPassword(newPassword)) {
				request.setAttribute("errorMessage",
						"Password must contain at least 8 characters, one uppercase letter, one lowercase letter, one number, and one special character (!@#$%^&*).");
				request.getRequestDispatcher("/customer/custPassword.jsp").forward(request, response);
				return;
			}

			int row = CustDAO.Custpassword(custID, currentPassword, newPassword);

			if (row > 0) {
				request.setAttribute("successMessage", "Password updated successfully.");
				request.getRequestDispatcher("/customer/custPassword.jsp").forward(request, response);
				return;
			} else {
				request.setAttribute("errorMessage", "Current password is incorrect.");
				request.getRequestDispatcher("/customer/custPassword.jsp").forward(request, response);
				return;
			}

		} catch (Exception e) {
			e.printStackTrace();

			request.setAttribute("errorMessage", "Error: " + e.getMessage());
			request.getRequestDispatcher("/customer/custPassword.jsp").forward(request, response);
		}
	}

	private boolean isStrongPassword(String password) {
		String passwordPattern = "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)(?=.*[!@#$%^&*]).{8,}$";
		return password.matches(passwordPattern);
	}
}