<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="example.DBConnection" %>
<%
    String userName = (String) session.getAttribute("userName");
    Integer userId = (Integer) session.getAttribute("userId");

    String categoryFilter = request.getParameter("category");
    String transmissionFilter = request.getParameter("transmission");
    String searchQuery = request.getParameter("search");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DriveEazy - Self Drive Vehicle Fleet</title>
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
            padding-bottom: 60px;
        }

        /* Navbar */
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

        /* Hero Banner & Filters */
        .hero {
            background: linear-gradient(180deg, #000000 0%, #0f172a 100%);
            color: #ffffff;
            padding: 40px 5% 50px 5%;
            text-align: center;
        }

        .hero h1 {
            font-size: 36px;
            font-weight: 800;
            margin-bottom: 8px;
        }

        .hero p {
            color: #94a3b8;
            font-size: 16px;
            margin-bottom: 25px;
        }

        .search-container {
            max-width: 800px;
            margin: 0 auto;
            background: rgba(255, 255, 255, 0.08);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.15);
            padding: 12px 16px;
            border-radius: 14px;
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }

        .search-container input, .search-container select {
            padding: 10px 14px;
            border-radius: 8px;
            border: none;
            font-size: 14px;
            outline: none;
            background: #ffffff;
            color: #0f172a;
        }

        .search-container input[type="text"] {
            flex: 2;
            min-width: 180px;
        }

        .search-container select {
            flex: 1;
            min-width: 120px;
        }

        .btn-search {
            background: var(--accent);
            color: #ffffff;
            font-weight: 700;
            border: none;
            padding: 10px 20px;
            border-radius: 8px;
            cursor: pointer;
            transition: opacity 0.2s;
        }

        .btn-search:hover {
            opacity: 0.9;
        }

        /* Container & Cards Grid */
        .container {
            max-width: 1250px;
            margin: 30px auto 0 auto;
            padding: 0 20px;
        }

        .fleet-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 24px;
        }

        .vehicle-card {
            background: #ffffff;
            border-radius: 16px;
            overflow: hidden;
            border: 1px solid var(--card-border);
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
            transition: transform 0.2s, box-shadow 0.2s;
            display: flex;
            flex-direction: column;
        }

        .vehicle-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 10px 20px -5px rgba(0,0,0,0.1);
        }

        .card-img-container {
            width: 100%;
            height: 180px;
            background: #f1f5f9;
            position: relative;
        }

        .card-img-container img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .category-badge {
            position: absolute;
            top: 12px;
            left: 12px;
            background: rgba(15, 23, 42, 0.85);
            color: #ffffff;
            font-size: 10px;
            font-weight: 800;
            padding: 4px 10px;
            border-radius: 20px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .card-body {
            padding: 20px;
            display: flex;
            flex-direction: column;
            flex-grow: 1;
        }

        .card-title {
            font-size: 18px;
            font-weight: 800;
            color: var(--text-dark);
            margin-bottom: 4px;
        }

        .card-brand {
            font-size: 12px;
            color: var(--text-muted);
            font-weight: 600;
            margin-bottom: 12px;
        }

        .spec-pills {
            display: flex;
            gap: 6px;
            flex-wrap: wrap;
            margin-bottom: 16px;
        }

        .spec-pill {
            background: #f1f5f9;
            color: #475569;
            font-size: 11px;
            font-weight: 700;
            padding: 4px 8px;
            border-radius: 6px;
        }

        .pricing-section {
            margin-top: auto;
            border-top: 1px solid #f1f5f9;
            padding-top: 14px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .price-tag {
            font-size: 20px;
            font-weight: 800;
            color: var(--text-dark);
        }

        .price-tag span {
            font-size: 12px;
            color: var(--text-muted);
            font-weight: 600;
        }

        .btn-book {
            background: #000000;
            color: #ffffff;
            border: none;
            padding: 10px 18px;
            border-radius: 8px;
            font-size: 13px;
            font-weight: 700;
            cursor: pointer;
            transition: background 0.2s;
        }

        .btn-book:hover {
            background: #1e293b;
        }

        /* Booking Modal */
        .modal-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.6);
            z-index: 200;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }

        .modal-card {
            background: #ffffff;
            width: 100%;
            max-width: 480px;
            border-radius: 16px;
            padding: 24px;
            box-shadow: 0 20px 25px -5px rgba(0,0,0,0.2);
        }

        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 18px;
            padding-bottom: 12px;
            border-bottom: 1px solid #e2e8f0;
        }

        .modal-title {
            font-size: 18px;
            font-weight: 800;
        }

        .btn-close {
            background: none;
            border: none;
            font-size: 20px;
            cursor: pointer;
            color: var(--text-muted);
        }

        .modal-form .form-group {
            margin-bottom: 14px;
        }

        .modal-form label {
            display: block;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            color: var(--text-muted);
            margin-bottom: 6px;
        }

        .modal-form input, .modal-form select {
            width: 100%;
            padding: 10px;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            font-size: 13px;
            outline: none;
        }

        .btn-confirm-booking {
            width: 100%;
            background: #000000;
            color: #ffffff;
            border: none;
            padding: 12px;
            border-radius: 8px;
            font-weight: 700;
            font-size: 14px;
            cursor: pointer;
            margin-top: 10px;
        }
    </style>
