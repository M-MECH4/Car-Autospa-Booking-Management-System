<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="vehicleBooking.dao.StaffDashboardDAO" %>
<%@ page import="vehicleBooking.bean.StaffDashboardBookingBean" %>

<%
    String role = (String) session.getAttribute("role");

    if (role == null || !"owner".equalsIgnoreCase(role)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String staffName = (String) session.getAttribute("name");

    if (staffName == null) {
        staffName = (String) session.getAttribute("staffUsername");
    }

    if (staffName == null || staffName.trim().isEmpty()) {
        staffName = "Owner";
    }

    String initials = "OW";

    if (staffName != null && staffName.trim().length() > 0) {
        String[] parts = staffName.trim().split(" ");

        if (parts.length >= 2) {
            initials = parts[0].substring(0, 1).toUpperCase()
                     + parts[1].substring(0, 1).toUpperCase();
        } else {
            initials = staffName.substring(0, 1).toUpperCase();
        }
    }

    int todayBookings = StaffDashboardDAO.getTodayBookings();
    int yesterdayBookings = StaffDashboardDAO.getYesterdayBookings();
    int bookingDifference = todayBookings - yesterdayBookings;

    int vehiclesServiced = StaffDashboardDAO.getVehiclesServicedThisMonth();
    double revenueThisWeek = StaffDashboardDAO.getRevenueThisWeek();

    List<StaffDashboardBookingBean> recentBookings = StaffDashboardDAO.getRecentBookings();

    DecimalFormat moneyFormat = new DecimalFormat("0.00");
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>Owner Dashboard | X-PERT DETAILING</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

     <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

    <!-- page css dulu -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/staffDashboard.css?v=<%= System.currentTimeMillis() %>">

    <!-- sidebar css LETAK LAST supaya dia override sidebar lama -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css?v=<%= System.currentTimeMillis() %>">
    
</head>

<body>

<div class="xp-layout">

      <jsp:include page="/sidebar.jsp" />

    <main class="xp-main-content">

        <header class="topbar">

            <h1>Owner Dashboard</h1>

            <div class="topbar-right">

                <div class="search-box">
                    <i class="fa-solid fa-magnifying-glass"></i>
                    <input type="text" placeholder="Search bookings...">
                </div>

                <div class="notification">
                    <i class="fa-solid fa-bell"></i>
                    <span><%= todayBookings %></span>
                </div>

                <div class="user-circle">
                    <%= initials %>
                </div>

            </div>

        </header>

        <section class="content-area">

            <div class="metrics-grid">

                <div class="metric-card">

                    <div class="metric-icon icon-blue">
                        <i class="fa-solid fa-calendar-days"></i>
                    </div>

                    <div>
                        <h3>Today's Bookings</h3>
                        <h2><%= todayBookings %></h2>

                        <%
                            if (bookingDifference >= 0) {
                        %>
                            <p class="positive">
                                <i class="fa-solid fa-arrow-trend-up"></i>
                                +<%= bookingDifference %> from yesterday
                            </p>
                        <%
                            } else {
                        %>
                            <p class="neutral">
                                <%= bookingDifference %> from yesterday
                            </p>
                        <%
                            }
                        %>
                    </div>

                </div>

                <div class="metric-card">

                    <div class="metric-icon icon-yellow">
                        <i class="fa-solid fa-car"></i>
                    </div>

                    <div>
                        <h3>Vehicles Serviced</h3>
                        <h2><%= vehiclesServiced %></h2>

                        <p class="positive">
                            <i class="fa-solid fa-check"></i>
                            completed this month
                        </p>
                    </div>

                </div>

                <div class="metric-card">

                    <div class="metric-icon icon-green">
                        <i class="fa-solid fa-dollar-sign"></i>
                    </div>

                    <div>
                        <h3>Revenue</h3>
                        <h2>RM <%= moneyFormat.format(revenueThisWeek) %></h2>

                        <p class="positive">
                            <i class="fa-solid fa-arrow-trend-up"></i>
                            this week
                        </p>
                    </div>

                </div>

            </div>

            <div class="table-card">

                <div class="table-header">
                    <h2>Recent Bookings</h2>

                    <a href="<%= request.getContextPath() %>/staff_owner/booking/staffBooking.jsp" class="view-btn">
                        View All
                    </a>
                </div>

                <table>

                    <thead>
                        <tr>
                            <th>Client</th>
                            <th>Vehicle</th>
                            <th>Package</th>
                            <th>Status</th>
                            <th>Action</th>
                        </tr>
                    </thead>

                    <tbody>

                    <%
                        if (recentBookings == null || recentBookings.size() == 0) {
                    %>

                        <tr>
                            <td colspan="5" class="empty-row">
                                No recent booking found.
                            </td>
                        </tr>

                    <%
                        } else {
                            for (StaffDashboardBookingBean b : recentBookings) {

                                String customerName = b.getCustomerName();

                                if (customerName == null || customerName.trim().isEmpty()) {
                                    customerName = "Customer";
                                }

                                String avatarText = "US";

                                String[] nameParts = customerName.trim().split(" ");

                                if (nameParts.length >= 2) {
                                    avatarText = nameParts[0].substring(0, 1).toUpperCase()
                                               + nameParts[1].substring(0, 1).toUpperCase();
                                } else {
                                    avatarText = customerName.substring(0, 1).toUpperCase();
                                }

                                String vehicleText = "";

                                if (b.getVehicleBrand() != null) {
                                    vehicleText += b.getVehicleBrand();
                                }

                                if (b.getVehicleModel() != null) {
                                    vehicleText += " " + b.getVehicleModel();
                                }

                                if (vehicleText.trim().isEmpty()) {
                                    vehicleText = "-";
                                }

                                String packageName = b.getPackageName();

                                if (packageName == null || packageName.trim().isEmpty()) {
                                    packageName = "-";
                                }

                                String status = b.getBookingStatus();

                                if (status == null || status.trim().isEmpty()) {
                                    status = "BOOKED";
                                }

                                String statusText = status;
                                String statusClass = "pending";

                                if ("BOOKED".equalsIgnoreCase(status)) {
                                    statusText = "Pending";
                                    statusClass = "pending";
                                } else if ("IN PROGRESS".equalsIgnoreCase(status)) {
                                    statusText = "In Progress";
                                    statusClass = "progress";
                                } else if ("COMPLETED".equalsIgnoreCase(status)) {
                                    statusText = "Completed";
                                    statusClass = "completed";
                                } else if ("CANCELLED".equalsIgnoreCase(status)) {
                                    statusText = "Cancelled";
                                    statusClass = "cancelled";
                                }
                    %>

                        <tr>

                            <td>
                                <div class="client-info">
                                    <div class="client-avatar"><%= avatarText %></div>
                                    <span><%= customerName %></span>
                                </div>
                            </td>

                            <td><%= vehicleText %></td>

                            <td><%= packageName %></td>

                            <td>
                                <span class="status <%= statusClass %>">
                                    <%= statusText %>
                                </span>
                            </td>

                            <td>
                                <span class="action-badge">
                                    <i class="fa-solid fa-circle-check"></i>
                                    Active
                                </span>
                            </td>

                        </tr>

                    <%
                            }
                        }
                    %>

                    </tbody>

                </table>

            </div>

        </section>

    </main>

</div>

</body>
</html>