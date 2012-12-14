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

<b><a href="Javascript:copyPaste('<%= table %>')"><%= table %></a></b>
<%= owner==null?cn.getComment(tname):cn.getSynTableComment(owner, tname) %><br/>

<table id="TABLE_<%=tname%>" width=360 border=0>
<tr>
	<th></th>
	<th bgcolor=#ccccff>Column Name</th>
	<th bgcolor=#ccccff>Type</th>
</tr>

<%	
	List<TableCol> list = cn.getTableDetail(owner, tname);
	for (int i=0;i<list.size();i++) {
		TableCol rec = list.get(i);
		
		// check if primary key
		String col_disp = rec.getName();
		if (rec.isPrimaryKey()) col_disp = "<span class='primary-key'>" + col_disp + "</span>";
%>
<tr>
	<td>&nbsp;</td>
	<td><a href="Javascript:copyPaste('<%= rec.getName().toLowerCase() %>')"><%= col_disp.toLowerCase() %></a></td>
	<td><%= rec.getTypeName() %></td>
</tr>

<%
	}
%>
</table>
</form>

