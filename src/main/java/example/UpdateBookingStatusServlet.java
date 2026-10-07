package example; // Change to match your project package name

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/UpdateBookingStatusServlet")
public class UpdateBookingStatusServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || !"ADMIN".equalsIgnoreCase((String) session.getAttribute("userRole"))) {
            response.sendRedirect("index.jsp");
            return;
        }

        String bookingIdStr = request.getParameter("bookingId");
        String vehicleIdStr = request.getParameter("vehicleId");
        String targetAction = request.getParameter("targetAction");

        if (bookingIdStr != null && vehicleIdStr != null && targetAction != null) {
            int bookingId = Integer.parseInt(bookingIdStr);
            int vehicleId = Integer.parseInt(vehicleIdStr);

            try (Connection conn = DBConnection.getConnection()) {
                conn.setAutoCommit(false); // Enable database transaction

                if ("APPROVE".equalsIgnoreCase(targetAction)) {
                    // Approve KYC / Driving License
                    String sql = "UPDATE bookings SET kyc_status = 'APPROVED' WHERE booking_id = ?";
                    try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                        stmt.setInt(1, bookingId);
                        stmt.executeUpdate();
                    }
                }
                else if ("REJECT".equalsIgnoreCase(targetAction)) {
                    // Reject Booking & release vehicle back to catalog
                    String sqlBooking = "UPDATE bookings SET kyc_status = 'REJECTED' WHERE booking_id = ?";
                    try (PreparedStatement stmt = conn.prepareStatement(sqlBooking)) {
                        stmt.setInt(1, bookingId);
                        stmt.executeUpdate();
                    }

                    String sqlVehicle = "UPDATE vehicles SET status = 'AVAILABLE' WHERE vehicle_id = ?";
                    try (PreparedStatement stmt = conn.prepareStatement(sqlVehicle)) {
                        stmt.setInt(1, vehicleId);
                        stmt.executeUpdate();
                    }
                }
                else if ("HANDOVER".equalsIgnoreCase(targetAction)) {
                    // Mark Vehicle Picked Up (Trip becomes Active)
                    String sql = "UPDATE bookings SET kyc_status = 'ACTIVE' WHERE booking_id = ?";
                    try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                        stmt.setInt(1, bookingId);
                        stmt.executeUpdate();
                    }
                }
                else if ("RETURN".equalsIgnoreCase(targetAction)) {
                    // Mark Vehicle Returned -> Complete booking & return vehicle to catalog
                    String sqlBooking = "UPDATE bookings SET kyc_status = 'COMPLETED' WHERE booking_id = ?";
                    try (PreparedStatement stmt = conn.prepareStatement(sqlBooking)) {
                        stmt.setInt(1, bookingId);
                        stmt.executeUpdate();
                    }

                    String sqlVehicle = "UPDATE vehicles SET status = 'AVAILABLE' WHERE vehicle_id = ?";
                    try (PreparedStatement stmt = conn.prepareStatement(sqlVehicle)) {
                        stmt.setInt(1, vehicleId);
                        stmt.executeUpdate();
                    }
                }

                conn.commit(); // Save changes
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        response.sendRedirect("admin_bookings.jsp");
    }
}