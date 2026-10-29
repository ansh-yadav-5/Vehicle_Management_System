package example;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/GenerateReceiptServlet")
public class GenerateReceiptServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");
        String bookingIdStr = request.getParameter("bookingId");

        if (bookingIdStr == null || bookingIdStr.trim().isEmpty()) {
            response.sendRedirect("my_bookings.jsp?error=Invalid booking reference.");
            return;
        }

        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "SELECT b.*, v.title, v.brand, v.category, u.name, u.email " +
                    "FROM bookings b " +
                    "JOIN vehicles v ON b.vehicle_id = v.vehicle_id " +
                    "JOIN users u ON b.user_id = u.user_id " +
                    "WHERE b.booking_id = ? AND b.user_id = ?";

            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, Integer.parseInt(bookingIdStr.trim()));
                stmt.setInt(2, userId);

                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        String paymentStatus = rs.getString("payment_status");
                        if (!"PAID".equalsIgnoreCase(paymentStatus)) {
                            response.sendRedirect("my_bookings.jsp?error=Receipt available only after payment verification.");
                            return;
                        }

                        // Render Official Payment Receipt HTML
                        out.println("<!DOCTYPE html>");
                        out.println("<html lang='en'>");
                        out.println("<head>");
                        out.println("<meta charset='UTF-8'>");
                        out.println("<title>Payment Receipt - GoDrive # " + rs.getInt("booking_id") + "</title>");
                        out.println("<link href='https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;600;700;800&display=swap' rel='stylesheet'>");
                        out.println("<style>");
                        out.println("body { font-family: 'Plus Jakarta Sans', sans-serif; background: #f8fafc; color: #0f172a; padding: 40px; display: flex; justify-content: center; }");
                        out.println(".receipt-box { background: #ffffff; max-width: 600px; width: 100%; padding: 40px; border-radius: 20px; border: 1px solid #e2e8f0; box-shadow: 0 10px 25px rgba(0,0,0,0.05); }");
                        out.println(".header { display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid #f1f5f9; padding-bottom: 20px; margin-bottom: 24px; }");
                        out.println(".brand { font-size: 24px; font-weight: 800; color: #000000; }");
                        out.println(".brand span { color: #22c55e; }");
                        out.println(".badge { background: #dcfce7; color: #15803d; padding: 6px 14px; border-radius: 20px; font-size: 12px; font-weight: 800; text-transform: uppercase; }");
                        out.println(".grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 24px; }");
                        out.println(".item label { font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; display: block; margin-bottom: 4px; }");
                        out.println(".item val { font-size: 15px; font-weight: 700; color: #0f172a; }");
                        out.println(".total-box { background: #0f172a; color: #ffffff; padding: 20px; border-radius: 12px; display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; }");
                        out.println(".total-box .val { font-size: 22px; font-weight: 800; color: #22c55e; }");
                        out.println(".print-btn { display: block; width: 100%; background: #000000; color: #ffffff; border: none; padding: 14px; border-radius: 10px; font-weight: 700; font-size: 14px; cursor: pointer; text-align: center; text-decoration: none; }");
                        out.println("@media print { .print-btn { display: none; } body { background: #ffffff; padding: 0; } .receipt-box { border: none; box-shadow: none; } }");
                        out.println("</style>");
                        out.println("</head>");
                        out.println("<body>");

                        out.println("<div class='receipt-box'>");
                        out.println("<div class='header'>");
                        out.println("<div class='brand'>Go<span>Drive</span></div>");
                        out.println("<div class='badge'>✓ Paid & Verified</div>");
                        out.println("</div>");

                        out.println("<h3 style='margin-bottom: 16px; font-size: 18px;'>Official Payment Receipt</h3>");

                        out.println("<div class='grid'>");
                        out.println("<div class='item'><label>Booking Reference</label><val>#" + rs.getInt("booking_id") + "</val></div>");
                        out.println("<div class='item'><label>Customer Name</label><val>" + rs.getString("name") + "</val></div>");
                        out.println("<div class='item'><label>Vehicle Rented</label><val>" + rs.getString("brand") + " " + rs.getString("title") + "</val></div>");
                        out.println("<div class='item'><label>UPI Transaction ID (UTR)</label><val>" + (rs.getString("transaction_id") != null ? rs.getString("transaction_id") : "N/A") + "</val></div>");
                        out.println("<div class='item'><label>Pickup Date</label><val>" + rs.getString("pickup_date") + "</val></div>");
                        out.println("<div class='item'><label>Return Date</label><val>" + rs.getString("return_date") + "</val></div>");
                        out.println("</div>");

                        out.println("<div class='total-box'>");
                        out.println("<div><div style='font-size:12px; color:#94a3b8; font-weight:600;'>Total Amount Paid</div><div style='font-size:13px;'>Inclusive of all taxes & insurance</div></div>");
                        out.println("<div class='val'>₹" + String.format("%.2f", rs.getDouble("total_price")) + "</div>");
                        out.println("</div>");

                        out.println("<button class='print-btn' onclick='window.print()'>🖨️ Print / Save Receipt PDF</button>");
                        out.println("</div>");

                        out.println("</body>");
                        out.println("</html>");
                        return;
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        response.sendRedirect("my_bookings.jsp?error=Receipt generation failed.");
    }
}