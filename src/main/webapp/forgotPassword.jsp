<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Forgot Password</title>
</head>
<body>

<h2>Forgot Password</h2>

<form action="<%= request.getContextPath() %>/ForgotPasswordController" method="post">

    <input type="email" name="email" placeholder="Enter your email" required>

    <br><br>

    <select name="role" required>
        <option value="">-- Select Role --</option>
        <option value="customer">Customer</option>
        <option value="staff">Staff</option>
        <option value="owner">Owner</option>
    </select>

    <br><br>

    <button type="submit">Send OTP</button>

</form>

<p style="color:red;">
<%= request.getAttribute("error") == null ? "" : request.getAttribute("error") %>
</p>

<a href="<%= request.getContextPath() %>/login.jsp">Back to Login</a>

</body>
</html>