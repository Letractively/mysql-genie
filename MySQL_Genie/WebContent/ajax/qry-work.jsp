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
	String sql = request.getParameter("sql");
	String id = request.getParameter("id");
	
	String pageNo = request.getParameter("pageNo");
	int pgNo = 1;
	if (pageNo != null) pgNo = Integer.parseInt(pageNo);

	String sortColumn = request.getParameter("sortColumn");
	String sortDirection = request.getParameter("sortDirection");
	String main = request.getParameter("main");
	
	if (sql==null) sql = "SELECT * FROM TABLE";
	sql = sql.trim();
	if (sql.endsWith(";")) sql = sql.substring(0, sql.length()-1);
	sql = sql.replaceAll("&gt;",">").replace("&lt;","<");

	String searchValue = request.getParameter("searchValue");
	if (searchValue==null) searchValue = "";
	
	Connect cn = (Connect) session.getAttribute("CN");
	Query q = new Query(cn, sql);
	if (q.isError()) {
%>
	<%= q.getMessage() %>
<%		
		return;
	}
	
	q.removeFilter();
	if (sortColumn != null && !sortColumn.equals("")) q.sort(sortColumn, sortDirection);
	if (searchValue !=null && !searchValue.equals("")) q.search(searchValue);
	
	// get table name
	String tbl = null;
	List<String> tbls = Util.getTables(sql); 
	if (tbls.size()>0) tbl = tbls.get(0);
	//	System.out.println("XXX TBL=" + tbl);

	String tname = tbl;
	if (tname.indexOf(".") > 0) tname = tname.substring(tname.indexOf(".")+1);

	List<String> pkColList = null;
	int linesPerPage = 20;
	int totalCount = q.getRecordCount();
	int filteredCount = q.getFilteredCount();
	int totalPage = q.getTotalPage(linesPerPage);
%>

<% if (q.getRecordCount() > 0) { %>

<% if (pgNo>1) { %>
<a href="Javascript:gotoPage(<%=id%>, <%= pgNo - 1%>)"><img border=0 src="image/prev.png" align="bottom"></a>
<% } %>

<% if (totalPage > 1) { %>
Page: <b><%= pgNo %></b> of <%= totalPage %>
<% } %>

<% if (q.getTotalPage(linesPerPage) > pgNo) { %>
<a href="Javascript:gotoPage(<%=id%>, <%= pgNo + 1%>)"><img border=0 src="image/next.png" align="bottom"></a>
<% } %>

Found: <%= filteredCount %>
<% if (totalCount > filteredCount) {%>
(of <%= totalCount %>)
<% } %>

<a id="modeHide-<%=id%>" href="Javascript:setColumnMode(<%=id%>,'hide')">Hide</a>
<a href="Javascript:showAllColumnTable('table-<%=id%>')">Show All</a>&nbsp;
<% if (totalCount>=2) { %>
<a id="modeSort-<%=id%>" href="Javascript:setColumnMode(<%=id%>,'sort')">Sort</a>
<% } %>

&nbsp;&nbsp;&nbsp;&nbsp;
<% if (totalCount>=5) { %>
<img src="image/view.png"><input id="search-<%=id%>" value="<%= searchValue %>" size=15 onChange="searchTable(<%=id%>,$(this).val())">
<a href="Javascript:clearSearch(<%=id%>)"><img border="0" src="image/clear.gif"></a>
<% } %>

<% } %>

<table id="table-<%= id %>" border=1 class="gridBody">
<tr>

<%
	boolean numberCol[] = new boolean[500];

	boolean hasData = q.hasMetaData();
	int colIdx = 0;
	for  (int i = 0; i<= q.getColumnCount()-1; i++){
	
		String colName = q.getColumnLabel(i);

		//System.out.println(i + " column type=" +rs.getMetaData().getColumnType(i));
		colIdx++;
		int colType = q.getColumnType(i);
		numberCol[colIdx] = Util.isNumberType(colType);
			
		String tooltip = q.getColumnTypeName(i);
		String comment =  cn.getComment(tname, colName);
		if (comment != null && comment.length() > 0) tooltip += " " + comment;
			
		String extraImage = "";
		boolean highlight = false;
		if (colName.equals(sortColumn)) {
			highlight = true;
			if (sortDirection.equals("0"))
				extraImage = "<img src='image/sort-ascending.png'>";
			else
				extraImage = "<img src='image/sort-descending.png'>";
		}
%>
<th class="headerRow"><a <%= ( highlight?"style='background-color:yellow;'" :"")%>
	href="Javascript:setColumn(<%= id %>, '<%=colName%>', <%= colIdx %>);" title="<%= tooltip %>"><%=colName.toLowerCase()%></a>
	<%= extraImage %>
</th>
<%
	} 
%>
</tr>

<%
	int rowCnt = 0;
	q.rewind(linesPerPage, pgNo);
	
	while (q.next()) {
		rowCnt++;
		String rowClass = "oddRow";
		if (rowCnt%2 == 0) rowClass = "evenRow";
%>
<tr class="simplehighlight">

<%
	colIdx=0;
	for  (int i = 0; q.hasData() && i < q.getColumnCount(); i++){

		colIdx++;
		String val = q.getValue(i);
		String valDisp = Util.escapeHtml(val);
		if (val != null && val.endsWith(" 00:00:00")) valDisp = val.substring(0, val.length()-9);
		if (val==null) valDisp = "<span class='nullstyle'>null</span>";
		if (val !=null && val.length() > 50) {
			id = Util.getId();
			String id_x = Util.getId();
			valDisp = valDisp.substring(0,50) + "<a id='"+id_x+"' href='Javascript:toggleText(" +id_x + "," +id +")'>...</a><span id='"+id+"' style='display: none;'>" + valDisp.substring(50) + "</span>";
		}
				
		String colName = q.getColumnLabel(i);
		String keyValue = val;
%>
<td class="<%= rowClass%>" <%= (numberCol[colIdx])?"align=right":""%>><%=valDisp%>
</td>
<%
	}
%>
</tr>
<%		if (q.hasData()) counter++;
		if (counter >= linesPerPage) break;
	}
	
%>
</table>
