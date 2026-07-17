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

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        try {
            HttpSession session = request.getSession(false);

            if (session == null || session.getAttribute("custID") == null) {
                response.sendRedirect(request.getContextPath() + "/login.jsp");
                return;
            }

            String role = (String) session.getAttribute("role");

            if (role == null || !"customer".equalsIgnoreCase(role)) {
                response.sendRedirect(request.getContextPath() + "/login.jsp");
                return;
            }

            String custID = (String) session.getAttribute("custID");

            String custName = request.getParameter("custName");
            String custPhoneNum = request.getParameter("custPhoneNum");
            String custEmail = request.getParameter("custEmail");
            String custUsername = request.getParameter("custUsername");

            if (isEmpty(custID)
                    || isEmpty(custName)
                    || isEmpty(custPhoneNum)
                    || isEmpty(custEmail)
                    || isEmpty(custUsername)) {

                request.setAttribute("errorMessage", "Please fill in all required fields.");
                request.setAttribute("editMode", "true");
                request.getRequestDispatcher("/customer/customerProfile.jsp").forward(request, response);
                return;
            }

            custName = custName.trim();
            custPhoneNum = custPhoneNum.trim();
            custEmail = custEmail.trim();
            custUsername = custUsername.trim();

            if (!isNumericPhone(custPhoneNum)) {
                request.setAttribute("errorMessage", "Phone number must contain numbers only.");
                request.setAttribute("editMode", "true");
                request.getRequestDispatcher("/customer/customerProfile.jsp").forward(request, response);
                return;
            }

            if (CustDAO.emailExistsForOtherCustomer(custEmail, custID)) {
                request.setAttribute("errorMessage", "This email is already used by another customer.");
                request.setAttribute("editMode", "true");
                request.getRequestDispatcher("/customer/customerProfile.jsp").forward(request, response);
                return;
            }

            CustomerBean customer = new CustomerBean();

            customer.setCustID(custID);
            customer.setCustName(custName);
            customer.setCustPhoneNum(custPhoneNum);
            customer.setCustEmail(custEmail);
            customer.setCustUsername(custUsername);

            int row = CustDAO.updateCustomerProfile(customer);

            if (row > 0) {

                CustomerBean updatedCustomer = CustDAO.getCustomerById(custID);

                if (updatedCustomer != null) {
                    session.setAttribute("custName", updatedCustomer.getCustName());
                    session.setAttribute("custPhoneNum", updatedCustomer.getCustPhoneNum());
                    session.setAttribute("custEmail", updatedCustomer.getCustEmail());
                    session.setAttribute("custUsername", updatedCustomer.getCustUsername());
                    session.setAttribute("custRace", updatedCustomer.getCustRace());
                    session.setAttribute("custReligion", updatedCustomer.getCustReligion());

                    session.setAttribute("name", updatedCustomer.getCustName());
                    session.setAttribute("email", updatedCustomer.getCustEmail());
                } else {
                    session.setAttribute("custName", custName);
                    session.setAttribute("custPhoneNum", custPhoneNum);
                    session.setAttribute("custEmail", custEmail);
                    session.setAttribute("custUsername", custUsername);

                    session.setAttribute("name", custName);
                    session.setAttribute("email", custEmail);
                }

                request.setAttribute("successMessage", "Profile updated successfully.");
                request.getRequestDispatcher("/customer/customerProfile.jsp").forward(request, response);
                return;
            }

            request.setAttribute("errorMessage", "Profile was not updated. Please try again.");
            request.setAttribute("editMode", "true");
            request.getRequestDispatcher("/customer/customerProfile.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();

            request.setAttribute("errorMessage", "Error: " + e.getMessage());
            request.setAttribute("editMode", "true");
            request.getRequestDispatcher("/customer/customerProfile.jsp").forward(request, response);
        }
    }

    private boolean isNumericPhone(String phone) {
        return phone != null && phone.matches("[0-9]+");
    }

    private boolean isEmpty(String value) {
        return value == null || value.trim().isEmpty();
    }
}