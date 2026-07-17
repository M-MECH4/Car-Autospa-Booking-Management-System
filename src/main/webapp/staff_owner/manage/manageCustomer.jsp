<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="vehicleBooking.bean.ManageCustomerBean" %>

<%!
    public String safe(String value) {
        if (value == null || value.trim().isEmpty()) {
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
    String role = (String) session.getAttribute("role");
    String staffRole = (String) session.getAttribute("staffRole");

    if (role == null || role.trim().isEmpty()) {
        role = staffRole;
    }

    if (role == null
            || (!"staff".equalsIgnoreCase(role)
            && !"owner".equalsIgnoreCase(role))) {

        response.sendRedirect(
                request.getContextPath() + "/login.jsp"
        );
        return;
    }

    boolean isOwner = "owner".equalsIgnoreCase(role);

    List<ManageCustomerBean> customerList =
            (List<ManageCustomerBean>)
            request.getAttribute("customerList");

    if (customerList == null) {
        response.sendRedirect(
                request.getContextPath()
                + "/ManageCustomerController"
        );
        return;
    }

    String keyword =
            (String) request.getAttribute("keyword");

    if (keyword == null) {
        keyword = "";
    }

    String msg = request.getParameter("msg");
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">

    <title>
        Manage Customer | X-PERT DETAILING
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
        href="${pageContext.request.contextPath}/css/sidebar.css?v=<%= System.currentTimeMillis() %>">

    <link
        rel="stylesheet"
        href="${pageContext.request.contextPath}/css/manageCustomer.css?v=<%= System.currentTimeMillis() %>">

    <link
        rel="stylesheet"
        href="${pageContext.request.contextPath}/css/xpertTheme.css?v=<%= System.currentTimeMillis() %>">

    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>

<body>

<div class="page-layout">

    <jsp:include page="/sidebar.jsp" />

    <main class="main-content">

        <!-- PAGE TITLE -->
        <div class="page-header">

            <div class="page-title-group">

                <h1>
                    <i class="fa-solid fa-users-gear"
                       style="color:#074858; margin-right:10px;"></i>

                    Manage Customer
                </h1>

                <% if (isOwner) { %>

                    <p>
                        Owner can view and delete customer accounts
                        that are not connected with booking data.
                    </p>

                <% } else { %>

                    <p>
                        Staff can view customer accounts only.
                    </p>

                <% } %>

            </div>

        </div>

        <!-- MESSAGES -->
        <% if ("deleted".equalsIgnoreCase(msg)) { %>

            <div class="alert alert-success">
                <i class="fa-solid fa-trash-can"></i>

                Customer account deleted successfully because
                the customer has no booking history.
            </div>

        <% } else if ("connectedData".equalsIgnoreCase(msg)) { %>

            <div class="alert alert-warning">
                <i class="fa-solid fa-lock"></i>

                This customer is connected with booking data,
                so the account cannot be deleted.
            </div>

        <% } else if ("deleteFailed".equalsIgnoreCase(msg)) { %>

            <div class="alert alert-danger">
                <i class="fa-solid fa-circle-xmark"></i>

                Failed to delete customer account.
            </div>

        <% } else if ("notAllowed".equalsIgnoreCase(msg)) { %>

            <div class="alert alert-danger">
                <i class="fa-solid fa-ban"></i>

                Staff is not allowed to delete customer accounts.
            </div>

        <% } %>

        <!-- SEARCH AND TOTAL -->
        <div class="action-bar">

            <form
                class="search-form"
                action="<%= request.getContextPath() %>/ManageCustomerController"
                method="get">

                <input
                    type="text"
                    name="keyword"
                    class="search-input"
                    placeholder="Search by ID, name, email, username, phone, race or religion."
                    value="<%= esc(keyword) %>">

                <button
                    type="submit"
                    class="btn-search">

                    <i class="fa-solid fa-magnifying-glass"></i>
                    Search
                </button>

            </form>

            <div class="total-badge">
                <i class="fa-solid fa-users"></i>

                Total:
                <%= customerList == null
                        ? 0
                        : customerList.size() %>
                customers
            </div>

        </div>

        <!-- CUSTOMER TABLE -->
        <div class="customer-table-card">

            <table>

                <thead>
                    <tr>
                        <th>Customer ID</th>
                        <th>Name</th>
                        <th>Email</th>
                        <th>Username</th>
                        <th>Phone</th>
                        <th>Race</th>
                        <th>Religion</th>
                        <th>Action</th>
                    </tr>
                </thead>

                <tbody>

                <%
                    if (customerList == null
                            || customerList.size() == 0) {
                %>

                    <tr>
                        <td colspan="8"
                            class="empty-row">

                            No customer found.
                        </td>
                    </tr>

                <%
                    } else {

                        for (ManageCustomerBean c
                                : customerList) {

                            boolean canDeleteCustomer =
                                    c.isDeleteAllowed();
                %>

                    <tr>

                        <td>
                            <span class="customer-id">
                                <%= safe(c.getCustID()) %>
                            </span>
                        </td>

                        <td>
                            <div class="customer-name">
                                <%= safe(c.getCustName()) %>
                            </div>
                        </td>

                        <td>
                            <%= safe(c.getCustEmail()) %>
                        </td>

                        <td>
                            <%= safe(c.getCustUsername()) %>
                        </td>

                        <td>
                            <%= safe(c.getCustPhoneNum()) %>
                        </td>

                        <td>
                            <%= safe(c.getCustRace()) %>
                        </td>

                        <td>
                            <%= safe(c.getCustReligion()) %>
                        </td>

                        <td>

                            <div class="action-btns">

                                <button
                                    type="button"
                                    class="view-btn"
                                    data-cust-id="<%= esc(c.getCustID()) %>"
                                    data-cust-name="<%= esc(c.getCustName()) %>"
                                    data-cust-email="<%= esc(c.getCustEmail()) %>"
                                    data-cust-username="<%= esc(c.getCustUsername()) %>"
                                    data-cust-phone="<%= esc(c.getCustPhoneNum()) %>"
                                    data-cust-race="<%= esc(c.getCustRace()) %>"
                                    data-cust-religion="<%= esc(c.getCustReligion()) %>"
                                    onclick="openViewCustomerModal(this)">

                                    View
                                </button>

                                <% if (isOwner
                                        && canDeleteCustomer) { %>

                                    <button
                                        type="button"
                                        class="delete-btn"
                                        data-cust-id="<%= esc(c.getCustID()) %>"
                                        data-cust-name="<%= esc(c.getCustName()) %>"
                                        onclick="openDeleteModal(this)">

                                        Delete
                                    </button>

                                <% } else if (isOwner) { %>

                                    <button
                                        type="button"
                                        class="delete-btn disabled-delete-btn"
                                        disabled
                                        title="This customer is connected with booking data and cannot be deleted.">

                                        Delete
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

<!-- DELETE CUSTOMER MODAL -->
<div class="modal"
     id="deleteModal">

    <div class="modal-box">

        <div class="modal-header">

            <h2>
                Delete Customer
            </h2>

            <button
                type="button"
                class="modal-close"
                onclick="closeDeleteModal()">

                &times;
            </button>

        </div>

        <form
            action="<%= request.getContextPath() %>/ManageCustomerController"
            method="post">

            <input
                type="hidden"
                name="action"
                value="delete">

            <input
                type="hidden"
                name="custID"
                id="deleteCustID">

            <div class="modal-body">

                <p>
                    Are you sure you want to delete

                    <strong
                        id="deleteCustName"
                        style="color:#dc2626;">
                    </strong>?
                </p>

                <p style="
                    font-size:13px;
                    font-weight:700;
                    color:#64748b;
                    margin-top:12px;
                ">
                    This action is only allowed when the customer
                    has no connected booking data. Booking and
                    report history will not be deleted.
                </p>

            </div>

            <div class="modal-footer">

                <button
                    type="button"
                    class="btn-cancel"
                    onclick="closeDeleteModal()">

                    Cancel
                </button>

                <button
                    type="submit"
                    class="btn-confirm-delete">

                    Delete
                </button>

            </div>

        </form>

    </div>

</div>

<!-- VIEW CUSTOMER MODAL -->
<div class="modal"
     id="viewCustomerModal">

    <div class="modal-box modal-box--view">

        <div class="modal-header">

            <h2>
                <i class="fa-solid fa-user"
                   style="color:#074858; margin-right:10px;"></i>

                Customer Details
            </h2>

            <button
                type="button"
                class="modal-close"
                onclick="closeViewCustomerModal()">

                &times;
            </button>

        </div>

        <div class="modal-body">

            <div class="view-grid">

                <div class="view-field">

                    <span class="view-label">
                        Customer ID
                    </span>

                    <span
                        class="view-value"
                        id="viewCustID">

                        -
                    </span>

                </div>

                <div class="view-field">

                    <span class="view-label">
                        Full Name
                    </span>

                    <span
                        class="view-value"
                        id="viewCustName">

                        -
                    </span>

                </div>

                <div class="view-field">

                    <span class="view-label">
                        Email
                    </span>

                    <span
                        class="view-value"
                        id="viewCustEmail">

                        -
                    </span>

                </div>

                <div class="view-field">

                    <span class="view-label">
                        Username
                    </span>

                    <span
                        class="view-value"
                        id="viewCustUsername">

                        -
                    </span>

                </div>

                <div class="view-field">

                    <span class="view-label">
                        Phone Number
                    </span>

                    <span
                        class="view-value"
                        id="viewCustPhone">

                        -
                    </span>

                </div>

                <div class="view-field">

                    <span class="view-label">
                        Race
                    </span>

                    <span
                        class="view-value"
                        id="viewCustRace">

                        -
                    </span>

                </div>

                <div class="view-field">

                    <span class="view-label">
                        Religion
                    </span>

                    <span
                        class="view-value"
                        id="viewCustReligion">

                        -
                    </span>

                </div>

            </div>

        </div>

        <div class="modal-footer">

            <button
                type="button"
                class="btn-cancel"
                onclick="closeViewCustomerModal()">

                Close
            </button>

        </div>

    </div>

</div>

<script>
    function openDeleteModal(button) {
        document.getElementById("deleteCustID").value =
            button.dataset.custId;

        document.getElementById("deleteCustName").innerText =
            button.dataset.custName;

        document.getElementById("deleteModal")
            .classList.add("active");
    }

    function closeDeleteModal() {
        document.getElementById("deleteModal")
            .classList.remove("active");
    }

    function openViewCustomerModal(button) {
        document.getElementById("viewCustID").innerText =
            button.dataset.custId || "-";

        document.getElementById("viewCustName").innerText =
            button.dataset.custName || "-";

        document.getElementById("viewCustEmail").innerText =
            button.dataset.custEmail || "-";

        document.getElementById("viewCustUsername").innerText =
            button.dataset.custUsername || "-";

        document.getElementById("viewCustPhone").innerText =
            button.dataset.custPhone || "-";

        document.getElementById("viewCustRace").innerText =
            button.dataset.custRace || "-";

        document.getElementById("viewCustReligion").innerText =
            button.dataset.custReligion || "-";

        document.getElementById("viewCustomerModal")
            .classList.add("active");
    }

    function closeViewCustomerModal() {
        document.getElementById("viewCustomerModal")
            .classList.remove("active");
    }
</script>

</body>

</html>