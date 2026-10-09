<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String userName = (String) session.getAttribute("userName");
    String userRole = (String) session.getAttribute("userRole");

    if (userName != null && "ADMIN".equalsIgnoreCase(userRole)) {
        response.sendRedirect("admin_dashboard.jsp");
        return;
    }

    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DriveEazy - Admin Access Portal</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #0f172a;
            --accent: #22c55e;
            --bg-dark: #000000;
            --text-dark: #0f172a;
            --text-muted: #64748b;
        }

        * { box-sizing: border-box; font-family: 'Plus Jakarta Sans', sans-serif; margin: 0; padding: 0; }
        body { background-color: var(--bg-dark); color: #ffffff; min-height: 100vh; display: flex; flex-direction: column; }

        .navbar {
            background: #000000;
            padding: 20px 6%;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }

        .navbar .brand { font-size: 26px; font-weight: 800; color: #ffffff; text-decoration: none; }
        .navbar .brand span { color: var(--accent); font-weight: 400; }

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
            max-width: 420px;
            background: #ffffff;
            color: var(--text-dark);
            border-radius: 20px;
            padding: 36px 32px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
            border: 2px solid #000000;
        }

        .auth-header { text-align: center; margin-bottom: 28px; }
        .auth-header h1 { font-size: 24px; font-weight: 800; color: var(--text-dark); margin-bottom: 6px; }
        .auth-header p { font-size: 13px; color: var(--text-muted); }

        .alert-error { background: #fee2e2; color: #dc2626; border: 1px solid #fca5a5; padding: 12px; border-radius: 10px; font-size: 13px; font-weight: 600; margin-bottom: 20px; }

        .form-group { margin-bottom: 18px; }
        .form-group label { display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: var(--text-muted); margin-bottom: 6px; }
        .form-group input {
            width: 100%; padding: 12px 14px; border: 1px solid #cbd5e1; border-radius: 10px; font-size: 14px; outline: none; background: #f8fafc;
        }

        .btn-submit {
            width: 100%; background: #0f172a; color: #ffffff; padding: 14px; border: none; border-radius: 10px; font-weight: 700; font-size: 14px; cursor: pointer; margin-top: 8px;
        }
    </style>
</head>
<body>

<div class="navbar">
    <a href="index.jsp" class="brand">Drive<span>Eazy</span> Admin Console</a>
</div>

<div class="auth-wrapper">
    <div class="auth-container">
        <div class="auth-header">
            <h1>Administrator Portal</h1>
            <p>Authorized fleet management credentials required</p>
        </div>

        <% if (error != null) { %>
            <div class="alert-error"><%= error %></div>
        <% } %>

        <form action="LoginServlet" method="POST">
            <input type="hidden" name="role" value="ADMIN">

            <div class="form-group">
                <label>Admin Email / Username</label>
                <input type="text" name="email" placeholder="admin@driveeazy.com" required>
            </div>

            <div class="form-group">
                <label>Security Password</label>
                <input type="password" name="password" placeholder="••••••••" required>
            </div>

            <button type="submit" class="btn-submit">Login to Dashboard</button>
        </form>
    </div>
</div>

</body>
</html>