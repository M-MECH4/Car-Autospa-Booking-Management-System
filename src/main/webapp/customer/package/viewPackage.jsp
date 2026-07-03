<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@page import="java.util.ArrayList"%>
<%@page import="vehicleBooking.bean.*"%>

<%
response.setHeader("Cache-Control","no-cache,no-store,must-revalidate");
response.setHeader("Pragma","no-cache");
response.setDateHeader("Expires",0);

if(session.getAttribute("role") == null){
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
}

String role = (String) session.getAttribute("role");

boolean isStaff =
    "staff".equalsIgnoreCase(role) ||
    "owner".equalsIgnoreCase(role);

boolean isCustomer =
    "customer".equalsIgnoreCase(role);

String displayName = (String) session.getAttribute("name");
if(displayName == null){
    displayName = (String) session.getAttribute("custName");
}
if(displayName == null){
    displayName = "User";
}

@SuppressWarnings("unchecked")
ArrayList<PackageBean> packageList =
    (ArrayList<PackageBean>) request.getAttribute("packageList");
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Package</title>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

    <!-- page css dulu -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/viewPackage.css?v=<%= System.currentTimeMillis() %>">

    <!-- sidebar css LETAK LAST supaya dia override sidebar lama -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css?v=<%= System.currentTimeMillis() %>">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/xpertTheme.css?v=<%= System.currentTimeMillis() %>">

</head>

<body>

