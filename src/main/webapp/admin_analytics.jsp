<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String adminUser = (String) session.getAttribute("adminUser");
    if (adminUser == null) {
        response.sendRedirect("admin_login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>GoDrive - Admin Analytics & Revenue Insights</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <!-- Chart.js Library -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
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

        /* Navbar */
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
        }

        .navbar .brand {
            font-size: 24px;
            font-weight: 800;
            color: #ffffff;
            text-decoration: none;
        }

        .navbar .brand span { color: var(--accent); }

        .nav-actions { display: flex; gap: 12px; }

        .nav-btn {
            color: #ffffff;
            text-decoration: none;
            font-size: 13px;
            font-weight: 700;
            padding: 8px 16px;
            border-radius: 8px;
            border: 1px solid rgba(255,255,255,0.2);
            transition: all 0.2s;
        }

        .nav-btn:hover { background: rgba(255,255,255,0.1); }

        /* Banner */
        .hero {
            background: linear-gradient(180deg, #000000 0%, #0f172a 100%);
            color: #ffffff;
            padding: 30px 5% 50px 5%;
        }

        .hero h1 { font-size: 28px; font-weight: 800; margin-bottom: 4px; }
        .hero p { color: #94a3b8; font-size: 14px; }

        /* Container */
        .container {
            max-width: 1240px;
            margin: -30px auto 0 auto;
            padding: 0 20px;
        }

        /* Summary Cards */
        .metrics-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .metric-card {
            background: #ffffff;
            border-radius: 16px;
            padding: 24px;
            border: 1px solid var(--card-border);
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.03);
        }

        .metric-label {
            font-size: 11px;
            font-weight: 800;
            text-transform: uppercase;
            color: var(--text-muted);
            letter-spacing: 0.5px;
            margin-bottom: 8px;
        }

        .metric-val {
            font-size: 26px;
            font-weight: 800;
            color: var(--text-dark);
        }

        .metric-sub {
            font-size: 12px;
            color: #16a34a;
            font-weight: 700;
            margin-top: 4px;
        }

        /* Charts Grid */
        .charts-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(500px, 1fr));
            gap: 24px;
            margin-bottom: 30px;
        }

        @media (max-width: 768px) {
            .charts-grid { grid-template-columns: 1fr; }
        }

        .chart-card {
            background: #ffffff;
            border-radius: 16px;
            padding: 24px;
            border: 1px solid var(--card-border);
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.03);
        }

        .chart-header {
            font-size: 16px;
            font-weight: 800;
            color: var(--text-dark);
            margin-bottom: 18px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        /* Tables Grid */
        .tables-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(500px, 1fr));
            gap: 24px;
        }

        @media (max-width: 768px) {
            .tables-grid { grid-template-columns: 1fr; }
        }

        .data-table-card {
            background: #ffffff;
            border-radius: 16px;
            padding: 24px;
            border: 1px solid var(--card-border);
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.03);
        }

        .data-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 12px;
        }

        .data-table th {
            text-align: left;
            font-size: 11px;
            font-weight: 800;
            text-transform: uppercase;
            color: var(--text-muted);
            padding: 10px;
            border-bottom: 2px solid #f1f5f9;
        }

        .data-table td {
            padding: 12px 10px;
            font-size: 13px;
            font-weight: 600;
            color: var(--text-dark);
            border-bottom: 1px solid #f8fafc;
        }

        .badge-rank {
            display: inline-block;
            width: 24px;
            height: 24px;
            line-height: 24px;
            text-align: center;
            border-radius: 50%;
            background: #f1f5f9;
            font-weight: 800;
            font-size: 11px;
        }
    </style>
</head>
<body>

<!-- Navbar -->
<div class="navbar">
    <a href="admin_dashboard.jsp" class="brand">Go<span>Drive</span> Admin</a>
    <div class="nav-actions">
        <a href="admin_dashboard.jsp" class="nav-btn">🚘 Fleet & Bookings</a>
        <a href="LogoutServlet" style="color: #ef4444; font-weight: 700; text-decoration: none; font-size: 13px;">Logout</a>
    </div>
