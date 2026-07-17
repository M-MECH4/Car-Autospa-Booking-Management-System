<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%!
    public String keepValue(HttpServletRequest request, String fieldName) {
        String value = request.getParameter(fieldName);

        if (value == null) {
            return "";
        }

        return value
                .replace("&", "&amp;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;")
                .replace("<", "&lt;")
                .replace(">", "&gt;");
    }

    public String keepSelected(HttpServletRequest request, String fieldName, String optionValue) {
        String value = request.getParameter(fieldName);

        if (value != null && value.equalsIgnoreCase(optionValue)) {
            return "selected";
        }

        return "";
    }
%>

<%
    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");
    String redirectToLogin = (String) request.getAttribute("redirectToLogin");

    boolean registerSuccess = "true".equalsIgnoreCase(redirectToLogin);
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Create Account | X-PERT DETAILING</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/register.css?v=<%= System.currentTimeMillis() %>">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>

<body>

<div class="create-account-container">

    <div class="form-header">

        <a href="${pageContext.request.contextPath}/index.html" class="back-home">
            <i class="fa-solid fa-arrow-left"></i>
            Back to Home
        </a>

        <div class="title-section">
            <div class="avatar-small">
                <i class="fa-solid fa-car"></i>
            </div>

            <h1>Create Customer Account</h1>
            <p>Register your account to book X-PERT DETAILING services</p>
        </div>

    </div>

    <% if (errorMessage != null && !errorMessage.trim().isEmpty()) { %>
        <div class="message-box error-box">
            <i class="fa-solid fa-circle-exclamation"></i>
            <%= errorMessage %>
        </div>
    <% } %>

    <% if (successMessage != null && !successMessage.trim().isEmpty()) { %>
        <div class="message-box success-box">
            <i class="fa-solid fa-circle-check"></i>
            <%= successMessage %>
        </div>
    <% } %>

    <% if (!registerSuccess) { %>

        <form action="<%= request.getContextPath() %>/RegisterController"
              method="post"
              class="form-grid"
              onsubmit="return validateRegisterPassword();">

            <div class="input-group">
                <label>Full Name</label>

                <div class="input-wrapper">
                    <i class="fa-regular fa-user input-icon"></i>
                    <input type="text"
                           name="fullName"
                           placeholder="Enter your full name"
                           value="<%= keepValue(request, "fullName") %>"
                           required>
                </div>
            </div>

            <div class="input-group">
                <label>Phone Number</label>

                <div class="input-wrapper">
                    <i class="fa-solid fa-phone input-icon"></i>
                    <input type="text"
                           name="phone"
                           inputmode="numeric"
                           pattern="[0-9]+"
                           maxlength="20"
                           title="Phone number must contain numbers only."
                           oninput="this.value = this.value.replace(/[^0-9]/g, '')"
                           placeholder="Example: 0123456789"
                           value="<%= keepValue(request, "phone") %>"
                           required>
                </div>
            </div>

            <div class="input-group">
                <label>Email</label>

                <div class="input-wrapper">
                    <i class="fa-regular fa-envelope input-icon"></i>
                    <input type="email"
                           name="email"
                           placeholder="Enter your email"
                           value="<%= keepValue(request, "email") %>"
                           required>
                </div>
            </div>

            <div class="input-group">
                <label>Username</label>

                <div class="input-wrapper">
                    <i class="fa-solid fa-user-tag input-icon"></i>
                    <input type="text"
                           name="username"
                           placeholder="Create username"
                           value="<%= keepValue(request, "username") %>"
                           required>
                </div>
            </div>

            <div class="input-group">
                <label>Race</label>

                <div class="input-wrapper">
                    <i class="fa-solid fa-users input-icon"></i>
                    <select name="race" required>
                        <option value="">Select race</option>
                        <option value="MALAY" <%= keepSelected(request, "race", "MALAY") %>>Malay</option>
                        <option value="CHINESE" <%= keepSelected(request, "race", "CHINESE") %>>Chinese</option>
                        <option value="INDIAN" <%= keepSelected(request, "race", "INDIAN") %>>Indian</option>
                        <option value="BUMIPUTERA" <%= keepSelected(request, "race", "BUMIPUTERA") %>>Bumiputera</option>
                        <option value="OTHER" <%= keepSelected(request, "race", "OTHER") %>>Other</option>
                    </select>
                </div>
            </div>

            <div class="input-group">
                <label>Religion</label>

                <div class="input-wrapper">
                    <i class="fa-solid fa-hands-praying input-icon"></i>
                    <select name="religion" required>
                        <option value="">Select religion</option>
                        <option value="ISLAM" <%= keepSelected(request, "religion", "ISLAM") %>>Islam</option>
                        <option value="BUDDHISM" <%= keepSelected(request, "religion", "BUDDHISM") %>>Buddhism</option>
                        <option value="CHRISTIANITY" <%= keepSelected(request, "religion", "CHRISTIANITY") %>>Christianity</option>
                        <option value="HINDUISM" <%= keepSelected(request, "religion", "HINDUISM") %>>Hinduism</option>
                        <option value="OTHER" <%= keepSelected(request, "religion", "OTHER") %>>Other</option>
                    </select>
                </div>
            </div>

            <div class="input-group">
                <label>Password</label>

                <div class="input-wrapper password-wrapper">
                    <i class="fa-solid fa-lock input-icon"></i>

                    <input type="password"
                           name="password"
                           id="password"
                           placeholder="Create password"
                           onkeyup="checkPasswordRules(); checkPasswordMatch();"
                           required>

                    <button type="button"
                            class="password-toggle"
                            onclick="togglePasswordVisibility('password', 'passwordEyeIcon')"
                            aria-label="Show password">
                        <i class="fa-regular fa-eye-slash" id="passwordEyeIcon"></i>
                    </button>
                </div>
            </div>

            <div class="input-group">
                <label>Confirm Password</label>

                <div class="input-wrapper password-wrapper">
                    <i class="fa-solid fa-lock input-icon"></i>

                    <input type="password"
                           name="confirmPassword"
                           id="confirmPassword"
                           placeholder="Confirm password"
                           onkeyup="checkPasswordMatch();"
                           required>

                    <button type="button"
                            class="password-toggle"
                            onclick="togglePasswordVisibility('confirmPassword', 'confirmPasswordEyeIcon')"
                            aria-label="Show confirm password">
                        <i class="fa-regular fa-eye-slash" id="confirmPasswordEyeIcon"></i>
                    </button>
                </div>
            </div>

            <div class="full-width">
                <div class="password-requirements">
                    <p>Password must contain:</p>

                    <ul class="requirements-list">
                        <li id="lengthRule">
                            <i class="fa-solid fa-circle-xmark"></i>
                            At least 8 characters
                        </li>

                        <li id="uppercaseRule">
                            <i class="fa-solid fa-circle-xmark"></i>
                            At least 1 uppercase letter
                        </li>

                        <li id="lowercaseRule">
                            <i class="fa-solid fa-circle-xmark"></i>
                            At least 1 lowercase letter
                        </li>

                        <li id="numberRule">
                            <i class="fa-solid fa-circle-xmark"></i>
                            At least 1 number
                        </li>

                        <li id="specialRule">
                            <i class="fa-solid fa-circle-xmark"></i>
                            At least 1 special character
                        </li>

                        <li id="matchRule">
                            <i class="fa-solid fa-circle-xmark"></i>
                            Passwords must match
                        </li>
                    </ul>
                </div>
            </div>

            <div class="full-width">
                <div class="message-box info-box">
                    <i class="fa-solid fa-circle-info"></i>
                    Race and religion are collected only to determine festive package eligibility.
                </div>
            </div>

            <div class="register-btn-wrapper">
                <button type="submit" class="register-btn">
                    Register
                </button>
            </div>

            <div class="signin-link">
                Already have an account?
                <a href="<%= request.getContextPath() %>/login.jsp">Sign in here</a>
            </div>

        </form>

    <% } else { %>

        <div class="form-grid">

            <div class="full-width">
                <div class="message-box success-box">
                    <i class="fa-solid fa-circle-check"></i>
                    Account has been created successfully.
                    Please wait. The system will go to login page.
                </div>
            </div>

        </div>

    <% } %>

