<%@ page pageEncoding="UTF-8"
    contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="vehicleBooking.bean.*" %>

<%
    response.setHeader(
            "Cache-Control",
            "no-cache,no-store,must-revalidate"
    );

    response.setHeader(
            "Pragma",
            "no-cache"
    );

    response.setDateHeader(
            "Expires",
            0
    );

    String role =
            (String) session.getAttribute("role");

    String staffRole =
            (String) session.getAttribute("staffRole");

    if (role == null || role.trim().isEmpty()) {
        role = staffRole;
    }

    if (role == null) {

        response.sendRedirect(
                request.getContextPath()
                + "/login.jsp"
        );

        return;
    }

    if (!"staff".equalsIgnoreCase(role)
            && !"owner".equalsIgnoreCase(role)) {

        response.sendRedirect(
                request.getContextPath()
                + "/login.jsp"
        );

        return;
    }

    boolean isOwner =
            "owner".equalsIgnoreCase(role);

    boolean isStaff =
            "staff".equalsIgnoreCase(role);

    String displayName =
            (String) session.getAttribute("name");

    if (displayName == null
            || displayName.trim().isEmpty()) {

        displayName =
                (String) session.getAttribute(
                        "staffUsername"
                );
    }

    if (displayName == null
            || displayName.trim().isEmpty()) {

        displayName =
                isOwner ? "Owner" : "Staff";
    }

    String dashboardLink =
            isOwner
            ? request.getContextPath()
                    + "/staff_owner/ownerDashboard.jsp"
            : request.getContextPath()
                    + "/staff_owner/staffDashboard.jsp";

    String profileLink =
            isOwner
            ? request.getContextPath()
                    + "/staff_owner/profile/"
                    + "ownerProfile.jsp"
            : request.getContextPath()
                    + "/staff_owner/profile/"
                    + "staffProfile.jsp";

    String packageError =
            (String) session.getAttribute(
                    "packageError"
            );

    String packageSuccess =
            (String) session.getAttribute(
                    "packageSuccess"
            );

    session.removeAttribute("packageError");
    session.removeAttribute("packageSuccess");

    ArrayList<PackageBean> packageList =
            (ArrayList<PackageBean>)
                    request.getAttribute(
                            "packageList"
                    );

    PackageBean editPackage =
            (PackageBean)
                    request.getAttribute(
                            "packageBean"
                    );

    boolean isEdit =
            editPackage != null;

    boolean isRoutine =
            editPackage instanceof RoutineBean;

    boolean isFestive =
            editPackage instanceof FestivalBean;

    String editTargetRace = "ALL";
    String editTargetReligion = "ALL";

    if (isFestive) {

        FestivalBean editFestive =
                (FestivalBean) editPackage;

        editTargetRace =
                editFestive.getTargetRace();

        editTargetReligion =
                editFestive.getTargetReligion();

        if (editTargetRace == null
                || editTargetRace.trim().isEmpty()) {

            editTargetRace = "ALL";
        }

        if (editTargetReligion == null
                || editTargetReligion
                        .trim()
                        .isEmpty()) {

            editTargetReligion = "ALL";
        }
    }
%>

<!DOCTYPE html>
<html>

<head>

<meta charset="UTF-8">

<title>Manage Package</title>

<link
    href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap"
    rel="stylesheet">

<link
    rel="stylesheet"
    href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

<link
    rel="stylesheet"
    href="${pageContext.request.contextPath}/css/managePackage.css?v=<%= System.currentTimeMillis() %>">

<link
    rel="stylesheet"
    href="${pageContext.request.contextPath}/css/sidebar.css?v=<%= System.currentTimeMillis() %>">

<link
    rel="stylesheet"
    href="${pageContext.request.contextPath}/css/xpertTheme.css?v=<%= System.currentTimeMillis() %>">

<style>

.price-breakdown {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    gap: 8px;
    margin: 10px 0;
}

.original-price {
    color: #6b7280;
    font-size: 14px;
    font-weight: 600;
    text-decoration: line-through;
}

.after-discount-price {
    color: #15803d;
    font-size: 18px;
    font-weight: 800;
}