<div class="xp-layout">

    <jsp:include page="/sidebar.jsp" />

    <!-- MAIN CONTENT -->
    <main class="xp-main-content">

        <h2>Explore Our Packages</h2>

        <% if(isStaff){ %>

        <div class="form-box">

            <h3>Create Package</h3>

            <form action="<%=request.getContextPath()%>/PackageController" method="post">

                <label>Package Type</label>
                <select name="type" required>
                    <option value="routine">Routine</option>
                    <option value="festive">Festive</option>
                </select>

                <label>Package ID</label>
                <input type="text" name="packageID" required>

                <label>Package Name</label>
                <input type="text" name="packageName" required>

                <label>Package Price</label>
                <input type="number" step="0.01" name="packagePrice" required>

                <label>Package Description</label>
                <textarea name="packageDesc" required></textarea>

                <label>Service Name</label>
                <input type="text" name="serviceName" required>

                <h4>Routine Details</h4>

                <label>Entry Method</label>
                <input type="text" name="entryMethod">

                <h4>Festive Details</h4>

                <label>Festival Name</label>
                <input type="text" name="festivalName">

                <label>Start Date</label>
                <input type="date" name="startDate">

                <label>End Date</label>
                <input type="date" name="endDate">

                <label>Discount Rate</label>
                <input type="number" step="0.01" name="discountRate">

                <button class="btn-main" type="submit">Create Package</button>

            </form>

        </div>

        <% } %>

        <div class="container">

        <%
        if(packageList == null || packageList.isEmpty()){
        %>

            <h3>No packages available.</h3>

        <%
        } else {
            int modalIndex = 0;

            for(PackageBean p : packageList){
                String modalId = "packageModal" + modalIndex;
                modalIndex++;
        %>

            <div class="card">

                <h2><%=p.getPackageName()%></h2>

                <div class="price">
                    RM <%=String.format("%.2f", p.getPackagePrice())%>
                </div>

                <p>
                    Service:
                    <b><%=p.getServiceName()%></b>
                </p>

                <%
                if(p instanceof FestivalBean){
                    FestivalBean f = (FestivalBean)p;
                %>

                <p class="badge">
                    <%=f.getFestivalName()%> -
                    <%=String.format("%.0f", f.getDiscountRate())%>% OFF
                </p>

                <p>
                    <small>
                        <%=f.getStartDate()%> until <%=f.getEndDate()%>
                    </small>
                </p>

                <%
                }
                %>

                <ul>
                <%
                if(p.getPackageDesc() != null){
                    String desc[] = p.getPackageDesc().split(",");

                    for(String s : desc){
                %>

                    <li><%=s.trim()%></li>

                <%
                    }
                }
                %>
                </ul>

                <%
                if(p instanceof RoutineBean){
                    RoutineBean r = (RoutineBean)p;

                    if(r.getEntryMethod() != null){
                %>

                <p>
                    Entry Method:
                    <b><%=r.getEntryMethod()%></b>
                </p>

                <%
                    }
                }
                %>

                <!-- CUSTOMER AND STAFF CAN VIEW PACKAGE DETAILS -->
                <button type="button" class="btn-view" onclick="openPackageModal('<%=modalId%>')">
                    View Details
                </button>

                <% if(isStaff){ %>

                <br><br>

                <a href="<%=request.getContextPath()%>/editPackage.jsp?packageID=<%=p.getPackageID()%>">
                    <button class="btn-edit">Edit</button>
                </a>

                <a href="<%=request.getContextPath()%>/PackageController?action=delete&packageID=<%=p.getPackageID()%>"
                   onclick="return confirm('Delete this package?');">
                    <button class="btn-delete">Delete</button>
                </a>

                <% } %>

            </div>

           <!-- PACKAGE DETAIL MODAL -->
<div class="package-modal" id="<%=modalId%>">
    <div class="package-modal-box">

        <%
            String packageType = "General";
            String entryMethod = "-";

            String festivalName = "-";
            String startDate = "-";
            String endDate = "-";
            double discountRate = 0.0;

            double originalPrice = p.getPackagePrice();
            double finalPrice = originalPrice;

            if (p instanceof RoutineBean) {
                packageType = "Routine Package";
                RoutineBean r = (RoutineBean) p;

                if (r.getEntryMethod() != null && !r.getEntryMethod().trim().isEmpty()) {
                    entryMethod = r.getEntryMethod();
                }
            }

            if (p instanceof FestivalBean) {
                packageType = "Festive Package";
                FestivalBean f = (FestivalBean) p;

                festivalName = f.getFestivalName();
                startDate = String.valueOf(f.getStartDate());
                endDate = String.valueOf(f.getEndDate());
                discountRate = f.getDiscountRate();

                finalPrice = originalPrice - (originalPrice * discountRate / 100);
            }
        %>

        <div class="package-modal-header">
            <div>
                <h2><%=p.getPackageName()%></h2>
                <p style="color:#64748b; font-weight:700; margin-top:6px;">
                    <%= packageType %>
                </p>
            </div>

            <button type="button" class="modal-close" onclick="closePackageModal('<%=modalId%>')">
                &times;
            </button>
        </div>

        <div class="package-summary-box">
            <div>
                <label>Original Price</label>
                <h3>RM <%=String.format("%.2f", originalPrice)%></h3>
            </div>

            <% if (p instanceof FestivalBean) { %>
                <div>
                    <label>Discount</label>
                    <h3><%=String.format("%.0f", discountRate)%>% OFF</h3>
                </div>

                <div>
                    <label>Final Price</label>
                    <h3 class="final-price">RM <%=String.format("%.2f", finalPrice)%></h3>
                </div>
            <% } %>
        </div>

        <div class="package-detail-grid">

            <div class="package-detail-row">
                <label>Package ID</label>
                <p><%=p.getPackageID()%></p>
            </div>

            <div class="package-detail-row">
                <label>Package Type</label>
                <p><%= packageType %></p>
            </div>

            <div class="package-detail-row">
                <label>Package Name</label>
                <p><%=p.getPackageName()%></p>
            </div>

            <div class="package-detail-row">
                <label>Service Name</label>
                <p><%=p.getServiceName()%></p>
            </div>

        </div>

        <div class="package-detail-row">
            <label>What is included?</label>

            <%
            if(p.getPackageDesc() != null && !p.getPackageDesc().trim().isEmpty()){
                String modalDesc[] = p.getPackageDesc().split(",");
            %>

            <ul class="modal-desc-list">
                <%
                for(String d : modalDesc){
                %>
                    <li><%=d.trim()%></li>
                <%
                }
                %>
            </ul>

            <%
            } else {
            %>
                <p>No description available.</p>
            <%
            }
            %>
        </div>

        <% if (p instanceof RoutineBean) { %>

            <div class="package-extra-box routine-box">
                <h4><i class="fa-solid fa-repeat"></i> Routine Package Details</h4>

                <div class="package-detail-row">
                    <label>Entry Method</label>
                    <p><%= entryMethod %></p>
                </div>

                <div class="package-detail-row">
                    <label>Suitable For</label>
                    <p>Normal day service booking and regular car care maintenance.</p>
                </div>
            </div>

        <% } %>

        <% if (p instanceof FestivalBean) { %>

            <div class="package-extra-box festive-box">
                <h4><i class="fa-solid fa-gift"></i> Festive Package Details</h4>

                <div class="package-detail-grid">

                    <div class="package-detail-row">
                        <label>Festival Name</label>
                        <p><%= festivalName %></p>
                    </div>

                    <div class="package-detail-row">
                        <label>Discount Rate</label>
                        <p><%=String.format("%.0f", discountRate)%>% OFF</p>
                    </div>

                    <div class="package-detail-row">
                        <label>Start Date</label>
                        <p><%= startDate %></p>
                    </div>

                    <div class="package-detail-row">
                        <label>End Date</label>
                        <p><%= endDate %></p>
                    </div>

                </div>

                <div class="package-detail-row">
                    <label>Price After Discount</label>
                    <p class="final-price-text">
                        RM <%=String.format("%.2f", finalPrice)%>
                    </p>
                </div>
            </div>

        <% } %>

        <div class="package-note">
            <i class="fa-solid fa-circle-info"></i>
            <span>
                This package information is for viewing only. To make a booking, please go to the booking page and select your vehicle, date, time, and package.
            </span>
        </div>

        <div class="modal-footer">
            <button type="button" class="modal-ok-btn" onclick="closePackageModal('<%=modalId%>')">
                Close
            </button>
        </div>

    </div>
</div>

        <%
            }
        }
        %>

        </div>

    </main>

</div>

<script>
    function openPackageModal(id) {
        document.getElementById(id).classList.add("active");
    }

    function closePackageModal(id) {
        document.getElementById(id).classList.remove("active");
    }
</script>

</body>
</html>