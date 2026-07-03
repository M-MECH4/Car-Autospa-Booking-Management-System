package vehicleBooking.servlet;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import vehicleBooking.bean.ManageCustomerBean;
import vehicleBooking.dao.ManageCustomerDAO;

@WebServlet("/ManageCustomerController")
public class ManageCustomerController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private static final String PAGE = "/staff_owner/manage/manageCustomer.jsp";

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String role = (String) session.getAttribute("role");
        String staffRole = (String) session.getAttribute("staffRole");

        if (role == null || role.trim().isEmpty()) {
            role = staffRole;
        }

        if (role == null || (!"staff".equalsIgnoreCase(role) && !"owner".equalsIgnoreCase(role))) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String keyword = request.getParameter("keyword");

        List<ManageCustomerBean> customerList = ManageCustomerDAO.getAllCustomers(keyword);

        System.out.println("TOTAL CUSTOMER FOUND = " + customerList.size());

        request.setAttribute("customerList", customerList);
        request.setAttribute("keyword", keyword);

        RequestDispatcher rd = request.getRequestDispatcher(PAGE);
        rd.forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String role = (String) session.getAttribute("role");
        String staffRole = (String) session.getAttribute("staffRole");

        if (role == null || role.trim().isEmpty()) {
            role = staffRole;
        }

        if (role == null || (!"staff".equalsIgnoreCase(role) && !"owner".equalsIgnoreCase(role))) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");

        if ("delete".equalsIgnoreCase(action)) {
            String custID = request.getParameter("custID");

            int row = ManageCustomerDAO.deleteCustomer(custID);

            if (row > 0) {
                response.sendRedirect(request.getContextPath() + "/ManageCustomerController?msg=deleted");
            } else {
                response.sendRedirect(request.getContextPath() + "/ManageCustomerController?msg=deleteFailed");
            }

            return;
        }

        response.sendRedirect(request.getContextPath() + "/ManageCustomerController");
    }
}