.unavailable-card .after-discount-price {
    color: #6b7280;
}

.modal-original-price {
    color: #6b7280;
    font-size: 15px;
    font-weight: 600;
    text-decoration: line-through;
    margin-bottom: 4px;
}

.modal-after-discount-price {
    color: #15803d;
    font-size: 24px;
    font-weight: 900;
}

</style>

<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<script>

function openModal() {

    document
        .getElementById("packageModal")
        .classList.add("active");
}

function closeModal() {

    document
        .getElementById("packageModal")
        .classList.remove("active");
}

function formatEligibility(value) {

    if (value == null || value.trim() === "") {
        return "ALL";
    }

    return value.replace("_", " ");
}

function openViewModal(
        id,
        name,
        type,
        status,
        price,
        service,
        desc,
        extra1,
        extra2,
        extra3,
        extra4,
        extra5,
        extra6) {

    document
        .getElementById("viewID")
        .innerText = id;

    document
        .getElementById("viewName")
        .innerText = name;

    document
        .getElementById("viewType")
        .innerText = type + " - " + status;

    var originalPrice =
        Number(price);

    var priceContainer =
        document.getElementById("viewPrice");

    if (!Number.isFinite(originalPrice)) {
        originalPrice = 0;
    }

    if (type === "Festive") {

        var discountRate =
            Number(extra4);

        if (!Number.isFinite(discountRate)) {
            discountRate = 0;
        }

        discountRate =
            Math.max(
                0,
                Math.min(100, discountRate)
            );

        var afterDiscountPrice =
            originalPrice
            - (
                originalPrice
                * discountRate
                / 100
            );

        priceContainer.innerHTML =
            "<div class='modal-original-price'>"
            + "Original: RM "
            + originalPrice.toFixed(2)
            + "</div>"
            + "<div class='modal-after-discount-price'>"
            + "After Discount: RM "
            + afterDiscountPrice.toFixed(2)
            + "</div>";

    } else {

        priceContainer.innerHTML =
            "<div class='modal-after-discount-price'>"
            + "RM "
            + originalPrice.toFixed(2)
            + "</div>";
    }

    document
        .getElementById("viewService")
        .innerText = service;

    var descList =
        document.getElementById("viewDesc");

    descList.innerHTML = "";

    if (desc != null
            && desc.trim() !== "") {

        var items =
            desc.split(/\r?\n|,/);

        for (var i = 0;
                i < items.length;
                i++) {

            if (items[i].trim() !== "") {

                var li =
                    document.createElement("li");

                li.innerText =
                    items[i].trim();

                descList.appendChild(li);
            }
        }

    } else {

        var li =
            document.createElement("li");

        li.innerText =
            "No description";

        descList.appendChild(li);
    }

    if (type === "Festive") {

        document
            .getElementById("extraTitle")
            .innerText = "Festive Details";

        document
            .getElementById("extraContent")
            .innerHTML =
                "<p><b>Festival Name:</b> "
                + extra1
                + "</p>"
                + "<p><b>Start Date:</b> "
                + extra2
                + "</p>"
                + "<p><b>End Date:</b> "
                + extra3
                + "</p>"
                + "<p><b>Discount Rate:</b> "
                + extra4
                + "%</p>"
                + "<p><b>Target Race:</b> "
                + formatEligibility(extra5)
                + "</p>"
                + "<p><b>Target Religion:</b> "
                + formatEligibility(extra6)
                + "</p>";

    } else {

        document
            .getElementById("extraTitle")
            .innerText = "Routine Details";

        document
            .getElementById("extraContent")
            .innerHTML =
                "<p><b>Entry Method:</b> "
                + extra1
                + "</p>";
    }

    document
        .getElementById("viewModal")
        .classList.add("active");
}

function closeViewModal() {

    document
        .getElementById("viewModal")
        .classList.remove("active");
}

function togglePackageType() {

    var type =
        document
            .getElementById("packageType")
            .value;

    var isFestive =
        type === "festive";

    document
        .getElementById("routineSection")
        .style.display =
            type === "routine"
            ? "block"
            : "none";

    document
        .getElementById("festiveSection")
        .style.display =
            isFestive
            ? "block"
            : "none";

    var discountRateInput =
        document.getElementById(
                "discountRate"
        );

    if (discountRateInput != null) {
        discountRateInput.required =
            isFestive;
    }
}

