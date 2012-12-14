<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="chingoo.mysql.Connect" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	Connect cn = (Connect) session.getAttribute("CN");
	String filter = request.getParameter("filter");

	List<String> list = new ArrayList<String>();
	list.add("session");
	list.add("Sequence");
	list.add("DB link");
	list.add("User role priv");
%>
<% 
	if (filter !=null) filter = filter.toUpperCase();
	for (int i=0; i<list.size();i++) {
		if (filter != null && !list.get(i).toUpperCase().contains(filter)) continue;
%>
	<li><a href="javascript:loadDba('<%=list.get(i)%>');"><%=list.get(i)%></a></li>
<% 
	} 
%>

