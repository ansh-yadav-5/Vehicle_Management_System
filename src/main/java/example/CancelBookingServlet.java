package example; // Ensure this matches your package name

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

@WebServlet("/CancelBookingServlet")
public class CancelBookingServlet extends HttpServlet {

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

        if (bookingIdStr != null && !bookingIdStr.trim().isEmpty()) {
            try {
                int bookingId = Integer.parseInt(bookingIdStr.trim());

                try (Connection conn = DBConnection.getConnection()) {
                    conn.setAutoCommit(false); // Enable transaction

                    // 1. Fetch current status & vehicle_id for ownership verification
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
                                conn.rollback();
                                response.sendRedirect("my_bookings.jsp?error=Reservation not found.");
                                return;
                            }
                        }
                    }

                    // 2. Strict Rule: Disallow cancellation if KYC is already APPROVED, ACTIVE, or COMPLETED
                    if ("APPROVED".equalsIgnoreCase(kycStatus) || "ACTIVE".equalsIgnoreCase(kycStatus) || "COMPLETED".equalsIgnoreCase(kycStatus)) {
                        conn.rollback();
                        response.sendRedirect("my_bookings.jsp?error=Cannot cancel booking after KYC approval.");
                        return;
                    }

                    // 3. Update booking status to REJECTED (Cancelled)
                    String cancelSql = "UPDATE bookings SET kyc_status = 'REJECTED', refund_status = 'INITIATED' WHERE booking_id = ?";
                    try (PreparedStatement stmt = conn.prepareStatement(cancelSql)) {
                        stmt.setInt(1, bookingId);
                        stmt.executeUpdate();
                    }

                    // 4. Release vehicle back to AVAILABLE in catalog.jsp
                    String releaseVehicleSql = "UPDATE vehicles SET status = 'AVAILABLE' WHERE vehicle_id = ?";
                    try (PreparedStatement stmt = conn.prepareStatement(releaseVehicleSql)) {
                        stmt.setInt(1, vehicleId);
                        stmt.executeUpdate();
                    }

                    conn.commit(); // Commit transaction
                    response.sendRedirect("my_bookings.jsp?msg=Booking cancelled successfully. Vehicle released.");
                    return;

                } catch (Exception e) {
                    e.printStackTrace();
                    response.sendRedirect("my_bookings.jsp?error=Error processing cancellation: " + e.getMessage());
                    return;
                }
            } catch (NumberFormatException e) {
                response.sendRedirect("my_bookings.jsp?error=Invalid booking ID.");
                return;
            }
        }
        response.sendRedirect("my_bookings.jsp");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
}