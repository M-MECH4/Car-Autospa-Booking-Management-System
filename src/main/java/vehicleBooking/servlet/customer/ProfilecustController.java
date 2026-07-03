package vehicleBooking.servlet.customer;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

import vehicleBooking.bean.CustomerBean;
import vehicleBooking.dao.CustDAO;

@WebServlet("/ProfilecustController")
public class ProfilecustController extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		response.sendRedirect(request.getContextPath() + "/customer/customerProfile.jsp");
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
			String custName = request.getParameter("custName");
			String custUsername = request.getParameter("custUsername");
			String custEmail = request.getParameter("custEmail");
			String custPhoneNum = request.getParameter("custPhoneNum");

			if (custID == null || custName == null || custUsername == null || custEmail == null || custPhoneNum == null
					|| custID.trim().isEmpty()
					|| custName.trim().isEmpty()
					|| custUsername.trim().isEmpty()
					|| custEmail.trim().isEmpty()
					|| custPhoneNum.trim().isEmpty()) {

				request.setAttribute("errorMessage", "Please fill in all required fields.");
				request.getRequestDispatcher("/customer/customerProfile.jsp").forward(request, response);
				return;
			}

			CustomerBean customer = new CustomerBean();

			customer.setCustID(custID);
			customer.setCustName(custName);
			customer.setCustUsername(custUsername);
			customer.setCustEmail(custEmail);
			customer.setCustPhoneNum(custPhoneNum);

			int row = CustDAO.updateCustomerProfile(customer);

			if (row > 0) {

				session.setAttribute("custName", custName);
				session.setAttribute("custUsername", custUsername);
				session.setAttribute("custEmail", custEmail);
				session.setAttribute("custPhoneNum", custPhoneNum);

				session.setAttribute("name", custName);
				session.setAttribute("email", custEmail);

				request.setAttribute("successMessage", "Profile updated successfully.");
				request.getRequestDispatcher("/customer/customerProfile.jsp").forward(request, response);
				return;

			} else {
				request.setAttribute("errorMessage", "Profile was not updated. Please try again.");
				request.getRequestDispatcher("/customer/customerProfile.jsp").forward(request, response);
				return;
			}

		} catch (Exception e) {
			e.printStackTrace();

			request.setAttribute("errorMessage", "Error: " + e.getMessage());
			request.getRequestDispatcher("/customer/customerProfile.jsp").forward(request, response);
		}
	}
}