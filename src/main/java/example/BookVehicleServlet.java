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

@WebServlet("/BookVehicleServlet")
public class BookVehicleServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");

        // Redirect to login if session is expired or invalid
        if (userId == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        String vehicleIdStr = request.getParameter("vehicleId");
        String pickupStr = request.getParameter("pickupDate");
        String returnStr = request.getParameter("returnDate");

        // Validate required inputs
        if (pickupStr == null || returnStr == null || pickupStr.isEmpty() || returnStr.isEmpty()) {
            request.setAttribute("error", "Please select both Pickup and Return dates before booking!");
            request.getRequestDispatcher("catalog.jsp").forward(request, response);
            return;
        }

        try {
            int vehicleId = Integer.parseInt(vehicleIdStr);
            LocalDate pickupDate = LocalDate.parse(pickupStr);
            LocalDate returnDate = LocalDate.parse(returnStr);

            long totalDays = ChronoUnit.DAYS.between(pickupDate, returnDate);

            if (totalDays <= 0) {
                request.setAttribute("error", "Return date must be at least 1 day after the Pickup date.");
                request.getRequestDispatcher("catalog.jsp").forward(request, response);
                return;
            }

            try (Connection conn = DBConnection.getConnection()) {
                conn.setAutoCommit(false); // Start Transaction

                // 1. Fetch Vehicle details & check availability
                String checkSql = "SELECT price_per_day, status FROM vehicles WHERE vehicle_id = ? FOR UPDATE";
                PreparedStatement checkStmt = conn.prepareStatement(checkSql);
                checkStmt.setInt(1, vehicleId);
                ResultSet rs = checkStmt.executeQuery();

                if (rs.next()) {
                    String status = rs.getString("status");
                    if (!"AVAILABLE".equalsIgnoreCase(status)) {
                        conn.rollback();
                        request.setAttribute("error", "Sorry, this vehicle is no longer available.");
                        request.getRequestDispatcher("catalog.jsp").forward(request, response);
                        return;
                    }

                    double pricePerDay = rs.getDouble("price_per_day");
                    double totalPrice = totalDays * pricePerDay;

                    // 2. Insert into bookings table
                    String insertSql = "INSERT INTO bookings (user_id, vehicle_id, pickup_date, return_date, total_days, total_price, booking_status) " +
                            "VALUES (?, ?, ?, ?, ?, ?, 'CONFIRMED')";
                    PreparedStatement insertStmt = conn.prepareStatement(insertSql);
                    insertStmt.setInt(1, userId);
                    insertStmt.setInt(2, vehicleId);
                    insertStmt.setString(3, pickupStr);
                    insertStmt.setString(4, returnStr);
                    insertStmt.setLong(5, totalDays);
                    insertStmt.setDouble(6, totalPrice);
                    insertStmt.executeUpdate();

                    // 3. Update vehicle status to BOOKED
                    String updateSql = "UPDATE vehicles SET status = 'BOOKED' WHERE vehicle_id = ?";
                    PreparedStatement updateStmt = conn.prepareStatement(updateSql);
                    updateStmt.setInt(1, vehicleId);
                    updateStmt.executeUpdate();

                    conn.commit(); // Commit Transaction

                    request.setAttribute("message", "Vehicle reserved successfully! Total Fare: ₹" + totalPrice + " for " + totalDays + " day(s).");
                } else {
                    conn.rollback();
                    request.setAttribute("error", "Vehicle not found.");
                }
            } catch (SQLException e) {
                e.printStackTrace();
                request.setAttribute("error", "Database error during booking reservation: " + e.getMessage());
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Invalid date format or parameters.");
        }

        request.getRequestDispatcher("catalog.jsp").forward(request, response);
    }
}