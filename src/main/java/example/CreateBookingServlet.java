package example;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/CreateBookingServlet")
public class CreateBookingServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");
        String vehicleIdStr = request.getParameter("vehicleId");
        String pickupDateStr = request.getParameter("pickupDate");
        String returnDateStr = request.getParameter("returnDate");
        String deliveryType = request.getParameter("deliveryType");

        if (vehicleIdStr == null || pickupDateStr == null || returnDateStr == null) {
            response.sendRedirect("catalog.jsp?error=Invalid booking parameters.");
            return;
        }

        try {
            int vehicleId = Integer.parseInt(vehicleIdStr.trim());
            LocalDate pickupDate = LocalDate.parse(pickupDateStr.trim());
            LocalDate returnDate = LocalDate.parse(returnDateStr.trim());

            // Inclusive of start day, minimum 1 day
            long daysBetween = ChronoUnit.DAYS.between(pickupDate, returnDate) + 1;
            int totalDays = daysBetween > 0 ? (int) daysBetween : 1;

            try (Connection conn = DBConnection.getConnection()) {
                if (conn == null) {
                    response.sendRedirect("catalog.jsp?error=Database connection failed.");
                    return;
                }

                // 1. Fetch vehicle daily rate
                double pricePerDay = 0.0;
                String rateSql = "SELECT price_per_day FROM vehicles WHERE vehicle_id = ?";
                try (PreparedStatement stmt = conn.prepareStatement(rateSql)) {
                    stmt.setInt(1, vehicleId);
                    try (ResultSet rs = stmt.executeQuery()) {
                        if (rs.next()) {
                            pricePerDay = rs.getDouble("price_per_day");
                        } else {
                            response.sendRedirect("catalog.jsp?error=Vehicle not found.");
                            return;
                        }
                    }
                }

                // 2. Calculate total price
                double totalPrice = totalDays * pricePerDay;
                if ("DOORSTEP".equalsIgnoreCase(deliveryType)) {
                    totalPrice += 300.0; // Doorstep delivery fee
                }

                // 3. Insert into bookings table
                String insertSql = "INSERT INTO bookings (user_id, vehicle_id, pickup_date, return_date, total_days, delivery_type, total_price, kyc_status, payment_status) VALUES (?, ?, ?, ?, ?, ?, ?, 'PENDING', 'PENDING')";
                int generatedBookingId = 0;

                try (PreparedStatement stmt = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
                    stmt.setInt(1, userId);
                    stmt.setInt(2, vehicleId);
                    stmt.setString(3, pickupDate.toString());
                    stmt.setString(4, returnDate.toString());
                    stmt.setInt(5, totalDays);
                    stmt.setString(6, deliveryType != null ? deliveryType : "SELF_PICKUP");
                    stmt.setDouble(7, totalPrice);
                    stmt.executeUpdate();

                    try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                        if (generatedKeys.next()) {
                            generatedBookingId = generatedKeys.getInt(1);
                        }
                    }
                }

                // 4. Update vehicle status to BOOKED
                String updateVehicleSql = "UPDATE vehicles SET status = 'BOOKED' WHERE vehicle_id = ?";
                try (PreparedStatement stmt = conn.prepareStatement(updateVehicleSql)) {
                    stmt.setInt(1, vehicleId);
                    stmt.executeUpdate();
                }

                // 5. Redirect to Fake Payment Gateway with bookingId and amount
                response.sendRedirect("payment.jsp?bookingId=" + generatedBookingId + "&amount=" + String.format("%.2f", totalPrice));
                return;

            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("catalog.jsp?error=Booking database error: " + e.getMessage());
                return;
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("catalog.jsp?error=Invalid date or vehicle format.");
            return;
        }
    }
}