package vehicleBooking.bean;

import java.io.Serializable;

public class FestivalBean extends PackageBean implements Serializable {

    private static final long serialVersionUID = 1L;

    private String festivalName;
    private String startDate;
    private String endDate;
    private double discountRate;

    // New attributes for festive package eligibility
    private String targetRace;
    private String targetReligion;

    public FestivalBean() {
    }

    public String getFestivalName() {
        return festivalName;
    }

    public void setFestivalName(String festivalName) {
        this.festivalName = festivalName;
    }

    public String getStartDate() {
        return startDate;
    }

    public void setStartDate(String startDate) {
        this.startDate = startDate;
    }

    public String getEndDate() {
        return endDate;
    }

    public void setEndDate(String endDate) {
        this.endDate = endDate;
    }

    public double getDiscountRate() {
        return discountRate;
    }

    public void setDiscountRate(double discountRate) {
        this.discountRate = discountRate;
    }

    public String getTargetRace() {
        if (targetRace == null || targetRace.trim().isEmpty()) {
            return "ALL";
        }

        return targetRace;
    }

    public void setTargetRace(String targetRace) {
        this.targetRace = targetRace;
    }

    public String getTargetReligion() {
        if (targetReligion == null || targetReligion.trim().isEmpty()) {
            return "ALL";
        }

        return targetReligion;
    }

    public void setTargetReligion(String targetReligion) {
        this.targetReligion = targetReligion;
    }
}