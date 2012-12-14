<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="chingoo.mysql.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	Connect cn = (Connect) session.getAttribute("CN");

	String table = request.getParameter("table");
	String owner = request.getParameter("owner");
	
	// incase owner is null & table has owner info
	if (owner==null && table!=null && table.indexOf(".")>0) {
		int idx = table.indexOf(".");
		owner = table.substring(0, idx);
		table = table.substring(idx+1);
	}
	
	System.out.println("owner=" + owner);
	
	String catalog = null;
	String tname = table;
	int idx = table.indexOf(".");
	if (idx>0) {
		catalog = table.substring(0, idx);
		tname = table.substring(idx+1);
	}
	if (catalog==null) catalog = cn.getSchemaName();
	
	String formName = "FORM_" + tname;
	String divName = "DIV_" + tname;
	if (table==null) { 
%>

Please select a Table to see the detail.

<%
		return;
	}
	
%>

<h2>TABLE: <%= table %> &nbsp;&nbsp;<span class="rowcountstyle"><%= cn.getTableRowCount(table) %></span>
<a href="Javascript:runQuery('','<%=tname%>')"><img border=0 src="image/icon_query.png" title="query"></a>
<a href="erd.jsp?tname=<%=tname%>" target="_blank"><img title="ERD" border=0 src="image/erd.gif"></a>
<a href="erd_svg.jsp?tname=<%=tname%>" target="_blank"><img title="Simple ERD" border=0 src="image/simple-erd.png"></a>
</h2>

<%= owner==null?cn.getComment(tname):cn.getSynTableComment(owner, tname) %><br/>

<div id="<%= divName %>">
<form id="<%= formName %>">
<input name="table" type="hidden" value="<%= table %>"/>
<input name="query" type="hidden" value=""/>

<table id="dataTable" border=1 class="gridBody" style="margin-left: 10px;">
<tr>
	<th class="headerRow">Column Name</th>
	<th class="headerRow">Type</th>
	<th class="headerRow">Null</th>
	<th class="headerRow">Default</th>
	<th class="headerRow">Remarks</th>
</tr>

<%	
	List<TableCol> list = cn.getTableDetail(owner, tname);
	int rowCnt = 0;
	for (int i=0;i<list.size();i++) {
		TableCol rec = list.get(i);
		
		// check if primary key
		String col_disp = rec.getName();
		if (rec.isPrimaryKey()) col_disp = "<span class='primary-key'>" + col_disp + "</span>";
		
		rowCnt++;
		String rowClass = "oddRow";
		if (rowCnt%2 == 0) rowClass = "evenRow";	
%>
<tr class="simplehighlight">
	<td class="<%= rowClass%>"><%= col_disp %></td>
	<td class="<%= rowClass%>"><%= rec.getTypeName() %></td>
	<td class="<%= rowClass%>"><%= rec.getNullable()==0?"N":"" %></td>
	<td class="<%= rowClass%>"><%= rec.getDefaults() %></td>
	<td class="<%= rowClass%>"><%= rec.getRemarks() %></td>
</tr>

<%
	}
%>
</table>
</form>


<%
	String pkName = cn.getPrimaryKeyName(tname);
	if (pkName == null && owner != null) pkName = cn.getPrimaryKeyName(owner, tname);

	String pkCols = cn.getConstraintCols(tname, pkName);
	if (pkName != null && pkCols.equals(""))
		pkCols = cn.getConstraintCols(owner, tname, pkName);

	List<ForeignKey> fks = cn.getForeignKeys(tname);
	if (owner != null) fks = cn.getForeignKeys(owner, tname);
	
	List<String> refTabs = cn.getReferencedTables(owner, tname);
	List<String> refPkgs = cn.getReferencedPackages(tname);
	List<String> refViews = cn.getReferencedViews(tname);
	List<String> refTrgs = cn.getReferencedTriggers(tname);
	List<String> refIdx = cn.getIndexes(owner, tname);
%>

<hr>


<% if (pkName != null)  {%>
<b>Primary Key</b><br/>
&nbsp;&nbsp;&nbsp;&nbsp;<%= pkName %> (<%= pkCols.toLowerCase() %>) 

<br/><br/>
<% } %>


