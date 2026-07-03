package vehicleBooking.servlet;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.ArrayList;

import vehicleBooking.bean.FestivalBean;
import vehicleBooking.bean.PackageBean;
import vehicleBooking.bean.RoutineBean;
import vehicleBooking.dao.PackageDAO;

@WebServlet("/PackageController")
public class PackageController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    public PackageController() {
        super();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("role") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String role = (String) session.getAttribute("role");
        String action = request.getParameter("action");

        boolean isStaff = "staff".equalsIgnoreCase(role) || "owner".equalsIgnoreCase(role);

        try {

            if ("delete".equalsIgnoreCase(action)) {

                if (!isStaff) {
                    response.sendRedirect(request.getContextPath() + "/PackageController");
                    return;
                }

                String packageID = request.getParameter("packageID");

                if (packageID != null && !packageID.trim().isEmpty()) {
                    PackageDAO.deletePackage(packageID);
                    session.setAttribute("packageSuccess", "Package deleted successfully.");
                } else {
                    session.setAttribute("packageError", "Invalid package ID.");
                }

                response.sendRedirect(request.getContextPath() + "/PackageController");
                return;
            }

            if ("restore".equalsIgnoreCase(action)) {

                if (!isStaff) {
                    response.sendRedirect(request.getContextPath() + "/PackageController");
                    return;
                }

                String packageID = request.getParameter("packageID");

                if (packageID != null && !packageID.trim().isEmpty()) {
                    PackageDAO.restorePackage(packageID);
                    session.setAttribute("packageSuccess", "Package restored successfully.");
                } else {
                    session.setAttribute("packageError", "Invalid package ID.");
                }

                response.sendRedirect(request.getContextPath() + "/PackageController");
                return;
            }

            if ("hardDelete".equalsIgnoreCase(action)) {

                if (!isStaff) {
                    response.sendRedirect(request.getContextPath() + "/PackageController");
                    return;
                }

                String packageID = request.getParameter("packageID");

                if (packageID == null || packageID.trim().isEmpty()) {
                    session.setAttribute("packageError", "Invalid package ID.");
                    response.sendRedirect(request.getContextPath() + "/PackageController");
                    return;
                }

                if (PackageDAO.hasBooking(packageID)) {
                    session.setAttribute(
                            "packageError",
                            "This package cannot be permanently deleted because customers already made a booking using this package."
                    );
                } else {
                    PackageDAO.hardDeletePackage(packageID);
                    session.setAttribute("packageSuccess", "Package permanently deleted successfully.");
                }

                response.sendRedirect(request.getContextPath() + "/PackageController");
                return;
            }

            if ("edit".equalsIgnoreCase(action)) {

                if (!isStaff) {
                    response.sendRedirect(request.getContextPath() + "/PackageController");
                    return;
                }

                String packageID = request.getParameter("packageID");

                if (packageID != null && !packageID.trim().isEmpty()) {
                    PackageBean packageBean = PackageDAO.getPackageById(packageID);
                    request.setAttribute("packageBean", packageBean);
                }
            }

            ArrayList<PackageBean> packageList;

            if (isStaff) {
                packageList = PackageDAO.getAllPackage();
            } else {
                packageList = PackageDAO.getCustomerPackage();
            }

            request.setAttribute("packageList", packageList);

            RequestDispatcher rd;

            if (isStaff) {
                rd = request.getRequestDispatcher("/staff_owner/package/managePackage.jsp");
            } else {
                rd = request.getRequestDispatcher("/customer/package/viewPackage.jsp");
            }

            rd.forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("packageError", "Error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/PackageController");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("role") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String role = (String) session.getAttribute("role");

        if (!"staff".equalsIgnoreCase(role) && !"owner".equalsIgnoreCase(role)) {
            response.sendRedirect(request.getContextPath() + "/PackageController");
            return;
        }

        try {
            String action = request.getParameter("action");
            String type = request.getParameter("type");

            if ("routine".equalsIgnoreCase(type)) {

                RoutineBean p = new RoutineBean();

                p.setPackageID(request.getParameter("packageID"));
                p.setPackageName(request.getParameter("packageName"));
                p.setPackagePrice(Double.parseDouble(request.getParameter("packagePrice")));
                p.setPackageDesc(request.getParameter("packageDesc"));
                p.setServiceName(request.getParameter("serviceName"));
                p.setEntryMethod(request.getParameter("entryMethod"));
                p.setPackageStatus("AVAILABLE");

                if ("update".equalsIgnoreCase(action)) {
                    PackageDAO.updateRoutine(p);
                    session.setAttribute("packageSuccess", "Routine package updated successfully.");
                } else {
                    PackageDAO.addRoutine(p);
                    session.setAttribute("packageSuccess", "Routine package added successfully.");
                }

            } else if ("festive".equalsIgnoreCase(type)) {

                FestivalBean p = new FestivalBean();

                p.setPackageID(request.getParameter("packageID"));
                p.setPackageName(request.getParameter("packageName"));
                p.setPackagePrice(Double.parseDouble(request.getParameter("packagePrice")));
                p.setPackageDesc(request.getParameter("packageDesc"));
                p.setServiceName(request.getParameter("serviceName"));
                p.setFestivalName(request.getParameter("festivalName"));
                p.setStartDate(request.getParameter("startDate"));
                p.setEndDate(request.getParameter("endDate"));
                p.setDiscountRate(Double.parseDouble(request.getParameter("discountRate")));
                p.setPackageStatus("AVAILABLE");

                if ("update".equalsIgnoreCase(action)) {
                    PackageDAO.updateFestive(p);
                    session.setAttribute("packageSuccess", "Festive package updated successfully.");
                } else {
                    PackageDAO.addFestive(p);
                    session.setAttribute("packageSuccess", "Festive package added successfully.");
                }

            } else {
                session.setAttribute("packageError", "Invalid package type.");
            }

            response.sendRedirect(request.getContextPath() + "/PackageController");

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("packageError", "Error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/PackageController");
        }
    }
}