<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="vehicleBooking.bean.*" %>

<%
    response.setHeader("Cache-Control", "no-cache,no-store,must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    String role = (String) session.getAttribute("role");
    String staffRole = (String) session.getAttribute("staffRole");

    if (role == null || role.trim().isEmpty()) {
        role = staffRole;
    }

    if (role == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    if (!"staff".equalsIgnoreCase(role) && !"owner".equalsIgnoreCase(role)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    boolean isOwner = "owner".equalsIgnoreCase(role);
    boolean isStaff = "staff".equalsIgnoreCase(role);

    String displayName = (String) session.getAttribute("name");

    if (displayName == null || displayName.trim().isEmpty()) {
        displayName = (String) session.getAttribute("staffUsername");
    }

    if (displayName == null || displayName.trim().isEmpty()) {
        displayName = isOwner ? "Owner" : "Staff";
    }

    String dashboardLink = isOwner
            ? request.getContextPath() + "/staff_owner/ownerDashboard.jsp"
            : request.getContextPath() + "/staff_owner/staffDashboard.jsp";

    String profileLink = isOwner
            ? request.getContextPath() + "/staff_owner/profile/ownerProfile.jsp"
            : request.getContextPath() + "/staff_owner/profile/staffProfile.jsp";

    String packageError = (String) session.getAttribute("packageError");
    String packageSuccess = (String) session.getAttribute("packageSuccess");

    session.removeAttribute("packageError");
    session.removeAttribute("packageSuccess");

    ArrayList<PackageBean> packageList =
            (ArrayList<PackageBean>) request.getAttribute("packageList");

    PackageBean editPackage =
            (PackageBean) request.getAttribute("packageBean");

    boolean isEdit = editPackage != null;
    boolean isRoutine = editPackage instanceof RoutineBean;
    boolean isFestive = editPackage instanceof FestivalBean;
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Manage Package</title>

  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

    <!-- page css dulu -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/managePackage.css?v=<%= System.currentTimeMillis() %>">

    <!-- sidebar css LETAK LAST supaya dia override sidebar lama -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css?v=<%= System.currentTimeMillis() %>">



<script>
function openModal() {
    document.getElementById("packageModal").classList.add("active");
}

function closeModal() {
    document.getElementById("packageModal").classList.remove("active");
}

function openViewModal(id, name, type, status, price, service, desc, extra1, extra2, extra3, extra4) {
    document.getElementById("viewID").innerText = id;
    document.getElementById("viewName").innerText = name;
    document.getElementById("viewType").innerText = type + " - " + status;
    document.getElementById("viewPrice").innerText = "RM " + price;
    document.getElementById("viewService").innerText = service;

    var descList = document.getElementById("viewDesc");
    descList.innerHTML = "";

    if (desc != null && desc.trim() !== "") {
        var items = desc.split(/\r?\n|,/);

        for (var i = 0; i < items.length; i++) {
            if (items[i].trim() !== "") {
                var li = document.createElement("li");
                li.innerText = items[i].trim();
                descList.appendChild(li);
            }
        }
    } else {
        var li = document.createElement("li");
        li.innerText = "No description";
        descList.appendChild(li);
    }

    if (type === "Festive") {
        document.getElementById("extraTitle").innerText = "Festive Details";
        document.getElementById("extraContent").innerHTML =
            "<p><b>Festival Name:</b> " + extra1 + "</p>" +
            "<p><b>Start Date:</b> " + extra2 + "</p>" +
            "<p><b>End Date:</b> " + extra3 + "</p>" +
            "<p><b>Discount Rate:</b> " + extra4 + "%</p>";
    } else {
        document.getElementById("extraTitle").innerText = "Routine Details";
        document.getElementById("extraContent").innerHTML =
            "<p><b>Entry Method:</b> " + extra1 + "</p>";
    }

    document.getElementById("viewModal").classList.add("active");
}

function closeViewModal() {
    document.getElementById("viewModal").classList.remove("active");
}

function togglePackageType() {
    var type = document.getElementById("packageType").value;

    document.getElementById("routineSection").style.display =
        type === "routine" ? "block" : "none";

    document.getElementById("festiveSection").style.display =
        type === "festive" ? "block" : "none";
}

function goEdit(packageID) {
    window.location.href = "<%= request.getContextPath() %>/PackageController?action=edit&packageID=" + packageID;
}

function goDelete(packageID) {
    if (confirm("Set this package as unavailable?")) {
        window.location.href = "<%= request.getContextPath() %>/PackageController?action=delete&packageID=" + packageID;
    }
}

function goRestore(packageID) {
    if (confirm("Add this routine package back?")) {
        window.location.href = "<%= request.getContextPath() %>/PackageController?action=restore&packageID=" + packageID;
    }
}

function goHardDelete(packageID) {
    if (confirm("WARNING:\n\nThis will permanently delete the package.\n\nIf customers already made a booking using this package, it cannot be deleted.\n\nContinue?")) {
        window.location.href = "<%= request.getContextPath() %>/PackageController?action=hardDelete&packageID=" + packageID;
    }
}

window.onclick = function(e) {
    var packageModal = document.getElementById("packageModal");
    var viewModal = document.getElementById("viewModal");

    if (e.target === packageModal) closeModal();
    if (e.target === viewModal) closeViewModal();
}

window.onload = function() {
    togglePackageType();

    <% if (isEdit) { %>
        openModal();
    <% } %>
}
</script>

</head>

<body>

<div class="xp-layout">

    <jsp:include page="/sidebar.jsp" />

    <main class="xp-main-content">

        <% if (packageError != null) { %>
            <div class="alert alert-error">
                <i class="fa-solid fa-triangle-exclamation"></i>
                <%= packageError %>
            </div>
        <% } %>

        <% if (packageSuccess != null) { %>
            <div class="alert alert-success">
                <i class="fa-solid fa-circle-check"></i>
                <%= packageSuccess %>
            </div>
        <% } %>

        <div class="package-header">
            <div class="package-title">
                <i class="fa-solid fa-box"></i>
                <span>Manage Packages</span>
            </div>

            <button type="button" class="create-btn" onclick="openModal()">
                <i class="fa-solid fa-plus"></i>
                Create Package
            </button>
        </div>

        <!-- AVAILABLE PACKAGES -->
        <div class="package-section">
            <h2 class="section-title">
                <i class="fa-solid fa-circle-check"></i>
                Available Packages
            </h2>

            <div class="package-divider"></div>

            <div class="package-grid">

            <%
                boolean hasAvailable = false;

                if (packageList != null) {
                    for (PackageBean p : packageList) {

                        boolean festive = p instanceof FestivalBean;
                        boolean routine = p instanceof RoutineBean;
                        boolean unavailable = false;

                        if ("UNAVAILABLE".equalsIgnoreCase(p.getPackageStatus())) {
                            unavailable = true;
                        }

                        String type = festive ? "Festive" : "Routine";
                        String extra1 = "";
                        String extra2 = "";
                        String extra3 = "";
                        String extra4 = "";

                        if (festive) {
                            FestivalBean f = (FestivalBean) p;
                            extra1 = f.getFestivalName();
                            extra2 = f.getStartDate();
                            extra3 = f.getEndDate();
                            extra4 = String.valueOf(f.getDiscountRate());

                            if (f.getEndDate() != null && !f.getEndDate().trim().isEmpty()) {
                                try {
                                    LocalDate endDate = LocalDate.parse(f.getEndDate());

                                    if (endDate.isBefore(LocalDate.now())) {
                                        unavailable = true;
                                    }
                                } catch (Exception ex) {
                                }
                            }
                        } else if (routine) {
                            RoutineBean r = (RoutineBean) p;
                            extra1 = r.getEntryMethod();
                        }

                        if (unavailable) {
                            continue;
                        }

                        hasAvailable = true;

                        String desc = p.getPackageDesc();

                        if (desc == null) {
                            desc = "";
                        }

                        String serviceName = p.getServiceName();

                        if (serviceName == null) {
                            serviceName = "";
                        }

                        String packageName = p.getPackageName();

                        if (packageName == null) {
                            packageName = "";
                        }

                        String statusText = "Available";
            %>

                <div class="package-card <%= festive ? "festive" : "" %>">

                    <div class="card-top">
                        <div>
                            <h2><%= packageName %></h2>

                            <% if (festive) { %>
                                <span class="popular-badge">
                                    <i class="fa-solid fa-fire"></i>
                                    Popular
                                </span>
                            <% } %>
                        </div>

                        <div class="card-actions-top">

                            <button type="button"
                                    class="icon-btn icon-edit"
                                    onclick="goEdit('<%= p.getPackageID() %>')">
                                <i class="fa-solid fa-pen"></i>
                            </button>

                            <button type="button"
                                    class="icon-btn icon-delete"
                                    onclick="goDelete('<%= p.getPackageID() %>')">
                                <i class="fa-solid fa-trash-can"></i>
                            </button>

                        </div>
                    </div>

                    <% if (festive) {
                        FestivalBean f = (FestivalBean) p;
                    %>

                        <div class="package-extra">
                            <%= f.getFestivalName() %> · <%= f.getDiscountRate() %>% off
                        </div>

                    <% } else if (routine) {
                        RoutineBean r = (RoutineBean) p;
                    %>

                        <div class="package-price">
                            From RM <%= String.format("%.0f", p.getPackagePrice()) %>
                            · <%= r.getEntryMethod() %>
                        </div>

                    <% } %>

                    <ul class="desc-list">
                        <%
                            if (!desc.trim().isEmpty()) {
                                String[] items = desc.split("\\r?\\n|,");

                                for (String item : items) {
                                    if (!item.trim().isEmpty()) {
                        %>
                                        <li><%= item.trim() %></li>
                        <%
                                    }
                                }
                            }
                        %>
                    </ul>

                    <button type="button"
                            class="btn-view"
                            onclick="openViewModal(
                                '<%= p.getPackageID() %>',
                                '<%= packageName.replace("'", "\\'") %>',
                                '<%= type %>',
                                '<%= statusText %>',
                                '<%= String.format("%.2f", p.getPackagePrice()) %>',
                                '<%= serviceName.replace("'", "\\'") %>',
                                '<%= desc.replace("'", "\\'").replace("\r", "").replace("\n", "\\n") %>',
                                '<%= extra1 == null ? "" : extra1.replace("'", "\\'") %>',
                                '<%= extra2 == null ? "" : extra2.replace("'", "\\'") %>',
                                '<%= extra3 == null ? "" : extra3.replace("'", "\\'") %>',
                                '<%= extra4 == null ? "" : extra4.replace("'", "\\'") %>'
                            )">
                        <i class="fa-solid fa-eye"></i>
                        View Details
                    </button>

                </div>

            <%
                    }
                }

                if (!hasAvailable) {
            %>
                <div class="empty-box">No available packages.</div>
            <%
                }
            %>

            </div>
        </div>

        <!-- UNAVAILABLE PACKAGES -->
        <div class="package-section">
            <h2 class="section-title unavailable-title">
                <i class="fa-solid fa-box-open"></i>
                Unavailable Packages
            </h2>

            <div class="package-divider"></div>

            <div class="package-grid">

            <%
                boolean hasUnavailable = false;

                if (packageList != null) {
                    for (PackageBean p : packageList) {

                        boolean festive = p instanceof FestivalBean;
                        boolean routine = p instanceof RoutineBean;
                        boolean unavailable = false;

                        if ("UNAVAILABLE".equalsIgnoreCase(p.getPackageStatus())) {
                            unavailable = true;
                        }

                        String type = festive ? "Festive" : "Routine";
                        String extra1 = "";
                        String extra2 = "";
                        String extra3 = "";
                        String extra4 = "";

                        if (festive) {
                            FestivalBean f = (FestivalBean) p;
                            extra1 = f.getFestivalName();
                            extra2 = f.getStartDate();
                            extra3 = f.getEndDate();
                            extra4 = String.valueOf(f.getDiscountRate());

                            if (f.getEndDate() != null && !f.getEndDate().trim().isEmpty()) {
                                try {
                                    LocalDate endDate = LocalDate.parse(f.getEndDate());

                                    if (endDate.isBefore(LocalDate.now())) {
                                        unavailable = true;
                                    }
                                } catch (Exception ex) {
                                }
                            }
                        } else if (routine) {
                            RoutineBean r = (RoutineBean) p;
                            extra1 = r.getEntryMethod();
                        }

                        if (!unavailable) {
                            continue;
                        }

                        hasUnavailable = true;

                        String desc = p.getPackageDesc();

                        if (desc == null) {
                            desc = "";
                        }

                        String serviceName = p.getServiceName();

                        if (serviceName == null) {
                            serviceName = "";
                        }

                        String packageName = p.getPackageName();

                        if (packageName == null) {
                            packageName = "";
                        }

                        String statusText = "Unavailable";
            %>

                <div class="package-card unavailable-card <%= festive ? "festive" : "" %>">

                    <div class="card-top">
                        <div>
                            <h2><%= packageName %></h2>
                            <span class="unavailable-badge">Unavailable</span>
                        </div>

                        <div class="card-actions-top">

                            <button type="button"
                                    class="icon-btn icon-edit"
                                    onclick="goEdit('<%= p.getPackageID() %>')">
                                <i class="fa-solid fa-pen"></i>
                            </button>

                            <% if (routine) { %>
                                <button type="button"
                                        class="icon-btn icon-restore"
                                        onclick="goRestore('<%= p.getPackageID() %>')">
                                    <i class="fa-solid fa-rotate-left"></i>
                                </button>
                            <% } %>

                            <button type="button"
                                    class="icon-btn icon-delete"
                                    onclick="goHardDelete('<%= p.getPackageID() %>')">
                                <i class="fa-solid fa-trash"></i>
                            </button>

                        </div>
                    </div>

                    <% if (festive) {
                        FestivalBean f = (FestivalBean) p;
                    %>

                        <div class="package-extra">
                            <%= f.getFestivalName() %> · <%= f.getDiscountRate() %>% off
                        </div>

                    <% } else if (routine) {
                        RoutineBean r = (RoutineBean) p;
                    %>

                        <div class="package-price">
                            From RM <%= String.format("%.0f", p.getPackagePrice()) %>
                            · <%= r.getEntryMethod() %>
                        </div>

                    <% } %>

                    <ul class="desc-list">
                        <%
                            if (!desc.trim().isEmpty()) {
                                String[] items = desc.split("\\r?\\n|,");

                                for (String item : items) {
                                    if (!item.trim().isEmpty()) {
                        %>
                                        <li><%= item.trim() %></li>
                        <%
                                    }
                                }
                            }
                        %>
                    </ul>

                    <button type="button"
                            class="btn-view"
                            onclick="openViewModal(
                                '<%= p.getPackageID() %>',
                                '<%= packageName.replace("'", "\\'") %>',
                                '<%= type %>',
                                '<%= statusText %>',
                                '<%= String.format("%.2f", p.getPackagePrice()) %>',
                                '<%= serviceName.replace("'", "\\'") %>',
                                '<%= desc.replace("'", "\\'").replace("\r", "").replace("\n", "\\n") %>',
                                '<%= extra1 == null ? "" : extra1.replace("'", "\\'") %>',
                                '<%= extra2 == null ? "" : extra2.replace("'", "\\'") %>',
                                '<%= extra3 == null ? "" : extra3.replace("'", "\\'") %>',
                                '<%= extra4 == null ? "" : extra4.replace("'", "\\'") %>'
                            )">
                        <i class="fa-solid fa-eye"></i>
                        View Details
                    </button>

                </div>

            <%
                    }
                }

                if (!hasUnavailable) {
            %>
                <div class="empty-box">No unavailable packages.</div>
            <%
                }
            %>

            </div>
        </div>

    </main>

</div>

<!-- ADD / EDIT MODAL -->
<div class="modal-overlay" id="packageModal">

    <div class="form-box">

        <div class="modal-header">
            <h2><%= isEdit ? "Edit Package" : "Create Package" %></h2>

            <button type="button" class="close-btn" onclick="closeModal()">
                &times;
            </button>
        </div>

        <form action="<%= request.getContextPath() %>/PackageController" method="post">

            <input type="hidden" name="action" value="<%= isEdit ? "update" : "add" %>">

            <label>Package Type</label>
            <select name="type" id="packageType" onchange="togglePackageType()" required>
                <option value="routine" <%= isRoutine ? "selected" : "" %>>Routine</option>
                <option value="festive" <%= isFestive ? "selected" : "" %>>Festive</option>
            </select>

            <% if (isEdit) { %>
                <label>Package ID</label>
                <input type="text"
                       name="packageID"
                       value="<%= editPackage.getPackageID() %>"
                       readonly
                       required>
            <% } %>

            <label>Package Name</label>
            <input type="text"
                   name="packageName"
                   value="<%= isEdit ? editPackage.getPackageName() : "" %>"
                   required>

            <label>Package Price</label>
            <input type="number"
                   step="0.01"
                   name="packagePrice"
                   value="<%= isEdit ? editPackage.getPackagePrice() : "" %>"
                   required>

            <label>Description</label>
            <textarea name="packageDesc" required><%= isEdit ? editPackage.getPackageDesc() : "" %></textarea>

            <label>Service Name</label>
            <input type="text"
                   name="serviceName"
                   value="<%= isEdit ? editPackage.getServiceName() : "" %>"
                   required>

            <div id="routineSection" class="extra-section">
                <label>Entry Method</label>

                <select name="entryMethod">
                    <option value="walk-in"
                        <%= isRoutine && "walk-in".equalsIgnoreCase(((RoutineBean) editPackage).getEntryMethod()) ? "selected" : "" %>>
                        Walk-in
                    </option>

                    <option value="online booking"
                        <%= isRoutine && "online booking".equalsIgnoreCase(((RoutineBean) editPackage).getEntryMethod()) ? "selected" : "" %>>
                        Online Booking
                    </option>
                </select>
            </div>

            <div id="festiveSection" class="extra-section">
                <label>Festival Name</label>
                <input type="text"
                       name="festivalName"
                       value="<%= isFestive ? ((FestivalBean) editPackage).getFestivalName() : "" %>">

                <label>Start Date</label>
                <input type="date"
                       name="startDate"
                       value="<%= isFestive ? ((FestivalBean) editPackage).getStartDate() : "" %>">

                <label>End Date</label>
                <input type="date"
                       name="endDate"
                       value="<%= isFestive ? ((FestivalBean) editPackage).getEndDate() : "" %>">

                <label>Discount Rate (%)</label>
                <input type="number"
                       step="0.01"
                       name="discountRate"
                       value="<%= isFestive ? ((FestivalBean) editPackage).getDiscountRate() : "" %>">
            </div>

            <div class="form-action">
                <a href="<%= request.getContextPath() %>/PackageController" class="btn-cancel">
                    Cancel
                </a>

                <button type="submit" class="btn-submit">
                    <%= isEdit ? "Update Package" : "Create Package" %>
                </button>
            </div>

        </form>

    </div>

</div>

<!-- VIEW MODAL -->
<div class="modal-overlay" id="viewModal">

    <div class="view-box">

        <div class="modal-header">
            <h2>Package Details</h2>

            <button type="button" class="close-btn" onclick="closeViewModal()">
                &times;
            </button>
        </div>

        <span class="detail-badge" id="viewType"></span>

        <h2 id="viewName" style="font-size:28px; margin-bottom:10px;"></h2>

        <div class="detail-price" id="viewPrice"></div>

        <div class="detail-row">
            <label>Package ID</label>
            <p id="viewID"></p>
        </div>

        <div class="detail-row">
            <label>Service Name</label>
            <p id="viewService"></p>
        </div>

        <div class="detail-row">
            <label>Description</label>
            <ul class="detail-desc" id="viewDesc"></ul>
        </div>

        <div class="detail-row">
            <label id="extraTitle"></label>
            <div id="extraContent"></div>
        </div>

        <button type="button" class="modal-ok-btn" onclick="closeViewModal()">
            OK
        </button>

    </div>

</div>

</body>
</html>