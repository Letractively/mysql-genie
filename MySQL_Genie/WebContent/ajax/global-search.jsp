<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="chingoo.mysql.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%
	String keyword = request.getParameter("keyword").toUpperCase().trim();;
	Connect cn = (Connect) session.getAttribute("CN");
		
	String catalog = cn.getSchemaName();
%>

<h2>Search Result for "<%= keyword %>"</h2>

<b>Table:</b><br/>
<%

	String qry = "SELECT TABLE_NAME FROM information_schema.TABLES WHERE TABLE_NAME LIKE '%" + Util.escapeQuote(keyword) +"%' AND table_schema='" + catalog + "' and table_type='BASE TABLE' ORDER BY TABLE_NAME";
	List<String> list = cn.queryMulti(qry);

	for (String text : list) {
%>
	&nbsp;&nbsp;
	<a href="javascript:loadTable('<%=text%>');"><%=text%></a>  <span class="rowcountstyle"><%= cn.getTableRowCount(text) %></span><br/>
	
<%
	}
%>

<br/>
<b>View:</b><br/>
<%
	qry = "SELECT TABLE_NAME FROM information_schema.TABLES WHERE TABLE_NAME LIKE '%" + Util.escapeQuote(keyword) +"%' AND table_schema='" + catalog + "' and table_type='VIEW' ORDER BY TABLE_NAME";
	list = cn.queryMulti(qry);
	
	for (String text : list) {
%>
	&nbsp;&nbsp;
	<a href="javascript:loadView('<%=text%>');"><%=text%></a><br/>
	
<%
	}
%>

<br/>
<b>Program:</b><br/>
<%
	qry = "SELECT ROUTINE_NAME FROM information_schema.ROUTINES WHERE ROUTINE_NAME LIKE '%" + Util.escapeQuote(keyword) +"%' AND routine_schema='" + catalog + "' ORDER BY ROUTINE_NAME";
	list = cn.queryMulti(qry);

	for (String text : list) {
%>
	&nbsp;&nbsp;
	<a href="javascript:loadPackage('<%=text%>');"><%=text%></a><br/>
	
<%
	}
%>

<%--
<br/>
<b>Synonym:</b><br/>
<%
	qry = "SELECT OBJECT_NAME FROM USER_OBJECTS WHERE object_type='SYNONYM' AND OBJECT_NAME LIKE '%" + Util.escapeQuote(keyword) +"%' ORDER BY OBJECT_NAME";
	list = cn.queryMulti(qry);

	for (String text : list) {
%>
	&nbsp;&nbsp;
	<a href="javascript:loadSynonym('<%=text%>');"><%=text%></a><br/>
<%
	}
%>
 --%>

<br/>
<b>Column:</b><br/>
<%
	qry = "SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE FROM information_schema.columns WHERE COLUMN_NAME='" + Util.escapeQuote(keyword) +"' AND table_schema='" + catalog + "' ORDER BY TABLE_NAME";
	List<String[]> lst = cn.query(qry);
	
	for (String[] rec : lst) {
		String tname = rec[1];
		String cname = rec[2];
		String data_type = rec[3];
%>
	&nbsp;&nbsp;
	<a href="javascript:loadTable('<%=tname%>');"><%=tname%></a>.<%= cname %> <%= data_type %><br/>
<%
	}
%>


<br/>
<b>Table Comments:</b><br/>
<%
	qry = "SELECT TABLE_NAME, table_comment FROM information_schema.tables WHERE table_comment LIKE '%" + Util.escapeQuote(keyword) +"%' and table_schema='"+catalog+"' ORDER BY TABLE_NAME";
	lst = cn.query(qry);

	for (String[] rec : lst) {
		String tname = rec[1];
		String comments = rec[2];
%>
	&nbsp;&nbsp;
	<a href="javascript:loadTable('<%=tname%>');"><%=tname%></a> <%= comments %><br/>
<%
	}
%>


<br/>
<b>Column Comments:</b><br/>
<%
	qry = "SELECT TABLE_NAME, column_name, column_comment FROM information_schema.columns WHERE column_comment LIKE '%" + Util.escapeQuote(keyword) +"%' and table_schema='"+catalog+"' ORDER BY TABLE_NAME";
//out.println(qry);
	lst = cn.query(qry);

	for (String[] rec : lst) {
		String tname = rec[1];
		String cname = rec[2];
		String comments = rec[3];
%>
	&nbsp;&nbsp;
	<a href="javascript:loadTable('<%=tname%>');"><%=tname%></a>.<%= cname %> <%= comments %><br/>
<%
	}
%>


