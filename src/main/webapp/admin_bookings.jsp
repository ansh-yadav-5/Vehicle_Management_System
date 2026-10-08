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
    <title>DriveEazy Admin - Booking & Fleet Control</title>
    <style>
        * { box-sizing: border-box; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; }
        body { background: #f4f6f9; margin: 0; padding: 0; color: #111; }
        .navbar { background: #000; color: #fff; padding: 15px 40px; display: flex; justify-content: space-between; align-items: center; }
        .container { max-width: 1250px; margin: 30px auto; padding: 0 20px; }
        .table-card { background: #fff; border-radius: 10px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); border: 1px solid #e2e8f0; margin-bottom: 30px; overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; text-align: left; }
        th { background: #f8fafc; padding: 14px; font-size: 11px; text-transform: uppercase; color: #475569; border-bottom: 1px solid #e2e8f0; }
        td { padding: 12px 14px; border-bottom: 1px solid #e2e8f0; font-size: 13px; }
        .badge { padding: 4px 8px; border-radius: 12px; font-size: 10px; font-weight: bold; text-transform: uppercase; }
        .badge-approved { background: #dcfce7; color: #15803d; }
        .badge-pending { background: #fef3c7; color: #b45309; }
        .badge-rejected { background: #fee2e2; color: #b91c1c; }
        .btn-act { background: #000; color: #fff; border: none; padding: 4px 8px; border-radius: 4px; font-size: 11px; cursor: pointer; }
    </style>
</head>
<body>

<div class="navbar">
    <div style="font-size:20px; font-weight:bold;">DriveEazy <span style="font-weight:300;">Admin</span></div>
    <div>
        <a href="admin_dashboard.jsp" style="color:#fff; text-decoration:none; margin-right:15px;">Dashboard</a>
        <a href="LogoutServlet" style="color: #ef4444; font-weight: 700; text-decoration: none; font-size: 14px; margin-left: 15px;">Logout</a>
    </div>
</div>

<div class="container">
    <h2>1. Customer Reservations & KYC Verification</h2>
    <div class="table-card">
        <table>
            <thead>
                <tr>
                    <th>Booking ID</th>
                    <th>Customer</th>
                    <th>Vehicle</th>
                    <th>Dates</th>
                    <th>Delivery</th>
                    <th>Total</th>
                    <th>DL Number</th>
                    <th>KYC Doc</th>
                    <th>KYC Action</th>
                </tr>
            </thead>
            <tbody>
                <%
                    String bookingSql = "SELECT b.booking_id, u.name AS user_name, v.title AS vehicle_title, " +
                                        "b.pickup_date, b.return_date, b.delivery_type, b.total_price, " +
                                        "b.dl_number, b.kyc_document_path, b.kyc_status " +
                                        "FROM bookings b " +
                                        "JOIN users u ON b.user_id = u.user_id " +
                                        "JOIN vehicles v ON b.vehicle_id = v.vehicle_id " +
                                        "ORDER BY b.booking_id DESC";

                    try (Connection conn = DBConnection.getConnection();
                         PreparedStatement stmt = conn.prepareStatement(bookingSql);
                         ResultSet rs = stmt.executeQuery()) {

                        while (rs.next()) {
                            int bId = rs.getInt("booking_id");
                            String kycStatus = rs.getString("kyc_status");
                            String docPath = rs.getString("kyc_document_path");
                %>
                <tr>
                    <td><strong>#<%= bId %></strong></td>
                    <td><%= rs.getString("user_name") %></td>
                    <td><%= rs.getString("vehicle_title") %></td>
                    <td><%= rs.getString("pickup_date") %> to <%= rs.getString("return_date") %></td>
                    <td><%= rs.getString("delivery_type") %></td>
                    <td><strong>₹<%= String.format("%.2f", rs.getDouble("total_price")) %></strong></td>
                    <td><%= rs.getString("dl_number") != null ? rs.getString("dl_number") : "Not Uploaded" %></td>
                    <td>
                        <% if (docPath != null) { %>
                            <a href="<%= docPath %>" target="_blank" style="color:#2563eb; font-weight:bold;">View DL Doc</a>
                        <% } else { %>
                            <span style="color:#999;">None</span>
                        <% } %>
                    </td>
                    <td>
                        <form action="VerifyKYCServlet" method="POST" style="display:flex; gap:4px;">
                            <input type="hidden" name="bookingId" value="<%= bId %>">
                            <select name="kycStatus" style="font-size:11px; padding:2px;">
                                <option value="PENDING" <%= "PENDING".equalsIgnoreCase(kycStatus) ? "selected" : "" %>>PENDING</option>
                                <option value="APPROVED" <%= "APPROVED".equalsIgnoreCase(kycStatus) ? "selected" : "" %>>APPROVED</option>
                                <option value="REJECTED" <%= "REJECTED".equalsIgnoreCase(kycStatus) ? "selected" : "" %>>REJECTED</option>
                            </select>
                            <button type="submit" class="btn-act">Set</button>
                        </form>
                    </td>
                </tr>
                <%
                        }
                    } catch (Exception e) {
                        out.println("<tr><td colspan='9' style='color:red;'>Error: " + e.getMessage() + "</td></tr>");
                    }
                %>
            </tbody>
        </table>
    </div>
</div>

</body>
</html>