</div>

<% if (registerSuccess) { %>
<script>
    setTimeout(function () {
        window.location.href = "<%= request.getContextPath() %>/login.jsp";
    }, 2500);
</script>
<% } %>

<script>
    function togglePasswordVisibility(inputId, iconId) {
        var passwordInput = document.getElementById(inputId);
        var eyeIcon = document.getElementById(iconId);

        if (!passwordInput || !eyeIcon) {
            return;
        }

        if (passwordInput.type === "password") {
            passwordInput.type = "text";
            eyeIcon.classList.remove("fa-eye-slash");
            eyeIcon.classList.add("fa-eye");
        } else {
            passwordInput.type = "password";
            eyeIcon.classList.remove("fa-eye");
            eyeIcon.classList.add("fa-eye-slash");
        }
    }

    function setRuleStatus(ruleId, isValid) {
        var rule = document.getElementById(ruleId);

        if (!rule) {
            return;
        }

        var icon = rule.querySelector("i");

        if (isValid) {
            rule.classList.add("valid");
            rule.classList.remove("invalid");

            icon.classList.remove("fa-circle-xmark");
            icon.classList.add("fa-circle-check");
        } else {
            rule.classList.add("invalid");
            rule.classList.remove("valid");

            icon.classList.remove("fa-circle-check");
            icon.classList.add("fa-circle-xmark");
        }
    }

    function checkPasswordRules() {
        var passwordInput = document.getElementById("password");

        if (!passwordInput) {
            return false;
        }

        var password = passwordInput.value;

        var hasLength = password.length >= 8;
        var hasUppercase = /[A-Z]/.test(password);
        var hasLowercase = /[a-z]/.test(password);
        var hasNumber = /[0-9]/.test(password);
        var hasSpecial = /[!@#$%^&*]/.test(password);

        setRuleStatus("lengthRule", hasLength);
        setRuleStatus("uppercaseRule", hasUppercase);
        setRuleStatus("lowercaseRule", hasLowercase);
        setRuleStatus("numberRule", hasNumber);
        setRuleStatus("specialRule", hasSpecial);

        return hasLength && hasUppercase && hasLowercase && hasNumber && hasSpecial;
    }

    function checkPasswordMatch() {
        var passwordInput = document.getElementById("password");
        var confirmPasswordInput = document.getElementById("confirmPassword");

        if (!passwordInput || !confirmPasswordInput) {
            return false;
        }

        var password = passwordInput.value;
        var confirmPassword = confirmPasswordInput.value;

        var isMatch = password.length > 0 && password === confirmPassword;

        setRuleStatus("matchRule", isMatch);

        return isMatch;
    }

    function validateRegisterPassword() {
        var isStrong = checkPasswordRules();
        var isMatch = checkPasswordMatch();

        if (!isStrong) {
            Swal.fire({
                title: "Password Requirements",
                text: "Password must be at least 8 characters and include an uppercase letter, lowercase letter, number, and special character.",
                icon: "warning",
                confirmButtonColor: "#0F4C5C"
            });
            return false;
        }

        if (!isMatch) {
            Swal.fire({
                title: "Passwords Do Not Match",
                text: "Password and confirm password must be the same.",
                icon: "error",
                confirmButtonColor: "#0F4C5C"
            });
            return false;
        }

        return true;
    }

    document.addEventListener("DOMContentLoaded", function () {
        checkPasswordRules();
        checkPasswordMatch();
    });
</script>

</body>
</html>