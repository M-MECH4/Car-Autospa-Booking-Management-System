package vehicleBooking.bean;

import java.io.Serializable;

public class CustomerBean implements Serializable {

    private static final long serialVersionUID = 1L;

    private String custID;
    private String custName;
    private String custEmail;
    private String custUsername;
    private String custPassword;
    private String custPhoneNum;

    // New attributes for festive package eligibility
    private String custRace;
    private String custReligion;

    private boolean loggedIn;

    public CustomerBean() {
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

    public String getCustPassword() {
        return custPassword;
    }

    public void setCustPassword(String custPassword) {
        this.custPassword = custPassword;
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

    public boolean isLoggedIn() {
        return loggedIn;
    }

    public void setLoggedIn(boolean loggedIn) {
        this.loggedIn = loggedIn;
    }
}