<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="vehicleBooking.bean.BookingBean" %>
<%@ page import="vehicleBooking.bean.PackageBean" %>
<%@ page import="vehicleBooking.bean.VehicleBean" %>
<%@ page import="vehicleBooking.dao.BookingDAO" %>
<%@ page import="vehicleBooking.dao.VehicleDAO" %>

<%
    String custID = (String) session.getAttribute("custID");
    String role = (String) session.getAttribute("role");

    if (custID == null || role == null || !"customer".equalsIgnoreCase(role)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    ArrayList<BookingBean> bookingList = new ArrayList<BookingBean>();
    ArrayList<PackageBean> packageList = new ArrayList<PackageBean>();
    ArrayList<VehicleBean> vehicleList = new ArrayList<VehicleBean>();
    ArrayList<String> unavailableDateList = new ArrayList<String>();

    try {
        bookingList = BookingDAO.getBookingByCustomer(custID);
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
    <title>My Bookings | X-PERT DETAILING</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/custBooking.css?v=<%= System.currentTimeMillis() %>">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css?v=<%= System.currentTimeMillis() %>">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/xpertTheme.css?v=<%= System.currentTimeMillis() %>">
</head>

<body>

<div class="xp-layout">

    <jsp:include page="/sidebar.jsp" />

    <main class="xp-main-content">

        <div class="booking-top">
            <div>
                <h1>My Bookings</h1>
                <p>View, update and manage your booking records.</p>
            </div>

            <a href="${pageContext.request.contextPath}/customer/booking/custBooking.jsp"
               class="new-booking-btn"
               style="text-decoration:none;">
                <i class="fa-solid fa-plus"></i>
                New Booking
            </a>
        </div>

        <% if (successMessage != null) { %>
            <div class="message success">
                <i class="fa-solid fa-circle-check"></i>
                <%= successMessage %>
            </div>
        <% } %>

        <% if (errorMessage != null) { %>
            <div class="message error">
                <i class="fa-solid fa-circle-xmark"></i>
                <%= errorMessage %>
            </div>
        <% } %>

        <div class="booking-table-card">
            <table>
                <thead>
                    <tr>
                        <th>No</th>
                        <th>Booking ID</th>
                        <th>Vehicle</th>
                        <th>Package</th>
                        <th>Status</th>
                        <th>Date and Time</th>
                        <th>Action</th>
                    </tr>
                </thead>

                <tbody>
                <%
                    if (bookingList == null || bookingList.size() == 0) {
                %>
                    <tr>
                        <td colspan="7" class="empty">No booking found.</td>
                    </tr>
                <%
                    } else {
                        for (int i = 0; i < bookingList.size(); i++) {
                            BookingBean b = bookingList.get(i);

                            String status = b.getBookingStatus();
                            String statusClass = "status-booked";

                            if ("IN PROGRESS".equalsIgnoreCase(status)) {
                                statusClass = "status-progress";
                            } else if ("COMPLETED".equalsIgnoreCase(status)) {
                                statusClass = "status-completed";
                            } else if ("CANCELLED".equalsIgnoreCase(status)) {
                                statusClass = "status-cancelled";
                            }

                            boolean canEditDelete = "BOOKED".equalsIgnoreCase(status);
                %>
                    <tr>
                        <td><%= i + 1 %></td>

                        <td>
                            <strong><%= b.getBookingID() %></strong>
                        </td>

                        <td>
                            <%= b.getVehiclePlateNum() %><br>
                            <small><%= b.getVehicleModel() %> (<%= b.getVehicleYear() %>)</small>
                        </td>

                        <td><%= b.getPackageName() %></td>

                        <td>
                            <span class="status <%= statusClass %>"><%= status %></span>
                        </td>

                        <td>
                            <%= b.getBookingDate() %><br>
                            <small><%= b.getBookingTime() %></small>
                        </td>

                        <td>
                            <div class="booking-action-row">

                                <button type="button" class="booking-btn booking-view"
                                    onclick="openViewModal(
                                        '<%= b.getBookingID() %>',
                                        '<%= b.getVehiclePlateNum() %>',
                                        '<%= b.getVehicleModel() %>',
                                        '<%= b.getVehicleYear() %>',
                                        '<%= b.getPackageName() %>',
                                        '<%= b.getBookingDate() %>',
                                        '<%= b.getBookingTime() %>',
                                        '<%= b.getBookingStatus() %>'
                                    )">
                                    View
                                </button>

                                <% if (canEditDelete) { %>
                                    <button type="button" class="booking-btn booking-edit"
                                        onclick="openUpdateModal(
                                            '<%= b.getBookingID() %>',
                                            '<%= b.getVehiclePlateNum() %>',
                                            '<%= b.getPackageID() %>',
                                            '<%= b.getBookingDate() %>',
                                            '<%= b.getBookingTime() %>'
                                        )">
                                        Edit
                                    </button>
                                <% } else { %>
                                    <button type="button" class="booking-btn booking-disabled" disabled>
                                        Edit
                                    </button>
                                <% } %>

                                <% if (canEditDelete) { %>
                                    <form action="${pageContext.request.contextPath}/BookingController"
                                          method="post"
                                          style="margin:0;"
                                          onsubmit="return confirm('Are you sure you want to delete this booking?');">

                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="bookingID" value="<%= b.getBookingID() %>">

                                        <button type="submit" class="booking-btn booking-delete">
                                            Delete
                                        </button>
                                    </form>
                                <% } else { %>
                                    <button type="button" class="booking-btn booking-disabled" disabled>
                                        Delete
                                    </button>
                                <% } %>

                            </div>
                        </td>
                    </tr>
                <%
                        }
                    }
                %>
                </tbody>
            </table>
        </div>

    </main>