</div>

<div class="hero">
    <h1>Revenue & Fleet Analytics</h1>
    <p>Real-time insights on financial growth, vehicle utilization, and high-value customers</p>
</div>

<div class="container">

    <!-- Metrics Row -->
    <div class="metrics-row">
        <div class="metric-card">
            <div class="metric-label">Total Revenue Generated</div>
            <div class="metric-val" id="totalRevVal">₹0.00</div>
            <div class="metric-sub">✓ Lifetime Gross Earnings</div>
        </div>

        <div class="metric-card">
            <div class="metric-label">Last 30 Days Revenue</div>
            <div class="metric-val" id="monthlyRevVal">₹0.00</div>
            <div class="metric-sub">📈 Current Month Trailing</div>
        </div>

        <div class="metric-card">
            <div class="metric-label">Last 7 Days Revenue</div>
            <div class="metric-val" id="weeklyRevVal">₹0.00</div>
            <div class="metric-sub">⚡ Weekly Sales Velocity</div>
        </div>

        <div class="metric-card">
            <div class="metric-label">Fleet Occupancy Rate</div>
            <div class="metric-val" id="occupancyVal">0%</div>
            <div class="metric-sub" id="fleetRatioSub">0 of 0 Vehicles On Road</div>
        </div>
    </div>

    <!-- Graphical Reports Section -->
    <div class="charts-grid">
        <!-- 1. Daily & Monthly Revenue Line/Bar Chart -->
        <div class="chart-card">
            <div class="chart-header">
                <span>Revenue Performance Trend</span>
            </div>
            <canvas id="revenueTrendChart" height="220"></canvas>
        </div>

        <!-- 2. Cars vs Bikes & Idle Ratio Pie/Doughnut Chart -->
        <div class="chart-card">
            <div class="chart-header">
                <span>Fleet Category & Availability Split</span>
            </div>
            <canvas id="fleetSplitChart" height="220"></canvas>
        </div>
    </div>

    <!-- Analytics Tables Grid -->
    <div class="tables-grid">
        <!-- Top 5 Rented Models -->
        <div class="data-table-card">
            <div class="chart-header">
                <span>Top 5 Most Rented Vehicle Models</span>
            </div>
            <table class="data-table">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Vehicle Model</th>
                        <th>Brand</th>
                        <th>Trips</th>
                        <th>Revenue</th>
                    </tr>
                </thead>
                <tbody id="topVehiclesBody">
                    <tr><td colspan="5" style="text-align:center; color:#94a3b8;">Loading vehicle performance data...</td></tr>
                </tbody>
            </table>
        </div>

        <!-- Customer Lifetime Value Leaderboard -->
        <div class="data-table-card">
            <div class="chart-header">
                <span>Customer Lifetime Value (LTV) Leaderboard</span>
            </div>
            <table class="data-table">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Customer Name</th>
                        <th>Email</th>
                        <th>Trips</th>
                        <th>LTV (Spend)</th>
                    </tr>
                </thead>
                <tbody id="ltvBody">
                    <tr><td colspan="5" style="text-align:center; color:#94a3b8;">Loading customer analytics...</td></tr>
                </tbody>
            </table>
        </div>
    </div>

