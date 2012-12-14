<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="chingoo.mysql.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	Connect cn = (Connect) session.getAttribute("CN");
	Connect cn2 = (Connect) session.getAttribute("CN2");

	String object = request.getParameter("object");
	String incl = request.getParameter("incl");
	String excl = request.getParameter("excl");

	String sql = request.getParameter("text_sql");
	
	SchemaDiff sd = (SchemaDiff) session.getAttribute("SD");
	if (sd== null) {
		sd = new SchemaDiff(cn, cn2);
		session.setAttribute("SD", sd);
	}
	
	if (sql !=null) object = "Q";
	sd.startCompare(object, incl, excl, sql);
%>

<%= sd.getResult() %>
