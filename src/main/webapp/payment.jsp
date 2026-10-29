<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String userName = (String) session.getAttribute("userName");
    Integer userId = (Integer) session.getAttribute("userId");

    if (userName == null || userId == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    String bookingId = request.getParameter("bookingId");
    String amount = request.getParameter("amount");

    if (bookingId == null || amount == null) {
        response.sendRedirect("catalog.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>UPI QR Payment - GoDrive</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #0f172a;
            --accent: #22c55e;
            --bg-gray: #0b0f19;
            --card-bg: #111827;
            --card-border: #1f2937;
            --text-dark: #f8fafc;
            --text-muted: #94a3b8;
        }

        * {
            box-sizing: border-box;
            font-family: 'Plus Jakarta Sans', sans-serif;
            margin: 0;
            padding: 0;
        }

        body {
            background-color: var(--bg-gray);
            color: var(--text-dark);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }

        .checkout-container {
            width: 100%;
            max-width: 440px;
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 24px;
            padding: 32px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
            text-align: center;
        }

        .brand-header h2 {
            font-size: 22px;
            font-weight: 800;
            color: #ffffff;
            margin-bottom: 4px;
        }

        .brand-header h2 span { color: var(--accent); }
        .brand-header p { color: var(--text-muted); font-size: 13px; margin-bottom: 20px; }

        .amount-box {
            background: #030712;
            border: 1px solid var(--card-border);
            border-radius: 14px;
            padding: 16px;
            margin-bottom: 20px;
        }

        .amount-box .label { font-size: 11px; font-weight: 800; text-transform: uppercase; color: var(--text-muted); margin-bottom: 2px; }
        .amount-box .val { font-size: 28px; font-weight: 800; color: var(--accent); }

        .qr-wrapper {
            background: #ffffff;
            padding: 16px;
            border-radius: 16px;
            display: inline-block;
            margin-bottom: 16px;
        }

        .qr-wrapper img {
            width: 180px;
            height: 180px;
            object-fit: contain;
        }

        .upi-id-box {
            background: #030712;
            padding: 10px;
            border-radius: 10px;
            font-size: 13px;
            font-weight: 700;
            color: #ffffff;
            margin-bottom: 20px;
            border: 1px solid var(--card-border);
        }

        .form-group { text-align: left; margin-bottom: 16px; }
        .form-group label { display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; color: var(--text-muted); margin-bottom: 6px; }
        .form-group input {
            width: 100%;
            padding: 12px 14px;
            background: #030712;
            border: 1px solid var(--card-border);
            border-radius: 10px;
            color: #ffffff;
            font-size: 14px;
            outline: none;
        }
        .form-group input:focus { border-color: var(--accent); }

        .pay-btn {
            width: 100%;
            background: var(--accent);
            color: #030712;
            border: none;
            padding: 14px;
            border-radius: 12px;
            font-size: 15px;
            font-weight: 800;
            cursor: pointer;
            transition: opacity 0.2s;
        }
        .pay-btn:hover { opacity: 0.9; }

        .instructions {
            font-size: 12px;
            color: var(--text-muted);
            margin-top: 14px;
            line-height: 1.5;
        }
    </style>
</head>
<body>

<div class="checkout-container">
    <div class="brand-header">
        <h2>Go<span>Drive</span> UPI Checkout</h2>
        <p>Scan QR or pay via UPI ID for Reservation #<%= bookingId %></p>
    </div>

    <div class="amount-box">
        <div class="label">Amount Payable</div>
        <div class="val">₹<%= amount %></div>
    </div>

    <!-- Simulated QR Code (Using a public placeholder QR generator) -->
    <div class="qr-wrapper">
        <img src="https://api.qrserver.com/v1/create-qr-code/?size=180x180&data=upi://pay?pa=godrive@ybl&pn=GoDrive&am=<%= amount %>&cu=INR" alt="UPI QR Code">
    </div>

    <div class="upi-id-box">
        UPI ID: <strong>godrive@ybl</strong>
    </div>

    <form action="SubmitPaymentServlet" method="POST">
        <input type="hidden" name="bookingId" value="<%= bookingId %>">

        <div class="form-group">
            <label>Enter UPI Transaction ID / UTR (12 digits)</label>
            <input type="text" name="transactionId" placeholder="e.g. 403219827364" required>
        </div>

        <button type="submit" class="pay-btn">I Have Paid — Submit UTR</button>
    </form>

    <div class="instructions">
        1. Open GPay, PhonePe, or Paytm.<br>
        2. Scan QR or pay to <strong>godrive@ybl</strong>.<br>
        3. Enter your 12-digit UTR/Transaction ID above for instant verification.
    </div>
</div>

</body>
</html>