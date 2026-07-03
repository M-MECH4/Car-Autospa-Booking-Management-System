<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="vehicleBooking.bean.InvoiceBean" %>
<%@ page import="vehicleBooking.dao.StaffInvoiceDAO" %>

<%!
    public String safe(String value) {
        if (value == null) {
            return "-";
        }
        return value;
    }

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

    List<InvoiceBean> invoiceList = StaffInvoiceDAO.getCompletedInvoicesForStaff();
    DecimalFormat moneyFormat = new DecimalFormat("0.00");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Staff Invoices | X-PERT DETAILING</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

    <!-- page css dulu -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/staffInvoice.css?v=<%= System.currentTimeMillis() %>">

    <!-- sidebar css LETAK LAST supaya dia override sidebar lama -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css?v=<%= System.currentTimeMillis() %>">
   
</head>

<body>

<div class="xp-layout">

    <jsp:include page="/sidebar.jsp" />
    
    <main class="xp-main-content">

        <div class="page-header">
            <div>
                <h1>
                    <i class="fa-solid fa-file-invoice" style="color:#074858; margin-right:10px;"></i>
                    Staff Invoices
                </h1>
                <p>Staff can generate and print invoices for completed bookings.</p>
            </div>
        </div>

        <div class="invoice-table-card">
            <table>
                <thead>
                    <tr>
                        <th>Invoice No.</th>
                        <th>Invoice Date</th>
                        <th>Customer</th>
                        <th>Vehicle</th>
                        <th>Package</th>
                        <th>Status</th>
                        <th>Amount</th>
                        <th>Actions</th>
                    </tr>
                </thead>

                <tbody>
                <%
                    if (invoiceList == null || invoiceList.size() == 0) {
                %>
                    <tr>
                        <td colspan="8" class="empty-row">
                            No invoice found. Invoice can be generated after booking status is COMPLETED.
                        </td>
                    </tr>
                <%
                    } else {
                        for (InvoiceBean inv : invoiceList) {

                            String vehicleText = safe(inv.getVehiclePlateNum()) + " - " +
                                                 safe(inv.getVehicleBrand()) + " " +
                                                 safe(inv.getVehicleModel()) + " (" +
                                                 inv.getVehicleYear() + ")";

                            String amountText = "RM " + moneyFormat.format(inv.getAmount());
                %>

                    <tr>
                        <td>
                            <span class="invoice-no">
                                <i class="fa-regular fa-file-lines"></i>
                                <%= safe(inv.getInvoiceNo()) %>
                            </span>
                        </td>

                        <td><%= safe(inv.getInvoiceDate()) %></td>

                        <td>
                            <strong><%= safe(inv.getCustomerName()) %></strong><br>
                            <small><%= safe(inv.getCustomerPhone()) %></small>
                        </td>

                        <td><%= safe(inv.getVehiclePlateNum()) %></td>

                        <td><%= safe(inv.getPackageName()) %></td>

                        <td>
                            <span class="paid-badge">
                                <i class="fa-solid fa-check"></i>
                                COMPLETED
                            </span>
                        </td>

                        <td>
                            <span class="amount-cell"><%= amountText %></span>
                        </td>

                        <td>
                            <div class="invoice-actions">

                                <button type="button"
                                        class="btn-invoice btn-view"
                                        data-invoice-no="<%= esc(inv.getInvoiceNo()) %>"
                                        data-invoice-date="<%= esc(inv.getInvoiceDate()) %>"
                                        data-booking-id="<%= esc(inv.getBookingID()) %>"
                                        data-booking-date="<%= esc(inv.getBookingDate()) %>"
                                        data-customer-name="<%= esc(inv.getCustomerName()) %>"
                                        data-customer-phone="<%= esc(inv.getCustomerPhone()) %>"
                                        data-vehicle="<%= esc(vehicleText) %>"
                                        data-package-name="<%= esc(inv.getPackageName()) %>"
                                        data-package-desc="<%= esc(inv.getPackageDesc()) %>"
                                        data-amount="<%= esc(amountText) %>"
                                        onclick="generateInvoice(this)">
                                    <i class="fa-solid fa-file-circle-plus"></i>
                                    Generate
                                </button>

                                <button type="button"
                                        class="btn-invoice btn-print"
                                        disabled
                                        data-generated="N"
                                        data-invoice-no="<%= esc(inv.getInvoiceNo()) %>"
                                        data-invoice-date="<%= esc(inv.getInvoiceDate()) %>"
                                        data-booking-id="<%= esc(inv.getBookingID()) %>"
                                        data-booking-date="<%= esc(inv.getBookingDate()) %>"
                                        data-customer-name="<%= esc(inv.getCustomerName()) %>"
                                        data-customer-phone="<%= esc(inv.getCustomerPhone()) %>"
                                        data-vehicle="<%= esc(vehicleText) %>"
                                        data-package-name="<%= esc(inv.getPackageName()) %>"
                                        data-package-desc="<%= esc(inv.getPackageDesc()) %>"
                                        data-amount="<%= esc(amountText) %>"
                                        onclick="printInvoice(this)">
                                    <i class="fa-solid fa-print"></i>
                                    Print
                                </button>

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

<div id="printArea" class="print-area">

    <div class="company-header">
        <h1>X-PERT <span>DETAILING</span></h1>
        <p>
            JC111, Jalan BMU 2, Bandar Baru Merlimau Utara,<br>
            77300 Merlimau, Melaka<br>
            Tel: +60 12-553 0688
        </p>
    </div>

    <div class="invoice-title-row">
        <h2>INVOICE</h2>

        <div class="invoice-meta">
            <strong>Invoice No:</strong> <span id="printInvoiceNo">-</span><br>
            <strong>Invoice Date:</strong> <span id="printInvoiceDate">-</span><br>
            <strong>Booking ID:</strong> <span id="printBookingID">-</span><br>
            <strong>Booking Date:</strong> <span id="printBookingDate">-</span>
        </div>
    </div>

    <div class="invoice-section">
        <h3>Billed To</h3>

        <div class="invoice-grid">
            <div>
                <div class="field-label">Customer Name</div>
                <div class="field-value" id="printCustomerName">-</div>
            </div>

            <div>
                <div class="field-label">Phone Number</div>
                <div class="field-value" id="printCustomerPhone">-</div>
            </div>

            <div>
                <div class="field-label">Vehicle</div>
                <div class="field-value" id="printVehicle">-</div>
            </div>

            <div>
                <div class="field-label">Service Status</div>
                <div class="field-value">COMPLETED</div>
            </div>
        </div>
    </div>

    <div class="invoice-section">
        <h3>Service Details</h3>

        <table class="service-table">
            <thead>
                <tr>
                    <th>No.</th>
                    <th>Description</th>
                    <th>Amount</th>
                </tr>
            </thead>

            <tbody>
                <tr>
                    <td>1</td>
                    <td>
                        <strong id="printPackageName">-</strong><br>
                        <small id="printPackageDesc">-</small>
                    </td>
                    <td id="printAmount">-</td>
                </tr>
            </tbody>
        </table>

        <div class="total-box">
            <div class="total-inner">
                <div class="total-row">
                    <span>Subtotal</span>
                    <span id="printSubtotal">-</span>
                </div>

                <div class="total-row">
                    <span>Tax (0%)</span>
                    <span>RM 0.00</span>
                </div>

                <div class="total-row grand-total">
                    <span>Total</span>
                    <span id="printTotal">-</span>
                </div>
            </div>
        </div>

        <div class="invoice-note">
            This invoice is system-generated by staff for a completed service booking.
        </div>
    </div>

</div>

<script>
    function safeValue(value) {
        if (value === null || value === undefined || value === "null" || value === "") {
            return "-";
        }
        return value;
    }

    function fillInvoicePrint(button) {
        document.getElementById("printInvoiceNo").innerText = safeValue(button.dataset.invoiceNo);
        document.getElementById("printInvoiceDate").innerText = safeValue(button.dataset.invoiceDate);
        document.getElementById("printBookingID").innerText = safeValue(button.dataset.bookingId);
        document.getElementById("printBookingDate").innerText = safeValue(button.dataset.bookingDate);
        document.getElementById("printCustomerName").innerText = safeValue(button.dataset.customerName);
        document.getElementById("printCustomerPhone").innerText = safeValue(button.dataset.customerPhone);
        document.getElementById("printVehicle").innerText = safeValue(button.dataset.vehicle);
        document.getElementById("printPackageName").innerText = safeValue(button.dataset.packageName);
        document.getElementById("printPackageDesc").innerText = safeValue(button.dataset.packageDesc);
        document.getElementById("printAmount").innerText = safeValue(button.dataset.amount);
        document.getElementById("printSubtotal").innerText = safeValue(button.dataset.amount);
        document.getElementById("printTotal").innerText = safeValue(button.dataset.amount);
    }

    function generateInvoice(button) {
        var actionBox = button.closest(".invoice-actions");
        var printButton = actionBox.querySelector(".btn-print");

        printButton.disabled = false;
        printButton.dataset.generated = "Y";
        printButton.classList.add("print-enabled");

        button.innerHTML = '<i class="fa-solid fa-check"></i> Generated';
        button.disabled = true;
    }

    function printInvoice(button) {
        if (button.dataset.generated !== "Y") {
            alert("Please generate the invoice first before printing.");
            return;
        }

        fillInvoicePrint(button);

        setTimeout(function () {
            window.print();
        }, 200);
    }
</script>

</body>
</html>