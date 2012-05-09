<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	Connect cn = (Connect) session.getAttribute("CN");
	HashMap<String, QueryLog> map = cn.getQueryHistory();
	
%>

<html>
<head> 
	<title>Genie</title>
    <link rel='stylesheet' type='text/css' href='css/style.css?<%= Util.getScriptionVersion() %>'> 
    <script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
	<script src="script/main.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>
	<style>
		tr.even {  background-color: #e0e0ff; }
		tr.odd {  background-color: #eeeeee;}	
	</style>

<script language="Javascript">
	
	function run(divName) {
		var qry = $("#" + divName).html();
		$("#sql").val(qry);
		//alert(qry);
		$("#form1").submit();
		//document.forms["form1"].submit();
		
		
	}	
</script>
	
</head>
<body>

<table>
<td><br><img src="image/small-genie.gif"/></td>
<td><%= cn.getUrlString() %> Database: <%= cn.getSchemaName() %></td>
</table>

<table id="dataTable" class="gridBody" border=1 width=800>
<tr class="rowHeader">
<th>Run</th>
<th>Query</th>
<th>Time</th>
</tr>

<%
	Iterator iterator = map.values().iterator();
	int idx = 0;
	while  (iterator.hasNext()) {
		idx ++;
		QueryLog ql = (QueryLog) iterator.next();
		String divName ="QRY-" + idx;

		String rowClass = "odd";
		if (idx%2 == 0) rowClass = "even";
%>
	<tr class="<%=rowClass%>">
		<td><a href="Javascript:run('<%= divName %>')">run</a></td>
		<td><div id="<%= divName %>"><%= ql.getQueryString() %></div></td>
		<td><%= ql.getTime() %></td>
	</tr>
<%
	}
 %>

</table>

<form id="form1" name="form1" target=_blank action="query.jsp" method="post">
<input id="sql" name="sql" type="hidden" value="select * from tab"/>
</form>

<br/><br/>
<a href="Javascript:window.close()">Close</a>
<br/><br/>

</body>
</html>