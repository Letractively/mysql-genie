<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="java.sql.*" 
	import="genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	int counter = 0;
	Connect cn = (Connect) session.getAttribute("CN");

	String pageId = request.getParameter("page");

	String sql = "SELECT * FROM GENIE_PAGE WHERE PAGE_ID='" + pageId +"'";
	Query q = new Query(cn, sql);
	
	String pageTitle = q.getValue("title");
	String param1 = q.getValue("param1");
	String param2 = q.getValue("param2");
	String param3 = q.getValue("param3");
	
	if (param1==null) param1 ="";
	if (param2==null) param2 ="";
	if (param3==null) param3 ="";
	
	String value1 = request.getParameter(param1);
	String value2 = request.getParameter(param2);
	String value3 = request.getParameter(param3);
	
	if (value1==null) value1 ="";
	if (value2==null) value2 ="";
	if (value3==null) value3 ="";	
%>

<html>
<head> 
	<title>Genie - <%= pageTitle %></title>
    <script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
    <script src="script/data-methods.js?20120302" type="text/javascript"></script>

    <link rel='stylesheet' type='text/css' href='css/style.css'>
	<link rel="icon" type="image/png" href="image/Genie-icon.png">

	<link rel="stylesheet" href="css/ui-lightness/jquery-ui-1.8.18.custom.css" type="text/css"/>
	<script src="script/jquery-ui-1.8.18.custom.min.js" type="text/javascript"></script>
    
</head> 

<body>

<img src="image/data-link.png" align="middle"/>
<%= cn.getUrlString() %>

<br/>

<a href="Javascript:hideNullColumn()">Hide Null</a>
&nbsp;&nbsp;
<a href="Javascript:showAllColumn()">Show All</a>
&nbsp;&nbsp;
<br/><br/>

<h3><%=pageTitle %></h3>
<form method="get">
<input type="hidden" name="page" value="<%=pageId%>">
<% if (param1 != null && !param1.equals("")) { %>
	<%= param1 %> <input name="<%= param1 %>" value="<%=value1%>">
<% } %>
<% if (param2 != null && !param2.equals("")) { %>
	<%= param2 %> <input name="<%= param2 %>" value="<%=value2%>">
<% } %>
<% if (param3 != null && !param3.equals("")) { %>
	<%= param3 %> <input name="<%= param3 %>" value="<%=value3%>">
<% } %>
<input type="submit">
</form>

<%
	if (value1 == null || value1.equals("")) {
		return;
	}

	List<String> autoLoadChild = new ArrayList<String>();
	
	sql = "SELECT * FROM GENIE_PAGE_SQL WHERE PAGE_ID='" + pageId +"' ORDER BY SEQ";
	q = new Query(cn, sql);
	
	q.rewind(100, 1);
	
	while (q.next()) {
		String title = q.getValue("title");
		String indent = q.getValue("indent");
		String sqlStmt = q.getValue("sql_stmt");
		if (!value1.equals("")) {
			sqlStmt = sqlStmt.replace("[" + param1 + "]", value1);
		}
%>

<%
	String id = Util.getId();
	autoLoadChild.add(id);
	sql = sqlStmt; 
%>
<b style="margin-left:<%= indent%>px;">
<a href="Javascript:toggleDiv('img-<%= id %>','div-<%= id %>')"><%= title %>
<a href="Javascript:toggleDiv('img-<%= id %>','div-<%= id %>')"><img id="img-<%= id %>" border=0 src="image/plus.gif"></a></b>
&nbsp;&nbsp;<a href="javascript:openQuery('<%=id%>')"><img src="image/sql.png" border=0 title="<%=sql%>"/></a>
<div style="display: none;" id="sql-<%=id%>"><%= sql%></div>
<div style="display: none;" id="hide-<%=id%>"></div>
<div style="display: none;" id="sort-<%=id%>"></div>
<div style="display: none;" id="sortdir-<%=id%>">0</div>
<div style="display: none;" id="mode-<%=id%>">hide</div>

<div id="div-<%=id%>" style="margin-left: <%= indent%>px; display: none;"></div>
<br/>

<%
	}
%>

<div style="display: none;">
<form name="form0" id="form0" action="query.jsp">
<input id="sql" name="sql" type="hidden" value=""/>
<input id="dataLink" name="dataLink" type="hidden" value="1"/>
<input id="id" name="id" type="hidden" value=""/>
<input id="showFK" name="showFK" type="hidden" value="0"/>
<input type="hidden" id="sortColumn" name="sortColumn" value="">
<input type="hidden" id="sortDirection" name="sortDirection" value="0">
<input type="hidden" id="hideColumn" name="hideColumn" value="">
<input type="hidden" id="filterColumn" name="filterColumn" value="">
<input type="hidden" id="filterValue" name="filterValue" value="">
<input type="hidden" id="searchValue" name="searchValue" value="">
<input type="hidden" id="pageNo" name="pageNo" value="1">
<input type="hidden" id="rowsPerPage" name="rowsPerPage" value="20">
</form>
</div>

<script type="text/javascript">
$(document).ready(function() {
<%	
	for (String id1: autoLoadChild) {
%>
		loadData(<%=id1%>,0);
<%
	}
%>
});	
</script>

</body>
</html>

