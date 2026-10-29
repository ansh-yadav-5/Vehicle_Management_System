package example;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/AdminVerifyPaymentServlet")
public class AdminVerifyPaymentServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminUser") == null) {
            response.sendRedirect("admin_login.jsp");
            return;
        }

        String bookingIdStr = request.getParameter("bookingId");
        String action = request.getParameter("action"); // 'APPROVE' or 'REJECT'

        if (bookingIdStr != null && action != null) {
            try {
                int bookingId = Integer.parseInt(bookingIdStr.trim());
                String newStatus = "APPROVE".equalsIgnoreCase(action) ? "PAID" : "REJECTED";

                try (Connection conn = DBConnection.getConnection()) {
                    String sql = "UPDATE bookings SET payment_status = ? WHERE booking_id = ?";
                    try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                        stmt.setString(1, newStatus);
                        stmt.setInt(2, bookingId);
                        stmt.executeUpdate();
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            } catch (Exception ignored) {}
        }
        response.sendRedirect("admin_dashboard.jsp");
    }
}