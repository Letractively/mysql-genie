<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="java.sql.*" 
	import="chingoo.mysql.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%
	Connect cn = (Connect) session.getAttribute("CN");

	String sql = "SELECT count(*) FROM information_schema.TABLES WHERE table_schema='" + cn.getSchemaName() + "' AND table_name='CHINGOO_SAVED_SQL'";
	String cnt = cn.queryOne(sql, false);
	
%>

<% if (cnt.equals("0")) { %>

Chingoo needs to create the following table to use "Saved Query" feature.
<br/><br/>

<li>CHINGOO_SAVED_SQL

<br/><br/>

<form>
<input type="button" value="CREATE TABLE" onClick="Javascript:createChingooTable2()">
</form>

<% 
		return;
	} 
%>

<a href="edit_sq.jsp" target="_blank">Edit / Add Saved Query</a><br/><br/>

<%
	sql = "SELECT * FROM CHINGOO_SAVED_SQL ORDER BY ID";
	Query q = new Query(cn, sql);

	q.rewind(100, 1);
	int i=0;
	while (q.next()) {
		i++;
		String id = q.getValue("ID");
		String sqlStmt = q.getValue("SQL_STMT");
%>
<div style="display: none;" id="SQ-<%=i%>"><%= sqlStmt%></div>
	<li><a href="Javascript:runSQ(<%=i%>)"><%= id %></a>

<%
	}
%>

<form id="form_SQ" target="_blank" method="post" action="query.jsp">
<input id="SQ_sql" name="sql" type="hidden">
</form>



