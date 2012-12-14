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
	list.add("Search DB Content");
//	list.add("Search Program");
	list.add("Table Column");
	list.add("Schema Diff");
	list.add("");
	
	list.add("User Defined Page");
	list.add("");
	
	list.add("System View");

	list.add("");
	list.add("Saved Query");
//	list.add("Preferenceses");
	
	//	list.add("test");
/* 	list.add("Dictionary");
	list.add("Sequence");
	list.add("DB link");
	list.add("User role priv"); */
%>
<% 
	if (filter !=null) filter = filter.toUpperCase();
	for (int i=0; i<list.size();i++) {
		if (filter != null && !list.get(i).toUpperCase().contains(filter)) continue;

		if (list.get(i)==null || list.get(i).equals("")) {
%>
	<br/>
<%	} else { %>

	<li><a href="javascript:loadTool('<%=list.get(i)%>');"><%=list.get(i)%></a></li>
<% 
	} 
	}
%>

