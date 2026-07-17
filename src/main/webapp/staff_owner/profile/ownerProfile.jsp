<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vehicleBooking.bean.StaffBean" %>
<%@ page import="vehicleBooking.dao.StaffDAO" %>
<%@ page import="vehicleBooking.dao.ReportDAO" %>

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

    String sessionStaffID =
            (String) session.getAttribute("staffID");

    if (role == null
            || !"owner".equalsIgnoreCase(role)
            || sessionStaffID == null
            || sessionStaffID.trim().isEmpty()) {

        response.sendRedirect(
                request.getContextPath() + "/login.jsp"
        );

        return;
    }

    String staffID = sessionStaffID;

    String staffUsername =
            (String) session.getAttribute("staffUsername");

    String staffPhoneNum =
            (String) session.getAttribute("staffPhoneNum");

    String staffRole =
            (String) session.getAttribute("staffRole");

    /*
     * Retrieve the latest owner information from the database.
     * Staff ID is used because the username can be changed.
     */
    try {
        StaffBean owner =
                StaffDAO.getStaffByID(staffID);

        if (owner != null) {
            staffID =
                    owner.getStaffID();

            staffUsername =
                    owner.getStaffUsername();

            staffPhoneNum =
                    owner.getStaffPhoneNum();

            staffRole =
                    owner.getStaffRole();

            /*
             * Keep the session information updated.
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

    int totalStaff = 0;
    int totalReports = 0;

    try {
        totalStaff =
                StaffDAO.getTotalStaff();

        totalReports =
                ReportDAO.getTotalReports();

    } catch (Exception e) {
        e.printStackTrace();
    }

    String msg =
            request.getParameter("msg");
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <title>
        Owner Account | X-PERT DETAILING
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
            href="${pageContext.request.contextPath}/staff_owner/ownerDashboard.jsp"
            class="back-link"
        >
            <i class="fa-solid fa-arrow-left"></i>
            Back to Dashboard
        </a>

        <div class="topbar">

            <div>

                <h1>
                    Owner Account
                </h1>

                <p>
                    View and manage your owner profile information
                </p>

            </div>

        </div>

        <% if ("success".equalsIgnoreCase(msg)) { %>

            <div class="message-box success-box">

                <i class="fa-solid fa-circle-check"></i>

                Owner profile updated successfully.

            </div>

        <% } else if ("invalidPhone".equalsIgnoreCase(msg)) { %>

            <div class="message-box error-box">

                <i class="fa-solid fa-triangle-exclamation"></i>

                Phone number must contain numbers only.

            </div>

        <% } else if ("failed".equalsIgnoreCase(msg)) { %>

            <div class="message-box error-box">

                <i class="fa-solid fa-circle-xmark"></i>

                Failed to update owner profile. Please try again.

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

                <!-- OWNER SUMMARY CARD -->
                <div class="card profile-card">

                    <div class="big-avatar">

                        <i class="fa-regular fa-user"></i>

                    </div>

                    <h2 id="ownerProfileUsername">
                        <%= esc(staffUsername) %>
                    </h2>

                    <p id="ownerProfilePhone">
                        <%= esc(staffPhoneNum) %>
                    </p>

                    <div class="badge">

                        <i class="fa-solid fa-shield"></i>

                        Owner

                    </div>

                    <hr>

                    <div class="stats">

                        <div>

                            <h3>
                                <%= totalStaff %>
                            </h3>

                            <span>
                                Total Staff
                            </span>

                        </div>

                        <div>

                            <h3>
                                <%= totalReports %>
                            </h3>

                            <span>
                                Total Reports
                            </span>

                        </div>

                    </div>

                </div>

                <!-- OWNER PROFILE INFORMATION -->
                <div class="card info-card">

                    <h2>
                        Profile Information
                    </h2>

                    <!-- OWNER ID -->
                    <div class="field">

                        <label>
                            Owner ID
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

                    <!-- OWNER USERNAME -->
                    <div class="field">

                        <label>
                            Owner Username
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

                    <!-- OWNER PHONE NUMBER -->
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

                    <!-- OWNER ROLE -->
                    <div class="field">

                        <label>
                            Owner Role
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
                        onclick="enableOwnerEditMode()"
                    >

                        <i class="fa-solid fa-pen"></i>

                        Edit

                    </button>

                    <!-- SAVE BUTTON -->
                    <button
                        type="submit"
                        class="save-btn"
                        id="saveBtn"
                        hidden
                    >

                        <i class="fa-solid fa-floppy-disk"></i>

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
                                    Update your owner account password
                                </p>

                            </div>

                        </div>

                        <a
                            href="${pageContext.request.contextPath}/staff_owner/profile/ownerPassword.jsp"
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

    function enableOwnerEditMode() {

        const usernameInput =
                document.getElementById("staffUsername");

        const phoneInput =
                document.getElementById("staffPhoneNum");

        /*
         * Allow the owner to edit the username
         * and phone number.
         */
        usernameInput.removeAttribute("readonly");
        phoneInput.removeAttribute("readonly");

        /*
         * Remove the grey read-only appearance.
         */
        document
                .getElementById("boxStaffUsername")
                .classList
                .remove("readonly");

        document
                .getElementById("boxStaffPhoneNum")
                .classList
                .remove("readonly");

        /*
         * Hide Edit and show Save.
         */
        document.getElementById("editBtn").hidden = true;
        document.getElementById("saveBtn").hidden = false;

        usernameInput.focus();
    }

</script>

</body>

</html>