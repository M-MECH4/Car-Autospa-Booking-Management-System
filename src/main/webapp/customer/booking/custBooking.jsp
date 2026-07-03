<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="vehicleBooking.bean.PackageBean" %>
<%@ page import="vehicleBooking.bean.VehicleBean" %>
<%@ page import="vehicleBooking.dao.BookingDAO" %>
<%@ page import="vehicleBooking.dao.VehicleDAO" %>

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

    ArrayList<PackageBean> packageList = new ArrayList<PackageBean>();
    ArrayList<VehicleBean> vehicleList = new ArrayList<VehicleBean>();
    ArrayList<String> unavailableDateList = new ArrayList<String>();

    try {
        packageList = BookingDAO.getPackageList();
        unavailableDateList = BookingDAO.getUnavailableDateList();

        VehicleDAO vehicleDAO = new VehicleDAO();
        vehicleList.addAll(vehicleDAO.getVehiclesByCustomer(custID));

    } catch (Exception e) {
        e.printStackTrace();
    }

    String successMessage = (String) session.getAttribute("successMessage");
    String errorMessage = (String) session.getAttribute("errorMessage");

    session.removeAttribute("successMessage");
    session.removeAttribute("errorMessage");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>New Booking | X-PERT Detailing</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

     <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

    <!-- page css dulu -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/custBooking.css?v=<%= System.currentTimeMillis() %>">

    <!-- sidebar css LETAK LAST supaya dia override sidebar lama -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css?v=<%= System.currentTimeMillis() %>">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/xpertTheme.css?v=<%= System.currentTimeMillis() %>">
</head>

<body>

<div class="xp-layout">

    <jsp:include page="/sidebar.jsp" />

    <main class="xp-main-content">

        <div class="booking-top">
            <h1>New Booking</h1>

            <a href="${pageContext.request.contextPath}/customer/booking/listBooking.jsp"
               class="new-booking-btn"
               style="text-decoration:none;">
                <i class="fa-solid fa-list"></i>
                View Bookings
            </a>
        </div>

        <% if (successMessage != null) { %>
            <div class="message success"><%= successMessage %></div>
        <% } %>

        <% if (errorMessage != null) { %>
            <div class="message error"><%= errorMessage %></div>
        <% } %>

        <div class="booking-table-card" style="padding:30px;">
            <form action="<%= request.getContextPath() %>/BookingController" method="post">
                <input type="hidden" name="action" value="create">

                <div class="form-grid">
                    <div class="form-group">
                        <label>Booking Date</label>
                        <input type="text" name="bookingDate" id="createBookingDate"
                               class="form-control" placeholder="Select booking date" required>
                    </div>

                    <div class="form-group">
                        <label>Booking Time</label>
                        <select name="bookingTime" class="form-control" required>
                            <option value="">-- Select Time --</option>
                            <option value="09:00">09:00 AM</option>
                            <option value="09:30">09:30 AM</option>
                            <option value="10:00">10:00 AM</option>
                            <option value="10:30">10:30 AM</option>
                            <option value="11:00">11:00 AM</option>
                            <option value="11:30">11:30 AM</option>
                            <option value="12:00">12:00 PM</option>
                            <option value="12:30">12:30 PM</option>
                            <option value="13:00">01:00 PM</option>
                            <option value="13:30">01:30 PM</option>
                            <option value="14:00">02:00 PM</option>
                            <option value="14:30">02:30 PM</option>
                            <option value="15:00">03:00 PM</option>
                            <option value="15:30">03:30 PM</option>
                            <option value="16:00">04:00 PM</option>
                            <option value="16:30">04:30 PM</option>
                            <option value="17:00">05:00 PM</option>
                            <option value="17:30">05:30 PM</option>
                            <option value="18:00">06:00 PM</option>
                        </select>
                    </div>
                </div>

                <div class="form-group">
                    <label>Package</label>
                    <select name="packageID" class="form-control" required>
                        <option value="">-- Select Package --</option>

                        <%
                            for (PackageBean p : packageList) {
                        %>
                            <option value="<%= p.getPackageID() %>">
                                <%= p.getPackageID() %> - <%= p.getPackageName() %>
                            </option>
                        <%
                            }
                        %>
                    </select>
                </div>

                <div class="form-group">
                    <label>Vehicle</label>
                    <select name="vehiclePlateNum" class="form-control" required>
                        <option value="">-- Select Your Vehicle --</option>

                        <%
                            for (VehicleBean v : vehicleList) {
                        %>
                            <option value="<%= v.getVehicleplatenum() %>">
                                <%= v.getVehicleplatenum() %> - <%= v.getVehiclebrand() %> <%= v.getVehiclemodel() %> (<%= v.getVehicleyear() %>)
                            </option>
                        <%
                            }
                        %>
                    </select>

                    <% if (vehicleList == null || vehicleList.size() == 0) { %>
                        <small style="color:#dc2626; font-weight:700;">
                            No vehicle found. Please register your vehicle first.
                        </small>
                    <% } %>
                </div>

                <% if (vehicleList == null || vehicleList.size() == 0) { %>
                    <button type="submit" class="submit-btn" disabled>
                        Create Booking
                    </button>
                <% } else { %>
                    <button type="submit" class="submit-btn">
                        Create Booking
                    </button>
                <% } %>

            </form>
        </div>

    </main>

</div>

<script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>

<script>
    var unavailableDates = [
        <%
            for (int i = 0; i < unavailableDateList.size(); i++) {
                String d = unavailableDateList.get(i);
        %>
                "<%= d %>"<%= (i < unavailableDateList.size() - 1) ? "," : "" %>
        <%
            }
        %>
    ];

    flatpickr("#createBookingDate", {
        dateFormat: "Y-m-d",
        minDate: "today",
        disable: [
            function(date) {
                return date.getDay() === 0;
            }
        ].concat(unavailableDates)
    });
</script>

</body>
</html>