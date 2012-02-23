<html>
<body>
<form method="post" action="getParameter.jsp" >
<table>
<tr><td>
Enter your Name:</td><td><input type="text" size="20" name="name"/></td></tr><tr><td>
Enter your Address:</td><td><input type="text" size="20" name="address"/><br></td></tr><tr><td>
<input type="submit" value="Get Parameter"/></td></tr>
<%
if (request.getParameter("name") == null&&request.getParameter("address") == null) {
out.println("Please enter the fields.");
} else {%>
<tr><td><%
out.println("Name: <b>"+request.getParameter("name")+"</b>!"+"<br>");
out.println("Address: <b>"+request.getParameter("address")+"</b>!");
}
%>
</td></tr>
</table>
</form>
</body>
</html>