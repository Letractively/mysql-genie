<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="chingoo.mysql.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	String view = request.getParameter("view");
	String owner = request.getParameter("owner");
	
	Connect cn = (Connect) session.getAttribute("CN");

	// incase owner is null & table has owner info
	if (owner==null && view!=null && view.indexOf(".")>0) {
		int idx = view.indexOf(".");
		owner = view.substring(0, idx);
		view = view.substring(idx+1);
	}
	
	String catalog = cn.getSchemaName();

	String qry = "SELECT VIEW_DEFINITION FROM information_schema.views WHERE TABLE_NAME='" + view +"' AND TABLE_SCHEMA='" + catalog + "'";
	String text = cn.queryOne(qry);
%>
<h2>VIEW: <%= view %> &nbsp;&nbsp;<a href="Javascript:runQuery('<%=catalog%>','<%=view%>')"><img border=0 src="image/icon_query.png" title="query"></a></h2>

<table id="TABLE_<%=view%>" width=640 border=0>
<tr>
	<th></th>
	<th bgcolor=#ccccff>Column Name</th>
	<th bgcolor=#ccccff>Type</th>
	<th bgcolor=#ccccff>Null</th>
	<th bgcolor=#ccccff>Default</th>
	<th bgcolor=#ccccff>Remarks</th>
</tr>

<%	
	List<TableCol> list = cn.getTableDetail(owner, view);
	for (int i=0;i<list.size();i++) {
		TableCol rec = list.get(i);
		
		// check if primary key
		String col_disp = rec.getName();
		if (rec.isPrimaryKey()) col_disp = "<span class='primary-key'>" + col_disp + "</span>";
%>
<tr>
	<td>&nbsp;</td>
	<td><%= col_disp %></td>
	<td><%= rec.getTypeName() %></td>
	<td><%= rec.getNullable()==0?"N":"" %></td>
	<td><%= rec.getDefaults() %></td>
	<td><%= rec.getRemarks() %></td>
</tr>

<%
	}
%>
</table>

<hr>

<b>Definition</b> 
<a href="Javascript:toggleDiv('imgDef','divDef')"><img id="imgDef" src="image/minus.gif"></a>
<div id="divDef" style="margin-left: 20px;">
<pre>
<%= text %>
</pre>
</div>


