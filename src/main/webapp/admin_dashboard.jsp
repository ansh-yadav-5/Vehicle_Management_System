<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="example.DBConnection" %>
<%
    // Session Check for Admin Authorization
    String userRole = (String) session.getAttribute("userRole");
    if (userRole == null || !"ADMIN".equals(userRole)) {
        response.sendRedirect("index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Admin Dashboard - Vehicle Management System</title>
    <style>
        * { box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { background: #f1f5f9; margin: 0; padding: 20px; }
        .header { display: flex; justify-content: space-between; align-items: center; background: #1e293b; color: white; padding: 15px 25px; border-radius: 8px; margin-bottom: 25px; }
        .header h2 { margin: 0; }
        .logout-btn { color: #f87171; text-decoration: none; font-weight: bold; }

        .container { display: flex; gap: 20px; flex-wrap: wrap; }
        .card { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.08); }
        .form-card { flex: 1; min-width: 320px; }
        .list-card { flex: 2; min-width: 500px; }

        .form-group { margin-bottom: 15px; }
        label { display: block; font-weight: bold; margin-bottom: 5px; color: #334155; font-size: 14px; }
        input[type="text"], input[type="number"], select, textarea, input[type="file"] {
            width: 100%; padding: 10px; border: 1px solid #cbd5e1; border-radius: 5px; outline: none;
        }
        .btn { width: 100%; padding: 10px; background: #2563eb; color: white; border: none; border-radius: 5px; font-weight: bold; cursor: pointer; }
        .btn:hover { background: #1d4ed8; }

        table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #e2e8f0; font-size: 14px; }
        th { background: #f8fafc; color: #475569; }

        .badge { padding: 4px 8px; border-radius: 4px; font-size: 12px; font-weight: bold; }
        .badge-available { background: #dcfce7; color: #16a34a; }
        .badge-booked { background: #fee2e2; color: #dc2626; }

        .alert { padding: 10px; margin-bottom: 15px; border-radius: 5px; font-size: 14px; }
        .alert-error { background: #fee2e2; color: #dc2626; }
        .alert-success { background: #dcfce7; color: #16a34a; }
    </style>
</head>
<body>

<div class="header">
    <h2>Admin Management Dashboard</h2>
    <div>
        <span>Welcome, <strong><%= session.getAttribute("userName") %></strong></span> |
        <a href="index.jsp" class="logout-btn">Logout</a>
    </div>
</div>

<div class="container">
    <!-- ADD VEHICLE FORM -->
    <div class="card form-card">
        <h3>Add New Vehicle</h3>

        <%
            String error = (String) request.getAttribute("error");
            String message = (String) request.getAttribute("message");
            if (error != null) {
        %>
            <div class="alert alert-error"><%= error %></div>
        <% } else if (message != null) { %>
            <div class="alert alert-success"><%= message %></div>
        <% } %>

        <form action="AddVehicleServlet" method="POST" enctype="multipart/form-data">
            <div class="form-group">
                <label>Vehicle Title</label>
                <input type="text" name="title" required placeholder="e.g. Honda City / Royal Enfield">
            </div>
            <div class="form-group">
                <label>Brand</label>
                <input type="text" name="brand" required placeholder="e.g. Honda / Yamaha">
            </div>
            <div class="form-group">
                <label>Category</label>
                <select name="category" required>
                    <option value="CAR">Car</option>
                    <option value="BIKE">Bike</option>
                </select>
            </div>
            <div class="form-group">
                <label>Price Per Day (₹)</label>
                <input type="number" step="0.01" name="pricePerDay" required placeholder="1500.00">
            </div>
            <div class="form-group">
                <label>Vehicle Image</label>
                <input type="file" name="image" accept="image/*" required>
            </div>
            <div class="form-group">
                <label>Description</label>
                <textarea name="description" rows="3" placeholder="Enter vehicle details..."></textarea>
            </div>
            <button type="submit" class="btn">Add Vehicle</button>
        </form>
    </div>

    <!-- VEHICLE INVENTORY LIST -->
    <div class="card list-card">
        <h3>Vehicle Inventory</h3>
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Title</th>
                    <th>Category</th>
                    <th>Price/Day</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
                <%
                    try (Connection conn = DBConnection.getConnection()) {
                        String sql = "SELECT * FROM vehicles ORDER BY vehicle_id DESC";
                        Statement stmt = conn.createStatement();
                        ResultSet rs = stmt.executeQuery(sql);

                        boolean hasData = false;
                        while (rs.next()) {
                            hasData = true;
                            String status = rs.getString("status");
                            String badgeClass = "AVAILABLE".equals(status) ? "badge-available" : "badge-booked";
                %>
                <tr>
                    <td>#<%= rs.getInt("vehicle_id") %></td>
                    <td><strong><%= rs.getString("title") %></strong> (<%= rs.getString("brand") %>)</td>
                    <td><%= rs.getString("category") %></td>
                    <td>₹<%= rs.getDouble("price_per_day") %></td>
                    <td><span class="badge <%= badgeClass %>"><%= status %></span></td>
                </tr>
                <%
                        }
                        if (!hasData) {
                %>
                <tr>
                    <td colspan="5" style="text-align: center; color: #64748b;">No vehicles found in inventory.</td>
                </tr>
                <%
                        }
                    } catch (Exception e) {
                        out.println("<tr><td colspan='5'>Error fetching inventory: " + e.getMessage() + "</td></tr>");
                    }
                %>
            </tbody>
        </table>
    </div>
</div>

</body>
</html>