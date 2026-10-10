<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String userName = (String) session.getAttribute("userName");
    Integer userId = (Integer) session.getAttribute("userId");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>About Us - DriveEazy</title>
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
            display: flex;
            flex-direction: column;
            min-height: 100vh;
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

        /* Hero Banner */
        .hero {
            background: linear-gradient(180deg, #000000 0%, #0f172a 100%);
            color: #ffffff;
            padding: 60px 5% 80px 5%;
            text-align: center;
        }

        .hero h1 {
            font-size: 38px;
            font-weight: 800;
            margin-bottom: 12px;
            letter-spacing: -0.5px;
        }

        .hero p {
            color: #94a3b8;
            font-size: 16px;
            max-width: 680px;
            margin: 0 auto;
            line-height: 1.6;
        }

        /* Main Wrapper Card */
        .main-wrapper {
            max-width: 1100px;
            margin: -40px auto 60px auto;
            padding: 40px;
            background: #ffffff;
            border-radius: 20px;
            border: 1px solid var(--card-border);
            box-shadow: 0 10px 25px -5px rgba(0,0,0,0.05);
        }

        /* Grid Sections */
        .section-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 32px;
            margin-bottom: 48px;
        }

        .grid-card {
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 16px;
            padding: 28px;
            transition: transform 0.2s ease, border-color 0.2s ease;
        }

        .grid-card:hover {
            transform: translateY(-4px);
            border-color: var(--accent);
        }

        .icon-box {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 48px;
            height: 48px;
            background: rgba(34, 197, 94, 0.15);
            color: var(--accent);
            border-radius: 12px;
            font-size: 22px;
            margin-bottom: 16px;
        }

        .card-title {
            font-size: 20px;
            font-weight: 800;
            color: var(--text-dark);
            margin-bottom: 10px;
        }

        .card-desc {
            font-size: 14px;
            color: var(--text-muted);
            line-height: 1.6;
        }

        /* Stats Counter Row */
        .stats-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            background: #000000;
            color: #ffffff;
            border-radius: 16px;
            padding: 36px 28px;
            text-align: center;
            margin-bottom: 48px;
        }

        .stat-item .number {
            font-size: 32px;
            font-weight: 800;
            color: var(--accent);
            margin-bottom: 4px;
        }

        .stat-item .label {
            font-size: 13px;
            color: #94a3b8;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        /* Call To Action Box */
        .cta-box {
            text-align: center;
            padding: 30px;
            background: linear-gradient(135deg, #0f172a 0%, #000000 100%);
            border-radius: 16px;
            color: #ffffff;
        }

        .cta-box h3 {
            font-size: 22px;
            font-weight: 800;
            margin-bottom: 10px;
        }

        .cta-box p {
            color: #94a3b8;
            font-size: 14px;
            margin-bottom: 20px;
        }

        .btn-cta {
            display: inline-block;
            background: var(--accent);
            color: #000000;
            text-decoration: none;
            padding: 12px 28px;
            border-radius: 10px;
            font-weight: 800;
            font-size: 14px;
            transition: opacity 0.2s ease;
        }

        .btn-cta:hover {
            opacity: 0.9;
        }

        /* Footer */
        .footer {
            margin-top: auto;
            background: #000000;
            color: #64748b;
            text-align: center;
            padding: 24px 5%;
            font-size: 13px;
            border-top: 1px solid rgba(255,255,255,0.1);
        }
    </style>
</head>
<body>

<!-- Navbar -->
<div class="navbar">
    <a href="catalog.jsp" class="brand">Drive<span>Eazy</span></a>
    <div class="nav-actions">
        <% if (userId != null) { %>
            <a href="catalog.jsp" class="nav-btn">🚘 Fleet Catalog</a>
            <a href="my_bookings.jsp" class="nav-btn">📋 My Reservations</a>
            <a href="LogoutServlet" style="color: #ef4444; font-weight: 700; text-decoration: none; font-size: 14px;">Logout</a>
        <% } else { %>
            <a href="index.jsp" class="nav-btn">Sign In / Register</a>
        <% } %>
    </div>
</div>

<!-- Dark Hero Header -->
<div class="hero">
    <h1>Redefining Self-Drive Mobility</h1>
    <p>DriveEazy gives you the freedom to explore roads with complete autonomy, transparent pricing, and instant online KYC verification.</p>
</div>

<!-- Main Wrapper -->
<div class="main-wrapper">

    <!-- Mission & Story Grid -->
    <div class="section-grid">
        <div class="grid-card">
            <div class="icon-box">🚀</div>
            <div class="card-title">Our Mission</div>
            <div class="card-desc">
                We eliminate traditional vehicle rental hassles by providing seamless self-drive car and bike access with zero hidden fees and instant automated dispatching.
            </div>
        </div>

        <div class="grid-card">
            <div class="icon-box">🛡️</div>
            <div class="card-title">Safety & Verification</div>
            <div class="card-desc">
                Every reservation undergoes digital License and KYC checks to ensure safety, full insurance coverage, and compliance before key handover.
            </div>
        </div>

        <div class="grid-card">
            <div class="icon-box">🚚</div>
            <div class="card-title">Flexible Delivery</div>
            <div class="card-desc">
                Choose between picking up your vehicle at our central Hub Centers or having it delivered directly to your doorstep for extra convenience.
            </div>
        </div>
    </div>

    <!-- Live Platform Statistics -->
    <div class="stats-row">
        <div class="stat-item">
            <div class="number">100+</div>
            <div class="label">Verified Vehicles</div>
        </div>
        <div class="stat-item">
            <div class="number">10,000+</div>
            <div class="label">Trips Completed</div>
        </div>
        <div class="stat-item">
            <div class="number">100%</div>
            <div class="label">Digital KYC</div>
        </div>
        <div class="stat-item">
            <div class="number">24/7</div>
            <div class="label">Roadside Support</div>
        </div>
    </div>

    <!-- Call To Action Box -->
    <div class="cta-box">
        <h3>Ready for Your Next Road Trip?</h3>
        <p>Browse our curated fleet of SUVs, sedans, hatchbacks, and bikes today.</p>
        <a href="catalog.jsp" class="btn-cta">Explore Available Fleet</a>
    </div>

</div>

<!-- Footer -->
<div class="footer">
    &copy; <%= java.time.Year.now().getValue() %> DriveEazy Self-Drive Rentals. All rights reserved.
</div>

</body>
</html>