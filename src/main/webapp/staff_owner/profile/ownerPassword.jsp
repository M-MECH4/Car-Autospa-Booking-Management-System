<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="vehicleBooking.bean.StaffBean" %>
<%@ page import="vehicleBooking.dao.StaffDAO" %>

<%!
    public String esc(String value) {

        if (value == null) {
            return "";
        }

        return value
                .replace("&", "&amp;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;")
                .replace("<", "&lt;")
                .replace(">", "&gt;");
    }
%>

<%
    response.setHeader(
            "Cache-Control",
            "no-cache,no-store,must-revalidate"
    );

    response.setHeader(
            "Pragma",
            "no-cache"
    );

    response.setDateHeader(
            "Expires",
            0
    );

    String role =
            (String) session.getAttribute(
                    "role"
            );

    String staffID =
            (String) session.getAttribute(
                    "staffID"
            );

    /*
     * Only logged-in owners may access this page.
     */
    if (role == null
            || !"owner".equalsIgnoreCase(role)
            || staffID == null
            || staffID.trim().isEmpty()) {

        response.sendRedirect(
                request.getContextPath()
                + "/login.jsp"
        );

        return;
    }

    String staffUsername =
            (String) session.getAttribute(
                    "staffUsername"
            );

    String staffPhoneNum =
            (String) session.getAttribute(
                    "staffPhoneNum"
            );

    String staffRole =
            (String) session.getAttribute(
                    "staffRole"
            );

    /*
     * Retrieve the latest owner information
     * from the STAFF table.
     */
    try {

        StaffBean owner =
                StaffDAO.getStaffByID(
                        staffID
                );

        if (owner != null) {

            staffID =
                    owner.getStaffID();

            staffUsername =
                    owner.getStaffUsername();

            staffPhoneNum =
                    owner.getStaffPhoneNum();

            staffRole =
                    owner.getStaffRole();

            session.setAttribute(
                    "staffID",
                    staffID
            );

            session.setAttribute(
                    "staffUsername",
                    staffUsername
            );

            session.setAttribute(
                    "staffPhoneNum",
                    staffPhoneNum
            );

            session.setAttribute(
                    "staffRole",
                    staffRole
            );
        }

    } catch (Exception e) {

        e.printStackTrace();
    }

    if (staffUsername == null
            || staffUsername.trim().isEmpty()) {

        staffUsername = "Owner";
    }

    if (staffPhoneNum == null
            || staffPhoneNum.trim().isEmpty()) {

        staffPhoneNum = "-";
    }

    if (staffRole == null
            || staffRole.trim().isEmpty()) {

        staffRole = "Owner";
    }

    String errorMessage =
            (String) request.getAttribute(
                    "errorMessage"
            );

    String successMessage =
            (String) request.getAttribute(
                    "successMessage"
            );
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <title>
        Change Password | Owner Account
    </title>

    <meta
        name="viewport"
        content="width=device-width, initial-scale=1.0">

    <link
        href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap"
        rel="stylesheet">

    <link
        rel="stylesheet"
        href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

    <!-- Reuse the existing staff password page design -->
    <link
        rel="stylesheet"
        href="${pageContext.request.contextPath}/css/staffPassword.css?v=<%= System.currentTimeMillis() %>">

    <link
        rel="stylesheet"
        href="${pageContext.request.contextPath}/css/sidebar.css?v=<%= System.currentTimeMillis() %>">

    <link
        rel="stylesheet"
        href="${pageContext.request.contextPath}/css/xpertTheme.css?v=<%= System.currentTimeMillis() %>">

    <script
        src="https://cdn.jsdelivr.net/npm/sweetalert2@11">
    </script>

</head>

<body>

