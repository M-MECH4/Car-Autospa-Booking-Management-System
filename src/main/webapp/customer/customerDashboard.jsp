<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="vehicleBooking.dao.CustomerDashboardDAO" %>
<%@ page import="vehicleBooking.bean.DashboardBookingBean" %>

<%
    String custID = (String) session.getAttribute("custID");
    String custName = (String) session.getAttribute("custName");
    String custUsername = (String) session.getAttribute("custUsername");
    String role = (String) session.getAttribute("role");

    if (custID == null || role == null || !"customer".equalsIgnoreCase(role)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    if (custName == null || custName.trim().isEmpty()) {
        custName = "Customer";
    }

    String initials = "US";
    if (custName != null && custName.trim().length() > 0) {
        String[] parts = custName.trim().split(" ");
        if (parts.length >= 2) {
            initials = parts[0].substring(0, 1).toUpperCase() + parts[1].substring(0, 1).toUpperCase();
        } else {
            initials = custName.substring(0, 1).toUpperCase();
        }
    }

    int totalBookings = CustomerDashboardDAO.getTotalBookings(custID);
    int completedBookings = CustomerDashboardDAO.getCompletedBookings(custID);
    int totalVehicles = CustomerDashboardDAO.getTotalVehicles(custID);
    String firstVehiclePlate = CustomerDashboardDAO.getFirstVehiclePlate(custID);
    int totalInvoices = CustomerDashboardDAO.getTotalInvoices(custID);

    List<DashboardBookingBean> recentBookings = CustomerDashboardDAO.getRecentBookings(custID);

    DecimalFormat moneyFormat = new DecimalFormat("0.00");
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>Customer Dashboard | X-PERT DETAILING</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

      <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

    <!-- page css dulu -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/customerDashboard.css?v=<%= System.currentTimeMillis() %>">

    <!-- sidebar css LETAK LAST supaya dia override sidebar lama -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css?v=<%= System.currentTimeMillis() %>">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/xpertTheme.css?v=<%= System.currentTimeMillis() %>">
</head>

<body>

<div class="xp-layout">

   <jsp:include page="/sidebar.jsp" />

    <!-- MAIN CONTENT -->
    <main class="xp-main-content">

        <!-- TOPBAR -->
        <header class="topbar">
            <h1>Dashboard</h1>

            <div class="topbar-right">
                <div class="search-box">
                    <i class="fa-solid fa-magnifying-glass"></i>
                    <input type="text" placeholder="Search bookings...">
                </div>

                <div class="notification">
                    <i class="fa-solid fa-bell"></i>
                    <span><%= totalBookings %></span>
                </div>

                <div class="user-circle">
                    <%= initials %>
                </div>
            </div>
        </header>

        <section class="content-area">

            <!-- METRIC CARDS -->
            <div class="metrics-grid">

                <div class="metric-card">
                    <div class="metric-icon icon-blue">
                        <i class="fa-solid fa-calendar-days"></i>
                    </div>
                    <div>
                        <h3>My Bookings</h3>
                        <h2><%= totalBookings %></h2>
                        <p class="positive">
                            <i class="fa-solid fa-arrow-trend-up"></i>
                            <%= completedBookings %> completed
                        </p>
                    </div>
                </div>

                <div class="metric-card">
                    <div class="metric-icon icon-yellow">
                        <i class="fa-solid fa-car"></i>
                    </div>
                    <div>
                        <h3>My Vehicles</h3>
                        <h2><%= totalVehicles %></h2>
                        <p class="positive">
                            Plate: <%= firstVehiclePlate %>
                        </p>
                    </div>
                </div>

                <div class="metric-card">
                    <div class="metric-icon icon-green">
                        <i class="fa-solid fa-file-invoice-dollar"></i>
                    </div>
                    <div>
                        <h3>Invoices</h3>
                        <h2><%= totalInvoices %></h2>
                        <p class="positive">
                            <i class="fa-solid fa-check"></i>
                            <%= totalInvoices > 0 ? "All paid" : "No invoice yet" %>
                        </p>
                    </div>
                </div>

            </div>

            <!-- RECENT BOOKING TABLE -->
            <div class="table-card">

                <div class="table-header">
                    <h2>Recent Bookings</h2>

                    <a href="${pageContext.request.contextPath}/customer/booking/listBooking.jsp" class="view-btn">
                        View All
                    </a>
                </div>

                <table>
                    <thead>
                        <tr>
                            <th>Date</th>
                            <th>Vehicle</th>
                            <th>Package</th>
                            <th>Status</th>
                            <th>Amount</th>
                        </tr>
                    </thead>

                    <tbody>
                    <%
                        if (recentBookings == null || recentBookings.size() == 0) {
                    %>
                        <tr>
                            <td colspan="5" style="text-align:center; padding:30px;">
                                No recent booking found.
                            </td>
                        </tr>
                    <%
                        } else {
                            for (DashboardBookingBean b : recentBookings) {
                                String status = b.getBookingStatus();

                                if (status == null || status.trim().isEmpty()) {
                                    status = "Pending";
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
                                    statusClass = "pending";
                                }
                    %>
                        <tr>
                            <td><%= b.getBookingDate() %></td>
                            <td><%= b.getVehiclePlateNum() %></td>
                            <td><%= b.getPackageName() %></td>
                            <td>
                                <span class="status <%= statusClass %>">
                                    <%= statusText %>
                                </span>
                            </td>
                            <td>RM <%= moneyFormat.format(b.getAmount()) %></td>
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