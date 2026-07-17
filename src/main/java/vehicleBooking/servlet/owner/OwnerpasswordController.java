package vehicleBooking.servlet.owner;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

import vehicleBooking.dao.StaffDAO;

@WebServlet("/OwnerpasswordController")
public class OwnerpasswordController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    public OwnerpasswordController() {
        super();
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        HttpSession session =
                request.getSession(false);

        if (!isValidOwnerSession(session)) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/login.jsp"
            );

            return;
        }

        response.sendRedirect(
                request.getContextPath()
                + "/staff_owner/profile/ownerPassword.jsp"
        );
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        request.setCharacterEncoding(
                "UTF-8"
        );

        response.setCharacterEncoding(
                "UTF-8"
        );

        HttpSession session =
                request.getSession(false);

        if (!isValidOwnerSession(session)) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/login.jsp"
            );

            return;
        }

        String staffID =
                (String) session.getAttribute(
                        "staffID"
                );

        String currentPassword =
                request.getParameter(
                        "currentPassword"
                );

        String newPassword =
                request.getParameter(
                        "newPassword"
                );

        String confirmPassword =
                request.getParameter(
                        "confirmPassword"
                );

        try {

            if (isEmpty(currentPassword)
                    || isEmpty(newPassword)
                    || isEmpty(confirmPassword)) {

                forwardWithError(
                        request,
                        response,
                        "Please fill in all password fields."
                );

                return;
            }

            currentPassword =
                    currentPassword.trim();

            newPassword =
                    newPassword.trim();

            confirmPassword =
                    confirmPassword.trim();

            if (!newPassword.equals(confirmPassword)) {

                forwardWithError(
                        request,
                        response,
                        "New password and confirm password do not match."
                );

                return;
            }

            if (currentPassword.equals(newPassword)) {

                forwardWithError(
                        request,
                        response,
                        "New password must be different from the current password."
                );

                return;
            }

            if (!isStrongPassword(newPassword)) {

                forwardWithError(
                        request,
                        response,
                        "Password must contain at least 8 characters, "
                        + "one uppercase letter, one lowercase letter, "
                        + "one number, and one special character "
                        + "(!@#$%^&*)."
                );

                return;
            }

            /*
             * Owners are stored inside the STAFF table.
             * Therefore, the existing StaffDAO password method
             * is also used for the owner.
             */
            int updatedRows =
                    StaffDAO.updateStaffPassword(
                            staffID,
                            currentPassword,
                            newPassword
                    );

            if (updatedRows > 0) {

                request.setAttribute(
                        "successMessage",
                        "Owner password updated successfully."
                );

                request.getRequestDispatcher(
                        "/staff_owner/profile/ownerPassword.jsp"
                ).forward(
                        request,
                        response
                );

                return;
            }

            forwardWithError(
                    request,
                    response,
                    "Current password is incorrect. "
                    + "Password was not changed."
            );

        } catch (Exception e) {

            e.printStackTrace();

            forwardWithError(
                    request,
                    response,
                    "Unable to update the owner password. "
                    + "Please try again."
            );
        }
    }

    private boolean isValidOwnerSession(
            HttpSession session) {

        if (session == null) {
            return false;
        }

        String role =
                (String) session.getAttribute(
                        "role"
                );

        String staffID =
                (String) session.getAttribute(
                        "staffID"
                );

        return "owner".equalsIgnoreCase(role)
                && staffID != null
                && !staffID.trim().isEmpty();
    }

    private boolean isEmpty(String value) {

        return value == null
                || value.trim().isEmpty();
    }

    private boolean isStrongPassword(
            String password) {

        String passwordPattern =
                "^(?=.*[A-Z])"
                + "(?=.*[a-z])"
                + "(?=.*\\d)"
                + "(?=.*[!@#$%^&*])"
                + ".{8,}$";

        return password.matches(
                passwordPattern
        );
    }

    private void forwardWithError(
            HttpServletRequest request,
            HttpServletResponse response,
            String message
    ) throws ServletException, IOException {

        request.setAttribute(
                "errorMessage",
                message
        );

        request.getRequestDispatcher(
                "/staff_owner/profile/ownerPassword.jsp"
        ).forward(
                request,
                response
        );
    }
}