function validatePackageForm() {

    var type =
        document
            .getElementById("packageType")
            .value;

    if (type !== "festive") {
        return true;
    }

    var discountRateInput =
        document.getElementById(
                "discountRate"
        );

    var discountRateText =
        discountRateInput
            .value
            .trim();

    var discountRate =
        Number(discountRateText);

    if (discountRateText === ""
            || !Number.isFinite(
                    discountRate
            )) {

        Swal.fire({
            icon: "error",
            title: "Invalid Discount Rate",
            text:
                "Please enter a valid "
                + "discount rate between "
                + "0 and 100."
        });

        discountRateInput.focus();

        return false;
    }

    if (discountRate < 0
            || discountRate > 100) {

        Swal.fire({
            icon: "error",
            title: "Invalid Discount Rate",
            text:
                "Discount rate must be "
                + "between 0 and 100."
        });

        discountRateInput.focus();

        return false;
    }

    return true;
}

function goEdit(packageID) {

    window.location.href =
        "<%= request.getContextPath() %>"
        + "/PackageController"
        + "?action=edit"
        + "&packageID="
        + packageID;
}

function goDelete(packageID) {

    Swal.fire({
        title: "Delete Package?",
        html:
            "If this package is linked "
            + "to a booking, it will be "
            + "set to <b>UNAVAILABLE</b>."
            + "<br><br>"
            + "It will be permanently "
            + "deleted otherwise.",
        icon: "warning",
        showCancelButton: true,
        confirmButtonColor: "#d33",
        cancelButtonColor: "#6c757d",
        confirmButtonText: "Delete",
        cancelButtonText: "Cancel"
    }).then((result) => {

        if (result.isConfirmed) {

            window.location.href =
                "<%= request.getContextPath() %>"
                + "/PackageController"
                + "?action=delete"
                + "&packageID="
                + packageID;
        }
    });
}

function goRestore(packageID) {

    Swal.fire({
        title: "Restore Package?",
        text:
            "This package will become "
            + "available for booking again.",
        icon: "question",
        showCancelButton: true,
        confirmButtonColor: "#198754",
        cancelButtonColor: "#6c757d",
        confirmButtonText: "Restore",
        cancelButtonText: "Cancel"
    }).then((result) => {

        if (result.isConfirmed) {

            window.location.href =
                "<%= request.getContextPath() %>"
                + "/PackageController"
                + "?action=restore"
                + "&packageID="
                + packageID;
        }
    });
}

window.onclick = function(e) {

    var packageModal =
        document.getElementById(
                "packageModal"
        );

    var viewModal =
        document.getElementById(
                "viewModal"
        );

    if (e.target === packageModal) {
        closeModal();
    }

    if (e.target === viewModal) {
        closeViewModal();
    }
};

