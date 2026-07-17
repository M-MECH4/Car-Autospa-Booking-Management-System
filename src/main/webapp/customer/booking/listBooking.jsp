<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="vehicleBooking.bean.*" %>
<%@ page import="vehicleBooking.dao.BookingDAO" %>
<%@ page import="vehicleBooking.dao.PackageDAO" %>
<%@ page import="vehicleBooking.dao.VehicleDAO" %>

<%
    response.setHeader("Cache-Control", "no-cache,no-store,must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

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
    Map<String, ArrayList<String>> bookedTimeMap = new java.util.LinkedHashMap<String, ArrayList<String>>();

    try {
        bookingList = BookingDAO.getBookingByCustomer(custID);

        // Important:
        // Package list is now filtered by customer's race and religion.
        // This prevents restricted festive packages from appearing during update.
        packageList = PackageDAO.getCustomerPackage(custID);

        unavailableDateList = BookingDAO.getUnavailableDateList();
        bookedTimeMap = BookingDAO.getBookedTimeMap();

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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/footer.css?v=<%= System.currentTimeMillis() %>">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
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
                                          class="delete-booking-form"
                                          style="margin:0;">

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

            <button type="button" class="close-btn" onclick="closeViewModal()">
                &times;
            </button>
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

            <button type="button" class="close-btn" onclick="closeUpdateModal()">
                &times;
            </button>
        </div>

        <form action="${pageContext.request.contextPath}/BookingController" method="post" id="updateBookingForm">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="bookingID" id="updateBookingID">

            <div class="form-grid">

                <div class="form-group">
                    <label>Booking Date</label>

                    <input type="text"
                           name="bookingDate"
                           id="updateBookingDate"
                           class="form-control"
                           placeholder="Select booking date"
                           required>
                </div>

                <div class="form-group">
                    <label>Booking Time</label>

                    <input type="hidden" name="bookingTime" id="updateBookingTime" required>

                    <div class="time-button-grid" id="updateTimeButtonGrid">
                        <button type="button" class="time-btn update-time-btn" data-time="09:00">09:00 AM</button>
                        <button type="button" class="time-btn update-time-btn" data-time="09:30">09:30 AM</button>
                        <button type="button" class="time-btn update-time-btn" data-time="10:00">10:00 AM</button>
                        <button type="button" class="time-btn update-time-btn" data-time="10:30">10:30 AM</button>
                        <button type="button" class="time-btn update-time-btn" data-time="11:00">11:00 AM</button>
                        <button type="button" class="time-btn update-time-btn" data-time="11:30">11:30 AM</button>
                        <button type="button" class="time-btn update-time-btn" data-time="12:00">12:00 PM</button>
                        <button type="button" class="time-btn update-time-btn" data-time="12:30">12:30 PM</button>
                        <button type="button" class="time-btn update-time-btn" data-time="13:00">01:00 PM</button>
                        <button type="button" class="time-btn update-time-btn" data-time="13:30">01:30 PM</button>
                        <button type="button" class="time-btn update-time-btn" data-time="14:00">02:00 PM</button>
                        <button type="button" class="time-btn update-time-btn" data-time="14:30">02:30 PM</button>
                        <button type="button" class="time-btn update-time-btn" data-time="15:00">03:00 PM</button>
                        <button type="button" class="time-btn update-time-btn" data-time="15:30">03:30 PM</button>
                        <button type="button" class="time-btn update-time-btn" data-time="16:00">04:00 PM</button>
                        <button type="button" class="time-btn update-time-btn" data-time="16:30">04:30 PM</button>
                        <button type="button" class="time-btn update-time-btn" data-time="17:00">05:00 PM</button>
                        <button type="button" class="time-btn update-time-btn" data-time="17:30">05:30 PM</button>
                        <button type="button" class="time-btn update-time-btn" data-time="18:00">06:00 PM</button>
                    </div>

                    <small class="time-helper" id="updateTimeHelper">
                        Select a booking date first.
                    </small>
                </div>

            </div>

            <div class="form-group">
                <label>Package</label>

                <select name="packageID" id="updatePackageID" class="form-control" required>
                    <option value="">-- Select Package --</option>

                    <%
                        if (packageList != null) {
                            for (PackageBean p : packageList) {

                                String typeText = "Package";
                                String priceText = "RM " + String.format("%.2f", p.getPackagePrice());

                                if (p instanceof RoutineBean) {
                                    typeText = "Routine";
                                }

                                if (p instanceof FestivalBean) {
                                    FestivalBean f = (FestivalBean) p;

                                    typeText = "Festive";

                                    double originalPrice = p.getPackagePrice();
                                    double discountRate = f.getDiscountRate();
                                    double finalPrice = originalPrice - (originalPrice * discountRate / 100);

                                    priceText = "RM " + String.format("%.2f", finalPrice)
                                            + " after " + String.format("%.0f", discountRate) + "% discount";
                                }
                    %>

                                <option value="<%= p.getPackageID() %>">
                                    <%= p.getPackageID() %> -
                                    <%= p.getPackageName() %>
                                    (<%= typeText %> | <%= priceText %>)
                                </option>

                    <%
                            }
                        }
                    %>
                </select>

                <% if (packageList == null || packageList.size() == 0) { %>
                    <small style="color:#dc2626; font-weight:700;">
                        No package is available for your account.
                    </small>
                <% } else { %>
                    <small style="color:#64748b; font-weight:700;">
                        Festive packages are filtered based on your registered race and religion.
                    </small>
                <% } %>
            </div>

            <div class="form-group">
                <label>Vehicle</label>

                <select name="vehiclePlateNum" id="updateVehiclePlateNum" class="form-control" required>
                    <option value="">-- Select Your Vehicle --</option>

                    <%
                        if (vehicleList != null) {
                            for (VehicleBean v : vehicleList) {
                    %>

                                <option value="<%= v.getVehicleplatenum() %>">
                                    <%= v.getVehicleplatenum() %> -
                                    <%= v.getVehiclebrand() %>
                                    <%= v.getVehiclemodel() %>
                                    (<%= v.getVehicleyear() %>)
                                </option>

                    <%
                            }
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

    var bookedTimeMap = {
        <%
            if (bookedTimeMap != null) {
                int dateIndex = 0;

                for (Map.Entry<String, ArrayList<String>> entry : bookedTimeMap.entrySet()) {
                    String dateKey = entry.getKey();
                    ArrayList<String> timeList = entry.getValue();
        %>
                "<%= dateKey %>": [
                    <%
                        if (timeList != null) {
                            for (int j = 0; j < timeList.size(); j++) {
                    %>
                                "<%= timeList.get(j) %>"<%= (j < timeList.size() - 1) ? "," : "" %>
                    <%
                            }
                        }
                    %>
                ]<%= (dateIndex < bookedTimeMap.size() - 1) ? "," : "" %>
        <%
                    dateIndex++;
                }
            }
        %>
    };

    var updateBookingTimeInput = document.getElementById("updateBookingTime");
    var updateTimeButtons = document.querySelectorAll(".update-time-btn");
    var updateTimeHelper = document.getElementById("updateTimeHelper");
    var currentUpdateDate = "";
    var currentUpdateTime = "";

    function resetUpdateSelectedTime() {
        updateBookingTimeInput.value = "";

        updateTimeButtons.forEach(function(button) {
            button.classList.remove("selected");
        });
    }

    function refreshUpdateTimeButtons(selectedDate, preferredTime) {
        resetUpdateSelectedTime();

        var bookedTimes = (bookedTimeMap[selectedDate] || []).slice();

        // The booking's current slot must remain selectable while it is being edited.
        if (selectedDate === currentUpdateDate && currentUpdateTime) {
            var currentIndex = bookedTimes.indexOf(currentUpdateTime);

            if (currentIndex !== -1) {
                bookedTimes.splice(currentIndex, 1);
            }
        }

        updateTimeButtons.forEach(function(button) {
            var time = button.dataset.time;
            var isBooked = bookedTimes.indexOf(time) !== -1;

            button.disabled = !selectedDate || isBooked;
            button.classList.toggle("booked", isBooked);

            if (!selectedDate) {
                button.title = "Select a booking date first.";
            } else if (isBooked) {
                button.title = "This time is already booked.";
            } else {
                button.title = "Available";
            }

            if (preferredTime === time && !button.disabled) {
                button.classList.add("selected");
                updateBookingTimeInput.value = time;
            }
        });

        if (!selectedDate) {
            updateTimeHelper.innerText = "Select a booking date first.";
        } else if (bookedTimes.length > 0) {
            updateTimeHelper.innerText = "Grey time slots are already booked for the selected date.";
        } else {
            updateTimeHelper.innerText = "All time slots are available for the selected date.";
        }
    }

    updateTimeButtons.forEach(function(button) {
        button.addEventListener("click", function() {
            if (button.disabled) {
                return;
            }

            updateTimeButtons.forEach(function(item) {
                item.classList.remove("selected");
            });

            button.classList.add("selected");
            updateBookingTimeInput.value = button.dataset.time;
        });
    });

    var updatePicker = flatpickr("#updateBookingDate", {
        dateFormat: "Y-m-d",
        minDate: "today",
        allowInput: false,
        disableMobile: true,
        disable: [
            function(date) {
                return date.getDay() === 0;
            }
        ].concat(unavailableDates),
        onChange: function(selectedDates, dateStr) {
            refreshUpdateTimeButtons(dateStr, "");
        }
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
        currentUpdateDate = date;
        currentUpdateTime = time;

        document.getElementById("updateBookingID").value = bookingID;
        document.getElementById("updateVehiclePlateNum").value = plateNum;
        document.getElementById("updatePackageID").value = packageID;

        var disabledForUpdate = unavailableDates.filter(function(unavailableDate) {
            return unavailableDate !== date;
        });

        updatePicker.set("disable", [
            function(dateObj) {
                return dateObj.getDay() === 0;
            }
        ].concat(disabledForUpdate));

        updatePicker.setDate(date, false);
        refreshUpdateTimeButtons(date, time);

        document.getElementById("updateModal").classList.add("active");
    }

    function closeUpdateModal() {
        document.getElementById("updateModal").classList.remove("active");
        currentUpdateDate = "";
        currentUpdateTime = "";
        resetUpdateSelectedTime();
    }

    var updateBookingForm = document.getElementById("updateBookingForm");

    if (updateBookingForm) {
        updateBookingForm.addEventListener("submit", function(event) {
            if (!updateBookingTimeInput.value) {
                event.preventDefault();

                Swal.fire({
                    title: "Select Booking Time",
                    text: "Please select an available booking time.",
                    icon: "warning",
                    confirmButtonColor: "#0F4C5C"
                });
            }
        });
    }

    document.querySelectorAll(".delete-booking-form").forEach(function(form) {
        form.addEventListener("submit", function(event) {
            if (form.dataset.confirmed === "true") {
                return;
            }

            event.preventDefault();

            Swal.fire({
                title: "Delete Booking?",
                text: "Are you sure you want to delete this booking?",
                icon: "warning",
                showCancelButton: true,
                confirmButtonColor: "#d33",
                cancelButtonColor: "#6c757d",
                confirmButtonText: "Delete",
                cancelButtonText: "Cancel"
            }).then(function(result) {
                if (result.isConfirmed) {
                    form.dataset.confirmed = "true";
                    form.submit();
                }
            });
        });
    });
</script>

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
                    <li><button type="button">Car Detailing</button></li>
                    <li><button type="button">Ceramic Coating</button></li>
                    <li><button type="button">Paint Protection</button></li>
                    <li><button type="button">Interior Cleaning</button></li>
                </ul>
            </div>

            <div class="footer-col">
                <h3>Quick Links</h3>

                <ul>
                    <li><button type="button">About Us</button></li>
                    <li><button type="button">Book Now</button></li>
                    <li><button type="button">Contact</button></li>
                    <li><button type="button">FAQ</button></li>
                </ul>
            </div>

            <div class="footer-col">
                <h3>Contact</h3>

                <div class="footer-contact-item">
                    <i class="fa-regular fa-envelope"></i>
                    <a href="mailto:info@xpertdetailing.com">info@xpertdetailing.com</a>
                </div>

                <div class="footer-contact-item">
                    <i class="fa-solid fa-phone"></i>
                    <a href="tel:+60123456789">+60 12-345 6789</a>
                </div>

                <div class="footer-contact-item">
                    <i class="fa-solid fa-location-dot"></i>
                    <span>
                        JC111, Jalan BMU 2,<br>
                        Bandar Baru Merlimau Utara,<br>
                        77300 Merlimau, Melaka
                    </span>
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