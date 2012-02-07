<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="genie.*" 
	pageEncoding="ISO-8859-1"
%>
<%
	String schema = request.getParameter("schema");
	
	Connect cn = (Connect) session.getAttribute("CN");
	cn.setSchema(schema);
%>
<% for (int i=0; i<cn.getTables().size();i++) { %>
	<li><a href="javascript:loadTable('<%=cn.getTable(i)%>');"><%=cn.getTable(i)%></a></li>
<% } %>

