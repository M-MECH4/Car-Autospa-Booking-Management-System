<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    String custID = (String) session.getAttribute("custID");
    String custName = (String) session.getAttribute("custName");
    String role = (String) session.getAttribute("role");

    if (custID == null || role == null || !"customer".equalsIgnoreCase(role)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String vehicleplatenum = request.getParameter("vehicleplatenum");

    if (vehicleplatenum == null || vehicleplatenum.trim().isEmpty()) {
        response.sendRedirect(request.getContextPath() + "/custVehicleController?action=list");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Delete Vehicle | X-PERT DETAILING</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

      <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

     <!-- page css dulu -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/custVehicle.css?v=<%= System.currentTimeMillis() %>">

    <!-- sidebar css LETAK LAST supaya dia override sidebar lama -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css?v=<%= System.currentTimeMillis() %>">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/xpertTheme.css?v=<%= System.currentTimeMillis() %>">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/footer.css?v=<%= System.currentTimeMillis() %>">
 
 
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>
<body>

<div class="xp-layout">

    <jsp:include page="/sidebar.jsp" />

    <main class="xp-main-content">

    <div class="delete-card">

        <div class="delete-header">
            <div class="delete-icon">
                <i class="fa-solid fa-trash"></i>
            </div>

            <div class="delete-header-text">
                <h1>Confirm Delete</h1>
                <p>Please review before removing this vehicle.</p>
            </div>
        </div>

        <div class="delete-body">
            <p class="delete-message">
                Are you sure you want to delete this vehicle from your account?
            </p>

            <div class="plate-badge">
                <i class="fa-solid fa-car"></i>
                Plate Number: <%= vehicleplatenum %>
            </div>

            <div class="warning-box">
                <i class="fa-solid fa-triangle-exclamation"></i>
                <span>
                    This action cannot be undone. Make sure you really want to remove this vehicle.
                </span>
            </div>

            <div class="btn-row">
                <form action="${pageContext.request.contextPath}/custVehicleController" method="post" style="margin:0;">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="vehicleplatenum" value="<%= vehicleplatenum %>">

                    <button type="submit" class="btn btn-delete">
                        <i class="fa-solid fa-trash"></i>
                        Yes, Delete
                    </button>
                </form>

                <a href="${pageContext.request.contextPath}/custVehicleController?action=list" class="btn btn-cancel">
                    <i class="fa-solid fa-arrow-left"></i>
                    Cancel
                </a>
            </div>
        </div>

    </div>

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
