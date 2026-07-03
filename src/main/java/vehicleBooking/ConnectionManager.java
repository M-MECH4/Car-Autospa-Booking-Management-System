package vehicleBooking;

/*
 * Author: FES (March 2025)
 */
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class ConnectionManager {
	static Connection con;
		
	//define and initialize database driver for Oracle
	private static final String DB_DRIVER = "oracle.jdbc.driver.OracleDriver";
	//define and initialize database url for Oracle
	private static final String DB_CONNECTION = "jdbc:oracle:thin:@//localhost:1521/freepdb1";
	//define and initialize database user
	private static final String DB_USER = "MUSTANG";
	//define and initialize database password
	private static final String DB_PASSWORD = "oracle";

	public static Connection getConnection() {

		try {
			//1. load the driver
			Class.forName(DB_DRIVER);

			try {
				//2. create connection
				con = DriverManager.getConnection(DB_CONNECTION,DB_USER,DB_PASSWORD);
				System.out.println("Connected");
			}catch(SQLException e) {
				e.printStackTrace();
			}
		}catch(ClassNotFoundException e) {
			e.printStackTrace();
		}		
		return con;
	}
}