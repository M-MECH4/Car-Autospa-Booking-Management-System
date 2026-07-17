package vehicleBooking.bean;

public class ManageCustomerBean {

    private String custID;
    private String custName;
    private String custEmail;
    private String custUsername;
    private String custPhoneNum;

    // New attributes for festive package eligibility
    private String custRace;
    private String custReligion;

    private int relatedRecordCount;

    public ManageCustomerBean() {
    }

    public String getCustID() {
        return custID;
    }

    public void setCustID(String custID) {
        this.custID = custID;
    }

    public String getCustName() {
        return custName;
    }

    public void setCustName(String custName) {
        this.custName = custName;
    }

    public String getCustEmail() {
        return custEmail;
    }

    public void setCustEmail(String custEmail) {
        this.custEmail = custEmail;
    }

    public String getCustUsername() {
        return custUsername;
    }

    public void setCustUsername(String custUsername) {
        this.custUsername = custUsername;
    }

    public String getCustPhoneNum() {
        return custPhoneNum;
    }

    public void setCustPhoneNum(String custPhoneNum) {
        this.custPhoneNum = custPhoneNum;
    }

    public String getCustRace() {
        return custRace;
    }

    public void setCustRace(String custRace) {
        this.custRace = custRace;
    }

    public String getCustReligion() {
        return custReligion;
    }

    public void setCustReligion(String custReligion) {
        this.custReligion = custReligion;
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