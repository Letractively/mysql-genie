<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="genie.*" 
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
	
	String typeName = cn.getObjectType(owner, name);
%>

<h2><%= typeName %>: <%= name %> &nbsp;&nbsp;<a href="<%=sourceUrl%>" target="_blank"><img border=0 src="image/icon_query.png" title="Source code"></a></h2>


<%

	String qry = "SELECT distinct PROCEDURE_NAME FROM all_procedures where owner='" + owner + "' and object_name='" + name + "' and PROCEDURE_NAME is not null order by 1";
	List<String> list = cn.queryMulti(qry);

%>


<% 
	if (list.size()>0) { 
%>
<b>Procedures</b>
<table border=0 width=100%>
<td width=10>&nbsp;</td>
<td valign=top>
<%
	int listSize = (list.size() / 3) + 1;
	int cnt = 0;
	for (int i=0; i<list.size(); i++) {
		cnt++;
%>

<% if ((cnt-1)>=listSize) { %>
		</td><td valign=top>
<%
		cnt = 1;
	} 
%>
	<%= list.get(i).toLowerCase() %><br/>		
<% }
}
%>
</td>
</table>


<br/>

<b>Dependencies</b>

<table>
<tr>
	<td>&nbsp;</td>
	<td bgcolor=#ccccff>Program</td>
	<td bgcolor=#ccccff>Table</td>
	<td bgcolor=#ccccff>View</td>
	<td bgcolor=#ccccff>Synonym</td>
</tr>
<tr>
	<td>&nbsp;</td>
	<td valign=top><%= cn.getDependencyPackage(owner, name) %></td>
	<td valign=top><%= cn.getDependencyTable(owner, name) %></td>
	<td valign=top><%= cn.getDependencyView(owner, name) %></td>
	<td valign=top><%= cn.getDependencySynonym(owner, name) %></td>
</tr>
</table>
<br/>

