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

    /*
     * Validates the package price.
     *
     * Negative package prices are rejected on the server side.
     * Zero is allowed, but values below zero are not allowed.
     */
    private static double parsePackagePrice(
            String packagePriceValue) {

        if (packagePriceValue == null
                || packagePriceValue.trim().isEmpty()) {

            throw new IllegalArgumentException(
                    "Package price is required."
            );
        }

        final double packagePrice;

        try {
            packagePrice =
                    Double.parseDouble(
                            packagePriceValue.trim()
                    );

        } catch (NumberFormatException e) {

            throw new IllegalArgumentException(
                    "Package price must be a valid number.",
                    e
            );
        }

        if (Double.isNaN(packagePrice)
                || Double.isInfinite(packagePrice)) {

            throw new IllegalArgumentException(
                    "Package price must be a valid number."
            );
        }

        if (packagePrice < 0) {

            throw new IllegalArgumentException(
                    "Package price cannot be negative."
            );
        }

        return packagePrice;
    }

    /*
     * Validates the festive discount rate.
     */
    private static double parseDiscountRate(
            String discountRateValue) {

        if (discountRateValue == null
                || discountRateValue.trim().isEmpty()) {

            throw new IllegalArgumentException(
                    "Discount rate is required and must be between 0 and 100."
            );
        }

        final double discountRate;

        try {
            discountRate =
                    Double.parseDouble(
                            discountRateValue.trim()
                    );

        } catch (NumberFormatException e) {

            throw new IllegalArgumentException(
                    "Discount rate must be a valid number between 0 and 100.",
                    e
            );
        }

        if (Double.isNaN(discountRate)
                || Double.isInfinite(discountRate)
                || discountRate < 0
                || discountRate > 100) {

            throw new IllegalArgumentException(
                    "Discount rate must be between 0 and 100."
            );
        }

        return discountRate;
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        HttpSession session =
                request.getSession(false);

        if (session == null
                || session.getAttribute("role") == null) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/login.jsp"
            );

            return;
        }

        String role =
                (String) session.getAttribute("role");

        String action =
                request.getParameter("action");

        boolean isStaffOrOwner =
                "staff".equalsIgnoreCase(role)
                || "owner".equalsIgnoreCase(role);

        try {

            /*
             * Delete package.
             *
             * If the package has no booking constraint,
             * it is permanently deleted.
             *
             * If the package is already used by a booking,
             * it is changed to UNAVAILABLE.
             */
            if ("delete".equalsIgnoreCase(action)) {

                if (!isStaffOrOwner) {

                    response.sendRedirect(
                            request.getContextPath()
                            + "/PackageController"
                    );

                    return;
                }

                String packageID =
                        request.getParameter(
                                "packageID"
                        );

                if (packageID != null
                        && !packageID.trim().isEmpty()) {

                    packageID =
                            packageID.trim();

                    boolean permanentlyDeleted =
                            PackageDAO
                                    .deletePackageWithConstraintCheck(
                                            packageID
                                    );

                    if (permanentlyDeleted) {

                        session.setAttribute(
                                "packageSuccess",
                                "Package had no booking constraint "
                                + "and was permanently deleted."
                        );

                    } else {

                        session.setAttribute(
                                "packageSuccess",
                                "Package is used by an existing "
                                + "booking, so it has been set "
                                + "to unavailable."
                        );
                    }

                } else {

                    session.setAttribute(
                            "packageError",
                            "Invalid package ID."
                    );
                }

                response.sendRedirect(
                        request.getContextPath()
                        + "/PackageController"
                );

                return;
            }

            /*
             * Restore an unavailable package.
             */
            if ("restore".equalsIgnoreCase(action)) {

                if (!isStaffOrOwner) {

                    response.sendRedirect(
                            request.getContextPath()
                            + "/PackageController"
                    );

                    return;
                }

                String packageID =
                        request.getParameter(
                                "packageID"
                        );

                if (packageID != null
                        && !packageID.trim().isEmpty()) {

                    PackageDAO.restorePackage(
                            packageID.trim()
                    );

                    session.setAttribute(
                            "packageSuccess",
                            "Package restored successfully."
                    );

                } else {

                    session.setAttribute(
                            "packageError",
                            "Invalid package ID."
                    );
                }

                response.sendRedirect(
                        request.getContextPath()
                        + "/PackageController"
                );

                return;
            }

            /*
             * Permanently delete a package when possible.
             */
            if ("hardDelete".equalsIgnoreCase(action)) {

                if (!isStaffOrOwner) {

                    response.sendRedirect(
                            request.getContextPath()
                            + "/PackageController"
                    );

                    return;
                }

                String packageID =
                        request.getParameter(
                                "packageID"
                        );

                if (packageID == null
                        || packageID.trim().isEmpty()) {

                    session.setAttribute(
                            "packageError",
                            "Invalid package ID."
                    );

                    response.sendRedirect(
                            request.getContextPath()
                            + "/PackageController"
                    );

                    return;
                }

                boolean permanentlyDeleted =
                        PackageDAO
                                .deletePackageWithConstraintCheck(
                                        packageID.trim()
                                );

                if (permanentlyDeleted) {

                    session.setAttribute(
                            "packageSuccess",
                            "Package had no booking constraint "
                            + "and was permanently deleted."
                    );

                } else {

                    session.setAttribute(
                            "packageSuccess",
                            "Package is used by an existing "
                            + "booking, so it has been set "
                            + "to unavailable."
                    );
                }

                response.sendRedirect(
                        request.getContextPath()
                        + "/PackageController"
                );

                return;
            }

            /*
             * Retrieve a package for editing.
             */
            if ("edit".equalsIgnoreCase(action)) {

                if (!isStaffOrOwner) {

                    response.sendRedirect(
                            request.getContextPath()
                            + "/PackageController"
                    );

                    return;
                }

                String packageID =
                        request.getParameter(
                                "packageID"
                        );

                if (packageID != null
                        && !packageID.trim().isEmpty()) {

                    PackageBean packageBean =
                            PackageDAO.getPackageById(
                                    packageID.trim()
                            );

                    request.setAttribute(
                            "packageBean",
                            packageBean
                    );
                }
            }

            /*
             * Retrieve the package list.
             */
            ArrayList<PackageBean> packageList;

            if (isStaffOrOwner) {

                packageList =
                        PackageDAO.getAllPackage();

            } else {

                String custID =
                        (String) session.getAttribute(
                                "custID"
                        );

                if (custID != null
                        && !custID.trim().isEmpty()) {

                    packageList =
                            PackageDAO
                                    .getCustomerPackage(
                                            custID
                                    );

                } else {

                    packageList =
                            PackageDAO
                                    .getCustomerPackage();
                }
            }

            request.setAttribute(
                    "packageList",
                    packageList
            );

            RequestDispatcher dispatcher;

            if (isStaffOrOwner) {

                dispatcher =
                        request.getRequestDispatcher(
                                "/staff_owner/package/managePackage.jsp"
                        );

            } else {

                dispatcher =
                        request.getRequestDispatcher(
                                "/customer/package/viewPackage.jsp"
                        );
            }

            dispatcher.forward(
                    request,
                    response
            );

        } catch (Exception e) {

            e.printStackTrace();

            session.setAttribute(
                    "packageError",
                    "Error: " + e.getMessage()
            );

            response.sendRedirect(
                    request.getContextPath()
                    + "/PackageController"
            );
        }
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        request.setCharacterEncoding(
                "UTF-8"
        );

        response.setCharacterEncoding(
                "UTF-8"
        );

        HttpSession session =
                request.getSession(false);

        if (session == null
                || session.getAttribute("role") == null) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/login.jsp"
            );

            return;
        }

        String role =
                (String) session.getAttribute(
                        "role"
                );

        if (!"staff".equalsIgnoreCase(role)
                && !"owner".equalsIgnoreCase(role)) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/PackageController"
            );

            return;
        }

        try {

            String action =
                    request.getParameter(
                            "action"
                    );

            String type =
                    request.getParameter(
                            "type"
                    );

            /*
             * Routine package.
             */
            if ("routine".equalsIgnoreCase(type)) {

                RoutineBean packageBean =
                        new RoutineBean();

                packageBean.setPackageID(
                        request.getParameter(
                                "packageID"
                        )
                );

                packageBean.setPackageName(
                        request.getParameter(
                                "packageName"
                        )
                );

                /*
                 * Negative price validation is performed here.
                 */
                packageBean.setPackagePrice(
                        parsePackagePrice(
                                request.getParameter(
                                        "packagePrice"
                                )
                        )
                );

                packageBean.setPackageDesc(
                        request.getParameter(
                                "packageDesc"
                        )
                );

                packageBean.setServiceName(
                        request.getParameter(
                                "serviceName"
                        )
                );

                packageBean.setEntryMethod(
                        request.getParameter(
                                "entryMethod"
                        )
                );

                packageBean.setPackageStatus(
                        "AVAILABLE"
                );

                if ("update".equalsIgnoreCase(action)) {

                    PackageDAO.updateRoutine(
                            packageBean
                    );

                    session.setAttribute(
                            "packageSuccess",
                            "Routine package updated successfully."
                    );

                } else {

                    PackageDAO.addRoutine(
                            packageBean
                    );

                    session.setAttribute(
                            "packageSuccess",
                            "Routine package added successfully."
                    );
                }

            /*
             * Festive package.
             */
            } else if ("festive".equalsIgnoreCase(type)) {

                FestivalBean packageBean =
                        new FestivalBean();

                packageBean.setPackageID(
                        request.getParameter(
                                "packageID"
                        )
                );

                packageBean.setPackageName(
                        request.getParameter(
                                "packageName"
                        )
                );

                /*
                 * Negative price validation is performed here.
                 */
                packageBean.setPackagePrice(
                        parsePackagePrice(
                                request.getParameter(
                                        "packagePrice"
                                )
                        )
                );

                packageBean.setPackageDesc(
                        request.getParameter(
                                "packageDesc"
                        )
                );

                packageBean.setServiceName(
                        request.getParameter(
                                "serviceName"
                        )
                );

                packageBean.setFestivalName(
                        request.getParameter(
                                "festivalName"
                        )
                );

                packageBean.setStartDate(
                        request.getParameter(
                                "startDate"
                        )
                );

                packageBean.setEndDate(
                        request.getParameter(
                                "endDate"
                        )
                );

                packageBean.setDiscountRate(
                        parseDiscountRate(
                                request.getParameter(
                                        "discountRate"
                                )
                        )
                );

                packageBean.setTargetRace(
                        request.getParameter(
                                "targetRace"
                        )
                );

                packageBean.setTargetReligion(
                        request.getParameter(
                                "targetReligion"
                        )
                );

                packageBean.setPackageStatus(
                        "AVAILABLE"
                );

                if ("update".equalsIgnoreCase(action)) {

                    PackageDAO.updateFestive(
                            packageBean
                    );

                    session.setAttribute(
                            "packageSuccess",
                            "Festive package updated successfully."
                    );

                } else {

                    PackageDAO.addFestive(
                            packageBean
                    );

                    session.setAttribute(
                            "packageSuccess",
                            "Festive package added successfully."
                    );
                }

            } else {

                session.setAttribute(
                        "packageError",
                        "Invalid package type."
                );
            }

            response.sendRedirect(
                    request.getContextPath()
                    + "/PackageController"
            );

        } catch (IllegalArgumentException e) {

            e.printStackTrace();

            session.setAttribute(
                    "packageError",
                    e.getMessage()
            );

            response.sendRedirect(
                    request.getContextPath()
                    + "/PackageController"
            );

        } catch (Exception e) {

            e.printStackTrace();

            session.setAttribute(
                    "packageError",
                    "Error: " + e.getMessage()
            );

            response.sendRedirect(
                    request.getContextPath()
                    + "/PackageController"
            );
        }
    }
}