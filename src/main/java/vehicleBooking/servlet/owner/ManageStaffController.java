

package vehicleBooking.servlet.owner;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Properties;

import vehicleBooking.bean.StaffBean;
import vehicleBooking.dao.StaffDAO;

@WebServlet("/ManageStaffController")
public class ManageStaffController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private static final String MANAGE_STAFF_PAGE = "/staff_owner/manage/manageStaff.jsp";

    private static final String FROM_EMAIL = "amsyarirfan2005@gmail.com";
    private static final String APP_PASSWORD = "lzrqnttzbsdetead";

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
            String keyword = request.getParameter("keyword");

            ArrayList<StaffBean> staffList = StaffDAO.getAllStaff(keyword);

            request.setAttribute("staffList", staffList);
            request.setAttribute("keyword", keyword);

            request.getRequestDispatcher(MANAGE_STAFF_PAGE).forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/ManageStaffController?msg=error");
        }
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

                String staffName = request.getParameter("staffName");
                String staffUsername = request.getParameter("staffUsername");
                String staffEmail = request.getParameter("staffEmail");
                String staffPhoneNum = request.getParameter("staffPhoneNum");
                String staffPassword = request.getParameter("staffPassword");

                if (isEmpty(staffName)
                        || isEmpty(staffUsername)
                        || isEmpty(staffEmail)
                        || isEmpty(staffPhoneNum)
                        || isEmpty(staffPassword)) {

                    response.sendRedirect(request.getContextPath() + "/ManageStaffController?msg=empty");
                    return;
                }

                staffName = staffName.trim();
                staffUsername = staffUsername.trim();
                staffEmail = staffEmail.trim();
                staffPhoneNum = staffPhoneNum.trim();
                staffPassword = staffPassword.trim();

                if (!isNumericPhone(staffPhoneNum)) {
                    response.sendRedirect(request.getContextPath() + "/ManageStaffController?msg=invalidPhone");
                    return;
                }

                if (!isStrongPassword(staffPassword)) {
                    response.sendRedirect(request.getContextPath() + "/ManageStaffController?msg=weakPassword");
                    return;
                }

                String generatedStaffID = StaffDAO.generateStaffID();

                StaffBean staff = new StaffBean();

                staff.setStaffID(generatedStaffID);
                staff.setStaffName(staffName);
                staff.setStaffUsername(staffUsername);
                staff.setStaffEmail(staffEmail);
                staff.setStaffPhoneNum(staffPhoneNum);
                staff.setStaffPassword(staffPassword);
                staff.setStaffRole("Staff");
                staff.setOwnerID(ownerID.trim().toUpperCase());

                int result = StaffDAO.addStaff(staff);

                if (result > 0) {
                    sendStaffCreatedEmail(
                            staffEmail,
                            staffName,
                            generatedStaffID,
                            staffUsername,
                            staffPassword
                    );

                    response.sendRedirect(request.getContextPath() + "/ManageStaffController?msg=success_create&newStaffID=" + generatedStaffID);
                } else {
                    response.sendRedirect(request.getContextPath() + "/ManageStaffController?msg=failed_create");
                }

                return;
            }

            if ("update".equalsIgnoreCase(action)) {

                String staffID = request.getParameter("staffID");
                String staffName = request.getParameter("staffName");
                String staffEmail = request.getParameter("staffEmail");
                String staffUsername = request.getParameter("staffUsername");
                String staffPhoneNum = request.getParameter("staffPhoneNum");

                if (isEmpty(staffID)
                        || isEmpty(staffName)
                        || isEmpty(staffEmail)
                        || isEmpty(staffUsername)
                        || isEmpty(staffPhoneNum)) {

                    response.sendRedirect(request.getContextPath() + "/ManageStaffController?msg=empty");
                    return;
                }

                staffPhoneNum = staffPhoneNum.trim();

                if (!isNumericPhone(staffPhoneNum)) {
                    response.sendRedirect(request.getContextPath() + "/ManageStaffController?msg=invalidPhone");
                    return;
                }

                int result = StaffDAO.updateStaffByOwner(
                        staffID.trim().toUpperCase(),
                        staffName.trim(),
                        staffEmail.trim(),
                        staffUsername.trim(),
                        staffPhoneNum
                );

                if (result > 0) {
                    response.sendRedirect(request.getContextPath() + "/ManageStaffController?msg=success_update");
                } else {
                    response.sendRedirect(request.getContextPath() + "/ManageStaffController?msg=failed_update");
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
                } else if (result == -1) {
                    response.sendRedirect(request.getContextPath() + "/ManageStaffController?msg=connectedData");
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

    private void sendStaffCreatedEmail(String toEmail, String staffName, String staffID, String username, String password) {
        try {
            Properties props = new Properties();

            props.put("mail.smtp.host", "smtp.gmail.com");
            props.put("mail.smtp.port", "587");
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");

            jakarta.mail.Session mailSession = jakarta.mail.Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(FROM_EMAIL, APP_PASSWORD);
                }
            });

            Message message = new MimeMessage(mailSession);
            message.setFrom(new InternetAddress(FROM_EMAIL));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject("X-PERT Detailing Staff Account Created");

            String body =
                    "Hello " + staffName + ",\n\n" +
                    "Your staff account has been created successfully.\n\n" +
                    "Staff ID: " + staffID + "\n" +
                    "Username: " + username + "\n" +
                    "Password: " + password + "\n\n" +
                    "Please log in to the X-PERT Detailing Management System.\n\n" +
                    "Thank you.";

            message.setText(body);
            Transport.send(message);

        } catch (Exception e) {
            e.printStackTrace();
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