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

@WebServlet("/UpdateVehicleStatusServlet")
public class UpdateVehicleStatusServlet extends HttpServlet {

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
        String newStatus = request.getParameter("status");

        if (vehicleIdStr != null && newStatus != null) {
            try (Connection conn = DBConnection.getConnection()) {
                String sql = "UPDATE vehicles SET status = ? WHERE vehicle_id = ?";
                PreparedStatement stmt = conn.prepareStatement(sql);
                stmt.setString(1, newStatus.toUpperCase());
                stmt.setInt(2, Integer.parseInt(vehicleIdStr));
                stmt.executeUpdate();

                request.setAttribute("message", "Vehicle #" + vehicleIdStr + " status updated to " + newStatus.toUpperCase());
            } catch (SQLException | NumberFormatException e) {
                request.setAttribute("error", "Error updating vehicle status: " + e.getMessage());
            }
        }

        request.getRequestDispatcher("admin_bookings.jsp").forward(request, response);
    }
}