<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<%
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

    String successMessage = (String) session.getAttribute("successMessage");
    String errorMessage = (String) session.getAttribute("errorMessage");

    session.removeAttribute("successMessage");
    session.removeAttribute("errorMessage");
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>Vehicle Management | X-PERT Detailing</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

    <!-- page css dulu -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/custVehicle.css?v=<%= System.currentTimeMillis() %>">

    <!-- sidebar css LETAK LAST supaya dia override sidebar lama -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css?v=<%= System.currentTimeMillis() %>">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/xpertTheme.css?v=<%= System.currentTimeMillis() %>">
</head>

<body>

<div class="xp-layout">

<jsp:include page="/sidebar.jsp" />

   

    <main class="xp-main-content">

        <div class="vehicle-top">
            <h1>Vehicle Management</h1>

            <a href="${pageContext.request.contextPath}/customer/vehicle/custVehicle.jsp"
               class="vehicle-new-btn"
               style="text-decoration:none;">
                <i class="fa-solid fa-plus"></i>
                New Vehicle
            </a>
        </div>

        <% if (successMessage != null && !successMessage.trim().isEmpty()) { %>
            <div class="message success">
                <%= successMessage %>
            </div>
        <% } %>

        <% if (errorMessage != null && !errorMessage.trim().isEmpty()) { %>
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
                        <th>Action</th>
                    </tr>
                </thead>

                <tbody>

                    <c:choose>

                        <c:when test="${empty vehicles}">
                            <tr>
                                <td colspan="6" class="vehicle-empty">
                                    No vehicle found.
                                </td>
                            </tr>
                        </c:when>

                        <c:otherwise>

                            <c:forEach items="${vehicles}" var="v" varStatus="loop">

                                <tr>
                                    <td>
                                        <c:out value="${loop.index + 1}" />
                                    </td>

                                    <td>
                                        <strong>
                                            <c:out value="${v.vehicleplatenum}" />
                                        </strong>
                                    </td>

                                    <td>
                                        <c:out value="${v.vehiclebrand}" />
                                    </td>

                                    <td>
                                        <c:out value="${v.vehiclemodel}" />
                                    </td>

                                    <td>
                                        <c:out value="${v.vehicleyear}" />
                                    </td>

                                    <td>
                                        <div class="vehicle-action-row">

                                            <button type="button"
                                                    class="vehicle-btn vehicle-view"
                                                    onclick="openViewVehicleModal(
                                                        '${v.vehicleplatenum}',
                                                        '${v.vehiclebrand}',
                                                        '${v.vehiclemodel}',
                                                        '${v.vehicleyear}'
                                                    )">
                                                View
                                            </button>

                                            <button type="button"
                                                    class="vehicle-btn vehicle-edit"
                                                    onclick="openEditVehicleModal(
                                                        '${v.vehicleplatenum}',
                                                        '${v.vehiclebrand}',
                                                        '${v.vehiclemodel}',
                                                        '${v.vehicleyear}'
                                                    )">
                                                Edit
                                            </button>

                                            <a class="vehicle-btn vehicle-delete"
                                               href="${pageContext.request.contextPath}/custVehicleController?action=delete&vehicleplatenum=${v.vehicleplatenum}"
                                               onclick="return confirm('Are you sure you want to delete this vehicle?');">
                                                Delete
                                            </a>

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
<div class="modal" id="viewVehicleModal">
    <div class="modal-box">

        <div class="modal-header">
            <h2>Vehicle Details</h2>

            <button type="button" class="close-btn" onclick="closeViewVehicleModal()">
                &times;
            </button>
        </div>

        <div class="form-group">
            <label>Plate Number</label>
            <input type="text" id="viewPlate" class="form-control" readonly>
        </div>

        <div class="form-group">
            <label>Brand</label>
            <input type="text" id="viewBrand" class="form-control" readonly>
        </div>

        <div class="form-group">
            <label>Model</label>
            <input type="text" id="viewModel" class="form-control" readonly>
        </div>

        <div class="form-group">
            <label>Year</label>
            <input type="text" id="viewYear" class="form-control" readonly>
        </div>

    </div>
</div>

<!-- EDIT VEHICLE MODAL -->
<div class="modal" id="editVehicleModal">
    <div class="modal-box">

        <div class="modal-header">
            <h2>Edit Vehicle</h2>

            <button type="button" class="close-btn" onclick="closeEditVehicleModal()">
                &times;
            </button>
        </div>

        <form action="${pageContext.request.contextPath}/custVehicleController" method="post">

            <input type="hidden" name="action" value="update">

            <div class="form-group">
                <label>Plate Number</label>
                <input type="text" id="editPlate" name="vehicleplatenum" class="form-control" readonly>
            </div>

            <div class="form-group">
                <label>Brand</label>
                <input type="text" id="editBrand" name="vehiclebrand" class="form-control" required>
            </div>

            <div class="form-group">
                <label>Model</label>
                <input type="text" id="editModel" name="vehiclemodel" class="form-control" required>
            </div>

            <div class="form-group">
                <label>Year</label>
              <input type="number"
       id="editYear"
       name="vehicleyear"
       class="form-control"
       min="1980"
       max="2028"
       required>
            </div>

            <button type="submit" class="submit-btn">
                Update Vehicle
            </button>

        </form>

    </div>
</div>

<script>
    function openViewVehicleModal(plate, brand, model, year) {
        document.getElementById("viewPlate").value = plate;
        document.getElementById("viewBrand").value = brand;
        document.getElementById("viewModel").value = model;
        document.getElementById("viewYear").value = year;

        document.getElementById("viewVehicleModal").classList.add("active");
    }

    function closeViewVehicleModal() {
        document.getElementById("viewVehicleModal").classList.remove("active");
    }

    function openEditVehicleModal(plate, brand, model, year) {
        document.getElementById("editPlate").value = plate;
        document.getElementById("editBrand").value = brand;
        document.getElementById("editModel").value = model;
        document.getElementById("editYear").value = year;

        document.getElementById("editVehicleModal").classList.add("active");
    }

    function closeEditVehicleModal() {
        document.getElementById("editVehicleModal").classList.remove("active");
    }
</script>

</body>
</html>