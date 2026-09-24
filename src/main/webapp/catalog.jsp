<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="example.DBConnection" %>
<%
    String userName = (String) session.getAttribute("userName");
    if (userName == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    String categoryFilter = request.getParameter("category");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Customer Vehicle Catalog</title>
    <style>
        * { box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { background: #f8fafc; margin: 0; padding: 20px; }
        .header { display: flex; justify-content: space-between; align-items: center; background: #0f172a; color: white; padding: 15px 30px; border-radius: 8px; margin-bottom: 25px; }
        .header h2 { margin: 0; }
        .logout-btn { color: #f87171; text-decoration: none; font-weight: bold; }

        .filter-bar { display: flex; gap: 15px; margin-bottom: 25px; background: white; padding: 15px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); }
        .filter-link { text-decoration: none; padding: 8px 16px; border-radius: 5px; background: #e2e8f0; color: #334155; font-weight: bold; }
        .filter-link.active { background: #2563eb; color: white; }

        .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 25px; }
        .card { background: white; border-radius: 10px; overflow: hidden; box-shadow: 0 4px 12px rgba(0,0,0,0.08); transition: transform 0.2s; }
        .card:hover { transform: translateY(-5px); }
        .card-img { width: 100%; height: 180px; object-fit: cover; background: #cbd5e1; }
        .card-body { padding: 20px; }
        .price { font-size: 20px; font-weight: bold; color: #16a34a; margin: 10px 0; }

        .form-group { margin-bottom: 12px; }
        label { display: block; font-size: 13px; font-weight: bold; color: #475569; margin-bottom: 4px; }
        input[type="date"] { width: 100%; padding: 8px; border: 1px solid #cbd5e1; border-radius: 5px; }

        .calc-summary { background: #f1f5f9; padding: 10px; border-radius: 5px; margin: 10px 0; font-size: 14px; font-weight: bold; color: #1e293b; }
        .btn-book { width: 100%; padding: 10px; background: #2563eb; color: white; border: none; border-radius: 5px; font-weight: bold; cursor: pointer; }
        .btn-book:hover { background: #1d4ed8; }

        .alert { padding: 12px; margin-bottom: 20px; border-radius: 6px; font-weight: bold; }
        .alert-error { background: #fee2e2; color: #dc2626; }
        .alert-success { background: #dcfce7; color: #16a34a; }
    </style>
</head>
<body>

<div class="header">
    <h2>Explore Available Fleet</h2>
    <div>
        <span>Welcome, <strong><%= userName %></strong></span> |
        <a href="index.jsp" class="logout-btn">Logout</a>
    </div>
</div>

<%-- Alert Messages --%>
<%
    String error = (String) request.getAttribute("error");
    String message = (String) request.getAttribute("message");
    if (error != null) {
%>
    <div class="alert alert-error"><%= error %></div>
<% } else if (message != null) { %>
    <div class="alert alert-success"><%= message %></div>
<% } %>

<!-- CATEGORY FILTER BAR -->
<div class="filter-bar">
    <a href="catalog.jsp" class="filter-link <%= (categoryFilter == null || categoryFilter.isEmpty()) ? "active" : "" %>">All Vehicles</a>
    <a href="catalog.jsp?category=CAR" class="filter-link <%= "CAR".equals(categoryFilter) ? "active" : "" %>">Cars</a>
    <a href="catalog.jsp?category=BIKE" class="filter-link <%= "BIKE".equals(categoryFilter) ? "active" : "" %>">Bikes</a>
</div>

<!-- VEHICLE GRID -->
<div class="grid">
    <%
        try (Connection conn = DBConnection.getConnection()) {
            String sql = "SELECT * FROM vehicles WHERE status = 'AVAILABLE'";
            if (categoryFilter != null && !categoryFilter.isEmpty()) {
                sql += " AND category = ?";
            }
            sql += " ORDER BY vehicle_id DESC";

            PreparedStatement stmt = conn.prepareStatement(sql);
            if (categoryFilter != null && !categoryFilter.isEmpty()) {
                stmt.setString(1, categoryFilter);
            }

            ResultSet rs = stmt.executeQuery();
            boolean found = false;

            while (rs.next()) {
                found = true;
                int vId = rs.getInt("vehicle_id");
                double price = rs.getDouble("price_per_day");
    %>
    <div class="card">
        <img src="<%= rs.getString("image_path") %>" class="card-img" alt="Vehicle Image" onerror="this.src='https://via.placeholder.com/300x180?text=No+Image';">
        <div class="card-body">
            <h3><%= rs.getString("title") %></h3>
            <p style="color: #64748b; font-size: 14px;"><%= rs.getString("brand") %> • <%= rs.getString("category") %></p>
            <div class="price">₹<%= price %> / day</div>
            <p style="font-size: 13px; color: #475569;"><%= rs.getString("description") %></p>

            <form action="VehicleCatalogServlet" method="POST">
                <input type="hidden" name="vehicleId" value="<%= vId %>">
                <input type="hidden" id="price_<%= vId %>" value="<%= price %>">

                <div class="form-group">
                    <label>Pickup Date</label>
                    <input type="date" id="pickup_<%= vId %>" name="pickupDate" required onchange="calculateFare(<%= vId %>)">
                </div>
                <div class="form-group">
                    <label>Return Date</label>
                    <input type="date" id="return_<%= vId %>" name="returnDate" required onchange="calculateFare(<%= vId %>)">
                </div>

                <div class="calc-summary" id="summary_<%= vId %>">Select dates to view fare</div>
                <button type="submit" class="btn-book">Book Now</button>
            </form>
        </div>
    </div>
    <%
            }
            if (!found) {
    %>
        <p style="grid-column: 1/-1; color: #64748b;">No available vehicles found for this category.</p>
    <%
            }
        } catch (Exception e) {
            out.println("<p>Error loading vehicles: " + e.getMessage() + "</p>");
        }
    %>
</div>

<script>
    function calculateFare(vId) {
        const pickupVal = document.getElementById("pickup_" + vId).value;
        const returnVal = document.getElementById("return_" + vId).value;
        const pricePerDay = parseFloat(document.getElementById("price_" + vId).value);
        const summaryDiv = document.getElementById("summary_" + vId);

        if (pickupVal && returnVal) {
            const pickup = new Date(pickupVal);
            const returnDate = new Date(returnVal);

            const timeDiff = returnDate.getTime() - pickup.getTime();
            const days = Math.ceil(timeDiff / (1000 * 3600 * 24));

            if (days > 0) {
                const totalFare = days * pricePerDay;
                summaryDiv.innerHTML = days + " Day(s) • Total: ₹" + totalFare.toFixed(2);
                summaryDiv.style.color = "#16a34a";
            } else {
                summaryDiv.innerHTML = "Return date must be after Pickup date!";
                summaryDiv.style.color = "#dc2626";
            }
        }
    }
</script>

</body>
</html>