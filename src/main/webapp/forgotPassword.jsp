<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%!
    private String escapeHtml(String value) {
        if (value == null) return "";
        return value
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#x27;");
    }

    private String checkedRole(String currentRole, String role) {
        return role.equalsIgnoreCase(currentRole) ? "checked" : "";
    }
%>

<%
    String contextPath = request.getContextPath();

    String error = (String) request.getAttribute("error");
    String success = (String) request.getAttribute("success");

    String emailValue = request.getParameter("email");
    if (emailValue == null) {
        emailValue = "";
    }

    String selectedRole = request.getParameter("role");
    if (selectedRole == null || selectedRole.trim().isEmpty()) {
        selectedRole = "customer";
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Forgot Password | X-PERT DETAILING</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Inter', sans-serif;
        }

        body {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 30px;
            background-image:
                linear-gradient(rgba(7, 72, 88, 0.25), rgba(7, 72, 88, 0.25)),
                url("https://images.myguide-cdn.com/tokyo/activities/tokyo-daikoku-car-meet-night-tour-by-sports-cars/large/tokyo-daikoku-car-meet-night-tour-by-sports-cars-7326197.jpg");
            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
        }

        .forgot-container {
            width: 100%;
            max-width: 480px;
            background: #ffffff;
            border-radius: 34px;
            box-shadow: 0 25px 45px rgba(0, 0, 0, 0.16);
            overflow: hidden;
        }

        .forgot-header {
            background: #074858;
            padding: 24px 34px 30px;
            color: white;
            text-align: center;
            position: relative;
        }

        .back-login {
            color: #d8eef4;
            text-decoration: none;
            font-size: 14px;
            font-weight: 800;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 20px;
            width: 100%;
        }

        .back-login:hover {
            color: #f5b93c;
        }

        .login-logo {
            width: 86px;
            height: 86px;
            background: #f5b93c;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 18px;
            overflow: hidden;
            padding: 6px;
        }

        .login-logo img {
            width: 100%;
            height: 100%;
            object-fit: contain;
            display: block;
        }

        .forgot-header h1 {
            font-size: 28px;
            font-weight: 900;
            margin-bottom: 8px;
        }

        .forgot-header p {
            color: #d8eef4;
            font-size: 14px;
            font-weight: 600;
            line-height: 1.5;
        }

        .forgot-body {
            padding: 34px;
        }

        .message {
            padding: 13px 16px;
            border-radius: 14px;
            margin-bottom: 18px;
            font-size: 14px;
            font-weight: 800;
            line-height: 1.5;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .message.error {
            background: #fee2e2;
            color: #991b1b;
            border: 1px solid #fecaca;
        }

        .message.success {
            background: #dcfce7;
            color: #166534;
            border: 1px solid #bbf7d0;
        }

        .info-box {
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            color: #475569;
            padding: 14px 16px;
            border-radius: 16px;
            font-size: 13px;
            font-weight: 700;
            line-height: 1.5;
            margin-bottom: 20px;
            display: flex;
            gap: 10px;
        }

        .info-box i {
            color: #074858;
            margin-top: 2px;
        }

        .form-group {
            margin-bottom: 18px;
        }

        .form-group label {
            display: block;
            margin-bottom: 8px;
            color: #374151;
            font-size: 14px;
            font-weight: 900;
        }

        .input-wrapper {
            position: relative;
        }

        .input-wrapper i {
            position: absolute;
            left: 16px;
            top: 50%;
            transform: translateY(-50%);
            color: #64748b;
            font-size: 16px;
        }

        .form-control {
            width: 100%;
            padding: 15px 16px 15px 46px;
            border: 1px solid #d1d5db;
            border-radius: 16px;
            outline: none;
            font-size: 15px;
            font-weight: 600;
            color: #1f2937;
            background: #ffffff;
        }

        .form-control::placeholder {
            color: #94a3b8;
            font-weight: 600;
        }

        .form-control:focus {
            border-color: #074858;
            box-shadow: 0 0 0 3px rgba(7, 72, 88, 0.12);
        }

        .role-box {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 10px;
            margin-top: 8px;
        }

        .role-option input {
            display: none;
        }

        .role-option span {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 7px;
            padding: 13px 8px;
            border: 1px solid #d1d5db;
            border-radius: 14px;
            font-size: 13px;
            font-weight: 900;
            color: #374151;
            cursor: pointer;
            transition: 0.2s ease;
            background: #ffffff;
        }

        .role-option span i {
            font-size: 14px;
        }

        .role-option input:checked + span {
            background: #074858;
            color: #ffffff;
            border-color: #074858;
            box-shadow: 0 10px 18px rgba(7, 72, 88, 0.18);
        }

        .role-option span:hover {
            border-color: #074858;
        }

        .send-btn {
            width: 100%;
            background: #074858;
            color: white;
            border: none;
            padding: 15px;
            border-radius: 16px;
            font-size: 16px;
            font-weight: 900;
            cursor: pointer;
            margin-top: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            transition: 0.2s ease;
        }

        .send-btn:hover {
            background: #053947;
            transform: translateY(-1px);
            box-shadow: 0 12px 22px rgba(7, 72, 88, 0.24);
        }

        .send-btn:active {
            transform: translateY(0);
        }

        .bottom-link {
            text-align: center;
            margin-top: 22px;
            font-size: 14px;
            color: #64748b;
            font-weight: 600;
        }

        .bottom-link a {
            color: #074858;
            font-weight: 900;
            text-decoration: none;
        }

        .bottom-link a:hover {
            text-decoration: underline;
        }

        @media (max-width: 520px) {
            body {
                padding: 18px;
            }

            .forgot-container {
                border-radius: 26px;
            }

            .forgot-header {
                padding: 22px 24px 28px;
            }

            .forgot-body {
                padding: 26px 22px;
            }

            .forgot-header h1 {
                font-size: 24px;
            }

            .role-box {
                grid-template-columns: 1fr;
            }

            .role-option span {
                justify-content: flex-start;
                padding-left: 18px;
            }
        }
    </style>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>

<body>

<div class="forgot-container">

    <div class="forgot-header">

        <a href="<%= contextPath %>/login.jsp" class="back-login">
            <i class="fa-solid fa-arrow-left"></i>
            Back to Login
        </a>

        <div class="login-logo">
                <i class="fa-solid fa-car"></i>
        </div>

        <h1>Forgot Password</h1>
        <p>Enter your registered email and account role. We will send an OTP to reset your password.</p>

    </div>

    <div class="forgot-body">

        <% if (error != null && !error.trim().isEmpty()) { %>
            <div class="message error">
                <i class="fa-solid fa-circle-exclamation"></i>
                <span><%= escapeHtml(error) %></span>
            </div>
        <% } %>

        <% if (success != null && !success.trim().isEmpty()) { %>
            <div class="message success">
                <i class="fa-solid fa-circle-check"></i>
                <span><%= escapeHtml(success) %></span>
            </div>
        <% } %>

        <div class="info-box">
            <i class="fa-solid fa-shield-halved"></i>
            <span>Please use the email address registered with your X-PERT DETAILING account.</span>
        </div>

        <form action="<%= contextPath %>/ForgotPasswordController" method="post">

            <div class="form-group">
                <label>Email Address</label>

                <div class="input-wrapper">
                    <i class="fa-regular fa-envelope"></i>

                    <input
                        type="email"
                        name="email"
                        class="form-control"
                        placeholder="Enter your registered email"
                        value="<%= escapeHtml(emailValue) %>"
                        required>
                </div>
            </div>

            <div class="form-group">
                <label>Account Role</label>

                <div class="role-box">

                    <label class="role-option">
                        <input
                            type="radio"
                            name="role"
                            value="customer"
                            <%= checkedRole(selectedRole, "customer") %>
                            required>
                        <span>
                            <i class="fa-solid fa-user"></i>
                            Customer
                        </span>
                    </label>

                    <label class="role-option">
                        <input
                            type="radio"
                            name="role"
                            value="staff"
                            <%= checkedRole(selectedRole, "staff") %>
                            required>
                        <span>
                            <i class="fa-solid fa-user-gear"></i>
                            Staff
                        </span>
                    </label>

                    <label class="role-option">
                        <input
                            type="radio"
                            name="role"
                            value="owner"
                            <%= checkedRole(selectedRole, "owner") %>
                            required>
                        <span>
                            <i class="fa-solid fa-user-tie"></i>
                            Owner
                        </span>
                    </label>

                </div>
            </div>

            <button type="submit" class="send-btn">
                <i class="fa-solid fa-paper-plane"></i>
                Send OTP
            </button>

        </form>

        <div class="bottom-link">
            Remember your password?
            <a href="<%= contextPath %>/login.jsp">Sign in here</a>
        </div>

    </div>

</div>

</body>
</html>