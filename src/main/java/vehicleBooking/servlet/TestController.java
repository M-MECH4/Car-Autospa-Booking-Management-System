package vehicleBooking.servlet;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/TestController")
public class TestController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public TestController() {
        System.out.println("TEST CONTROLLER LOADED");
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.getWriter().println("Test Controller is working");
    }
}