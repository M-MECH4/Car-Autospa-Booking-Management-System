<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    String custID = (String) session.getAttribute("custID");
    String custName = (String) session.getAttribute("custName");
    String role = (String) session.getAttribute("role");

    if (custID == null || role == null || !"customer".equalsIgnoreCase(role)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    if (custName == null || custName.trim().isEmpty()) {
        custName = "Customer";
    }

    String plate = request.getParameter("vehicleplatenum");
    String brand = request.getParameter("vehiclebrand");
    String model = request.getParameter("vehiclemodel");
    String year  = request.getParameter("vehicleyear");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Update Vehicle | X-PERT Detailing</title>
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

<div class="xp-layout">

   <jsp:include page="/sidebar.jsp" />

    <main class="xp-main-content">

    <div class="vehicle-top">
            <h1>Update Vehicle</h1>

            <a href="${pageContext.request.contextPath}/custVehicleController?action=list" class="new-booking-btn" style="text-decoration:none;">
                <i class="fa-solid fa-list"></i>
                Vehicle List
            </a>
        </div>

        <div class="booking-table-card" style="max-width:650px; padding:28px;">
            <form action="${pageContext.request.contextPath}/custVehicleController" method="post">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="originalPlate" value="<%= plate %>">

                <div class="form-group">
                    <label>Plate Number</label>
                    <input type="text" class="form-control" name="vehicleplatenum" value="<%= plate %>" readonly>
                </div>

                <div class="form-group">
                    <label>Brand</label>
                    <input type="text" class="form-control" name="vehiclebrand" value="<%= brand %>" required>
                </div>

                <div class="form-group">
                    <label>Model</label>
                    <input type="text" class="form-control" name="vehiclemodel" value="<%= model %>" required>
                </div>

                <div class="form-group">
                    <label>Year</label>
                  <input type="number"
       class="form-control"
       name="vehicleyear"
       min="1980"
       max="2028"
       value="<%= year %>"
       required>
                </div>

                <button type="submit" class="submit-btn">
                    Update Vehicle
                </button>
            </form>
        </div>

    </main>

</div>

</body>
</html>