<div class="xp-layout">

    <jsp:include page="/sidebar.jsp" />

    <main class="xp-main-content">

        <a
            href="${pageContext.request.contextPath}/staff_owner/profile/ownerProfile.jsp"
            class="back-link">

            <i class="fa-solid fa-arrow-left"></i>

            Back to Profile

        </a>

        <div class="topbar">

            <div>

                <h1>
                    Change Password
                </h1>

                <p>
                    Update your owner account password securely
                </p>

            </div>

        </div>

        <% if (errorMessage != null
                && !errorMessage.trim().isEmpty()) { %>

            <div class="message-box error-box">

                <%= esc(errorMessage) %>

            </div>

        <% } %>

        <% if (successMessage != null
                && !successMessage.trim().isEmpty()) { %>

            <div class="message-box success-box">

                <%= esc(successMessage) %>

            </div>

        <% } %>

        <form
            action="${pageContext.request.contextPath}/OwnerpasswordController"
            method="post"
            id="ownerPasswordForm">

            <div class="grid">

                <!-- OWNER INFORMATION -->
                <div class="card profile-card">

                    <div class="big-avatar">

                        <i class="fa-regular fa-user"></i>

                    </div>

                    <h2>
                        <%= esc(staffUsername) %>
                    </h2>

                    <p>
                        <%= esc(staffPhoneNum) %>
                    </p>

                    <div class="badge">

                        <i class="fa-solid fa-crown"></i>

                        Owner

                    </div>

                    <hr>

                    <div class="stats">

                        <div>

                            <h3>
                                <i class="fa-solid fa-lock"></i>
                            </h3>

                            <span>
                                Secure Account
                            </span>

                        </div>

                        <div>

                            <h3>
                                <i class="fa-solid fa-shield-halved"></i>
                            </h3>

                            <span>
                                Protected
                            </span>

                        </div>

                    </div>

                </div>

                <!-- PASSWORD FORM -->
                <div class="card info-card">

                    <h2>
                        Password Information
                    </h2>

                    <div class="field">

                        <label>
                            Owner ID
                        </label>

                        <div class="input-box readonly">

                            <i class="fa-solid fa-id-badge"></i>

                            <input
                                type="text"
                                value="<%= esc(staffID) %>"
                                readonly>

                        </div>

                    </div>

                    <div class="field">

                        <label>
                            Current Password
                        </label>

                        <div class="input-box">

                            <i class="fa-solid fa-lock"></i>

                            <input
                                type="password"
                                id="currentPassword"
                                name="currentPassword"
                                placeholder="Enter current password"
                                autocomplete="current-password"
                                required>

                        </div>

                    </div>

                    <div class="field">

                        <label>
                            New Password
                        </label>

                        <div class="input-box">

                            <i class="fa-solid fa-key"></i>

                            <input
                                type="password"
                                id="newPassword"
                                name="newPassword"
                                placeholder="Enter new password"
                                autocomplete="new-password"
                                minlength="8"
                                pattern="(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!@#$%^&amp;*]).{8,}"
                                title="Use at least 8 characters with uppercase, lowercase, number, and special character (!@#$%^&amp;*)."
                                required>

                        </div>

                    </div>

                    <div class="field">

                        <label>
                            Confirm New Password
                        </label>

                        <div class="input-box">

                            <i class="fa-solid fa-check"></i>

                            <input
                                type="password"
                                id="confirmPassword"
                                name="confirmPassword"
                                placeholder="Confirm new password"
                                autocomplete="new-password"
                                required>

                        </div>

                    </div>

                    <button
                        type="submit"
                        class="save-btn">

                        <i class="fa-solid fa-floppy-disk"></i>

                        Update Password

                    </button>

                </div>

            </div>

        </form>

    </main>

</div>

<script>

    const ownerPasswordForm =
            document.getElementById(
                    "ownerPasswordForm"
            );

    ownerPasswordForm.addEventListener(
            "submit",
            function (event) {

                const newPassword =
                        document.getElementById(
                                "newPassword"
                        ).value;

                const confirmPassword =
                        document.getElementById(
                                "confirmPassword"
                        ).value;

                if (newPassword !== confirmPassword) {

                    event.preventDefault();

                    Swal.fire({

                        icon: "error",

                        title: "Password does not match",

                        text:
                            "New password and confirm password "
                            + "must be the same."

                    });
                }
            }
    );

</script>

</body>

</html>