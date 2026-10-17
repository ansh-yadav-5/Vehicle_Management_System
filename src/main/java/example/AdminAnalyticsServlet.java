package example;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/AdminAnalyticsServlet")
public class AdminAnalyticsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminUser") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        StringBuilder json = new StringBuilder();
        json.append("{");

        try (Connection conn = DBConnection.getConnection()) {
            if (conn != null) {

                // 1. Total Revenue Summary Metrics
                String summarySql = "SELECT " +
                        "COALESCE(SUM(total_price), 0) AS total_revenue, " +
                        "COALESCE(SUM(CASE WHEN pickup_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY) THEN total_price ELSE 0 END), 0) AS weekly_revenue, " +
                        "COALESCE(SUM(CASE WHEN pickup_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY) THEN total_price ELSE 0 END), 0) AS monthly_revenue " +
                        "FROM bookings WHERE kyc_status IN ('APPROVED', 'ACTIVE', 'COMPLETED')";

                try (PreparedStatement stmt = conn.prepareStatement(summarySql);
                     ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        json.append("\"totalRevenue\": ").append(rs.getDouble("total_revenue")).append(",");
                        json.append("\"weeklyRevenue\": ").append(rs.getDouble("weekly_revenue")).append(",");
                        json.append("\"monthlyRevenue\": ").append(rs.getDouble("monthly_revenue")).append(",");
                    }
                }

                // 2. Daily Revenue (Last 7 Days)
                json.append("\"dailyRevenue\": [");
                String dailySql = "SELECT DATE_FORMAT(pickup_date, '%b %d') AS label, COALESCE(SUM(total_price), 0) AS val " +
                        "FROM bookings WHERE kyc_status IN ('APPROVED', 'ACTIVE', 'COMPLETED') " +
                        "AND pickup_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 6 DAY) " +
                        "GROUP BY DATE(pickup_date) ORDER BY pickup_date ASC";
                try (PreparedStatement stmt = conn.prepareStatement(dailySql);
                     ResultSet rs = stmt.executeQuery()) {
                    boolean first = true;
                    while (rs.next()) {
                        if (!first) json.append(",");
                        json.append("{\"label\":\"").append(rs.getString("label")).append("\", \"val\":").append(rs.getDouble("val")).append("}");
                        first = false;
                    }
                }
                json.append("],");

                // 3. Monthly Revenue (Last 6 Months)
                json.append("\"monthlyTrend\": [");
                String monthlyTrendSql = "SELECT DATE_FORMAT(pickup_date, '%b %Y') AS label, COALESCE(SUM(total_price), 0) AS val " +
                        "FROM bookings WHERE kyc_status IN ('APPROVED', 'ACTIVE', 'COMPLETED') " +
                        "GROUP BY YEAR(pickup_date), MONTH(pickup_date) ORDER BY pickup_date ASC LIMIT 6";
                try (PreparedStatement stmt = conn.prepareStatement(monthlyTrendSql);
                     ResultSet rs = stmt.executeQuery()) {
                    boolean first = true;
                    while (rs.next()) {
                        if (!first) json.append(",");
                        json.append("{\"label\":\"").append(rs.getString("label")).append("\", \"val\":").append(rs.getDouble("val")).append("}");
                        first = false;
                    }
                }
                json.append("],");

                // 4. Fleet Utilization (Cars vs Bikes)
                json.append("\"categoryBreakdown\": [");
                String catSql = "SELECT v.category, COUNT(b.booking_id) AS total_bookings " +
                        "FROM vehicles v LEFT JOIN bookings b ON v.vehicle_id = b.vehicle_id " +
                        "GROUP BY v.category";
                try (PreparedStatement stmt = conn.prepareStatement(catSql);
                     ResultSet rs = stmt.executeQuery()) {
                    boolean first = true;
                    while (rs.next()) {
                        if (!first) json.append(",");
                        json.append("{\"category\":\"").append(rs.getString("category")).append("\", \"count\":").append(rs.getInt("total_bookings")).append("}");
                        first = false;
                    }
                }
                json.append("],");

                // 5. Fleet Idle vs Rented Ratio
                String fleetRatioSql = "SELECT " +
                        "SUM(CASE WHEN status = 'AVAILABLE' THEN 1 ELSE 0 END) AS idle_count, " +
                        "SUM(CASE WHEN status = 'BOOKED' THEN 1 ELSE 0 END) AS rented_count, " +
                        "COUNT(*) AS total_fleet FROM vehicles";
                try (PreparedStatement stmt = conn.prepareStatement(fleetRatioSql);
                     ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        json.append("\"idleFleet\": ").append(rs.getInt("idle_count")).append(",");
                        json.append("\"rentedFleet\": ").append(rs.getInt("rented_count")).append(",");
                        json.append("\"totalFleet\": ").append(rs.getInt("total_fleet")).append(",");
                    }
                }

                // 6. Top 5 Most Rented Vehicle Models
                json.append("\"topVehicles\": [");
                String topVehiclesSql = "SELECT v.title, v.brand, COUNT(b.booking_id) AS rental_count, COALESCE(SUM(b.total_price), 0) AS total_gen " +
                        "FROM vehicles v JOIN bookings b ON v.vehicle_id = b.vehicle_id " +
                        "WHERE b.kyc_status IN ('APPROVED', 'ACTIVE', 'COMPLETED') " +
                        "GROUP BY v.vehicle_id ORDER BY rental_count DESC LIMIT 5";
                try (PreparedStatement stmt = conn.prepareStatement(topVehiclesSql);
                     ResultSet rs = stmt.executeQuery()) {
                    boolean first = true;
                    while (rs.next()) {
                        if (!first) json.append(",");
                        json.append("{\"title\":\"").append(rs.getString("title").replace("\"", "\\\"")).append("\", ")
                                .append("\"brand\":\"").append(rs.getString("brand")).append("\", ")
                                .append("\"rentals\":").append(rs.getInt("rental_count")).append(", ")
                                .append("\"revenue\":").append(rs.getDouble("total_gen")).append("}");
                        first = false;
                    }
                }
                json.append("],");

                // 7. Customer Lifetime Value (LTV) Leaderboard
                json.append("\"customerLtv\": [");
                String ltvSql = "SELECT u.name, u.email, COUNT(b.booking_id) AS total_trips, COALESCE(SUM(b.total_price), 0) AS ltv_amount " +
                        "FROM users u JOIN bookings b ON u.user_id = b.user_id " +
                        "WHERE b.kyc_status IN ('APPROVED', 'ACTIVE', 'COMPLETED') " +
                        "GROUP BY u.user_id ORDER BY ltv_amount DESC LIMIT 5";
                try (PreparedStatement stmt = conn.prepareStatement(ltvSql);
                     ResultSet rs = stmt.executeQuery()) {
                    boolean first = true;
                    while (rs.next()) {
                        if (!first) json.append(",");
                        json.append("{\"name\":\"").append(rs.getString("name").replace("\"", "\\\"")).append("\", ")
                                .append("\"email\":\"").append(rs.getString("email")).append("\", ")
                                .append("\"trips\":").append(rs.getInt("total_trips")).append(", ")
                                .append("\"ltv\":").append(rs.getDouble("ltv_amount")).append("}");
                        first = false;
                    }
                }
                json.append("]");

            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        json.append("}");

        PrintWriter out = response.getWriter();
        out.print(json.toString());
        out.flush();
    }
}