<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="java.sql.*" 
	import="chingoo.mysql.*" 
	import="org.apache.commons.lang3.StringEscapeUtils" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	int counter = 0;
	Connect cn = (Connect) session.getAttribute("CN");
	
	String table = request.getParameter("table");
	String col = request.getParameter("col");
	String key = request.getParameter("key");
	String backTable = request.getParameter("backTable");
	
	String condition = Util.buildCondition(col, key);
	
	String sql = "SELECT * FROM " + table + " WHERE " +condition;
	if (sql.endsWith(";")) sql = sql.substring(0, sql.length()-1);
	sql = sql.replaceAll("&gt;",">").replace("&lt;","<");
	System.out.println("PK-LINK:" + sql);
	
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
<table id="dataTable" class=gridBody border=1>
<tr>
<%
	boolean numberCol[] = new boolean[500];

	boolean hasData = false;
	if (rs != null) hasData = rs.next();
	int colIdx = 0;
	for  (int i = 1; rs != null && i<= rs.getMetaData().getColumnCount(); i++){
	
		String colName = q.getColumnLabel(i);

			//System.out.println(i + " column type=" +rs.getMetaData().getColumnType(i));
			colIdx++;
			int colType = q.getColumnType(i);
			numberCol[colIdx] = Util.isNumberType(colType);
			
%>
<th class="headerRow"><b><%=colName%></a></b></th>
<%
	}	
%>
</tr>

<%
	int rowIdx=0;
	while (rs != null && hasData/* && rs.next() */) {
		rowIdx++;
		String rowClass = "oddRow";
		if ((rowIdx)%2 == 0) rowClass = "evenRow";
%>
	<tr>
<%	
		colIdx=0;
		for  (int i = 1; i <= rs.getMetaData().getColumnCount(); i++){

				colIdx++;
				String val = q.getValue(i);
				String valDisp = Util.escapeHtml(val);
				if (val != null && val.endsWith(" 00:00:00")) valDisp = val.substring(0, val.length()-9);
				if (val==null) valDisp = "<span class='nullstyle'>null</span>";

				String colName = q.getColumnLabel(i);
				String keyValue = val;
%>
<td  class="<%=rowClass%>" <%= (numberCol[colIdx])?"align=right":""%>><%=valDisp%>
</td>
<%
		}
%>
</tr>
<%		counter++;
		if (counter >= 100) break;
		
		if (!rs.next()) break;
	}
	
	q.close();

%>
</table>

<br/>
<br/>

<a href="javascript:backTolinkPk('<%= backTable %>', '<%= Util.encodeUrl(key) %>')">Back</a> 

