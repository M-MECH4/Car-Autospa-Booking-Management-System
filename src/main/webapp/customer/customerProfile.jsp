<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="jakarta.servlet.http.HttpServletRequest" %>
<%@ page import="vehicleBooking.bean.CustomerBean" %>
<%@ page import="vehicleBooking.dao.CustDAO" %>

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

    public String keepValue(HttpServletRequest request, String paramName, String sessionValue) {
        String paramValue = request.getParameter(paramName);

        if (paramValue != null) {
            return esc(paramValue);
        }

        return esc(sessionValue);
    }
%>

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

    String custName = (String) session.getAttribute("custName");
    String custUsername = (String) session.getAttribute("custUsername");
    String custEmail = (String) session.getAttribute("custEmail");
    String custPhoneNum = (String) session.getAttribute("custPhoneNum");
    String custRace = (String) session.getAttribute("custRace");
    String custReligion = (String) session.getAttribute("custReligion");

    int totalBookings = 0;
    int loyaltyPoints = 0;

    try {
        CustomerBean dbCustomer = CustDAO.getCustomerById(custID);

        if (dbCustomer != null) {
            custName = dbCustomer.getCustName();
            custUsername = dbCustomer.getCustUsername();
            custEmail = dbCustomer.getCustEmail();
            custPhoneNum = dbCustomer.getCustPhoneNum();
            custRace = dbCustomer.getCustRace();
            custReligion = dbCustomer.getCustReligion();

            session.setAttribute("custName", custName);
            session.setAttribute("custUsername", custUsername);
            session.setAttribute("custEmail", custEmail);
            session.setAttribute("custPhoneNum", custPhoneNum);
            session.setAttribute("custRace", custRace);
            session.setAttribute("custReligion", custReligion);
            session.setAttribute("name", custName);
            session.setAttribute("email", custEmail);
        }

        totalBookings = CustDAO.getTotalBookingByCustomer(custID);
        loyaltyPoints = CustDAO.getLoyaltyPointsByCustomer(custID);

    } catch (Exception e) {
        e.printStackTrace();
        totalBookings = 0;
        loyaltyPoints = 0;
    }

    if (custName == null || custName.trim().isEmpty()) {
        custName = "Customer";
    }

    if (custUsername == null) {
        custUsername = "";
    }

    if (custEmail == null) {
        custEmail = "";
    }

    if (custPhoneNum == null) {
        custPhoneNum = "";
    }

    if (custRace == null || custRace.trim().isEmpty()) {
        custRace = "-";
    }

    if (custReligion == null || custReligion.trim().isEmpty()) {
        custReligion = "-";
    }

    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");
    String editModeValue = (String) request.getAttribute("editMode");

    boolean editMode = "true".equalsIgnoreCase(editModeValue);

    String displayName = keepValue(request, "custName", custName);
    String displayUsername = keepValue(request, "custUsername", custUsername);
    String displayEmail = keepValue(request, "custEmail", custEmail);
    String displayPhoneNum = keepValue(request, "custPhoneNum", custPhoneNum);

    String readonlyAttr = editMode ? "" : "readonly";
    String inputBoxClass = editMode ? "input-box" : "input-box readonly";
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>My Account | Customer Profile</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/customerProfile.css?v=<%= System.currentTimeMillis() %>">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css?v=<%= System.currentTimeMillis() %>">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/xpertTheme.css?v=<%= System.currentTimeMillis() %>">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/footer.css?v=<%= System.currentTimeMillis() %>">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>

<body>

