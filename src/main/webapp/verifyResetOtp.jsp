<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
if (session.getAttribute("resetUserId") == null) {
    response.sendRedirect(request.getContextPath() + "/forgotPassword.jsp");
    return;
}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Verify OTP</title>
</head>
<body>

<h2>Verify OTP</h2>

<p>Enter the OTP sent to:</p>
<b><%= session.getAttribute("resetEmail") %></b>

<br><br>

<form action="<%= request.getContextPath() %>/VerifyResetOtpController" method="post">

    <input type="text" name="otp" placeholder="Enter 6-digit OTP" maxlength="6" required>

    <br><br>

    <button type="submit">Verify OTP</button>

</form>

<p style="color:red;">
<%= request.getAttribute("error") == null ? "" : request.getAttribute("error") %>
</p>

</body>
</html>