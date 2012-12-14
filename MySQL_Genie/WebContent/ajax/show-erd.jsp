<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="chingoo.mysql.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%
	Connect cn = (Connect) session.getAttribute("CN");

	String table = request.getParameter("tname");
	String owner = request.getParameter("owner");
	
	// incase owner is null & table has owner info
	if (owner==null && table!=null && table.indexOf(".")>0) {
		int idx = table.indexOf(".");
		owner = table.substring(0, idx);
		table = table.substring(idx+1);
	}
	
	System.out.println("owner=" + owner);
	
//	String catalog = null;
	String tname = table;
	int idx = table.indexOf(".");
/* 	if (idx>0) {
		catalog = table.substring(0, idx);
		tname = table.substring(idx+1);
	}
	if (catalog==null) catalog = cn.getSchemaName();
 */
	if (owner==null) owner = cn.getSchemaName();

	String pkName = cn.getPrimaryKeyName(tname);
	ArrayList<String> pk = cn.getPrimaryKeys(owner, tname);
	if (pkName == null && owner != null) pkName = cn.getPrimaryKeyName(owner, tname);

	String pkCols = cn.getConstraintCols(owner, pkName);
	if (pkName != null && pkCols.equals(""))
		pkCols = cn.getConstraintCols(owner, pkName);

	List<ForeignKey> fks = cn.getForeignKeys(tname);
	if (owner != null) fks = cn.getForeignKeys(owner, tname);
	
	List<String> refTabs = cn.getReferencedTables(tname);
	
	List<TableCol> list = cn.getTableDetail(owner, tname);
System.out.println("refTabs.size()="+refTabs.size() +  " tname=" + tname);
%>

<div id="ERD">

<div id="parentDiv" style="background-color: #ffffcc; width:220px; height: 150px; overflow: auto; border: 1px solid #cccccc; float: left">
<div>
<% for (ForeignKey rec: fks) { %>

<a href="javascript:loadERD('<%= rec.rTableName %>')"><%= rec.rTableName %></a> <span class="rowcountstyle"><%= cn.getTableRowCount(rec.rTableName) %></span><br/>

<% } %>
</div>
</div>

<img style="float:left;" src="image/blue_arrow_left.png">

<div id="mainDiv" style="background-color: #ffffcc; width:220px; height: 150px; overflow: auto; border: 1px solid #cccccc; float: left">
<b><%= tname %></b> <span class="rowcountstyle"><%= cn.getTableRowCount(tname) %></span>
&nbsp;
<a href="Javascript:selectFromErd('<%=tname%>')">add<%--<img border=0 src="image/view.png" />--%></a>
<br/>
<hr>
<table>
<% for (TableCol t: list) {
	String colDisp = t.getName().toLowerCase();
	if (pk.contains(t.getName())) colDisp = "<b>" + colDisp + "</b>";
%>
<tr>
<td width="20">&nbsp;</td>
<td>
<%= colDisp %>
</td>
<td>
<%= t.getTypeName() %>
</td>
</tr>
<% } %>
</table>
</div>


<img style="float:left;" src="image/blue_arrow_left.png">

<div id="childDiv" style="background-color: #ffffcc; width:220px; height: 150px; overflow: auto; border: 1px solid #cccccc; float: left">
<div>
<% for (String t: refTabs) { %>
<a href="javascript:loadERD('<%= t %>')"><%= t %></a> <span class="rowcountstyle"><%= cn.getTableRowCount(t) %></span><br/>
<% } %>
</div>
</div>
<br clear="all"/>

</div>