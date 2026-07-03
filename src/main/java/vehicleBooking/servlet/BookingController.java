package vehicleBooking.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.DayOfWeek;
import java.time.LocalDate;

import vehicleBooking.bean.BookingBean;
import vehicleBooking.dao.BookingDAO;

@WebServlet("/BookingController")
public class BookingController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private static final String CUSTOMER_BOOKING_LIST = "/customer/booking/listBooking.jsp";
    private static final String CUSTOMER_BOOKING_FORM = "/customer/booking/custBooking.jsp";
    private static final String STAFF_BOOKING_PAGE = "/staff_owner/booking/staffBooking.jsp";

    public BookingController() {
        super();
        System.out.println("BOOKING CONTROLLER LOADED");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session != null && session.getAttribute("staffID") != null) {
            response.sendRedirect(request.getContextPath() + STAFF_BOOKING_PAGE);
            return;
        }

        response.sendRedirect(request.getContextPath() + CUSTOMER_BOOKING_LIST);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("BOOKING CONTROLLER POST RUNNING");

        HttpSession session = request.getSession(false);

        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");

        System.out.println("BOOKING ACTION = " + action);
        System.out.println("SESSION CUSTID = " + session.getAttribute("custID"));
        System.out.println("SESSION STAFFID = " + session.getAttribute("staffID"));
        System.out.println("SESSION ROLE = " + session.getAttribute("role"));

        try {
            if ("updateProgress".equalsIgnoreCase(action)
                    || "updateServiceProgress".equalsIgnoreCase(action)) {

                if (!isStaff(session)) {
                    response.sendRedirect(request.getContextPath() + "/login.jsp");
                    return;
                }

                updateProgress(request, response, session);
                return;
            }

            if ("sendNotification".equalsIgnoreCase(action)
                    || "send".equalsIgnoreCase(action)
                    || "notify".equalsIgnoreCase(action)) {

                if (!isStaff(session)) {
                    response.sendRedirect(request.getContextPath() + "/login.jsp");
                    return;
                }

                sendNotification(request, response, session);
                return;
            }

            if (session.getAttribute("custID") == null) {
                response.sendRedirect(request.getContextPath() + "/login.jsp");
                return;
            }

            if ("create".equalsIgnoreCase(action)) {
                createBooking(request, response, session);
                return;
            }

            if ("update".equalsIgnoreCase(action)) {
                updateBooking(request, response, session);
                return;
            }

            if ("delete".equalsIgnoreCase(action)) {
                deleteBooking(request, response, session);
                return;
            }

            session.setAttribute("errorMessage", "Invalid booking action.");
            response.sendRedirect(request.getContextPath() + CUSTOMER_BOOKING_LIST);

        } catch (Exception e) {
            e.printStackTrace();

            if (isStaff(session)) {
                session.setAttribute("errorMessage", "Error: " + e.getMessage());
                response.sendRedirect(request.getContextPath() + STAFF_BOOKING_PAGE);
            } else {
                session.setAttribute("errorMessage", "Error: " + e.getMessage());
                response.sendRedirect(request.getContextPath() + CUSTOMER_BOOKING_LIST);
            }
        }
    }

    // =========================
    // STAFF: UPDATE PROGRESS
    // =========================
    private void updateProgress(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws Exception {

        String bookingID = request.getParameter("bookingID");
        String bookingStatus = request.getParameter("bookingStatus");

        if (isEmpty(bookingStatus)) {
            bookingStatus = request.getParameter("status");
        }

        if (isEmpty(bookingStatus)) {
            bookingStatus = request.getParameter("serviceProgress");
        }

        System.out.println("========== UPDATE PROGRESS DEBUG ==========");
        System.out.println("BOOKING ID = " + bookingID);
        System.out.println("BOOKING STATUS = " + bookingStatus);
        System.out.println("===========================================");

        if (isEmpty(bookingID) || isEmpty(bookingStatus)) {
            session.setAttribute("errorMessage", "Please select booking and progress status.");
            response.sendRedirect(request.getContextPath() + STAFF_BOOKING_PAGE);
            return;
        }

        String staffID = (String) session.getAttribute("staffID");

        int row = BookingDAO.updateServiceProgress(
                bookingID.trim(),
                bookingStatus.trim(),
                staffID
        );

        if (row > 0) {
            session.setAttribute("successMessage", "Progress updated successfully. Click Send to notify customer.");
        } else {
            session.setAttribute("errorMessage", "Progress was not updated.");
        }

        response.sendRedirect(request.getContextPath() + STAFF_BOOKING_PAGE);
    }

    // =========================
    // STAFF: SEND NOTIFICATION
    // =========================
    private void sendNotification(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws Exception {

        String bookingID = request.getParameter("bookingID");
        String notificationMessage = request.getParameter("notificationMessage");

        if (isEmpty(notificationMessage)) {
            notificationMessage = request.getParameter("message");
        }

        if (isEmpty(notificationMessage)) {
            notificationMessage = "Your vehicle service progress has been updated. Please check your booking details.";
        }

        System.out.println("========== SEND NOTIFICATION DEBUG ==========");
        System.out.println("BOOKING ID = " + bookingID);
        System.out.println("MESSAGE = " + notificationMessage);
        System.out.println("=============================================");

        if (isEmpty(bookingID)) {
            session.setAttribute("errorMessage", "Invalid booking ID.");
            response.sendRedirect(request.getContextPath() + STAFF_BOOKING_PAGE);
            return;
        }

        int row = BookingDAO.sendNotification(bookingID.trim(), notificationMessage.trim());

        if (row > 0) {
            session.setAttribute("successMessage", "Notification sent successfully.");
        } else {
            session.setAttribute("errorMessage", "Notification was not sent.");
        }

        response.sendRedirect(request.getContextPath() + STAFF_BOOKING_PAGE);
    }

    // =========================
    // CUSTOMER: CREATE BOOKING
    // =========================
    private void createBooking(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws Exception {

        String custID = (String) session.getAttribute("custID");

        String bookingDate = request.getParameter("bookingDate");
        String bookingTime = request.getParameter("bookingTime");
        String packageID = request.getParameter("packageID");
        String vehiclePlateNum = request.getParameter("vehiclePlateNum");

        if (isEmpty(bookingDate) || isEmpty(bookingTime) || isEmpty(packageID) || isEmpty(vehiclePlateNum)) {
            session.setAttribute("errorMessage", "Please fill in all booking fields.");
            response.sendRedirect(request.getContextPath() + CUSTOMER_BOOKING_FORM);
            return;
        }

        bookingDate = bookingDate.trim();
        bookingTime = bookingTime.trim();
        packageID = packageID.trim();
        vehiclePlateNum = vehiclePlateNum.trim().toUpperCase();

        if (!isValidBookingTime(bookingTime)) {
            session.setAttribute("errorMessage", "Please select a valid booking time.");
            response.sendRedirect(request.getContextPath() + CUSTOMER_BOOKING_FORM);
            return;
        }

        if (isPastDate(bookingDate)) {
            session.setAttribute("errorMessage", "Booking date cannot be in the past.");
            response.sendRedirect(request.getContextPath() + CUSTOMER_BOOKING_FORM);
            return;
        }

        if (isSunday(bookingDate)) {
            session.setAttribute("errorMessage", "Booking cannot be made on Sunday.");
            response.sendRedirect(request.getContextPath() + CUSTOMER_BOOKING_FORM);
            return;
        }

        if (!BookingDAO.isCustomerVehicle(vehiclePlateNum, custID)) {
            session.setAttribute("errorMessage", "Invalid vehicle. Please choose your registered vehicle only.");
            response.sendRedirect(request.getContextPath() + CUSTOMER_BOOKING_FORM);
            return;
        }

        if (!BookingDAO.isDateAvailableForCreate(bookingDate)) {
            session.setAttribute("errorMessage", "This date is already booked. Please choose another date.");
            response.sendRedirect(request.getContextPath() + CUSTOMER_BOOKING_FORM);
            return;
        }

        if (!BookingDAO.isDateTimeAvailableForCreate(bookingDate, bookingTime)) {
            session.setAttribute("errorMessage", "This date and time is already booked. Please choose another time.");
            response.sendRedirect(request.getContextPath() + CUSTOMER_BOOKING_FORM);
            return;
        }

        BookingBean booking = new BookingBean();

        booking.setBookingDate(bookingDate);
        booking.setBookingTime(bookingTime);
        booking.setPackageID(packageID);
        booking.setVehiclePlateNum(vehiclePlateNum);

        int row = BookingDAO.createBooking(booking);

        if (row > 0) {
            session.setAttribute("successMessage", "Booking created successfully.");
            response.sendRedirect(request.getContextPath() + CUSTOMER_BOOKING_LIST);
        } else {
            session.setAttribute("errorMessage", "Booking failed. Please try again.");
            response.sendRedirect(request.getContextPath() + CUSTOMER_BOOKING_FORM);
        }
    }

    // =========================
    // CUSTOMER: UPDATE BOOKING
    // =========================
    private void updateBooking(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws Exception {

        String custID = (String) session.getAttribute("custID");

        String bookingID = request.getParameter("bookingID");
        String bookingDate = request.getParameter("bookingDate");
        String bookingTime = request.getParameter("bookingTime");
        String packageID = request.getParameter("packageID");
        String vehiclePlateNum = request.getParameter("vehiclePlateNum");

        if (isEmpty(bookingID) || isEmpty(bookingDate) || isEmpty(bookingTime)
                || isEmpty(packageID) || isEmpty(vehiclePlateNum)) {

            session.setAttribute("errorMessage", "Please fill in all update fields.");
            response.sendRedirect(request.getContextPath() + CUSTOMER_BOOKING_LIST);
            return;
        }

        bookingID = bookingID.trim();
        bookingDate = bookingDate.trim();
        bookingTime = bookingTime.trim();
        packageID = packageID.trim();
        vehiclePlateNum = vehiclePlateNum.trim().toUpperCase();

        if (!isValidBookingTime(bookingTime)) {
            session.setAttribute("errorMessage", "Please select a valid booking time.");
            response.sendRedirect(request.getContextPath() + CUSTOMER_BOOKING_LIST);
            return;
        }

        if (isPastDate(bookingDate)) {
            session.setAttribute("errorMessage", "Booking date cannot be in the past.");
            response.sendRedirect(request.getContextPath() + CUSTOMER_BOOKING_LIST);
            return;
        }

        if (isSunday(bookingDate)) {
            session.setAttribute("errorMessage", "Booking cannot be updated to Sunday.");
            response.sendRedirect(request.getContextPath() + CUSTOMER_BOOKING_LIST);
            return;
        }

        if (!BookingDAO.isCustomerVehicle(vehiclePlateNum, custID)) {
            session.setAttribute("errorMessage", "Invalid vehicle. Please choose your registered vehicle only.");
            response.sendRedirect(request.getContextPath() + CUSTOMER_BOOKING_LIST);
            return;
        }

        if (!BookingDAO.isDateAvailableForUpdate(bookingDate, bookingID)) {
            session.setAttribute("errorMessage", "This date is already booked. Please choose another date.");
            response.sendRedirect(request.getContextPath() + CUSTOMER_BOOKING_LIST);
            return;
        }

        if (!BookingDAO.isDateTimeAvailableForUpdate(bookingDate, bookingTime, bookingID)) {
            session.setAttribute("errorMessage", "This date and time is already booked. Please choose another time.");
            response.sendRedirect(request.getContextPath() + CUSTOMER_BOOKING_LIST);
            return;
        }

        BookingBean booking = new BookingBean();

        booking.setBookingID(bookingID);
        booking.setBookingDate(bookingDate);
        booking.setBookingTime(bookingTime);
        booking.setPackageID(packageID);
        booking.setVehiclePlateNum(vehiclePlateNum);

        int row = BookingDAO.updateBooking(booking, custID);

        if (row > 0) {
            session.setAttribute("successMessage", "Booking updated successfully.");
        } else {
            session.setAttribute("errorMessage", "Booking cannot be updated because the status is not BOOKED.");
        }

        response.sendRedirect(request.getContextPath() + CUSTOMER_BOOKING_LIST);
    }

    // =========================
    // CUSTOMER: DELETE BOOKING
    // =========================
    private void deleteBooking(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws Exception {

        String custID = (String) session.getAttribute("custID");
        String bookingID = request.getParameter("bookingID");

        if (isEmpty(bookingID)) {
            session.setAttribute("errorMessage", "Invalid booking ID.");
            response.sendRedirect(request.getContextPath() + CUSTOMER_BOOKING_LIST);
            return;
        }

        bookingID = bookingID.trim();

        int row = BookingDAO.deleteBooking(bookingID, custID);

        if (row > 0) {
            session.setAttribute("successMessage", "Booking deleted successfully.");
        } else {
            session.setAttribute("errorMessage", "Booking cannot be deleted because the status is not BOOKED.");
        }

        response.sendRedirect(request.getContextPath() + CUSTOMER_BOOKING_LIST);
    }

    private boolean isStaff(HttpSession session) {
        if (session == null) {
            return false;
        }

        String role = (String) session.getAttribute("role");

        return session.getAttribute("staffID") != null
                || "staff".equalsIgnoreCase(role);
    }

    private boolean isEmpty(String value) {
        return value == null || value.trim().isEmpty();
    }

    private boolean isSunday(String bookingDate) {
        LocalDate date = LocalDate.parse(bookingDate);
        return date.getDayOfWeek() == DayOfWeek.SUNDAY;
    }

    private boolean isPastDate(String bookingDate) {
        LocalDate selectedDate = LocalDate.parse(bookingDate);
        LocalDate today = LocalDate.now();
        return selectedDate.isBefore(today);
    }

    private boolean isValidBookingTime(String bookingTime) {
        if (bookingTime == null) {
            return false;
        }

        return bookingTime.equals("09:00")
                || bookingTime.equals("09:30")
                || bookingTime.equals("10:00")
                || bookingTime.equals("10:30")
                || bookingTime.equals("11:00")
                || bookingTime.equals("11:30")
                || bookingTime.equals("12:00")
                || bookingTime.equals("12:30")
                || bookingTime.equals("13:00")
                || bookingTime.equals("13:30")
                || bookingTime.equals("14:00")
                || bookingTime.equals("14:30")
                || bookingTime.equals("15:00")
                || bookingTime.equals("15:30")
                || bookingTime.equals("16:00")
                || bookingTime.equals("16:30")
                || bookingTime.equals("17:00")
                || bookingTime.equals("17:30")
                || bookingTime.equals("18:00");
    }
}