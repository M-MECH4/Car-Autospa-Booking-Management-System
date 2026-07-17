package vehicleBooking.util;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;

public class OtpMicroserviceClient {

	private static final String BASE_URL =
		    "https://xpert-otp-service-mustang-0448d57dbcd5.herokuapp.com/api/otp";

    public static boolean createOtp(String userid, String userrole, String email) {
        try {
            URL url = new URL(BASE_URL + "/create");
            HttpURLConnection con = (HttpURLConnection) url.openConnection();

            con.setRequestMethod("POST");
            con.setRequestProperty("Content-Type", "application/json");
            con.setDoOutput(true);

            String json = "{"
                    + "\"userid\":\"" + userid + "\","
                    + "\"userrole\":\"" + userrole + "\","
                    + "\"email\":\"" + email + "\""
                    + "}";

            OutputStream os = con.getOutputStream();
            os.write(json.getBytes());
            os.flush();
            os.close();

            BufferedReader br = new BufferedReader(
                    new InputStreamReader(con.getInputStream())
            );

            String response = br.readLine();
            return response != null && response.contains("\"success\":true");

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public static boolean verifyOtp(String userid, String userrole, String otpCode) {
        try {
            URL url = new URL(BASE_URL + "/verify");
            HttpURLConnection con = (HttpURLConnection) url.openConnection();

            con.setRequestMethod("POST");
            con.setRequestProperty("Content-Type", "application/json");
            con.setDoOutput(true);

            String json = "{"
                    + "\"userid\":\"" + userid + "\","
                    + "\"userrole\":\"" + userrole + "\","
                    + "\"otpCode\":\"" + otpCode + "\""
                    + "}";

            OutputStream os = con.getOutputStream();
            os.write(json.getBytes());
            os.flush();
            os.close();

            BufferedReader br = new BufferedReader(
                    new InputStreamReader(con.getInputStream())
            );

            String response = br.readLine();
            return response != null && response.contains("\"success\":true");

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}