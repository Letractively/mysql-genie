<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="java.sql.*" 
	import="genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	int counter = 0;
	String sql = request.getParameter("qry");
	if (sql==null) sql = "SELECT * FROM TABLE";
	sql = sql.trim();
	if (sql.endsWith(";")) sql = sql.substring(0, sql.length()-1);
	sql = sql.replaceAll("&gt;",">").replace("&lt;","<");
	
	Connect cn = (Connect) session.getAttribute("CN");
	
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
	
	String tname = tbl;
	if (tname.indexOf(".") > 0) tname = tname.substring(tname.indexOf(".")+1);

%>

<a href="javascript:form1.submit()"><img border=0 src="image/icon_query.png" title="open query"></a>


<form id="form1" name="form1" target=_blank action="query.jsp" method="post">
<textarea id="sql" name="sql" cols=70 rows=4>
<%= sql %>
</textarea>
</form>

<table id="dataTable" class="gridBody" border=1>
<tr class="rowHeader">

<%
	int offset = 0;
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
			
			String tooltip = ""; //q.getColumnTypeName(i);
			String comment =  cn.getComment(tname, colName);
			if (comment != null && comment.length() > 0) tooltip += " " + comment;
			
%>
<th><b><%=colName%></b></th>
<%
	} 
%>
</tr>


<%
	int rowCnt = 0;
	while (rs != null && hasData/* && rs.next() */) {
		rowCnt++;
		String rowClass = "odd";
		if (rowCnt%2 == 0) rowClass = "even";
%>
<tr class="<%= rowClass%>">

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
				boolean isLinked = false;
				String linkUrl = "";
%>
<td <%= (numberCol[colIdx])?"align=right":""%>><%=valDisp%>
</td>
<%
		}
%>
</tr>
<%		counter++;
		if (counter >= 2000) break;
		
		if (!rs.next()) break;
	}
	
	q.close();

%>
</table>
<%= counter %> rows found.<br/>
Elapsed Time <%= q.getElapsedTime() %>ms.<br/>
