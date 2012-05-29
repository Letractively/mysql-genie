<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="java.sql.*" 
	import="genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	GenieManager gm = GenieManager.getInstance();
	ArrayList<Connect> ss = gm.getSessions();
%>

<html>
<head> 
	<title>Genie Sessions <%= ss.size() %></title>
    <script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
    <script src="script/data-methods.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>
    <script src="script/worksheet-methods.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>

    <link rel='stylesheet' type='text/css' href='css/style.css?<%= Util.getScriptionVersion() %>'>
	<link rel="icon" type="image/png" href="image/Genie-icon.png">

	<link rel="stylesheet" href="css/ui-lightness/jquery-ui-1.8.18.custom.css" type="text/css"/>
	<script src="script/jquery-ui-1.8.18.custom.min.js" type="text/javascript"></script>

    <meta http-equiv="refresh" content="30;">
</head> 

<body>

<b>Genie Sessions</b>
<br/><br/>

<table border=1>
<tr>
	<th>IP Address</th>
	<th>Email</th>
	<th>Database</th>
	<th>Count</th>
	<th>Queries</th>
</tr>
<% 
	for (Connect cn : ss) {
		HashMap<String,QueryLog> map = cn.getQueryHistory();
		
		String qry = "";
    	if (map != null) {
	    	Iterator iterator = map.values().iterator();
    		int idx = 0;
    		while  (iterator.hasNext()) {
    			idx ++;
    			QueryLog ql = (QueryLog) iterator.next();
    			qry += ql.getQueryString() + "<br/>";
    		}
    	}		
%>
<tr>
	<td><%= cn.getIPAddress() %></td>
	<td><%= cn.getEmail() %></td>
	<td><%= cn.getUrlString() %></td>
	<td><%= map.size() %></td>
	<td><%= qry %></td>
</tr>

<% 
	}
%>
</table>

</body>
</html>

