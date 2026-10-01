package example;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
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

        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("userRole");

        if (role == null || !"ADMIN".equalsIgnoreCase(role)) {
            response.sendRedirect("index.jsp");
            return;
        }

        String title = request.getParameter("title");
        String brand = request.getParameter("brand");
        String category = request.getParameter("category");
        String priceStr = request.getParameter("pricePerDay");
        String description = request.getParameter("description");

        // Handle File Upload
        Part filePart = request.getPart("imageFile");
        String dbImagePath = "https://via.placeholder.com/320x190?text=VMS+Drive"; // Fallback default

        if (filePart != null && filePart.getSize() > 0) {
            String fileName = extractFileName(filePart);

            // Get real path of the uploads folder on server
            String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdir();
            }

            // Generate unique filename to avoid overwriting existing images
            String uniqueFileName = System.currentTimeMillis() + "_" + fileName;
            String filePath = uploadPath + File.separator + uniqueFileName;

            // Save file on server
            filePart.write(filePath);

            // Save relative web path to database
            dbImagePath = UPLOAD_DIR + "/" + uniqueFileName;
        }

        try (Connection conn = DBConnection.getConnection()) {
            double pricePerDay = Double.parseDouble(priceStr);
            String sql = "INSERT INTO vehicles (title, brand, category, price_per_day, image_path, description, status) " +
                    "VALUES (?, ?, ?, ?, ?, ?, 'AVAILABLE')";

            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1, title);
            stmt.setString(2, brand);
            stmt.setString(3, category);
            stmt.setDouble(4, pricePerDay);
            stmt.setString(5, dbImagePath);
            stmt.setString(6, description);

            stmt.executeUpdate();
            request.setAttribute("message", "Vehicle successfully added with uploaded image!");

        } catch (SQLException | NumberFormatException e) {
            request.setAttribute("error", "Failed to add vehicle: " + e.getMessage());
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
        return "vehicle.jpg";
    }
}