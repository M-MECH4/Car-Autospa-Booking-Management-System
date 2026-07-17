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
 <link rel="stylesheet" href="${pageContext.request.contextPath}/css/footer.css?v=<%= System.currentTimeMillis() %>">

    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>

<body>

<div class="xp-layout">

   <jsp:include page="/sidebar.jsp" />

    <!-- MAIN CONTENT -->
    <main class="xp-main-content">

        <!-- TOPBAR -->
        <header class="topbar">
            <div>
                <h1>Dashboard</h1>
            </div>
        </header>

        <section >

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
                                    statusText = "Booked";
                                    statusClass = "booked";
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

<!-- ── FOOTER ───────────────────────────────────────────── -->
  <footer id="footer">
    <div class="container">
      <div class="footer-grid">
        <div>
          <div class="footer-brand">X<span>-</span>PERT DETAILING</div>
          <p class="footer-tagline">Premium car detailing and maintenance services</p>
        </div>
        <div class="footer-col">
          <h3>Services</h3>
          <ul>
            <li><button onclick="scrollTo('services')">Car Detailing</button></li>
            <li><button onclick="scrollTo('services')">Ceramic Coating</button></li>
            <li><button onclick="scrollTo('services')">Paint Protection</button></li>
            <li><button onclick="scrollTo('services')">Interior Cleaning</button></li>
          </ul>
        </div>
        <div class="footer-col">
          <h3>Quick Links</h3>
          <ul>
            <li><button onclick="scrollTo('about')">About Us</button></li>
            <li><button onclick="openModal()">Book Now</button></li>
            <li><button onclick="scrollTo('footer')">Contact</button></li>
            <li><button onclick="Swal.fire({title:'Coming Soon', text:'FAQ is coming soon!', icon:'info', confirmButtonColor:'#0F4C5C'})">FAQ</button></li>
          </ul>
        </div>
        <div class="footer-col">
          <h3>Contact</h3>
          <div class="footer-contact-item">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor"
              stroke-width="2">
              <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z" />
              <polyline points="22,6 12,13 2,6" />
            </svg>
            <a href="mailto:info@xpertdetailing.com">info@xpertdetailing.com</a>
          </div>
          <div class="footer-contact-item">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor"
              stroke-width="2">
              <path
                d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.69 12a19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 3.6 1.17H6.6a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L7.91 8.7a16 16 0 0 0 6 6l.91-.91a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z" />
            </svg>
            <a href="tel:+60123456789">+60 12-345 6789</a>
          </div>
          <div class="footer-contact-item">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor"
              stroke-width="2">
              <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z" />
              <circle cx="12" cy="10" r="3" />
            </svg>
            <span>JC111, Jalan BMU 2,<br>Bandar Baru Merlimau Utara,<br>77300 Merlimau, Melaka</span>
          </div>
        </div>
      </div>
      <div class="footer-bottom">
        <p>&copy; 2026 X-PERT DETAILING. All rights reserved.</p>
      </div>
    </div>
  </footer>

</body>
</html>