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
    <title>My Reservations - GoDrive</title>
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
        * { box-sizing: border-box; font-family: 'Plus Jakarta Sans', sans-serif; margin: 0; padding: 0; }
        body { background-color: var(--bg-gray); color: var(--text-dark); padding-bottom: 60px; }
        .navbar { background: #000000; color: #ffffff; padding: 16px 5%; display: flex; justify-content: space-between; align-items: center; position: sticky; top: 0; z-index: 100; }
        .navbar .brand { font-size: 24px; font-weight: 800; color: #ffffff; text-decoration: none; }
        .navbar .brand span { color: var(--accent); }
        .nav-actions { display: flex; align-items: center; gap: 15px; }
        .nav-btn { color: #ffffff; text-decoration: none; font-size: 14px; font-weight: 600; padding: 8px 16px; border-radius: 8px; border: 1px solid rgba(255,255,255,0.2); transition: all 0.2s; }
        .nav-btn:hover { background: rgba(255,255,255,0.1); }
        .hero { background: linear-gradient(180deg, #000000 0%, #0f172a 100%); color: #ffffff; padding: 40px 5% 60px 5%; }
        .hero h1 { font-size: 32px; font-weight: 800; margin-bottom: 6px; }
        .hero p { color: #94a3b8; font-size: 15px; }
        .container { max-width: 1000px; margin: -30px auto 0 auto; padding: 0 20px; }
        .alert { padding: 14px 20px; border-radius: 10px; font-weight: 600; font-size: 14px; margin-bottom: 20px; }
        .alert-error { background: #fee2e2; color: #dc2626; border: 1px solid #fca5a5; }
        .alert-success { background: #dcfce7; color: #16a34a; border: 1px solid #86efac; }
        .booking-card { background: #ffffff; border-radius: 16px; padding: 24px; margin-bottom: 24px; border: 1px solid var(--card-border); box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); display: flex; flex-direction: column; gap: 16px; }
        .card-header { display: flex; justify-content: space-between; align-items: flex-start; border-bottom: 1px solid #f1f5f9; padding-bottom: 16px; flex-wrap: wrap; gap: 10px; }
        .vehicle-info { display: flex; align-items: center; gap: 16px; }
        .vehicle-thumb { width: 80px; height: 60px; object-fit: cover; border-radius: 10px; background: #f1f5f9; }
        .vehicle-title { font-size: 20px; font-weight: 800; color: var(--text-dark); }
        .vehicle-sub { font-size: 13px; color: var(--text-muted); font-weight: 600; }
        .status-group { display: flex; gap: 8px; align-items: center; flex-wrap: wrap; }
        .badge { padding: 5px 12px; border-radius: 20px; font-size: 11px; font-weight: 800; text-transform: uppercase; }
        .badge-approved { background: #dcfce7; color: #15803d; }
        .badge-pending { background: #fef3c7; color: #b45309; }
        .badge-under_review { background: #e0f2fe; color: #0369a1; }
        .badge-active { background: #dbeafe; color: #1d4ed8; }
        .badge-completed { background: #f1f5f9; color: #475569; }
        .badge-paid { background: #dcfce7; color: #15803d; }
        .details-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(160px, 1fr)); gap: 15px; background: #f8fafc; padding: 16px; border-radius: 12px; border: 1px solid #f1f5f9; }
        .detail-item { display: flex; flex-direction: column; }
        .detail-label { font-size: 11px; font-weight: 700; text-transform: uppercase; color: var(--text-muted); margin-bottom: 4px; }
        .detail-value { font-size: 14px; font-weight: 700; color: var(--text-dark); }
        .card-actions-bar { display: flex; gap: 12px; flex-wrap: wrap; align-items: center; border-top: 1px solid #f1f5f9; padding-top: 14px; }
        .btn-action { display: inline-flex; align-items: center; gap: 6px; padding: 8px 14px; border-radius: 8px; font-size: 12px; font-weight: 700; border: none; cursor: pointer; text-decoration: none; }
        .btn-pdf { background: #0f172a; color: #ffffff; }
        .btn-pay { background: #2563eb; color: #ffffff; }
        .btn-receipt { background: #059669; color: #ffffff; }
        .btn-review { background: #eab308; color: #000000; }
        .kyc-upload-box { background: #ffffff; border: 1px dashed #cbd5e1; border-radius: 12px; padding: 18px; margin-top: 5px; }
        .kyc-title { font-size: 14px; font-weight: 700; color: var(--text-dark); margin-bottom: 4px; }
        .kyc-sub { font-size: 12px; color: var(--text-muted); margin-bottom: 12px; }
        .kyc-form { display: flex; gap: 12px; flex-wrap: wrap; align-items: center; }
        .kyc-form input[type="text"] { padding: 10px 12px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13px; flex: 1; min-width: 180px; outline: none; }
        .btn-upload { background: #000000; color: #ffffff; border: none; padding: 10px 18px; border-radius: 8px; font-size: 13px; font-weight: 700; cursor: pointer; }
        .modal-overlay { display: none; position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.7); z-index: 200; align-items: center; justify-content: center; padding: 20px; }
        .modal-card { background: #ffffff; border-radius: 20px; width: 100%; max-width: 440px; padding: 28px; box-shadow: 0 20px 25px rgba(0,0,0,0.2); }
        .star-rating-select { display: flex; gap: 8px; margin-bottom: 16px; font-size: 28px; cursor: pointer; }
        .star-rating-select span { color: #cbd5e1; }
        .star-rating-select span.selected { color: #f59e0b; }
        .empty-state { background: #ffffff; border-radius: 16px; padding: 50px 20px; text-align: center; border: 1px solid var(--card-border); }
        .btn-browse { display: inline-block; margin-top: 15px; background: #000000; color: #ffffff; text-decoration: none; padding: 12px 24px; border-radius: 10px; font-weight: 700; }
    </style>
</head>
<body>

<div class="navbar">
    <a href="catalog.jsp" class="brand">Go<span>Drive</span></a>
    <div class="nav-actions">
        <a href="about.jsp" class="nav-btn">ℹ️ About Us</a>
        <a href="catalog.jsp" class="nav-btn">🚘 Book Another Vehicle</a>
        <a href="LogoutServlet" style="color: #ef4444; font-weight: 700; text-decoration: none; font-size: 14px;">Logout</a>
    </div>
</div>

<div class="hero">
    <h1>My Reservations</h1>
    <p>Track booking status, upload DL documents, complete UPI payments, and review vehicles</p>
</div>

<div class="container">

    <% if (msg != null && !msg.isEmpty()) { %>
    <div class="alert alert-success"><%= msg %></div>
    <% } %>
    <% if (err != null && !err.isEmpty()) { %>
    <div class="alert alert-error"><%= err %></div>
    <% } %>

    <%
        boolean hasBookings = false;
        String sql = "SELECT b.*, v.title, v.brand, v.image_path, v.category, " +
                "(SELECT COUNT(*) FROM reviews r WHERE r.booking_id = b.booking_id) AS has_reviewed " +
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
                String paymentStatus = rs.getString("payment_status");
                if (kycStatus == null) kycStatus = "PENDING";
                if (paymentStatus == null) paymentStatus = "PENDING";

                boolean hasReviewed = rs.getInt("has_reviewed") > 0;
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
                <span class="badge badge-<%= paymentStatus.toLowerCase() %>">
                    Payment: <%= paymentStatus %>
                </span>
                <span class="badge badge-<%= kycStatus.toLowerCase() %>">
                    KYC: <%= kycStatus.replace("_", " ") %>
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
                <span class="detail-value"><%= rs.getInt("total_days") %> Days</span>
            </div>
            <div class="detail-item">
                <span class="detail-label">Total Amount</span>
                <span class="detail-value" style="color: #16a34a;">₹<%= String.format("%.2f", rs.getDouble("total_price")) %></span>
            </div>
        </div>

        <% if (!"APPROVED".equalsIgnoreCase(kycStatus) && !"ACTIVE".equalsIgnoreCase(kycStatus) && !"COMPLETED".equalsIgnoreCase(kycStatus)) { %>
        <div class="kyc-upload-box">
            <div class="kyc-title">📄 Verification Required for Vehicle Handover</div>
            <div class="kyc-sub">Submit your Driving License details to get your reservation confirmed.</div>

            <form action="UploadKYCServlet" method="POST" enctype="multipart/form-data" class="kyc-form">
                <input type="hidden" name="bookingId" value="<%= bookingId %>">
                <input type="text" name="dlNumber" placeholder="Enter DL Number" value="<%= rs.getString("dl_number") != null ? rs.getString("dl_number") : "" %>" required>
                <input type="file" name="kycDocument" accept="image/*" required>
                <button type="submit" class="btn-upload">Submit Document</button>
            </form>
        </div>
        <% } %>

        <div class="card-actions-bar">
            <% if ("PENDING".equalsIgnoreCase(paymentStatus) || "REJECTED".equalsIgnoreCase(paymentStatus)) { %>
            <a href="payment.jsp?bookingId=<%= bookingId %>&amount=<%= rs.getDouble("total_price") %>" class="btn-action btn-pay">
                💳 Complete UPI Payment
            </a>
            <% } else if ("VERIFYING".equalsIgnoreCase(paymentStatus)) { %>
            <span style="font-size: 12px; font-weight: 700; color: #b45309; background: #fef3c7; padding: 6px 12px; border-radius: 8px;">
                ⏳ UTR Verification Pending
            </span>
            <% } else if ("PAID".equalsIgnoreCase(paymentStatus)) { %>
            <a href="GenerateReceiptServlet?bookingId=<%= bookingId %>" class="btn-action btn-receipt" target="_blank">
                🧾 Download Receipt
            </a>
            <% } %>

            <a href="GenerateInvoiceServlet?bookingId=<%= bookingId %>" class="btn-action btn-pdf">
                📄 Invoice PDF
            </a>

            <% if ("COMPLETED".equalsIgnoreCase(kycStatus)) { %>
            <% if (!hasReviewed) { %>
            <button class="btn-action btn-review" onclick="openReviewModal(<%= bookingId %>, '<%= rs.getString("title").replace("'", "\\'") %>')">
                ⭐ Rate Vehicle
            </button>
            <% } else { %>
            <span style="font-size: 12px; font-weight: 700; color: #16a34a; background: #dcfce7; padding: 6px 12px; border-radius: 8px;">
                    ✓ Reviewed
                </span>
            <% } %>
            <% } %>
        </div>
    </div>
    <%
        }

        if (!hasBookings) {
    %>
    <div class="empty-state">
        <h3>No Reservations Found</h3>
        <p style="color: #64748b;">You haven't booked any vehicles yet.</p>
        <a href="catalog.jsp" class="btn-browse">Explore GoDrive Fleet</a>
    </div>
    <%
            }
        } catch (Exception e) {
            out.println("<p style='color:red;'>Error loading reservations: " + e.getMessage() + "</p>");
        }
    %>

</div>

<!-- Rating Review Modal -->
<div id="reviewModal" class="modal-overlay">
    <div class="modal-card">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
            <h3 id="reviewModalTitle" style="font-size: 18px; font-weight: 800;">Rate Vehicle</h3>
            <button onclick="closeReviewModal()" style="background:none; border:none; font-size:20px; cursor:pointer;">&times;</button>
        </div>

        <form action="SubmitReviewServlet" method="POST">
            <input type="hidden" name="bookingId" id="reviewBookingId">
            <input type="hidden" name="rating" id="reviewRatingInput" value="5">

            <div style="margin-bottom: 12px; font-size: 11px; font-weight: 700; text-transform: uppercase; color: var(--text-muted);">
                Select Rating
            </div>

            <div class="star-rating-select" id="starRatingBox">
                <span onclick="setRating(1)">★</span>
                <span onclick="setRating(2)">★</span>
                <span onclick="setRating(3)">★</span>
                <span onclick="setRating(4)">★</span>
                <span onclick="setRating(5)" class="selected">★</span>
            </div>

            <div style="margin-bottom: 16px;">
                <label style="display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: var(--text-muted); margin-bottom: 6px;">Comments</label>
                <textarea name="reviewText" rows="3" placeholder="How was your experience?" style="width: 100%; padding: 10px; border-radius: 8px; border: 1px solid #cbd5e1; outline: none; font-size: 13px;"></textarea>
            </div>

            <button type="submit" class="btn-action btn-review" style="width: 100%; justify-content: center; padding: 12px; font-size: 14px;">
                Submit Rating
            </button>
        </form>
    </div>
</div>

<script>
    function openReviewModal(bookingId, vehicleTitle) {
        document.getElementById('reviewBookingId').value = bookingId;
        document.getElementById('reviewModalTitle').innerText = 'Rate ' + vehicleTitle;
        setRating(5);
        document.getElementById('reviewModal').style.display = 'flex';
    }

    function closeReviewModal() {
        document.getElementById('reviewModal').style.display = 'none';
    }

    function setRating(val) {
        document.getElementById('reviewRatingInput').value = val;
        const stars = document.querySelectorAll('#starRatingBox span');
        stars.forEach((s, idx) => {
            if (idx < val) s.classList.add('selected');
            else s.classList.remove('selected');
        });
    }
</script>

</body>
</html>