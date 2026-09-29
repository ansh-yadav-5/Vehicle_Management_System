<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="example.DBConnection" %>
<%
    String userName = (String) session.getAttribute("userName");
    if (userName == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    // Filter Parameters from Search Header
    String filterPickup = request.getParameter("pickupDate");
    String filterReturn = request.getParameter("returnDate");
    String filterCategory = request.getParameter("category");
    String filterModel = request.getParameter("model");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>VMS - Rent Vehicles On Demand</title>
    <style>
        * { box-sizing: border-box; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; }
        body { background: #f3f3f3; margin: 0; padding: 0; color: #000; }

        /* Navbar */
        .navbar { background: #000000; color: #ffffff; padding: 15px 40px; display: flex; justify-content: space-between; align-items: center; }
        .navbar .logo { font-size: 24px; font-weight: bold; letter-spacing: -0.5px; }
        .navbar .nav-right { display: flex; align-items: center; gap: 20px; font-size: 14px; }
        .navbar a.nav-btn { color: #ffffff; text-decoration: none; font-weight: 600; padding: 8px 14px; border-radius: 6px; border: 1px solid rgba(255,255,255,0.3); transition: 0.2s; }
        .navbar a.nav-btn:hover { background: rgba(255,255,255,0.15); }
        .navbar a.logout { color: #ef4444; text-decoration: none; font-weight: bold; }

        /* Hero Search Section */
        .hero-section { background: #000000; color: white; padding: 40px 40px 60px 40px; }
        .hero-title { font-size: 36px; font-weight: 700; margin-bottom: 20px; }

        .search-card { background: #ffffff; padding: 25px; border-radius: 12px; box-shadow: 0 10px 30px rgba(0,0,0,0.15); display: flex; gap: 15px; flex-wrap: wrap; align-items: flex-end; color: #000; }
        .input-group { flex: 1; min-width: 180px; }
        .input-group label { display: block; font-size: 12px; font-weight: 700; text-transform: uppercase; margin-bottom: 6px; color: #555; }
        .input-group input, .input-group select { width: 100%; padding: 12px; border: 1px solid #ccc; border-radius: 8px; font-size: 14px; background: #f9f9f9; outline: none; }
        .input-group input:focus, .input-group select:focus { border-color: #000; background: #fff; }
        .search-btn { background: #000000; color: #ffffff; padding: 13px 25px; border: none; border-radius: 8px; font-weight: bold; font-size: 15px; cursor: pointer; transition: 0.2s; }
        .search-btn:hover { background: #222222; }

        /* Main Catalog Grid */
        .container { max-width: 1200px; margin: -30px auto 40px auto; padding: 0 20px; }

        .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 25px; }
        .card { background: #ffffff; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 15px rgba(0,0,0,0.06); transition: transform 0.2s, box-shadow 0.2s; border: 1px solid #eee; display: flex; flex-direction: column; justify-content: space-between; }
        .card:hover { transform: translateY(-4px); box-shadow: 0 8px 25px rgba(0,0,0,0.12); }
        .card-img { width: 100%; height: 190px; object-fit: cover; background: #e5e7eb; }
        .card-body { padding: 20px; display: flex; flex-direction: column; flex-grow: 1; }
        .vehicle-title { font-size: 20px; font-weight: 700; margin: 0 0 5px 0; }
        .vehicle-subtitle { color: #666; font-size: 14px; margin-bottom: 10px; }

        /* Vehicle Description Style */
        .vehicle-desc { font-size: 13px; color: #555555; line-height: 1.4; margin-bottom: 15px; flex-grow: 1; }

        .price-tag { font-size: 22px; font-weight: 800; color: #000; margin-bottom: 15px; }

        .calc-summary { background: #f8f8f8; padding: 12px; border-radius: 8px; margin-bottom: 15px; font-size: 13px; font-weight: 600; text-align: center; border: 1px solid #e5e5e5; }
        .btn-ride { width: 100%; padding: 12px; background: #000000; color: #ffffff; border: none; border-radius: 8px; font-size: 15px; font-weight: bold; cursor: pointer; }
        .btn-ride:hover { background: #222222; }

        /* Alerts */
        .alert { padding: 15px; border-radius: 8px; font-weight: bold; margin-bottom: 20px; }
        .alert-error { background: #fee2e2; color: #dc2626; }
        .alert-success { background: #dcfce7; color: #16a34a; }
    </style>
</head>
<body>

<!-- NAVBAR -->
<div class="navbar">
    <div class="logo">VMS <span style="font-weight: 300;">Drive</span></div>
    <div class="nav-right">
        <a href="my_bookings.jsp" class="nav-btn">My Bookings</a>
        <span>Welcome, <strong><%= userName %></strong></span>
        <a href="index.jsp" class="logout">Logout</a>
    </div>
</div>

<!-- HERO SEARCH SECTION -->
<div class="hero-section">
    <div class="hero-title">Rent rides on your terms</div>
    <form action="catalog.jsp" method="GET" class="search-card">
        <div class="input-group">
            <label>Pickup Date</label>
            <input type="date" name="pickupDate" id="globalPickup" value="<%= filterPickup != null ? filterPickup : "" %>" required>
        </div>
        <div class="input-group">
            <label>Return Date</label>
            <input type="date" name="returnDate" id="globalReturn" value="<%= filterReturn != null ? filterReturn : "" %>" required>
        </div>
        <div class="input-group">
            <label>Vehicle Type</label>
            <select name="category">
                <option value="">All Categories</option>
                <option value="CAR" <%= "CAR".equals(filterCategory) ? "selected" : "" %>>Cars</option>
                <option value="BIKE" <%= "BIKE".equals(filterCategory) ? "selected" : "" %>>Bikes</option>
            </select>
        </div>
        <div class="input-group">
            <label>Model / Brand</label>
            <input type="text" name="model" placeholder="e.g. Honda, BMW" value="<%= filterModel != null ? filterModel : "" %>">
        </div>
        <button type="submit" class="search-btn">Search Vehicles</button>
    </form>
</div>

<!-- MAIN CATALOG GRID -->
<div class="container">

    <%-- Alert Notifications --%>
    <%
        String error = (String) request.getAttribute("error");
        String message = (String) request.getAttribute("message");
        if (error != null) {
    %>
        <div class="alert alert-error"><%= error %></div>
    <% } else if (message != null) { %>
        <div class="alert alert-success"><%= message %></div>
    <% } %>

    <div class="grid">
        <%
            try (Connection conn = DBConnection.getConnection()) {
                StringBuilder sql = new StringBuilder("SELECT * FROM vehicles WHERE status = 'AVAILABLE'");

                boolean hasCategory = (filterCategory != null && !filterCategory.trim().isEmpty());
                boolean hasModel = (filterModel != null && !filterModel.trim().isEmpty());

                if (hasCategory) {
                    sql.append(" AND category = ?");
                }
                if (hasModel) {
                    sql.append(" AND (title LIKE ? OR brand LIKE ?)");
                }
                sql.append(" ORDER BY vehicle_id DESC");

                PreparedStatement stmt = conn.prepareStatement(sql.toString());
                int paramIndex = 1;

                if (hasCategory) {
                    stmt.setString(paramIndex++, filterCategory);
                }
                if (hasModel) {
                    stmt.setString(paramIndex++, "%" + filterModel.trim() + "%");
                    stmt.setString(paramIndex++, "%" + filterModel.trim() + "%");
                }

                ResultSet rs = stmt.executeQuery();
                boolean hasVehicles = false;

                while (rs.next()) {
                    hasVehicles = true;
                    int vId = rs.getInt("vehicle_id");
                    double price = rs.getDouble("price_per_day");
                    String description = rs.getString("description");
        %>
        <div class="card">
            <img src="<%= rs.getString("image_path") %>" class="card-img" alt="Vehicle Image" onerror="this.src='https://via.placeholder.com/320x190?text=VMS+Drive';">
            <div class="card-body">
                <h3 class="vehicle-title"><%= rs.getString("title") %></h3>
                <div class="vehicle-subtitle"><%= rs.getString("brand") %> • <%= rs.getString("category") %></div>

                <!-- DISPLAY VEHICLE DESCRIPTION -->
                <div class="vehicle-desc">
                    <%= (description != null && !description.trim().isEmpty()) ? description : "No description provided." %>
                </div>

                <div class="price-tag">₹<%= price %> <span style="font-size: 14px; font-weight: normal; color: #666;">/ day</span></div>

                <form action="BookVehicleServlet" method="POST">
                    <input type="hidden" name="vehicleId" value="<%= vId %>">
                    <input type="hidden" id="price_<%= vId %>" value="<%= price %>">

                    <input type="hidden" id="pickup_<%= vId %>" name="pickupDate" value="<%= filterPickup != null ? filterPickup : "" %>">
                    <input type="hidden" id="return_<%= vId %>" name="returnDate" value="<%= filterReturn != null ? filterReturn : "" %>">

                    <div class="calc-summary" id="summary_<%= vId %>">
                        <% if (filterPickup != null && filterReturn != null && !filterPickup.isEmpty() && !filterReturn.isEmpty()) { %>
                            Calculating fare...
                        <% } else { %>
                            Search dates above to calculate fare
                        <% } %>
                    </div>

                    <button type="submit" class="btn-ride">Reserve Vehicle</button>
                </form>
            </div>
        </div>
        <%
                }
                if (!hasVehicles) {
        %>
            <p style="grid-column: 1/-1; text-align: center; color: #666; font-size: 18px; padding: 40px;">No available vehicles matching your search criteria.</p>
        <%
                }
            } catch (Exception e) {
                out.println("<p>Error loading fleet: " + e.getMessage() + "</p>");
            }
        %>
    </div>
</div>

<script>
    // Sync header dates with vehicle cards & dynamically calculate fare
    function syncAndCalculate() {
        const globalPickup = document.getElementById("globalPickup").value;
        const globalReturn = document.getElementById("globalReturn").value;

        if (!globalPickup || !globalReturn) return;

        const pickupDate = new Date(globalPickup);
        const returnDate = new Date(globalReturn);
        const timeDiff = returnDate.getTime() - pickupDate.getTime();
        const totalDays = Math.ceil(timeDiff / (1000 * 3600 * 24));

        const cards = document.querySelectorAll('.card');
        cards.forEach(card => {
            const form = card.querySelector('form');
            if (!form) return;

            const vId = form.querySelector('input[name="vehicleId"]').value;
            const pricePerDay = parseFloat(document.getElementById('price_' + vId).value);
            const summaryDiv = document.getElementById('summary_' + vId);

            document.getElementById('pickup_' + vId).value = globalPickup;
            document.getElementById('return_' + vId).value = globalReturn;

            if (totalDays > 0) {
                const totalFare = totalDays * pricePerDay;
                summaryDiv.innerHTML = totalDays + " Day(s) • Estimated Total: ₹" + totalFare.toFixed(2);
                summaryDiv.style.color = "#000000";
            } else {
                summaryDiv.innerHTML = "Return date must be after Pickup date";
                summaryDiv.style.color = "#dc2626";
            }
        });
    }

    window.onload = syncAndCalculate;
</script>

</body>
</html>