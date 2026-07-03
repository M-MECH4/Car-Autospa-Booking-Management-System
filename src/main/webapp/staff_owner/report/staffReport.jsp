<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="vehicleBooking.bean.BookingBean" %>
<%@ page import="vehicleBooking.bean.PackageBean" %>
<%@ page import="vehicleBooking.bean.CustomerBean" %>

<%!
    public String safe(String value) {
        if (value == null || value.trim().isEmpty()) {
            return "-";
        }
        return value;
    }

    public String statusClass(String status) {
        if (status == null) {
            return "pending";
        }

        if ("COMPLETED".equalsIgnoreCase(status)) {
            return "completed";
        }

        if ("IN PROGRESS".equalsIgnoreCase(status)) {
            return "progress";
        }

        return "pending";
    }
%>

<%
    String role = (String) session.getAttribute("role");
    String staffRole = (String) session.getAttribute("staffRole");

    if (role == null || role.trim().isEmpty()) {
        role = staffRole;
    }

    if (role == null || (!"staff".equalsIgnoreCase(role) && !"owner".equalsIgnoreCase(role))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String displayName = (String) session.getAttribute("name");

    if (displayName == null || displayName.trim().isEmpty()) {
        displayName = (String) session.getAttribute("staffUsername");
    }

    if (displayName == null || displayName.trim().isEmpty()) {
        displayName = "Staff";
    }

    ArrayList<BookingBean> bookingList =
            (ArrayList<BookingBean>) request.getAttribute("bookingList");

    ArrayList<PackageBean> packageList =
            (ArrayList<PackageBean>) request.getAttribute("packageList");

    ArrayList<CustomerBean> customerList =
            (ArrayList<CustomerBean>) request.getAttribute("customerList");

    String period = (String) request.getAttribute("period");
    String reportTitle = (String) request.getAttribute("reportTitle");

    Boolean generatedObj = (Boolean) request.getAttribute("generated");
    boolean generated = generatedObj != null && generatedObj.booleanValue();

    if (bookingList == null) {
        bookingList = new ArrayList<BookingBean>();
    }

    if (packageList == null) {
        packageList = new ArrayList<PackageBean>();
    }

    if (customerList == null) {
        customerList = new ArrayList<CustomerBean>();
    }

    if (period == null) {
        period = "";
    }

    if (reportTitle == null) {
        reportTitle = "Please select report type";
    }

    DecimalFormat moneyFormat = new DecimalFormat("0.00");

    int totalBookings = bookingList.size();
    int totalPackages = packageList.size();
    int totalCustomers = customerList.size();

    int completedCount = 0;
    int progressCount = 0;
    int bookedCount = 0;
    double totalSales = 0.00;

    for (BookingBean b : bookingList) {
        if ("COMPLETED".equalsIgnoreCase(b.getBookingStatus())) {
            completedCount++;
            totalSales += b.getPackagePrice();
        } else if ("IN PROGRESS".equalsIgnoreCase(b.getBookingStatus())) {
            progressCount++;
        } else {
            bookedCount++;
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Staff Report | X-PERT DETAILING</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

    <!-- page css dulu -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/staffReport.css?v=<%= System.currentTimeMillis() %>">

    <!-- sidebar css LETAK LAST supaya dia override sidebar lama -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css?v=<%= System.currentTimeMillis() %>">
    
</head>

<body>

<div class="xp-layout">

       <jsp:include page="/sidebar.jsp" />

    <main class="xp-main-content">

        <div class="topbar">
            <div>
                <h1><%= reportTitle %></h1>
            </div>

            <div class="topbar-right">
                <form action="${pageContext.request.contextPath}/ReportController" method="get" class="report-actions">

                    <select name="period"
                            id="periodSelect"
                            class="period-select"
                            onchange="toggleGenerateButton()"
                            required>

                        <option value="">-- Select Report Type --</option>

                        <option value="weekly" <%= "weekly".equalsIgnoreCase(period) ? "selected" : "" %>>
                            Weekly Report
                        </option>

                        <option value="monthly" <%= "monthly".equalsIgnoreCase(period) ? "selected" : "" %>>
                            Monthly Report
                        </option>

                    </select>

                    <button type="submit"
                            id="generateBtn"
                            class="report-btn"
                            <%= period == null || period.trim().isEmpty() ? "disabled" : "" %>>

                        <i class="fa-solid fa-file-circle-plus"></i>
                        Generate Report
                    </button>

                    <% if (generated) { %>
                        <button type="button" class="report-btn print-btn" onclick="window.print()">
                            <i class="fa-solid fa-print"></i>
                            Print
                        </button>
                    <% } %>
                </form>

                <div class="user-circle">
                    <%= displayName.substring(0, 1).toUpperCase() %>
                </div>
            </div>
        </div>

        <div class="content-area">

            <% if (!generated) { %>

                <div class="report-table-card">
                    <div class="empty-state">
                        <i class="fa-solid fa-chart-line"></i>
                        <h3>No report generated yet</h3>
                        <p>Please select Weekly Report or Monthly Report first. Then click Generate Report.</p>
                    </div>
                </div>

            <% } else { %>

                <div class="report-grid">

                    <div class="report-card">
                        <div class="report-card-top">
                            <div>
                                <h2><%= totalBookings %></h2>
                                <h3>Total Bookings</h3>
                                <p class="small-text">Based on selected period</p>
                            </div>

                            <div class="report-icon icon-blue">
                                <i class="fa-solid fa-calendar-check"></i>
                            </div>
                        </div>
                    </div>

                    <div class="report-card">
                        <div class="report-card-top">
                            <div>
                                <h2>RM <%= moneyFormat.format(totalSales) %></h2>
                                <h3>Total Sales</h3>
                                <p class="small-text">Completed bookings only</p>
                            </div>

                            <div class="report-icon icon-green">
                                <i class="fa-solid fa-money-bill-wave"></i>
                            </div>
                        </div>
                    </div>

                    <div class="report-card">
                        <div class="report-card-top">
                            <div>
                                <h2><%= totalCustomers %></h2>
                                <h3>Total Customers</h3>
                                <p class="small-text">All registered customers</p>
                            </div>

                            <div class="report-icon icon-yellow">
                                <i class="fa-solid fa-users"></i>
                            </div>
                        </div>
                    </div>

                    <div class="report-card">
                        <div class="report-card-top">
                            <div>
                                <h2><%= totalPackages %></h2>
                                <h3>Total Packages</h3>
                                <p class="small-text">All service packages</p>
                            </div>

                            <div class="report-icon icon-purple">
                                <i class="fa-solid fa-box"></i>
                            </div>
                        </div>
                    </div>

                </div>

                <div class="report-section-grid">

                    <div class="section-card">
                        <h2>Booking Status Summary</h2>

                        <div class="status-row completed">
                            <span>Completed</span>
                            <strong><%= completedCount %></strong>
                        </div>

                        <div class="status-row progress">
                            <span>In Progress</span>
                            <strong><%= progressCount %></strong>
                        </div>

                        <div class="status-row pending">
                            <span>Booked</span>
                            <strong><%= bookedCount %></strong>
                        </div>
                    </div>

                    <div class="section-card">
                        <h2>Report Information</h2>

                        <table>
                            <tr>
                                <th>Report Type</th>
                                <td><%= "weekly".equalsIgnoreCase(period) ? "Weekly" : "Monthly" %></td>
                            </tr>

                            <tr>
                                <th>Generated By</th>
                                <td><%= safe(displayName) %></td>
                            </tr>

                            <tr>
                                <th>Total Records</th>
                                <td><%= totalBookings %> bookings</td>
                            </tr>
                        </table>
                    </div>

                </div>

                <div class="report-table-card">
                    <h2>Booking Details</h2>

                    <% if (bookingList.size() == 0) { %>

                        <div class="empty-state">
                            <i class="fa-solid fa-folder-open"></i>
                            <h3>No booking found</h3>
                            <p>No booking record found for this selected report period.</p>
                        </div>

                    <% } else { %>

                        <table>
                            <thead>
                                <tr>
                                    <th>Booking ID</th>
                                    <th>Date</th>
                                    <th>Time</th>
                                    <th>Customer</th>
                                    <th>Vehicle</th>
                                    <th>Package</th>
                                    <th>Price</th>
                                    <th>Status</th>
                                </tr>
                            </thead>

                            <tbody>
                            <%
                                for (BookingBean b : bookingList) {
                            %>
                                <tr>
                                    <td><%= safe(b.getBookingID()) %></td>
                                    <td><%= safe(b.getBookingDate()) %></td>
                                    <td><%= safe(b.getBookingTime()) %></td>
                                    <td><%= safe(b.getCustName()) %></td>
                                    <td><%= safe(b.getVehiclePlateNum()) %> - <%= safe(b.getVehicleModel()) %></td>
                                    <td><%= safe(b.getPackageName()) %></td>
                                    <td>RM <%= moneyFormat.format(b.getPackagePrice()) %></td>
                                    <td>
                                        <span class="status <%= statusClass(b.getBookingStatus()) %>">
                                            <%= safe(b.getBookingStatus()) %>
                                        </span>
                                    </td>
                                </tr>
                            <%
                                }
                            %>
                            </tbody>
                        </table>

                    <% } %>
                </div>

                <div class="report-table-card">
                    <div class="shrink-header" onclick="toggleDetails('packageDetails')">
                        <h2>Package Details</h2>
                        <button type="button" class="shrink-btn">Show / Hide</button>
                    </div>

                    <div class="details-content" id="packageDetails">
                        <% if (packageList.size() == 0) { %>

                            <div class="empty-state">
                                <i class="fa-solid fa-box-open"></i>
                                <h3>No package found</h3>
                            </div>

                        <% } else { %>

                            <table>
                                <thead>
                                    <tr>
                                        <th>Package ID</th>
                                        <th>Package Name</th>
                                        <th>Service</th>
                                        <th>Price</th>
                                        <th>Status</th>
                                    </tr>
                                </thead>

                                <tbody>
                                <%
                                    for (PackageBean p : packageList) {
                                %>
                                    <tr>
                                        <td><%= safe(p.getPackageID()) %></td>
                                        <td><%= safe(p.getPackageName()) %></td>
                                        <td><%= safe(p.getServiceName()) %></td>
                                        <td>RM <%= moneyFormat.format(p.getPackagePrice()) %></td>
                                        <td><%= safe(p.getPackageStatus()) %></td>
                                    </tr>
                                <%
                                    }
                                %>
                                </tbody>
                            </table>

                        <% } %>
                    </div>
                </div>

                <div class="report-table-card">
                    <div class="shrink-header" onclick="toggleDetails('customerDetails')">
                        <h2>Customer Details</h2>
                        <button type="button" class="shrink-btn">Show / Hide</button>
                    </div>

                    <div class="details-content" id="customerDetails">
                        <% if (customerList.size() == 0) { %>

                            <div class="empty-state">
                                <i class="fa-solid fa-user-slash"></i>
                                <h3>No customer found</h3>
                            </div>

                        <% } else { %>

                            <table>
                                <thead>
                                    <tr>
                                        <th>Customer ID</th>
                                        <th>Name</th>
                                        <th>Username</th>
                                        <th>Email</th>
                                        <th>Phone</th>
                                    </tr>
                                </thead>

                                <tbody>
                                <%
                                    for (CustomerBean c : customerList) {
                                %>
                                    <tr>
                                        <td><%= safe(c.getCustID()) %></td>
                                        <td><%= safe(c.getCustName()) %></td>
                                        <td><%= safe(c.getCustUsername()) %></td>
                                        <td><%= safe(c.getCustEmail()) %></td>
                                        <td><%= safe(c.getCustPhoneNum()) %></td>
                                    </tr>
                                <%
                                    }
                                %>
                                </tbody>
                            </table>

                        <% } %>
                    </div>
                </div>

            <% } %>

        </div>

    </main>

</div>

<script>
    function toggleGenerateButton() {
        const periodSelect = document.getElementById("periodSelect");
        const generateBtn = document.getElementById("generateBtn");

        if (periodSelect.value === "") {
            generateBtn.disabled = true;
        } else {
            generateBtn.disabled = false;
        }
    }

    function toggleDetails(id) {
        const details = document.getElementById(id);
        details.classList.toggle("show");
    }

    document.addEventListener("DOMContentLoaded", function () {
        toggleGenerateButton();
    });
</script>

</body>
</html>