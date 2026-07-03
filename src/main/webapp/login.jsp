<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    String error = request.getParameter("error");
    String logout = request.getParameter("logout");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Login | X-PERT DETAILING</title>

    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css?v=5000">
 <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css?v=3000">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/login.css?v=3000">
   
</head>

<body>

<div class="login-container">

    <div class="login-header">

    <div class="form-header">
        <a href="${pageContext.request.contextPath}/index.html" class="back-home">
            <i class="fa-solid fa-arrow-left"></i>
            Back to Home
        </a>
    </div>

    <div class="login-logo">
        <i class="fa-solid fa-car"></i>
    </div>

    <h1>X-PERT DETAILING</h1>
    <p>Login to your account</p>

</div>

    <div class="login-body">

        <% if ("invalid".equals(error)) { %>
            <div class="message error">
                Invalid username, password, or role.
            </div>
        <% } %>

        <% if ("empty".equals(error)) { %>
            <div class="message error">
                Please fill in all fields.
            </div>
        <% } %>

        <% if ("logout".equals(logout)) { %>
            <div class="message success">
                You have logged out successfully.
            </div>
        <% } %>

        <form action="<%= request.getContextPath() %>/LoginController" method="post">

            <div class="form-group">
                <label>Login As</label>

                <div class="role-box">

                    <label class="role-option">
                        <input type="radio" name="role" value="owner" required>
                        <span>
                            <i class="fa-solid fa-user-tie"></i>
                            Owner
                        </span>
                    </label>

                    <label class="role-option">
                        <input type="radio" name="role" value="staff" required>
                        <span>
                            <i class="fa-solid fa-user-gear"></i>
                            Staff
                        </span>
                    </label>

                    <label class="role-option">
                        <input type="radio" name="role" value="customer" required checked>
                        <span>
                            <i class="fa-solid fa-user"></i>
                            Customer
                        </span>
                    </label>

                </div>
            </div>

            <div class="form-group">
                <label>Username</label>
                <input type="text"
                       name="username"
                       class="form-control"
                       placeholder="Enter username"
                       required>
            </div>

            <div class="form-group">
                <label>Password</label>

                <div class="password-wrapper">
                    <input type="password"
                           name="password"
                           id="password"
                           class="form-control"
                           placeholder="Enter password"
                           required>

                    <button type="button" class="toggle-password" onclick="togglePassword()">
                        <i class="fa-solid fa-eye" id="eyeIcon"></i>
                    </button>
                </div>
            </div>

            <button type="submit" class="login-btn">
                Login
            </button>

        </form>

       <div class="bottom-link">
    New customer?
    <a href="<%= request.getContextPath() %>/RegisterController">
        Sign up here
    </a><br><br>
    <a href="<%= request.getContextPath() %>/forgotPassword.jsp">Forgot Password?</a>
</div>

    </div>

</div>

<script>
    function togglePassword() {
        var passwordInput = document.getElementById("password");
        var eyeIcon = document.getElementById("eyeIcon");

        if (passwordInput.type === "password") {
            passwordInput.type = "text";
            eyeIcon.classList.remove("fa-eye");
            eyeIcon.classList.add("fa-eye-slash");
        } else {
            passwordInput.type = "password";
            eyeIcon.classList.remove("fa-eye-slash");
            eyeIcon.classList.add("fa-eye");
        }
    }
</script>

</body>
</html>