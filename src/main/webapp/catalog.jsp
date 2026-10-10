<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="example.DBConnection" %>
<%
    String userName = (String) session.getAttribute("userName");
    Integer userId = (Integer) session.getAttribute("userId");

    if (userName == null || userId == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    // Auto-release expired bookings on catalog page view
    try (Connection conn = DBConnection.getConnection()) {
        if (conn != null) {
            String autoReleaseSql = 
                "UPDATE vehicles v " +
                "JOIN bookings b ON v.vehicle_id = b.vehicle_id " +
                "SET v.status = 'AVAILABLE', b.kyc_status = 'COMPLETED' " +
                "WHERE b.kyc_status IN ('APPROVED', 'ACTIVE') AND b.return_date < CURRENT_DATE()";
                
            try (PreparedStatement stmt = conn.prepareStatement(autoReleaseSql)) {
                stmt.executeUpdate();
            }
        }
    } catch (Throwable t) {
        t.printStackTrace();
    }

    String categoryFilter = request.getParameter("category");
    String searchQuery = request.getParameter("search");
    String todayDate = LocalDate.now().toString();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DriveEazy - Vehicle Fleet Catalog</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #0f172a;
            --accent: #22c55e;
            --bg-gray: #f8fafc;
            --card-border: #e2e8f0;
            --text-dark: #0f172a;
            --text-muted: #64748b;
        }

        * {
            box-sizing: border-box;
            font-family: 'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, sans-serif;
            margin: 0;
            padding: 0;
        }

        body {
            background-color: var(--bg-gray);
            color: var(--text-dark);
        }

        /* Top Bar */
        .navbar {
            background: #000000;
            color: #ffffff;
            padding: 16px 5%;
            display: flex;
            justify-content: space-between;
            align-items: center;
            position: sticky;
            top: 0;
            z-index: 100;
            box-shadow: 0 2px 10px rgba(0,0,0,0.15);
        }

        .navbar .brand {
            font-size: 24px;
            font-weight: 800;
            color: #ffffff;
            text-decoration: none;
            letter-spacing: -0.5px;
        }

        .navbar .brand span {
            color: var(--accent);
            font-weight: 400;
        }

        .nav-actions {
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .nav-btn {
            color: #ffffff;
            text-decoration: none;
            font-size: 14px;
            font-weight: 600;
            padding: 8px 16px;
            border-radius: 8px;
            border: 1px solid rgba(255,255,255,0.2);
            transition: all 0.2s ease;
        }

        .nav-btn:hover {
            background: rgba(255,255,255,0.1);
        }

        /* Hero Header */
        .catalog-hero {
            background: linear-gradient(180deg, #000000 0%, #0f172a 100%);
            color: #ffffff;
            padding: 40px 5% 60px 5%;
            text-align: center;
        }

        .catalog-hero h1 {
            font-size: 32px;
            font-weight: 800;
            margin-bottom: 8px;
        }

        .catalog-hero p {
            color: #94a3b8;
            font-size: 15px;
        }

        /* Main Wrapper Card */
        .main-catalog-wrapper {
            max-width: 1240px;
            margin: -35px auto 40px auto;
            padding: 24px;
            background: #ffffff;
            border-radius: 20px;
            border: 1px solid var(--card-border);
            box-shadow: 0 10px 25px -5px rgba(0,0,0,0.05);
        }

        /* Filter Toolbar */
        .filter-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 15px;
            margin-bottom: 28px;
            padding-bottom: 20px;
            border-bottom: 1px solid #f1f5f9;
        }

        .search-form {
            display: flex;
            gap: 8px;
            flex: 1;
            max-width: 420px;
        }

        .search-input {
            width: 100%;
            padding: 10px 16px;
            border-radius: 10px;
            border: 1px solid var(--card-border);
            outline: none;
            font-size: 14px;
            background: #ffffff;
            color: var(--text-dark);
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.02);
            transition: border-color 0.2s, box-shadow 0.2s;
        }

        .search-input:focus {
            background: #ffffff;
            border-color: #000000;
            box-shadow: 0 0 0 2px rgba(0, 0, 0, 0.05);
        }

        .search-btn {
            background: #000000;
            color: #ffffff;
            border: none;
            padding: 10px 20px;
            border-radius: 10px;
            font-weight: 700;
            cursor: pointer;
            transition: background 0.2s;
        }

        .search-btn:hover {
            background: #1e293b;
        }

        .category-pills {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
        }

        .pill {
            text-decoration: none;
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 700;
            background: #f1f5f9;
            color: var(--text-muted);
            transition: all 0.2s;
        }

        .pill.active, .pill:hover {
            background: #000000;
            color: #ffffff;
        }

        /* Grid Layout */
        .grid-container {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
            gap: 24px;
        }

        .vehicle-card {
            background: #ffffff;
            border-radius: 16px;
            overflow: hidden;
            border: 1px solid var(--card-border);
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.03);
            display: flex;
            flex-direction: column;
            cursor: pointer;
            transition: transform 0.2s, box-shadow 0.2s;
        }

        .vehicle-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 12px 20px -5px rgba(0,0,0,0.08);
        }

        .card-img-wrapper {
            position: relative;
            height: 190px;
            background: #f8fafc;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 12px;
        }

        .card-img {
            max-width: 100%;
            max-height: 100%;
            object-fit: contain;
        }

        .category-badge {
            position: absolute;
            top: 12px;
            left: 12px;
            background: #000000;
            color: #ffffff;
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 10px;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .card-body {
            padding: 20px;
            display: flex;
            flex-direction: column;
            flex: 1;
        }

        .brand-subtitle {
            font-size: 11px;
            font-weight: 800;
            color: var(--text-muted);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 2px;
        }

        .vehicle-title {
            font-size: 18px;
            font-weight: 800;
            color: var(--text-dark);
            margin-bottom: 6px;
        }

        .vehicle-desc {
            font-size: 13px;
            color: var(--text-muted);
            line-height: 1.5;
            margin-bottom: 14px;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
            min-height: 38px;
        }

        .card-price {
            font-size: 20px;
            font-weight: 800;
            color: #16a34a;
            margin-bottom: 16px;
        }

        .card-price span {
            font-size: 12px;
            color: var(--text-muted);
            font-weight: 600;
        }

        .btn-book {
            width: 100%;
            background: #000000;
            color: #ffffff;
            border: none;
            padding: 12px;
            border-radius: 10px;
            font-weight: 700;
            font-size: 14px;
            cursor: pointer;
            margin-top: auto;
            transition: background 0.2s;
        }

        .btn-book:hover {
            background: #1e293b;
        }

        /* Extended Vehicle Details Modal */
        .modal-overlay {
            display: none;
            position: fixed;
            top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(0,0,0,0.7);
            z-index: 200;
            align-items: center;
            justify-content: center;
            padding: 20px;
            overflow-y: auto;
        }

        .modal-card {
            background: #ffffff;
            border-radius: 20px;
            width: 100%;
            max-width: 800px;
            padding: 28px;
            box-shadow: 0 20px 25px -5px rgba(0,0,0,0.2);
            position: relative;
        }

        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            border-bottom: 1px solid #f1f5f9;
            padding-bottom: 12px;
        }

        .modal-header h3 { font-size: 20px; font-weight: 800; }
        .close-btn { background: none; border: none; font-size: 24px; cursor: pointer; color: var(--text-muted); }

        .modal-body-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 24px;
        }

        @media (max-width: 768px) {
            .modal-body-grid {
                grid-template-columns: 1fr;
            }
        }

        .modal-vehicle-preview {
            background: #f8fafc;
            border-radius: 16px;
            padding: 20px;
            display: flex;
            flex-direction: column;
            align-items: center;
            border: 1px solid var(--card-border);
        }

        .modal-vehicle-img {
            max-width: 100%;
            max-height: 200px;
            object-fit: contain;
            margin-bottom: 15px;
        }

        .modal-info-pills {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
            margin-bottom: 12px;
            width: 100%;
        }

        .info-tag {
            background: #f1f5f9;
            padding: 6px 12px;
            border-radius: 8px;
            font-size: 12px;
            font-weight: 700;
            color: var(--text-dark);
        }

        .modal-vehicle-desc {
            font-size: 13px;
            color: var(--text-muted);
            line-height: 1.6;
            margin-top: 10px;
            width: 100%;
        }

        .modal-form-side {
            display: flex;
            flex-direction: column;
        }

        .form-group { margin-bottom: 16px; }
        .form-group label { display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: var(--text-muted); margin-bottom: 6px; }
        .form-group input, .form-group select {
            width: 100%; padding: 11px 14px; border: 1px solid #cbd5e1; border-radius: 10px; outline: none; font-size: 14px;
        }

        .price-summary-box {
            background: #f0fdf4;
            border: 1px solid #bbf7d0;
            padding: 14px;
            border-radius: 10px;
            margin-bottom: 16px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .price-summary-box .label { font-size: 13px; font-weight: 700; color: #166534; }
        .price-summary-box .val { font-size: 20px; font-weight: 800; color: #15803d; }

        /* HOW TO BOOK SECTION */
        .how-it-works-section {
            background: #000000;
            color: #ffffff;
            padding: 60px 5%;
            margin-top: 60px;
            border-top: 1px solid rgba(255, 255, 255, 0.1);
        }

        .how-it-works-container { max-width: 1240px; margin: 0 auto; }
        .section-header { text-align: center; margin-bottom: 48px; }
        .section-header h2 { font-size: 28px; font-weight: 800; color: #ffffff; margin-bottom: 8px; letter-spacing: -0.5px; }
        .section-header p { color: #94a3b8; font-size: 15px; }

        .steps-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
        }

        @media (max-width: 1024px) {
            .steps-grid { grid-template-columns: repeat(2, 1fr); }
        }

        @media (max-width: 640px) {
            .steps-grid { grid-template-columns: 1fr; }
        }

        .step-card {
            background: #0f172a;
            border: 1px solid #1e293b;
            border-radius: 16px;
            padding: 24px 20px;
            transition: transform 0.2s ease, border-color 0.2s ease;
        }

        .step-card:hover { transform: translateY(-4px); border-color: #22c55e; }

        .step-number {
            display: inline-flex; align-items: center; justify-content: center; width: 36px; height: 36px;
            background: rgba(34, 197, 94, 0.15); color: #22c55e; border-radius: 10px; font-size: 14px; font-weight: 800; margin-bottom: 16px;
        }

        .step-icon { font-size: 28px; margin-bottom: 12px; display: block; }
        .step-title { font-size: 16px; font-weight: 700; color: #ffffff; margin-bottom: 8px; }
        .step-desc { font-size: 13px; color: #94a3b8; line-height: 1.5; }

        .empty-catalog {
            grid-column: 1 / -1;
            text-align: center;
            padding: 60px 20px;
            background: #ffffff;
            border-radius: 16px;
        }
    </style>
</head>
<body>

<!-- Navbar -->
<div class="navbar">
    <a href="catalog.jsp" class="brand">Drive<span>Eazy</span></a>
    <div class="nav-actions">
    <a href="about.jsp" class="nav-btn">ℹ️ About Us</a>
        <a href="my_bookings.jsp" class="nav-btn">📋 My Reservations</a>
        <a href="LogoutServlet" style="color: #ef4444; font-weight: 700; text-decoration: none; font-size: 14px;">Logout</a>
    </div>
</div>

<!-- Hero Banner -->
<div class="catalog-hero">
    <h1>Explore Available Fleet</h1>
    <p>Select your dream car or bike for self-drive travel across India</p>
</div>

<!-- Main Section Wrapper -->
<div class="main-catalog-wrapper">

    <!-- Filter & Search Toolbar -->
    <div class="filter-bar">
        <form action="catalog.jsp" method="GET" class="search-form">
            <input type="text" name="search" class="search-input" placeholder="Search by brand or title..." value="<%= searchQuery != null ? searchQuery : "" %>">
            <button type="submit" class="search-btn">Search</button>
        </form>

        <div class="category-pills">
            <a href="catalog.jsp" class="pill <%= (categoryFilter == null || categoryFilter.isEmpty()) ? "active" : "" %>">All Vehicles</a>
            <a href="catalog.jsp?category=Car" class="pill <%= "Car".equals(categoryFilter) ? "active" : "" %>">Cars</a>
            <a href="catalog.jsp?category=Bike" class="pill <%= "Bike".equals(categoryFilter) ? "active" : "" %>">Bikes / Scooters</a>
        </div>
    </div>

    <!-- Vehicle Catalog Grid -->
    <div class="grid-container">
        <%
            boolean hasVehicles = false;
            try (Connection conn = DBConnection.getConnection()) {
                if (conn != null) {
                    String sql = "SELECT * FROM vehicles WHERE status = 'AVAILABLE'";

                    if (categoryFilter != null && !categoryFilter.isEmpty()) {
                        sql += " AND category = ?";
                    }
                    if (searchQuery != null && !searchQuery.trim().isEmpty()) {
                        sql += " AND (title LIKE ? OR brand LIKE ?)";
                    }

                    PreparedStatement stmt = conn.prepareStatement(sql);
                    int paramIndex = 1;

                    if (categoryFilter != null && !categoryFilter.isEmpty()) {
                        stmt.setString(paramIndex++, categoryFilter);
                    }
                    if (searchQuery != null && !searchQuery.trim().isEmpty()) {
                        String searchPattern = "%" + searchQuery.trim() + "%";
                        stmt.setString(paramIndex++, searchPattern);
                        stmt.setString(paramIndex++, searchPattern);
                    }

                    ResultSet rs = stmt.executeQuery();

                    while (rs.next()) {
                        hasVehicles = true;
                        int vehicleId = rs.getInt("vehicle_id");
                        String title = rs.getString("title");
                        String brand = rs.getString("brand");
                        String category = rs.getString("category");
                        double pricePerDay = rs.getDouble("price_per_day");
                        String imagePath = rs.getString("image_path");

                        String description = "";
                        try {
                            description = rs.getString("description");
                        } catch (Exception ignored) {}

                        if (description == null || description.trim().isEmpty()) {
                            description = "Premium self-drive " + category.toLowerCase() + " offering superior performance and comfort for long drives.";
                        }
        %>
        <!-- Vehicle Card (Clickable to open full details modal) -->
        <div class="vehicle-card" onclick="openVehicleDetailsModal(<%= vehicleId %>, '<%= title.replace("'", "\\'") %>', '<%= brand.replace("'", "\\'") %>', '<%= category %>', <%= pricePerDay %>, '<%= imagePath %>', '<%= description.replace("'", "\\'").replace("\n", " ") %>')">
            <div class="card-img-wrapper">
                <span class="category-badge"><%= category %></span>
                <img src="<%= imagePath %>" class="card-img" alt="<%= title %>" onerror="this.src='https://via.placeholder.com/300x180?text=Vehicle+Image';">
            </div>
            <div class="card-body">
                <div class="brand-subtitle"><%= brand %></div>
                <div class="vehicle-title"><%= title %></div>

                <div class="vehicle-desc"><%= description %></div>

                <div class="card-price">₹<%= String.format("%.2f", pricePerDay) %> <span>/ day</span></div>
                <button class="btn-book">View Details & Book</button>
            </div>
        </div>
        <%
                    }
                }

                if (!hasVehicles) {
        %>
        <div class="empty-catalog">
            <h3>No Available Vehicles Found</h3>
            <p style="color: #64748b; margin-top: 6px;">Try adjusting your search criteria or category filter.</p>
        </div>
        <%
                }
            } catch (Exception e) {
                out.println("<div class='empty-catalog' style='color:red;'>Error loading catalog: " + e.getMessage() + "</div>");
            }
        %>
    </div>

</div>

<!-- Expanded Vehicle Details & Booking Modal -->
<div id="vehicleModal" class="modal-overlay">
    <div class="modal-card">
        <div class="modal-header">
            <div>
                <span id="modalBrandSubtitle" style="font-size:11px; font-weight:800; color:#64748b; text-transform:uppercase;">BRAND</span>
                <h3 id="modalVehicleTitle">Vehicle Title</h3>
            </div>
            <button class="close-btn" onclick="closeVehicleModal()">&times;</button>
        </div>

        <div class="modal-body-grid">
            <!-- Left Side: Vehicle Info & Image -->
            <div class="modal-vehicle-preview">
                <img id="modalVehicleImg" src="" class="modal-vehicle-img" alt="Vehicle Image">

                <div class="modal-info-pills">
                    <span class="info-tag" id="modalCategoryTag">Category: SUV</span>
                    <span class="info-tag" style="background:#dcfce7; color:#15803d;" id="modalRateTag">₹0.00 / Day</span>
                </div>

                <div class="modal-vehicle-desc" id="modalVehicleDesc">
                    Detailed vehicle specs and comfort highlights will appear here.
                </div>
            </div>

            <!-- Right Side: Booking Dates & Delivery Form -->
            <div class="modal-form-side">
                <form action="CreateBookingServlet" method="POST" id="bookingForm">
                    <input type="hidden" name="vehicleId" id="modalVehicleId">

                    <div class="form-group">
                        <label>Pickup Date</label>
                        <input type="date" name="pickupDate" id="pickupDate" min="<%= todayDate %>" value="<%= todayDate %>" required onchange="calculatePrice()">
                    </div>

                    <div class="form-group">
                        <label>Return Date</label>
                        <input type="date" name="returnDate" id="returnDate" min="<%= todayDate %>" value="<%= todayDate %>" required onchange="calculatePrice()">
                    </div>

                    <div class="form-group">
                        <label>Handover Choice</label>
                        <select name="deliveryType" id="deliveryType" required onchange="calculatePrice()">
                            <option value="SELF_PICKUP">Self Pickup (Hub Center - Free)</option>
                            <option value="DOORSTEP">Doorstep Delivery (+₹300)</option>
                        </select>
                    </div>

                    <div class="price-summary-box">
                        <span class="label">Estimated Total:</span>
                        <span class="val" id="totalPriceDisplay">₹0.00</span>
                    </div>

                    <button type="submit" class="btn-book">Confirm & Create Reservation</button>
                </form>
            </div>
        </div>
    </div>
</div>

<!-- HOW TO BOOK SECTION -->
<div class="how-it-works-section">
    <div class="how-it-works-container">

        <div class="section-header">
            <h2>How to Book Your Drive</h2>
            <p>Rent your favorite car or bike in 4 simple steps</p>
        </div>

        <div class="steps-grid">
            <div class="step-card">
                <span class="step-number">01</span>
                <span class="step-icon">🏎️</span>
                <div class="step-title">Choose Your Vehicle</div>
                <div class="step-desc">
                    Browse our available fleet in the catalog above. Filter by brand, category, or daily rates to find your perfect match.
                </div>
            </div>

            <div class="step-card">
                <span class="step-number">02</span>
                <span class="step-icon">📅</span>
                <div class="step-title">Select Dates & Mode</div>
                <div class="step-desc">
                    Pick your pickup and return dates along with your preferred handover option (Self Pickup or Doorstep Delivery).
                </div>
            </div>

            <div class="step-card">
                <span class="step-number">03</span>
                <span class="step-icon">📄</span>
                <div class="step-title">Upload Driving License</div>
                <div class="step-desc">
                    Head to <strong>My Reservations</strong> to submit your DL number and document image for quick admin verification.
                </div>
            </div>

            <div class="step-card">
                <span class="step-number">04</span>
                <span class="step-icon">🔑</span>
                <div class="step-title">Get Keys & Drive</div>
                <div class="step-desc">
                    Once verified, receive your vehicle keys, enjoy your trip, and manage extension or PDF invoice directly from your portal.
                </div>
            </div>
        </div>

    </div>
</div>

<script>
    let currentDailyRate = 0;

    function openVehicleDetailsModal(id, title, brand, category, rate, imagePath, desc) {
        currentDailyRate = rate;
        document.getElementById('modalVehicleId').value = id;
        document.getElementById('modalBrandSubtitle').innerText = brand;
        document.getElementById('modalVehicleTitle').innerText = title;
        document.getElementById('modalCategoryTag').innerText = 'Category: ' + category;
        document.getElementById('modalRateTag').innerText = '₹' + rate.toFixed(2) + ' / Day';
        document.getElementById('modalVehicleImg').src = imagePath;
        document.getElementById('modalVehicleImg').onerror = function() {
            this.src = 'https://via.placeholder.com/300x180?text=Vehicle+Image';
        };
        document.getElementById('modalVehicleDesc').innerText = desc;

        calculatePrice();
        document.getElementById('vehicleModal').style.display = 'flex';
    }

    function closeVehicleModal() {
        document.getElementById('vehicleModal').style.display = 'none';
    }

    function calculatePrice() {
        const pDateVal = document.getElementById('pickupDate').value;
        const rDateVal = document.getElementById('returnDate').value;
        const deliveryType = document.getElementById('deliveryType').value;

        if (!pDateVal || !rDateVal) return;

        const pDate = new Date(pDateVal);
        const rDate = new Date(rDateVal);

        let diffTime = rDate.getTime() - pDate.getTime();
        let diffDays = Math.ceil(diffTime / (1000 * 360 * 24)) + 1; // inclusive of start day

        if (diffDays < 1) diffDays = 1;

        let total = diffDays * currentDailyRate;
        if (deliveryType === 'DOORSTEP') {
            total += 300;
        }

        document.getElementById('totalPriceDisplay').innerText = '₹' + total.toFixed(2) + ' (' + diffDays + ' Days)';
    }

    window.onclick = function(event) {
        var modal = document.getElementById('vehicleModal');
        if (event.target === modal) {
            closeVehicleModal();
        }
    }
</script>

</body>
</html>