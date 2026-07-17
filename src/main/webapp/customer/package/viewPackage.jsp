<%-- src/main/webapp/customer/package/viewPackage.jsp --%>

<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="vehicleBooking.bean.*" %>

<%!
    public String safe(String value) {
        if (value == null || value.trim().isEmpty() || "null".equalsIgnoreCase(value)) {
            return "-";
        }
        return value.trim();
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

    public String money(double amount) {
        return "RM " + String.format("%.2f", amount);
    }
%>

<%
    response.setHeader("Cache-Control", "no-cache,no-store,must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    String role = (String) session.getAttribute("role");

    if (role == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    if (!"customer".equalsIgnoreCase(role)) {
        response.sendRedirect(request.getContextPath() + "/PackageController");
        return;
    }

    String displayName = (String) session.getAttribute("custName");

    if (displayName == null || displayName.trim().isEmpty()) {
        displayName = (String) session.getAttribute("name");
    }

    if (displayName == null || displayName.trim().isEmpty()) {
        displayName = "Customer";
    }

    @SuppressWarnings("unchecked")
    ArrayList<PackageBean> packageList =
            (ArrayList<PackageBean>) request.getAttribute("packageList");

    if (packageList == null) {
        response.sendRedirect(request.getContextPath() + "/PackageController");
        return;
    }

    int routineCount = 0;
    int festiveCount = 0;

    for (PackageBean packageBean : packageList) {
        if (packageBean instanceof RoutineBean) {
            routineCount++;
        } else if (packageBean instanceof FestivalBean) {
            festiveCount++;
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Packages | X-PERT DETAILING</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css?v=<%= System.currentTimeMillis() %>">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/xpertTheme.css?v=<%= System.currentTimeMillis() %>">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/viewPackage.css?v=<%= System.currentTimeMillis() %>">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/footer.css?v=<%= System.currentTimeMillis() %>">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>

<body>

<div class="xp-layout">

    <jsp:include page="/sidebar.jsp" />

    <main class="xp-main-content">

        <div class="page-header package-page-header">
            <div>
                <h1>
                    <i class="fa-solid fa-box-open"></i>
                    Explore Packages
                </h1>
                <p>
                    Welcome, <strong><%= esc(displayName) %></strong>. View available detailing packages and festive offers for your account.
                </p>
            </div>

            <div class="package-total-card">
                <i class="fa-solid fa-layer-group"></i>
                <div>
                    <span><%= packageList.size() %></span>
                    <small>Available Packages</small>
                </div>
            </div>
        </div>

        <div class="package-summary-row">
            <div class="package-summary-item">
                <i class="fa-solid fa-repeat"></i>
                <div>
                    <span><%= routineCount %></span>
                    <p>Routine Packages</p>
                </div>
            </div>

            <div class="package-summary-item">
                <i class="fa-solid fa-gift"></i>
                <div>
                    <span><%= festiveCount %></span>
                    <p>Festive Packages</p>
                </div>
            </div>

            <div class="package-summary-note">
                <i class="fa-solid fa-circle-info"></i>
                <p>
                    Festive packages are filtered based on your registered race and religion.
                </p>
            </div>
        </div>

        <div class="package-filter-card">
            <div class="filter-top">
                <div>
                    <h2>
                        <i class="fa-solid fa-filter"></i>
                        Filter Packages
                    </h2>
                    <p>Search packages by name, service, type, festival, or price.</p>
                </div>

                <button type="button" class="btn-reset-filter" onclick="resetPackageFilter()">
                    <i class="fa-solid fa-rotate-left"></i>
                    Reset
                </button>
            </div>

            <div class="filter-grid">
                <div class="filter-group filter-search-group">
                    <label>Search Package</label>
                    <div class="search-box">
                        <i class="fa-solid fa-magnifying-glass"></i>
                        <input type="text"
                               id="packageSearchInput"
                               placeholder="Search package name, service, festival...">
                    </div>
                </div>

                <div class="filter-group">
                    <label>Package Type</label>
                    <select id="packageTypeFilter">
                        <option value="all">All Packages</option>
                        <option value="routine">Routine Package</option>
                        <option value="festive">Festive Package</option>
                    </select>
                </div>

                <div class="filter-group">
                    <label>Price Sort</label>
                    <select id="packageSortFilter">
                        <option value="default">Default Order</option>
                        <option value="priceLowHigh">Price: Low to High</option>
                        <option value="priceHighLow">Price: High to Low</option>
                        <option value="nameAZ">Name: A to Z</option>
                        <option value="nameZA">Name: Z to A</option>
                    </select>
                </div>
            </div>



            <div class="filter-result-text">
                Showing <strong id="packageShownCount"><%= packageList.size() %></strong>
                of <strong id="packageTotalCount"><%= packageList.size() %></strong> packages
            </div>
        </div>

        <%
            if (packageList.isEmpty()) {
        %>

            <div class="empty-package-card">
                <div class="empty-icon">
                    <i class="fa-solid fa-box-open"></i>
                </div>

                <h2>No packages available</h2>
                <p>No package is currently available for your account. Please check again later.</p>
            </div>

        <%
            } else {
        %>

            <div class="package-container" id="packageContainer">

            <%
                int modalIndex = 0;

                for (PackageBean p : packageList) {
                    String modalId = "packageModal" + modalIndex;
                    modalIndex++;

                    boolean isRoutine = p instanceof RoutineBean;
                    boolean isFestive = p instanceof FestivalBean;

                    String packageType = "General Package";
                    String packageTypeClass = "general";
                    String entryMethod = "-";

                    String festivalName = "-";
                    String startDate = "-";
                    String endDate = "-";
                    String targetRace = "ALL";
                    String targetReligion = "ALL";

                    double discountRate = 0.0;
                    double originalPrice = p.getPackagePrice();
                    double finalPrice = originalPrice;

                    if (isRoutine) {
                        packageType = "Routine Package";
                        packageTypeClass = "routine";

                        RoutineBean r = (RoutineBean) p;
                        entryMethod = safe(r.getEntryMethod());
                    }

                    if (isFestive) {
                        packageType = "Festive Package";
                        packageTypeClass = "festive";

                        FestivalBean f = (FestivalBean) p;

                        festivalName = safe(f.getFestivalName());
                        startDate = safe(f.getStartDate());
                        endDate = safe(f.getEndDate());
                        discountRate = f.getDiscountRate();
                        targetRace = safe(f.getTargetRace());
                        targetReligion = safe(f.getTargetReligion());

                        finalPrice = originalPrice - (originalPrice * discountRate / 100);
                    }

                    String filterText =
                            safe(p.getPackageID()) + " " +
                            safe(p.getPackageName()) + " " +
                            safe(p.getServiceName()) + " " +
                            safe(p.getPackageDesc()) + " " +
                            packageType + " " +
                            festivalName + " " +
                            entryMethod + " " +
                            targetRace + " " +
                            targetReligion;
            %>

                <div class="package-item"
                     data-type="<%= packageTypeClass %>"
                     data-name="<%= esc(safe(p.getPackageName()).toLowerCase()) %>"
                     data-price="<%= finalPrice %>"
                     data-original-index="<%= modalIndex %>"
                     data-search="<%= esc(filterText.toLowerCase()) %>">

                    <div class="package-card">

                        <div class="package-card-top">
                            <span class="package-type-badge <%= packageTypeClass %>">
                                <% if (isFestive) { %>
                                    <i class="fa-solid fa-gift"></i>
                                <% } else if (isRoutine) { %>
                                    <i class="fa-solid fa-repeat"></i>
                                <% } else { %>
                                    <i class="fa-solid fa-box"></i>
                                <% } %>

                                <%= packageType %>
                            </span>

                            <span class="package-id-pill">
                                <%= esc(safe(p.getPackageID())) %>
                            </span>
                        </div>

                        <h2 class="package-title">
                            <%= esc(safe(p.getPackageName())) %>
                        </h2>

                        <div class="package-service">
                            <i class="fa-solid fa-screwdriver-wrench"></i>
                            <span><%= esc(safe(p.getServiceName())) %></span>
                        </div>

                        <div class="package-price-box">
                            <% if (isFestive) { %>
                                <div>
                                    <span class="old-price"><%= money(originalPrice) %></span>
                                    <span class="discount-badge"><%= String.format("%.0f", discountRate) %>% OFF</span>
                                </div>

                                <h3><%= money(finalPrice) %></h3>
                                <p>Final price after festive discount</p>
                            <% } else { %>
                                <h3><%= money(originalPrice) %></h3>
                                <p>Package price</p>
                            <% } %>
                        </div>

                        <% if (isFestive) { %>
                            <div class="package-info-grid">
                                <div>
                                    <small>Festival</small>
                                    <strong><%= esc(festivalName) %></strong>
                                </div>

                                <div>
                                    <small>Valid Until</small>
                                    <strong><%= esc(endDate) %></strong>
                                </div>
                            </div>
                        <% } %>

                        <% if (isRoutine) { %>
                            <div class="package-info-grid one">
                                <div>
                                    <small>Entry Method</small>
                                    <strong><%= esc(entryMethod) %></strong>
                                </div>
                            </div>
                        <% } %>

                        <div class="package-desc-section">
                            <h4>Included Services</h4>

                            <%
                                if (p.getPackageDesc() != null && !p.getPackageDesc().trim().isEmpty()) {
                                    String[] desc = p.getPackageDesc().split(",");

                                    for (String d : desc) {
                                        if (d != null && !d.trim().isEmpty()) {
                            %>

                                <div class="package-desc-item">
                                    <i class="fa-solid fa-check"></i>
                                    <span><%= esc(d.trim()) %></span>
                                </div>

                            <%
                                        }
                                    }
                                } else {
                            %>

                                <div class="package-desc-item muted">
                                    <i class="fa-solid fa-circle-info"></i>
                                    <span>No description available.</span>
                                </div>

                            <%
                                }
                            %>
                        </div>

                        <div class="package-actions">
                            <button type="button" class="btn-view" onclick="openPackageModal('<%= modalId %>')">
                                View Details
                            </button>

                            <a href="<%= request.getContextPath() %>/BookingController" class="btn-book">
                                Book Now
                            </a>
                        </div>

                    </div>

                    <div class="package-modal" id="<%= modalId %>">

                        <div class="package-modal-box">

                            <div class="package-modal-header">
                                <div>
                                    <span class="package-type-badge <%= packageTypeClass %>">
                                        <%= packageType %>
                                    </span>

                                    <h2><%= esc(safe(p.getPackageName())) %></h2>
                                    <p><%= esc(safe(p.getServiceName())) %></p>
                                </div>

                                <button type="button" class="modal-close" onclick="closePackageModal('<%= modalId %>')">
                                    &times;
                                </button>
                            </div>

                            <div class="package-summary-box">
                                <div>
                                    <label>Original Price</label>
                                    <h3><%= money(originalPrice) %></h3>
                                </div>

                                <% if (isFestive) { %>
                                    <div>
                                        <label>Discount</label>
                                        <h3><%= String.format("%.0f", discountRate) %>% OFF</h3>
                                    </div>

                                    <div>
                                        <label>Final Price</label>
                                        <h3 class="final-price"><%= money(finalPrice) %></h3>
                                    </div>
                                <% } %>
                            </div>

                            <div class="package-detail-grid">
                                <div class="package-detail-row">
                                    <label>Package ID</label>
                                    <p><%= esc(safe(p.getPackageID())) %></p>
                                </div>

                                <div class="package-detail-row">
                                    <label>Package Type</label>
                                    <p><%= packageType %></p>
                                </div>

                                <div class="package-detail-row">
                                    <label>Package Name</label>
                                    <p><%= esc(safe(p.getPackageName())) %></p>
                                </div>

                                <div class="package-detail-row">
                                    <label>Service Name</label>
                                    <p><%= esc(safe(p.getServiceName())) %></p>
                                </div>
                            </div>

                            <div class="package-detail-row full">
                                <label>What is included?</label>

                                <%
                                    if (p.getPackageDesc() != null && !p.getPackageDesc().trim().isEmpty()) {
                                        String[] modalDesc = p.getPackageDesc().split(",");
                                %>

                                    <div class="modal-desc-list">
                                        <%
                                            for (String d : modalDesc) {
                                                if (d != null && !d.trim().isEmpty()) {
                                        %>

                                            <div>
                                                <i class="fa-solid fa-check"></i>
                                                <span><%= esc(d.trim()) %></span>
                                            </div>

                                        <%
                                                }
                                            }
                                        %>
                                    </div>

                                <%
                                    } else {
                                %>

                                    <p>No description available.</p>

                                <%
                                    }
                                %>
                            </div>

                            <% if (isRoutine) { %>

                                <div class="package-extra-box routine-box">
                                    <h4>
                                        <i class="fa-solid fa-repeat"></i>
                                        Routine Package Details
                                    </h4>

                                    <div class="package-detail-grid">
                                        <div class="package-detail-row">
                                            <label>Entry Method</label>
                                            <p><%= esc(entryMethod) %></p>
                                        </div>

                                        <div class="package-detail-row">
                                            <label>Suitable For</label>
                                            <p>Normal day service booking and regular car care maintenance.</p>
                                        </div>
                                    </div>
                                </div>

                            <% } %>

                            <% if (isFestive) { %>

                                <div class="package-extra-box festive-box">
                                    <h4>
                                        <i class="fa-solid fa-gift"></i>
                                        Festive Package Details
                                    </h4>

                                    <div class="package-detail-grid">
                                        <div class="package-detail-row">
                                            <label>Festival Name</label>
                                            <p><%= esc(festivalName) %></p>
                                        </div>

                                        <div class="package-detail-row">
                                            <label>Discount Rate</label>
                                            <p><%= String.format("%.0f", discountRate) %>% OFF</p>
                                        </div>

                                        <div class="package-detail-row">
                                            <label>Start Date</label>
                                            <p><%= esc(startDate) %></p>
                                        </div>

                                        <div class="package-detail-row">
                                            <label>End Date</label>
                                            <p><%= esc(endDate) %></p>
                                        </div>

                                        <div class="package-detail-row">
                                            <label>Target Race</label>
                                            <p><%= esc(targetRace) %></p>
                                        </div>

                                        <div class="package-detail-row">
                                            <label>Target Religion</label>
                                            <p><%= esc(targetReligion) %></p>
                                        </div>
                                    </div>
                                </div>

                            <% } %>

                            <div class="package-note">
                                <i class="fa-solid fa-circle-info"></i>

                                <span>
                                    To make a booking, click Book Now and select your vehicle, date, time, and preferred package.
                                </span>
                            </div>

                            <div class="modal-footer">
                                <a href="<%= request.getContextPath() %>/BookingController" class="modal-book-btn">
                                    <i class="fa-solid fa-calendar-check"></i>
                                    Book Now
                                </a>

                                <button type="button" class="modal-ok-btn" onclick="closePackageModal('<%= modalId %>')">
                                    Close
                                </button>
                            </div>

                        </div>
                    </div>

                </div>

            <%
                }
            %>

            </div>

            <div class="empty-package-card filter-empty-card" id="filterEmptyCard">
                <div class="empty-icon">
                    <i class="fa-solid fa-magnifying-glass"></i>
                </div>

                <h2>No matching packages</h2>
                <p>Try changing your search keyword, package type, or price sorting.</p>
            </div>

        <%
            }
        %>

    </main>

</div>

<script>
    const packageSearchInput = document.getElementById("packageSearchInput");
    const packageTypeFilter = document.getElementById("packageTypeFilter");
    const packageSortFilter = document.getElementById("packageSortFilter");
    const packageContainer = document.getElementById("packageContainer");
    const packageShownCount = document.getElementById("packageShownCount");
    const filterEmptyCard = document.getElementById("filterEmptyCard");

    function setQuickFilter(button) {
        document.querySelectorAll(".filter-tab").forEach(function (tab) {
            tab.classList.remove("active");
        });

        button.classList.add("active");

        if (packageTypeFilter) {
            packageTypeFilter.value = button.dataset.filter || "all";
        }

        applyPackageFilter();
    }

    function syncQuickFilter(typeValue) {
        document.querySelectorAll(".filter-tab").forEach(function (tab) {
            if (tab.dataset.filter === typeValue) {
                tab.classList.add("active");
            } else {
                tab.classList.remove("active");
            }
        });
    }

    function applyPackageFilter() {
        if (!packageContainer) {
            return;
        }

        const searchValue = packageSearchInput ? packageSearchInput.value.toLowerCase().trim() : "";
        const typeValue = packageTypeFilter ? packageTypeFilter.value : "all";
        const sortValue = packageSortFilter ? packageSortFilter.value : "default";

        let packageItems = Array.from(packageContainer.querySelectorAll(".package-item"));

        packageItems.forEach(function (item) {
            const itemType = item.dataset.type || "";
            const itemSearch = item.dataset.search || "";

            const matchType = typeValue === "all" || itemType === typeValue;
            const matchSearch = searchValue === "" || itemSearch.includes(searchValue);

            if (matchType && matchSearch) {
                item.style.display = "";
            } else {
                item.style.display = "none";
            }
        });

        packageItems.sort(function (a, b) {
            const priceA = parseFloat(a.dataset.price || "0");
            const priceB = parseFloat(b.dataset.price || "0");
            const nameA = a.dataset.name || "";
            const nameB = b.dataset.name || "";
            const indexA = parseInt(a.dataset.originalIndex || "0");
            const indexB = parseInt(b.dataset.originalIndex || "0");

            if (sortValue === "priceLowHigh") {
                return priceA - priceB;
            }

            if (sortValue === "priceHighLow") {
                return priceB - priceA;
            }

            if (sortValue === "nameAZ") {
                return nameA.localeCompare(nameB);
            }

            if (sortValue === "nameZA") {
                return nameB.localeCompare(nameA);
            }

            return indexA - indexB;
        });

        packageItems.forEach(function (item) {
            packageContainer.appendChild(item);
        });

        const visibleCount = packageItems.filter(function (item) {
            return item.style.display !== "none";
        }).length;

        if (packageShownCount) {
            packageShownCount.textContent = visibleCount;
        }

        if (filterEmptyCard) {
            filterEmptyCard.style.display = visibleCount === 0 ? "block" : "none";
        }
    }

    function resetPackageFilter() {
        if (packageSearchInput) {
            packageSearchInput.value = "";
        }

        if (packageTypeFilter) {
            packageTypeFilter.value = "all";
        }

        if (packageSortFilter) {
            packageSortFilter.value = "default";
        }

        syncQuickFilter("all");
        applyPackageFilter();
    }

    if (packageSearchInput) {
        packageSearchInput.addEventListener("input", applyPackageFilter);
    }

    if (packageTypeFilter) {
        packageTypeFilter.addEventListener("change", function () {
            syncQuickFilter(packageTypeFilter.value);
            applyPackageFilter();
        });
    }

    if (packageSortFilter) {
        packageSortFilter.addEventListener("change", applyPackageFilter);
    }

    function openPackageModal(id) {
        const modal = document.getElementById(id);

        if (modal) {
            document.body.appendChild(modal);

            modal.classList.add("active");
            document.body.classList.add("modal-open");

            const modalBox = modal.querySelector(".package-modal-box");

            if (modalBox) {
                modalBox.scrollTop = 0;
            }

            modal.scrollTop = 0;
        }
    }

    function closePackageModal(id) {
        const modal = document.getElementById(id);

        if (modal) {
            modal.classList.remove("active");
            document.body.classList.remove("modal-open");
        }
    }

    document.addEventListener("click", function (event) {
        if (event.target.classList.contains("package-modal")) {
            event.target.classList.remove("active");
            document.body.classList.remove("modal-open");
        }
    });

    document.addEventListener("keydown", function (event) {
        if (event.key === "Escape") {
            document.querySelectorAll(".package-modal.active").forEach(function (modal) {
                modal.classList.remove("active");
            });

            document.body.classList.remove("modal-open");
        }
    });

    applyPackageFilter();
</script>

<footer id="footer">
    <div class="container">
        <div class="footer-grid">

            <div>
                <div class="footer-brand">X<span>-</span>PERT DETAILING</div>
                <p class="footer-tagline">Premium car detailing and maintenance services</p>
            </div>

            <div class="footer-col">
                <h3>Services</h3>

                <ul>
                    <li><button type="button">Car Detailing</button></li>
                    <li><button type="button">Ceramic Coating</button></li>
                    <li><button type="button">Paint Protection</button></li>
                    <li><button type="button">Interior Cleaning</button></li>
                </ul>
            </div>

            <div class="footer-col">
                <h3>Quick Links</h3>

                <ul>
                    <li><button type="button">About Us</button></li>
                    <li><button type="button">Book Now</button></li>
                    <li><button type="button">Contact</button></li>
                    <li><button type="button">FAQ</button></li>
                </ul>
            </div>

            <div class="footer-col">
                <h3>Contact</h3>

                <div class="footer-contact-item">
                    <i class="fa-regular fa-envelope"></i>
                    <a href="mailto:info@xpertdetailing.com">info@xpertdetailing.com</a>
                </div>

                <div class="footer-contact-item">
                    <i class="fa-solid fa-phone"></i>
                    <a href="tel:+60123456789">+60 12-345 6789</a>
                </div>

                <div class="footer-contact-item">
                    <i class="fa-solid fa-location-dot"></i>
                    <span>
                        JC111, Jalan BMU 2,<br>
                        Bandar Baru Merlimau Utara,<br>
                        77300 Merlimau, Melaka
                    </span>
                </div>
            </div>

        </div>

        <div class="footer-bottom">
            <p>&copy; 2026 X-PERT DETAILING. All rights reserved.</p>
        </div>
    </div>
</footer>

</body>
</html>