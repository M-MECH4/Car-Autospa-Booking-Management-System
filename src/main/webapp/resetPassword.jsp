<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
Boolean verified = (Boolean) session.getAttribute("resetVerified");

if (verified == null || !verified) {
    response.sendRedirect(request.getContextPath() + "/forgotPassword.jsp");
    return;
}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Reset Password</title>
</head>
<body>

<h2>Reset Password</h2>

<form action="<%= request.getContextPath() %>/ResetPasswordController" method="post">

    <input type="password" name="newPassword" placeholder="New password" required>

    <br><br>

    <input type="password" name="confirmPassword" placeholder="Confirm password" required>

    <br><br>

    <button type="submit">Reset Password</button>

</form>

<p style="color:red;">
<%= request.getAttribute("error") == null ? "" : request.getAttribute("error") %>
</p>

</body>
</html>