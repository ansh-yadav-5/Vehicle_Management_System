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

    String msg = request.getParameter("msg");
    String err = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Reservations - DriveEazy</title>
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

        /* Top Navigation Header */
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

        .nav-actions {
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .nav-btn {
            color: #ffffff;
            text-decoration: none;
            font-size: 14px;
            font-weight: 600;
            padding: 8px 16px;
            border-radius: 8px;
            border: 1px solid rgba(255,255,255,0.2);
            transition: all 0.2s ease;
        }

        .nav-btn:hover {
            background: rgba(255,255,255,0.1);
        }

        /* Dark Hero Banner */
        .hero {
            background: linear-gradient(180deg, #000000 0%, #0f172a 100%);
            color: #ffffff;
            padding: 40px 5% 60px 5%;
        }

        .hero h1 {
            font-size: 32px;
            font-weight: 800;
            margin-bottom: 6px;
        }

        .hero p {
            color: #94a3b8;
            font-size: 15px;
        }

        /* Reservation List Container */
        .container {
            max-width: 1000px;
            margin: -30px auto 0 auto;
            padding: 0 20px;
        }

        /* Notifications */
        .alert {
            padding: 14px 20px;
            border-radius: 10px;
            font-weight: 600;
            font-size: 14px;
            margin-bottom: 20px;
        }
        .alert-error { background: #fee2e2; color: #dc2626; border: 1px solid #fca5a5; }
        .alert-success { background: #dcfce7; color: #16a34a; border: 1px solid #86efac; }

        /* Booking Cards */
        .booking-card {
            background: #ffffff;
            border-radius: 16px;
            padding: 24px;
            margin-bottom: 24px;
            border: 1px solid var(--card-border);
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
            display: flex;
            flex-direction: column;
            gap: 16px;
        }

        .card-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            border-bottom: 1px solid #f1f5f9;
            padding-bottom: 16px;
            flex-wrap: wrap;
            gap: 10px;
        }

        .vehicle-info {
            display: flex;
            align-items: center;
            gap: 16px;
        }

        .vehicle-thumb {
            width: 80px;
            height: 60px;
            object-fit: cover;
            border-radius: 10px;
            background: #f1f5f9;
        }

        .vehicle-title {
            font-size: 20px;
            font-weight: 800;
            color: var(--text-dark);
        }

        .vehicle-sub {
            font-size: 13px;
            color: var(--text-muted);
            font-weight: 600;
        }

        /* Badges */
        .status-group {
            display: flex;
            gap: 8px;
            align-items: center;
        }

        .badge {
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .badge-approved { background: #dcfce7; color: #15803d; }
        .badge-pending { background: #fef3c7; color: #b45309; }
        .badge-under_review { background: #e0f2fe; color: #0369a1; }
        .badge-active { background: #dbeafe; color: #1d4ed8; }
        .badge-completed { background: #f1f5f9; color: #475569; }
        .badge-rejected { background: #fee2e2; color: #b91c1c; }

        /* Details Grid */
        .details-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
            gap: 15px;
            background: #f8fafc;
            padding: 16px;
            border-radius: 12px;
            border: 1px solid #f1f5f9;
        }

        .detail-item {
            display: flex;
            flex-direction: column;
        }

        .detail-label {
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            color: var(--text-muted);
            margin-bottom: 4px;
        }

        .detail-value {
            font-size: 14px;
            font-weight: 700;
            color: var(--text-dark);
        }

        /* Toolbar */
        .card-actions-bar {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
            align-items: center;
            border-top: 1px solid #f1f5f9;
            padding-top: 14px;
        }

        .btn-action {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 8px 14px;
            border-radius: 8px;
            font-size: 12px;
            font-weight: 700;
            border: none;
            cursor: pointer;
            text-decoration: none;
            transition: opacity 0.2s;
        }

        .btn-action:hover { opacity: 0.85; }

        .btn-pdf { background: #0f172a; color: #ffffff; }
        .btn-extend { background: #2563eb; color: #ffffff; }
        .btn-cancel { background: #dc2626; color: #ffffff; }

        /* KYC Form */
        .kyc-upload-box {
            background: #ffffff;
            border: 1px dashed #cbd5e1;
            border-radius: 12px;
            padding: 18px;
            margin-top: 5px;
        }

        .kyc-title {
            font-size: 14px;
            font-weight: 700;
            color: var(--text-dark);
            margin-bottom: 4px;
        }

        .kyc-sub {
            font-size: 12px;
            color: var(--text-muted);
            margin-bottom: 12px;
        }

        .kyc-form {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
            align-items: center;
        }

        .kyc-form input[type="text"] {
            padding: 10px 12px;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            font-size: 13px;
            outline: none;
            flex: 1;
            min-width: 180px;
        }

        .kyc-form input[type="file"] {
            font-size: 12px;
            cursor: pointer;
        }

        .btn-upload {
            background: #000000;
            color: #ffffff;
            border: none;
            padding: 10px 18px;
            border-radius: 8px;
            font-size: 13px;
            font-weight: 700;
            cursor: pointer;
            transition: background 0.2s;
        }

        .empty-state {
            background: #ffffff;
            border-radius: 16px;
            padding: 50px 20px;
            text-align: center;
            border: 1px solid var(--card-border);
        }

        .empty-state h3 { font-size: 20px; margin-bottom: 8px; }

        .btn-browse {
            display: inline-block;
            margin-top: 15px;
            background: #000000;
            color: #ffffff;
            text-decoration: none;
            padding: 12px 24px;
            border-radius: 10px;
            font-weight: 700;
            font-size: 14px;
        }
    </style>
</head>
<body>

<!-- Navbar -->
<div class="navbar">
    <a href="catalog.jsp" class="brand">Drive<span>Eazy</span></a>
    <div class="nav-actions">
        <a href="about.jsp" class="nav-btn">ℹ️ About Us</a>
        <a href="catalog.jsp" class="nav-btn">🚘 Book Another Vehicle</a>
        <a href="LogoutServlet" style="color: #ef4444; font-weight: 700; text-decoration: none; font-size: 14px;">Logout</a>
    </div>
</div>

<!-- Header -->
<div class="hero">
    <h1>My Reservations</h1>
    <p>Track booking status, upload DL documents, extend trips, and download PDF receipts</p>
</div>

<div class="container">

    <%-- Success/Error Alerts --%>
    <% if (msg != null && !msg.isEmpty()) { %>
        <div class="alert alert-success"><%= msg %></div>
    <% } %>
    <% if (err != null && !err.isEmpty()) { %>
        <div class="alert alert-error"><%= err %></div>
    <% } %>

    <%
        boolean hasBookings = false;
        String sql = "SELECT b.*, v.title, v.brand, v.image_path, v.category " +
                     "FROM bookings b " +
                     "JOIN vehicles v ON b.vehicle_id = v.vehicle_id " +
                     "WHERE b.user_id = ? ORDER BY b.booking_id DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                hasBookings = true;
                int bookingId = rs.getInt("booking_id");
                String kycStatus = rs.getString("kyc_status");
                if (kycStatus == null) kycStatus = "PENDING";

                String deliveryType = rs.getString("delivery_type");
                if (deliveryType == null) deliveryType = "SELF_PICKUP";

                int extendedDays = 0;
                try {
                    extendedDays = rs.getInt("extended_days");
                } catch (Exception ignored) {}
    %>
    <div class="booking-card">
        <div class="card-header">
            <div class="vehicle-info">
                <img src="<%= rs.getString("image_path") %>" class="vehicle-thumb" alt="Vehicle" onerror="this.src='https://via.placeholder.com/80x60?text=Vehicle';">
                <div>
                    <div class="vehicle-title"><%= rs.getString("title") %></div>
                    <div class="vehicle-sub"><%= rs.getString("brand") %> • <%= rs.getString("category") %></div>
                </div>
            </div>

            <div class="status-group">
                <span class="badge badge-<%= kycStatus.toLowerCase() %>">
                    KYC: <%= kycStatus.replace("_", " ") %>
                </span>
                <span class="badge badge-approved" style="background:#e0f2fe; color:#0369a1;">
                    Booking #<%= bookingId %>
                </span>
            </div>
        </div>

        <div class="details-grid">
            <div class="detail-item">
                <span class="detail-label">Pickup Date</span>
                <span class="detail-value"><%= rs.getString("pickup_date") %></span>
            </div>
            <div class="detail-item">
                <span class="detail-label">Return Date</span>
                <span class="detail-value"><%= rs.getString("return_date") %></span>
            </div>
            <div class="detail-item">
                <span class="detail-label">Duration</span>
                <span class="detail-value"><%= rs.getInt("total_days") %> Days <%= extendedDays > 0 ? "(+" + extendedDays + " Ext)" : "" %></span>
            </div>
            <div class="detail-item">
                <span class="detail-label">Handover Mode</span>
                <span class="detail-value"><%= "DOORSTEP".equalsIgnoreCase(deliveryType) ? "Doorstep Delivery" : "Self Pickup" %></span>
            </div>
            <div class="detail-item">
                <span class="detail-label">Total Amount</span>
                <span class="detail-value" style="color: #16a34a;">₹<%= String.format("%.2f", rs.getDouble("total_price")) %></span>
            </div>
        </div>

        <%-- KYC Upload Form (Shown only before approval) --%>
        <% if (!"APPROVED".equalsIgnoreCase(kycStatus) && !"ACTIVE".equalsIgnoreCase(kycStatus) && !"COMPLETED".equalsIgnoreCase(kycStatus) && !"REJECTED".equalsIgnoreCase(kycStatus)) { %>
        <div class="kyc-upload-box">
            <div class="kyc-title">📄 Verification Required for Vehicle Handover</div>
            <div class="kyc-sub">Please submit your Driving License details to get your reservation confirmed by DriveEazy.</div>

            <form action="UploadKYCServlet" method="POST" enctype="multipart/form-data" class="kyc-form">
                <input type="hidden" name="bookingId" value="<%= bookingId %>">
                <input type="text" name="dlNumber" placeholder="Enter Driving License Number" value="<%= rs.getString("dl_number") != null ? rs.getString("dl_number") : "" %>" required>
                <input type="file" name="kycDocument" accept="image/*" required>
                <button type="submit" class="btn-upload">Submit Document</button>
            </form>
        </div>
        <% } %>

        <%-- Action Controls Toolbar --%>
        <div class="card-actions-bar">
            <!-- 1. Download PDF Invoice -->
            <a href="GenerateInvoiceServlet?bookingId=<%= bookingId %>" class="btn-action btn-pdf">
                📄 Download Invoice PDF
            </a>

            <!-- 2. Extend Trip Form (Only for APPROVED or ACTIVE trips) -->
            <% if ("APPROVED".equalsIgnoreCase(kycStatus) || "ACTIVE".equalsIgnoreCase(kycStatus)) { %>
            <form action="ExtendTripServlet" method="POST" style="display:inline-flex; gap: 6px; align-items: center;">
                <input type="hidden" name="bookingId" value="<%= bookingId %>">
                <input type="number" name="extraDays" min="1" max="14" value="1" style="width: 55px; padding: 6px; border-radius: 6px; border: 1px solid #cbd5e1; font-weight:700;">
                <button type="submit" class="btn-action btn-extend">
                    ➕ Extend Trip
                </button>
            </form>
            <% } %>

            <!-- 3. Cancel Booking Button (VISIBLE ONLY BEFORE KYC IS APPROVED) -->
            <% if (!"APPROVED".equalsIgnoreCase(kycStatus) && !"ACTIVE".equalsIgnoreCase(kycStatus) && !"COMPLETED".equalsIgnoreCase(kycStatus) && !"REJECTED".equalsIgnoreCase(kycStatus)) { %>
            <form action="CancelBookingServlet" method="POST" style="display:inline;" onsubmit="return confirm('Are you sure you want to cancel this reservation?');">
                <input type="hidden" name="bookingId" value="<%= bookingId %>">
                <button type="submit" class="btn-action btn-cancel">
                    ✖ Cancel Booking
                </button>
            </form>
            <% } %>
        </div>
    </div>
    <%
            }

            if (!hasBookings) {
    %>
    <div class="empty-state">
        <h3>No Reservations Found</h3>
        <p style="color: #64748b;">You haven't booked any self-drive cars or bikes yet.</p>
        <a href="catalog.jsp" class="btn-browse">Explore DriveEazy Fleet</a>
    </div>
    <%
            }
        } catch (Exception e) {
            out.println("<p style='color:red;'>Error loading reservations: " + e.getMessage() + "</p>");
        }
    %>

</div>

</body>
</html>