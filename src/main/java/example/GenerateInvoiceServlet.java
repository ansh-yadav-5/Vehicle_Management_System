package example;

import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;
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

@WebServlet("/GenerateInvoiceServlet")
public class GenerateInvoiceServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");
        String bookingIdStr = request.getParameter("bookingId");

        if (bookingIdStr == null || bookingIdStr.trim().isEmpty()) {
            response.sendRedirect("my_bookings.jsp");
            return;
        }

        int bookingId = Integer.parseInt(bookingIdStr);

        try (Connection conn = DBConnection.getConnection()) {
            // Removed u.phone from query to fix SQLSyntaxErrorException
            String sql = "SELECT b.*, u.name AS customer_name, u.email, v.title AS vehicle_title, v.brand, v.price_per_day " +
                    "FROM bookings b " +
                    "JOIN users u ON b.user_id = u.user_id " +
                    "JOIN vehicles v ON b.vehicle_id = v.vehicle_id " +
                    "WHERE b.booking_id = ? AND b.user_id = ?";

            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, bookingId);
                stmt.setInt(2, userId);

                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        response.reset();
                        response.setContentType("application/pdf");
                        response.setHeader("Content-Disposition", "attachment; filename=\"DriveEazy_Invoice_#" + bookingId + ".pdf\"");

                        Document document = new Document(PageSize.A4, 36, 36, 36, 36);
                        PdfWriter.getInstance(document, response.getOutputStream());
                        document.open();

                        // Header / Title Styling
                        Font headerFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 22, BaseColor.BLACK);
                        Font subFont = FontFactory.getFont(FontFactory.HELVETICA, 10, BaseColor.GRAY);
                        Font boldFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12, BaseColor.BLACK);
                        Font normalFont = FontFactory.getFont(FontFactory.HELVETICA, 11, BaseColor.DARK_GRAY);

                        Paragraph title = new Paragraph("DriveEazy - Rental Invoice", headerFont);
                        title.setAlignment(Element.ALIGN_CENTER);
                        document.add(title);

                        Paragraph sub = new Paragraph("Booking Receipt & Payment Confirmation\n\n", subFont);
                        sub.setAlignment(Element.ALIGN_CENTER);
                        document.add(sub);

                        // Invoice Details Table
                        PdfPTable table = new PdfPTable(2);
                        table.setWidthPercentage(100);
                        table.setSpacingBefore(10f);

                        addTableRow(table, "Invoice ID:", "#INV-" + bookingId, boldFont, normalFont);
                        addTableRow(table, "Customer Name:", rs.getString("customer_name"), boldFont, normalFont);
                        addTableRow(table, "Customer Email:", rs.getString("email"), boldFont, normalFont);
                        addTableRow(table, "Vehicle Reserved:", rs.getString("brand") + " " + rs.getString("vehicle_title"), boldFont, normalFont);
                        addTableRow(table, "Rental Duration:", rs.getString("pickup_date") + " to " + rs.getString("return_date"), boldFont, normalFont);
                        addTableRow(table, "Total Days:", rs.getInt("total_days") + " Days", boldFont, normalFont);
                        addTableRow(table, "Daily Rate:", "INR " + rs.getDouble("price_per_day"), boldFont, normalFont);
                        addTableRow(table, "Delivery Mode:", rs.getString("delivery_type"), boldFont, normalFont);
                        addTableRow(table, "KYC Status:", rs.getString("kyc_status"), boldFont, normalFont);
                        addTableRow(table, "Total Paid:", "INR " + String.format("%.2f", rs.getDouble("total_price")), boldFont, boldFont);

                        document.add(table);

                        Paragraph footer = new Paragraph("\n\nThank you for choosing DriveEazy! Have a safe journey.", subFont);
                        footer.setAlignment(Element.ALIGN_CENTER);
                        document.add(footer);

                        document.close();
                        response.getOutputStream().flush();
                    } else {
                        response.sendRedirect("my_bookings.jsp?error=Invoice record not found");
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("my_bookings.jsp?error=Error generating PDF invoice");
        }
    }

    private void addTableRow(PdfPTable table, String label, String value, Font labelFont, Font valueFont) {
        PdfPCell cell1 = new PdfPCell(new Phrase(label, labelFont));
        PdfPCell cell2 = new PdfPCell(new Phrase(value, valueFont));
        cell1.setPadding(8);
        cell2.setPadding(8);
        table.addCell(cell1);
        table.addCell(cell2);
    }
}