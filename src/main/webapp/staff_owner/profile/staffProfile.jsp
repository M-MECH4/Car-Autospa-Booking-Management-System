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

    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    String role =
            (String) session.getAttribute("role");

    String staffID =
            (String) session.getAttribute("staffID");

    String staffUsername =
            (String) session.getAttribute("staffUsername");

    String staffPhoneNum =
            (String) session.getAttribute("staffPhoneNum");

    String staffRole =
            (String) session.getAttribute("staffRole");

    /*
     * Only staff users can access this page.
     */
    if (role == null
            || !"staff".equalsIgnoreCase(role)
            || ((staffID == null || staffID.trim().isEmpty())
            && (staffUsername == null
            || staffUsername.trim().isEmpty()))) {

        response.sendRedirect(
                request.getContextPath() + "/login.jsp"
        );

        return;
    }

    /*
     * Retrieve the latest staff details from the database.
     * Staff ID is preferred because the username can be updated.
     */
    StaffBean staff = null;

    try {
        if (staffID != null
                && !staffID.trim().isEmpty()) {

            staff = StaffDAO.getStaffByID(staffID);

        } else {
            staff = StaffDAO.getStaffByUsername(
                    staffUsername
            );
        }

        if (staff != null) {
            staffID = staff.getStaffID();
            staffUsername = staff.getStaffUsername();
            staffPhoneNum = staff.getStaffPhoneNum();
            staffRole = staff.getStaffRole();

            /*
             * Keep the session data synchronized
             * with the database.
             */
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

    if (staffID == null
            || staffID.trim().isEmpty()) {

        staffID = "-";
    }

    if (staffUsername == null
            || staffUsername.trim().isEmpty()) {

        staffUsername = "Staff";
    }

    if (staffPhoneNum == null
            || staffPhoneNum.trim().isEmpty()) {

        staffPhoneNum = "-";
    }

    if (staffRole == null
            || staffRole.trim().isEmpty()) {

        staffRole = "Staff";
    }

    String msg =
            request.getParameter("msg");
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <title>
        Staff Account | Staff Profile
    </title>

    <meta
        name="viewport"
        content="width=device-width, initial-scale=1.0"
    >

    <link
        href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap"
        rel="stylesheet"
    >

    <link
        rel="stylesheet"
        href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"
    >

    <link
        rel="stylesheet"
        href="${pageContext.request.contextPath}/css/staffProfile.css?v=<%= System.currentTimeMillis() %>"
    >

    <link
        rel="stylesheet"
        href="${pageContext.request.contextPath}/css/sidebar.css?v=<%= System.currentTimeMillis() %>"
    >

    <link
        rel="stylesheet"
        href="${pageContext.request.contextPath}/css/xpertTheme.css?v=<%= System.currentTimeMillis() %>"
    >

    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

</head>

<body>

<div class="xp-layout">

    <jsp:include page="/sidebar.jsp" />

    <main class="xp-main-content">

        <a
            href="${pageContext.request.contextPath}/staff_owner/staffDashboard.jsp"
            class="back-link"
        >

            <i class="fa-solid fa-arrow-left"></i>

            Back to Dashboard

        </a>

        <div class="topbar">

            <div>

                <h1>
                    Staff Account
                </h1>

                <p>
                    View and manage your staff profile information
                </p>

            </div>

        </div>

        <% if ("success".equalsIgnoreCase(msg)) { %>

            <div class="message-box success-box">

                <i class="fa-solid fa-circle-check"></i>

                Staff profile updated successfully.

            </div>

        <% } else if ("invalidPhone".equalsIgnoreCase(msg)) { %>

            <div class="message-box error-box">

                <i class="fa-solid fa-triangle-exclamation"></i>

                Phone number must contain numbers only.

            </div>

        <% } else if ("failed".equalsIgnoreCase(msg)) { %>

            <div class="message-box error-box">

                <i class="fa-solid fa-circle-xmark"></i>

                Failed to update the staff profile.
                The username may already be used by another account.

            </div>

        <% } %>

        <form
            action="${pageContext.request.contextPath}/ProfileStaffController"
            method="post"
        >

            <input
                type="hidden"
                name="staffID"
                value="<%= esc(staffID) %>"
            >

            <div class="grid">

                <!-- STAFF SUMMARY CARD -->
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

                        <i class="fa-solid fa-shield"></i>

                        Staff

                    </div>

                    <hr>

                    <div class="stats">

                        <div>

                            <h3>
                                0
                            </h3>

                            <span>
                                Total Tasks
                            </span>

                        </div>

                        <div>

                            <h3>
                                0
                            </h3>

                            <span>
                                Completed
                            </span>

                        </div>

                    </div>

                </div>

                <!-- STAFF PROFILE INFORMATION -->
                <div class="card info-card">

                    <h2>
                        Profile Information
                    </h2>

                    <!-- STAFF ID -->
                    <div class="field">

                        <label>
                            Staff ID
                        </label>

                        <div class="input-box readonly">

                            <i class="fa-solid fa-id-badge"></i>

                            <input
                                type="text"
                                value="<%= esc(staffID) %>"
                                readonly
                            >

                        </div>

                    </div>

                    <!-- STAFF USERNAME -->
                    <div class="field">

                        <label>
                            Staff Username
                        </label>

                        <div
                            class="input-box readonly"
                            id="boxStaffUsername"
                        >

                            <i class="fa-solid fa-id-card"></i>

                            <input
                                type="text"
                                name="staffUsername"
                                id="staffUsername"
                                value="<%= esc(staffUsername) %>"
                                required
                                readonly
                            >

                        </div>

                    </div>

                    <!-- STAFF PHONE NUMBER -->
                    <div class="field">

                        <label>
                            Phone Number
                        </label>

                        <div
                            class="input-box readonly"
                            id="boxStaffPhoneNum"
                        >

                            <i class="fa-solid fa-phone"></i>

                            <input
                                type="text"
                                name="staffPhoneNum"
                                id="staffPhoneNum"
                                inputmode="numeric"
                                pattern="[0-9]+"
                                maxlength="20"
                                title="Phone number must contain numbers only."
                                oninput="this.value = this.value.replace(/[^0-9]/g, '')"
                                value="<%= esc(staffPhoneNum) %>"
                                required
                                readonly
                            >

                        </div>

                    </div>

                    <!-- STAFF ROLE -->
                    <div class="field">

                        <label>
                            Staff Role
                        </label>

                        <div class="input-box readonly">

                            <i class="fa-solid fa-user-gear"></i>

                            <input
                                type="text"
                                value="<%= esc(staffRole) %>"
                                readonly
                            >

                        </div>

                    </div>

                    <!-- EDIT BUTTON -->
                    <button
                        type="button"
                        class="save-btn"
                        id="editBtn"
                        onclick="enableEditMode()"
                    >
                        Edit
                    </button>

                    <!-- SAVE BUTTON -->
                    <button
                        type="submit"
                        class="save-btn"
                        id="saveBtn"
                        hidden
                    >
                        Save
                    </button>

                </div>

                <!-- SECURITY SETTINGS -->
                <div class="card security-card">

                    <h2>
                        Security Settings
                    </h2>

                    <div class="security-box">

                        <div class="security-left">

                            <i class="fa-solid fa-shield"></i>

                            <div>

                                <h4>
                                    Change Password
                                </h4>

                                <p>
                                    Update your staff account password
                                </p>

                            </div>

                        </div>

                        <a
                            href="${pageContext.request.contextPath}/staff_owner/profile/staffPassword.jsp"
                            class="icon-btn"
                        >

                            <i class="fa-solid fa-pen"></i>

                        </a>

                    </div>

                </div>

            </div>

        </form>

    </main>

</div>

<script>

    function enableEditMode() {

        const usernameInput =
                document.getElementById("staffUsername");

        const phoneInput =
                document.getElementById("staffPhoneNum");

        const usernameBox =
                document.getElementById("boxStaffUsername");

        const phoneBox =
                document.getElementById("boxStaffPhoneNum");

        const editButton =
                document.getElementById("editBtn");

        const saveButton =
                document.getElementById("saveBtn");

        /*
         * Unlock the editable fields.
         */
        usernameInput.readOnly = false;
        phoneInput.readOnly = false;

        /*
         * Remove the read-only appearance.
         */
        usernameBox.classList.remove("readonly");
        phoneBox.classList.remove("readonly");

        /*
         * Replace Edit with Save.
         */
        editButton.hidden = true;
        saveButton.hidden = false;

        usernameInput.focus();
        usernameInput.select();
    }

</script>

</body>

</html>