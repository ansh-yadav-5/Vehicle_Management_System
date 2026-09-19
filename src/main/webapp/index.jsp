<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Vehicle Management System - Login & Signup</title>
    <style>
        * { box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { background: #f4f6f9; display: flex; justify-content: center; align-items: center; min-height: 100vh; margin: 0; }
        .auth-container { background: #ffffff; padding: 30px; border-radius: 10px; box-shadow: 0 4px 15px rgba(0,0,0,0.1); width: 400px; }
        .tabs { display: flex; margin-bottom: 20px; border-bottom: 2px solid #e2e8f0; }
        .tab-btn { flex: 1; padding: 10px; text-align: center; cursor: pointer; font-weight: bold; color: #64748b; }
        .tab-btn.active { color: #2563eb; border-bottom: 3px solid #2563eb; }
        .form-group { margin-bottom: 15px; }
        label { display: block; margin-bottom: 5px; color: #334155; font-size: 14px; }
        input[type="text"], input[type="email"], input[type="password"] { width: 100%; padding: 10px; border: 1px solid #cbd5e1; border-radius: 5px; outline: none; }
        input:focus { border-color: #2563eb; }
        .btn { width: 100%; padding: 10px; background: #2563eb; color: white; border: none; border-radius: 5px; font-size: 16px; cursor: pointer; font-weight: bold; }
        .btn:hover { background: #1d4ed8; }
        .alert { padding: 10px; margin-bottom: 15px; border-radius: 5px; font-size: 14px; }
        .alert-error { background: #fee2e2; color: #dc2626; border: 1px solid #fca5a5; }
        .alert-success { background: #dcfce7; color: #16a34a; border: 1px solid #86efac; }
        .hidden { display: none; }
    </style>
</head>
<body>

<div class="auth-container">
    <div class="tabs">
        <div class="tab-btn active" id="loginTab" onclick="showForm('login')">Login</div>
        <div class="tab-btn" id="signupTab" onclick="showForm('signup')">Sign Up</div>
    </div>

    <%
        String error = (String) request.getAttribute("error");
        String message = (String) request.getAttribute("message");
        if (error != null) {
    %>
        <div class="alert alert-error"><%= error %></div>
    <% } else if (message != null) { %>
        <div class="alert alert-success"><%= message %></div>
    <% } %>

    <!-- LOGIN FORM -->
    <form id="loginForm" action="AuthServlet" method="POST">
        <input type="hidden" name="action" value="login">
        <div class="form-group">
            <label>Email Address</label>
            <input type="email" name="email" required placeholder="name@example.com">
        </div>
        <div class="form-group">
            <label>Password</label>
            <input type="password" name="password" required placeholder="••••••••">
        </div>
        <button type="submit" class="btn">Login</button>
    </form>

    <!-- SIGNUP FORM -->
    <form id="signupForm" action="AuthServlet" method="POST" class="hidden">
        <input type="hidden" name="action" value="register">
        <div class="form-group">
            <label>Full Name</label>
            <input type="text" name="name" required placeholder="John Doe">
        </div>
        <div class="form-group">
            <label>Email Address</label>
            <input type="email" name="email" required placeholder="name@example.com">
        </div>
        <div class="form-group">
            <label>Password</label>
            <input type="password" name="password" required placeholder="••••••••">
        </div>
        <button type="submit" class="btn">Create Account</button>
    </form>
</div>

<script>
    function showForm(formType) {
        if (formType === 'login') {
            document.getElementById('loginForm').classList.remove('hidden');
            document.getElementById('signupForm').classList.add('hidden');
            document.getElementById('loginTab').classList.add('active');
            document.getElementById('signupTab').classList.remove('active');
        } else {
            document.getElementById('loginForm').classList.add('hidden');
            document.getElementById('signupForm').classList.remove('hidden');
            document.getElementById('signupTab').classList.add('active');
            document.getElementById('loginTab').classList.remove('active');
        }
    }
</script>

</body>
</html>