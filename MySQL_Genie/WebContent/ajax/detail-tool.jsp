<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	String owner = request.getParameter("owner");
	String tool = request.getParameter("name");
	Connect cn = (Connect) session.getAttribute("CN");

	String catalog = cn.getSchemaName();

	String qry=null;
	if (tool.equalsIgnoreCase("system view"))
		qry = "select table_schema, table_name from information_schema.tables where table_type='SYSTEM VIEW'";
	else if (tool.equalsIgnoreCase("sequence"))
		qry = "SELECT * FROM USER_SEQUENCES ORDER BY 1";
	else if (tool.equalsIgnoreCase("db link"))
		qry = "SELECT * FROM USER_DB_LINKS ORDER BY 1";
	else if (tool.equalsIgnoreCase("User role priv")) {
		qry = "SELECT * FROM USER_ROLE_PRIVS";
	}
	
	// 
%>
<h2>TOOL: <%= tool %> &nbsp;&nbsp;</h2>

<% if (qry != null)  {%>
<jsp:include page="detail-tool-query.jsp">
	<jsp:param value="<%= qry %>" name="qry"/>
	
</jsp:include>

<% } %>

<% if (tool.equalsIgnoreCase("search db content")) { %>
<jsp:include page="content-search.jsp"/>
<% } %>

