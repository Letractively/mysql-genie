<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="chingoo.mysql.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	Connect cn = (Connect) session.getAttribute("CN");

	String owner = request.getParameter("owner");
	String name = request.getParameter("name");

	// incase owner is null & table has owner info
	if (owner==null && name!=null && name.indexOf(".")>0) {
		int idx = name.indexOf(".");
		owner = name.substring(0, idx);
		name = name.substring(idx+1);
	}
	
	if (owner==null) owner = cn.getSchemaName().toUpperCase();
	
	String catalog = cn.getSchemaName();

	String sourceUrl = "source.jsp?name=" + name;
	if (owner != null) sourceUrl += "&owner=" + owner;
	
	String qry = "SELECT routine_type, data_type, routine_definition, routine_comment FROM information_schema.routines WHERE ROUTINE_NAME='" + name +"' AND ROUTINE_SCHEMA='" + catalog + "'";
	List<String[]> list  = cn.query(qry);
	
	String typeName = list.get(0)[1];
	String dataType = list.get(0)[2];
	String def = list.get(0)[3];
	String comment = list.get(0)[4];

	qry = "SELECT parameter_name, parameter_mode, data_type FROM information_schema.parameters WHERE SPECIFIC_NAME='" + name +"' AND SPECIFIC_SCHEMA='" + catalog + "' AND ordinal_position > 0 ORDER BY ordinal_position";
	List<String[]> list2  = cn.query(qry);

%>

<h2><%= typeName %> <%= name %> <%= dataType.equals("")?"":"RETURN " + dataType %></h2>

Parameters
<table>
<% 
	for (int i=0;i<list2.size();i++) {
		String pname = list2.get(i)[1];
		String pmode = list2.get(i)[2];
		String ptype = list2.get(i)[3];
%>
<tr>
	<td width=20>&nbsp;</td>
	<td><%= pname %></td>
	<td><%= pmode %></td>
	<td><%= ptype %></td>
</tr>
<%
	}
%>

</table>


<pre>
<%= def %>
</pre>


