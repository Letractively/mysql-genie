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
/*
	QueryCache.getInstance().clearAll();
	ListCache.getInstance().clearAll();
	ListCache2.getInstance().clearAll();
	StringCache.getInstance().clearAll();
	TableDetailCache.getInstance().clearAll();
*/
%>

<html>
<head> 
	<title>Genie - Cache</title>
    <script src="script/jquery.js" type="text/javascript"></script>
    <script src="script/data-link.js" type="text/javascript"></script>

    <script src="script/jquery.colorbox-min.js"></script>

    <link rel='stylesheet' type='text/css' href='css/style.css'>
    <link rel="stylesheet" href="css/colorbox.css" />
	<link rel="icon" type="image/png" href="image/Genie-icon.png">
</head>
<body>

Query Cache: <br/>
<%
	Enumeration<String> en1 = QueryCache.getInstance().getKeys();
	while (en1.hasMoreElements()) {
		String key = en1.nextElement();
%>
<%= key %><br/>
<%	} %>
<hr>

List Cache: <br/>
<%
	Enumeration<String> en2 = ListCache.getInstance().getKeys();
	while (en2.hasMoreElements()) {
		String key = en2.nextElement();
%>
<%= key %><br/>
<%	} %>
<hr>

List Cache2: <br/>
<%
	Enumeration<String> en3 = ListCache2.getInstance().getKeys();
	while (en3.hasMoreElements()) {
		String key = en3.nextElement();
%>
<%= key %><br/>
<%	} %>
<hr>

String Cache: <br/>
<%
	Enumeration<String> en4 = StringCache.getInstance().getKeys();
	while (en4.hasMoreElements()) {
		String key = en4.nextElement();
%>
<%= key %><br/>
<%	} %>
<hr>

Table Detail Cache: <br/>
<%
	Enumeration<String> en5 = TableDetailCache.getInstance().getKeys();
	while (en5.hasMoreElements()) {
		String key = en5.nextElement();
%>
<%= key %><br/>
<%	} %>
<hr>

</body>
</html>
