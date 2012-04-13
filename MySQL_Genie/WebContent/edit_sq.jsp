<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%
	Connect cn = (Connect) session.getAttribute("CN");

	String id = request.getParameter("id");
	
	String type = request.getParameter("type");
	if (type==null) type="";
	String actionType = request.getParameter("actionType");
	if (actionType==null) actionType="";
	
	String sqlStmt = request.getParameter("sql_stmt");

	String error = null;
	
//	System.out.println("actionType=" + actionType);
	
	if (actionType.equals("UPDATE")) {
		String sql = "UPDATE GENIE_SAVED_SQL SET sql_stmt='" + Util.escapeQuote(sqlStmt) + "', timestamp=sysdate() where id='" + Util.escapeQuote(id) + "'";
System.out.println(sql);
		try {
			cn.getConnection().setReadOnly(false);
			Statement stmt = cn.getConnection().createStatement();
			stmt.executeUpdate(sql);
			stmt.close();
		} catch (SQLException e) {
			error = e.getMessage();
		} finally {
			cn.getConnection().setReadOnly(true);
		}
	}
	
	if (actionType.equals("NEW")) {
		String sql = "INSERT INTO GENIE_SAVED_SQL (id, sql_stmt) VALUES ('" + Util.escapeQuote(id) + "', '" + Util.escapeQuote(sqlStmt) + "')";

		try {
			cn.getConnection().setReadOnly(false);
			Statement stmt = cn.getConnection().createStatement();
			stmt.executeUpdate(sql);
			stmt.close();
		} catch (SQLException e) {
			error = e.getMessage();
		} finally {
			cn.getConnection().setReadOnly(true);
		}
	}

	if (type.equals("delete")) {
		try {
			cn.getConnection().setReadOnly(false);
			String sql = "DELETE FROM GENIE_SAVED_SQL WHERE id='" + Util.escapeQuote(id) + "'";
			Statement stmt = cn.getConnection().createStatement();
			stmt.executeUpdate(sql);
			stmt.close();
		} catch (SQLException e) {
			error = e.getMessage();
		} finally {
			cn.getConnection().setReadOnly(true);
		}
	}

	String sql = "SELECT * FROM GENIE_SAVED_SQL";
	Query q = new Query(cn, sql);

	q.rewind(100, 1);
%>

<html>
<head> 
	<title>Genie - Edit Saved Query</title>
    <script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
    <script src="script/data-methods.js?20120302" type="text/javascript"></script>

    <link rel='stylesheet' type='text/css' href='css/style.css'>
	<link rel="icon" type="image/png" href="image/Genie-icon.png">
    
</head> 

<body>

<img src="image/data-link.png" align="middle"/>
<%= cn.getUrlString() %>

<% if (error != null) { %>

<h3 style="color: red;"><%= error %></h3>

<% } %>

<h3>Edit Saved Query</h3>

<a href="edit_sq.jsp?type=new">Add New Query</a>
<table border=1 class="gridBody">
<tr>
	<th class="headerRow">Action</th>
	<th class="headerRow">ID</th>
	<th class="headerRow">SQL Statement</th>
</tr>

<%
	while (q.next()) {
		String pId = q.getValue("id");
		String pSqlStmt = q.getValue("sql_stmt");
%>
<tr>
	<td><a href="edit_sq.jsp?id=<%= pId %>&type=edit">Edit</a>
	 &nbsp;&nbsp; 
		<a href="edit_sq.jsp?id=<%= pId %>&type=delete">Delete</a>
	</td>
	<td><%= pId %></td>
	<td><%= pSqlStmt %></td>
</tr>
<% 
	}
%>
</table>

<br/><br/>


<%
	if (type.equals("new") || type.equals("edit")) {
		
		if (id != null) {
			String s = "SELECT SQL_STMT FROM GENIE_SAVED_SQL WHERE ID='" + Util.escapeQuote(id) + "'";
			sqlStmt = cn.queryOne(s, false);
		} else {
			sqlStmt = "";
		}

%>
<div style="margin-left: 30px;">
	<form method="get">
		<% if (type.equals("new")) { %>
			<input type="hidden" name="actionType" value="NEW">
			Query Name <input name="id" value="" size="30">
			<br/>
		<% } else { %>
			<h3>Edit Query: "<%= id %>"</h3>
			<input type="hidden" name="actionType" value="UPDATE">
			<input type="hidden" name="id" value="<%=id%>">
		<% } %>
		SQL Stmt<br>
		<textarea name="sql_stmt" value="<%= sqlStmt %>" rows=5 cols=60><%= sqlStmt %></textarea>
		<br/>
		<input type="submit">
	</form>
</div>	
<%
	}
%>

</body>
</html>