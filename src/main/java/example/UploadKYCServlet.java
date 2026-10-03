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

@WebServlet("/UploadKYCServlet")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 10,      // 10MB
        maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class UploadKYCServlet extends HttpServlet {

    private static final String UPLOAD_DIR = "uploads/kyc";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String userName = (String) session.getAttribute("userName");

        if (userName == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        String bookingIdStr = request.getParameter("bookingId");
        String dlNumber = request.getParameter("dlNumber");
        Part filePart = request.getPart("kycDocument");

        if (bookingIdStr != null && filePart != null && filePart.getSize() > 0) {
            String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }

            String fileName = System.currentTimeMillis() + "_" + extractFileName(filePart);
            String filePath = uploadPath + File.separator + fileName;
            filePart.write(filePath);

            String dbDocPath = UPLOAD_DIR + "/" + fileName;

            try (Connection conn = DBConnection.getConnection()) {
                String sql = "UPDATE bookings SET dl_number = ?, kyc_document_path = ?, kyc_status = 'PENDING' WHERE booking_id = ?";
                PreparedStatement stmt = conn.prepareStatement(sql);
                stmt.setString(1, dlNumber);
                stmt.setString(2, dbDocPath);
                stmt.setInt(3, Integer.parseInt(bookingIdStr));
                stmt.executeUpdate();

                request.setAttribute("message", "KYC Document submitted successfully! Pending verification.");
            } catch (Exception e) {
                request.setAttribute("error", "Failed to upload KYC: " + e.getMessage());
            }
        }

        request.getRequestDispatcher("my_bookings.jsp").forward(request, response);
    }

    private String extractFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        for (String s : contentDisp.split(";")) {
            if (s.trim().startsWith("filename")) {
                return s.substring(s.indexOf("=") + 2, s.length() - 1);
            }
        }
        return "dl_doc.jpg";
    }
}