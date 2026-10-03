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
    <title>My Reservations - DriveEazy</title>
    <style>
        * { box-sizing: border-box; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; }
        body { background: #f3f4f6; margin: 0; padding: 0; color: #111; }
        .navbar { background: #000; color: #fff; padding: 15px 40px; display: flex; justify-content: space-between; align-items: center; }
        .container { max-width: 1100px; margin: 30px auto; padding: 0 20px; }
        .card { background: #fff; border-radius: 12px; padding: 20px; margin-bottom: 20px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); border: 1px solid #e5e7eb; }
        .badge { padding: 4px 8px; border-radius: 6px; font-size: 11px; font-weight: bold; }
        .badge-approved { background: #dcfce7; color: #15803d; }
        .badge-pending { background: #fef3c7; color: #b45309; }
        .kyc-box { background: #f9fafb; padding: 15px; border-radius: 8px; margin-top: 15px; border: 1px dashed #cbd5e1; }
    </style>
</head>
<body>

<div class="navbar">
    <div style="font-size: 22px; font-weight: bold;">DriveEazy</div>
    <div>
        <a href="catalog.jsp" style="color: #fff; text-decoration: none; margin-right: 15px;">Book Vehicle</a>
        <a href="index.jsp" style="color: #ef4444; text-decoration: none; font-weight: bold;">Logout</a>
    </div>
</div>

<div class="container">
    <h2>My Vehicle Reservations</h2>

    <%
        String sql = "SELECT b.*, v.title, v.brand, v.image_path FROM bookings b " +
                     "JOIN vehicles v ON b.vehicle_id = v.vehicle_id " +
                     "WHERE b.user_id = ? ORDER BY b.booking_id DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                int bookingId = rs.getInt("booking_id");
                String kycStatus = rs.getString("kyc_status");
    %>
    <div class="card">
        <div style="display: flex; justify-content: space-between; align-items: center;">
            <h3><%= rs.getString("title") %> (<%= rs.getString("brand") %>)</h3>
            <span class="badge <%= "APPROVED".equalsIgnoreCase(kycStatus) ? "badge-approved" : "badge-pending" %>">
                KYC: <%= kycStatus != null ? kycStatus : "PENDING" %>
            </span>
        </div>
        <p><strong>Dates:</strong> <%= rs.getString("pickup_date") %> to <%= rs.getString("return_date") %> (<%= rs.getInt("total_days") %> Days)</p>
        <p><strong>Total Paid:</strong> ₹<%= rs.getDouble("total_price") %></p>

        <% if (!"APPROVED".equalsIgnoreCase(kycStatus)) { %>
        <div class="kyc-box">
            <h4 style="margin-top:0;">Upload Driving License for Instant Handover Verification</h4>
            <form action="UploadKYCServlet" method="POST" enctype="multipart/form-data" style="display:flex; gap:10px; flex-wrap:wrap;">
                <input type="hidden" name="bookingId" value="<%= bookingId %>">
                <input type="text" name="dlNumber" placeholder="Enter DL Number" required style="padding:8px; border:1px solid #ccc; border-radius:6px;">
                <input type="file" name="kycDocument" accept="image/*" required style="padding:6px;">
                <button type="submit" style="background:#000; color:#fff; border:none; padding:8px 15px; border-radius:6px; font-weight:bold; cursor:pointer;">Submit KYC</button>
            </form>
        </div>
        <% } %>
    </div>
    <%
            }
        } catch (Exception e) {
            out.println("<p>Error loading reservations: " + e.getMessage() + "</p>");
        }
    %>
</div>

</body>
</html>