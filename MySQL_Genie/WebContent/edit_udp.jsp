<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%
	Connect cn = (Connect) session.getAttribute("CN");

	String pageId = request.getParameter("page");
	
	String type = request.getParameter("type");
	if (type==null) type="";
	String actionType = request.getParameter("actionType");
	if (actionType==null) actionType="";
	
	String title = request.getParameter("title");
	String param1 = request.getParameter("param1");
	String param2 = request.getParameter("param2");
	String param3 = request.getParameter("param3");

	String seq = request.getParameter("seq");
	String newseq = request.getParameter("newseq");
	String indent = request.getParameter("indent");
	String sqlStmt = request.getParameter("sqlStmt");
	
//	System.out.println("actionType=" + actionType);
	
	if (actionType.equals("GENIE_PAGE UPDATE")) {
		String sql = "UPDATE GENIE_PAGE SET title='" + title + "', param1='" + param1 +
				"', param2='" + param2 + "', param3='" + param3 + "' where page_id='" + pageId + "'";
		
		Statement stmt = cn.getConnection().createStatement();
		stmt.executeUpdate(sql);
		stmt.close();
	}
	
	if (actionType.equals("GENIE_PAGE NEW")) {
		String sql = "INSERT INTO GENIE_PAGE (page_id, title, param1, param2, param3) VALUES ('" + pageId + "', '" + title + "', '" + param1 +
			"', '" + param2 + "', '" + param3 + "')";
		Statement stmt = cn.getConnection().createStatement();
		stmt.executeUpdate(sql);
		stmt.close();
	}

	if (type.equals("delete")) {
		String sql = "DELETE FROM GENIE_PAGE WHERE page_id='" + pageId + "'";
		Statement stmt = cn.getConnection().createStatement();
		stmt.executeUpdate(sql);
		stmt.close();
	}

	if (actionType.equals("GENIE_PAGE_SQL NEW")) {
		String sql = "INSERT INTO GENIE_PAGE_SQL (page_id, seq, title, indent, sql_stmt) VALUES ('" + pageId + "', " + newseq + ", '" + title +
			"', " + indent + ", '" + Util.escapeQuote(sqlStmt) + "')";
		System.out.println(sql);
		
		Statement stmt = cn.getConnection().createStatement();
		stmt.executeUpdate(sql);
		stmt.close();
	}

	if (actionType.equals("GENIE_PAGE_SQL UPDATE")) {
		String sql = "UPDATE GENIE_PAGE_SQL SET seq=" + newseq + ", title='" + title + "', indent=" + indent +
				", sql_stmt='" + Util.escapeQuote(sqlStmt) + "' where page_id='" + pageId + "' AND seq = " + seq;
		System.out.println(sql);

		Statement stmt = cn.getConnection().createStatement();
		stmt.executeUpdate(sql);
		stmt.close();
	}
	
	String sql = "SELECT * FROM GENIE_PAGE";
	Query q = new Query(cn, sql);

	q.rewind(100, 1);
%>

<html>
<head> 
	<title>Genie - Edit User Defined Page</title>
    <script src="script/jquery.js" type="text/javascript"></script>
    <script src="script/data-link.js" type="text/javascript"></script>

    <script src="script/jquery.colorbox-min.js"></script>

    <link rel='stylesheet' type='text/css' href='css/style.css'>
    <link rel="stylesheet" href="css/colorbox.css" />
	<link rel="icon" type="image/png" href="image/Genie-icon.png">
    
</head> 

<body>

<img src="image/data-link.png" align="middle"/>
<%= cn.getUrlString() %>

<br/>

<h3>Edit User Defined Page</h3>

<p>
User can define pages by combining multiple queries.
<li>A page can have up to 3 parameters</li>
<li>A query can be any SQL query statement</li>
<li>A page can have unlimited queries</li>
<br/>

Ex: param1=name, param2=city<br>
SQL: SELECT * FROM EMPLOYEE WHERE FULLNAME LIKE '%[name]%' AND CITY ='[city]';

</p>

