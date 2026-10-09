package example; // Ensure this matches your project package name

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

@WebListener
public class AutoReturnListener implements ServletContextListener {

    private ScheduledExecutorService scheduler;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        // Create a scheduled background thread executor
        scheduler = Executors.newSingleThreadScheduledExecutor();

        // Run check immediately on startup, then re-check every 5 minutes
        scheduler.scheduleAtFixedRate(() -> {
            checkAndAutoReturnVehicles();
        }, 0, 5, TimeUnit.MINUTES);
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (scheduler != null && !scheduler.isShutdown()) {
            scheduler.shutdownNow(); // Fixed: changed shutdownWithNow() to shutdownNow()
        }
    }

    private void checkAndAutoReturnVehicles() {
        // Query to find all active/approved bookings whose return date is in the past
        String findExpiredSql = "SELECT booking_id, vehicle_id FROM bookings " +
                "WHERE kyc_status IN ('APPROVED', 'ACTIVE') AND return_date < CURRENT_DATE()";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);

            try (PreparedStatement stmt = conn.prepareStatement(findExpiredSql);
                 ResultSet rs = stmt.executeQuery()) {

                String completeBookingSql = "UPDATE bookings SET kyc_status = 'COMPLETED' WHERE booking_id = ?";
                String releaseVehicleSql = "UPDATE vehicles SET status = 'AVAILABLE' WHERE vehicle_id = ?";

                try (PreparedStatement pstmtBooking = conn.prepareStatement(completeBookingSql);
                     PreparedStatement pstmtVehicle = conn.prepareStatement(releaseVehicleSql)) {

                    boolean hasUpdates = false;

                    while (rs.next()) {
                        int bookingId = rs.getInt("booking_id");
                        int vehicleId = rs.getInt("vehicle_id");

                        // 1. Mark booking completed
                        pstmtBooking.setInt(1, bookingId);
                        pstmtBooking.addBatch();

                        // 2. Mark vehicle available for catalog.jsp
                        pstmtVehicle.setInt(1, vehicleId);
                        pstmtVehicle.addBatch();

                        hasUpdates = true;
                    }

                    if (hasUpdates) {
                        pstmtBooking.executeBatch();
                        pstmtVehicle.executeBatch();
                        conn.commit();
                        System.out.println("[AutoReturnListener] Auto-returned expired vehicles to fleet catalog.");
                    } else {
                        conn.rollback();
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}