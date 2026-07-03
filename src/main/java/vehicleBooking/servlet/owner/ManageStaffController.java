package vehicleBooking.servlet.owner;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.ArrayList;

import vehicleBooking.bean.StaffBean;
import vehicleBooking.dao.StaffDAO;

@WebServlet("/ManageStaffController")
public class ManageStaffController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private static final String MANAGE_STAFF_PAGE = "/staff_owner/manage/manageStaff.jsp";

    @Override
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

        if (role == null || !"owner".equalsIgnoreCase(role)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        try {
            ArrayList<StaffBean> staffList = StaffDAO.getAllStaff();

            request.setAttribute("staffList", staffList);

            request.getRequestDispatcher(MANAGE_STAFF_PAGE).forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/ManageStaffController?msg=error");
        }
    }

    @Override
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

        if (role == null || !"owner".equalsIgnoreCase(role)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");

        try {
            if ("create".equalsIgnoreCase(action)) {

                String ownerID = (String) session.getAttribute("staffID");

                if (ownerID == null || ownerID.trim().isEmpty()) {
                    ownerID = (String) session.getAttribute("ownerID");
                }

                if (ownerID == null || ownerID.trim().isEmpty()) {
                    response.sendRedirect(request.getContextPath() + "/ManageStaffController?msg=noOwner");
                    return;
                }

                String staffID = request.getParameter("staffID");
                String staffName = request.getParameter("staffName");
                String staffUsername = request.getParameter("staffUsername");
                String staffEmail = request.getParameter("staffEmail");
                String staffPhoneNum = request.getParameter("staffPhoneNum");
                String staffPassword = request.getParameter("staffPassword");

                if (isEmpty(staffID) || isEmpty(staffName) || isEmpty(staffUsername)
                        || isEmpty(staffEmail) || isEmpty(staffPhoneNum) || isEmpty(staffPassword)) {

                    response.sendRedirect(request.getContextPath() + "/ManageStaffController?msg=empty");
                    return;
                }

                StaffBean staff = new StaffBean();

                staff.setStaffID(staffID.trim().toUpperCase());
                staff.setStaffName(staffName.trim());
                staff.setStaffUsername(staffUsername.trim());
                staff.setStaffEmail(staffEmail.trim());
                staff.setStaffPhoneNum(staffPhoneNum.trim());
                staff.setStaffPassword(staffPassword.trim());
                staff.setStaffRole("Staff");
                staff.setOwnerID(ownerID.trim().toUpperCase());

                int result = StaffDAO.addStaff(staff);

                if (result > 0) {
                    response.sendRedirect(request.getContextPath() + "/ManageStaffController?msg=success_create");
                } else {
                    response.sendRedirect(request.getContextPath() + "/ManageStaffController?msg=failed_create");
                }

                return;
            }

            if ("delete".equalsIgnoreCase(action)) {

                String staffID = request.getParameter("staffID");

                if (isEmpty(staffID)) {
                    response.sendRedirect(request.getContextPath() + "/ManageStaffController?msg=invalid");
                    return;
                }

                int result = StaffDAO.deleteStaff(staffID.trim().toUpperCase());

                if (result > 0) {
                    response.sendRedirect(request.getContextPath() + "/ManageStaffController?msg=success_delete");
                } else {
                    response.sendRedirect(request.getContextPath() + "/ManageStaffController?msg=failed_delete");
                }

                return;
            }

            response.sendRedirect(request.getContextPath() + "/ManageStaffController");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/ManageStaffController?msg=error");
        }
    }

    private boolean isEmpty(String value) {
        return value == null || value.trim().isEmpty();
    }
}