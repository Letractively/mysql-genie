<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="chingoo.mysql.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	Connect cn = (Connect) session.getAttribute("CN");

	SchemaDiff sd = (SchemaDiff) session.getAttribute("SD");
	
	if (sd != null) {
		sd.cancel();
		
	}
%>
<%
%>
