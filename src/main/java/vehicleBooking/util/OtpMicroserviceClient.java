package vehicleBooking.util;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;

public class OtpMicroserviceClient {

    private static final String BASE_URL =
            "http://localhost:8081/otp-service/api/otp";

    public static boolean createOtp(String userId, String role, String email) {
        try {
            URL url = new URL(BASE_URL + "/create");
            HttpURLConnection con = (HttpURLConnection) url.openConnection();

            con.setRequestMethod("POST");
            con.setRequestProperty("Content-Type", "application/json");
            con.setDoOutput(true);

            String json = "{"
                    + "\"userId\":\"" + escape(userId) + "\","
                    + "\"userRole\":\"" + escape(role) + "\","
                    + "\"email\":\"" + escape(email) + "\""
                    + "}";

            try (OutputStream os = con.getOutputStream()) {
                os.write(json.getBytes("UTF-8"));
            }

            String response = readResponse(con);

            return con.getResponseCode() == 200
                    && response.contains("\"success\":true");

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public static boolean verifyOtp(String userId, String role, String otpCode) {
        try {
            URL url = new URL(BASE_URL + "/verify");
            HttpURLConnection con = (HttpURLConnection) url.openConnection();

            con.setRequestMethod("POST");
            con.setRequestProperty("Content-Type", "application/json");
            con.setDoOutput(true);

            String json = "{"
                    + "\"userId\":\"" + escape(userId) + "\","
                    + "\"userRole\":\"" + escape(role) + "\","
                    + "\"otpCode\":\"" + escape(otpCode) + "\""
                    + "}";

            try (OutputStream os = con.getOutputStream()) {
                os.write(json.getBytes("UTF-8"));
            }

            String response = readResponse(con);

            return con.getResponseCode() == 200
                    && response.contains("\"success\":true");

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    private static String readResponse(HttpURLConnection con) throws Exception {
        BufferedReader br;

        if (con.getResponseCode() >= 200 && con.getResponseCode() < 300) {
            br = new BufferedReader(new InputStreamReader(con.getInputStream()));
        } else {
            br = new BufferedReader(new InputStreamReader(con.getErrorStream()));
        }

        StringBuilder sb = new StringBuilder();
        String line;

        while ((line = br.readLine()) != null) {
            sb.append(line);
        }

        br.close();
        return sb.toString();
    }

    private static String escape(String value) {
        if (value == null) return "";
        return value.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}