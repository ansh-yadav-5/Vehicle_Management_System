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

@WebServlet("/SubmitPaymentServlet")
public class SubmitPaymentServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        String bookingIdStr = request.getParameter("bookingId");
        String transactionId = request.getParameter("transactionId");

        if (bookingIdStr != null && transactionId != null && !transactionId.trim().isEmpty()) {
            try {
                int bookingId = Integer.parseInt(bookingIdStr.trim());

                try (Connection conn = DBConnection.getConnection()) {
                    String sql = "UPDATE bookings SET transaction_id = ?, payment_status = 'VERIFYING' WHERE booking_id = ?";
                    try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                        stmt.setString(1, transactionId.trim());
                        stmt.setInt(2, bookingId);
                        stmt.executeUpdate();
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    response.sendRedirect("my_bookings.jsp?error=Database error: " + e.getMessage());
                    return;
                }

                response.sendRedirect("my_bookings.jsp?msg=UPI Transaction ID submitted! Waiting for Admin verification.");
                return;

            } catch (NumberFormatException e) {
                response.sendRedirect("my_bookings.jsp?error=Invalid booking reference.");
                return;
            }
        }
        response.sendRedirect("my_bookings.jsp?error=Please enter a valid Transaction ID / UTR.");
    }
}