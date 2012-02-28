<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="java.sql.*" 
	import="genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%
	Connect cn = (Connect) session.getAttribute("CN");

	String sql = "SELECT count(*) FROM information_schema.TABLES WHERE table_schema='" + cn.getSchemaName() + "' AND table_name='GENIE_PAGE_SQL'";
	String cnt = cn.queryOne(sql, false);
	
%>

<% if (cnt.equals("0")) { %>

GENIE needs to create the following 2 tables to use "User Defined Page" feature.
<br/><br/>

<li>GENIE_PAGE
<li>GENIE_PAGE_SQL

<br/><br/>

<form>
<input type="button" value="CREATE TABLE" onClick="Javascript:createGenieTable()">
</form>

<% 
		return;
	} 
%>

<%
	sql = "SELECT * FROM GENIE_PAGE";
	Query q = new Query(cn, sql);

	q.rewind(100, 1);
	while (q.next()) {
		String pageId = q.getValue("page_id");
%>
	<li><a href="page.jsp?page=<%=pageId%>" target="_blank"><%=q.getValue("title") %></a>

<%
	}
%>

<br/>
<br/>
<a href="edit_udp.jsp" target="_blank">Edit</a>
