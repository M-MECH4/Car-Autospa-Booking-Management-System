<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="vehicleBooking.bean.StaffBean" %>

<%!
    public String safe(String value) {
        if (value == null || value.trim().isEmpty()) return "-";
        return value;
    }

    public String esc(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
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

    if (!"owner".equalsIgnoreCase(role)) {
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
    String newStaffID = request.getParameter("newStaffID");

    String keyword = (String) request.getAttribute("keyword");
    if (keyword == null) keyword = request.getParameter("keyword");
    if (keyword == null) keyword = "";
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Manage Staff | X-PERT DETAILING</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

<link rel="stylesheet" href="${pageContext.request.contextPath}/css/manageStaff.css?v=<%= System.currentTimeMillis() %>">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css?v=<%= System.currentTimeMillis() %>">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/xpertTheme.css?v=<%= System.currentTimeMillis() %>">

<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<style>
.password-requirements {
    grid-column: 1 / -1;
    background: #f9fbfe;
    padding: 16px 18px;
    border-radius: 14px;
    border: 1px solid #edf2f9;
    margin-top: 4px;
}

.password-requirements p {
    font-weight: 900;
    font-size: 13px;
    color: #2d4f5e;
    margin-bottom: 10px;
}

.requirements-list {
    display: flex;
    flex-wrap: wrap;
    gap: 10px 20px;
    list-style: none;
    padding-left: 0;
    margin: 0;
}

.requirements-list li {
    font-size: 12px;
    display: flex;
    align-items: center;
    gap: 8px;
    color: #5b6f8c;
    font-weight: 700;
}

.requirements-list li.valid {
    color: #2b7e3a;
}

.requirements-list .fa-circle-check {
    color: #2b7e3a;
}

.requirements-list .fa-circle-xmark {
    color: #c2412c;
}

.staff-password-wrapper {
    position: relative;
    display: flex;
    align-items: center;
}

.staff-password-wrapper .form-control {
    padding-right: 48px;
}

.staff-password-toggle {
    position: absolute;
    right: 10px;
    width: 34px;
    height: 34px;
    border: none;
    border-radius: 50%;
    background: transparent;
    color: #64748b;
    cursor: pointer;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    font-size: 15px;
}

.staff-password-toggle:hover {
    background: #f1f5f9;
    color: #074858;
}

.disabled-delete-btn {
    opacity: 0.45;
    cursor: not-allowed !important;
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
            <i class="fa-solid fa-users-gear" style="color:#074858; margin-right:10px;"></i>
            Manage Staff
        </h1>
        <p>Create, view, update and delete staff accounts for X-PERT Detailing. Staff that has handle bookings, can't be deleted.</p>
    </div>

    <button type="button" class="btn-open-form" onclick="toggleForm()">
      + Add Staff
    </button>
</div>

<% if ("success_create".equalsIgnoreCase(msg)) { %>
    <div class="alert alert-success">
        <i class="fa-solid fa-circle-check"></i>
        Staff account registered successfully.
        <% if (newStaffID != null && !newStaffID.trim().isEmpty()) { %>
            Generated Staff ID: <strong><%= esc(newStaffID) %></strong>
        <% } %>
    </div>
<% } else if ("success_delete".equalsIgnoreCase(msg)) { %>
    <div class="alert alert-success">
        <i class="fa-solid fa-trash-can"></i>
        Staff account deleted successfully.
    </div>
<% } else if ("connectedData".equalsIgnoreCase(msg)) { %>
    <div class="alert alert-warning">
        <i class="fa-solid fa-lock"></i>
        This staff account is connected with booking data, so it cannot be deleted.
    </div>
<% } else if ("failed_create".equalsIgnoreCase(msg)) { %>
    <div class="alert alert-danger">
        <i class="fa-solid fa-circle-xmark"></i>
        Failed to register staff. Please check duplicate username, email, or database constraint.
    </div>
<% } else if ("failed_delete".equalsIgnoreCase(msg)) { %>
    <div class="alert alert-danger">
        <i class="fa-solid fa-circle-xmark"></i>
        Failed to delete staff account.
    </div>
<% } else if ("empty".equalsIgnoreCase(msg)) { %>
    <div class="alert alert-warning">
        <i class="fa-solid fa-triangle-exclamation"></i>
        Please fill in all fields.
    </div>
<% } else if ("invalidPhone".equalsIgnoreCase(msg)) { %>
    <div class="alert alert-warning">
        <i class="fa-solid fa-triangle-exclamation"></i>
        Phone number must contain numbers only.
    </div>
<% } else if ("weakPassword".equalsIgnoreCase(msg)) { %>
    <div class="alert alert-warning">
        <i class="fa-solid fa-triangle-exclamation"></i>
        Password must contain at least 8 characters, one uppercase letter, one lowercase letter, one number, and one special character (!@#$%^&amp;*).
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
<% } else if ("success_update".equalsIgnoreCase(msg)) { %>
    <div class="alert alert-success">
        <i class="fa-solid fa-pen-to-square"></i>
        Staff information updated successfully.
    </div>
<% } else if ("failed_update".equalsIgnoreCase(msg)) { %>
    <div class="alert alert-danger">
        <i class="fa-solid fa-circle-xmark"></i>
        Failed to update staff information.
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

    <form action="${pageContext.request.contextPath}/ManageStaffController"
          method="post"
          onsubmit="return validateStaffPasswordBeforeSubmit();">

        <input type="hidden" name="action" value="create">

        <div class="form-grid">

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
                <input type="text" name="staffPhoneNum" class="form-control" inputmode="numeric" pattern="[0-9]+" maxlength="20" title="Phone number must contain numbers only." oninput="this.value = this.value.replace(/[^0-9]/g, '')" placeholder="0123456789" required>
            </div>

            <div class="form-group">
                <label>Password</label>

                <div class="staff-password-wrapper">
                    <input type="password"
                           name="staffPassword"
                           id="staffPassword"
                           class="form-control"
                           placeholder="Password"
                           pattern="(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!@#$%^&*]).{8,}"
                           title="Password must contain at least 8 characters, one uppercase letter, one lowercase letter, one number, and one special character (!@#$%^&*)."
                           required>

                    <button type="button"
                            class="staff-password-toggle"
                            onclick="toggleStaffPasswordVisibility()">
                        <i class="fa-regular fa-eye" id="staffPasswordEyeIcon"></i>
                    </button>
                </div>
            </div>

            <div class="password-requirements staff-password-rules">
                <p>
                    <i class="fa-solid fa-shield-halved"></i>
                    Password must contain:
                </p>

                <ul class="requirements-list">
                    <li id="staffReqLength">
                        <i class="fa-regular fa-circle-xmark"></i>
                        At least 8 characters
                    </li>
                    <li id="staffReqUpper">
                        <i class="fa-regular fa-circle-xmark"></i>
                        One uppercase letter
                    </li>
                    <li id="staffReqLower">
                        <i class="fa-regular fa-circle-xmark"></i>
                        One lowercase letter
                    </li>
                    <li id="staffReqNumber">
                        <i class="fa-regular fa-circle-xmark"></i>
                        One number
                    </li>
                    <li id="staffReqSpecial">
                        <i class="fa-regular fa-circle-xmark"></i>
                        One special character (!@#$%^&amp;*)
                    </li>
                </ul>
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

<div class="action-bar">
    <form class="search-form" action="${pageContext.request.contextPath}/ManageStaffController" method="get">
        <input type="text"
               name="keyword"
               class="search-input"
               placeholder="Search by ID, name, email, username, phone or role..."
               value="<%= esc(keyword) %>">

        <button type="submit" class="btn-search">
            <i class="fa-solid fa-magnifying-glass"></i>
            Search
        </button>
    </form>

    <div class="total-badge">
        <i class="fa-solid fa-users"></i>
        Total: <%= staffList == null ? 0 : staffList.size() %> staff
    </div>
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
    <th>Created by</th>
    <th>Action</th>
</tr>
</thead>

<tbody>
<%
    if (staffList == null || staffList.size() == 0) {
%>
<tr>
    <td colspan="8" class="empty-row">No staff records available.</td>
</tr>
<%
    } else {
        int rowNo = 0;

        for (StaffBean s : staffList) {
            rowNo++;

            String deleteFormId = "deleteForm_" + rowNo;
            boolean isOwnerStaff = "owner".equalsIgnoreCase(s.getStaffRole());

            /*
             * FIX:
             * This variable was missing before.
             * Delete button is only enabled when staff is NOT connected with booking data.
             */
            boolean canDeleteStaff = s.isDeleteAllowed();
%>

<tr>
    <td><span class="staff-id"><%= safe(s.getStaffID()) %></span></td>

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
        <div class="action-btns">

            <button type="button"
                    class="view-btn"
                    data-staff-id="<%= esc(s.getStaffID()) %>"
                    data-staff-name="<%= esc(s.getStaffName()) %>"
                    data-staff-email="<%= esc(s.getStaffEmail()) %>"
                    data-staff-username="<%= esc(s.getStaffUsername()) %>"
                    data-staff-phone="<%= esc(s.getStaffPhoneNum()) %>"
                    data-staff-role="<%= esc(s.getStaffRole()) %>"
                    data-owner-id="<%= esc(s.getOwnerID()) %>"
                    onclick="openViewStaffModal(this)">
                View
            </button>

            <% if (!isOwnerStaff) { %>

                <button type="button"
                        class="update-btn"
                        data-staff-id="<%= esc(s.getStaffID()) %>"
                        data-staff-name="<%= esc(s.getStaffName()) %>"
                        data-staff-email="<%= esc(s.getStaffEmail()) %>"
                        data-staff-username="<%= esc(s.getStaffUsername()) %>"
                        data-staff-phone="<%= esc(s.getStaffPhoneNum()) %>"
                        onclick="openUpdateStaffModal(this)">
                    Edit
                </button>

                <% if (canDeleteStaff) { %>
                    <button type="button"
                            class="delete-btn"
                            data-form-id="<%= deleteFormId %>"
                            data-staff-name="<%= esc(s.getStaffName()) %>"
                            onclick="submitDeleteStaff(this)">
                        Delete
                    </button>
                <% } else { %>
                    <button type="button"
                            class="delete-btn disabled-delete-btn"
                            disabled
                            title="This staff is connected with booking data and cannot be deleted.">
                        Delete
                    </button>
                <% } %>

                <form id="<%= deleteFormId %>"
                      action="${pageContext.request.contextPath}/ManageStaffController"
                      method="post"
                      style="display:none;">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="staffID" value="<%= esc(s.getStaffID()) %>">
                </form>

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

<div class="modal" id="viewStaffModal">
    <div class="modal-box modal-box--view">

        <div class="modal-header">
            <h2>
                <i class="fa-solid fa-user-tie" style="color:#074858; margin-right:10px;"></i>
                Staff Details
            </h2>

            <button type="button" class="modal-close" onclick="closeViewStaffModal()">&times;</button>
        </div>

        <div class="modal-body">
            <div class="view-grid">

                <div class="view-field">
                    <span class="view-label">Staff ID</span>
                    <span class="view-value" id="viewStaffID">-</span>
                </div>

                <div class="view-field">
                    <span class="view-label">Full Name</span>
                    <span class="view-value" id="viewStaffName">-</span>
                </div>

                <div class="view-field">
                    <span class="view-label">Email</span>
                    <span class="view-value" id="viewStaffEmail">-</span>
                </div>

                <div class="view-field">
                    <span class="view-label">Username</span>
                    <span class="view-value" id="viewStaffUsername">-</span>
                </div>

                <div class="view-field">
                    <span class="view-label">Phone Number</span>
                    <span class="view-value" id="viewStaffPhone">-</span>
                </div>

                <div class="view-field">
                    <span class="view-label">Role</span>
                    <span class="view-value" id="viewStaffRole">-</span>
                </div>

                <div class="view-field">
                    <span class="view-label">Created by</span>
                    <span class="view-value" id="viewOwnerID">-</span>
                </div>


            </div>
        </div>

        <div class="modal-footer">
            <button type="button" class="btn-cancel" onclick="closeViewStaffModal()">Close</button>
        </div>

    </div>
</div>

<div class="modal" id="updateStaffModal">
    <div class="modal-box modal-box--view">

        <div class="modal-header">
            <h2>
                <i class="fa-solid fa-pen-to-square" style="color:#074858; margin-right:10px;"></i>
                Update Staff
            </h2>

            <button type="button" class="modal-close" onclick="closeUpdateStaffModal()">&times;</button>
        </div>

        <form action="${pageContext.request.contextPath}/ManageStaffController" method="post">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="staffID" id="updateStaffID">

            <div class="modal-body">
                <div class="update-form-grid">

                    <div class="form-group">
                        <label>Full Name</label>
                        <input type="text" name="staffName" id="updateStaffName" class="form-control" required>
                    </div>

                    <div class="form-group">
                        <label>Email</label>
                        <input type="email" name="staffEmail" id="updateStaffEmail" class="form-control" required>
                    </div>

                    <div class="form-group">
                        <label>Username</label>
                        <input type="text" name="staffUsername" id="updateStaffUsername" class="form-control" required>
                    </div>

                    <div class="form-group">
                        <label>Phone Number</label>
                        <input type="text" name="staffPhoneNum" id="updateStaffPhone" class="form-control" inputmode="numeric" pattern="[0-9]+" maxlength="20" title="Phone number must contain numbers only." oninput="this.value = this.value.replace(/[^0-9]/g, '')" required>
                    </div>

                </div>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn-cancel" onclick="closeUpdateStaffModal()">Cancel</button>

                <button type="submit" class="btn-save">
                    <i class="fa-solid fa-floppy-disk"></i>
                    Save Changes
                </button>
            </div>
        </form>

    </div>
</div>

<script>
function toggleForm() {
    document.getElementById("staffFormCard").classList.toggle("active");
}

function submitDeleteStaff(button) {
    const staffName = button.dataset.staffName || "this staff";
    const formId = button.dataset.formId;

    Swal.fire({
        title: "Delete Staff?",
        html:
            "<b>" + staffName + "</b><br><br>" +
            "This staff account will be permanently deleted only if it is not connected with booking data.",
        icon: "warning",
        showCancelButton: true,
        confirmButtonColor: "#d33",
        cancelButtonColor: "#6c757d",
        confirmButtonText: "Delete",
        cancelButtonText: "Cancel"
    }).then((result) => {
        if (result.isConfirmed) {
            document.getElementById(formId).submit();
        }
    });
}

function openViewStaffModal(button) {
    document.getElementById("viewStaffID").innerText = button.dataset.staffId || "-";
    document.getElementById("viewStaffName").innerText = button.dataset.staffName || "-";
    document.getElementById("viewStaffEmail").innerText = button.dataset.staffEmail || "-";
    document.getElementById("viewStaffUsername").innerText = button.dataset.staffUsername || "-";
    document.getElementById("viewStaffPhone").innerText = button.dataset.staffPhone || "-";
    document.getElementById("viewStaffRole").innerText = button.dataset.staffRole || "-";
    document.getElementById("viewOwnerID").innerText = button.dataset.ownerId || "-";


    document.getElementById("viewStaffModal").classList.add("active");
}

function closeViewStaffModal() {
    document.getElementById("viewStaffModal").classList.remove("active");
}

function openUpdateStaffModal(button) {
    document.getElementById("updateStaffID").value = button.dataset.staffId || "";
    document.getElementById("updateStaffName").value = button.dataset.staffName || "";
    document.getElementById("updateStaffEmail").value = button.dataset.staffEmail || "";
    document.getElementById("updateStaffUsername").value = button.dataset.staffUsername || "";
    document.getElementById("updateStaffPhone").value = button.dataset.staffPhone || "";

    document.getElementById("updateStaffModal").classList.add("active");
}

function closeUpdateStaffModal() {
    document.getElementById("updateStaffModal").classList.remove("active");
}

const staffPasswordInput = document.getElementById("staffPassword");
const staffReqLength = document.getElementById("staffReqLength");
const staffReqUpper = document.getElementById("staffReqUpper");
const staffReqLower = document.getElementById("staffReqLower");
const staffReqNumber = document.getElementById("staffReqNumber");
const staffReqSpecial = document.getElementById("staffReqSpecial");

function isStrongStaffPassword(password) {
    return /^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!@#$%^&*]).{8,}$/.test(password);
}

function updateStaffReq(element, valid, text) {
    if (!element) return;

    element.innerHTML = valid
        ? '<i class="fa-regular fa-circle-check"></i> ' + text
        : '<i class="fa-regular fa-circle-xmark"></i> ' + text;

    if (valid) {
        element.classList.add("valid");
    } else {
        element.classList.remove("valid");
    }
}

function refreshStaffPasswordRules() {
    if (!staffPasswordInput) return;

    const pwd = staffPasswordInput.value;

    updateStaffReq(staffReqLength, pwd.length >= 8, "At least 8 characters");
    updateStaffReq(staffReqUpper, /[A-Z]/.test(pwd), "One uppercase letter");
    updateStaffReq(staffReqLower, /[a-z]/.test(pwd), "One lowercase letter");
    updateStaffReq(staffReqNumber, /[0-9]/.test(pwd), "One number");
    updateStaffReq(staffReqSpecial, /[!@#$%^&*]/.test(pwd), "One special character (!@#$%^&*)");
}

function validateStaffPasswordBeforeSubmit() {
    if (!staffPasswordInput) return true;

    const pwd = staffPasswordInput.value;

    refreshStaffPasswordRules();

    if (!isStrongStaffPassword(pwd)) {
        Swal.fire({
            icon: "warning",
            title: "Weak Password",
            text: "Password must contain at least 8 characters, one uppercase letter, one lowercase letter, one number, and one special character (!@#$%^&*).",
            confirmButtonColor: "#074858"
        });

        staffPasswordInput.focus();
        return false;
    }

    return true;
}

if (staffPasswordInput) {
    staffPasswordInput.addEventListener("input", refreshStaffPasswordRules);
    refreshStaffPasswordRules();
}

function toggleStaffPasswordVisibility() {
    const input = document.getElementById("staffPassword");
    const icon = document.getElementById("staffPasswordEyeIcon");

    if (!input || !icon) return;

    if (input.type === "password") {
        input.type = "text";

        // swapped: visible password shows closed eye
        icon.classList.remove("fa-eye-slash");
        icon.classList.add("fa-eye");
    } else {
        input.type = "password";

        // swapped: hidden password shows open eye
        icon.classList.remove("fa-eye");
        icon.classList.add("fa-eye-slash");
    }
}
</script>

</body>
</html>