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
	Connect cn = (Connect) session.getAttribute("CN");
	
	String table = request.getParameter("table");
	String key = request.getParameter("key");
	
	List<String> refTabs = cn.getReferencedTables(table);
%>

<div id="pkLink">

<% if (refTabs.size() > 0) { %>
Linked Tables: (<%= refTabs.size() %>)<br/>

<table class="gridBody" border=1>
<tr>
	<th class="headerRow"><b>Table Name</b></th>
	<th class="headerRow"><b>Records</b></th>
	<th class="headerRow"><b>Comment</b></th>
</tr>
<%
	// Primary Key for PK Link
	String pkName = cn.getPrimaryKeyName(table);
	String pkCols = null;
	String pkColName = null;
	int pkColIndex = -1;
	if (pkName != null) {
		pkCols = cn.getConstraintCols(table, pkName);
		int colCount = Util.countMatches(pkCols, ",") + 1;
		System.out.println("pkCols=" + pkCols + ", colCount=" + colCount);
	
		pkColName = pkCols;
	}


	for (int i=0; i<refTabs.size(); i++) {
		String refTab = refTabs.get(i);
		int recCount = cn.getPKLinkCount(refTab, pkColName, key);
		String rowClass = "oddRow";
		if ((i+1)%2 == 0) rowClass = "evenRow";
%>
	<tr>
		<td class="<%= rowClass%>"><%=(recCount>0?"<b>":"")%>
			<a href="javascript:linkPk('<%= refTab %>','<%= pkColName %>','<%= Util.encodeUrl(key) %>','<%= table %>')"><%= refTab %></a>
			<%=(recCount>0?"</b>":"")%>
		</td>
		<td class="<%= rowClass%>" align=center><%=(recCount>0?"<b>":"")%><%= recCount %><%=(recCount>0?"</b>":"")%></td>
		<td class="<%= rowClass%>"><%= cn.getComment(refTab) %></td>
	</tr>
<% }
}
%>
</table>

</div>