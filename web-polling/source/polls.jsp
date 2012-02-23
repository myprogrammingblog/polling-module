<%
/**
* BigBlueButton open source conferencing system - http://www.bigbluebutton.org/
*
* Copyright (c) 2010 BigBlueButton Inc. and by respective authors (see below).
*
* This program is free software; you can redistribute it and/or modify it under the
* terms of the GNU Lesser General Public License as published by the Free Software
* Foundation; either version 2.1 of the License, or (at your option) any later
* version.
*
* BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY
* WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
* PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License along
* with BigBlueButton; if not, see <http://www.gnu.org/licenses/>.
* 
*/
%>

<jsp:useBean id="connection" class="connection.JedisConnection" scope="session"/>
<jsp:setProperty name="connection" property="*"/> 

<%@page import="javax.servlet.http.Cookie"%>

<%
	String poll = request.getParameter( "poll" );
	String error = null;
	
	// grab cookies and look for bbbpollstaken
	String cookieValue = null;
	Cookie [] cookies = request.getCookies();
	if (cookies != null) {
		for (int i=0; i < cookies.length; i++) {
			if (cookies[i].getName().equals("bbbpollstaken")) {
				cookieValue = cookies[i].getValue();
			}
		}
	}
	
	if (poll == null) {
		error = "Error 404: No poll entered.";
	} else if (connection.cleanWebKey(poll)) {
		error = "Error 405: Improper formatting.";
	} else if (connection.sessionVoted(poll) || (cookieValue != null && connection.cookieCheck(cookieValue, poll))) { // already voted
		error = "Error 406: Already voted.";
	} else if (!connection.retrievePoll(poll)) { // tries to find poll
		error = "Error 407: Poll not found.";
	} else {
	  	String [] answers = connection.getAnswers();
	  	session.setAttribute("webkey", poll); %>
		<html>
		<head>
			<title><%= connection.getTitle()%></title>
		</head>
		<body>
			<%= connection.getQuestion()%> <br /> <br />
			<form method="post" action="finished.jsp">
				<%
				// determine whether to use checkboxes or radio buttons
				String type;
				if (connection.getMultiple().equals("true")) {
					type = "checkbox";
				} else {
					type = "radio";
				}
				
				// display the possible answers
				for (int i=0; i < answers.length; i++){
					%>
					<input type="<%= type%>" name="answers" value="<%= i+1%>" /> <%= answers[i]%> <br />
					<%
				}
				%>
				<br />
				<input type="submit" value="Submit" />
			</form>		
	<%
	}
	
	
	if (error != null) {
	%>
		<html>
		<head>
			<title>Error</title>
		</head>
		<body>
			<h1> <%= error%> </h1>
	<% 
	} 
	%>
</body>
</html>