<%
	if (pageId != null || type.equals("new") ) {
		sql = "SELECT * FROM GENIE_PAGE_SQL WHERE PAGE_ID='" + pageId + "' ORDER BY SEQ";
		Query q2 = new Query(cn, sql);

		sql = "SELECT * FROM GENIE_PAGE WHERE PAGE_ID='" + pageId + "'";
		Query q3 = new Query(cn, sql);
		q3.rewind(100,1);
		q3.next();
		
		String tt = q3.getValue("title");
		String p1 = q3.getValue("param1");
		String p2 = q3.getValue("param2");
		String p3 = q3.getValue("param3");
		
		if (p1==null) p1 = "";
		if (p2==null) p2 = "";
		if (p3==null) p3 = "";
		
		if (tt==null) tt = "";
%>

<%
	if (type.equals("new") || type.equals("edit")) {
%>
	<form method="post">
		<% if (type.equals("new")) { %>
			<input type="hidden" name="actionType" value="GENIE_PAGE NEW">
			ID <input name="page" value="<%=pageId%>">
		<% } else { %>
			<input type="hidden" name="actionType" value="GENIE_PAGE UPDATE">
			<input type="hidden" name="page" value="<%=pageId%>">
		<% } %>
		Title <input name="title" value="<%= tt %>">
		Param 1 <input name="param1" value="<%= p1 %>">
		Param 2 <input name="param2" value="<%= p2 %>">
		Param 3 <input name="param3" value="<%= p3 %>">
		<input type="submit">
	</form>
<%
	}
%>


<%
	if (type.equals("newSql") || type.equals("editSql")) {
		
		sql = "SELECT * FROM GENIE_PAGE_SQL WHERE PAGE_ID='" + pageId + "' AND SEQ=" + seq;
		System.out.println(sql);
		Query q4 = new Query(cn, sql);
		
		q4.rewind(100,1);
		q4.next();
		tt = q4.getValue("title");
		sqlStmt = q4.getValue("sql_stmt");
		indent = q4.getValue("indent");
		
		if (type.equals("newSql")) {
			tt = "";
			seq = "";
			indent = "0";
			sqlStmt = "";
		}

%>
	<form method="post">
		<% if (type.equals("newSql")) { %>
			<input type="hidden" name="actionType" value="GENIE_PAGE_SQL NEW">
			<input type="hidden" name="page" value="<%=pageId%>">
		<% } else { %>
			<input type="hidden" name="actionType" value="GENIE_PAGE_SQL UPDATE">
			<input type="hidden" name="page" value="<%=pageId%>">
		<% } %>
		SEQ <input name="newseq" value="<%= seq %>">
		Title <input name="title" value="<%= tt %>">
		Indent <input name="indent" value="<%= indent %>">
		<br/>
		SQL Stmt<br/>
		<textarea name="sqlStmt" cols=80 rows=3><%=sqlStmt%></textarea>
		<br/>
		<input type="submit">
	</form>
<%
	}

%>

	<a href="edit_udp.jsp?page=<%=pageId%>&type=newSql">Add New SQL</a>
	<table border=1>
	<tr>
		<th>Action</th>
		<th>SEQ</th>
		<th>Title</th>
		<th>Indent</th>
		<th>SQL Stmt</th>
	</tr>
<%
		q2.rewind(100, 1);
		while (q2.next()) {
			String sq=q2.getValue("seq");
%>
	<tr>
		<td><a href="edit_udp.jsp?type=editSql&page=<%=pageId%>&seq=<%=sq%>">Edit</a> 
			&nbsp;&nbsp; 
			<a href="">Delete</a>
		</td>
		<td><%= sq %></td>
		<td><%= q2.getValue("title") %></td>
		<td><%= q2.getValue("indent") %></td>
		<td><%= q2.getValue("sql_stmt") %></td>
	</tr>
<%
		}
%>
	</table>
	<br/><br/>
<%
	}
%>
<a href="edit_udp.jsp?type=new">Add New Page</a>
<table border=1>
<tr>
	<th>Action</th>
	<th>ID</th>
	<th>Title</th>
	<th>Param 1</th>
	<th>Param 2</th>
	<th>Param 3</th>
</tr>

<%
	while (q.next()) {
		String pId = q.getValue("page_id");
		String tt = q.getValue("title");
		String p1 = q.getValue("param1");
		String p2 = q.getValue("param2");
		String p3 = q.getValue("param3");
		
		if (p1==null) p1 = "";
		if (p2==null) p2 = "";
		if (p3==null) p3 = "";
%>
<tr>
	<td><a href="edit_udp.jsp?page=<%= pId %>&type=edit">Edit</a>
	 &nbsp;&nbsp; 
		<a href="edit_udp.jsp?page=<%= pId %>&type=delete">Delete</a>
	</td>
	<td><%= pId %></td>
	<td><%= tt %></td>
	<td><%= p1 %></td>
	<td><%= p2 %></td>
	<td><%= p3 %></td>
</tr>
<% 
	}
%>
</table>


</body>
</html>