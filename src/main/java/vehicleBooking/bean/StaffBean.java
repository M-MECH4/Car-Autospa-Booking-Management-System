package vehicleBooking.bean;

public class StaffBean {

    private String staffID;
    private String staffName;
    private String staffEmail;
    private String staffUsername;
    private String staffPassword;
    private String staffPhoneNum;
    private String staffRole;
    private String ownerID;
    private int relatedRecordCount;

    public StaffBean() {
    }

    public String getStaffID() {
        return staffID;
    }

    public void setStaffID(String staffID) {
        this.staffID = staffID;
    }

    public String getStaffName() {
        return staffName;
    }

    public void setStaffName(String staffName) {
        this.staffName = staffName;
    }

    public String getStaffEmail() {
        return staffEmail;
    }

    public void setStaffEmail(String staffEmail) {
        this.staffEmail = staffEmail;
    }

    public String getStaffUsername() {
        return staffUsername;
    }

    public void setStaffUsername(String staffUsername) {
        this.staffUsername = staffUsername;
    }

    public String getStaffPassword() {
        return staffPassword;
    }

    public void setStaffPassword(String staffPassword) {
        this.staffPassword = staffPassword;
    }

    public String getStaffPhoneNum() {
        return staffPhoneNum;
    }

    public void setStaffPhoneNum(String staffPhoneNum) {
        this.staffPhoneNum = staffPhoneNum;
    }

    public String getStaffRole() {
        return staffRole;
    }

    public void setStaffRole(String staffRole) {
        this.staffRole = staffRole;
    }

    public String getOwnerID() {
        return ownerID;
    }

    public void setOwnerID(String ownerID) {
        this.ownerID = ownerID;
    }


    public int getRelatedRecordCount() {
        return relatedRecordCount;
    }

    public void setRelatedRecordCount(int relatedRecordCount) {
        this.relatedRecordCount = relatedRecordCount;
    }

    public boolean isDeleteAllowed() {
        return relatedRecordCount <= 0;
    }
}