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
import java.sql.SQLException;

@WebServlet("/UpdateVehiclePriceServlet")
public class UpdateVehiclePriceServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("userRole");

        if (role == null || !"ADMIN".equalsIgnoreCase(role)) {
            response.sendRedirect("index.jsp");
            return;
        }

        String vehicleIdStr = request.getParameter("vehicleId");
        String newPriceStr = request.getParameter("pricePerDay");

        if (vehicleIdStr != null && newPriceStr != null) {
            try (Connection conn = DBConnection.getConnection()) {
                double newPrice = Double.parseDouble(newPriceStr);
                String sql = "UPDATE vehicles SET price_per_day = ? WHERE vehicle_id = ?";
                PreparedStatement stmt = conn.prepareStatement(sql);
                stmt.setDouble(1, newPrice);
                stmt.setInt(2, Integer.parseInt(vehicleIdStr));
                stmt.executeUpdate();

                request.setAttribute("message", "Rate for Vehicle #" + vehicleIdStr + " updated to ₹" + newPrice);
            } catch (SQLException | NumberFormatException e) {
                request.setAttribute("error", "Error updating daily price: " + e.getMessage());
            }
        }

        request.getRequestDispatcher("admin_bookings.jsp").forward(request, response);
    }
}