<div class="xp-layout">

    <jsp:include page="/sidebar.jsp" />

    <main class="xp-main-content">

        <a href="${pageContext.request.contextPath}/customer/customerDashboard.jsp" class="back-link">
            <i class="fa-solid fa-arrow-left"></i>
            Back to Dashboard
        </a>

        <div class="topbar">
            <div>
                <h1>My Account</h1>
                <p>View and manage your profile information</p>
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

        <form action="${pageContext.request.contextPath}/ProfilecustController" method="post">

            <input type="hidden" name="custID" value="<%= esc(custID) %>">

            <div class="grid">

                <div class="card profile-card">

                    <div class="big-avatar">
                        <i class="fa-regular fa-user"></i>
                    </div>

                    <h2><%= displayName %></h2>

                    <% if (displayEmail == null || displayEmail.trim().isEmpty()) { %>
                        <p>-</p>
                    <% } else { %>
                        <p><%= displayEmail %></p>
                    <% } %>

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

                <div class="card info-card">

                    <h2>Profile Information</h2>

                    <div class="field">
                        <label>Customer ID</label>
                        <div class="input-box readonly">
                            <i class="fa-solid fa-id-card"></i>
                            <input type="text" value="<%= esc(custID) %>" readonly>
                        </div>
                    </div>

                    <div class="field">
                        <label>Full Name</label>
                        <div class="<%= inputBoxClass %>" id="boxCustName">
                            <i class="fa-regular fa-user"></i>
                            <input type="text"
                                   name="custName"
                                   id="custName"
                                   value="<%= displayName %>"
                                   required
                                   <%= readonlyAttr %>>
                        </div>
                    </div>

                    <div class="field">
                        <label>Phone Number</label>
                        <div class="<%= inputBoxClass %>" id="boxCustPhoneNum">
                            <i class="fa-solid fa-phone"></i>
                            <input type="text"
                                   name="custPhoneNum"
                                   id="custPhoneNum"
                                   inputmode="numeric"
                                   pattern="[0-9]+"
                                   maxlength="20"
                                   title="Phone number must contain numbers only."
                                   oninput="this.value = this.value.replace(/[^0-9]/g, '')"
                                   value="<%= displayPhoneNum %>"
                                   required
                                   <%= readonlyAttr %>>
                        </div>
                    </div>

                    <div class="field">
                        <label>Email Address</label>
                        <div class="<%= inputBoxClass %>" id="boxCustEmail">
                            <i class="fa-regular fa-envelope"></i>
                            <input type="email"
                                   name="custEmail"
                                   id="custEmail"
                                   value="<%= displayEmail %>"
                                   required
                                   <%= readonlyAttr %>>
                        </div>
                    </div>

                    <div class="field">
                        <label>Username</label>
                        <div class="<%= inputBoxClass %>" id="boxCustUsername">
                            <i class="fa-regular fa-circle-user"></i>
                            <input type="text"
                                   name="custUsername"
                                   id="custUsername"
                                   value="<%= displayUsername %>"
                                   required
                                   <%= readonlyAttr %>>
                        </div>
                    </div>

                    <div class="field">
                        <label>Race</label>
                        <div class="input-box readonly">
                            <i class="fa-solid fa-users"></i>
                            <input type="text"
                                   value="<%= esc(custRace) %>"
                                   readonly>
                        </div>
                    </div>

                    <div class="field">
                        <label>Religion</label>
                        <div class="input-box readonly">
                            <i class="fa-solid fa-hands-praying"></i>
                            <input type="text"
                                   value="<%= esc(custReligion) %>"
                                   readonly>
                        </div>
                    </div>

                    <button type="button"
                            class="save-btn"
                            id="editBtn"
                            onclick="enableEditMode()"
                            <%= editMode ? "hidden" : "" %>>
                        Edit
                    </button>

                    <button type="submit"
                            class="save-btn"
                            id="saveBtn"
                            <%= editMode ? "" : "hidden" %>>
                        Save
                    </button>

                </div>

                <div class="card security-card">

                    <h2>Security Settings</h2>

                    <div class="security-box">

                        <div class="security-left">
                            <i class="fa-solid fa-shield"></i>

                            <div>
                                <h4>Change Password</h4>
                                <p>Update your account password</p>
                            </div>
                        </div>

                        <a href="${pageContext.request.contextPath}/customer/custPassword.jsp" class="icon-btn">
                            <i class="fa-solid fa-pen"></i>
                        </a>

                    </div>

                </div>

            </div>

        </form>

    </main>

</div>

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
                    <li><button type="button" onclick="goHomeSection('services')">Car Detailing</button></li>
                    <li><button type="button" onclick="goHomeSection('services')">Ceramic Coating</button></li>
                    <li><button type="button" onclick="goHomeSection('services')">Paint Protection</button></li>
                    <li><button type="button" onclick="goHomeSection('services')">Interior Cleaning</button></li>
                </ul>
            </div>

            <div class="footer-col">
                <h3>Quick Links</h3>

                <ul>
                    <li><button type="button" onclick="goHomeSection('about')">About Us</button></li>
                    <li><button type="button" onclick="goBookingPage()">Book Now</button></li>
                    <li><button type="button" onclick="goHomeSection('footer')">Contact</button></li>
                    <li><button type="button" onclick="Swal.fire({title:'Coming Soon', text:'FAQ is coming soon!', icon:'info', confirmButtonColor:'#0F4C5C'})">FAQ</button></li>
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

<script>
    function enableEditMode() {
        document.getElementById("custName").removeAttribute("readonly");
        document.getElementById("custPhoneNum").removeAttribute("readonly");
        document.getElementById("custEmail").removeAttribute("readonly");
        document.getElementById("custUsername").removeAttribute("readonly");

        document.getElementById("boxCustName").classList.remove("readonly");
        document.getElementById("boxCustPhoneNum").classList.remove("readonly");
        document.getElementById("boxCustEmail").classList.remove("readonly");
        document.getElementById("boxCustUsername").classList.remove("readonly");

        document.getElementById("editBtn").hidden = true;
        document.getElementById("saveBtn").hidden = false;

        document.getElementById("custName").focus();
    }

    function goHomeSection(sectionId) {
        window.location.href = "<%= request.getContextPath() %>/index.html#" + sectionId;
    }

    function goBookingPage() {
        window.location.href = "<%= request.getContextPath() %>/BookingController";
    }
</script>

</body>
</html>