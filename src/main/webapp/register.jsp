<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Create Customer Account | X-PERT DETAILING</title>

  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/register.css">
  
</head>

<body>

  <div class="create-account-container">

    <div class="form-header">
      <a href="${pageContext.request.contextPath}/index.html" class="back-home">
        <i class="fa-solid fa-arrow-left"></i> Back to Home
      </a>

      <div class="avatar-small">
        <img src="${pageContext.request.contextPath}/LOGO%20XPERT.png" alt="Profile Logo">
      </div>

      <div class="title-section">
        <h1>Create Customer Account</h1>
        <p>Join X-PERT DETAILING today</p>
      </div>
    </div>

    <%
      String errorMessage = (String) request.getAttribute("errorMessage");
      String successMessage = (String) request.getAttribute("successMessage");

      if (errorMessage != null && !errorMessage.trim().isEmpty()) {
    %>
      <div class="message-box error-box">
        <%= errorMessage %>
      </div>
    <%
      }

      if (successMessage != null && !successMessage.trim().isEmpty()) {
    %>
      <div class="message-box success-box">
        <%= successMessage %>
      </div>
    <%
      }
    %>

    <form action="${pageContext.request.contextPath}/RegisterController" method="post">

      <div class="form-grid">

        <div class="input-group">
          <label>Full Name *</label>
          <div class="input-wrapper">
            <i class="fa-regular fa-circle-user input-icon"></i>
            <input type="text" name="fullName" placeholder="Enter your full name" autocomplete="off" required>
          </div>
        </div>

        <div class="input-group">
          <label>Phone Number *</label>
          <div class="input-wrapper">
            <i class="fa-solid fa-mobile-alt input-icon"></i>
            <input type="tel" name="phone" placeholder="0123456789" required>
          </div>
        </div>

        <div class="input-group">
          <label>Email *</label>
          <div class="input-wrapper">
            <i class="fa-regular fa-envelope input-icon"></i>
            <input type="email" name="email" placeholder="your.email@example.com" required>
          </div>
        </div>

        <div class="input-group">
          <label>Race *</label>
          <div class="input-wrapper">
            <i class="fa-regular fa-flag input-icon"></i>
            <select name="race" required>
              <option value="" disabled selected>Select race</option>
              <option value="Malay">Malay</option>
              <option value="Chinese">Chinese</option>
              <option value="Indian">Indian</option>
              <option value="Other Bumiputera">Other Bumiputera</option>
              <option value="Others">Others</option>
            </select>
          </div>
        </div>

        <div class="input-group">
          <label>Religion *</label>
          <div class="input-wrapper">
            <i class="fa-solid fa-dove input-icon"></i>
            <select name="religion" required>
              <option value="" disabled selected>Select religion</option>
              <option value="Islam">Islam</option>
              <option value="Christianity">Christianity</option>
              <option value="Hinduism">Hinduism</option>
              <option value="Buddhism">Buddhism</option>
              <option value="Other">Other</option>
            </select>
          </div>
        </div>

        <div class="input-group">
          <label>Username *</label>
          <div class="input-wrapper">
            <i class="fa-regular fa-circle-check input-icon"></i>
            <input type="text" name="username" placeholder="Choose a username" required>
          </div>
        </div>

        <div class="input-group">
          <label>Password *</label>
          <div class="input-wrapper">
            <i class="fa-solid fa-key input-icon"></i>
            <input type="password" id="password" name="password" placeholder="Enter password" required>

            <button type="button" class="password-toggle" id="togglePassword">
              <i class="fa-regular fa-eye-slash"></i>
            </button>
          </div>
        </div>

        <div class="input-group">
          <label>Confirm Password *</label>
          <div class="input-wrapper">
            <i class="fa-solid fa-check-circle input-icon"></i>
            <input type="password" id="confirmPassword" name="confirmPassword" placeholder="Confirm password" required>

            <button type="button" class="password-toggle" id="toggleConfirmPassword">
              <i class="fa-regular fa-eye-slash"></i>
            </button>
          </div>
        </div>

        <div class="full-width password-requirements">
          <p><i class="fa-solid fa-shield-halved"></i> Password must contain:</p>
          <ul class="requirements-list">
            <li id="reqLength"><i class="fa-regular fa-circle-xmark"></i> At least 8 characters</li>
            <li id="reqUpper"><i class="fa-regular fa-circle-xmark"></i> One uppercase letter</li>
            <li id="reqLower"><i class="fa-regular fa-circle-xmark"></i> One lowercase letter</li>
            <li id="reqNumber"><i class="fa-regular fa-circle-xmark"></i> One number</li>
            <li id="reqSpecial"><i class="fa-regular fa-circle-xmark"></i> One special character (!@#$%^&amp;*)</li>
          </ul>
        </div>

        <div class="register-btn-wrapper">
          <button type="submit" class="register-btn">
            <i class="fa-solid fa-user-plus"></i> Register
          </button>
        </div>

        <div class="signin-link">
          Already have an account?
          <a href="${pageContext.request.contextPath}/login.jsp">Sign In</a>
        </div>

      </div>
    </form>

  </div>

  <script>
    var passwordInput = document.getElementById('password');
    var confirmInput = document.getElementById('confirmPassword');
    var togglePwd = document.getElementById('togglePassword');
    var toggleConfirm = document.getElementById('toggleConfirmPassword');

    togglePwd.addEventListener('click', function () {
      var type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
      passwordInput.setAttribute('type', type);

      togglePwd.innerHTML = type === 'password'
        ? '<i class="fa-regular fa-eye-slash"></i>'
        : '<i class="fa-regular fa-eye"></i>';
    });

    toggleConfirm.addEventListener('click', function () {
      var type = confirmInput.getAttribute('type') === 'password' ? 'text' : 'password';
      confirmInput.setAttribute('type', type);

      toggleConfirm.innerHTML = type === 'password'
        ? '<i class="fa-regular fa-eye-slash"></i>'
        : '<i class="fa-regular fa-eye"></i>';
    });

    var reqLength = document.getElementById('reqLength');
    var reqUpper = document.getElementById('reqUpper');
    var reqLower = document.getElementById('reqLower');
    var reqNumber = document.getElementById('reqNumber');
    var reqSpecial = document.getElementById('reqSpecial');

    function updateReq(el, isValid, text) {
      el.innerHTML = isValid
        ? '<i class="fa-regular fa-circle-check"></i> ' + text
        : '<i class="fa-regular fa-circle-xmark"></i> ' + text;

      if (isValid) {
        el.classList.add('valid');
      } else {
        el.classList.remove('valid');
      }
    }

    passwordInput.addEventListener('input', function () {
      var pwd = passwordInput.value;

      updateReq(reqLength, pwd.length >= 8, 'At least 8 characters');
      updateReq(reqUpper, /[A-Z]/.test(pwd), 'One uppercase letter');
      updateReq(reqLower, /[a-z]/.test(pwd), 'One lowercase letter');
      updateReq(reqNumber, /[0-9]/.test(pwd), 'One number');
      updateReq(reqSpecial, /[!@#$%^&*]/.test(pwd), 'One special character (!@#$%^&*)');
    });
  </script>

</body>

</html>