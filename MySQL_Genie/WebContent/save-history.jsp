<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="java.sql.*" 
	import="genie.Connect" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	Connect cn = (Connect) session.getAttribute("CN");

	String value = request.getParameter("value");

	boolean connected = true;
	if (cn==null || !cn.isConnected()) {
		connected = false;
	} else {
		cn.ping();
	}
	
	if (value != null) cn.addHistory(value);
//	System.out.println("ping " + connected + " " + (new Date()));
%>
