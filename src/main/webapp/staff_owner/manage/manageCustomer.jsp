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

    if (role == null || (!"staff".equalsIgnoreCase(role) && !"owner".equalsIgnoreCase(role))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    boolean isOwner = "owner".equalsIgnoreCase(role);

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

    List<ManageCustomerBean> customerList =
            (List<ManageCustomerBean>) request.getAttribute("customerList");

    if (customerList == null) {
        response.sendRedirect(request.getContextPath() + "/ManageCustomerController");
        return;
    }

    String keyword = (String) request.getAttribute("keyword");

    if (keyword == null) {
        keyword = "";
    }

    String msg = request.getParameter("msg");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Manage Customer | X-PERT DETAILING</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

     <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

    <!-- page css dulu -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/manageCustomer.css?v=<%= System.currentTimeMillis() %>">

    <!-- sidebar css LETAK LAST supaya dia override sidebar lama -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css?v=<%= System.currentTimeMillis() %>">
  
   
</head>

<body>

<div class="xp-layout">

    <jsp:include page="/sidebar.jsp" />

    <main class="xp-main-content">

        <div class="page-header">
            <h1>
                <i class="fa-solid fa-users-gear" style="color:#074858; margin-right:10px;"></i>
                Manage Customer
            </h1>
            <p>View customer accounts and delete customer accounts only.</p>
        </div>

        <% if ("deleted".equalsIgnoreCase(msg)) { %>
            <div class="alert alert-success">
                <i class="fa-solid fa-trash-can"></i> Customer account deleted successfully.
            </div>
        <% } else if ("deleteFailed".equalsIgnoreCase(msg)) { %>
            <div class="alert alert-danger">
                <i class="fa-solid fa-circle-xmark"></i> Failed to delete customer account.
            </div>
        <% } %>

        <div class="action-bar">
            <form class="search-form" action="<%= request.getContextPath() %>/ManageCustomerController" method="get">
                <input type="text"
                       name="keyword"
                       class="search-input"
                       placeholder="Search by ID, name, email, username or phone..."
                       value="<%= esc(keyword) %>">

                <button type="submit" class="btn-search">
                    <i class="fa-solid fa-magnifying-glass"></i>
                    Search
                </button>

               
            </form>

            <div class="total-badge">
                <i class="fa-solid fa-users"></i>
                Total: <%= customerList == null ? 0 : customerList.size() %> customers
            </div>
        </div>

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
                    if (customerList == null || customerList.size() == 0) {
                %>
                    <tr>
                        <td colspan="8" class="empty-row">
                            No customer found.
                        </td>
                    </tr>
                <%
                    } else {
                        for (ManageCustomerBean c : customerList) {
                %>
                    <tr>
                        <td>
                            <span class="customer-id"><%= safe(c.getCustID()) %></span>
                        </td>

                        <td>
                            <div class="customer-name"><%= safe(c.getCustName()) %></div>
                        </td>

                        <td><%= safe(c.getCustEmail()) %></td>

                        <td><%= safe(c.getCustUsername()) %></td>

                        <td><%= safe(c.getCustPhoneNum()) %></td>

                        <td><%= safe(c.getCustRace()) %></td>

                        <td><%= safe(c.getCustReligion()) %></td>

                        <td>
                            <button type="button"
                                    class="delete-btn"
                                    data-cust-id="<%= esc(c.getCustID()) %>"
                                    data-cust-name="<%= esc(c.getCustName()) %>"
                                    onclick="openDeleteModal(this)">
                                <i class="fa-solid fa-trash"></i>
                                Delete
                            </button>
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

<div class="modal" id="deleteModal">
    <div class="modal-box">

        <div class="modal-header">
            <h2>Delete Customer</h2>
            <button type="button" class="modal-close" onclick="closeDeleteModal()">&times;</button>
        </div>

        <form action="<%= request.getContextPath() %>/ManageCustomerController" method="post">
            <input type="hidden" name="action" value="delete">
            <input type="hidden" name="custID" id="deleteCustID">

            <div class="modal-body">
                <p>
                    Are you sure you want to delete
                    <strong id="deleteCustName" style="color:#dc2626;"></strong>?
                </p>

                <p style="font-size:13px; font-weight:700; color:#64748b; margin-top:12px;">
                    This will also delete the customer’s vehicles and bookings.
                </p>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn-cancel" onclick="closeDeleteModal()">Cancel</button>
                <button type="submit" class="btn-confirm-delete">Delete</button>
            </div>
        </form>

    </div>
</div>

<script>
    function openDeleteModal(button) {
        document.getElementById("deleteCustID").value = button.dataset.custId;
        document.getElementById("deleteCustName").innerText = button.dataset.custName;

        document.getElementById("deleteModal").classList.add("active");
    }

    function closeDeleteModal() {
        document.getElementById("deleteModal").classList.remove("active");
    }
</script>

</body>
</html>