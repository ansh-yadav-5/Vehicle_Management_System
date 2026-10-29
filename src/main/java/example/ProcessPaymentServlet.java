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

@WebServlet("/ProcessPaymentServlet")
public class ProcessPaymentServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        String bookingIdStr = request.getParameter("bookingId");

        if (bookingIdStr != null && !bookingIdStr.trim().isEmpty()) {
            try {
                int bookingId = Integer.parseInt(bookingIdStr.trim());

                try (Connection conn = DBConnection.getConnection()) {
                    String sql = "UPDATE bookings SET payment_status = 'PAID' WHERE booking_id = ?";
                    try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                        stmt.setInt(1, bookingId);
                        stmt.executeUpdate();
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    response.sendRedirect("my_bookings.jsp?error=Payment database error: " + e.getMessage());
                    return;
                }

                response.sendRedirect("my_bookings.jsp?msg=Payment successful! Booking confirmed. Please complete your KYC verification.");
                return;

            } catch (NumberFormatException e) {
                response.sendRedirect("my_bookings.jsp?error=Invalid booking reference.");
                return;
            }
        }
        response.sendRedirect("my_bookings.jsp");
    }
}