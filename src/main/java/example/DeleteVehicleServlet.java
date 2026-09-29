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

@WebServlet("/DeleteVehicleServlet")
public class DeleteVehicleServlet extends HttpServlet {

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

        if (vehicleIdStr != null) {
            try (Connection conn = DBConnection.getConnection()) {
                String sql = "DELETE FROM vehicles WHERE vehicle_id = ?";
                PreparedStatement stmt = conn.prepareStatement(sql);
                stmt.setInt(1, Integer.parseInt(vehicleIdStr));
                stmt.executeUpdate();

                request.setAttribute("message", "Vehicle #" + vehicleIdStr + " successfully removed from fleet.");
            } catch (SQLException | NumberFormatException e) {
                request.setAttribute("error", "Cannot delete vehicle with active bookings. Error: " + e.getMessage());
            }
        }

        request.getRequestDispatcher("admin_bookings.jsp").forward(request, response);
    }
}