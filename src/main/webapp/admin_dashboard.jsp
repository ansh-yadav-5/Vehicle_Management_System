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
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Admin Dashboard - VMS Drive</title>
    <style>
        * { box-sizing: border-box; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; }
        body { background: #f4f6f9; margin: 0; padding: 0; color: #111; }

        /* Navbar */
        .navbar { background: #000000; color: #ffffff; padding: 15px 40px; display: flex; justify-content: space-between; align-items: center; }
        .navbar .logo { font-size: 22px; font-weight: bold; }
        .navbar .nav-right { display: flex; align-items: center; gap: 15px; }
        .navbar a.nav-btn { color: #ffffff; text-decoration: none; font-size: 13px; font-weight: 600; padding: 8px 14px; border-radius: 6px; border: 1px solid rgba(255,255,255,0.3); transition: 0.2s; }
        .navbar a.nav-btn:hover { background: rgba(255,255,255,0.15); }
        .navbar a.logout { color: #ef4444; font-weight: bold; text-decoration: none; font-size: 14px; }

        .container { max-width: 1100px; margin: 40px auto; padding: 0 20px; }
        .header-title { font-size: 28px; font-weight: 800; margin-bottom: 25px; }

        /* Action Bar */
        .action-bar { display: flex; gap: 15px; margin-bottom: 30px; flex-wrap: wrap; }
        .btn-link { background: #000000; color: #ffffff; text-decoration: none; padding: 12px 20px; border-radius: 8px; font-weight: bold; font-size: 14px; display: inline-flex; align-items: center; transition: 0.2s; }
        .btn-link:hover { background: #222222; }
        .btn-link-secondary { background: #ffffff; color: #000000; border: 1px solid #000000; }
        .btn-link-secondary:hover { background: #f0f0f0; }

        /* Form Card */
        .card { background: #ffffff; border-radius: 12px; padding: 30px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); border: 1px solid #e2e8f0; margin-bottom: 30px; }
        .card-title { font-size: 20px; font-weight: 700; margin-bottom: 20px; border-bottom: 2px solid #f1f5f9; padding-bottom: 10px; }

        .form-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 20px; }
        .form-group { display: flex; flex-direction: column; }
        .form-group label { font-size: 12px; font-weight: 700; text-transform: uppercase; margin-bottom: 8px; color: #475569; }
        .form-group input, .form-group select, .form-group textarea { padding: 10px 12px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px; outline: none; }
        .form-group input[type="file"] { padding: 8px; background: #f8fafc; cursor: pointer; }
        .form-group input:focus, .form-group select:focus, .form-group textarea:focus { border-color: #000; }

        .full-width { grid-column: 1 / -1; }
        .btn-submit { background: #000000; color: #ffffff; padding: 12px 25px; border: none; border-radius: 8px; font-weight: bold; font-size: 15px; cursor: pointer; transition: 0.2s; }
        .btn-submit:hover { background: #222222; }

        /* Alerts */
        .alert { padding: 15px; border-radius: 8px; font-weight: bold; margin-bottom: 25px; }
        .alert-error { background: #fee2e2; color: #dc2626; }
        .alert-success { background: #dcfce7; color: #16a34a; }
    </style>
</head>
<body>

<!-- NAVBAR -->
<div class="navbar">
    <div class="logo">VMS <span style="font-weight: 300;">Admin</span></div>
    <div class="nav-right">
        <a href="admin_bookings.jsp" class="nav-btn">Show Bookings & Fleet</a>
        <span>Welcome, <strong><%= userName %></strong></span>
        <a href="index.jsp" class="logout">Logout</a>
    </div>
</div>

<div class="container">

    <div class="header-title">Admin Management Control</div>

    <%-- Quick Action Navigation Bar --%>
    <div class="action-bar">
        <a href="admin_bookings.jsp" class="btn-link">📋 Show All Customer Bookings</a>
        <a href="admin_bookings.jsp" class="btn-link btn-link-secondary">🚘 Manage Fleet & Rates</a>
    </div>

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

    <!-- ADD VEHICLE FORM WITH FILE UPLOAD -->
    <div class="card">
        <div class="card-title">Add New Vehicle to Fleet</div>
        <form action="AddVehicleServlet" method="POST" enctype="multipart/form-data">
            <div class="form-grid">
                <div class="form-group">
                    <label>Vehicle Title / Name</label>
                    <input type="text" name="title" placeholder="e.g. Honda City" required>
                </div>
                <div class="form-group">
                    <label>Brand / Manufacturer</label>
                    <input type="text" name="brand" placeholder="e.g. Honda" required>
                </div>
                <div class="form-group">
                    <label>Category</label>
                    <select name="category" required>
                        <option value="CAR">Car</option>
                        <option value="BIKE">Bike</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Daily Rental Rate (₹)</label>
                    <input type="number" step="0.01" name="pricePerDay" placeholder="e.g. 2500" required>
                </div>

                <!-- FILE UPLOAD INPUT -->
                <div class="form-group full-width">
                    <label>Vehicle Image (JPG/PNG)</label>
                    <input type="file" name="imageFile" accept="image/*" required>
                </div>

                <div class="form-group full-width">
                    <label>Description</label>
                    <textarea name="description" rows="3" placeholder="Enter vehicle specifications, transmission type, seating capacity, features, etc."></textarea>
                </div>
                <div class="full-width">
                    <button type="submit" class="btn-submit">+ Add Vehicle to Fleet</button>
                </div>
            </div>
        </form>
    </div>

</div>

</body>
</html>