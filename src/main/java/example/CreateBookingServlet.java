package example; // Change this to match your project's package structure

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
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
            response.sendRedirect("catalog.jsp");
            return;
        }

        try {
            int vehicleId = Integer.parseInt(vehicleIdStr);
            LocalDate pickupDate = LocalDate.parse(pickupDateStr);
            LocalDate returnDate = LocalDate.parse(returnDateStr);

            long totalDays = ChronoUnit.DAYS.between(pickupDate, returnDate);
            if (totalDays <= 0) {
                totalDays = 1;
            }

            double pricePerDay = 0.0;

            try (Connection conn = DBConnection.getConnection()) {
                String rateSql = "SELECT price_per_day FROM vehicles WHERE vehicle_id = ?";
                try (PreparedStatement stmt = conn.prepareStatement(rateSql)) {
                    stmt.setInt(1, vehicleId);
                    try (ResultSet rs = stmt.executeQuery()) {
                        if (rs.next()) {
                            pricePerDay = rs.getDouble("price_per_day");
                        }
                    }
                }

                double totalPrice = pricePerDay * totalDays;
                if ("DOORSTEP".equalsIgnoreCase(deliveryType)) {
                    totalPrice += 300.0;
                }

                String insertSql = "INSERT INTO bookings (user_id, vehicle_id, pickup_date, return_date, total_days, total_price, delivery_type, kyc_status) VALUES (?, ?, ?, ?, ?, ?, ?, 'PENDING')";
                try (PreparedStatement stmt = conn.prepareStatement(insertSql)) {
                    stmt.setInt(1, userId);
                    stmt.setInt(2, vehicleId);
                    stmt.setString(3, pickupDateStr);
                    stmt.setString(4, returnDateStr);
                    stmt.setLong(5, totalDays);
                    stmt.setDouble(6, totalPrice);
                    stmt.setString(7, deliveryType);
                    stmt.executeUpdate();
                }
            }

            response.sendRedirect("my_bookings.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("catalog.jsp");
        }
    }
}