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
%>

<html>
<head> 
	<title>Genie - Cache</title>
    <script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
    <script src="script/data-methods.js?20120302" type="text/javascript"></script>

    <link rel='stylesheet' type='text/css' href='css/style.css'>
	<link rel="icon" type="image/png" href="image/Genie-icon.png">
</head>
<body>

Query Cache: <br/>
<%
	Enumeration<String> en1 = cn.queryCache.getKeys();
	while (en1.hasMoreElements()) {
		String key = en1.nextElement();
%>
<%= key %><br/>
<%	} %>
<hr>

List Cache: <br/>
<%
	Enumeration<String> en2 = cn.listCache.getKeys();
	while (en2.hasMoreElements()) {
		String key = en2.nextElement();
%>
<%= key %><br/>
<%	} %>
<hr>

List Cache2: <br/>
<%
	Enumeration<String> en3 = cn.listCache2.getKeys();
	while (en3.hasMoreElements()) {
		String key = en3.nextElement();
%>
<%= key %><br/>
<%	} %>
<hr>

String Cache: <br/>
<%
	Enumeration<String> en4 = cn.stringCache.getKeys();
	while (en4.hasMoreElements()) {
		String key = en4.nextElement();
%>
<%= key %><br/>
<%	} %>
<hr>

Table Detail Cache: <br/>
<%
	Enumeration<String> en5 = cn.tableDetailCache.getKeys();
	while (en5.hasMoreElements()) {
		String key = en5.nextElement();
%>
<%= key %><br/>
<%	} %>
<hr>

</body>
</html>
