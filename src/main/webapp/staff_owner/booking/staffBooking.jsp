<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="vehicleBooking.bean.BookingBean" %>
<%@ page import="vehicleBooking.dao.BookingDAO" %>

<%!
    public String safe(String value) {
        if (value == null) {
            return "";
        }

        return value
            .replace("&", "&amp;")
            .replace("\"", "&quot;")
            .replace("'", "&#39;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\r", " ")
            .replace("\n", " ");
    }
%>

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

    String successMessage = (String) session.getAttribute("successMessage");
    String errorMessage = (String) session.getAttribute("errorMessage");

    session.removeAttribute("successMessage");
    session.removeAttribute("errorMessage");

    ArrayList<BookingBean> bookingList = new ArrayList<BookingBean>();

    try {
        bookingList = BookingDAO.getAllBookingsForStaff();
    } catch (Exception e) {
        e.printStackTrace();
        errorMessage = "Error: " + e.getMessage();
    }
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>Staff Booking Management | X-PERT Detailing</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

     <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

    <!-- page css dulu -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/staffBooking.css?v=<%= System.currentTimeMillis() %>">

    <!-- sidebar css LETAK LAST supaya dia override sidebar lama -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css?v=<%= System.currentTimeMillis() %>">
   
</head>

<body>

<div class="xp-layout">


   <jsp:include page="/sidebar.jsp" />

    <main class="xp-main-content">

        <div class="booking-top">
            <div>
                <h1>Booking Management</h1>
                <p>View all customer bookings and update service progress</p>
            </div>

            <div class="booking-count">
                Total Bookings: <%= bookingList.size() %>
            </div>
        </div>

        <% if (successMessage != null && !successMessage.trim().isEmpty()) { %>
            <div class="message success"><%= safe(successMessage) %></div>
        <% } %>

        <% if (errorMessage != null && !errorMessage.trim().isEmpty()) { %>
            <div class="message error"><%= safe(errorMessage) %></div>
        <% } %>

        <div class="table-card">

            <table>
                <thead>
                    <tr>
                        <th>No</th>
                        <th>Booking ID</th>
                        <th>Customer</th>
                        <th>Phone</th>
                        <th>Vehicle</th>
                        <th>Package</th>
                        <th>Date & Time</th>
                        <th>Progress</th>
                        <th>Notification</th>
                        <th>Action</th>
                    </tr>
                </thead>

                <tbody>

                <% if (bookingList == null || bookingList.size() == 0) { %>

                    <tr>
                        <td colspan="10" class="empty">No booking found.</td>
                    </tr>

                <% } else { %>

                    <% for (int i = 0; i < bookingList.size(); i++) {
                        BookingBean b = bookingList.get(i);

                        String bookingID = safe(b.getBookingID());
                        String custName = safe(b.getCustName());
                        String phone = safe(b.getCustPhoneNum());
                        String email = safe(b.getCustEmail());

                        String plate = safe(b.getVehiclePlateNum());
                        String brand = safe(b.getVehicleBrand());
                        String model = safe(b.getVehicleModel());

                        String packageName = safe(b.getPackageName());
                        String date = safe(b.getBookingDate());
                        String time = safe(b.getBookingTime());
                        String status = safe(b.getBookingStatus());

                        String notifSent = safe(b.getNotificationSent());

                        if (status.trim().isEmpty()) {
                            status = "BOOKED";
                        }

                        if (notifSent.trim().isEmpty()) {
                            notifSent = "N";
                        }

                        if ("COMPLETED".equalsIgnoreCase(status)) {
                            notifSent = "Y";
                        }

                        String notifText = "Y".equalsIgnoreCase(notifSent) ? "Sent" : "Not Sent";

                        String statusClass = "status-booked";

                        if ("IN PROGRESS".equalsIgnoreCase(status)) {
                            statusClass = "status-progress";
                        } else if ("COMPLETED".equalsIgnoreCase(status)) {
                            statusClass = "status-completed";
                        }

                        boolean isCompleted = "COMPLETED".equalsIgnoreCase(status);
                    %>

                    <tr>
                        <td><%= i + 1 %></td>

                        <td><strong><%= bookingID %></strong></td>

                        <td><%= custName %></td>

                        <td><%= phone %></td>

                        <td>
                            <strong><%= plate %></strong><br>
                            <small><%= model %></small>
                        </td>

                        <td><%= packageName %></td>

                        <td>
                            <%= date %><br>
                            <small><%= time %></small>
                        </td>

                        <td>
                            <span class="status <%= statusClass %>"><%= status %></span>
                        </td>

                        <td>
                            <%= notifText %>
                        </td>

                        <td>
                            <div class="action-row">

                                <button type="button"
                                        class="btn btn-view view-booking-btn"
                                        data-bookingid="<%= bookingID %>"
                                        data-custname="<%= custName %>"
                                        data-phone="<%= phone %>"
                                        data-email="<%= email %>"
                                        data-plate="<%= plate %>"
                                        data-brand="<%= brand %>"
                                        data-model="<%= model %>"
                                        data-year="<%= b.getVehicleYear() %>"
                                        data-packagename="<%= packageName %>"
                                        data-price="<%= String.format("%.2f", b.getPackagePrice()) %>"
                                        data-date="<%= date %>"
                                        data-time="<%= time %>"
                                        data-status="<%= status %>"
                                        data-notif="<%= notifText %>">
                                    <i class="fa-solid fa-eye"></i>
                                    View
                                </button>

                                <% if (isCompleted) { %>

                                    <button type="button"
                                            class="btn btn-update"
                                            style="background:#9ca3af !important; color:#ffffff !important; cursor:not-allowed !important; opacity:0.75 !important; box-shadow:none !important;"
                                            disabled>
                                        <i class="fa-solid fa-pen"></i>
                                        Progress
                                    </button>

                                    <button type="button"
                                            class="btn btn-send"
                                            style="background:#9ca3af !important; color:#ffffff !important; cursor:not-allowed !important; opacity:0.75 !important; box-shadow:none !important;"
                                            disabled>
                                        <i class="fa-solid fa-bell"></i>
                                        Send
                                    </button>

                                <% } else { %>

                                    <button type="button"
                                            class="btn btn-update"
                                            onclick="openUpdateModal('<%= bookingID %>', '<%= status %>')">
                                        <i class="fa-solid fa-pen"></i>
                                        Progress
                                    </button>

                                    <button type="button"
                                            class="btn btn-send"
                                            onclick="openNotificationModal('<%= bookingID %>', '<%= custName %>')">
                                        <i class="fa-solid fa-bell"></i>
                                        Send
                                    </button>

                                <% } %>

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

<!-- VIEW MODAL -->
<div class="modal" id="viewModal">
    <div class="modal-box">

        <div class="modal-header">
            <h2>Booking Details</h2>
            <button type="button" class="close-btn" onclick="closeModal('viewModal')">&times;</button>
        </div>

        <div class="section-title">Customer Information</div>

        <div class="detail-row">
            <span>Customer Name</span>
            <strong id="viewCustName"></strong>
        </div>

        <div class="detail-row">
            <span>Phone</span>
            <strong id="viewPhone"></strong>
        </div>

        <div class="detail-row">
            <span>Email</span>
            <strong id="viewEmail"></strong>
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

        <div class="section-title">Booking Information</div>

        <div class="detail-row">
            <span>Booking ID</span>
            <strong id="viewBookingID"></strong>
        </div>

        <div class="detail-row">
            <span>Package</span>
            <strong id="viewPackage"></strong>
        </div>

        <div class="detail-row">
            <span>Price</span>
            <strong id="viewPrice"></strong>
        </div>

        <div class="detail-row">
            <span>Date</span>
            <strong id="viewDate"></strong>
        </div>

        <div class="detail-row">
            <span>Time</span>
            <strong id="viewTime"></strong>
        </div>

        <div class="detail-row">
            <span>Status</span>
            <strong id="viewStatus"></strong>
        </div>

        <div class="detail-row">
            <span>Notification</span>
            <strong id="viewNotif"></strong>
        </div>

    </div>
</div>

<!-- UPDATE PROGRESS MODAL -->
<div class="modal" id="updateModal">
    <div class="modal-box">

        <div class="modal-header">
            <h2>Update Service Progress</h2>
            <button type="button" class="close-btn" onclick="closeModal('updateModal')">&times;</button>
        </div>

        <form action="<%= request.getContextPath() %>/BookingController" method="post">

            <input type="hidden" name="action" value="updateProgress">
            <input type="hidden" name="bookingID" id="updateBookingID">

            <div class="form-group">
                <label>Booking ID</label>
                <input type="text" id="updateBookingIDView" class="form-control" readonly>
            </div>

            <div class="form-group">
                <label>Service Progress</label>
                <select name="bookingStatus" id="updateBookingStatus" class="form-control" required>
                    <option value="BOOKED">BOOKED</option>
                    <option value="IN PROGRESS">IN PROGRESS</option>
                    <option value="COMPLETED">COMPLETED</option>
                </select>
            </div>

            <p style="font-size:13px; color:#64748b; font-weight:700;">
                If status is changed to COMPLETED, notification will be updated to Sent automatically.
            </p>

            <button type="submit" class="submit-btn">
                Update Progress
            </button>

        </form>

    </div>
</div>

<!-- SEND NOTIFICATION MODAL -->
<div class="modal" id="notificationModal">
    <div class="modal-box">

        <div class="modal-header">
            <h2>Send Notification</h2>
            <button type="button" class="close-btn" onclick="closeModal('notificationModal')">&times;</button>
        </div>

        <form action="<%= request.getContextPath() %>/BookingController" method="post">

            <input type="hidden" name="action" value="sendNotification">
            <input type="hidden" name="bookingID" id="notifBookingID">

            <div class="form-group">
                <label>Customer</label>
                <input type="text" id="notifCustomerName" class="form-control" readonly>
            </div>

            <p style="font-size:13px; color:#64748b; font-weight:700;">
                This will mark notification as Sent.
            </p>

            <button type="submit" class="submit-btn">
                Send Notification
            </button>

        </form>

    </div>
</div>

<script>
    document.addEventListener("DOMContentLoaded", function () {
        var viewButtons = document.querySelectorAll(".view-booking-btn");

        viewButtons.forEach(function (btn) {
            btn.addEventListener("click", function () {
                document.getElementById("viewBookingID").innerText = btn.dataset.bookingid || "";
                document.getElementById("viewCustName").innerText = btn.dataset.custname || "";
                document.getElementById("viewPhone").innerText = btn.dataset.phone || "";
                document.getElementById("viewEmail").innerText = btn.dataset.email || "";

                document.getElementById("viewPlate").innerText = btn.dataset.plate || "";
                document.getElementById("viewBrand").innerText = btn.dataset.brand || "";
                document.getElementById("viewModel").innerText = btn.dataset.model || "";
                document.getElementById("viewYear").innerText = btn.dataset.year || "";

                document.getElementById("viewPackage").innerText = btn.dataset.packagename || "";
                document.getElementById("viewPrice").innerText = "RM " + (btn.dataset.price || "0.00");
                document.getElementById("viewDate").innerText = btn.dataset.date || "";
                document.getElementById("viewTime").innerText = btn.dataset.time || "";
                document.getElementById("viewStatus").innerText = btn.dataset.status || "";
                document.getElementById("viewNotif").innerText = btn.dataset.notif || "Not Sent";

                document.getElementById("viewModal").classList.add("active");
            });
        });
    });

    function openUpdateModal(bookingID, status) {
        document.getElementById("updateBookingID").value = bookingID;
        document.getElementById("updateBookingIDView").value = bookingID;

        var statusSelect = document.getElementById("updateBookingStatus");
        var bookedOption = statusSelect.querySelector("option[value='BOOKED']");

        status = status.trim().toUpperCase();

        bookedOption.disabled = false;
        bookedOption.style.display = "block";

        if (status === "IN PROGRESS") {
            bookedOption.disabled = true;
            bookedOption.style.display = "none";
        }

        statusSelect.value = status;
        document.getElementById("updateModal").classList.add("active");
    }

    function openNotificationModal(bookingID, custName) {
        document.getElementById("notifBookingID").value = bookingID;
        document.getElementById("notifCustomerName").value = custName;
        document.getElementById("notificationModal").classList.add("active");
    }

    function closeModal(id) {
        document.getElementById(id).classList.remove("active");
    }
</script>

</body>
</html>