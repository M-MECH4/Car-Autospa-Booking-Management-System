<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="vehicleBooking.bean.BookingBean" %>
<%@ page import="vehicleBooking.dao.BookingDAO" %>

<%!
    public String esc(String value) {
        if (value == null) {
            return "";
        }

        return value
                .replace("&", "&amp;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;")
                .replace("<", "&lt;")
                .replace(">", "&gt;");
    }
%>

<%
    String custID = (String) session.getAttribute("custID");
    String custName = (String) session.getAttribute("custName");
    String custEmail = (String) session.getAttribute("custEmail");
    String role = (String) session.getAttribute("role");

    if (custID == null || role == null || !"customer".equalsIgnoreCase(role)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    if (custName == null || custName.trim().isEmpty()) {
        custName = "Customer";
    }

    if (custEmail == null || custEmail.trim().isEmpty()) {
        custEmail = "-";
    }

    int totalBookings = 0;
    int completedBookings = 0;
    int loyaltyPoints = 0;

    try {
        ArrayList<BookingBean> bookingList = BookingDAO.getBookingByCustomer(custID);

        if (bookingList != null) {
            totalBookings = bookingList.size();

            for (BookingBean booking : bookingList) {
                String status = booking.getBookingStatus();

                if (status != null && "COMPLETED".equalsIgnoreCase(status.trim())) {
                    completedBookings++;
                }
            }
        }

        /*
         * Loyalty point rule:
         * 1 completed booking = 10 points
         */
        loyaltyPoints = completedBookings * 10;

    } catch (Exception e) {
        e.printStackTrace();

        totalBookings = 0;
        loyaltyPoints = 0;
    }

    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>Change Password | X-PERT DETAILING</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

    <!-- page css dulu -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/customerProfile.css?v=<%= System.currentTimeMillis() %>">

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

        <a href="${pageContext.request.contextPath}/customer/customerProfile.jsp" class="back-link">
            <i class="fa-solid fa-arrow-left"></i>
            Back to Profile
        </a>

        <div class="topbar">
            <div>
                <h1>Change Password</h1>
                <p>Update your account password securely</p>
            </div>
        </div>

        <% if (errorMessage != null && !errorMessage.trim().isEmpty()) { %>
            <div class="message-box error-box">
                <%= errorMessage %>
            </div>
        <% } %>

        <% if (successMessage != null && !successMessage.trim().isEmpty()) { %>
            <div class="message-box success-box">
                <%= successMessage %>
            </div>
        <% } %>

        <form action="${pageContext.request.contextPath}/CustpasswordController" method="post">

            <input type="hidden" name="custID" value="<%= esc(custID) %>">

            <div class="grid">

                <!-- PROFILE CARD -->
                <div class="card profile-card">

                    <div class="big-avatar">
                        <i class="fa-regular fa-user"></i>
                    </div>

                    <h2><%= esc(custName) %></h2>
                    <p><%= esc(custEmail) %></p>

                    <div class="badge">
                        <i class="fa-solid fa-shield"></i>
                        Customer
                    </div>

                    <hr>

                    <div class="stats">
                        <div>
                            <h3><%= totalBookings %></h3>
                            <span>Total Bookings</span>
                        </div>

                        <div>
                            <h3><%= loyaltyPoints %></h3>
                            <span>Loyalty Points</span>
                        </div>
                    </div>

                </div>

                <!-- CHANGE PASSWORD CARD -->
                <div class="card info-card">

                    <h2>Password Information</h2>

                    <div class="field">
                        <label>Current Password</label>

                        <div class="input-box">
                            <i class="fa-solid fa-lock"></i>
                            <input type="password"
                                   name="currentPassword"
                                   placeholder="Enter current password"
                                   required>
                        </div>
                    </div>

                    <div class="field">
                        <label>New Password</label>

                        <div class="input-box">
                            <i class="fa-solid fa-key"></i>
                            <input type="password"
                                   name="newPassword"
                                   placeholder="Enter new password"
                                   required>
                        </div>
                    </div>

                    <div class="field">
                        <label>Confirm New Password</label>

                        <div class="input-box">
                            <i class="fa-solid fa-check"></i>
                            <input type="password"
                                   name="confirmPassword"
                                   placeholder="Confirm new password"
                                   required>
                        </div>
                    </div>

                    <button type="submit" class="save-btn">
                        <i class="fa-solid fa-floppy-disk"></i>
                        Update Password
                    </button>

                </div>

            </div>

        </form>

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
                    <li><button onclick="goHomeSection('services')">Car Detailing</button></li>
                    <li><button onclick="goHomeSection('services')">Ceramic Coating</button></li>
                    <li><button onclick="goHomeSection('services')">Paint Protection</button></li>
                    <li><button onclick="goHomeSection('services')">Interior Cleaning</button></li>
                </ul>
            </div>

            <div class="footer-col">
                <h3>Quick Links</h3>

                <ul>
                    <li><button onclick="goHomeSection('about')">About Us</button></li>
                    <li><button onclick="goBookingPage()">Book Now</button></li>
                    <li><button onclick="goHomeSection('footer')">Contact</button></li>
                    <li><button onclick="Swal.fire({title:'Coming Soon', text:'FAQ is coming soon!', icon:'info', confirmButtonColor:'#0F4C5C'})">FAQ</button></li>
                </ul>
            </div>

            <div class="footer-col">
                <h3>Contact</h3>

                <div class="footer-contact-item">
                    <svg xmlns="http://www.w3.org/2000/svg"
                         viewBox="0 0 24 24"
                         fill="none"
                         stroke="currentColor"
                         stroke-width="2">
                        <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z" />
                        <polyline points="22,6 12,13 2,6" />
                    </svg>

                    <a href="mailto:info@xpertdetailing.com">info@xpertdetailing.com</a>
                </div>

                <div class="footer-contact-item">
                    <svg xmlns="http://www.w3.org/2000/svg"
                         viewBox="0 0 24 24"
                         fill="none"
                         stroke="currentColor"
                         stroke-width="2">
                        <path
                            d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.69 12a19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 3.6 1.17H6.6a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L7.91 8.7a16 16 0 0 0 6 6l.91-.91a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z" />
                    </svg>

                    <a href="tel:+60123456789">+60 12-345 6789</a>
                </div>

                <div class="footer-contact-item">
                    <svg xmlns="http://www.w3.org/2000/svg"
                         viewBox="0 0 24 24"
                         fill="none"
                         stroke="currentColor"
                         stroke-width="2">
                        <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z" />
                        <circle cx="12" cy="10" r="3" />
                    </svg>

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

<script>
    function goHomeSection(sectionId) {
        window.location.href = "<%= request.getContextPath() %>/index.html#" + sectionId;
    }

    function goBookingPage() {
        window.location.href = "<%= request.getContextPath() %>/BookingController";
    }
</script>

</body>
</html>