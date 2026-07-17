<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<%
    String custID =
            (String) session.getAttribute("custID");

    String custName =
            (String) session.getAttribute("custName");

    String role =
            (String) session.getAttribute("role");

    if (custID == null
            || role == null
            || !"customer".equalsIgnoreCase(role)) {

        response.sendRedirect(
                request.getContextPath() + "/login.jsp"
        );
        return;
    }

    if (custName == null
            || custName.trim().isEmpty()) {

        custName = "Customer";
    }

    String successMessage =
            (String) session.getAttribute("successMessage");

    String errorMessage =
            (String) session.getAttribute("errorMessage");

    session.removeAttribute("successMessage");
    session.removeAttribute("errorMessage");
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <title>
        Vehicle Management | X-PERT Detailing
    </title>

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <link
        href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap"
        rel="stylesheet">

    <link
        rel="stylesheet"
        href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

    <link
        rel="stylesheet"
        href="${pageContext.request.contextPath}/css/custVehicle.css?v=<%= System.currentTimeMillis() %>">

    <link
        rel="stylesheet"
        href="${pageContext.request.contextPath}/css/sidebar.css?v=<%= System.currentTimeMillis() %>">

    <link
        rel="stylesheet"
        href="${pageContext.request.contextPath}/css/xpertTheme.css?v=<%= System.currentTimeMillis() %>">

    <link
        rel="stylesheet"
        href="${pageContext.request.contextPath}/css/footer.css?v=<%= System.currentTimeMillis() %>">

    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

</head>

<body>

<div class="xp-layout">

    <jsp:include page="/sidebar.jsp" />

    <main class="xp-main-content">

        <!-- PAGE TITLE -->
        <div class="vehicle-top">

            <div class="page-title-group">

                <h1>
                    Vehicle Management
                </h1>

                <p>
                    View, update and manage your vehicles.
                    Vehicles that has made a booking before, can't be deleted.
                </p>

            </div>

            <a
                href="${pageContext.request.contextPath}/customer/vehicle/custVehicle.jsp"
                class="vehicle-new-btn"
                style="text-decoration:none;">

                <i class="fa-solid fa-plus"></i>
                New Vehicle
            </a>

        </div>

        <!-- SUCCESS MESSAGE -->
        <% if (successMessage != null
                && !successMessage.trim().isEmpty()) { %>

            <div class="message success">
                <%= successMessage %>
            </div>

        <% } %>

        <!-- ERROR MESSAGE -->
        <% if (errorMessage != null
                && !errorMessage.trim().isEmpty()) { %>

            <div class="message error">
                <%= errorMessage %>
            </div>

        <% } %>

        <!-- VEHICLE TABLE -->
        <div class="vehicle-table-card">

            <table>

                <thead>

                    <tr>
                        <th>No</th>
                        <th>Plate Number</th>
                        <th>Brand</th>
                        <th>Model</th>
                        <th>Year</th>
                        <th>Action</th>
                    </tr>

                </thead>

                <tbody>

                    <c:choose>

                        <c:when test="${empty vehicles}">

                            <tr>

                                <td
                                    colspan="6"
                                    class="vehicle-empty">

                                    No vehicle found.
                                </td>

                            </tr>

                        </c:when>

                        <c:otherwise>

                            <c:forEach
                                items="${vehicles}"
                                var="v"
                                varStatus="loop">

                                <tr>

                                    <td>
                                        <c:out
                                            value="${loop.index + 1}" />
                                    </td>

                                    <td>
                                        <strong>
                                            <c:out
                                                value="${v.vehicleplatenum}" />
                                        </strong>
                                    </td>

                                    <td>
                                        <c:out
                                            value="${v.vehiclebrand}" />
                                    </td>

                                    <td>
                                        <c:out
                                            value="${v.vehiclemodel}" />
                                    </td>

                                    <td>
                                        <c:out
                                            value="${v.vehicleyear}" />
                                    </td>

                                    <td>

                                        <div class="vehicle-action-row">

                                            <button
                                                type="button"
                                                class="vehicle-btn vehicle-view"
                                                onclick="openViewVehicleModal(
                                                    '${v.vehicleplatenum}',
                                                    '${v.vehiclebrand}',
                                                    '${v.vehiclemodel}',
                                                    '${v.vehicleyear}'
                                                )">

                                                View
                                            </button>

                                            <button
                                                type="button"
                                                class="vehicle-btn vehicle-edit"
                                                onclick="openEditVehicleModal(
                                                    '${v.vehicleplatenum}',
                                                    '${v.vehiclebrand}',
                                                    '${v.vehiclemodel}',
                                                    '${v.vehicleyear}'
                                                )">

                                                Edit
                                            </button>

                                            <c:choose>

                                                <c:when test="${v.deleteAllowed}">

                                                    <button
                                                        type="button"
                                                        class="vehicle-btn vehicle-delete"
                                                        onclick="confirmVehicleDelete(
                                                            '${v.vehicleplatenum}'
                                                        )">

                                                        Delete
                                                    </button>

                                                </c:when>

                                                <c:otherwise>

                                                    <button
                                                        type="button"
                                                        class="vehicle-btn vehicle-delete vehicle-delete-disabled"
                                                        title="This vehicle is linked to an existing booking."
                                                        disabled>

                                                        Delete
                                                    </button>

                                                </c:otherwise>

                                            </c:choose>

                                        </div>

                                    </td>

                                </tr>

                            </c:forEach>

                        </c:otherwise>

                    </c:choose>

                </tbody>

            </table>

        </div>

    </main>

</div>

