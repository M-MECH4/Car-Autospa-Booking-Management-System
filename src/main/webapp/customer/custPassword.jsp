<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    String custID = (String) session.getAttribute("custID");
    String custName = (String) session.getAttribute("custName");
    String custEmail = (String) session.getAttribute("custEmail");
    String role = (String) session.getAttribute("role");

    if (custID == null || role == null || !"customer".equalsIgnoreCase(role)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    if (custName == null || custName.trim().isEmpty()) {
        custName = "Customer";
    }

    if (custEmail == null) {
        custEmail = "-";
    }
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>Change Password | X-PERT DETAILING</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

      <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

    <!-- page css dulu -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/custPassword.css?v=<%= System.currentTimeMillis() %>">

    <!-- sidebar css LETAK LAST supaya dia override sidebar lama -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css?v=<%= System.currentTimeMillis() %>">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/xpertTheme.css?v=<%= System.currentTimeMillis() %>">
</head>

<body>

<div class="xp-layout">

    <jsp:include page="/sidebar.jsp" />

    <!-- MAIN CONTENT -->
    <main class="xp-main-content">

        <a href="${pageContext.request.contextPath}/customer/customerProfile.jsp" class="back-link">
            <i class="fa-solid fa-arrow-left"></i>
            Back to Profile
        </a>

        <div class="topbar">
            <div>
                <h1>Change Password</h1>
                <p>Update your account password securely</p>
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

       <form action="${pageContext.request.contextPath}/CustpasswordController" method="post">

            <input type="hidden" name="custID" value="<%= custID %>">

            <div class="grid">

                <!-- PROFILE CARD -->
                <div class="card profile-card">
                    <div class="big-avatar">
                        <i class="fa-regular fa-user"></i>
                    </div>

                    <h2><%= custName %></h2>
                    <p><%= custEmail %></p>

                    <div class="badge">
                        <i class="fa-solid fa-shield"></i>
                        Customer
                    </div>

                    <hr>

                    <div class="stats">
                        <div>
                            <h3>0</h3>
                            <span>Total Bookings</span>
                        </div>

                        <div>
                            <h3>0</h3>
                            <span>Loyalty Points</span>
                        </div>
                    </div>
                </div>

                <!-- CHANGE PASSWORD CARD -->
                <div class="card info-card">

                    <h2>Password Information</h2>

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