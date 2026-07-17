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
%>

<%
Boolean verified = (Boolean) session.getAttribute("resetVerified");

if (verified == null || !verified) {
    response.sendRedirect(request.getContextPath() + "/forgotPassword.jsp");
    return;
}

String contextPath = request.getContextPath();

String error = (String) request.getAttribute("error");
String success = (String) request.getAttribute("success");
%>

<!DOCTYPE html>
<html lang="en">

<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>Reset Password | X-PERT DETAILING</title>

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

    .reset-container {
        width: 100%;
        max-width: 500px;
        background: #ffffff;
        border-radius: 34px;
        box-shadow: 0 25px 45px rgba(0, 0, 0, 0.16);
        overflow: hidden;
    }

    .reset-header {
        background: #074858;
        padding: 24px 34px 30px;
        color: white;
        text-align: center;
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

    .reset-header h1 {
        font-size: 28px;
        font-weight: 900;
        margin-bottom: 8px;
    }

    .reset-header p {
        color: #d8eef4;
        font-size: 14px;
        font-weight: 600;
        line-height: 1.5;
    }

    .reset-body {
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

    .input-icon {
        position: absolute;
        left: 16px;
        top: 50%;
        transform: translateY(-50%);
        color: #64748b;
        font-size: 16px;
    }

    .input-wrapper input {
        width: 100%;
        padding: 15px 52px 15px 46px;
        border: 1px solid #d1d5db;
        border-radius: 16px;
        outline: none;
        font-size: 15px;
        font-weight: 600;
        color: #1f2937;
        background: #ffffff;
    }

    .input-wrapper input::placeholder {
        color: #94a3b8;
        font-weight: 600;
    }

    .input-wrapper input:focus {
        border-color: #074858;
        box-shadow: 0 0 0 3px rgba(7, 72, 88, 0.12);
    }

    .password-toggle {
        position: absolute;
        right: 14px;
        top: 50%;
        transform: translateY(-50%);
        border: none;
        background: transparent;
        color: #64748b;
        cursor: pointer;
        font-size: 17px;
        width: 28px;
        height: 28px;
        display: flex;
        align-items: center;
        justify-content: center;
    }

    .password-toggle:hover {
        color: #074858;
    }

    .password-requirements {
        background: #f8fafc;
        border: 1px solid #e2e8f0;
        padding: 16px;
        border-radius: 18px;
        margin: 20px 0;
    }

    .password-requirements p {
        font-size: 14px;
        font-weight: 900;
        color: #374151;
        margin-bottom: 12px;
        display: flex;
        align-items: center;
        gap: 8px;
    }

    .password-requirements p i {
        color: #074858;
    }

    .requirements-list {
        list-style: none;
        display: grid;
        gap: 8px;
    }

    .requirements-list li {
        font-size: 13px;
        font-weight: 800;
        color: #991b1b;
        display: flex;
        align-items: center;
        gap: 8px;
    }

    .requirements-list li.valid {
        color: #166534;
    }

    .match-message {
        font-size: 13px;
        font-weight: 800;
        margin-top: 8px;
        display: none;
    }

    .match-message.error-text {
        display: block;
        color: #991b1b;
    }

    .match-message.success-text {
        display: block;
        color: #166534;
    }

    .reset-btn {
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

    .reset-btn:hover {
        background: #053947;
        transform: translateY(-1px);
        box-shadow: 0 12px 22px rgba(7, 72, 88, 0.24);
    }

    .reset-btn:active {
        transform: translateY(0);
    }

    .reset-btn:disabled {
        background: #94a3b8;
        cursor: not-allowed;
        transform: none;
        box-shadow: none;
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

        .reset-container {
            border-radius: 26px;
        }

        .reset-header {
            padding: 22px 24px 28px;
        }

        .reset-body {
            padding: 26px 22px;
        }

        .reset-header h1 {
            font-size: 24px;
        }
    }
</style>

    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>

<body>

<div class="reset-container">

    <div class="reset-header">

        <a href="<%= contextPath %>/login.jsp" class="back-login">
            <i class="fa-solid fa-arrow-left"></i>
            Back to Login
        </a>

        <div class="login-logo">
                <i class="fa-solid fa-car"></i>
        </div>

        <h1>Reset Password</h1>
        <p>Create a new secure password for your account.</p>

    </div>

    <div class="reset-body">

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
            <span>Your new password must follow the security rules below.</span>
        </div>

        <form action="<%= contextPath %>/ResetPasswordController" method="post" id="resetPasswordForm">

            <div class="form-group">
                <label>New Password *</label>

                <div class="input-wrapper">

                    <i class="fa-solid fa-key input-icon"></i>

                    <input
                        type="password"
                        id="password"
                        name="newPassword"
                        placeholder="Enter new password"
                        required>

                    <button
                        type="button"
                        class="password-toggle"
                        id="togglePassword">

                        <i class="fa-regular fa-eye-slash"></i>

                    </button>

                </div>
            </div>

            <div class="form-group">
                <label>Confirm Password *</label>

                <div class="input-wrapper">

                    <i class="fa-solid fa-check-circle input-icon"></i>

                    <input
                        type="password"
                        id="confirmPassword"
                        name="confirmPassword"
                        placeholder="Confirm new password"
                        required>

                    <button
                        type="button"
                        class="password-toggle"
                        id="toggleConfirmPassword">

                        <i class="fa-regular fa-eye-slash"></i>

                    </button>

                </div>

                <div id="matchMessage" class="match-message"></div>
            </div>

            <div class="password-requirements">

                <p>
                    <i class="fa-solid fa-shield-halved"></i>
                    Password must contain:
                </p>

                <ul class="requirements-list">

                    <li id="reqLength">
                        <i class="fa-regular fa-circle-xmark"></i>
                        At least 8 characters
                    </li>

                    <li id="reqUpper">
                        <i class="fa-regular fa-circle-xmark"></i>
                        One uppercase letter
                    </li>

                    <li id="reqLower">
                        <i class="fa-regular fa-circle-xmark"></i>
                        One lowercase letter
                    </li>

                    <li id="reqNumber">
                        <i class="fa-regular fa-circle-xmark"></i>
                        One number
                    </li>

                    <li id="reqSpecial">
                        <i class="fa-regular fa-circle-xmark"></i>
                        One special character (!@#$%^&*)
                    </li>

                </ul>

            </div>

            <button type="submit" class="reset-btn" id="resetBtn">
                <i class="fa-solid fa-key"></i>
                Reset Password
            </button>

        </form>

        <div class="bottom-link">
            Remember your password?
            <a href="<%= contextPath %>/login.jsp">Sign in here</a>
        </div>

    </div>

</div>

<script>
    const form = document.getElementById("resetPasswordForm");

    const passwordInput = document.getElementById("password");
    const confirmInput = document.getElementById("confirmPassword");

    const togglePwd = document.getElementById("togglePassword");
    const toggleConfirm = document.getElementById("toggleConfirmPassword");

    const resetBtn = document.getElementById("resetBtn");
    const matchMessage = document.getElementById("matchMessage");

    const reqLength = document.getElementById("reqLength");
    const reqUpper = document.getElementById("reqUpper");
    const reqLower = document.getElementById("reqLower");
    const reqNumber = document.getElementById("reqNumber");
    const reqSpecial = document.getElementById("reqSpecial");

    function togglePasswordVisibility(input, button) {
        const type = input.type === "password" ? "text" : "password";
        input.type = type;

        button.innerHTML =
            type === "password"
            ? '<i class="fa-regular fa-eye-slash"></i>'
            : '<i class="fa-regular fa-eye"></i>';
    }

    togglePwd.addEventListener("click", function() {
        togglePasswordVisibility(passwordInput, togglePwd);
    });

    toggleConfirm.addEventListener("click", function() {
        togglePasswordVisibility(confirmInput, toggleConfirm);
    });

    function updateReq(element, valid, text) {
        element.innerHTML =
            valid
            ? '<i class="fa-regular fa-circle-check"></i> ' + text
            : '<i class="fa-regular fa-circle-xmark"></i> ' + text;

        if (valid) {
            element.classList.add("valid");
        } else {
            element.classList.remove("valid");
        }
    }

    function validatePassword() {
        const pwd = passwordInput.value;
        const confirmPwd = confirmInput.value;

        const lengthValid = pwd.length >= 8;
        const upperValid = /[A-Z]/.test(pwd);
        const lowerValid = /[a-z]/.test(pwd);
        const numberValid = /[0-9]/.test(pwd);
        const specialValid = /[!@#$%^&*]/.test(pwd);

        updateReq(reqLength, lengthValid, "At least 8 characters");
        updateReq(reqUpper, upperValid, "One uppercase letter");
        updateReq(reqLower, lowerValid, "One lowercase letter");
        updateReq(reqNumber, numberValid, "One number");
        updateReq(reqSpecial, specialValid, "One special character (!@#$%^&*)");

        const passwordValid =
            lengthValid &&
            upperValid &&
            lowerValid &&
            numberValid &&
            specialValid;

        if (confirmPwd.length > 0) {
            if (pwd === confirmPwd) {
                matchMessage.className = "match-message success-text";
                matchMessage.innerHTML = '<i class="fa-regular fa-circle-check"></i> Passwords match';
            } else {
                matchMessage.className = "match-message error-text";
                matchMessage.innerHTML = '<i class="fa-regular fa-circle-xmark"></i> Passwords do not match';
            }
        } else {
            matchMessage.className = "match-message";
            matchMessage.innerHTML = "";
        }

        return passwordValid && pwd === confirmPwd;
    }

    passwordInput.addEventListener("input", validatePassword);
    confirmInput.addEventListener("input", validatePassword);

    form.addEventListener("submit", function(event) {
        if (!validatePassword()) {
            event.preventDefault();
            Swal.fire({
                title: "Check Your Password",
                text: "Please make sure your password follows all rules and both passwords match.",
                icon: "warning",
                confirmButtonColor: "#0F4C5C"
            });
        }
    });
</script>

</body>
</html>