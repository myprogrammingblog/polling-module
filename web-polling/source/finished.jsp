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
<%@page import="javax.servlet.http.Cookie"%>

<%
	boolean validVote = false;
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
	
	String vote = null;
	String [] votes = null;
	if (connection.getTitle() != null) {
		if (connection.getMultiple().equals("false")) {
			vote = request.getParameter( "answers" );
		} else {
			votes = request.getParameterValues( "answers" );
		}
	}

	if (connection.getTitle() == null || (votes == null && vote == null)) {
		error = "Error 408: You must vote first.";
	} else if (connection.sessionVoted(connection.getWebKey()) ||  (cookieValue != null && connection.cookieCheck(cookieValue, connection.getWebKey()))) { // already voted
		error = "Error 406: Already voted.";
	} else if (connection.getMultiple().equals("false")) { // radio buttons used

		// check to see if they actually pressed the submit button
		if (vote != null) {
			validVote = true;
			
			connection.recordRadioVote(vote);
		}
	} else {									// checkboxes used
		
		if (votes != null) {
			validVote = true;
			
			connection.recordCheckVote(votes);
		}
	}
%>

<%
	if (validVote) {
		%>
		<html>
		<head>
			<title><%= connection.getTitle()%></title>
		</head>
		<body>
			Thank you for voting!
		<% 
	} 
	
	if (error != null) { // they went straight to finished.jsp
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
		
	<%
	if (validVote) {
		
		if (cookieValue == null) {
			cookieValue = "," + (String) session.getAttribute("webkey") + ",";
		} else {
			cookieValue += session.getAttribute("webkey") + ",";
		}
		
		Cookie bbbpollstaken = new Cookie("bbbpollstaken", cookieValue);
		bbbpollstaken.setMaxAge(60*60*8); // expire after 8h
		
		response.addCookie( bbbpollstaken );
	}
%>