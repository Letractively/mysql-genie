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

	String qry = "SELECT ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES WHERE routine_schema	='"+cn.getSchemaName()+"' order by 1"; 	
	List<String> list = cn.queryMulti(qry);
	int totalCnt = list.size();
	int selectedCnt = 0;
	if (filter !=null) filter = filter.toUpperCase();
	for (int i=0; i<list.size();i++) {
		if (filter != null && !list.get(i).toUpperCase().contains(filter)) continue;
		selectedCnt ++;
	}

%>
Found <%= selectedCnt %> program(s).
<br/><br/>
<%	
	if (filter !=null) filter = filter.toUpperCase();
	for (int i=0; i<list.size();i++) {
		if (filter != null && !list.get(i).toUpperCase().contains(filter)) continue;
%>
	<li><a href="javascript:loadPackage('<%=list.get(i)%>');"><%=list.get(i)%></a></li>
<% 
	} 
%>
