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

	String qry = "SELECT SYNONYM_NAME FROM USER_SYNONYMS ORDER BY 1"; 	
	List<String> list = cn.queryMulti(qry);

	if (filter !=null) filter = filter.toUpperCase();
	for (int i=0; i<list.size();i++) {
		if (filter != null && !list.get(i).contains(filter)) continue;
%>
	<li><a href="javascript:loadSynonym('<%=list.get(i)%>');"><%=list.get(i)%></a></li>
<% 
	} 
%>

