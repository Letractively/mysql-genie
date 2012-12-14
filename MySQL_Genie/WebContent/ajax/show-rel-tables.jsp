<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
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
	
	List<ForeignKey> fks = cn.getForeignKeys(table);
	List<String> refTabs = cn.getReferencedTables(owner, table);
	List<String> refViews = cn.getReferencedViews(table);
	
	List<String> list = new ArrayList<String>();
	
	for (int i=0; i<fks.size(); i++) {
		ForeignKey rec = fks.get(i);
		String rTable = rec.rTableName;
		list.add(rTable);
	}
	if (fks.size() > 0) list.add("");
		
	for (int i=0; i<refTabs.size(); i++) {
		list.add(refTabs.get(i));
	}
	if (refTabs.size() > 0) list.add("");

	for (int i=0; i<refViews.size(); i++) {
		list.add(refViews.get(i));
	}

%>
<select size=1 id="selectTable" name=""selectTable"" onChange="showTable(this.options[this.selectedIndex].value);"">
	<option></option>
<% for (int i=0; i<list.size();i++) { %>
	<option value="<%=list.get(i)%>"><%=list.get(i)%></option>
<% } %>
</select>

<input id="input-table" size=30 value="" onChange="showTable(this.value)"/>

