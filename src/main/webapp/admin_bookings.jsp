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
    <title>Admin Dashboard - Fleet & Reservations</title>
    <style>
        * { box-sizing: border-box; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; }
        body { background: #f4f6f9; margin: 0; padding: 0; color: #111; }

        /* Navbar */
        .navbar { background: #000000; color: #ffffff; padding: 15px 40px; display: flex; justify-content: space-between; align-items: center; }
        .navbar .logo { font-size: 22px; font-weight: bold; }
        .navbar .nav-links a { color: #ffffff; text-decoration: none; margin-left: 20px; font-size: 14px; font-weight: 500; }
        .navbar .nav-links a.logout { color: #ef4444; font-weight: bold; }

        .container { max-width: 1250px; margin: 30px auto; padding: 0 20px; }
        .section-header { font-size: 22px; font-weight: 800; margin-bottom: 15px; margin-top: 35px; border-left: 4px solid #000; padding-left: 10px; }

        /* Tables */
        .table-card { background: #ffffff; border-radius: 10px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); overflow: hidden; border: 1px solid #e2e8f0; margin-bottom: 30px; }
        table { width: 100%; border-collapse: collapse; text-align: left; }
        th { background: #f8fafc; padding: 14px 16px; font-size: 12px; font-weight: 700; text-transform: uppercase; color: #475569; border-bottom: 1px solid #e2e8f0; }
        td { padding: 14px 16px; border-bottom: 1px solid #e2e8f0; font-size: 13px; vertical-align: middle; }
        tr:last-child td { border-bottom: none; }

        /* Badges */
        .badge { padding: 4px 10px; border-radius: 12px; font-size: 11px; font-weight: 700; display: inline-block; text-transform: uppercase; }
        .badge-available { background: #dcfce7; color: #15803d; }
        .badge-booked { background: #dbeafe; color: #1d4ed8; }
        .badge-maintenance { background: #fef3c7; color: #b45309; }
        .badge-cancelled { background: #fee2e2; color: #b91c1c; }

        /* Inline Forms */
        .inline-form { display: flex; gap: 6px; align-items: center; margin: 0; }
        .inline-input { padding: 6px 8px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 13px; width: 90px; }
        .btn-action { background: #000; color: #fff; border: none; padding: 6px 12px; border-radius: 6px; font-size: 12px; font-weight: 600; cursor: pointer; }
        .btn-action:hover { background: #333; }
        .btn-danger { background: #dc2626; color: #fff; border: none; padding: 6px 12px; border-radius: 6px; font-size: 12px; font-weight: 600; cursor: pointer; }
        .btn-danger:hover { background: #b91c1c; }

        /* Alerts */
        .alert { padding: 12px 16px; border-radius: 8px; font-weight: bold; margin-bottom: 20px; font-size: 14px; }
        .alert-error { background: #fee2e2; color: #dc2626; }
        .alert-success { background: #dcfce7; color: #16a34a; }
    </style>
</head>
<body>

<div class="navbar">
    <div class="logo">VMS <span style="font-weight: 300;">Admin</span></div>
    <div class="nav-links">
        <a href="admin_dashboard.jsp">Dashboard Home</a>
        <a href="admin_bookings.jsp" style="text-decoration: underline; font-weight: bold;">Fleet & Bookings</a>
        <a href="index.jsp" class="logout">Logout</a>
    </div>
</div>

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

    <!-- SECTION 1: ALL CUSTOMER BOOKINGS -->
    <div class="section-header">1. Customer Reservations Oversight</div>
    <div class="table-card">
        <table>
            <thead>
                <tr>
                    <th>Booking ID</th>
                    <th>Customer Name</th>
                    <th>Vehicle</th>
                    <th>Pickup Date</th>
                    <th>Return Date</th>
                    <th>Total Days</th>
                    <th>Total Price</th>
                    <th>Booking Status</th>
                </tr>
            </thead>
            <tbody>
                <%
                    String bookingSql = "SELECT b.booking_id, u.name AS user_name, v.title AS vehicle_title, " +
                                        "b.pickup_date, b.return_date, b.total_days, b.total_price, b.booking_status " +
                                        "FROM bookings b " +
                                        "JOIN users u ON b.user_id = u.user_id " +
                                        "JOIN vehicles v ON b.vehicle_id = v.vehicle_id " +
                                        "ORDER BY b.booking_id DESC";

                    try (Connection conn = DBConnection.getConnection();
                         PreparedStatement stmt = conn.prepareStatement(bookingSql);
                         ResultSet rs = stmt.executeQuery()) {

                        boolean hasBookings = false;
                        while (rs.next()) {
                            hasBookings = true;
                            String bStatus = rs.getString("booking_status");
                %>
                <tr>
                    <td><strong>#<%= rs.getInt("booking_id") %></strong></td>
                    <td><%= rs.getString("user_name") %></td>
                    <td><%= rs.getString("vehicle_title") %></td>
                    <td><%= rs.getString("pickup_date") %></td>
                    <td><%= rs.getString("return_date") %></td>
                    <td><%= rs.getInt("total_days") %> Days</td>
                    <td><strong>₹<%= String.format("%.2f", rs.getDouble("total_price")) %></strong></td>
                    <td>
                        <% if ("CONFIRMED".equalsIgnoreCase(bStatus)) { %>
                            <span class="badge badge-booked">Confirmed</span>
                        <% } else if ("CANCELLED".equalsIgnoreCase(bStatus)) { %>
                            <span class="badge badge-cancelled">Cancelled</span>
                        <% } else { %>
                            <span class="badge badge-maintenance"><%= bStatus %></span>
                        <% } %>
                    </td>
                </tr>
                <%
                        }
                        if (!hasBookings) {
                %>
                <tr><td colspan="8" style="text-align:center; color:#666;">No bookings records found.</td></tr>
                <%
                        }
                    } catch (Exception e) {
                        out.println("<tr><td colspan='8' style='color:red;'>Error loading bookings: " + e.getMessage() + "</td></tr>");
                    }
                %>
            </tbody>
        </table>
    </div>

    <!-- SECTION 2: FLEET MANAGEMENT -->
    <div class="section-header">2. Vehicle Fleet & Rates Control</div>
    <div class="table-card">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Vehicle Title</th>
                    <th>Category</th>
                    <th>Rate/Day (₹)</th>
                    <th>Current Status</th>
                    <th>Update Status</th>
                    <th>Update Rate</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <%
                    String vehicleSql = "SELECT * FROM vehicles ORDER BY vehicle_id DESC";

                    try (Connection conn = DBConnection.getConnection();
                         PreparedStatement stmt = conn.prepareStatement(vehicleSql);
                         ResultSet rs = stmt.executeQuery()) {

                        boolean hasVehicles = false;
                        while (rs.next()) {
                            hasVehicles = true;
                            int vId = rs.getInt("vehicle_id");
                            String status = rs.getString("status");
                            double price = rs.getDouble("price_per_day");
                %>
                <tr>
                    <td><strong>#<%= vId %></strong></td>
                    <td><strong><%= rs.getString("title") %></strong><br><small style="color:#666;"><%= rs.getString("brand") %></small></td>
                    <td><%= rs.getString("category") %></td>
                    <td>₹<%= String.format("%.2f", price) %></td>
                    <td>
                        <% if ("AVAILABLE".equalsIgnoreCase(status)) { %>
                            <span class="badge badge-available">Available</span>
                        <% } else if ("BOOKED".equalsIgnoreCase(status)) { %>
                            <span class="badge badge-booked">Booked</span>
                        <% } else { %>
                            <span class="badge badge-maintenance">Maintenance</span>
                        <% } %>
                    </td>
                    <td>
                        <form action="UpdateVehicleStatusServlet" method="POST" class="inline-form">
                            <input type="hidden" name="vehicleId" value="<%= vId %>">
                            <select name="status" class="inline-input">
                                <option value="AVAILABLE" <%= "AVAILABLE".equalsIgnoreCase(status) ? "selected" : "" %>>AVAILABLE</option>
                                <option value="BOOKED" <%= "BOOKED".equalsIgnoreCase(status) ? "selected" : "" %>>BOOKED</option>
                                <option value="MAINTENANCE" <%= "MAINTENANCE".equalsIgnoreCase(status) ? "selected" : "" %>>MAINTENANCE</option>
                            </select>
                            <button type="submit" class="btn-action">Set</button>
                        </form>
                    </td>
                    <td>
                        <form action="UpdateVehiclePriceServlet" method="POST" class="inline-form">
                            <input type="hidden" name="vehicleId" value="<%= vId %>">
                            <input type="number" step="0.01" name="pricePerDay" value="<%= price %>" class="inline-input" required>
                            <button type="submit" class="btn-action">Save</button>
                        </form>
                    </td>
                    <td>
                        <form action="DeleteVehicleServlet" method="POST" onsubmit="return confirm('Delete vehicle #<%= vId %>?');" class="inline-form">
                            <input type="hidden" name="vehicleId" value="<%= vId %>">
                            <button type="submit" class="btn-danger">Delete</button>
                        </form>
                    </td>
                </tr>
                <%
                        }
                        if (!hasVehicles) {
                %>
                <tr><td colspan="8" style="text-align:center; color:#666;">No vehicles found in fleet.</td></tr>
                <%
                        }
                    } catch (Exception e) {
                        out.println("<tr><td colspan='8' style='color:red;'>Error loading fleet: " + e.getMessage() + "</td></tr>");
                    }
                %>
            </tbody>
        </table>
    </div>

</div>

</body>
</html>