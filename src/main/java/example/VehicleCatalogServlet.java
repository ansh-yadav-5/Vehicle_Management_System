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
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

@WebServlet("/VehicleCatalogServlet")
public class VehicleCatalogServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");

        if (userId == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        int vehicleId = Integer.parseInt(request.getParameter("vehicleId"));
        String pickupStr = request.getParameter("pickupDate");
        String returnStr = request.getParameter("returnDate");

        LocalDate pickupDate = LocalDate.parse(pickupStr);
        LocalDate returnDate = LocalDate.parse(returnStr);

        long totalDays = ChronoUnit.DAYS.between(pickupDate, returnDate);

        if (totalDays <= 0) {
            request.setAttribute("error", "Return date must be at least 1 day after Pickup date!");
            request.getRequestDispatcher("catalog.jsp").forward(request, response);
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            // Fetch vehicle price per day
            String priceSql = "SELECT price_per_day FROM vehicles WHERE vehicle_id = ?";
            PreparedStatement priceStmt = conn.prepareStatement(priceSql);
            priceStmt.setInt(1, vehicleId);
            ResultSet rs = priceStmt.executeQuery();

            if (rs.next()) {
                double pricePerDay = rs.getDouble("price_per_day");
                double totalPrice = totalDays * pricePerDay;

                // Save booking
                String bookingSql = "INSERT INTO bookings (user_id, vehicle_id, pickup_date, return_date, total_days, total_price, booking_status) " +
                        "VALUES (?, ?, ?, ?, ?, ?, 'PENDING')";
                PreparedStatement bookingStmt = conn.prepareStatement(bookingSql);
                bookingStmt.setInt(1, userId);
                bookingStmt.setInt(2, vehicleId);
                bookingStmt.setString(3, pickupStr);
                bookingStmt.setString(4, returnStr);
                bookingStmt.setLong(5, totalDays);
                bookingStmt.setDouble(6, totalPrice);

                int rowsInserted = bookingStmt.executeUpdate();

                if (rowsInserted > 0) {
                    request.setAttribute("message", "Booking submitted successfully! Total Fare: ₹" + totalPrice);
                } else {
                    request.setAttribute("error", "Failed to place booking request.");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error during booking: " + e.getMessage());
        }

        request.getRequestDispatcher("catalog.jsp").forward(request, response);
    }
}