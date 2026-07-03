package vehicleBooking.bean;

import java.io.Serializable;

public class FestivalBean extends PackageBean implements Serializable {
    private static final long serialVersionUID = 1L;

    private String festivalName;
    private String startDate;
    private String endDate;
    private double discountRate;

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
}