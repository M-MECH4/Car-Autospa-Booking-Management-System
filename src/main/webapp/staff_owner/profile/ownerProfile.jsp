<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vehicleBooking.bean.StaffBean" %>
<%@ page import="vehicleBooking.dao.StaffDAO" %>

<%
    String role = (String) session.getAttribute("role");

    if (role == null || !"owner".equalsIgnoreCase(role)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String staffID = (String) session.getAttribute("staffID");
    String staffUsername = (String) session.getAttribute("staffUsername");
    String staffPhoneNum = (String) session.getAttribute("staffPhoneNum");
    String staffRole = (String) session.getAttribute("staffRole");

    if (staffUsername != null) {
        StaffBean owner = StaffDAO.getStaffByUsername(staffUsername);

        if (owner != null) {
            staffID = owner.getStaffID();
            staffUsername = owner.getStaffUsername();
            staffPhoneNum = owner.getStaffPhoneNum();
            staffRole = owner.getStaffRole();
        }
    }

    if (staffID == null || staffID.trim().isEmpty()) {
        staffID = "-";
    }

    if (staffUsername == null || staffUsername.trim().isEmpty()) {
        staffUsername = "Owner";
    }

    if (staffPhoneNum == null || staffPhoneNum.trim().isEmpty()) {
        staffPhoneNum = "-";
    }

    if (staffRole == null || staffRole.trim().isEmpty()) {
        staffRole = "Owner";
    }

    String msg = request.getParameter("msg");
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>Owner Account | X-PERT DETAILING</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

     <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

    <!-- page css dulu -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/staffProfile.css?v=<%= System.currentTimeMillis() %>">

    <!-- sidebar css LETAK LAST supaya dia override sidebar lama -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css?v=<%= System.currentTimeMillis() %>">

 
</head>

<body>

<div class="xp-layout">

   <jsp:include page="/sidebar.jsp" />

    <main class="xp-main-content">

        <a href="${pageContext.request.contextPath}/staff_owner/ownerDashboard.jsp" class="back-link">
            <i class="fa-solid fa-arrow-left"></i>
            Back to Dashboard
        </a>

        <div class="topbar">
            <div>
                <h1>Owner Account</h1>
                <p>View and manage your owner profile information</p>
            </div>
        </div>

        <% if ("success".equalsIgnoreCase(msg)) { %>
            <div class="message-box success-box">
                <i class="fa-solid fa-circle-check"></i>
                Owner profile updated successfully.
            </div>
        <% } else if ("failed".equalsIgnoreCase(msg)) { %>
            <div class="message-box error-box">
                <i class="fa-solid fa-circle-xmark"></i>
                Failed to update owner profile. Please try again.
            </div>
        <% } %>

        <form action="${pageContext.request.contextPath}/ProfileStaffController" method="post">

            <input type="hidden" name="staffID" value="<%= staffID %>">

            <div class="grid">

                <div class="card profile-card">

                    <div class="big-avatar">
                        <i class="fa-regular fa-user"></i>
                    </div>

                    <h2><%= staffUsername %></h2>
                    <p><%= staffPhoneNum %></p>

                    <div class="badge">
                        <i class="fa-solid fa-shield"></i>
                        Owner
                    </div>

                    <hr>

                    <div class="stats">
                        <div>
                            <h3>0</h3>
                            <span>Total Staff</span>
                        </div>

                        <div>
                            <h3>0</h3>
                            <span>Reports</span>
                        </div>
                    </div>

                </div>

                <div class="card info-card">

                    <h2>Profile Information</h2>

                    <div class="field">
                        <label>Owner ID</label>
                        <div class="input-box readonly">
                            <i class="fa-solid fa-id-badge"></i>
                            <input type="text" value="<%= staffID %>" readonly>
                        </div>
                    </div>

                    <div class="field">
                        <label>Owner Username</label>
                        <div class="input-box">
                            <i class="fa-solid fa-id-card"></i>
                            <input type="text" name="staffUsername" value="<%= staffUsername %>" required>
                        </div>
                    </div>

                    <div class="field">
                        <label>Phone Number</label>
                        <div class="input-box">
                            <i class="fa-solid fa-phone"></i>
                            <input type="text" name="staffPhoneNum" value="<%= staffPhoneNum %>" required>
                        </div>
                    </div>

                    <div class="field">
                        <label>Owner Role</label>
                        <div class="input-box readonly">
                            <i class="fa-solid fa-user-gear"></i>
                            <input type="text" value="<%= staffRole %>" readonly>
                        </div>
                    </div>

                    <button type="submit" class="save-btn">
                        <i class="fa-solid fa-floppy-disk"></i>
                        Update Profile
                    </button>

                </div>

                <div class="card security-card">

                    <h2>Security Settings</h2>

                    <div class="security-box">

                        <div class="security-left">
                            <i class="fa-solid fa-shield"></i>

                            <div>
                                <h4>Change Password</h4>
                                <p>Update your owner account password</p>
                            </div>
                        </div>

                        <a href="${pageContext.request.contextPath}/staff_owner/profile/ownerPassword.jsp" class="icon-btn">
                            <i class="fa-solid fa-pen"></i>
                        </a>

                    </div>

                </div>

            </div>

        </form>

    </main>

</div>

</body>
</html>