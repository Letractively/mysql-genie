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
	
	String pkName = cn.getPrimaryKeyName(table);
	String conCols = cn.getConstraintCols(table, pkName);
//	if (conCols.length() > 2) conCols = conCols.substring(1, conCols.length()-1);
	
	String condition = Util.buildCondition(conCols, key);

	String sql = "SELECT * FROM " + table + " WHERE " + condition;
	if (sql.endsWith(";")) sql = sql.substring(0, sql.length()-1);
	sql = sql.replaceAll("&gt;",">").replace("&lt;","<");
	
	OldQuery q = new OldQuery(cn, sql, request);
	ResultSet rs = q.getResultSet();
	
	// get table name
	String tbl = null;
	//String temp = sql.replaceAll("\n", " ").trim();
	String temp=sql.replaceAll("[\n\r\t]", " ");
	
	int idx = temp.toUpperCase().indexOf(" FROM ");
	if (idx >0) {
		temp = temp.substring(idx + 6);
		idx = temp.indexOf(" ");
		if (idx > 0) temp = temp.substring(0, idx).trim();
		
		tbl = temp.trim();
		
		
		idx = tbl.indexOf(" ");
		if (idx > 0) tbl = tbl.substring(0, idx);
		
	}
//	System.out.println("XXX TBL=" + tbl);
%>
<script language="Javascript">

function selectOption(select_id, option_val) {
    $('#'+select_id+' option:selected').removeAttr('selected');
    $('#'+select_id+' option[value='+option_val+']').attr('selected','selected');       
}

</script>

<form name="formQry" method="post" action="query.jsp">
<input name="sql" type="hidden" value="<%= sql %>">
</form>

SQL = <%= sql %> <a href="javascript:doQuery()"><img border=0 src="image/icon_query.png" title="Open Query"></a>
<a href="javascript:doQueryNew()"><img border=0 src="image/icon_query_new.png" title="Open Query on New page"></a>

<table id="inspectTable" class="gridBody" border=1 width=600>
<tr>
	<th class="headerRow"><b>Column Name</b></th>
	<th class="headerRow"><b>Value</b></th>
	<th class="headerRow"><b>Comment</b> <a href="Javascript:hideInspectComment()">x</a></th> 
</tr>

<%
	boolean numberCol[] = new boolean[500];

	boolean hasData = false;
	if (rs != null) hasData = rs.next();
	int colIdx = 0;
	for  (int i = 1; rs != null && i<= rs.getMetaData().getColumnCount(); i++){
	
		String colName = q.getColumnLabel(i);

			colIdx++;
			int colType = q.getColumnType(i);
			numberCol[colIdx] = Util.isNumberType(colType);
			
			String val = q.getValue(i);
			String valDisp = Util.escapeHtml(val);
			if (val != null && val.endsWith(" 00:00:00")) valDisp = val.substring(0, val.length()-9);
			if (val==null) valDisp = "<span class='nullstyle'>null</span>";
			
			if (val!=null && val.equals("Exhausted Resultset")) valDisp = "<span class='nullstyle'>null</span>";

			String rowClass = "oddRow";
			if (i%2 == 0) rowClass = "evenRow";
%>
	<tr>
		<td class="<%=rowClass%>"><b><%=colName%></b></td>
		<td class="<%=rowClass%>"<%= (numberCol[colIdx])?"align=right":""%>><%= valDisp %></td>
		<td class="<%=rowClass%>"><%= cn.getComment(table, colName) %></td>
	</tr>
<%
	}	
%>
</tr>
</table>
