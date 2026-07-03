<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    String custID = (String) session.getAttribute("custID");
    String custName = (String) session.getAttribute("custName");
    String custUsername = (String) session.getAttribute("custUsername");
    String custEmail = (String) session.getAttribute("custEmail");
    String custPhoneNum = (String) session.getAttribute("custPhoneNum");
    String custRace = (String) session.getAttribute("custRace");
    String custReligion = (String) session.getAttribute("custReligion");
    String role = (String) session.getAttribute("role");

    if (custID == null || role == null || !"customer".equalsIgnoreCase(role)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    if (custName == null || custName.trim().isEmpty()) {
        custName = "Customer";
    }

    if (custUsername == null || custUsername.trim().isEmpty()) {
        custUsername = "-";
    }

    if (custEmail == null || custEmail.trim().isEmpty()) {
        custEmail = "-";
    }

    if (custPhoneNum == null || custPhoneNum.trim().isEmpty()) {
        custPhoneNum = "-";
    }

    if (custRace == null || custRace.trim().isEmpty()) {
        custRace = "-";
    }

    if (custReligion == null || custReligion.trim().isEmpty()) {
        custReligion = "-";
    }
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>My Account | Customer Profile</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

    <!-- page css dulu -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/customerProfile.css?v=<%= System.currentTimeMillis() %>">

    <!-- sidebar css LETAK LAST supaya dia override sidebar lama -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css?v=<%= System.currentTimeMillis() %>">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/xpertTheme.css?v=<%= System.currentTimeMillis() %>">
</head>

<body>

<div class="xp-layout">
<jsp:include page="/sidebar.jsp" />

    <!-- MAIN CONTENT -->
    <main class="xp-main-content">

        <a href="${pageContext.request.contextPath}/customer/customerDashboard.jsp" class="back-link">
            <i class="fa-solid fa-arrow-left"></i>
            Back to Dashboard
        </a>

        <div class="topbar">
            <div>
                <h1>My Account</h1>
                <p>View and manage your profile information</p>
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

        <form action="${pageContext.request.contextPath}/ProfilecustController" method="post">

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

                <!-- PROFILE INFO -->
                <div class="card info-card">

                    <h2>Profile Information</h2>

                    <div class="field">
                        <label>Customer ID</label>
                        <div class="input-box readonly">
                            <i class="fa-solid fa-id-card"></i>
                            <input type="text" value="<%= custID %>" readonly>
                        </div>
                    </div>

                    <div class="field">
                        <label>Full Name</label>
                        <div class="input-box">
                            <i class="fa-regular fa-user"></i>
                            <input type="text" name="custName" value="<%= custName %>" required>
                        </div>
                    </div>

                    <div class="field">
                        <label>Username</label>
                        <div class="input-box">
                            <i class="fa-regular fa-circle-user"></i>
                            <input type="text" name="custUsername" value="<%= custUsername %>" required>
                        </div>
                    </div>

                    <div class="field">
                        <label>Email Address</label>
                        <div class="input-box">
                            <i class="fa-regular fa-envelope"></i>
                            <input type="email" name="custEmail" value="<%= custEmail %>" required>
                        </div>
                    </div>

                    <div class="field">
                        <label>Phone Number</label>
                        <div class="input-box">
                            <i class="fa-solid fa-phone"></i>
                            <input type="text" name="custPhoneNum" value="<%= custPhoneNum %>" required>
                        </div>
                    </div>

                    <div class="field">
                        <label>Race</label>
                        <div class="input-box readonly">
                            <i class="fa-regular fa-user"></i>
                            <input type="text" value="<%= custRace %>" readonly>
                        </div>
                    </div>

                    <div class="field">
                        <label>Religion</label>
                        <div class="input-box readonly">
                            <i class="fa-regular fa-user"></i>
                            <input type="text" value="<%= custReligion %>" readonly>
                        </div>
                    </div>

                    <button type="submit" class="save-btn">
                        <i class="fa-solid fa-floppy-disk"></i>
                        Update Profile
                    </button>

                </div>

                <!-- SECURITY -->
                <div class="card security-card">

                    <h2>Security Settings</h2>

                    <div class="security-box">

                        <div class="security-left">
                            <i class="fa-solid fa-shield"></i>

                            <div>
                                <h4>Change Password</h4>
                                <p>Update your account password</p>
                            </div>
                        </div>

                        <a href="${pageContext.request.contextPath}/customer/custPassword.jsp" class="icon-btn">
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