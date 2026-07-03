<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="vehicleBooking.bean.InvoiceBean" %>
<%@ page import="vehicleBooking.dao.CustomerInvoiceDAO" %>

<%!
    public String safe(String value) {
        if (value == null || value.trim().isEmpty() || "null".equalsIgnoreCase(value)) {
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

    public boolean isGenerated(InvoiceBean inv) {
        if (inv == null) {
            return false;
        }

        String invoiceNo = inv.getInvoiceNo();
        String invoiceDate = inv.getInvoiceDate();

        return invoiceNo != null
                && !invoiceNo.trim().isEmpty()
                && !"null".equalsIgnoreCase(invoiceNo)
                && !"-".equals(invoiceNo.trim())
                && invoiceDate != null
                && !invoiceDate.trim().isEmpty()
                && !"null".equalsIgnoreCase(invoiceDate)
                && !"-".equals(invoiceDate.trim());
    }
%>

<%
    String custID = (String) session.getAttribute("custID");
    String custName = (String) session.getAttribute("custName");
    String custPhone = (String) session.getAttribute("custPhoneNum");
    String role = (String) session.getAttribute("role");

    if (custID == null || role == null || !"customer".equalsIgnoreCase(role)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    if (custName == null || custName.trim().isEmpty()) {
        custName = "Customer";
    }

    if (custPhone == null || custPhone.trim().isEmpty()) {
        custPhone = "-";
    }

    List<InvoiceBean> invoiceList =
            CustomerInvoiceDAO.getCompletedInvoicesByCustomer(custID, custName, custPhone);

    DecimalFormat moneyFormat = new DecimalFormat("0.00");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>My Invoices | X-PERT DETAILING</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css?v=<%= System.currentTimeMillis() %>">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/xpertTheme.css?v=<%= System.currentTimeMillis() %>">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/custInvoice.css?v=<%= System.currentTimeMillis() %>">

    <style>
        .print-area {
            display: none;
        }

        .btn-waiting {
            background: #e2e8f0 !important;
            color: #94a3b8 !important;
            cursor: not-allowed !important;
        }

        .invoice-actions {
            display: flex;
            gap: 8px;
            align-items: center;
            flex-wrap: nowrap;
        }

        .btn-print {
            background: #0F4C5C !important;
            color: #ffffff !important;
        }

        .btn-print:hover {
            background: #0A3440 !important;
        }

        @media print {
            body * {
                visibility: hidden !important;
            }

            #printArea,
            #printArea * {
                visibility: visible !important;
            }

            #printArea {
                display: block !important;
                position: absolute !important;
                left: 0 !important;
                top: 0 !important;
                width: 100% !important;
                background: #ffffff !important;
                padding: 40px !important;
                box-sizing: border-box !important;
            }

            .xp-sidebar,
            .page-header,
            .invoice-table-card {
                display: none !important;
            }
        }
    </style>
</head>

<body>

<div class="xp-layout">

    <jsp:include page="/sidebar.jsp" />

    <main class="xp-main-content">

        <div class="page-header">
            <div>
                <h1>
                    <i class="fa-solid fa-file-lines" style="color:#074858; margin-right:10px;"></i>
                    My Invoices
                </h1>
                <p>Customer can print invoice only after staff generates the invoice.</p>
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
                        <th>Action</th>
                    </tr>
                </thead>

                <tbody>
                <%
                    if (invoiceList == null || invoiceList.size() == 0) {
                %>
                    <tr>
                        <td colspan="8" class="empty-row">
                            No invoice found. Invoice will appear after staff generates it.
                        </td>
                    </tr>
                <%
                    } else {
                        for (int i = 0; i < invoiceList.size(); i++) {
                            InvoiceBean inv = invoiceList.get(i);

                            String vehicleText = safe(inv.getVehiclePlateNum()) + " - " +
                                                 safe(inv.getVehicleBrand()) + " " +
                                                 safe(inv.getVehicleModel()) + " (" +
                                                 inv.getVehicleYear() + ")";

                            String amountText = "RM " + moneyFormat.format(inv.getAmount());

                            boolean generated = isGenerated(inv);
                %>
                    <tr>
                        <td>
                            <span class="invoice-no">
                                <i class="fa-regular fa-file-lines"></i>
                                <%= generated ? safe(inv.getInvoiceNo()) : "Not generated" %>
                            </span>
                        </td>

                        <td><%= generated ? safe(inv.getInvoiceDate()) : "-" %></td>

                        <td>
                            <strong><%= safe(inv.getCustomerName()) %></strong><br>
                            <small><%= safe(inv.getCustomerPhone()) %></small>
                        </td>

                        <td><%= safe(inv.getVehiclePlateNum()) %></td>

                        <td><%= safe(inv.getPackageName()) %></td>

                        <td>
                            <% if (generated) { %>
                                <span class="paid-badge">
                                    <i class="fa-solid fa-check"></i>
                                    GENERATED
                                </span>
                            <% } else { %>
                                <span class="paid-badge" style="background:#e2e8f0; color:#64748b;">
                                    <i class="fa-solid fa-clock"></i>
                                    WAITING STAFF
                                </span>
                            <% } %>
                        </td>

                        <td>
                            <span class="amount-cell"><%= amountText %></span>
                        </td>

                        <td>
                            <div class="invoice-actions">

                                <% if (generated) { %>
                                    <button type="button"
                                            class="btn-invoice btn-print"
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
                                <% } else { %>
                                    <button type="button"
                                            class="btn-invoice btn-waiting"
                                            disabled>
                                        <i class="fa-solid fa-lock"></i>
                                        Print
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

<!-- HIDDEN PRINT AREA -->
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
                <div class="field-label">Payment Status</div>
                <div class="field-value">PAID</div>
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

        <div class="payment-box">
            <i class="fa-solid fa-circle-check"></i>
            PAYMENT RECEIVED
        </div>

        <div class="invoice-note">
            Thank you for your business. This invoice is system-generated after staff confirmation.
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

    function printInvoice(button) {
        fillInvoicePrint(button);

        setTimeout(function () {
            window.print();
        }, 200);
    }
</script>

</body>
</html>