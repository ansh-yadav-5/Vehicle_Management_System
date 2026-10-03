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

@WebServlet("/VerifyKYCServlet")
public class VerifyKYCServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("userRole");

        if (role == null || !"ADMIN".equalsIgnoreCase(role)) {
            response.sendRedirect("index.jsp");
            return;
        }

        String bookingIdStr = request.getParameter("bookingId");
        String kycStatus = request.getParameter("kycStatus"); // APPROVED or REJECTED

        if (bookingIdStr != null && kycStatus != null) {
            try (Connection conn = DBConnection.getConnection()) {
                String sql = "UPDATE bookings SET kyc_status = ? WHERE booking_id = ?";
                PreparedStatement stmt = conn.prepareStatement(sql);
                stmt.setString(1, kycStatus.toUpperCase());
                stmt.setInt(2, Integer.parseInt(bookingIdStr));
                stmt.executeUpdate();

                request.setAttribute("message", "Booking #" + bookingIdStr + " KYC status updated to " + kycStatus);
            } catch (Exception e) {
                request.setAttribute("error", "Error updating KYC status: " + e.getMessage());
            }
        }

        request.getRequestDispatcher("admin_bookings.jsp").forward(request, response);
    }
}