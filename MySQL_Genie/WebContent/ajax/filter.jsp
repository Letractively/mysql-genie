<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="java.sql.*" 
	import="chingoo.mysql.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	int counter = 0;
	String filterColumn = request.getParameter("filterColumn");
	
	String sql = request.getParameter("sql");

	if (sql==null) sql = "SELECT * FROM TABLE";
	sql = sql.trim();
	if (sql.endsWith(";")) sql = sql.substring(0, sql.length()-1);
	sql = sql.replaceAll("&gt;",">").replace("&lt;","<");
	
	Connect cn = (Connect) session.getAttribute("CN");
	
//	Query q = (Query) session.getAttribute(sql);
	Query q = cn.queryCache.getQueryObject(sql);
	if (q==null) {
		q = new Query(cn, sql);
		cn.queryCache.addQuery(sql, q);
	} else {
//		System.out.println("*** REUSE Query");
	}

	if (filterColumn.equals("0")) {
		filterColumn = q.getColumnLabel(0);
	}

//	List<String> list = q.getFilterList(filterColumn);
	List<FilterRecord> list = q.getFilterListWithCount(filterColumn);
%>

Filter for <B><%= filterColumn %></B>
<select id="filterSelect" onchange="applyFilter(this.options[this.selectedIndex].value);">
<option value="">All</option>
<% for (int i=0; i<list.size(); i++) { 
		FilterRecord rec = list.get(i);
		String value = rec.getValue();
		String dispValue = value;
		if (rec.getCount() > 1) dispValue += "\t[" + rec.getCount() + "]";
%>
	<option value="<%= value %>"><%= dispValue %></option>
<% } %>
</select>

<a href="Javascript:removeFilter()">Remove Filter</a>