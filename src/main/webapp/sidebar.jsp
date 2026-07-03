<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    String sbContextPath = request.getContextPath();

    String sbRole = (String) session.getAttribute("role");
    String sbStaffRole = (String) session.getAttribute("staffRole");

    if (sbRole == null || sbRole.trim().isEmpty()) {
        sbRole = sbStaffRole;
    }

    if (sbRole == null && session.getAttribute("custID") != null) {
        sbRole = "customer";
    }

    if (sbRole == null) {
        sbRole = "";
    }

    String sbName = (String) session.getAttribute("name");

    if (sbName == null || sbName.trim().isEmpty()) {
        sbName = (String) session.getAttribute("custName");
    }

    if (sbName == null || sbName.trim().isEmpty()) {
        sbName = (String) session.getAttribute("custUsername");
    }

    if (sbName == null || sbName.trim().isEmpty()) {
        sbName = (String) session.getAttribute("staffName");
    }

    if (sbName == null || sbName.trim().isEmpty()) {
        sbName = (String) session.getAttribute("staffUsername");
    }

    if (sbName == null || sbName.trim().isEmpty()) {
        sbName = "User";
    }

    String sbRoleLabel = sbRole;

    if (sbRoleLabel == null || sbRoleLabel.trim().isEmpty()) {
        sbRoleLabel = "User";
    }

    String sbCurrentUri = (String) request.getAttribute("jakarta.servlet.forward.request_uri");

    if (sbCurrentUri == null || sbCurrentUri.trim().isEmpty()) {
        sbCurrentUri = request.getRequestURI();
    }

    String sbCurrentPath = sbCurrentUri.toLowerCase();

    boolean sbIsCustomer = "customer".equalsIgnoreCase(sbRole);
    boolean sbIsStaff = "staff".equalsIgnoreCase(sbRole);
    boolean sbIsOwner = "owner".equalsIgnoreCase(sbRole);

    boolean sbActiveDashboard = sbCurrentPath.contains("dashboard");
    boolean sbActiveVehicle = sbCurrentPath.contains("vehicle") 
            || sbCurrentPath.contains("custvehiclecontroller") 
            || sbCurrentPath.contains("staffvehiclecontroller");

    boolean sbActiveBooking = sbCurrentPath.contains("booking") 
            || sbCurrentPath.contains("bookingcontroller");

    boolean sbActivePackage = sbCurrentPath.contains("package") 
            || sbCurrentPath.contains("packagecontroller");

    boolean sbActiveInvoice = sbCurrentPath.contains("invoice");

    boolean sbActiveCustomer = sbCurrentPath.contains("managecustomercontroller") 
            || sbCurrentPath.contains("managecustomer");

    boolean sbActiveStaff = sbCurrentPath.contains("managestaffcontroller") 
            || sbCurrentPath.contains("managestaff");

    boolean sbActiveReport = sbCurrentPath.contains("reportcontroller") 
            || sbCurrentPath.contains("staffreport");

    String sbProfileLink = sbContextPath + "/login.jsp";

    if (sbIsCustomer) {
        sbProfileLink = sbContextPath + "/customer/customerProfile.jsp";
    } else if (sbIsOwner) {
        sbProfileLink = sbContextPath + "/staff_owner/profile/ownerProfile.jsp";
    } else if (sbIsStaff) {
        sbProfileLink = sbContextPath + "/staff_owner/profile/staffProfile.jsp";
    }
%>