</head>
<body>

<!-- Top Navigation -->
<div class="navbar">
    <a href="catalog.jsp" class="brand">Drive<span>Eazy</span></a>
    <div class="nav-actions">
        <% if (userName != null) { %>
            <a href="my_bookings.jsp" class="nav-btn">📋 My Reservations</a>
            <a href="index.jsp" style="color: #ef4444; font-weight: 700; text-decoration: none; font-size: 14px;">Logout</a>
        <% } else { %>
            <a href="index.jsp" class="nav-btn">Login / Sign Up</a>
        <% } %>
    </div>
</div>

<!-- Search & Filter Banner -->
<div class="hero">
    <h1>Find Your Perfect Self-Drive Vehicle</h1>
    <p>Sanitized, well-maintained cars & bikes available for instant booking</p>

    <form action="catalog.jsp" method="GET" class="search-container">
        <input type="text" name="search" placeholder="Search by model or brand (e.g. City, Thar)..." value="<%= searchQuery != null ? searchQuery : "" %>">

        <select name="category">
            <option value="">All Categories</option>
            <option value="CAR" <%= "CAR".equals(categoryFilter) ? "selected" : "" %>>Cars</option>
            <option value="BIKE" <%= "BIKE".equals(categoryFilter) ? "selected" : "" %>>Bikes</option>
        </select>

        <select name="transmission">
            <option value="">All Transmission</option>
            <option value="MANUAL" <%= "MANUAL".equals(transmissionFilter) ? "selected" : "" %>>Manual</option>
            <option value="AUTOMATIC" <%= "AUTOMATIC".equals(transmissionFilter) ? "selected" : "" %>>Automatic</option>
        </select>

        <button type="submit" class="btn-search">Search Fleet</button>
    </form>
</div>

