<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="chingoo.mysql.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	Connect cn = (Connect) session.getAttribute("CN");

	String qry = "SELECT ID, UPDATED FROM CHINGOO_WORK_SHEET ORDER BY UPDATED DESC";
	List<String[]> list = cn.query(qry, false);
	
%>

<table border=0 width=100%>
<tr>
	<th><b>Work Sheet Name</b></th>
	<th><b>Last Updated</b></th>
	<th><b></b></th>
</tr>

<% 
	for (int i=0;i<list.size();i++) {
		String name = list.get(i)[1];
		String date = list.get(i)[2];
%>
<tr>
	<td nowrap><a href="Javascript:loadWS('<%= name.replaceAll("'","\\\\'") %>')"><%= name %></a></td>
	<td nowrap><%= date %></td>
	<td nowrap><a href="Javascript:deleteWS('<%= name.replaceAll("'","\\\\'") %>')">delete</a></td>
</tr>
<%
	}
%>
</table>
