<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="genie.Connect" 
	pageEncoding="ISO-8859-1"
%>
<%
	Connect cn = (Connect) session.getAttribute("CN");
	if (cn!=null) {
		try {
			cn.disconnect();
		} catch (Exception e) {}
	}
	
	session.removeAttribute("CN");
%>

<html>
  <head>
    <title>Genie 4 MySQL</title>
    <link rel='stylesheet' type='text/css' href='css/style.css'> 
  </head>

 <img src="image/genie.jpg"/>

<h2>Disconnected. Good Bye!</h2>

<br/>
<a href="index.jsp">Home</a>

</html>