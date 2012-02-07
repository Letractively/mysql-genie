<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="java.sql.*" 
	import="genie.Connect" 
	pageEncoding="ISO-8859-1"
%>

<%
	Connect cn = (Connect) session.getAttribute("CN");

	boolean connected = true;
	if (cn==null || !cn.isConnected()) {
		connected = false;
	} else {
		cn.ping();
	}
	
//	System.out.println("ping " + connected + " " + (new Date()));
%>

<%=connected%> <%= new Date() %>