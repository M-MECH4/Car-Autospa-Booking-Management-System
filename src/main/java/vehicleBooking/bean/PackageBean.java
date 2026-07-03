package vehicleBooking.bean;

public class PackageBean {

    private String packageID;
    private String packageName;
    private double packagePrice;
    private String packageDesc;
    private String serviceName;
    private String packageStatus;

    public PackageBean() {
    }

    public String getPackageID() {
        return packageID;
    }

    public void setPackageID(String packageID) {
        this.packageID = packageID;
    }

    public String getPackageName() {
        return packageName;
    }

    public void setPackageName(String packageName) {
        this.packageName = packageName;
    }

    public double getPackagePrice() {
        return packagePrice;
    }

    public void setPackagePrice(double packagePrice) {
        this.packagePrice = packagePrice;
    }

    public String getPackageDesc() {
        return packageDesc;
    }

    public void setPackageDesc(String packageDesc) {
        this.packageDesc = packageDesc;
    }

    public String getServiceName() {
        return serviceName;
    }

    public void setServiceName(String serviceName) {
        this.serviceName = serviceName;
    }

    public String getPackageStatus() {
        if (packageStatus == null || packageStatus.trim().isEmpty()) {
            return "AVAILABLE";
        }
        return packageStatus;
    }

    public void setPackageStatus(String packageStatus) {
        this.packageStatus = packageStatus;
    }
}