<% 
	if (fks.size()>0) { 
%>
<b>Foreign Key</b><br/>
<%

	for (int i=0; i<fks.size(); i++) {
		ForeignKey rec = fks.get(i);
		String rTable = rec.rTableName;
		boolean tabLink = true;
		if (rTable == null) {
			rTable = rec.rTableName;
			tabLink = false;
			tabLink = true;
		}
%>
&nbsp;&nbsp;&nbsp;&nbsp;<%= rec.constraintName %>
	(<%= cn.getConstraintCols(rec.owner, rec.tableName, rec.constraintName) %>)
	->
<%
	if (tabLink) {
%>
	<a href="Javascript:loadTable('<%= rTable %>')"><%= rTable %></a> <span class="rowcountstyle"><%= cn.getTableRowCount(rTable) %></span>
<%
	} else {
%>	
	<%= rTable %>
<%
	}
%>
	(<%= cn.getConstraintCols(rec.rOwner, rec.rTableName, rec.rConstraintName) %>)
	<br/>
<%
 }
%>
	<br/>
<%
} 
%>



<% 
	if (refIdx.size()>0) { 
%>
<b>Index</b><br/>
<%

	for (int i=0; i<refIdx.size(); i++) {
		String indexName = refIdx.get(i);
%>
	&nbsp;&nbsp;&nbsp;&nbsp;<%= indexName %> 
	<%= cn.getIndexColumns(owner, tname, indexName).toLowerCase() %>
	<br/>
<%
	}
%>
<br/>
<%
}
%>


<% 
	if (refTabs.size()>0) { 
%>
<b>Related Table</b>
<a href="Javascript:toggleDiv('imgTable','divTable')"><img id="imgTable" border=0 src="image/minus.gif"></a>
<div id="divTable">
<table border=0>
<td width=10>&nbsp;</td>
<td valign=top>
<%
	int listSize = (refTabs.size() / 3) + 1;
	int cnt = 0;
	for (int i=0; i<refTabs.size(); i++) {
		String refTab = refTabs.get(i);
		cnt++;
%>

<% if ((cnt-1)>=listSize) { %>
		</td><td valign=top>
<%
		cnt = 1;
	} 
%>

		<a href="Javascript:loadTable('<%= refTab %>')"><%= refTab %></a> <span class="rowcountstyle"><%= cn.getTableRowCount(refTab) %></span>&nbsp;&nbsp;<br/>	
<% }
%>
</td>
</table>
</div>
<% }
%>

<br/>
<% 
	if (refViews.size()>0) { 
%>
<b>Related View</b>
<a href="Javascript:toggleDiv('imgView','divView')"><img id="imgView" border=0 src="image/minus.gif"></a>
<div id="divView">
<table border=0>
<td width=10>&nbsp;</td>
<td valign=top>
<%
	int listSize = (refViews.size() / 3) + 1;
	int cnt = 0;
	for (int i=0; i<refViews.size(); i++) {
		String refView = refViews.get(i);
		cnt++;
%>

<% if ((cnt-1)>=listSize) { %>
		</td><td valign=top>
<%
		cnt = 1;
	} 
%>

		<a href="Javascript:loadView('<%= refView %>')"><%= refView %></a>&nbsp;&nbsp;<br/>		
<% }
%>
</td>
</table>
</div>
<%
	}
%>

<br/>
<% 
	if (refTrgs.size()>0) { 
%>
<b>Related Trigger</b>
<a href="Javascript:toggleDiv('imgTrg','divTrg')"><img id="imgTrg" border=0 src="image/minus.gif"></a>
<div id="divTrg">
<table border=0>
<td width=10>&nbsp;</td>
<td valign=top>
<%
	int listSize = (refTrgs.size() / 3) + 1;
	int cnt = 0;
	for (int i=0; i<refTrgs.size(); i++) {
		String refTrg = refTrgs.get(i);
		cnt++;
%>

<% if ((cnt-1)>=listSize) { %>
		</td><td valign=top>
<%
		cnt = 1;
	} 
%>

		<a href="Javascript:loadPackage('<%= refTrg %>')"><%= refTrg %></a>&nbsp;&nbsp;<br/>		
<% }
%>
</td>
</table>
</div>

<%
	}
%>

<br/>
<% 
	if (refPkgs.size()>0) { 
%>
<b>Related Program</b>
<a href="Javascript:toggleDiv('imgPgm','divPgm')"><img id="imgPgm" border=0 src="image/minus.gif"></a>
<div id="divPgm">
<table border=0>
<td width=10>&nbsp;</td>
<td valign=top>
<%
	int listSize = (refPkgs.size() / 3) + 1;
	int cnt = 0;
	for (int i=0; i<refPkgs.size(); i++) {
		String refPkg = refPkgs.get(i);
		cnt++;
%>

<% if ((cnt-1)>=listSize) { %>
		</td><td valign=top>
<%
		cnt = 1;
	} 
%>

		<a href="Javascript:loadPackage('<%= refPkg %>')"><%= refPkg %></a>&nbsp;&nbsp;<br/>		
<% }
%>
</td>
</table>
</div>
<%
}
%>


</div>