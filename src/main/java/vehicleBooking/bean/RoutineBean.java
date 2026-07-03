package vehicleBooking.bean;

import java.io.Serializable;

public class RoutineBean extends PackageBean implements Serializable {
    private static final long serialVersionUID = 1L;

    private String entryMethod;

    public RoutineBean() {
    }

    public String getEntryMethod() {
        return entryMethod;
    }

    public void setEntryMethod(String entryMethod) {
        this.entryMethod = entryMethod;
    }
}