<!-- Fleet Display Grid -->
<div class="container">
    <div class="fleet-grid">
        <%
            try (Connection conn = DBConnection.getConnection()) {
                String sql = "SELECT * FROM vehicles WHERE status = 'AVAILABLE'";

                if (categoryFilter != null && !categoryFilter.isEmpty()) {
                    sql += " AND category = ?";
                }
                if (transmissionFilter != null && !transmissionFilter.isEmpty()) {
                    sql += " AND transmission = ?";
                }
                if (searchQuery != null && !searchQuery.trim().isEmpty()) {
                    sql += " AND (title LIKE ? OR brand LIKE ?)";
                }

                sql += " ORDER BY vehicle_id DESC";

                PreparedStatement stmt = conn.prepareStatement(sql);
                int paramIndex = 1;

                if (categoryFilter != null && !categoryFilter.isEmpty()) {
                    stmt.setString(paramIndex++, categoryFilter);
                }
                if (transmissionFilter != null && !transmissionFilter.isEmpty()) {
                    stmt.setString(paramIndex++, transmissionFilter);
                }
                if (searchQuery != null && !searchQuery.trim().isEmpty()) {
                    String q = "%" + searchQuery.trim() + "%";
                    stmt.setString(paramIndex++, q);
                    stmt.setString(paramIndex++, q);
                }

                ResultSet rs = stmt.executeQuery();
                boolean hasResults = false;

                while (rs.next()) {
                    hasResults = true;
                    int vId = rs.getInt("vehicle_id");
                    String title = rs.getString("title");
                    String brand = rs.getString("brand");
                    String category = rs.getString("category");
                    String transmission = rs.getString("transmission");
                    String fuelType = rs.getString("fuel_type");
                    double price = rs.getDouble("price_per_day");
                    String imagePath = rs.getString("image_path");
        %>
        <div class="vehicle-card">
            <div class="card-img-container">
                <span class="category-badge"><%= category %></span>
                <img src="<%= imagePath %>" alt="<%= title %>" onerror="this.src='https://via.placeholder.com/280x180?text=DriveEazy+Vehicle';">
            </div>
            <div class="card-body">
                <div class="card-title"><%= title %></div>
                <div class="card-brand"><%= brand %></div>

                <div class="spec-pills">
                    <% if (transmission != null) { %><span class="spec-pill">⚙️ <%= transmission %></span><% } %>
                    <% if (fuelType != null) { %><span class="spec-pill">⛽ <%= fuelType %></span><% } %>
                    <span class="spec-pill">🛡️ Zero Deposit</span>
                </div>

                <div class="pricing-section">
                    <div class="price-tag">₹<%= (int)price %> <span>/ day</span></div>
                    <% if (userName != null) { %>
                        <button class="btn-book" onclick="openBookingModal(<%= vId %>, '<%= title %>', <%= price %>)">Book Now</button>
                    <% } else { %>
                        <a href="index.jsp" class="btn-book" style="text-decoration:none;">Login to Book</a>
                    <% } %>
                </div>
            </div>
        </div>
        <%
                }
                if (!hasResults) {
        %>
            <div style="grid-column: 1 / -1; text-align: center; padding: 60px 20px; background: white; border-radius: 16px; border: 1px solid var(--card-border);">
                <h3>No Vehicles Available</h3>
                <p style="color: var(--text-muted); margin-top: 6px;">Try adjusting your search criteria or category filters.</p>
            </div>
        <%
                }
            } catch (Exception e) {
                out.println("<p style='color:red;'>Error loading fleet: " + e.getMessage() + "</p>");
            }
        %>
    </div>
</div>

<!-- Modal Dialog for Handover & Date Selection -->
<div class="modal-overlay" id="bookingModal">
    <div class="modal-card">
        <div class="modal-header">
            <div class="modal-title" id="modalVehicleTitle">Reserve Vehicle</div>
            <button class="btn-close" onclick="closeBookingModal()">&times;</button>
        </div>

        <form action="CreateBookingServlet" method="POST" class="modal-form">
            <input type="hidden" name="vehicleId" id="modalVehicleId">

            <div class="form-group">
                <label>Pickup Date</label>
                <input type="date" name="pickupDate" required>
            </div>

            <div class="form-group">
                <label>Return Date</label>
                <input type="date" name="returnDate" required>
            </div>

            <div class="form-group">
                <label>Handover Mode</label>
                <select name="deliveryType" required>
                    <option value="SELF_PICKUP">Self Pickup (DriveEazy Hub)</option>
                    <option value="DOORSTEP">Doorstep Delivery (+₹300)</option>
                </select>
            </div>

            <button type="submit" class="btn-confirm-booking">Confirm Reservation</button>
        </form>
    </div>
</div>

<script>
    function openBookingModal(vehicleId, title, price) {
        document.getElementById('modalVehicleId').value = vehicleId;
        document.getElementById('modalVehicleTitle').innerText = 'Reserve ' + title;
        document.getElementById('bookingModal').style.display = 'flex';
    }

    function closeBookingModal() {
        document.getElementById('bookingModal').style.display = 'none';
    }
</script>

</body>
</html>