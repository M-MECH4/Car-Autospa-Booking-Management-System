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
    Map<String, ArrayList<String>> bookedTimeMap = null;

    try {
        // Package list is filtered by customer's race and religion.
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
    <title>New Booking | X-PERT Detailing</title>
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
                <h1>New Booking</h1>
                <p>Select a date, available time, package and vehicle for your appointment.</p>
            </div>

            <a href="${pageContext.request.contextPath}/customer/booking/listBooking.jsp"
               class="new-booking-btn"
               style="text-decoration:none;">
                <i class="fa-solid fa-list"></i>
                View Bookings
            </a>
        </div>

        <% if (successMessage != null) { %>
            <div class="message success">
                <%= successMessage %>
            </div>
        <% } %>

        <% if (errorMessage != null) { %>
            <div class="message error">
                <%= errorMessage %>
            </div>
        <% } %>

        <div class="booking-table-card" style="padding:30px;">

            <form action="<%= request.getContextPath() %>/BookingController" method="post" id="createBookingForm">

                <input type="hidden" name="action" value="create">

                <div class="form-grid">

                    <div class="form-group">
                        <label>Booking Date</label>

                        <input type="text"
                               name="bookingDate"
                               id="createBookingDate"
                               class="form-control"
                               placeholder="Select booking date"
                               autocomplete="off"
                               required>
                    </div>

                    <div class="form-group">
                        <label>Booking Time</label>

                        <input type="hidden" name="bookingTime" id="bookingTime" required>

                        <div class="time-button-grid" id="timeButtonGrid">
                            <button type="button" class="time-btn" data-time="09:00">09:00 AM</button>
                            <button type="button" class="time-btn" data-time="09:30">09:30 AM</button>
                            <button type="button" class="time-btn" data-time="10:00">10:00 AM</button>
                            <button type="button" class="time-btn" data-time="10:30">10:30 AM</button>
                            <button type="button" class="time-btn" data-time="11:00">11:00 AM</button>
                            <button type="button" class="time-btn" data-time="11:30">11:30 AM</button>
                            <button type="button" class="time-btn" data-time="12:00">12:00 PM</button>
                            <button type="button" class="time-btn" data-time="12:30">12:30 PM</button>
                            <button type="button" class="time-btn" data-time="13:00">01:00 PM</button>
                            <button type="button" class="time-btn" data-time="13:30">01:30 PM</button>
                            <button type="button" class="time-btn" data-time="14:00">02:00 PM</button>
                            <button type="button" class="time-btn" data-time="14:30">02:30 PM</button>
                            <button type="button" class="time-btn" data-time="15:00">03:00 PM</button>
                            <button type="button" class="time-btn" data-time="15:30">03:30 PM</button>
                            <button type="button" class="time-btn" data-time="16:00">04:00 PM</button>
                            <button type="button" class="time-btn" data-time="16:30">04:30 PM</button>
                            <button type="button" class="time-btn" data-time="17:00">05:00 PM</button>
                            <button type="button" class="time-btn" data-time="17:30">05:30 PM</button>
                            <button type="button" class="time-btn" data-time="18:00">06:00 PM</button>
                        </div>

                        <small class="time-helper" id="timeHelper">Select a booking date first.</small>
                    </div>

                </div>

                <div class="form-group">
                    <label>Package</label>

                    <select name="packageID" class="form-control" required>
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
                            Festive packages are shown based on your registered race and religion.
                        </small>
                    <% } %>
                </div>

                <div class="form-group">
                    <label>Vehicle</label>

                    <select name="vehiclePlateNum" class="form-control" required>
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

                    <% if (vehicleList == null || vehicleList.size() == 0) { %>
<small style="color:#dc2626; font-weight:700;">
    No vehicle found. Please register your vehicle
    <a href="<%= request.getContextPath() %>/custVehicleController?action=list">
        <span>here</span>
    </a>.
</small>
                    <% } %>
                </div>

                <%
                    boolean disableSubmit =
                            vehicleList == null
                            || vehicleList.size() == 0
                            || packageList == null
                            || packageList.size() == 0;
                %>

                <% if (disableSubmit) { %>
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
                                String timeValue = timeList.get(j);
                    %>
                                "<%= timeValue %>"<%= (j < timeList.size() - 1) ? "," : "" %>
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

    var createBookingDateInput = document.getElementById("createBookingDate");
    var bookingTimeInput = document.getElementById("bookingTime");
    var timeButtons = document.querySelectorAll(".time-btn");
    var timeHelper = document.getElementById("timeHelper");

    function resetSelectedTime() {
        bookingTimeInput.value = "";
        timeButtons.forEach(function(button) {
            button.classList.remove("selected");
        });
    }

    function refreshTimeButtons(selectedDate) {
        resetSelectedTime();

        var bookedTimes = bookedTimeMap[selectedDate] || [];

        timeButtons.forEach(function(button) {
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
        });

        if (!selectedDate) {
            timeHelper.innerText = "Select a booking date first.";
        } else if (bookedTimes.length > 0) {
            timeHelper.innerText = "Grey time slots are already booked for the selected date.";
        } else {
            timeHelper.innerText = "All time slots are available for the selected date.";
        }
    }

    timeButtons.forEach(function(button) {
        button.addEventListener("click", function() {
            if (button.disabled) {
                return;
            }

            timeButtons.forEach(function(btn) {
                btn.classList.remove("selected");
            });

            button.classList.add("selected");
            bookingTimeInput.value = button.dataset.time;
        });
    });

    if (window.flatpickr) {
        flatpickr(createBookingDateInput, {
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
                refreshTimeButtons(dateStr);
            }
        });
    } else {
        createBookingDateInput.setAttribute("type", "date");
        createBookingDateInput.addEventListener("change", function() {
            refreshTimeButtons(this.value);
        });
    }

    refreshTimeButtons(createBookingDateInput.value);

    var createBookingForm = document.getElementById("createBookingForm");

    if (createBookingForm) {
        createBookingForm.addEventListener("submit", function(event) {
            if (!bookingTimeInput.value) {
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