<!-- VIEW VEHICLE MODAL -->
<div class="modal"
     id="viewVehicleModal">

    <div class="modal-box">

        <div class="modal-header">

            <h2>
                Vehicle Details
            </h2>

            <button
                type="button"
                class="close-btn"
                onclick="closeViewVehicleModal()">

                &times;
            </button>

        </div>

        <div class="form-group">

            <label>
                Plate Number
            </label>

            <input
                type="text"
                id="viewPlate"
                class="form-control"
                readonly>

        </div>

        <div class="form-group">

            <label>
                Brand
            </label>

            <input
                type="text"
                id="viewBrand"
                class="form-control"
                readonly>

        </div>

        <div class="form-group">

            <label>
                Model
            </label>

            <input
                type="text"
                id="viewModel"
                class="form-control"
                readonly>

        </div>

        <div class="form-group">

            <label>
                Year
            </label>

            <input
                type="text"
                id="viewYear"
                class="form-control"
                readonly>

        </div>

    </div>

</div>

<!-- EDIT VEHICLE MODAL -->
<div class="modal"
     id="editVehicleModal">

    <div class="modal-box">

        <div class="modal-header">

            <h2>
                Edit Vehicle
            </h2>

            <button
                type="button"
                class="close-btn"
                onclick="closeEditVehicleModal()">

                &times;
            </button>

        </div>

        <form
            action="${pageContext.request.contextPath}/custVehicleController"
            method="post">

            <input
                type="hidden"
                name="action"
                value="update">

            <div class="form-group">

                <label>
                    Plate Number
                </label>

                <input
                    type="text"
                    id="editPlate"
                    name="vehicleplatenum"
                    class="form-control"
                    readonly>

            </div>

            <div class="form-group">

                <label>
                    Brand
                </label>

                <input
                    type="text"
                    id="editBrand"
                    name="vehiclebrand"
                    class="form-control"
                    required>

            </div>

            <div class="form-group">

                <label>
                    Model
                </label>

                <input
                    type="text"
                    id="editModel"
                    name="vehiclemodel"
                    class="form-control"
                    required>

            </div>

            <div class="form-group">

                <label>
                    Year
                </label>

                <input
                    type="number"
                    id="editYear"
                    name="vehicleyear"
                    class="form-control"
                    min="1980"
                    max="2028"
                    required>

            </div>

            <button
                type="submit"
                class="submit-btn">

                Update Vehicle
            </button>

        </form>

    </div>

</div>

<script>
    function openViewVehicleModal(
        plate,
        brand,
        model,
        year
    ) {
        document.getElementById("viewPlate").value =
            plate;

        document.getElementById("viewBrand").value =
            brand;

        document.getElementById("viewModel").value =
            model;

        document.getElementById("viewYear").value =
            year;

        document.getElementById("viewVehicleModal")
            .classList.add("active");
    }

    function closeViewVehicleModal() {
        document.getElementById("viewVehicleModal")
            .classList.remove("active");
    }

    function openEditVehicleModal(
        plate,
        brand,
        model,
        year
    ) {
        document.getElementById("editPlate").value =
            plate;

        document.getElementById("editBrand").value =
            brand;

        document.getElementById("editModel").value =
            model;

        document.getElementById("editYear").value =
            year;

        document.getElementById("editVehicleModal")
            .classList.add("active");
    }

    function closeEditVehicleModal() {
        document.getElementById("editVehicleModal")
            .classList.remove("active");
    }

    function confirmVehicleDelete(plate) {
        Swal.fire({
            title: "Delete Vehicle?",
            text: "Are you sure you want to delete vehicle "
                    + plate + "?",
            icon: "warning",
            showCancelButton: true,
            confirmButtonColor: "#d33",
            cancelButtonColor: "#6c757d",
            confirmButtonText: "Delete",
            cancelButtonText: "Cancel"
        }).then(function(result) {

            if (result.isConfirmed) {

                window.location.href =
                    "${pageContext.request.contextPath}"
                    + "/custVehicleController"
                    + "?action=delete"
                    + "&vehicleplatenum="
                    + encodeURIComponent(plate);
            }
        });
    }
</script>

<footer id="footer">

    <div class="footer-container">

        <div class="footer-grid">

            <div>

                <div class="footer-brand">
                    X<span>-</span>PERT DETAILING
                </div>

                <p class="footer-tagline">
                    Premium car detailing and maintenance services
                </p>

            </div>

            <div class="footer-col">

                <h3>
                    Services
                </h3>

                <ul>
                    <li>
                        <button type="button">
                            Car Detailing
                        </button>
                    </li>

                    <li>
                        <button type="button">
                            Ceramic Coating
                        </button>
                    </li>

                    <li>
                        <button type="button">
                            Paint Protection
                        </button>
                    </li>

                    <li>
                        <button type="button">
                            Interior Cleaning
                        </button>
                    </li>
                </ul>

            </div>

            <div class="footer-col">

                <h3>
                    Quick Links
                </h3>

                <ul>
                    <li>
                        <button type="button">
                            About Us
                        </button>
                    </li>

                    <li>
                        <button type="button">
                            Book Now
                        </button>
                    </li>

                    <li>
                        <button type="button">
                            Contact
                        </button>
                    </li>

                    <li>
                        <button type="button">
                            FAQ
                        </button>
                    </li>
                </ul>

            </div>

            <div class="footer-col">

                <h3>
                    Contact
                </h3>

                <div class="footer-contact-item">

                    <i class="fa-regular fa-envelope"></i>

                    <a href="mailto:info@xpertdetailing.com">
                        info@xpertdetailing.com
                    </a>

                </div>

                <div class="footer-contact-item">

                    <i class="fa-solid fa-phone"></i>

                    <a href="tel:+60123456789">
                        +60 12-345 6789
                    </a>

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

            <p>
                &copy; 2026 X-PERT DETAILING.
                All rights reserved.
            </p>

        </div>

    </div>

</footer>

</body>

</html>