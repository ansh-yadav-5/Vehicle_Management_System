package example; // Ensure this matches your project's package structure

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String role = request.getParameter("role"); // 'CUSTOMER' or 'ADMIN'

        if (email == null || password == null || email.trim().isEmpty() || password.trim().isEmpty()) {
            request.setAttribute("error", "Email and Password are required.");
            request.getRequestDispatcher("index.jsp").forward(request, response);
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            String sql;

            // Query based on role selected from index.jsp
            if ("ADMIN".equalsIgnoreCase(role)) {
                sql = "SELECT * FROM users WHERE email = ? AND password = ? AND role = 'ADMIN'";
            } else {
                sql = "SELECT * FROM users WHERE email = ? AND password = ?";
            }

            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, email.trim());
                stmt.setString(2, password.trim());

                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        HttpSession session = request.getSession(true);
                        session.setAttribute("userId", rs.getInt("user_id"));
                        session.setAttribute("userName", rs.getString("name"));

                        String userRole = rs.getString("role");
                        if (userRole == null || userRole.trim().isEmpty()) {
                            userRole = "CUSTOMER";
                        }
                        session.setAttribute("userRole", userRole);

                        // Redirect based on role
                        if ("ADMIN".equalsIgnoreCase(userRole)) {
                            response.sendRedirect("admin_dashboard.jsp");
                        } else {
                            response.sendRedirect("catalog.jsp");
                        }
                    } else {
                        request.setAttribute("error", "Invalid credentials. Please try again.");
                        request.getRequestDispatcher("index.jsp").forward(request, response);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
            request.getRequestDispatcher("index.jsp").forward(request, response);
        }
    }
}