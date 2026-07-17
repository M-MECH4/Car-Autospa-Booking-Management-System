<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="vehicleBooking.bean.VehicleBean" %>
<%@ page import="vehicleBooking.dao.VehicleDAO" %>

<%
    String staffID = (String) session.getAttribute("staffID");
    String staffUsername = (String) session.getAttribute("staffUsername");
    String role = (String) session.getAttribute("role");

    if (staffID == null || role == null ||
        (!"staff".equalsIgnoreCase(role) && !"owner".equalsIgnoreCase(role))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    boolean isOwner = "owner".equalsIgnoreCase(role);

    if (staffUsername == null || staffUsername.trim().isEmpty()) {
        staffUsername = isOwner ? "Owner" : "Staff";
    }

    String roleLabel = isOwner ? "Owner" : "Staff";

    String dashboardLink = isOwner
            ? request.getContextPath() + "/owner/ownerDashboard.jsp"
            : request.getContextPath() + "/staff_owner/staffDashboard.jsp";

    List<VehicleBean> vehicles = new ArrayList<VehicleBean>();
    String errorMessage = null;

    try {
        vehicles = VehicleDAO.getAllVehiclesForStaff();
    } catch (Exception e) {
        e.printStackTrace();
        errorMessage = "Error: " + e.getMessage();
    }
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>Staff Vehicle Management | X-PERT Detailing</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

     <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

    <!-- page css dulu -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/staffVehicle.css?v=<%= System.currentTimeMillis() %>">

    <!-- sidebar css LETAK LAST supaya dia override sidebar lama -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css?v=<%= System.currentTimeMillis() %>">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/xpertTheme.css?v=<%= System.currentTimeMillis() %>">
  
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>

<body>

<div class="xp-layout">

       <jsp:include page="/sidebar.jsp" />

    <main class="xp-main-content">

        <div class="vehicle-top">
            <div>
                <h1>Vehicle Management</h1>
                <p>View all registered customer vehicles in the system</p>
            </div>

            <div class="vehicle-count">
                Total Vehicles: <%= vehicles.size() %>
            </div>
        </div>

        <% if (errorMessage != null) { %>
            <div class="message error">
                <%= errorMessage %>
            </div>
        <% } %>

        <div class="vehicle-table-card">

            <table>
                <thead>
                    <tr>
                        <th>No</th>
                        <th>Plate Number</th>
                        <th>Brand</th>
                        <th>Model</th>
                        <th>Year</th>
                        <th>Customer</th>
                        <th>Action</th>
                    </tr>
                </thead>

                <tbody>

                    <% if (vehicles == null || vehicles.size() == 0) { %>

                        <tr>
                            <td colspan="7" class="vehicle-empty">
                                No vehicle found.
                            </td>
                        </tr>

                    <% } else { %>

                        <% for (int i = 0; i < vehicles.size(); i++) {
                            VehicleBean v = vehicles.get(i);

                            String plate = v.getVehicleplatenum();
                            String brand = v.getVehiclebrand();
                            String model = v.getVehiclemodel();
                            int year = v.getVehicleyear();

                            String vehicleCustID = v.getCustID();
                            String custName = v.getCustName();
                            String custUsername = v.getCustUsername();
                            String custEmail = v.getCustEmail();
                            String custPhoneNum = v.getCustPhoneNum();

                            if (plate == null) plate = "";
                            if (brand == null) brand = "";
                            if (model == null) model = "";
                            if (vehicleCustID == null) vehicleCustID = "";
                            if (custName == null) custName = "";
                            if (custUsername == null) custUsername = "";
                            if (custEmail == null) custEmail = "";
                            if (custPhoneNum == null) custPhoneNum = "";
                        %>

                            <tr>
                                <td><%= i + 1 %></td>

                                <td>
                                    <span class="plate-badge"><%= plate %></span>
                                </td>

                                <td><%= brand %></td>

                                <td><%= model %></td>

                                <td><%= year %></td>

                                <td>
                                    <div class="customer-name"><%= custName %></div>
                                    <div class="customer-email"><%= custEmail %></div>
                                </td>

                                <td>
                                    <div class="vehicle-action-row">
                                        <button type="button"
                                                class="vehicle-btn vehicle-view"
                                                onclick="openViewVehicleModal(
                                                    '<%= plate %>',
                                                    '<%= brand %>',
                                                    '<%= model %>',
                                                    '<%= year %>',
                                                    '<%= vehicleCustID %>',
                                                    '<%= custName %>',
                                                    '<%= custUsername %>',
                                                    '<%= custEmail %>',
                                                    '<%= custPhoneNum %>'
                                                )">
                                            
                                            View
                                        </button>
                                    </div>
                                </td>
                            </tr>

                        <% } %>

                    <% } %>

                </tbody>
            </table>

        </div>

    </main>

</div>

<div class="modal" id="viewVehicleModal">

    <div class="modal-box">

        <div class="modal-header">
            <h2>Vehicle Details</h2>

            <button type="button" class="close-btn" onclick="closeViewVehicleModal()">
                &times;
            </button>
        </div>

        <div class="section-title">Vehicle Information</div>

        <div class="detail-row">
            <span>Plate Number</span>
            <strong id="viewPlate"></strong>
        </div>

        <div class="detail-row">
            <span>Brand</span>
            <strong id="viewBrand"></strong>
        </div>

        <div class="detail-row">
            <span>Model</span>
            <strong id="viewModel"></strong>
        </div>

        <div class="detail-row">
            <span>Year</span>
            <strong id="viewYear"></strong>
        </div>

        <div class="section-title">Customer Information</div>

        <div class="detail-row">
            <span>Customer ID</span>
            <strong id="viewCustID"></strong>
        </div>

        <div class="detail-row">
            <span>Name</span>
            <strong id="viewCustName"></strong>
        </div>

        <div class="detail-row">
            <span>Username</span>
            <strong id="viewCustUsername"></strong>
        </div>

        <div class="detail-row">
            <span>Email</span>
            <strong id="viewCustEmail"></strong>
        </div>

        <div class="detail-row">
            <span>Phone Number</span>
            <strong id="viewCustPhone"></strong>
        </div>

    </div>

</div>

<script>
    function openViewVehicleModal(plate, brand, model, year, custID, custName, custUsername, custEmail, custPhone) {
        document.getElementById("viewPlate").innerText = plate;
        document.getElementById("viewBrand").innerText = brand;
        document.getElementById("viewModel").innerText = model;
        document.getElementById("viewYear").innerText = year;

        document.getElementById("viewCustID").innerText = custID;
        document.getElementById("viewCustName").innerText = custName;
        document.getElementById("viewCustUsername").innerText = custUsername;
        document.getElementById("viewCustEmail").innerText = custEmail;
        document.getElementById("viewCustPhone").innerText = custPhone;

        document.getElementById("viewVehicleModal").classList.add("active");
    }

    function closeViewVehicleModal() {
        document.getElementById("viewVehicleModal").classList.remove("active");
    }
</script>

</body>
</html>