window.onload = function() {

    togglePackageType();

    <% if (isEdit) { %>
        openModal();
    <% } %>
};

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

                <div>

                    <h1>Manage Packages</h1>

                    <p>
                        Create, update and manage packages.
                        Packages that have been used for
                        bookings cannot be deleted.
                        <br>
                        They will become unavailable instead.
                    </p>

                </div>

            </div>

            <button
                type="button"
                class="create-btn"
                onclick="openModal()">

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

                        boolean festive =
                                p instanceof FestivalBean;

                        boolean routine =
                                p instanceof RoutineBean;

                        boolean statusUnavailable =
                                "UNAVAILABLE"
                                    .equalsIgnoreCase(
                                        p.getPackageStatus()
                                    );

                        boolean unavailable =
                                statusUnavailable;

                        String type =
                                festive
                                ? "Festive"
                                : "Routine";

                        String extra1 = "";
                        String extra2 = "";
                        String extra3 = "";
                        String extra4 = "";
                        String extra5 = "";
                        String extra6 = "";

                        if (festive) {

                            FestivalBean f =
                                    (FestivalBean) p;

                            extra1 =
                                    f.getFestivalName();

                            extra2 =
                                    f.getStartDate();

                            extra3 =
                                    f.getEndDate();

                            extra4 =
                                    String.valueOf(
                                            f.getDiscountRate()
                                    );

                            extra5 =
                                    f.getTargetRace();

                            extra6 =
                                    f.getTargetReligion();

                            if (f.getEndDate() != null
                                    && !f.getEndDate()
                                        .trim()
                                        .isEmpty()) {

                                try {

                                    LocalDate endDate =
                                            LocalDate.parse(
                                                    f.getEndDate()
                                            );

                                    if (endDate.isBefore(
                                            LocalDate.now()
                                    )) {

                                        unavailable = true;
                                    }

                                } catch (Exception ex) {
                                }
                            }

                        } else if (routine) {

                            RoutineBean r =
                                    (RoutineBean) p;

                            extra1 =
                                    r.getEntryMethod();
                        }

                        if (unavailable) {
                            continue;
                        }

                        hasAvailable = true;

                        String desc =
                                p.getPackageDesc();

                        if (desc == null) {
                            desc = "";
                        }

                        String serviceName =
                                p.getServiceName();

                        if (serviceName == null) {
                            serviceName = "";
                        }

                        String packageName =
                                p.getPackageName();

                        if (packageName == null) {
                            packageName = "";
                        }

                        String statusText =
                                "Available";
            %>

                <div class="package-card <%= festive ? "festive" : "" %>">

                    <div class="card-top">

                        <div>

                            <h2>
                                <%= packageName %>
                            </h2>

                            <% if (festive) { %>

                                <span class="popular-badge">

                                    <i class="fa-solid fa-fire"></i>

                                    Festive

                                </span>

                            <% } %>

                        </div>

                        <div class="card-actions-top">

                            <button
                                type="button"
                                class="icon-btn icon-edit"
                                onclick="goEdit('<%= p.getPackageID() %>')">

                                Edit

                            </button>

                            <button
                                type="button"
                                class="icon-btn icon-delete"
                                onclick="goDelete('<%= p.getPackageID() %>')">

                                Delete

                            </button>

                        </div>

                    </div>

                    <% if (festive) {

                        FestivalBean f =
                                (FestivalBean) p;

                        double safeDiscountRate =
                                Math.max(
                                    0,
                                    Math.min(
                                        100,
                                        f.getDiscountRate()
                                    )
                                );

                        double afterDiscountPrice =
                                p.getPackagePrice()
                                - (
                                    p.getPackagePrice()
                                    * safeDiscountRate
                                    / 100.0
                                );
                    %>

                        <div class="package-price price-breakdown">

                            <span class="original-price">

                                Original: RM

                                <%= String.format(
                                        "%.2f",
                                        p.getPackagePrice()
                                ) %>

                            </span>

                            <span class="after-discount-price">

                                After Discount: RM

                                <%= String.format(
                                        "%.2f",
                                        afterDiscountPrice
                                ) %>

                            </span>

                        </div>

                        <div class="package-extra">

                            <%= f.getFestivalName() %>

                            ·

                            <%= f.getDiscountRate() %>% off

                        </div>

                        <div class="package-extra">

                            Eligibility:

                            <%= f.getTargetRace() %>

                            /

                            <%= f.getTargetReligion() %>

                        </div>

                    <% } else if (routine) {

                        RoutineBean r =
                                (RoutineBean) p;
                    %>

                        <div class="package-price">

                            From RM

                            <%= String.format(
                                    "%.0f",
                                    p.getPackagePrice()
                            ) %>

                            ·

                            <%= r.getEntryMethod() %>

                        </div>

                    <% } %>

                    <ul class="desc-list">

                        <%
                            if (!desc.trim().isEmpty()) {

                                String[] items =
                                        desc.split(
                                                "\\r?\\n|,"
                                        );

                                for (String item : items) {

                                    if (!item
                                            .trim()
                                            .isEmpty()) {
                        %>

                                        <li>
                                            <%= item.trim() %>
                                        </li>

                        <%
                                    }
                                }
                            }
                        %>

                    </ul>

                    <button
                        type="button"
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
                            '<%= extra4 == null ? "" : extra4.replace("'", "\\'") %>',
                            '<%= extra5 == null ? "ALL" : extra5.replace("'", "\\'") %>',
                            '<%= extra6 == null ? "ALL" : extra6.replace("'", "\\'") %>'
                        )">

                        View Details

                    </button>

                </div>

            <%
                    }
                }

                if (!hasAvailable) {
            %>

                <div class="empty-box">
                    No available packages.
                </div>

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

                        boolean festive =
                                p instanceof FestivalBean;

                        boolean routine =
                                p instanceof RoutineBean;

                        boolean statusUnavailable =
                                "UNAVAILABLE"
                                    .equalsIgnoreCase(
                                        p.getPackageStatus()
                                    );

                        boolean unavailable =
                                statusUnavailable;

                        String type =
                                festive
                                ? "Festive"
                                : "Routine";

                        String extra1 = "";
                        String extra2 = "";
                        String extra3 = "";
                        String extra4 = "";
                        String extra5 = "";
                        String extra6 = "";

                        if (festive) {

                            FestivalBean f =
                                    (FestivalBean) p;

                            extra1 =
                                    f.getFestivalName();

                            extra2 =
                                    f.getStartDate();

                            extra3 =
                                    f.getEndDate();

                            extra4 =
                                    String.valueOf(
                                            f.getDiscountRate()
                                    );

                            extra5 =
                                    f.getTargetRace();

                            extra6 =
                                    f.getTargetReligion();

                            if (f.getEndDate() != null
                                    && !f.getEndDate()
                                        .trim()
                                        .isEmpty()) {

                                try {

                                    LocalDate endDate =
                                            LocalDate.parse(
                                                    f.getEndDate()
                                            );

                                    if (endDate.isBefore(
                                            LocalDate.now()
                                    )) {

                                        unavailable = true;
                                    }

                                } catch (Exception ex) {
                                }
                            }

                        } else if (routine) {

                            RoutineBean r =
                                    (RoutineBean) p;

                            extra1 =
                                    r.getEntryMethod();
                        }

                        if (!unavailable) {
                            continue;
                        }

                        hasUnavailable = true;

                        String desc =
                                p.getPackageDesc();

                        if (desc == null) {
                            desc = "";
                        }

                        String serviceName =
                                p.getServiceName();

                        if (serviceName == null) {
                            serviceName = "";
                        }

                        String packageName =
                                p.getPackageName();

                        if (packageName == null) {
                            packageName = "";
                        }

                        String statusText =
                                "Unavailable";
            %>

                <div class="package-card unavailable-card <%= festive ? "festive" : "" %>">

                    <div class="card-top">

                        <div>

                            <h2>
                                <%= packageName %>
                            </h2>

                            <span class="unavailable-badge">
                                Unavailable
                            </span>

                        </div>

                    </div>

                    <% if (festive) {

                        FestivalBean f =
                                (FestivalBean) p;

                        double safeDiscountRate =
                                Math.max(
                                    0,
                                    Math.min(
                                        100,
                                        f.getDiscountRate()
                                    )
                                );

                        double afterDiscountPrice =
                                p.getPackagePrice()
                                - (
                                    p.getPackagePrice()
                                    * safeDiscountRate
                                    / 100.0
                                );
                    %>

                        <div class="package-price price-breakdown">

                            <span class="original-price">

                                Original: RM

                                <%= String.format(
                                        "%.2f",
                                        p.getPackagePrice()
                                ) %>

                            </span>

                            <span class="after-discount-price">

                                After Discount: RM

                                <%= String.format(
                                        "%.2f",
                                        afterDiscountPrice
                                ) %>

                            </span>

                        </div>

                        <div class="package-extra">

                            <%= f.getFestivalName() %>

                            ·

                            <%= f.getDiscountRate() %>% off

                        </div>

                        <div class="package-extra">

                            Eligibility:

                            <%= f.getTargetRace() %>

                            /

                            <%= f.getTargetReligion() %>

                        </div>

                    <% } else if (routine) {

                        RoutineBean r =
                                (RoutineBean) p;
                    %>

                        <div class="package-price">

                            From RM

                            <%= String.format(
                                    "%.0f",
                                    p.getPackagePrice()
                            ) %>

                            ·

                            <%= r.getEntryMethod() %>

                        </div>

                    <% } %>

                    <ul class="desc-list">

                        <%
                            if (!desc.trim().isEmpty()) {

                                String[] items =
                                        desc.split(
                                                "\\r?\\n|,"
                                        );

                                for (String item : items) {

                                    if (!item
                                            .trim()
                                            .isEmpty()) {
                        %>

                                        <li>
                                            <%= item.trim() %>
                                        </li>

                        <%
                                    }
                                }
                            }
                        %>

                    </ul>

                    <button
                        type="button"
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
                            '<%= extra4 == null ? "" : extra4.replace("'", "\\'") %>',
                            '<%= extra5 == null ? "ALL" : extra5.replace("'", "\\'") %>',
                            '<%= extra6 == null ? "ALL" : extra6.replace("'", "\\'") %>'
                        )">

                        View Details

                    </button>

                </div>

            <%
                    }
                }

                if (!hasUnavailable) {
            %>

                <div class="empty-box">
                    No unavailable packages.
                </div>

            <%
                }
            %>

            </div>

        </div>

    </main>

