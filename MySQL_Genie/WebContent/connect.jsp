<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="genie.Connect" 
	pageEncoding="ISO-8859-1"
%>

<%
	String url = request.getParameter("url");
	String username = request.getParameter("username");
	String password = request.getParameter("password");
	
	Connect cn = new Connect(url, username, password, request.getRemoteAddr());
	
	if (cn.isConnected()) {
		// you're connected.
		// assign the Connect object to session
		session.setAttribute("CN", cn);
	
		// redirect to homepage
		response.sendRedirect("index.jsp");
		return;
	}
%>

<html>
  <head>
    <title>Genie for MySQL</title>
    <link rel='stylesheet' type='text/css' href='css/style.css'> 
  </head>
  
  <body>

  <img src="image/genie.jpg"/><br/>

	<h2>Sorry, Genie could not connect to the database.</h2>
	Message: <%= cn.getMessage() %>
	<br/><br/>
	
	<a href="javascript:history.back()">Try Again</a>
	 

</body>
</html>
