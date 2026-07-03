<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="vehicleBooking.bean.StaffBean" %>

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

    boolean isOwner = "owner".equalsIgnoreCase(role);

    if (!isOwner) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String ownerName = (String) session.getAttribute("name");

    if (ownerName == null || ownerName.trim().isEmpty()) {
        ownerName = (String) session.getAttribute("staffUsername");
    }

    if (ownerName == null || ownerName.trim().isEmpty()) {
        ownerName = "Owner";
    }

    ArrayList<StaffBean> staffList =
            (ArrayList<StaffBean>) request.getAttribute("staffList");

    if (staffList == null) {
        response.sendRedirect(request.getContextPath() + "/ManageStaffController");
        return;
    }

    String msg = request.getParameter("msg");
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>Manage Staff | X-PERT DETAILING</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

     <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

    <!-- page css dulu -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/manageStaff.css?v=<%= System.currentTimeMillis() %>">

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
                    <i class="fa-solid fa-users-gear" style="color:#074858; margin-right:10px;"></i>
                    Manage Staff
                </h1>
                <p>Create, view and remove staff accounts for X-PERT Detailing.</p>
            </div>

            <button type="button" class="btn-open-form" onclick="toggleForm()">
                <i class="fa-solid fa-user-plus"></i>
                Add Staff
            </button>
        </div>

        <% if ("success_create".equalsIgnoreCase(msg)) { %>
            <div class="alert alert-success">
                <i class="fa-solid fa-circle-check"></i>
                Staff account registered successfully.
            </div>
        <% } else if ("success_delete".equalsIgnoreCase(msg)) { %>
            <div class="alert alert-success">
                <i class="fa-solid fa-trash-can"></i>
                Staff account deleted successfully.
            </div>
        <% } else if ("failed_create".equalsIgnoreCase(msg)) { %>
            <div class="alert alert-danger">
                <i class="fa-solid fa-circle-xmark"></i>
                Failed to register staff. Please check duplicate Staff ID, username, email, or database constraint.
            </div>
        <% } else if ("failed_delete".equalsIgnoreCase(msg)) { %>
            <div class="alert alert-danger">
                <i class="fa-solid fa-circle-xmark"></i>
                Failed to delete staff account. Staff may have related booking records.
            </div>
        <% } else if ("empty".equalsIgnoreCase(msg)) { %>
            <div class="alert alert-warning">
                <i class="fa-solid fa-triangle-exclamation"></i>
                Please fill in all fields.
            </div>
        <% } else if ("noOwner".equalsIgnoreCase(msg)) { %>
            <div class="alert alert-danger">
                <i class="fa-solid fa-circle-xmark"></i>
                Owner session not found. Please login again.
            </div>
        <% } else if ("invalid".equalsIgnoreCase(msg)) { %>
            <div class="alert alert-warning">
                <i class="fa-solid fa-triangle-exclamation"></i>
                Invalid staff ID.
            </div>
        <% } else if ("error".equalsIgnoreCase(msg)) { %>
            <div class="alert alert-danger">
                <i class="fa-solid fa-circle-xmark"></i>
                Something went wrong. Please check Eclipse console.
            </div>
        <% } %>

        <div class="form-card" id="staffFormCard">
            <h2>
                <i class="fa-solid fa-user-plus" style="color:#074858; margin-right:8px;"></i>
                Register New Staff
            </h2>

            <form action="${pageContext.request.contextPath}/ManageStaffController" method="post">
                <input type="hidden" name="action" value="create">

                <div class="form-grid">

                    <div class="form-group">
                        <label>Staff ID</label>
                        <input type="text" name="staffID" class="form-control" placeholder="Example: S011" required>
                    </div>

                    <div class="form-group">
                        <label>Full Name</label>
                        <input type="text" name="staffName" class="form-control" placeholder="Enter full name" required>
                    </div>

                    <div class="form-group">
                        <label>Username</label>
                        <input type="text" name="staffUsername" class="form-control" placeholder="Enter username" required>
                    </div>

                    <div class="form-group">
                        <label>Role</label>
                        <input type="text" value="Staff" class="form-control" readonly>
                    </div>

                    <div class="form-group">
                        <label>Email</label>
                        <input type="email" name="staffEmail" class="form-control" placeholder="staff@gmail.com" required>
                    </div>

                    <div class="form-group">
                        <label>Phone Number</label>
                        <input type="text" name="staffPhoneNum" class="form-control" placeholder="0123456789" required>
                    </div>

                    <div class="form-group">
                        <label>Password</label>
                        <input type="password" name="staffPassword" class="form-control" placeholder="Password" required>
                    </div>

                </div>

                <div class="form-actions">
                    <button type="button" class="btn-cancel" onclick="toggleForm()">Cancel</button>

                    <button type="submit" class="btn-save">
                        <i class="fa-solid fa-check"></i>
                        Register Staff
                    </button>
                </div>
            </form>
        </div>

        <div class="staff-table-card">

            <table>
                <thead>
                    <tr>
                        <th>Staff ID</th>
                        <th>Full Name</th>
                        <th>Username</th>
                        <th>Role</th>
                        <th>Email</th>
                        <th>Phone</th>
                        <th>Owner ID</th>
                        <th>Status</th>
                        <th>Action</th>
                    </tr>
                </thead>

                <tbody>
                <%
                    if (staffList == null || staffList.size() == 0) {
                %>
                    <tr>
                        <td colspan="9" class="empty-row">
                            No staff records available.
                        </td>
                    </tr>
                <%
                    } else {
                        for (StaffBean s : staffList) {
                %>
                    <tr>
                        <td>
                            <span class="staff-id"><%= safe(s.getStaffID()) %></span>
                        </td>

                        <td>
                            <div class="staff-name"><%= safe(s.getStaffName()) %></div>
                        </td>

                        <td><%= safe(s.getStaffUsername()) %></td>

                        <td>
                            <span class="role-badge"><%= safe(s.getStaffRole()) %></span>
                        </td>

                        <td><%= safe(s.getStaffEmail()) %></td>

                        <td><%= safe(s.getStaffPhoneNum()) %></td>

                        <td><%= safe(s.getOwnerID()) %></td>

                        <td>
                            <span class="status-badge">
                                <i class="fa-solid fa-circle"></i>
                                Active
                            </span>
                        </td>

                        <td>
                            <% if (!"owner".equalsIgnoreCase(s.getStaffRole())) { %>
                                <form action="${pageContext.request.contextPath}/ManageStaffController"
                                      method="post"
                                      onsubmit="return confirm('Are you sure you want to delete staff <%= esc(s.getStaffName()) %>?');">

                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="staffID" value="<%= esc(s.getStaffID()) %>">

                                    <button type="submit" class="delete-btn">
                                        <i class="fa-solid fa-trash-can"></i>
                                        Delete
                                    </button>
                                </form>
                            <% } else { %>
                                -
                            <% } %>
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

<script>
    function toggleForm() {
        document.getElementById("staffFormCard").classList.toggle("active");
    }
</script>

</body>
</html>