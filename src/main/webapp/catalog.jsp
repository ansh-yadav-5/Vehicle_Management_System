<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.net.URLEncoder" %>
<%@ page import="example.DBConnection" %>
<%
    String userName = (String) session.getAttribute("userName");
    if (userName == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    String filterPickup = request.getParameter("pickupDate");
    String filterReturn = request.getParameter("returnDate");
    String filterCategory = request.getParameter("category");
    String filterModel = request.getParameter("model");
    String filterDelivery = request.getParameter("deliveryType");
    if (filterDelivery == null) filterDelivery = "SELF_PICKUP";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>DriveEazy Fleet - Rent Self-Drive Vehicles</title>
    <style>
        * { box-sizing: border-box; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; }
        body { background: #f3f4f6; margin: 0; padding: 0; color: #111; }

        .navbar { background: #000000; color: #ffffff; padding: 15px 40px; display: flex; justify-content: space-between; align-items: center; }
        .navbar .logo { font-size: 24px; font-weight: 800; }
        .navbar a.nav-btn { color: #ffffff; text-decoration: none; font-weight: 600; padding: 8px 14px; border-radius: 6px; border: 1px solid rgba(255,255,255,0.3); }

        .hero-section { background: #000000; color: white; padding: 40px 40px 60px 40px; }
        .hero-title { font-size: 32px; font-weight: 800; margin-bottom: 20px; }

        .search-card { background: #ffffff; padding: 25px; border-radius: 12px; display: flex; gap: 15px; flex-wrap: wrap; align-items: flex-end; color: #000; }
        .input-group { flex: 1; min-width: 160px; }
        .input-group label { display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; margin-bottom: 6px; color: #555; }
        .input-group input, .input-group select { width: 100%; padding: 10px; border: 1px solid #ccc; border-radius: 8px; font-size: 14px; }
        .search-btn { background: #000; color: #fff; padding: 11px 20px; border: none; border-radius: 8px; font-weight: bold; cursor: pointer; }

        .container { max-width: 1250px; margin: -30px auto 40px auto; padding: 0 20px; }
        .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(340px, 1fr)); gap: 25px; }

        .card { background: #ffffff; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 15px rgba(0,0,0,0.06); border: 1px solid #e5e7eb; display: flex; flex-direction: column; justify-content: space-between; }
        .card-img { width: 100%; height: 200px; object-fit: cover; background: #e5e7eb; }
        .card-body { padding: 20px; display: flex; flex-direction: column; flex-grow: 1; }

        .spec-tags { display: flex; gap: 8px; flex-wrap: wrap; margin: 10px 0; }
        .tag { background: #f3f4f6; color: #374151; font-size: 11px; font-weight: 700; padding: 4px 8px; border-radius: 6px; text-transform: uppercase; }

        .price-tag { font-size: 22px; font-weight: 800; color: #000; margin: 10px 0; }
        .deposit-info { font-size: 12px; color: #16a34a; font-weight: 600; margin-bottom: 12px; }

        .calc-summary { background: #f9fafb; padding: 12px; border-radius: 8px; margin-bottom: 12px; font-size: 13px; font-weight: 600; text-align: center; border: 1px solid #e5e7eb; }

        .btn-ride { width: 100%; padding: 12px; background: #000; color: #fff; border: none; border-radius: 8px; font-size: 14px; font-weight: bold; cursor: pointer; margin-bottom: 8px; }
        .btn-wa { width: 100%; padding: 10px; background: #25D366; color: #fff; text-decoration: none; text-align: center; border-radius: 8px; font-size: 13px; font-weight: bold; display: block; }
    </style>
</head>
<body>

<div class="navbar">
    <div class="logo">DriveEazy <span style="font-weight: 300;">Self-Drive</span></div>
    <div>
        <a href="my_bookings.jsp" class="nav-btn">My Bookings</a>
        <a href="index.jsp" style="color:#ef4444; margin-left: 15px; font-weight: bold; text-decoration:none;">Logout</a>
    </div>
</div>

<div class="hero-section">
    <div class="hero-title">Self-Drive Car & Bike Rentals</div>
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
            <label>Delivery Mode</label>
            <select name="deliveryType" id="globalDelivery" onchange="syncAndCalculate()">
                <option value="SELF_PICKUP" <%= "SELF_PICKUP".equals(filterDelivery) ? "selected" : "" %>>Self Pickup (Free)</option>
                <option value="DOORSTEP" <%= "DOORSTEP".equals(filterDelivery) ? "selected" : "" %>>Doorstep Delivery (+₹500)</option>
            </select>
        </div>
        <div class="input-group">
            <label>Vehicle Type</label>
            <select name="category">
                <option value="">All Categories</option>
                <option value="CAR" <%= "CAR".equals(filterCategory) ? "selected" : "" %>>Cars</option>
                <option value="BIKE" <%= "BIKE".equals(filterCategory) ? "selected" : "" %>>Bikes</option>
            </select>
        </div>
        <button type="submit" class="search-btn">Search Fleet</button>
    </form>
</div>

<div class="container">
    <div class="grid">
        <%
            try (Connection conn = DBConnection.getConnection()) {
                String sql = "SELECT * FROM vehicles WHERE status = 'AVAILABLE' ORDER BY vehicle_id DESC";
                PreparedStatement stmt = conn.prepareStatement(sql);
                ResultSet rs = stmt.executeQuery();

                while (rs.next()) {
                    int vId = rs.getInt("vehicle_id");
                    double price = rs.getDouble("price_per_day");
                    double deposit = rs.getDouble("security_deposit");
                    String title = rs.getString("title");

                    String waText = "Hi DriveEazy, I want to book " + title + " from " + (filterPickup != null ? filterPickup : "today") + " to " + (filterReturn != null ? filterReturn : "tomorrow");
                    String waUrl = "https://wa.me/919876543210?text=" + URLEncoder.encode(waText, "UTF-8");
        %>
        <div class="card">
            <img src="<%= rs.getString("image_path") %>" class="card-img" alt="Vehicle" onerror="this.src='https://via.placeholder.com/320x190?text=DriveEazy+Vehicle';">
            <div class="card-body">
                <h3 style="margin: 0 0 4px 0;"><%= title %></h3>
                <div style="color: #666; font-size: 13px;"><%= rs.getString("brand") %> • <%= rs.getString("category") %></div>

                <div class="spec-tags">
                    <span class="tag"><%= rs.getString("transmission") %></span>
                    <span class="tag"><%= rs.getString("fuel_type") %></span>
                    <span class="tag"><%= rs.getInt("seating_capacity") %> Seats</span>
                </div>

                <div style="font-size: 13px; color: #555; margin-bottom: 10px;">
                    <%= rs.getString("description") != null ? rs.getString("description") : "Well-maintained self-drive vehicle." %>
                </div>

                <div class="price-tag">₹<%= price %> <span style="font-size:13px; font-weight:normal; color:#666;">/ day</span></div>
                <div class="deposit-info">🛡️ Refundable Deposit: ₹<%= deposit %></div>

                <form action="BookVehicleServlet" method="POST">
                    <input type="hidden" name="vehicleId" value="<%= vId %>">
                    <input type="hidden" id="price_<%= vId %>" value="<%= price %>">
                    <input type="hidden" id="pickup_<%= vId %>" name="pickupDate" value="<%= filterPickup != null ? filterPickup : "" %>">
                    <input type="hidden" id="return_<%= vId %>" name="returnDate" value="<%= filterReturn != null ? filterReturn : "" %>">
                    <input type="hidden" id="delivery_<%= vId %>" name="deliveryType" value="<%= filterDelivery %>">

                    <div class="calc-summary" id="summary_<%= vId %>">Select dates to view fare breakdown</div>

                    <button type="submit" class="btn-ride">Reserve Vehicle</button>
                    <a href="<%= waUrl %>" target="_blank" class="btn-wa">📱 Quick Reserve via WhatsApp</a>
                </form>
            </div>
        </div>
        <%
                }
            } catch (Exception e) {
                out.println("<p>Error loading fleet: " + e.getMessage() + "</p>");
            }
        %>
    </div>
</div>

<script>
    function syncAndCalculate() {
        const pickup = document.getElementById("globalPickup").value;
        const returnD = document.getElementById("globalReturn").value;
        const delivery = document.getElementById("globalDelivery").value;

        if (!pickup || !returnD) return;

        const pDate = new Date(pickup);
        const rDate = new Date(returnD);
        const days = Math.ceil((rDate - pDate) / (1000 * 3600 * 24));
        const deliveryFee = (delivery === "DOORSTEP") ? 500 : 0;

        document.querySelectorAll('.card').forEach(card => {
            const form = card.querySelector('form');
            if (!form) return;

            const vId = form.querySelector('input[name="vehicleId"]').value;
            const price = parseFloat(document.getElementById('price_' + vId).value);
            const summary = document.getElementById('summary_' + vId);

            document.getElementById('pickup_' + vId).value = pickup;
            document.getElementById('return_' + vId).value = returnD;
            document.getElementById('delivery_' + vId).value = delivery;

            if (days > 0) {
                const total = (days * price) + deliveryFee;
                summary.innerHTML = days + " Day(s) • Base: ₹" + (days * price) + (deliveryFee > 0 ? " + Delivery: ₹500" : "") + "<br><strong>Total Payable: ₹" + total.toFixed(2) + "</strong>";
            } else {
                summary.innerHTML = "Return date must be after Pickup date";
            }
        });
    }

    window.onload = syncAndCalculate;
</script>

</body>
</html>