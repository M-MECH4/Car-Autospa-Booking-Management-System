package vehicleBooking.servlet;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import vehicleBooking.bean.ManageCustomerBean;
import vehicleBooking.dao.ManageCustomerDAO;

@WebServlet("/ManageCustomerController")
public class ManageCustomerController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String PAGE = "/staff_owner/manage/manageCustomer.jsp";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);

        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String role = getRole(session);

        if (!isStaffOrOwner(role)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String keyword = request.getParameter("keyword");

        if (keyword == null) {
            keyword = "";
        }

        keyword = keyword.trim();

        List<ManageCustomerBean> customerList = ManageCustomerDAO.getAllCustomers(keyword);

        if (customerList == null) {
            customerList = new ArrayList<ManageCustomerBean>();
        }

        System.out.println("========== MANAGE CUSTOMER DEBUG ==========");
        System.out.println("ROLE = " + role);
        System.out.println("KEYWORD = " + keyword);
        System.out.println("TOTAL CUSTOMER FOUND = " + customerList.size());
        System.out.println("===========================================");

        request.setAttribute("customerList", customerList);
        request.setAttribute("keyword", keyword);

        RequestDispatcher rd = request.getRequestDispatcher(PAGE);
        rd.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);

        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String role = getRole(session);

        if (!isStaffOrOwner(role)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");

        if (action == null || action.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/ManageCustomerController");
            return;
        }

        if ("delete".equalsIgnoreCase(action)) {

            if (!"owner".equalsIgnoreCase(role)) {
                response.sendRedirect(request.getContextPath() + "/ManageCustomerController?msg=notAllowed");
                return;
            }

            deleteCustomer(request, response);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/ManageCustomerController");
    }

    private void deleteCustomer(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String custID = request.getParameter("custID");

        if (custID == null || custID.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/ManageCustomerController?msg=deleteFailed");
            return;
        }

        custID = custID.trim();

        boolean hasBooking = ManageCustomerDAO.hasBooking(custID);

        if (hasBooking) {
            response.sendRedirect(request.getContextPath() + "/ManageCustomerController?msg=connectedData");
            return;
        }

        int row = ManageCustomerDAO.deleteCustomerNoBooking(custID);

        if (row > 0) {
            response.sendRedirect(request.getContextPath() + "/ManageCustomerController?msg=deleted");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/ManageCustomerController?msg=deleteFailed");
    }

    private String getRole(HttpSession session) {

        String role = (String) session.getAttribute("role");
        String staffRole = (String) session.getAttribute("staffRole");

        if (role == null || role.trim().isEmpty()) {
            role = staffRole;
        }

        if (role == null) {
            role = "";
        }

        return role.trim();
    }

    private boolean isStaffOrOwner(String role) {
        return "staff".equalsIgnoreCase(role) || "owner".equalsIgnoreCase(role);
    }
}