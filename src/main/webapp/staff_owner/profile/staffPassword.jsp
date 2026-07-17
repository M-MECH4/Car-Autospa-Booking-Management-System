<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vehicleBooking.bean.StaffBean" %>
<%@ page import="vehicleBooking.dao.StaffDAO" %>

<%
    String staffID = (String) session.getAttribute("staffID");
    String staffUsername = (String) session.getAttribute("staffUsername");
    String staffPhoneNum = (String) session.getAttribute("staffPhoneNum");
    String staffRole = (String) session.getAttribute("staffRole");
    String role = (String) session.getAttribute("role");

    if (staffID == null || staffUsername == null || role == null || !"staff".equalsIgnoreCase(role)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    StaffBean staff = StaffDAO.getStaffByID(staffID);

    if (staff != null) {
        staffID = staff.getStaffID();
        staffUsername = staff.getStaffUsername();
        staffPhoneNum = staff.getStaffPhoneNum();
        staffRole = staff.getStaffRole();
    }

    if (staffPhoneNum == null || staffPhoneNum.trim().isEmpty()) {
        staffPhoneNum = "-";
    }

    if (staffRole == null || staffRole.trim().isEmpty()) {
        staffRole = "Staff";
    }
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>Change Password | Staff Account</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

      <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

    <!-- page css dulu -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/staffPassword.css?v=<%= System.currentTimeMillis() %>">

    <!-- sidebar css LETAK LAST supaya dia override sidebar lama -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css?v=<%= System.currentTimeMillis() %>">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/xpertTheme.css?v=<%= System.currentTimeMillis() %>">
    
    
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>

<body>

<div class="xp-layout">

  <jsp:include page="/sidebar.jsp" />

    <main class="xp-main-content">

        <a href="${pageContext.request.contextPath}/staff_owner/profile/staffProfile.jsp" class="back-link">
            <i class="fa-solid fa-arrow-left"></i>
            Back to Profile
        </a>

        <div class="topbar">
            <div>
                <h1>Change Password</h1>
                <p>Update your staff account password securely</p>
            </div>
        </div>

        <%
            String errorMessage = (String) request.getAttribute("errorMessage");
            String successMessage = (String) request.getAttribute("successMessage");

            if (errorMessage != null && !errorMessage.trim().isEmpty()) {
        %>
            <div class="message-box error-box">
                <%= errorMessage %>
            </div>
        <%
            }

            if (successMessage != null && !successMessage.trim().isEmpty()) {
        %>
            <div class="message-box success-box">
                <%= successMessage %>
            </div>
        <%
            }
        %>

        <form action="${pageContext.request.contextPath}/StaffpasswordController" method="post">

            <div class="grid">

                <div class="card profile-card">

                    <div class="big-avatar">
                        <i class="fa-regular fa-user"></i>
                    </div>

                    <h2><%= staffUsername %></h2>
                    <p><%= staffPhoneNum %></p>

                    <div class="badge">
                        <i class="fa-solid fa-shield"></i>
                        Staff
                    </div>

                    <hr>

                    <div class="stats">
                        <div>
                            <h3>0</h3>
                            <span>Total Tasks</span>
                        </div>

                        <div>
                            <h3>0</h3>
                            <span>Completed</span>
                        </div>
                    </div>

                </div>

                <div class="card info-card">

                    <h2>Password Information</h2>

                    <div class="field">
                        <label>Staff ID</label>
                        <div class="input-box readonly">
                            <i class="fa-solid fa-id-badge"></i>
                            <input type="text" value="<%= staffID %>" readonly>
                        </div>
                    </div>

                    <div class="field">
                        <label>Current Password</label>
                        <div class="input-box">
                            <i class="fa-solid fa-lock"></i>
                            <input type="password" name="currentPassword" placeholder="Enter current password" required>
                        </div>
                    </div>

                    <div class="field">
                        <label>New Password</label>
                        <div class="input-box">
                            <i class="fa-solid fa-key"></i>
                            <input type="password" name="newPassword" placeholder="Enter new password" required>
                        </div>
                    </div>

                    <div class="field">
                        <label>Confirm New Password</label>
                        <div class="input-box">
                            <i class="fa-solid fa-check"></i>
                            <input type="password" name="confirmPassword" placeholder="Confirm new password" required>
                        </div>
                    </div>

                    <button type="submit" class="save-btn">
                        <i class="fa-solid fa-floppy-disk"></i>
                        Update Password
                    </button>

                </div>

            </div>

        </form>

    </main>

</div>

</body>

</html>