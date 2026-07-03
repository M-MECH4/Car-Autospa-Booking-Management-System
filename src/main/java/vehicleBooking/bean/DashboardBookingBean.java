package vehicleBooking.bean;

public class DashboardBookingBean {

    private String bookingDate;
    private String vehiclePlateNum;
    private String packageName;
    private String bookingStatus;
    private double amount;

    public DashboardBookingBean() {
    }

    public String getBookingDate() {
        return bookingDate;
    }

    public void setBookingDate(String bookingDate) {
        this.bookingDate = bookingDate;
    }

    public String getVehiclePlateNum() {
        return vehiclePlateNum;
    }

    public void setVehiclePlateNum(String vehiclePlateNum) {
        this.vehiclePlateNum = vehiclePlateNum;
    }

    public String getPackageName() {
        return packageName;
    }

    public void setPackageName(String packageName) {
        this.packageName = packageName;
    }

    public String getBookingStatus() {
        return bookingStatus;
    }

    public void setBookingStatus(String bookingStatus) {
        this.bookingStatus = bookingStatus;
    }

    public double getAmount() {
        return amount;
    }

    public void setAmount(double amount) {
        this.amount = amount;
    }
}