</div>

<!-- VIEW MODAL -->
<div class="modal" id="viewModal">
    <div class="modal-box">
        <div class="modal-header">
            <h2>Booking Details</h2>
            <button class="close-btn" onclick="closeViewModal()">&times;</button>
        </div>

        <div class="form-group">
            <label>Booking ID</label>
            <input type="text" id="viewBookingID" class="form-control" readonly>
        </div>

        <div class="form-group">
            <label>Vehicle</label>
            <input type="text" id="viewVehicle" class="form-control" readonly>
        </div>

        <div class="form-group">
            <label>Package</label>
            <input type="text" id="viewPackage" class="form-control" readonly>
        </div>

        <div class="form-group">
            <label>Date and Time</label>
            <input type="text" id="viewDateTime" class="form-control" readonly>
        </div>

        <div class="form-group">
            <label>Status</label>
            <input type="text" id="viewStatus" class="form-control" readonly>
        </div>
    </div>
</div>

<!-- UPDATE MODAL -->
<div class="modal" id="updateModal">
    <div class="modal-box">
        <div class="modal-header">
            <h2>Update Booking</h2>
            <button class="close-btn" onclick="closeUpdateModal()">&times;</button>
        </div>

        <form action="${pageContext.request.contextPath}/BookingController" method="post">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="bookingID" id="updateBookingID">

            <div class="form-grid">
                <div class="form-group">
                    <label>Booking Date</label>
                    <input type="text" name="bookingDate" id="updateBookingDate"
                           class="form-control" placeholder="Select booking date" required>
                </div>

                <div class="form-group">
                    <label>Booking Time</label>
                    <input type="time" name="bookingTime" id="updateBookingTime"
                           class="form-control" required>
                </div>
            </div>

            <div class="form-group">
                <label>Package</label>
                <select name="packageID" id="updatePackageID" class="form-control" required>
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
                <select name="vehiclePlateNum" id="updateVehiclePlateNum" class="form-control" required>
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
            </div>

            <button type="submit" class="submit-btn">
                Update Booking
            </button>
        </form>
    </div>
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

    var updatePicker = flatpickr("#updateBookingDate", {
        dateFormat: "Y-m-d",
        minDate: "today",
        disable: [
            function(date) {
                return date.getDay() === 0;
            }
        ].concat(unavailableDates)
    });

    function openViewModal(bookingID, plateNum, model, year, packageName, date, time, status) {
        document.getElementById("viewBookingID").value = bookingID;
        document.getElementById("viewVehicle").value = plateNum + " - " + model + " (" + year + ")";
        document.getElementById("viewPackage").value = packageName;
        document.getElementById("viewDateTime").value = date + " " + time;
        document.getElementById("viewStatus").value = status;

        document.getElementById("viewModal").classList.add("active");
    }

    function closeViewModal() {
        document.getElementById("viewModal").classList.remove("active");
    }

    function openUpdateModal(bookingID, plateNum, packageID, date, time) {
        document.getElementById("updateBookingID").value = bookingID;
        document.getElementById("updateVehiclePlateNum").value = plateNum;
        document.getElementById("updatePackageID").value = packageID;
        document.getElementById("updateBookingTime").value = time;

        var disabledForUpdate = unavailableDates.filter(function(d) {
            return d !== date;
        });

        updatePicker.set("disable", [
            function(dateObj) {
                return dateObj.getDay() === 0;
            }
        ].concat(disabledForUpdate));

        updatePicker.setDate(date, true);

        document.getElementById("updateModal").classList.add("active");
    }

    function closeUpdateModal() {
        document.getElementById("updateModal").classList.remove("active");
    }
</script>

</body>
</html>