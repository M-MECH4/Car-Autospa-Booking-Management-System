<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    String custID = (String) session.getAttribute("custID");
    String custName = (String) session.getAttribute("custName");
    String role = (String) session.getAttribute("role");

    if (custID == null || role == null || !"customer".equalsIgnoreCase(role)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String vehicleplatenum = request.getParameter("vehicleplatenum");

    if (vehicleplatenum == null || vehicleplatenum.trim().isEmpty()) {
        response.sendRedirect(request.getContextPath() + "/custVehicleController?action=list");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Delete Vehicle | X-PERT DETAILING</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

      <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

     <!-- page css dulu -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/custVehicle.css?v=<%= System.currentTimeMillis() %>">

    <!-- sidebar css LETAK LAST supaya dia override sidebar lama -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css?v=<%= System.currentTimeMillis() %>">

<link rel="stylesheet" href="${pageContext.request.contextPath}/css/xpertTheme.css?v=<%= System.currentTimeMillis() %>">
 
</head>
<body>


    <div class="delete-card">

        <div class="delete-header">
            <div class="delete-icon">
                <i class="fa-solid fa-trash"></i>
            </div>

            <div class="delete-header-text">
                <h1>Confirm Delete</h1>
                <p>Please review before removing this vehicle.</p>
            </div>
        </div>

        <div class="delete-body">
            <p class="delete-message">
                Are you sure you want to delete this vehicle from your account?
            </p>

            <div class="plate-badge">
                <i class="fa-solid fa-car"></i>
                Plate Number: <%= vehicleplatenum %>
            </div>

            <div class="warning-box">
                <i class="fa-solid fa-triangle-exclamation"></i>
                <span>
                    This action cannot be undone. Make sure you really want to remove this vehicle.
                </span>
            </div>

            <div class="btn-row">
                <form action="${pageContext.request.contextPath}/custVehicleController" method="post" style="margin:0;">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="vehicleplatenum" value="<%= vehicleplatenum %>">

                    <button type="submit" class="btn btn-delete">
                        <i class="fa-solid fa-trash"></i>
                        Yes, Delete
                    </button>
                </form>

                <a href="${pageContext.request.contextPath}/custVehicleController?action=list" class="btn btn-cancel">
                    <i class="fa-solid fa-arrow-left"></i>
                    Cancel
                </a>
            </div>
        </div>

    </div>

</body>
</html>