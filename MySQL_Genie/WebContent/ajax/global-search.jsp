<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%
	String keyword = request.getParameter("keyword").toUpperCase();
	Connect cn = (Connect) session.getAttribute("CN");
		
	String catalog = cn.getSchemaName();
%>

<h2>Search Result for "<%= keyword %>"</h2>

<b>Table:</b><br/>
<%

	String qry = "SELECT TABLE_NAME FROM USER_TABLES WHERE TABLE_NAME LIKE '%" + Util.escapeQuote(keyword) +"%' ORDER BY TABLE_NAME";
	List<String> list = cn.queryMulti(qry);

	for (String text : list) {
%>
	&nbsp;&nbsp;
	<a href="javascript:loadTable('<%=text%>');"><%=text%></a><br/>
	
<%
	}
%>

<br/>
<b>View:</b><br/>
<%
	qry = "SELECT VIEW_NAME FROM USER_VIEWS WHERE VIEW_NAME LIKE '%" + Util.escapeQuote(keyword) +"%' ORDER BY VIEW_NAME";
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
	qry = "SELECT OBJECT_NAME FROM USER_OBJECTS WHERE object_type IN ('PACKAGE','PROCEDURE','FUNCTION','TYPE') AND OBJECT_NAME LIKE '%" + Util.escapeQuote(keyword) + "%' ORDER BY OBJECT_NAME";
	list = cn.queryMulti(qry);

	for (String text : list) {
%>
	&nbsp;&nbsp;
	<a href="javascript:loadPackage('<%=text%>');"><%=text%></a><br/>
	
<%
	}
%>

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

<br/>
<b>Column:</b><br/>
<%
	qry = "SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE, DATA_LENGTH, DATA_PRECISION, DATA_SCALE FROM USER_TAB_COLUMNS WHERE COLUMN_NAME='" + Util.escapeQuote(keyword) +"' ORDER BY TABLE_NAME";
	List<String[]> lst = cn.queryMultiCol(qry, 6);
	
	for (String[] rec : lst) {
		String tname = rec[1];
		String cname = rec[2];

		String data_type = rec[3];

		int data_length = (rec[4]!=null?Integer.parseInt(rec[4]):0);
		int data_prec   = (rec[5]!=null?Integer.parseInt(rec[5]):0);
		int data_scale  = (rec[6]!=null?Integer.parseInt(rec[6]):0);

		String dType = data_type.toLowerCase();

		if (dType.equals("varchar") || dType.equals("varchar2") || dType.equals("char"))
			dType += "(" + data_length + ")";

		if (dType.equals("number")) {
			if (data_prec > 0 && data_scale > 0)
				dType += "(" + data_prec + "," + data_scale +")";
			else if (data_prec > 0)
				dType += "(" + data_prec + ")";
		}
%>
	&nbsp;&nbsp;
	<a href="javascript:loadTable('<%=tname%>');"><%=tname%></a>.<%= cname.toLowerCase() %> <%= dType %><br/>
<%
	}
%>


<br/>
<b>Table Comments:</b><br/>
<%
	qry = "SELECT TABLE_NAME, COMMENTS FROM USER_TAB_COMMENTS WHERE UPPER(COMMENTS) LIKE '%" + Util.escapeQuote(keyword) +"%' ORDER BY TABLE_NAME";
	lst = cn.queryMultiCol(qry, 2);

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
	qry = "SELECT TABLE_NAME, COLUMN_NAME, COMMENTS FROM USER_COL_COMMENTS WHERE UPPER(COMMENTS) LIKE '%" + Util.escapeHtml(keyword) +"%' ORDER BY TABLE_NAME";
	lst = cn.queryMultiCol(qry, 3);

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

