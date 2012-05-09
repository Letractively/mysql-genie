<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="genie.*" 
	pageEncoding="ISO-8859-1"
%>

<%
	String name = request.getParameter("name");
	Connect cn = (Connect) session.getAttribute("CN");

	if (cn==null) {
%>	
		Connection lost. Please log in again.
<%
		return;
	}
		
	Connection conn = cn.getConnection();

	String catalog = null;
	String tname = name;
	
	int idx = name.indexOf(".");
	if (idx>0) {
		catalog = name.substring(0, idx);
		tname = name.substring(idx+1);
	}
	if (catalog==null) catalog = cn.getSchemaName();
	
	String formName = "FORM_" + tname;
	String divName = "DIV_" + tname;
	if (name==null) { 
%>

Please select a Table to see the detail.

<%
		return;
	}

	String routineDef = "";
	String qry = "SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_SCHEMA='" + catalog+ "' AND " +
		" ROUTINE_TYPE='PROCEDURE' AND ROUTINE_NAME='" + tname + "'";
	
	try {
		Statement stmt = conn.createStatement();
		ResultSet rs = stmt.executeQuery(qry);
		
		if (rs.next()) {
			routineDef = rs.getString("ROUTINE_DEFINITION");
		}
	
		rs.close();
		stmt.close();
	} catch (SQLException e) {
        System.err.println (e.toString());
	}
	
%>


<html>
<head> 
	<title>Query result - Genie for MySQL</title>
    <link rel='stylesheet' type='text/css' href='css/style.css?<%= Util.getScriptionVersion() %>'> 
	<script src="http://code.jquery.com/jquery-1.5.2.min.js" type="text/javascript"></script>

	<style>
		tr.even {  background-color: #e0e0ff; }
		tr.odd {  background-color: #eeeeee;}	
	</style>
	
</head> 

<body>

<b>PROCEDURE <%= name %></b>
<br/>

<pre>
<%= routineDef %>
</pre>

<br/><br/><br/>
<a href="Javascript:window.close()">Close</href>

</body>
</html>