<aside class="xp-sidebar">

    <a href="<%= sbProfileLink %>" class="xp-sidebar-profile">
        <div class="xp-profile-icon">
            <i class="fa-solid fa-user"></i>
        </div>

        <div class="xp-profile-text">
            <h4><%= sbName %></h4>
            <p><%= sbRoleLabel %></p>
        </div>
    </a>

    <nav class="xp-sidebar-nav">

        <% if (sbIsCustomer) { %>

            <a href="<%= sbContextPath %>/customer/customerDashboard.jsp"
               class="xp-nav-item <%= sbActiveDashboard ? "active" : "" %>">
                <i class="fa-solid fa-gauge-high"></i>
                <span>Dashboard</span>
            </a>

            <p class="xp-nav-title">BOOKING</p>

            <a href="<%= sbContextPath %>/custVehicleController?action=list"
               class="xp-nav-item <%= sbActiveVehicle ? "active" : "" %>">
                <i class="fa-solid fa-car"></i>
                <span>Vehicle</span>
            </a>

            <a href="<%= sbContextPath %>/BookingController"
               class="xp-nav-item <%= sbActiveBooking ? "active" : "" %>">
                <i class="fa-solid fa-calendar-check"></i>
                <span>My Bookings</span>
            </a>

            <a href="<%= sbContextPath %>/PackageController"
               class="xp-nav-item <%= sbActivePackage ? "active" : "" %>">
                <i class="fa-solid fa-box"></i>
                <span>Package</span>
            </a>

            <a href="<%= sbContextPath %>/customer/invoice/custInvoice.jsp"
               class="xp-nav-item <%= sbActiveInvoice ? "active" : "" %>">
                <i class="fa-solid fa-file-lines"></i>
                <span>Invoice</span>
            </a>

        <% } else { %>

            <% if (sbIsOwner) { %>
                <a href="<%= sbContextPath %>/staff_owner/ownerDashboard.jsp"
                   class="xp-nav-item <%= sbActiveDashboard ? "active" : "" %>">
                    <i class="fa-solid fa-gauge-high"></i>
                    <span>Dashboard</span>
                </a>
            <% } else { %>
                <a href="<%= sbContextPath %>/staff_owner/staffDashboard.jsp"
                   class="xp-nav-item <%= sbActiveDashboard ? "active" : "" %>">
                    <i class="fa-solid fa-gauge-high"></i>
                    <span>Dashboard</span>
                </a>
            <% } %>

            <p class="xp-nav-title">MANAGEMENT</p>

            <a href="<%= sbContextPath %>/StaffVehicleController"
               class="xp-nav-item <%= sbActiveVehicle ? "active" : "" %>">
                <i class="fa-solid fa-car"></i>
                <span>Vehicle</span>
            </a>

            <a href="<%= sbContextPath %>/staff_owner/booking/staffBooking.jsp"
               class="xp-nav-item <%= sbActiveBooking ? "active" : "" %>">
                <i class="fa-solid fa-calendar-check"></i>
                <span>Booking</span>
            </a>

            <a href="<%= sbContextPath %>/PackageController"
               class="xp-nav-item <%= sbActivePackage ? "active" : "" %>">
                <i class="fa-solid fa-box"></i>
                <span>Package</span>
            </a>

            <a href="<%= sbContextPath %>/staff_owner/invoice/staffInvoice.jsp"
               class="xp-nav-item <%= sbActiveInvoice ? "active" : "" %>">
                <i class="fa-solid fa-file-lines"></i>
                <span>Invoice</span>
            </a>

            <a href="<%= sbContextPath %>/ManageCustomerController"
               class="xp-nav-item <%= sbActiveCustomer ? "active" : "" %>">
                <i class="fa-solid fa-users-gear"></i>
                <span>Manage Customer</span>
            </a>

            <% if (sbIsOwner) { %>
                <a href="<%= sbContextPath %>/ManageStaffController"
                   class="xp-nav-item <%= sbActiveStaff ? "active" : "" %>">
                    <i class="fa-solid fa-user-tie"></i>
                    <span>Manage Staff</span>
                </a>
            <% } %>

            <a href="<%= sbContextPath %>/ReportController"
               class="xp-nav-item <%= sbActiveReport ? "active" : "" %>">
                <i class="fa-solid fa-chart-line"></i>
                <span>Report</span>
            </a>

        <% } %>

    </nav>

    <div class="xp-sidebar-footer">
        <a href="<%= sbContextPath %>/LogoutController" class="xp-logout-link">
            <i class="fa-solid fa-right-from-bracket"></i>
            <span>Logout</span>
        </a>
    </div>

</aside>