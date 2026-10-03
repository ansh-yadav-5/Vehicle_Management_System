<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="example.DBConnection" %>
<%
    String userName = (String) session.getAttribute("userName");
    String userRole = (String) session.getAttribute("userRole");

    if (userName == null || !"ADMIN".equalsIgnoreCase(userRole)) {
        response.sendRedirect("index.jsp");
        return;
    }

    String filterCategory = request.getParameter("category");
    String searchQuery = request.getParameter("search");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DriveEazy Admin Dashboard</title>
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

        /* DriveEazy Admin Navbar */
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

        .nav-right {
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .nav-btn {
            color: #ffffff;
            text-decoration: none;
            font-size: 13px;
            font-weight: 600;
            padding: 8px 16px;
            border-radius: 8px;
            border: 1px solid rgba(255,255,255,0.2);
            transition: all 0.2s ease;
        }

        .nav-btn:hover {
            background: rgba(255,255,255,0.1);
        }

        .logout-link {
            color: #ef4444;
            font-weight: 700;
            text-decoration: none;
            font-size: 14px;
        }

        /* Admin Hero Header */
        .admin-hero {
            background: linear-gradient(180deg, #000000 0%, #0f172a 100%);
            color: #ffffff;
            padding: 40px 5% 60px 5%;
        }

        .admin-hero h1 {
            font-size: 32px;
            font-weight: 800;
            margin-bottom: 8px;
        }

        .admin-hero p {
            color: #94a3b8;
            font-size: 15px;
        }

        /* KPI Metrics Cards */
        .container {
            max-width: 1350px;
            margin: -35px auto 0 auto;
            padding: 0 20px;
        }

        .metrics-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .metric-card {
            background: #ffffff;
            border-radius: 14px;
            padding: 20px;
            border: 1px solid var(--card-border);
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
        }

        .metric-title {
            font-size: 12px;
            font-weight: 700;
            text-transform: uppercase;
            color: var(--text-muted);
            margin-bottom: 6px;
        }

        .metric-value {
            font-size: 26px;
            font-weight: 800;
            color: var(--text-dark);
        }

        /* Alerts */
        .alert {
            padding: 14px 20px;
            border-radius: 10px;
            font-weight: 600;
            font-size: 14px;
            margin-bottom: 25px;
        }

        .alert-error { background: #fee2e2; color: #dc2626; border: 1px solid #fca5a5; }
        .alert-success { background: #dcfce7; color: #16a34a; border: 1px solid #86efac; }

        /* Dashboard Layout: Left Form + Right Table */
        .dashboard-layout {
            display: grid;
            grid-template-columns: 380px 1fr;
            gap: 25px;
            align-items: start;
        }

        @media (max-width: 1024px) {
            .dashboard-layout {
                grid-template-columns: 1fr;
            }
        }

        /* Card Container */
        .card {
            background: #ffffff;
            border-radius: 16px;
            padding: 24px;
            border: 1px solid var(--card-border);
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
        }

        .card-title {
            font-size: 18px;
            font-weight: 800;
            margin-bottom: 20px;
            padding-bottom: 12px;
            border-bottom: 1px solid var(--card-border);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        /* Form Inputs */
        .form-group {
            margin-bottom: 16px;
        }

        .form-group label {
            display: block;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            color: var(--text-muted);
            margin-bottom: 6px;
        }

        .form-group input, .form-group select, .form-group textarea {
            width: 100%;
            padding: 10px 12px;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            font-size: 13px;
            outline: none;
            background: #f8fafc;
            transition: border-color 0.2s;
        }

        .form-group input[type="file"] {
            padding: 7px;
            cursor: pointer;
        }

        .form-group input:focus, .form-group select:focus, .form-group textarea:focus {
            border-color: #000;
            background: #ffffff;
        }

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
        }

        .btn-submit {
            width: 100%;
            background: #000000;
            color: #ffffff;
            padding: 12px;
            border: none;
            border-radius: 8px;
            font-weight: 700;
            font-size: 14px;
            cursor: pointer;
            transition: background 0.2s;
            margin-top: 10px;
        }

        .btn-submit:hover {
            background: #1e293b;
        }

        /* Table Filter Bar */
        .filter-bar {
            display: flex;
            gap: 12px;
            margin-bottom: 16px;
        }

        .filter-bar input, .filter-bar select {
            padding: 8px 12px;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            font-size: 13px;
            outline: none;
        }

        /* Table Styling */
        .table-responsive {
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            text-align: left;
        }

        th {
            background: #f8fafc;
            padding: 12px 14px;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            color: var(--text-muted);
            border-bottom: 1px solid var(--card-border);
        }

        td {
            padding: 14px;
            border-bottom: 1px solid var(--card-border);
            font-size: 13px;
            vertical-align: middle;
        }

        .vehicle-thumb {
            width: 50px;
            height: 38px;
            object-fit: cover;
            border-radius: 6px;
            background: #e2e8f0;
        }

        .badge-status {
            padding: 4px 8px;
            border-radius: 20px;
            font-size: 10px;
            font-weight: 700;
            text-transform: uppercase;
        }

        .badge-available { background: #dcfce7; color: #15803d; }
        .badge-maintenance { background: #fee2e2; color: #b91c1c; }

        .btn-action {
            background: #000000;
            color: #ffffff;
            border: none;
            padding: 6px 10px;
            border-radius: 6px;
            font-size: 11px;
            font-weight: 700;
            cursor: pointer;
        }

        .btn-delete {
            background: #ef4444;
            color: #ffffff;
            border: none;
            padding: 6px 10px;
            border-radius: 6px;
            font-size: 11px;
            font-weight: 700;
            cursor: pointer;
            text-decoration: none;
        }
    </style>
</head>
<body>

<!-- Navbar -->
<div class="navbar">
    <a href="admin_dashboard.jsp" class="brand">Drive<span>Eazy</span> Admin</a>
    <div class="nav-right">
        <a href="admin_bookings.jsp" class="nav-btn">📋 Manage Customer Bookings</a>
        <a href="catalog.jsp" class="nav-btn" target="_blank">🌐 Live Catalog View</a>
        <a href="index.jsp" class="logout-link">Logout</a>
    </div>
</div>

<!-- Header -->
<div class="admin-hero">
    <h1>Fleet Management Console</h1>
    <p>Manage vehicle inventory, dynamic rental rates, and specifications</p>
</div>

<div class="container">

    <%-- Notifications --%>
    <%
        String error = (String) request.getAttribute("error");
        String message = (String) request.getAttribute("message");
        if (error != null) {
    %>
        <div class="alert alert-error"><%= error %></div>
    <% } else if (message != null) { %>
        <div class="alert alert-success"><%= message %></div>
    <% } %>

    <%
        // Fetch Live Fleet Stats
        int totalVehicles = 0;
        int availableVehicles = 0;
        double avgRate = 0.0;

        try (Connection conn = DBConnection.getConnection()) {
            String statsSql = "SELECT COUNT(*) AS total, SUM(CASE WHEN status = 'AVAILABLE' THEN 1 ELSE 0 END) AS available, AVG(price_per_day) AS avg_price FROM vehicles";
            Statement stmt = conn.createStatement();
            ResultSet rsStats = stmt.executeQuery(statsSql);
            if (rsStats.next()) {
                totalVehicles = rsStats.getInt("total");
                availableVehicles = rsStats.getInt("available");
                avgRate = rsStats.getDouble("avg_price");
            }
        } catch (Exception e) {
            // Log silently or display fallback
        }
    %>

    <!-- KPI Metrics -->
    <div class="metrics-grid">
        <div class="metric-card">
            <div class="metric-title">Total Vehicles</div>
            <div class="metric-value"><%= totalVehicles %></div>
        </div>
        <div class="metric-card">
            <div class="metric-title">Active Fleet Available</div>
            <div class="metric-value" style="color: #16a34a;"><%= availableVehicles %></div>
        </div>
        <div class="metric-card">
            <div class="metric-title">Avg Daily Rental</div>
            <div class="metric-value">₹<%= (int)avgRate %></div>
        </div>
    </div>

    <!-- Main Dashboard Grid -->
    <div class="dashboard-layout">

        <!-- Left Form: Add New Vehicle -->
        <div class="card">
            <div class="card-title">+ Add Vehicle to Fleet</div>
            <form action="AddVehicleServlet" method="POST" enctype="multipart/form-data">
                <div class="form-group">
                    <label>Vehicle Title</label>
                    <input type="text" name="title" placeholder="e.g. Honda City" required>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label>Brand</label>
                        <input type="text" name="brand" placeholder="e.g. Honda" required>
                    </div>
                    <div class="form-group">
                        <label>Category</label>
                        <select name="category" required>
                            <option value="CAR">Car</option>
                            <option value="BIKE">Bike</option>
                        </select>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label>Transmission</label>
                        <select name="transmission">
                            <option value="MANUAL">Manual</option>
                            <option value="AUTOMATIC">Automatic</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Fuel Type</label>
                        <select name="fuelType">
                            <option value="PETROL">Petrol</option>
                            <option value="DIESEL">Diesel</option>
                            <option value="EV">Electric</option>
                        </select>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label>Daily Price (₹)</label>
                        <input type="number" step="0.01" name="pricePerDay" placeholder="e.g. 2500" required>
                    </div>
                    <div class="form-group">
                        <label>Deposit (₹)</label>
                        <input type="number" step="0.01" name="securityDeposit" placeholder="e.g. 5000" value="5000">
                    </div>
                </div>

                <div class="form-group">
                    <label>Vehicle Image File</label>
                    <input type="file" name="imageFile" accept="image/*" required>
                </div>

                <div class="form-group">
                    <label>Short Description</label>
                    <textarea name="description" rows="2" placeholder="Seating capacity, features, transmission specs..."></textarea>
                </div>

                <button type="submit" class="btn-submit">Add Vehicle</button>
            </form>
        </div>

        <!-- Right Table: Fleet Directory & Operations -->
        <div class="card">
            <div class="card-title">
                <span>Fleet Inventory Directory</span>
                <form action="admin_dashboard.jsp" method="GET" class="filter-bar" style="margin:0;">
                    <select name="category" onchange="this.form.submit()">
                        <option value="">All Categories</option>
                        <option value="CAR" <%= "CAR".equals(filterCategory) ? "selected" : "" %>>Cars</option>
                        <option value="BIKE" <%= "BIKE".equals(filterCategory) ? "selected" : "" %>>Bikes</option>
                    </select>
                </form>
            </div>

            <div class="table-responsive">
                <table>
                    <thead>
                        <tr>
                            <th>Image</th>
                            <th>Vehicle</th>
                            <th>Category</th>
                            <th>Rate / Day</th>
                            <th>Status</th>
                            <th>Quick Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            try (Connection conn = DBConnection.getConnection()) {
                                String sql = "SELECT * FROM vehicles WHERE 1=1";
                                if (filterCategory != null && !filterCategory.isEmpty()) {
                                    sql += " AND category = ?";
                                }
                                sql += " ORDER BY vehicle_id DESC";

                                PreparedStatement stmt = conn.prepareStatement(sql);
                                if (filterCategory != null && !filterCategory.isEmpty()) {
                                    stmt.setString(1, filterCategory);
                                }

                                ResultSet rs = stmt.executeQuery();

                                while (rs.next()) {
                                    int vId = rs.getInt("vehicle_id");
                                    String status = rs.getString("status");
                                    double price = rs.getDouble("price_per_day");
                        %>
                        <tr>
                            <td>
                                <img src="<%= rs.getString("image_path") %>" class="vehicle-thumb" alt="Thumb" onerror="this.src='https://via.placeholder.com/50x38?text=Vehicle';">
                            </td>
                            <td>
                                <strong><%= rs.getString("title") %></strong><br>
                                <span style="font-size: 11px; color: #64748b;"><%= rs.getString("brand") %></span>
                            </td>
                            <td><%= rs.getString("category") %></td>
                            <td>
                                <form action="UpdateVehiclePriceServlet" method="POST" style="display:flex; gap:4px; align-items:center;">
                                    <input type="hidden" name="vehicleId" value="<%= vId %>">
                                    ₹<input type="number" step="0.01" name="newPrice" value="<%= price %>" style="width:70px; padding:4px; font-size:12px;">
                                    <button type="submit" class="btn-action">Save</button>
                                </form>
                            </td>
                            <td>
                                <form action="UpdateVehicleStatusServlet" method="POST">
                                    <input type="hidden" name="vehicleId" value="<%= vId %>">
                                    <select name="status" onchange="this.form.submit()" class="badge-status <%= "AVAILABLE".equalsIgnoreCase(status) ? "badge-available" : "badge-maintenance" %>" style="border:none; cursor:pointer;">
                                        <option value="AVAILABLE" <%= "AVAILABLE".equalsIgnoreCase(status) ? "selected" : "" %>>AVAILABLE</option>
                                        <option value="MAINTENANCE" <%= "MAINTENANCE".equalsIgnoreCase(status) ? "selected" : "" %>>MAINTENANCE</option>
                                    </select>
                                </form>
                            </td>
                            <td>
                                <a href="DeleteVehicleServlet?vehicleId=<%= vId %>" class="btn-delete" onclick="return confirm('Are you sure you want to remove this vehicle from fleet?');">Delete</a>
                            </td>
                        </tr>
                        <%
                                }
                            } catch (Exception e) {
                                out.println("<tr><td colspan='6' style='color:red;'>Error: " + e.getMessage() + "</td></tr>");
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>

    </div>

</div>

</body>
</html>