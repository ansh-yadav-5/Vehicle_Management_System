<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="example.DBConnection" %>
<%
    String userName = (String) session.getAttribute("userName");
    Integer userId = (Integer) session.getAttribute("userId");

    if (userName == null || userId == null) {
        response.sendRedirect("index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>My Bookings - VMS Drive</title>
    <style>
        * { box-sizing: border-box; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; }
        body { background: #f3f3f3; margin: 0; padding: 0; color: #000; }

        /* Navbar */
        .navbar { background: #000000; color: #ffffff; padding: 15px 40px; display: flex; justify-content: space-between; align-items: center; }
        .navbar .logo { font-size: 24px; font-weight: bold; letter-spacing: -0.5px; }
        .navbar .nav-links a { color: #ffffff; text-decoration: none; margin-left: 20px; font-weight: 500; font-size: 14px; }
        .navbar .nav-links a.logout { color: #ef4444; font-weight: bold; }

        /* Container */
        .container { max-width: 1100px; margin: 40px auto; padding: 0 20px; }
        .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; }
        .page-title { font-size: 28px; font-weight: 700; margin: 0; }

        /* Table Design */
        .table-card { background: #ffffff; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.06); overflow: hidden; border: 1px solid #eee; }
        table { width: 100%; border-collapse: collapse; text-align: left; }
        th { background: #fafafa; padding: 16px 20px; font-size: 12px; font-weight: 700; text-transform: uppercase; color: #555; border-bottom: 1px solid #eee; }
        td { padding: 18px 20px; border-bottom: 1px solid #eee; font-size: 14px; vertical-align: middle; }
        tr:last-child td { border-bottom: none; }

        .vehicle-meta { font-weight: 700; font-size: 15px; color: #000; }
        .vehicle-sub { font-size: 12px; color: #666; margin-top: 2px; }

        /* Status Badges */
        .badge { padding: 6px 12px; border-radius: 20px; font-size: 12px; font-weight: 700; display: inline-block; text-transform: uppercase; }
        .badge-confirmed { background: #dcfce7; color: #15803d; }
        .badge-cancelled { background: #fee2e2; color: #b91c1c; }
        .badge-pending { background: #fef3c7; color: #b45309; }

        /* Action Button */
        .btn-cancel { background: #ffffff; color: #dc2626; border: 1px solid #dc2626; padding: 8px 14px; border-radius: 6px; font-weight: bold; font-size: 13px; cursor: pointer; transition: 0.2s; }
        .btn-cancel:hover { background: #dc2626; color: #ffffff; }

        /* Alerts */
        .alert { padding: 15px; border-radius: 8px; font-weight: bold; margin-bottom: 20px; }
        .alert-error { background: #fee2e2; color: #dc2626; }
        .alert-success { background: #dcfce7; color: #16a34a; }

        .empty-state { padding: 50px; text-align: center; color: #666; }
        .empty-state a { color: #000; font-weight: bold; text-decoration: underline; }
    </style>
</head>
<body>

<!-- NAVBAR -->
<div class="navbar">
    <div class="logo">VMS <span style="font-weight: 300;">Drive</span></div>
    <div class="nav-links">
        <a href="catalog.jsp">Explore Fleet</a>
        <a href="my_bookings.jsp" style="text-decoration: underline; font-weight: bold;">My Bookings</a>
        <a href="index.jsp" class="logout">Logout</a>
    </div>
</div>

<!-- MAIN CONTENT -->
<div class="container">

    <div class="page-header">
        <h1 class="page-title">My Trip Reservations</h1>
    </div>

    <%-- Notification Alerts --%>
    <%
        String error = (String) request.getAttribute("error");
        String message = (String) request.getAttribute("message");
        if (error != null) {
    %>
        <div class="alert alert-error"><%= error %></div>
    <% } else if (message != null) { %>
        <div class="alert alert-success"><%= message %></div>
    <% } %>

    <div class="table-card">
        <table>
            <thead>
                <tr>
                    <th>Booking ID</th>
                    <th>Vehicle Details</th>
                    <th>Pickup Date</th>
                    <th>Return Date</th>
                    <th>Duration</th>
                    <th>Total Fare</th>
                    <th>Status</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
                <%
                    String sql = "SELECT b.booking_id, b.pickup_date, b.return_date, b.total_days, b.total_price, b.booking_status, " +
                                 "v.title, v.brand, v.category " +
                                 "FROM bookings b " +
                                 "JOIN vehicles v ON b.vehicle_id = v.vehicle_id " +
                                 "WHERE b.user_id = ? " +
                                 "ORDER BY b.booking_id DESC";

                    try (Connection conn = DBConnection.getConnection();
                         PreparedStatement stmt = conn.prepareStatement(sql)) {

                        stmt.setInt(1, userId);
                        ResultSet rs = stmt.executeQuery();
                        boolean hasBookings = false;

                        while (rs.next()) {
                            hasBookings = true;
                            int bookingId = rs.getInt("booking_id");
                            String status = rs.getString("booking_status");
                %>
                <tr>
                    <td><strong>#<%= bookingId %></strong></td>
                    <td>
                        <div class="vehicle-meta"><%= rs.getString("title") %></div>
                        <div class="vehicle-sub"><%= rs.getString("brand") %> • <%= rs.getString("category") %></div>
                    </td>
                    <td><%= rs.getString("pickup_date") %></td>
                    <td><%= rs.getString("return_date") %></td>
                    <td><%= rs.getInt("total_days") %> Day(s)</td>
                    <td><strong>₹<%= String.format("%.2f", rs.getDouble("total_price")) %></strong></td>
                    <td>
                        <% if ("CONFIRMED".equalsIgnoreCase(status)) { %>
                            <span class="badge badge-confirmed">Confirmed</span>
                        <% } else if ("CANCELLED".equalsIgnoreCase(status)) { %>
                            <span class="badge badge-cancelled">Cancelled</span>
                        <% } else { %>
                            <span class="badge badge-pending"><%= status %></span>
                        <% } %>
                    </td>
                    <td>
                        <% if ("CONFIRMED".equalsIgnoreCase(status) || "PENDING".equalsIgnoreCase(status)) { %>
                            <form action="CancelBookingServlet" method="POST" onsubmit="return confirm('Are you sure you want to cancel booking #<%= bookingId %>?');" style="margin:0;">
                                <input type="hidden" name="bookingId" value="<%= bookingId %>">
                                <button type="submit" class="btn-cancel">Cancel</button>
                            </form>
                        <% } else { %>
                            <span style="color: #999; font-size: 13px;">N/A</span>
                        <% } %>
                    </td>
                </tr>
                <%
                        }
                        if (!hasBookings) {
                %>
                <tr>
                    <td colspan="8">
                        <div class="empty-state">
                            <p>You have no active or past bookings yet.</p>
                            <a href="catalog.jsp">Browse Available Vehicles</a>
                        </div>
                    </td>
                </tr>
                <%
                        }
                    } catch (Exception e) {
                        out.println("<tr><td colspan='8' style='color:red;'>Error fetching bookings: " + e.getMessage() + "</td></tr>");
                    }
                %>
            </tbody>
        </table>
    </div>
</div>

</body>
</html>