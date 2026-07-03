package vehicleBooking.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

import vehicleBooking.bean.CustomerBean;
import vehicleBooking.dao.CustDAO;

@WebServlet("/RegisterController")
public class RegisterController extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		response.sendRedirect("register.jsp");
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		try {
			String fullName = request.getParameter("fullName");
			String phone = request.getParameter("phone");
			String email = request.getParameter("email");
			String race = request.getParameter("race");
			String religion = request.getParameter("religion");
			String username = request.getParameter("username");
			String password = request.getParameter("password");
			String confirmPassword = request.getParameter("confirmPassword");

			System.out.println("fullName = " + fullName);
			System.out.println("phone = " + phone);
			System.out.println("email = " + email);
			System.out.println("race = " + race);
			System.out.println("religion = " + religion);
			System.out.println("username = " + username);
			System.out.println("password = " + password);
			System.out.println("confirmPassword = " + confirmPassword);

			if (fullName == null || phone == null || email == null || race == null
					|| religion == null || username == null || password == null || confirmPassword == null
					|| fullName.trim().isEmpty() || phone.trim().isEmpty() || email.trim().isEmpty()
					|| race.trim().isEmpty() || religion.trim().isEmpty() || username.trim().isEmpty()
					|| password.trim().isEmpty() || confirmPassword.trim().isEmpty()) {

				request.setAttribute("errorMessage", "Please fill in all required fields.");
				request.getRequestDispatcher("register.jsp").forward(request, response);
				return;
			}

			if (!password.equals(confirmPassword)) {
				request.setAttribute("errorMessage", "Password and confirm password do not match.");
				request.getRequestDispatcher("register.jsp").forward(request, response);
				return;
			}

			CustomerBean customer = new CustomerBean();

			customer.setCustName(fullName);
			customer.setCustPhoneNum(phone);
			customer.setCustEmail(email);
			customer.setCustRace(race);
			customer.setCustReligion(religion);
			customer.setCustUsername(username);
			customer.setCustPassword(password);

			int row = CustDAO.addCustomer(customer);

			if (row > 0) {
				request.setAttribute("successMessage", "Customer account created successfully. Please login.");
				request.getRequestDispatcher("login.jsp").forward(request, response);
			} else {
				request.setAttribute("errorMessage", "Account was not created. Please try again.");
				request.getRequestDispatcher("register.jsp").forward(request, response);
			}

		} catch (Exception e) {
			e.printStackTrace();

			request.setAttribute("errorMessage", "Error: " + e.getMessage());
			request.getRequestDispatcher("register.jsp").forward(request, response);
		}
	}
}