</div>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        fetch('AdminAnalyticsServlet')
            .then(res => res.json())
            .then(data => {
                // Update top summary cards
                document.getElementById('totalRevVal').innerText = '₹' + data.totalRevenue.toLocaleString('en-IN', {minimumFractionDigits: 2});
                document.getElementById('monthlyRevVal').innerText = '₹' + data.monthlyRevenue.toLocaleString('en-IN', {minimumFractionDigits: 2});
                document.getElementById('weeklyRevVal').innerText = '₹' + data.weeklyRevenue.toLocaleString('en-IN', {minimumFractionDigits: 2});

                let occupancy = data.totalFleet > 0 ? Math.round((data.rentedFleet / data.totalFleet) * 100) : 0;
                document.getElementById('occupancyVal').innerText = occupancy + '%';
                document.getElementById('fleetRatioSub').innerText = data.rentedFleet + ' of ' + data.totalFleet + ' Vehicles Rented';

                // Render Chart 1: Daily Revenue Trend
                const revCtx = document.getElementById('revenueTrendChart').getContext('2d');
                const revLabels = data.dailyRevenue.map(d => d.label);
                const revValues = data.dailyRevenue.map(d => d.val);

                new Chart(revCtx, {
                    type: 'line',
                    data: {
                        labels: revLabels.length > 0 ? revLabels : ['No Data'],
                        datasets: [{
                            label: 'Daily Revenue (₹)',
                            data: revValues.length > 0 ? revValues : [0],
                            borderColor: '#22c55e',
                            backgroundColor: 'rgba(34, 197, 94, 0.1)',
                            fill: true,
                            tension: 0.3,
                            borderWidth: 3
                        }]
                    },
                    options: {
                        responsive: true,
                        plugins: { legend: { display: false } },
                        scales: { y: { beginAtZero: true } }
                    }
                });

                // Render Chart 2: Fleet Category Split
                const fleetCtx = document.getElementById('fleetSplitChart').getContext('2d');
                const catLabels = data.categoryBreakdown.map(c => c.category);
                const catCounts = data.categoryBreakdown.map(c => c.count);

                new Chart(fleetCtx, {
                    type: 'doughnut',
                    data: {
                        labels: catLabels.length > 0 ? catLabels : ['Available', 'Booked'],
                        datasets: [{
                            data: catCounts.length > 0 ? catCounts : [data.idleFleet, data.rentedFleet],
                            backgroundColor: ['#0f172a', '#22c55e', '#2563eb', '#f59e0b']
                        }]
                    },
                    options: {
                        responsive: true,
                        plugins: { legend: { position: 'bottom' } }
                    }
                });

                // Populate Top Vehicles Table
                let topVehiclesHtml = '';
                if (data.topVehicles && data.topVehicles.length > 0) {
                    data.topVehicles.forEach((v, idx) => {
                        topVehiclesHtml += `
                            <tr>
                                <td><span class="badge-rank">${idx + 1}</span></td>
                                <td>${v.title}</td>
                                <td>${v.brand}</td>
                                <td>${v.rentals}</td>
                                <td style="color:#16a34a; font-weight:800;">₹${v.revenue.toFixed(2)}</td>
                            </tr>`;
                    });
                } else {
                    topVehiclesHtml = '<tr><td colspan="5" style="text-align:center; color:#94a3b8;">No trip completed data yet.</td></tr>';
                }
                document.getElementById('topVehiclesBody').innerHTML = topVehiclesHtml;

                // Populate LTV Leaderboard Table
                let ltvHtml = '';
                if (data.customerLtv && data.customerLtv.length > 0) {
                    data.customerLtv.forEach((c, idx) => {
                        ltvHtml += `
                            <tr>
                                <td><span class="badge-rank">${idx + 1}</span></td>
                                <td>${c.name}</td>
                                <td style="color:#64748b;">${c.email}</td>
                                <td>${c.trips} Trips</td>
                                <td style="color:#16a34a; font-weight:800;">₹${c.ltv.toFixed(2)}</td>
                            </tr>`;
                    });
                } else {
                    ltvHtml = '<tr><td colspan="5" style="text-align:center; color:#94a3b8;">No customer spend data yet.</td></tr>';
                }
                document.getElementById('ltvBody').innerHTML = ltvHtml;

            })
            .catch(err => console.error("Analytics fetch error:", err));
    });
</script>

</body>
</html>