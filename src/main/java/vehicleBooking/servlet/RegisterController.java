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

        response.sendRedirect(request.getContextPath() + "/register.jsp");
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        try {
            String fullName = request.getParameter("fullName");
            String phone = request.getParameter("phone");
            String email = request.getParameter("email");

            String race = request.getParameter("race");
            String religion = request.getParameter("religion");

            String username = request.getParameter("username");
            String password = request.getParameter("password");
            String confirmPassword = request.getParameter("confirmPassword");

            System.out.println("========== REGISTER CUSTOMER DEBUG ==========");
            System.out.println("Full Name = " + fullName);
            System.out.println("Phone = " + phone);
            System.out.println("Email = " + email);
            System.out.println("Race = " + race);
            System.out.println("Religion = " + religion);
            System.out.println("Username = " + username);
            System.out.println("=============================================");

            if (isEmpty(fullName)
                    || isEmpty(phone)
                    || isEmpty(email)
                    || isEmpty(race)
                    || isEmpty(religion)
                    || isEmpty(username)
                    || isEmpty(password)
                    || isEmpty(confirmPassword)) {

                request.setAttribute("errorMessage", "Please fill in all required fields.");
                request.getRequestDispatcher("/register.jsp").forward(request, response);
                return;
            }

            fullName = fullName.trim();
            phone = phone.trim();
            email = email.trim();
            race = race.trim().toUpperCase();
            religion = religion.trim().toUpperCase();
            username = username.trim();
            password = password.trim();
            confirmPassword = confirmPassword.trim();

            if (!isNumericPhone(phone)) {
                request.setAttribute("errorMessage", "Phone number must contain numbers only.");
                request.getRequestDispatcher("/register.jsp").forward(request, response);
                return;
            }

            if (!password.equals(confirmPassword)) {
                request.setAttribute("errorMessage", "Password and confirm password do not match.");
                request.getRequestDispatcher("/register.jsp").forward(request, response);
                return;
            }

            if (!isStrongPassword(password)) {
                request.setAttribute(
                        "errorMessage",
                        "Password must be at least 8 characters and include uppercase letter, lowercase letter, number, and special character (!@#$%^&*)."
                );
                request.getRequestDispatcher("/register.jsp").forward(request, response);
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
                request.setAttribute("successMessage", "Registration successful! Redirecting to login page...");
                request.setAttribute("redirectToLogin", "true");
                request.getRequestDispatcher("/register.jsp").forward(request, response);
                return;
            }

            request.setAttribute("errorMessage", "Account was not created. Please try again.");
            request.getRequestDispatcher("/register.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();

            request.setAttribute("errorMessage", "Registration failed. Username or email may already exist.");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
        }
    }

    private boolean isStrongPassword(String password) {
        if (password == null) {
            return false;
        }

        String passwordPattern = "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)(?=.*[!@#$%^&*]).{8,}$";
        return password.matches(passwordPattern);
    }

    private boolean isNumericPhone(String phone) {
        return phone != null && phone.matches("[0-9]+");
    }

    private boolean isEmpty(String value) {
        return value == null || value.trim().isEmpty();
    }
}