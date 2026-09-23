package example;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

@WebServlet("/AddVehicleServlet")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 10,      // 10MB
        maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class AddVehicleServlet extends HttpServlet {

    private static final String UPLOAD_DIR = "uploads";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String title = request.getParameter("title");
        String brand = request.getParameter("brand");
        String category = request.getParameter("category");
        double pricePerDay = Double.parseDouble(request.getParameter("pricePerDay"));
        String description = request.getParameter("description");

        // Handle Image File Upload
        Part filePart = request.getPart("image");
        String fileName = extractFileName(filePart);

        // Get absolute path to the web application directory
        String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdir();
        }

        String dbImagePath = UPLOAD_DIR + "/" + fileName;
        if (fileName != null && !fileName.isEmpty()) {
            filePart.write(uploadPath + File.separator + fileName);
        } else {
            dbImagePath = "assets/default_vehicle.jpg"; // Default fallback image
        }

        // Save Vehicle Record into MySQL Database
        try (Connection conn = DBConnection.getConnection()) {
            String sql = "INSERT INTO vehicles (title, brand, category, price_per_day, status, image_path, description) " +
                    "VALUES (?, ?, ?, ?, 'AVAILABLE', ?, ?)";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1, title);
            stmt.setString(2, brand);
            stmt.setString(3, category);
            stmt.setDouble(4, pricePerDay);
            stmt.setString(5, dbImagePath);
            stmt.setString(6, description);

            int rowsInserted = stmt.executeUpdate();

            if (rowsInserted > 0) {
                request.setAttribute("message", "Vehicle added successfully!");
            } else {
                request.setAttribute("error", "Failed to add vehicle.");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
        }

        request.getRequestDispatcher("admin_dashboard.jsp").forward(request, response);
    }

    private String extractFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] items = contentDisp.split(";");
        for (String s : items) {
            if (s.trim().startsWith("filename")) {
                return s.substring(s.indexOf("=") + 2, s.length() - 1);
            }
        }
        return "";
    }
}