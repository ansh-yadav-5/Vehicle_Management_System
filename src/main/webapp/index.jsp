<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String userName = (String) session.getAttribute("userName");
    String userRole = (String) session.getAttribute("userRole");

    // Auto-redirect if already logged in
    if (userName != null) {
        if ("ADMIN".equalsIgnoreCase(userRole)) {
            response.sendRedirect("admin_dashboard.jsp");
            return;
        } else {
            response.sendRedirect("catalog.jsp");
            return;
        }
    }

    String error = (String) request.getAttribute("error");
    String message = (String) request.getAttribute("message");
    String activeTab = request.getParameter("tab");
    if (activeTab == null) activeTab = "user-login";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DriveEazy - Self Drive Rentals | Login & Signup</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #0f172a;
            --accent: #22c55e;
            --bg-dark: #000000;
            --card-bg: #ffffff;
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
            background-color: var(--bg-dark);
            color: #ffffff;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        /* Top Bar */
        .navbar {
            background: #000000;
            padding: 20px 6%;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }

        .navbar .brand {
            font-size: 26px;
            font-weight: 800;
            color: #ffffff;
            text-decoration: none;
            letter-spacing: -0.5px;
        }

        .navbar .brand span {
            color: var(--accent);
            font-weight: 400;
        }

        .navbar .nav-link {
            color: #94a3b8;
            text-decoration: none;
            font-size: 14px;
            font-weight: 600;
            transition: color 0.2s;
        }

        .navbar .nav-link:hover {
            color: #ffffff;
        }

        /* Main Container */
        .auth-wrapper {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 40px 20px;
            background: radial-gradient(circle at top, #1e293b 0%, #000000 70%);
        }

        .auth-container {
            width: 100%;
            max-width: 440px;
            background: #ffffff;
            color: var(--text-dark);
            border-radius: 20px;
            padding: 36px 32px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
            border: 1px solid rgba(255, 255, 255, 0.2);
        }

        .auth-header {
            text-align: center;
            margin-bottom: 28px;
        }

        .auth-header h1 {
            font-size: 26px;
            font-weight: 800;
            color: var(--text-dark);
            margin-bottom: 6px;
        }

        .auth-header p {
            font-size: 14px;
            color: var(--text-muted);
        }

        /* Segmented Tab Switcher */
        .auth-tabs {
            display: flex;
            background: #f1f5f9;
            padding: 4px;
            border-radius: 12px;
            margin-bottom: 24px;
            gap: 4px;
        }

        .tab-btn {
            flex: 1;
            padding: 10px;
            border: none;
            background: transparent;
            font-size: 12px;
            font-weight: 700;
            color: var(--text-muted);
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.2s;
            text-align: center;
        }

        .tab-btn.active {
            background: #000000;
            color: #ffffff;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        /* Alerts */
        .alert {
            padding: 12px 16px;
            border-radius: 10px;
            font-size: 13px;
            font-weight: 600;
            margin-bottom: 20px;
        }
        .alert-error { background: #fee2e2; color: #dc2626; border: 1px solid #fca5a5; }
        .alert-success { background: #dcfce7; color: #16a34a; border: 1px solid #86efac; }

        /* Form Controls */
        .form-panel {
            display: none;
        }

        .form-panel.active {
            display: block;
        }

        .form-group {
            margin-bottom: 18px;
        }

        .form-group label {
            display: block;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            color: var(--text-muted);
            margin-bottom: 6px;
            letter-spacing: 0.5px;
        }

        .form-group input {
            width: 100%;
            padding: 12px 14px;
            border: 1px solid #cbd5e1;
            border-radius: 10px;
            font-size: 14px;
            outline: none;
            background: #f8fafc;
            color: var(--text-dark);
            transition: border-color 0.2s, background 0.2s;
        }

        .form-group input:focus {
            border-color: #000000;
            background: #ffffff;
        }

        .btn-submit {
            width: 100%;
            background: #000000;
            color: #ffffff;
            padding: 14px;
            border: none;
            border-radius: 10px;
            font-weight: 700;
            font-size: 14px;
            cursor: pointer;
            transition: background 0.2s, transform 0.1s;
            margin-top: 8px;
        }

        .btn-submit:hover {
            background: #1e293b;
        }

        .btn-submit:active {
            transform: scale(0.99);
        }

        .auth-footer {
            margin-top: 24px;
            text-align: center;
            font-size: 13px;
            color: var(--text-muted);
        }

        .auth-footer a {
            color: #000000;
            font-weight: 700;
            text-decoration: none;
        }

        .auth-footer a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>

<!-- Navbar -->
<div class="navbar">
    <a href="catalog.jsp" class="brand">Drive<span>Eazy</span></a>
    <a href="catalog.jsp" class="nav-link">Explore Fleet Catalog →</a>
</div>

<!-- Main Auth Container -->
<div class="auth-wrapper">
    <div class="auth-container">

        <div class="auth-header">
            <h1>Welcome to DriveEazy</h1>
            <p>Self-drive vehicle rentals made effortless</p>
        </div>

        <!-- Tab Controls -->
        <div class="auth-tabs">
            <button class="tab-btn <%= "user-login".equals(activeTab) ? "active" : "" %>" onclick="switchTab('user-login')">Customer Login</button>
            <button class="tab-btn <%= "admin-login".equals(activeTab) ? "active" : "" %>" onclick="switchTab('admin-login')">Admin Portal</button>
            <button class="tab-btn <%= "register".equals(activeTab) ? "active" : "" %>" onclick="switchTab('register')">Register</button>
        </div>

        <%-- Notification Alerts --%>
        <% if (error != null) { %>
            <div class="alert alert-error"><%= error %></div>
        <% } else if (message != null) { %>
            <div class="alert alert-success"><%= message %></div>
        <% } %>

        <!-- 1. Customer Login Panel -->
        <div id="user-login" class="form-panel <%= "user-login".equals(activeTab) ? "active" : "" %>">
            <form action="LoginServlet" method="POST">
                <input type="hidden" name="role" value="CUSTOMER">

                <div class="form-group">
                    <label>Email Address</label>
                    <input type="email" name="email" placeholder="name@example.com" required>
                </div>

                <div class="form-group">
                    <label>Password</label>
                    <input type="password" name="password" placeholder="••••••••" required>
                </div>

                <button type="submit" class="btn-submit">Login as Customer</button>
            </form>

            <div class="auth-footer">
                New to DriveEazy? <a href="#" onclick="switchTab('register'); return false;">Create an account</a>
            </div>
        </div>

        <!-- 2. Admin Portal Panel -->
        <div id="admin-login" class="form-panel <%= "admin-login".equals(activeTab) ? "active" : "" %>">
            <form action="LoginServlet" method="POST">
                <input type="hidden" name="role" value="ADMIN">

                <div class="form-group">
                    <label>Admin Username / Email</label>
                    <input type="text" name="email" placeholder="admin@driveeazy.com" required>
                </div>

                <div class="form-group">
                    <label>Admin Security Password</label>
                    <input type="password" name="password" placeholder="••••••••" required>
                </div>

                <button type="submit" class="btn-submit" style="background: #0f172a;">Login to Console</button>
            </form>
        </div>

        <!-- 3. Account Registration Panel -->
        <div id="register" class="form-panel <%= "register".equals(activeTab) ? "active" : "" %>">
            <form action="RegisterServlet" method="POST">
                <div class="form-group">
                    <label>Full Name</label>
                    <input type="text" name="name" placeholder="John Doe" required>
                </div>

                <div class="form-group">
                    <label>Email Address</label>
                    <input type="email" name="email" placeholder="name@example.com" required>
                </div>

                <div class="form-group">
                    <label>Phone Number</label>
                    <input type="tel" name="phone" placeholder="+91 98765 43210" required>
                </div>

                <div class="form-group">
                    <label>Create Password</label>
                    <input type="password" name="password" placeholder="Minimum 6 characters" required>
                </div>

                <button type="submit" class="btn-submit">Register Account</button>
            </form>

            <div class="auth-footer">
                Already registered? <a href="#" onclick="switchTab('user-login'); return false;">Log in here</a>
            </div>
        </div>

    </div>
</div>

<script>
    function switchTab(tabId) {
        // Hide all form panels
        document.querySelectorAll('.form-panel').forEach(panel => {
            panel.classList.remove('active');
        });

        // Deactivate all tab buttons
        document.querySelectorAll('.tab-btn').forEach(btn => {
            btn.classList.remove('active');
        });

        // Activate target panel & button
        document.getElementById(tabId).classList.add('active');
        event.currentTarget.classList.add('active');
    }
</script>

</body>
</html>