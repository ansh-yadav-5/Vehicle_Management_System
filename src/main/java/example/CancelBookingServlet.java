package example;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet("/CancelBookingServlet")
public class CancelBookingServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");

        if (userId == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        String bookingIdStr = request.getParameter("bookingId");

        if (bookingIdStr == null || bookingIdStr.isEmpty()) {
            request.setAttribute("error", "Invalid booking request.");
            request.getRequestDispatcher("my_bookings.jsp").forward(request, response);
            return;
        }

        try {
            int bookingId = Integer.parseInt(bookingIdStr);

            try (Connection conn = DBConnection.getConnection()) {
                conn.setAutoCommit(false); // Begin transaction

                // 1. Fetch vehicle_id associated with this booking and confirm ownership
                String fetchSql = "SELECT vehicle_id, booking_status FROM bookings WHERE booking_id = ? AND user_id = ? FOR UPDATE";
                PreparedStatement fetchStmt = conn.prepareStatement(fetchSql);
                fetchStmt.setInt(1, bookingId);
                fetchStmt.setInt(2, userId);
                ResultSet rs = fetchStmt.executeQuery();

                if (rs.next()) {
                    String currentStatus = rs.getString("booking_status");

                    if ("CANCELLED".equalsIgnoreCase(currentStatus)) {
                        conn.rollback();
                        request.setAttribute("error", "This booking is already cancelled.");
                        request.getRequestDispatcher("my_bookings.jsp").forward(request, response);
                        return;
                    }

                    int vehicleId = rs.getInt("vehicle_id");

                    // 2. Update booking status to CANCELLED
                    String cancelSql = "UPDATE bookings SET booking_status = 'CANCELLED' WHERE booking_id = ?";
                    PreparedStatement cancelStmt = conn.prepareStatement(cancelSql);
                    cancelStmt.setInt(1, bookingId);
                    cancelStmt.executeUpdate();

                    // 3. Reset vehicle status back to AVAILABLE
                    String updateVehicleSql = "UPDATE vehicles SET status = 'AVAILABLE' WHERE vehicle_id = ?";
                    PreparedStatement updateVehicleStmt = conn.prepareStatement(updateVehicleSql);
                    updateVehicleStmt.setInt(1, vehicleId);
                    updateVehicleStmt.executeUpdate();

                    conn.commit(); // Commit transaction
                    request.setAttribute("message", "Booking #" + bookingId + " cancelled successfully. Vehicle is now available again.");
                } else {
                    conn.rollback();
                    request.setAttribute("error", "Booking record not found or access denied.");
                }

            } catch (SQLException e) {
                e.printStackTrace();
                request.setAttribute("error", "Database error during cancellation: " + e.getMessage());
            }

        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid Booking ID format.");
        }

        request.getRequestDispatcher("my_bookings.jsp").forward(request, response);
    }
}