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
    if (session.getAttribute("resetUserId") == null) {
        response.sendRedirect(request.getContextPath() + "/forgotPassword.jsp");
        return;
    }

    String contextPath = request.getContextPath();

    String resetEmail = (String) session.getAttribute("resetEmail");
    String resetRole = (String) session.getAttribute("resetRole");

    if (resetEmail == null) resetEmail = "";
    if (resetRole == null) resetRole = "";

    String error = (String) request.getAttribute("error");
    String success = (String) request.getAttribute("success");

    String otpValue = request.getParameter("otp");
    if (otpValue == null) otpValue = "";
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Verify OTP | X-PERT DETAILING</title>
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
                url("<%= contextPath %>/images/background.jpg");
            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
        }

        .otp-container {
            width: 100%;
            max-width: 480px;
            background: #ffffff;
            border-radius: 34px;
            box-shadow: 0 25px 45px rgba(0, 0, 0, 0.16);
            overflow: hidden;
        }

        .otp-header {
            background: #074858;
            padding: 24px 34px 30px;
            color: white;
            text-align: center;
        }

        .back-link {
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

        .back-link:hover {
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

        .otp-header h1 {
            font-size: 28px;
            font-weight: 900;
            margin-bottom: 8px;
        }

        .otp-header p {
            color: #d8eef4;
            font-size: 14px;
            font-weight: 600;
            line-height: 1.5;
        }

        .otp-body {
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

        .email-box {
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            color: #475569;
            padding: 15px 16px;
            border-radius: 16px;
            font-size: 13px;
            font-weight: 700;
            line-height: 1.5;
            margin-bottom: 22px;
            display: flex;
            gap: 11px;
        }

        .email-box i {
            color: #074858;
            margin-top: 2px;
            font-size: 16px;
        }

        .email-box strong {
            color: #074858;
            font-weight: 900;
            word-break: break-all;
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

        .otp-input-wrapper {
            position: relative;
        }

        .otp-input-wrapper i {
            position: absolute;
            left: 16px;
            top: 50%;
            transform: translateY(-50%);
            color: #64748b;
            font-size: 16px;
        }

        .otp-input {
            width: 100%;
            padding: 16px 16px 16px 48px;
            border: 1px solid #d1d5db;
            border-radius: 16px;
            outline: none;
            font-size: 22px;
            font-weight: 900;
            color: #1f2937;
            background: #ffffff;
            letter-spacing: 8px;
            text-align: center;
        }

        .otp-input::placeholder {
            color: #94a3b8;
            font-size: 15px;
            letter-spacing: normal;
            text-align: left;
            font-weight: 600;
        }

        .otp-input:focus {
            border-color: #074858;
            box-shadow: 0 0 0 3px rgba(7, 72, 88, 0.12);
        }

        .hint-text {
            margin-top: 9px;
            color: #64748b;
            font-size: 13px;
            font-weight: 600;
            line-height: 1.4;
        }

        .verify-btn {
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

        .verify-btn:hover {
            background: #053947;
            transform: translateY(-1px);
            box-shadow: 0 12px 22px rgba(7, 72, 88, 0.24);
        }

        .verify-btn:active {
            transform: translateY(0);
        }

        .divider {
            display: flex;
            align-items: center;
            gap: 12px;
            margin: 24px 0 18px;
            color: #94a3b8;
            font-size: 13px;
            font-weight: 800;
        }

        .divider::before,
        .divider::after {
            content: "";
            flex: 1;
            height: 1px;
            background: #e2e8f0;
        }

        .resend-form {
            margin-bottom: 16px;
        }

        .resend-btn {
            width: 100%;
            border: 1px solid #074858;
            background: #ffffff;
            color: #074858;
            padding: 13px;
            border-radius: 16px;
            font-size: 14px;
            font-weight: 900;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            transition: 0.2s ease;
        }

        .resend-btn:hover {
            background: #f0f9fb;
        }

        .resend-btn:disabled {
            cursor: not-allowed;
            color: #64748b;
            border-color: #cbd5e1;
            background: #f1f5f9;
            box-shadow: none;
        }

        .resend-btn:disabled:hover {
            background: #f1f5f9;
        }

        .resend-note {
            text-align: center;
            margin-top: 10px;
            color: #64748b;
            font-size: 13px;
            font-weight: 700;
            line-height: 1.4;
        }

        .bottom-link {
            text-align: center;
            margin-top: 18px;
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

            .otp-container {
                border-radius: 26px;
            }

            .otp-header {
                padding: 22px 24px 28px;
            }

            .otp-body {
                padding: 26px 22px;
            }

            .otp-header h1 {
                font-size: 24px;
            }

            .otp-input {
                font-size: 20px;
                letter-spacing: 6px;
            }
        }
    </style>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>

<body>

<div class="otp-container">

    <div class="otp-header">

        <a href="<%= contextPath %>/forgotPassword.jsp" class="back-link">
            <i class="fa-solid fa-arrow-left"></i>
            Back
        </a>

        <div class="login-logo">
                <i class="fa-solid fa-car"></i>
        </div>

        <h1>Verify OTP</h1>
        <p>Enter the 6-digit OTP code that was sent to your registered email.</p>

    </div>

    <div class="otp-body">

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

        <div class="email-box">
            <i class="fa-regular fa-envelope"></i>
            <span>
                OTP sent to:<br>
                <strong><%= escapeHtml(resetEmail) %></strong>
            </span>
        </div>

        <form action="<%= contextPath %>/VerifyResetOtpController" method="post">

            <div class="form-group">
                <label>OTP Code</label>

                <div class="otp-input-wrapper">
                    <i class="fa-solid fa-shield-halved"></i>

                    <input
                        type="text"
                        id="otp"
                        name="otp"
                        class="otp-input"
                        maxlength="6"
                        placeholder="Enter 6-digit OTP"
                        value="<%= escapeHtml(otpValue) %>"
                        pattern="[0-9]{6}"
                        inputmode="numeric"
                        autocomplete="one-time-code"
                        required>
                </div>

                <p class="hint-text">
                    The OTP must contain exactly 6 numbers.
                </p>
            </div>

            <button type="submit" class="verify-btn">
                <i class="fa-solid fa-circle-check"></i>
                Verify OTP
            </button>

        </form>

        <div class="divider">OR</div>

        <form action="<%= contextPath %>/ForgotPasswordController" method="post" class="resend-form" id="resendForm">
            <input type="hidden" name="email" value="<%= escapeHtml(resetEmail) %>">
            <input type="hidden" name="role" value="<%= escapeHtml(resetRole) %>">

            <button type="submit" class="resend-btn" id="resendBtn">
                <i class="fa-solid fa-rotate-right"></i>
                <span id="resendText">Resend OTP</span>
            </button>

            <p class="resend-note" id="resendNote">
                You can resend the OTP after 60 seconds.
            </p>
        </form>

        <div class="bottom-link">
            Wrong email?
            <a href="<%= contextPath %>/forgotPassword.jsp">Try again</a>
        </div>

    </div>

</div>

<script>
    const otpInput = document.getElementById("otp");

    otpInput.addEventListener("input", function () {
        this.value = this.value.replace(/[^0-9]/g, "").slice(0, 6);
    });

    otpInput.addEventListener("paste", function (event) {
        event.preventDefault();

        const pastedText = (event.clipboardData || window.clipboardData).getData("text");
        this.value = pastedText.replace(/[^0-9]/g, "").slice(0, 6);
    });


    const resendForm = document.getElementById("resendForm");
    const resendBtn = document.getElementById("resendBtn");
    const resendText = document.getElementById("resendText");
    const resendNote = document.getElementById("resendNote");

    const waitSeconds = 60;
    const resetEmail = "<%= escapeHtml(resetEmail) %>";
    const storageKey = "otp_resend_wait_until_" + resetEmail;

    let countdownInterval = null;

    function startCountdown(secondsLeft) {
        resendBtn.disabled = true;
        resendText.textContent = "Resend OTP in " + secondsLeft + "s";
        resendNote.textContent = "Please wait before requesting another OTP.";

        clearInterval(countdownInterval);

        countdownInterval = setInterval(function () {
            secondsLeft--;

            if (secondsLeft <= 0) {
                clearInterval(countdownInterval);
                resendBtn.disabled = false;
                resendText.textContent = "Resend OTP";
                resendNote.textContent = "You can now resend the OTP.";
                localStorage.removeItem(storageKey);
            } else {
                resendText.textContent = "Resend OTP in " + secondsLeft + "s";
            }
        }, 1000);
    }

    function checkCountdownOnLoad() {
        const waitUntil = localStorage.getItem(storageKey);

        if (waitUntil) {
            const remainingSeconds = Math.ceil((parseInt(waitUntil) - Date.now()) / 1000);

            if (remainingSeconds > 0) {
                startCountdown(remainingSeconds);
            } else {
                localStorage.removeItem(storageKey);
            }
        } else {
            const newWaitUntil = Date.now() + (waitSeconds * 1000);
            localStorage.setItem(storageKey, newWaitUntil);
            startCountdown(waitSeconds);
        }
    }

    resendForm.addEventListener("submit", function () {
        const newWaitUntil = Date.now() + (waitSeconds * 1000);
        localStorage.setItem(storageKey, newWaitUntil);
    });

    checkCountdownOnLoad();
</script>

</body>
</html>