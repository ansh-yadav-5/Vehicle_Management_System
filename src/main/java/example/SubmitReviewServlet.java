package example;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/SubmitReviewServlet")
public class SubmitReviewServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");
        String bookingIdStr = request.getParameter("bookingId");
        String ratingStr = request.getParameter("rating");
        String reviewText = request.getParameter("reviewText");

        if (bookingIdStr != null && ratingStr != null) {
            try {
                int bookingId = Integer.parseInt(bookingIdStr.trim());
                int rating = Integer.parseInt(ratingStr.trim());

                if (rating < 1) rating = 1;
                if (rating > 5) rating = 5;

                try (Connection conn = DBConnection.getConnection()) {
                    // 1. Check if booking exists, belongs to user, and is COMPLETED
                    String checkSql = "SELECT vehicle_id, kyc_status FROM bookings WHERE booking_id = ? AND user_id = ?";
                    int vehicleId = 0;
                    String kycStatus = "";

                    try (PreparedStatement stmt = conn.prepareStatement(checkSql)) {
                        stmt.setInt(1, bookingId);
                        stmt.setInt(2, userId);
                        try (ResultSet rs = stmt.executeQuery()) {
                            if (rs.next()) {
                                vehicleId = rs.getInt("vehicle_id");
                                kycStatus = rs.getString("kyc_status");
                            } else {
                                response.sendRedirect("my_bookings.jsp?error=Reservation not found.");
                                return;
                            }
                        }
                    }

                    if (!"COMPLETED".equalsIgnoreCase(kycStatus)) {
                        response.sendRedirect("my_bookings.jsp?error=You can only review completed trips.");
                        return;
                    }

                    // 2. Prevent duplicate reviews for the same booking
                    String dupCheckSql = "SELECT review_id FROM reviews WHERE booking_id = ?";
                    try (PreparedStatement stmt = conn.prepareStatement(dupCheckSql)) {
                        stmt.setInt(1, bookingId);
                        try (ResultSet rs = stmt.executeQuery()) {
                            if (rs.next()) {
                                response.sendRedirect("my_bookings.jsp?error=Review already submitted for this trip.");
                                return;
                            }
                        }
                    }

                    // 3. Insert review
                    String insertSql = "INSERT INTO reviews (booking_id, vehicle_id, user_id, rating, review_text) VALUES (?, ?, ?, ?, ?)";
                    try (PreparedStatement stmt = conn.prepareStatement(insertSql)) {
                        stmt.setInt(1, bookingId);
                        stmt.setInt(2, vehicleId);
                        stmt.setInt(3, userId);
                        stmt.setInt(4, rating);
                        stmt.setString(5, reviewText != null ? reviewText.trim() : "");
                        stmt.executeUpdate();
                    }

                    response.sendRedirect("my_bookings.jsp?msg=Thank you! Your feedback has been submitted.");
                    return;

                } catch (Exception e) {
                    e.printStackTrace();
                    response.sendRedirect("my_bookings.jsp?error=Error submitting review: " + e.getMessage());
                    return;
                }
            } catch (NumberFormatException e) {
                response.sendRedirect("my_bookings.jsp?error=Invalid rating parameters.");
                return;
            }
        }
        response.sendRedirect("my_bookings.jsp");
    }
}