</div>

<!-- ADD / EDIT MODAL -->

<div
    class="modal-overlay"
    id="packageModal">

    <div class="form-box">

        <div class="modal-header">

            <h2>
                <%= isEdit
                    ? "Edit Package"
                    : "Create Package" %>
            </h2>

            <button
                type="button"
                class="close-btn"
                onclick="closeModal()">

                &times;

            </button>

        </div>

        <form
            action="<%= request.getContextPath() %>/PackageController"
            method="post"
            onsubmit="return validatePackageForm();">

            <input
                type="hidden"
                name="action"
                value="<%= isEdit ? "update" : "add" %>">

            <label>Package Type</label>

            <select
                name="type"
                id="packageType"
                onchange="togglePackageType()"
                required>

                <option
                    value="routine"
                    <%= isRoutine ? "selected" : "" %>>

                    Routine

                </option>

                <option
                    value="festive"
                    <%= isFestive ? "selected" : "" %>>

                    Festive

                </option>

            </select>

            <% if (isEdit) { %>

                <label>Package ID</label>

                <input
                    type="text"
                    name="packageID"
                    value="<%= editPackage.getPackageID() %>"
                    readonly
                    required>

            <% } %>

            <label>Package Name</label>

            <input
                type="text"
                name="packageName"
                value="<%= isEdit ? editPackage.getPackageName() : "" %>"
                required>

            <label>Package Price</label>

            <input
                type="number"
                step="0.01"
                name="packagePrice"
                value="<%= isEdit ? editPackage.getPackagePrice() : "" %>"
                required>

            <label>Description</label>

            <textarea
                name="packageDesc"
                required><%= isEdit ? editPackage.getPackageDesc() : "" %></textarea>

            <label>Service Name</label>

            <input
                type="text"
                name="serviceName"
                value="<%= isEdit ? editPackage.getServiceName() : "" %>"
                required>

            <div
                id="routineSection"
                class="extra-section">

                <label>Entry Method</label>

                <select name="entryMethod">

                    <option
                        value="walk-in"
                        <%= isRoutine
                            && "walk-in"
                                .equalsIgnoreCase(
                                    ((RoutineBean) editPackage)
                                        .getEntryMethod()
                                )
                            ? "selected"
                            : "" %>>

                        Walk-in

                    </option>

                    <option
                        value="online booking"
                        <%= isRoutine
                            && "online booking"
                                .equalsIgnoreCase(
                                    ((RoutineBean) editPackage)
                                        .getEntryMethod()
                                )
                            ? "selected"
                            : "" %>>

                        Online Booking

                    </option>

                </select>

            </div>

            <div
                id="festiveSection"
                class="extra-section">

                <label>Festival Name</label>

                <input
                    type="text"
                    name="festivalName"
                    value="<%= isFestive ? ((FestivalBean) editPackage).getFestivalName() : "" %>">

                <label>Start Date</label>

                <input
                    type="date"
                    name="startDate"
                    value="<%= isFestive ? ((FestivalBean) editPackage).getStartDate() : "" %>">

                <label>End Date</label>

                <input
                    type="date"
                    name="endDate"
                    value="<%= isFestive ? ((FestivalBean) editPackage).getEndDate() : "" %>">

                <label>Discount Rate (%)</label>

                <input
                    type="number"
                    id="discountRate"
                    step="0.01"
                    min="0"
                    max="100"
                    name="discountRate"
                    value="<%= isFestive ? ((FestivalBean) editPackage).getDiscountRate() : "" %>">

                <label>Target Race</label>

                <select name="targetRace">

                    <option
                        value="ALL"
                        <%= "ALL".equalsIgnoreCase(editTargetRace) ? "selected" : "" %>>

                        All Race

                    </option>

                    <option
                        value="MALAY"
                        <%= "MALAY".equalsIgnoreCase(editTargetRace) ? "selected" : "" %>>

                        Malay

                    </option>

                    <option
                        value="CHINESE"
                        <%= "CHINESE".equalsIgnoreCase(editTargetRace) ? "selected" : "" %>>

                        Chinese

                    </option>

                    <option
                        value="INDIAN"
                        <%= "INDIAN".equalsIgnoreCase(editTargetRace) ? "selected" : "" %>>

                        Indian

                    </option>

                    <option
                        value="BUMIPUTERA"
                        <%= "BUMIPUTERA".equalsIgnoreCase(editTargetRace) ? "selected" : "" %>>

                        Bumiputera

                    </option>

                    <option
                        value="OTHER"
                        <%= "OTHER".equalsIgnoreCase(editTargetRace) ? "selected" : "" %>>

                        Other

                    </option>

                </select>

                <label>Target Religion</label>

                <select name="targetReligion">

                    <option
                        value="ALL"
                        <%= "ALL".equalsIgnoreCase(editTargetReligion) ? "selected" : "" %>>

                        All Religion

                    </option>

                    <option
                        value="ISLAM"
                        <%= "ISLAM".equalsIgnoreCase(editTargetReligion) ? "selected" : "" %>>

                        Islam

                    </option>

                    <option
                        value="BUDDHISM"
                        <%= "BUDDHISM".equalsIgnoreCase(editTargetReligion) ? "selected" : "" %>>

                        Buddhism

                    </option>

                    <option
                        value="CHRISTIANITY"
                        <%= "CHRISTIANITY".equalsIgnoreCase(editTargetReligion) ? "selected" : "" %>>

                        Christianity

                    </option>

                    <option
                        value="HINDUISM"
                        <%= "HINDUISM".equalsIgnoreCase(editTargetReligion) ? "selected" : "" %>>

                        Hinduism

                    </option>

                    <option
                        value="OTHER"
                        <%= "OTHER".equalsIgnoreCase(editTargetReligion) ? "selected" : "" %>>

                        Other

                    </option>

                </select>

            </div>

            <div class="form-action">

                <a
                    href="<%= request.getContextPath() %>/PackageController"
                    class="btn-cancel">

                    Cancel

                </a>

                <button
                    type="submit"
                    class="btn-submit">

                    <%= isEdit
                        ? "Update Package"
                        : "Create Package" %>

                </button>

            </div>

        </form>

    </div>

</div>

<!-- VIEW MODAL -->

<div
    class="modal-overlay"
    id="viewModal">

    <div class="view-box">

        <div class="modal-header">

            <h2>Package Details</h2>

            <button
                type="button"
                class="close-btn"
                onclick="closeViewModal()">

                &times;

            </button>

        </div>

        <span
            class="detail-badge"
            id="viewType">
        </span>

        <h2
            id="viewName"
            style="font-size:28px; margin-bottom:10px;">
        </h2>

        <div
            class="detail-price"
            id="viewPrice">
        </div>

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

            <ul
                class="detail-desc"
                id="viewDesc">
            </ul>

        </div>

        <div class="detail-row">

            <label id="extraTitle"></label>

            <div id="extraContent"></div>

        </div>

        <button
            type="button"
            class="modal-ok-btn"
            onclick="closeViewModal()">

            OK

        </button>

    </div>

</div>

</body>
</html>