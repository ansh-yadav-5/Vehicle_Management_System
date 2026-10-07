package example;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/ExtendTripServlet")
public class ExtendTripServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        String bookingIdStr = request.getParameter("bookingId");
        String extraDaysStr = request.getParameter("extraDays");

        if (bookingIdStr != null && extraDaysStr != null) {
            int bookingId = Integer.parseInt(bookingIdStr);
            int extraDays = Integer.parseInt(extraDaysStr);

            if (extraDays <= 0) {
                response.sendRedirect("my_bookings.jsp?error=Invalid extra days requested");
                return;
            }

            try (Connection conn = DBConnection.getConnection()) {
                conn.setAutoCommit(false);

                // 1. Get current booking and vehicle details
                String fetchSql = "SELECT b.*, v.price_per_day FROM bookings b " +
                        "JOIN vehicles v ON b.vehicle_id = v.vehicle_id WHERE b.booking_id = ?";

                int vehicleId = 0;
                LocalDate currentReturnDate = null;
                double pricePerDay = 0.0;
                int currentTotalDays = 0;
                double currentTotalPrice = 0.0;

                try (PreparedStatement stmt = conn.prepareStatement(fetchSql)) {
                    stmt.setInt(1, bookingId);
                    try (ResultSet rs = stmt.executeQuery()) {
                        if (rs.next()) {
                            vehicleId = rs.getInt("vehicle_id");
                            currentReturnDate = LocalDate.parse(rs.getString("return_date"));
                            pricePerDay = rs.getDouble("price_per_day");
                            currentTotalDays = rs.getInt("total_days");
                            currentTotalPrice = rs.getDouble("total_price");
                        } else {
                            response.sendRedirect("my_bookings.jsp?error=Booking not found");
                            return;
                        }
                    }
                }

                LocalDate newReturnDate = currentReturnDate.plusDays(extraDays);

                // 2. Check overlap with other customer reservations for the same vehicle
                String overlapSql = "SELECT COUNT(*) FROM bookings WHERE vehicle_id = ? AND booking_id != ? " +
                        "AND kyc_status NOT IN ('REJECTED', 'COMPLETED') " +
                        "AND pickup_date < ? AND return_date > ?";

                try (PreparedStatement stmt = conn.prepareStatement(overlapSql)) {
                    stmt.setInt(1, vehicleId);
                    stmt.setInt(2, bookingId);
                    stmt.setString(3, newReturnDate.toString());
                    stmt.setString(4, currentReturnDate.toString());

                    try (ResultSet rs = stmt.executeQuery()) {
                        if (rs.next() && rs.getInt(1) > 0) {
                            conn.rollback();
                            response.sendRedirect("my_bookings.jsp?error=Vehicle is reserved by another customer for requested extension dates");
                            return;
                        }
                    }
                }

                // 3. Update return date and total cost
                double additionalCost = pricePerDay * extraDays;
                double newTotalPrice = currentTotalPrice + additionalCost;
                int newTotalDays = currentTotalDays + extraDays;

                String updateSql = "UPDATE bookings SET return_date = ?, total_days = ?, total_price = ?, " +
                        "extended_days = extended_days + ? WHERE booking_id = ?";
                try (PreparedStatement stmt = conn.prepareStatement(updateSql)) {
                    stmt.setString(1, newReturnDate.toString());
                    stmt.setInt(2, newTotalDays);
                    stmt.setDouble(3, newTotalPrice);
                    stmt.setInt(4, extraDays);
                    stmt.setInt(5, bookingId);
                    stmt.executeUpdate();
                }

                conn.commit();
                response.sendRedirect("my_bookings.jsp?msg=Trip extended successfully!");

            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("my_bookings.jsp?error=Failed to extend trip");
            }
        }
    }
}