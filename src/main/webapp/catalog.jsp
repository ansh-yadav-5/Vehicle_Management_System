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
    <title>GoDrive - Vehicle Fleet Catalog</title>
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

        .rating-badge-top {
            position: absolute;
            top: 12px;
            right: 12px;
            background: rgba(255, 255, 255, 0.95);
            color: #000000;
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 11px;
            font-weight: 800;
            display: flex;
            align-items: center;
            gap: 4px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
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

        .rating-row {
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: 12px;
            font-weight: 700;
            color: #d97706;
            margin-bottom: 8px;
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

        /* Expanded Vehicle Details Modal */
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
            .modal-body-grid { grid-template-columns: 1fr; }
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

        /* WHY US SECTION */
        .why-us-section {
            background: #0f172a;
            color: #ffffff;
            padding: 60px 5%;
            border-top: 1px solid #1e293b;
        }

        .why-us-container { max-width: 1240px; margin: 0 auto; }

        .why-us-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
            gap: 24px;
        }

        .why-card {
            background: #000000;
            border: 1px solid #1e293b;
            border-radius: 16px;
            padding: 28px 24px;
            transition: transform 0.2s ease, border-color 0.2s ease;
        }

        .why-card:hover { transform: translateY(-4px); border-color: #22c55e; }
        .why-icon { font-size: 32px; margin-bottom: 16px; display: inline-block; }
        .why-title { font-size: 18px; font-weight: 800; color: #ffffff; margin-bottom: 8px; }
        .why-desc { font-size: 13px; color: #94a3b8; line-height: 1.6; }

        /* FAQ SECTION */
        .faq-section {
            background: #000000;
            color: #ffffff;
            padding: 60px 5%;
            border-top: 1px solid rgba(255,255,255,0.1);
        }

        .faq-container { max-width: 860px; margin: 0 auto; }

        .faq-item {
            background: #0f172a;
            border: 1px solid #1e293b;
            border-radius: 12px;
            margin-bottom: 16px;
            overflow: hidden;
            transition: border-color 0.2s ease;
        }

        .faq-item:hover { border-color: #22c55e; }

        .faq-question {
            padding: 20px 24px;
            font-size: 16px;
            font-weight: 700;
            color: #ffffff;
            cursor: pointer;
            display: flex;
            justify-content: space-between;
            align-items: center;
            user-select: none;
        }

        .faq-toggle-icon { font-size: 18px; color: #22c55e; transition: transform 0.3s ease; }

        .faq-answer {
            max-height: 0;
            overflow: hidden;
            padding: 0 24px;
            font-size: 14px;
            color: #94a3b8;
            line-height: 1.6;
            transition: max-height 0.3s ease, padding 0.3s ease;
        }

        .faq-item.active .faq-toggle-icon { transform: rotate(45deg); }
        .faq-item.active .faq-answer { max-height: 200px; padding: 0 24px 20px 24px; }

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
    <a href="catalog.jsp" class="brand">Go<span>Drive</span></a>
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
                    String sql =
                        "SELECT v.*, " +
                        "COALESCE(AVG(r.rating), 0) AS avg_rating, " +
                        "COUNT(r.review_id) AS total_reviews " +
                        "FROM vehicles v " +
                        "LEFT JOIN reviews r ON v.vehicle_id = r.vehicle_id " +
                        "WHERE v.status = 'AVAILABLE' ";

                    if (categoryFilter != null && !categoryFilter.isEmpty()) {
                        sql += " AND v.category = ?";
                    }
                    if (searchQuery != null && !searchQuery.trim().isEmpty()) {
                        sql += " AND (v.title LIKE ? OR v.brand LIKE ?)";
                    }

                    sql += " GROUP BY v.vehicle_id";

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
                        double avgRating = rs.getDouble("avg_rating");
                        int totalReviews = rs.getInt("total_reviews");

                        String description = "";
                        try { description = rs.getString("description"); } catch (Exception ignored) {}

                        if (description == null || description.trim().isEmpty()) {
                            description = "Premium self-drive " + category.toLowerCase() + " offering superior performance and comfort for long drives.";
                        }
        %>
        <!-- Vehicle Card -->
        <div class="vehicle-card" onclick="openVehicleDetailsModal(<%= vehicleId %>, '<%= title.replace("'", "\\'") %>', '<%= brand.replace("'", "\\'") %>', '<%= category %>', <%= pricePerDay %>, '<%= imagePath %>', '<%= description.replace("'", "\\'").replace("\n", " ") %>', <%= avgRating %>, <%= totalReviews %>)">
            <div class="card-img-wrapper">
                <span class="category-badge"><%= category %></span>
                <% if (totalReviews > 0) { %>
                <span class="rating-badge-top">⭐ <%= String.format("%.1f", avgRating) %></span>
                <% } %>
                <img src="<%= imagePath %>" class="card-img" alt="<%= title %>" onerror="this.src='https://via.placeholder.com/300x180?text=Vehicle+Image';">
            </div>
            <div class="card-body">
                <div class="brand-subtitle"><%= brand %></div>
                <div class="vehicle-title"><%= title %></div>

                <div class="rating-row">
                    <% if (totalReviews > 0) { %>
                        ★ <%= String.format("%.1f", avgRating) %> <span style="color: #64748b; font-weight: normal;">(<%= totalReviews %> <%= totalReviews == 1 ? "review" : "reviews" %>)</span>
                    <% } else { %>
                        <span style="color: #94a3b8; font-weight: normal;">New to fleet (No ratings)</span>
                    <% } %>
                </div>

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

<!-- Expanded Vehicle Details Modal -->
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
            <div class="modal-vehicle-preview">
                <img id="modalVehicleImg" src="" class="modal-vehicle-img" alt="Vehicle Image">

                <div class="modal-info-pills">
                    <span class="info-tag" id="modalCategoryTag">Category: SUV</span>
                    <span class="info-tag" style="background:#fef3c7; color:#b45309;" id="modalRatingTag">⭐ New</span>
                    <span class="info-tag" style="background:#dcfce7; color:#15803d;" id="modalRateTag">₹0.00 / Day</span>
                </div>

                <div style="font-size: 13px; color: var(--text-muted); line-height: 1.6; margin-top: 10px; width: 100%;" id="modalVehicleDesc"></div>
            </div>

            <div class="modal-form-side">
                <form action="CreateBookingServlet" method="POST">
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

<!-- WHY US SECTION -->
<div class="why-us-section">
    <div class="why-us-container">
        <div class="section-header">
            <h2>Why Choose GoDrive?</h2>
            <p>Experience hassle-free self-drive rentals engineered for safety, speed, and transparency</p>
        </div>

        <div class="why-us-grid">
            <div class="why-card">
                <span class="why-icon">💰</span>
                <div class="why-title">Zero Hidden Charges</div>
                <div class="why-desc">
                    Transparent pricing with all taxes and insurance included upfront. What you see is exactly what you pay.
                </div>
            </div>

            <div class="why-card">
                <span class="why-icon">⚡</span>
                <div class="why-title">Instant Digital KYC</div>
                <div class="why-desc">
                    Upload your driving license online and get verified in minutes without long paperwork queues at hubs.
                </div>
            </div>

            <div class="why-card">
                <span class="why-icon">🧼</span>
                <div class="why-title">Deep Cleaned & Sanitized</div>
                <div class="why-desc">
                    Every car and bike undergoes multi-point safety checks and deep cleaning prior to key handover.
                </div>
            </div>

            <div class="why-card">
                <span class="why-icon">🛠️</span>
                <div class="why-title">24/7 Roadside Assistance</div>
                <div class="why-desc">
                    Travel with complete peace of mind knowing our dedicated support team is available round-the-clock nationwide.
                </div>
            </div>
        </div>
    </div>
</div>

<!-- FAQ SECTION -->
<div class="faq-section">
    <div class="faq-container">
        <div class="section-header">
            <h2>Frequently Asked Questions</h2>
            <p>Everything you need to know about renting with GoDrive</p>
        </div>

        <div class="faq-item">
            <div class="faq-question" onclick="toggleFaq(this)">
                <span>What documents are required to rent a vehicle?</span>
                <span class="faq-toggle-icon">✚</span>
            </div>
            <div class="faq-answer">
                You will need an active original Driving License (DL) along with a valid Government ID (Aadhaar, Passport, or Voter ID). Upload your DL details directly on the <strong>My Reservations</strong> page after booking.
            </div>
        </div>

        <div class="faq-item">
            <div class="faq-question" onclick="toggleFaq(this)">
                <span>Is there a security deposit?</span>
                <span class="faq-toggle-icon">✚</span>
            </div>
            <div class="faq-answer">
                No! GoDrive operates with zero security deposit for verified users with approved KYC documents.
            </div>
        </div>

        <div class="faq-item">
            <div class="faq-question" onclick="toggleFaq(this)">
                <span>How does doorstep delivery work?</span>
                <span class="faq-toggle-icon">✚</span>
            </div>
            <div class="faq-answer">
                When reserving a vehicle, select "Doorstep Delivery" (+₹300 fee). Our agent will deliver the cleaned vehicle directly to your specified location upon KYC approval.
            </div>
        </div>

        <div class="faq-item">
            <div class="faq-question" onclick="toggleFaq(this)">
                <span>Can I extend my booking duration during a trip?</span>
                <span class="faq-toggle-icon">✚</span>
            </div>
            <div class="faq-answer">
                Yes! Go to <strong>My Reservations</strong>, select your active booking, enter the extra days required, and click "Extend Trip". Your new total will update automatically.
            </div>
        </div>

        <div class="faq-item">
            <div class="faq-question" onclick="toggleFaq(this)">
                <span>What is the fuel policy?</span>
                <span class="faq-toggle-icon">✚</span>
            </div>
            <div class="faq-answer">
                GoDrive vehicles are delivered with a baseline fuel level. You should return the vehicle with the same fuel level as when received.
            </div>
        </div>
    </div>
</div>

<script>
    let currentDailyRate = 0;

    function openVehicleDetailsModal(id, title, brand, category, rate, imagePath, desc, avgRating, totalReviews) {
        currentDailyRate = rate;
        document.getElementById('modalVehicleId').value = id;
        document.getElementById('modalBrandSubtitle').innerText = brand;
        document.getElementById('modalVehicleTitle').innerText = title;
        document.getElementById('modalCategoryTag').innerText = 'Category: ' + category;
        document.getElementById('modalRateTag').innerText = '₹' + rate.toFixed(2) + ' / Day';

        if (totalReviews > 0) {
            document.getElementById('modalRatingTag').innerText = '⭐ ' + avgRating.toFixed(1) + ' (' + totalReviews + ' reviews)';
        } else {
            document.getElementById('modalRatingTag').innerText = '⭐ New (0 reviews)';
        }

        document.getElementById('modalVehicleImg').src = imagePath;
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
        let diffDays = Math.ceil(diffTime / (1000 * 3600 * 24)) + 1;

        if (diffDays < 1) diffDays = 1;

        let total = diffDays * currentDailyRate;
        if (deliveryType === 'DOORSTEP') {
            total += 300;
        }

        document.getElementById('totalPriceDisplay').innerText = '₹' + total.toFixed(2) + ' (' + diffDays + ' Days)';
    }

    function toggleFaq(element) {
        const faqItem = element.parentElement;
        const isActive = faqItem.classList.contains('active');

        document.querySelectorAll('.faq-item').forEach(item => {
            item.classList.remove('active');
        });

        if (!isActive) {
            faqItem.classList.add('active');
        }
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