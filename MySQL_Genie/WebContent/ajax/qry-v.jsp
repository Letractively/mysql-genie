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
	String sortColumn = request.getParameter("sortColumn");
	String sortDirection = request.getParameter("sortDirection");
	String pageNo = request.getParameter("pageNo");
	String dataLink = request.getParameter("dataLink");

	boolean dLink = dataLink != null && dataLink.equals("1");  
	
	boolean preFormat = request.getParameter("preFormat") != null && request.getParameter("preFormat").equals("1");
	//preFormat = true;
	
	int pgNo = 1;
	if (pageNo != null) pgNo = Integer.parseInt(pageNo);

	String rowsPerPage = request.getParameter("rowsPerPage");
	int linesPerPage = 20;
	if (rowsPerPage != null) linesPerPage = Integer.parseInt(rowsPerPage);
	
	String filterColumn = request.getParameter("filterColumn");
	String filterValue = request.getParameter("filterValue");
	String searchValue = request.getParameter("searchValue");
	if (searchValue==null) searchValue = "";
/*
	String hideColumn = request.getParameter("hideColumn");
	if (hideColumn == null) hideColumn = "";
	
	String hiddenColumns[] = hideColumn.split("\\,");
*/

//System.out.println("filterColumn=" + filterColumn);
//System.out.println("filterValue=" + filterValue);
//System.out.println("pageNo=" + pgNo);
//System.out.println("rowsPerPage=" + rowsPerPage);

	if (sql==null) sql = "SELECT * FROM TABLE";
	sql = sql.trim();
	if (sql.endsWith(";")) sql = sql.substring(0, sql.length()-1);
	sql = sql.replaceAll("&gt;",">").replace("&lt;","<");
	
	String norun = request.getParameter("norun");
	
	Connect cn = (Connect) session.getAttribute("CN");
//	System.out.println(request.getRemoteAddr()+": " + sql +";");
	
	int lineLength = Util.countLines(sql);
	if (lineLength <5) lineLength = 5;

	Query q = cn.queryCache.getQueryObject(sql);
	if (q==null) {
		q = new Query(cn, sql, false);
		cn.queryCache.addQuery(sql, q);
	} else {
//		System.out.println("*** REUSE Query");
	}

	if (q != null && q.isError()) {
%>
		<%= q.getMessage() %>
<%		
		return;
	}
	
	q.removeFilter();

	if (sortColumn != null && !sortColumn.equals("")) q.sort(sortColumn, sortDirection);
	if (filterColumn != null && !filterColumn.equals("")) {
		if (filterColumn.equals("0")) {
			filterColumn = q.getColumnLabel(0);
		}
		q.filter(filterColumn, filterValue);
	}
	
	if (searchValue !=null && !searchValue.equals("")) {
		q.search(searchValue);
	}
	
	// get table name
	String tbl = Util.getMainTable(sql);
	List<String> tbls = Util.getTables(sql); 
//	if (tbls.size()>0) tbl = tbls.get(0);
//	System.out.println("XXX TBL=" + tbl);

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

	boolean hasDataLink = false;
	String tname = tbl;
	if (tname==null) tname = "";
	if (tname.indexOf(".") > 0) tname = tname.substring(tname.indexOf(".")+1);

	// Foreign keys - For FK lookup
	List<ForeignKey> fks = cn.getForeignKeys(tname);
	Hashtable<String, String>  linkTable = new Hashtable<String, String>();
//	Hashtable<String, String>  linkTable2 = new Hashtable<String, String>();
	
	List<String> fkLinkTab = new ArrayList<String>();
	List<String> fkLinkCol = new ArrayList<String>();
	
	for (int i=0; i<fks.size(); i++) {
		ForeignKey rec = fks.get(i);
		String linkCol = cn.getConstraintCols(rec.tableName, rec.constraintName);
		String rTable = rec.rTableName;
		
//		System.out.println("linkCol=" + linkCol);
//		System.out.println("rTable=" + rTable);
		
		int colCount = Util.countMatches(linkCol, ",") + 1;
		if (colCount == 1) {
			if (rTable != null) linkTable.put(linkCol, rTable);
//			System.out.println("linkTable");
		} else {
			// check if columns are part of result set
			int matchCount = 0;
			String[] t = linkCol.split("\\,");
			for (int j=0;j<t.length;j++) {
				String colName = t[j].trim();
				for  (int k = 0; k<= q.getColumnCount()-1; k++){
					String col = q.getColumnLabel(k);
					if (col.equalsIgnoreCase(colName)) {
						matchCount++;
						continue;
					}
				}
			}
			if (rTable != null && matchCount==colCount) {
				fkLinkTab.add(rTable);
				fkLinkCol.add(linkCol);
			}
//			System.out.println("linkTable2");
		}
	}
	
	
	// Primary Key for PK Link
	String pkName = cn.getPrimaryKeyName(tname);
//System.out.println("pkName=" + pkName);			
	boolean pkLink = false;
	boolean hasPK = false;
	int pkColIndex = -1;
	
	List<String> pkColList = null;
	if (pkName != null) {
		pkColList = cn.getConstraintColList(tname, pkName);
/*
System.out.println("tname=" + tname);			
System.out.println("pkName=" + pkName);			
System.out.println("pkColList=" + pkColList.size());			
System.out.println("pkColList=" + pkColList.get(0));
*/
		// check if PK columns are in the result set
		int matchCount = 0;
		for (int j=0;j<pkColList.size();j++) {
			String colName = pkColList.get(j);
			for  (int i = 0; i<= q.getColumnCount()-1; i++){
				String col = q.getColumnLabel(i);
				if (col.equalsIgnoreCase(colName)) {
					matchCount++;
					continue;
				}
			}
		}

		if (tbls.size()>=1) hasPK = true;
//System.out.println("hasPK=" + hasPK);		
		// there should be other tables that has FK to this
		List<String> refTabs = cn.getReferencedTables(tname);
		if (matchCount == pkColList.size() && refTabs.size()>0) {
			pkLink = true;
			hasDataLink = true;
		}

//		System.out.println("pkLink=" + pkLink);			
//		System.out.println("hasPK=" + hasPK);			
	
	}
	
	// check if FK links are there
	if (!hasDataLink) {
		for  (int i = 0; q.hasData() && i < q.getColumnCount(); i++){
			String colName = q.getColumnLabel(i);
			String lTable = linkTable.get(colName);
			if (lTable != null) {
				hasDataLink = true;
				break;
			}
		}
	}
	
	int totalCount = q.getRecordCount();
	int filteredCount = q.getFilteredCount();
	int totalPage = q.getTotalPage(linesPerPage);
%>

<pre style="color: #000000;"><%= sql %></pre>
<% if (pgNo>1) { %>
<a href="Javascript:gotoPage(<%= pgNo - 1%>)"><img border=0 src="image/btn-prev.png" align="top"></a>
<% } %>

<% if (totalPage > 1) { %>
Page: <b><%= pgNo %></b> of <%= totalPage %>
<% } %>

<% if (q.getTotalPage(linesPerPage) > pgNo) { %>
<a href="Javascript:gotoPage(<%= pgNo + 1%>)"><img border=0 src="image/btn-next.png" align="top"></a>
<% } %>


Records: <%= filteredCount %>
<% if (totalCount > filteredCount) {%>
(<%= totalCount %>)
<% } %>

<% if (filteredCount > 10) {%>
Rows/Page 
<select id="linePerPage" name="linePerPage" onChange="rowsPerPage(this.options[this.selectedIndex].value);">
<option value="1" <%= (linesPerPage==1?"SELECTED":"") %>>1</option>
<option value="2" <%= (linesPerPage==2?"SELECTED":"") %>>2</option>
<option value="5" <%= (linesPerPage==5?"SELECTED":"") %>>5</option>
<option value="10" <%= (linesPerPage==10?"SELECTED":"") %>>10</option>
<option value="20" <%= (linesPerPage==20?"SELECTED":"") %>>20</option>
</select>

<% } %>

<% if (totalCount > 1) { %>
&nbsp;&nbsp;<img src="image/view.png">
<input id="search" name="search" value="<%= searchValue %>" size=20 onChange="searchRecords($(this).val())">
<a href="Javascript:clearSearch()"><img border="0" src="image/clear.gif"></a>
<% } %>





<% if (totalCount>0 && hasDataLink) { 
		String txt = "DataLink";
		if (!dLink) txt = "DataLink"; 
%>
<a id="dataLinkText" href="Javascript:toggleDataLink()"><%= txt %></a>
<% } %>

<% if (totalCount>0) { 
		String txt = "Format";
%>
<a id="preFormatText" href="Javascript:togglePreFormat()"><%= txt %></a>
<% } %>



<!-- <table id="dataTable" border=1 class="gridBody">
<tr>
 -->
<%
	int offset = 0;
	String pkLabel[] = new String [q.getColumnCount()+1];
	String pkDataLink[] = new String [linesPerPage+1];
	String dataCell[][] = new String[linesPerPage+1][q.getColumnCount()+1];

	if (hasPK && dLink) {
		offset ++;
%>
<!-- 	<th class="headerRow"><b>PK</b></th>
 --><%
	}
	if (fkLinkTab.size()>0 && dLink) {
		offset ++;
%>
<!-- 	<th class="headerRow"><b>FK Link</b></th>
 --><%
	}
	boolean numberCol[] = new boolean[500];

	boolean hasData = q.hasMetaData();
	int colIdx = 0;
	for  (int i = 0; i<= q.getColumnCount()-1; i++){
	
		String colName = q.getColumnLabel(i);

			//System.out.println(i + " column type=" +rs.getMetaData().getColumnType(i));
			colIdx++;
			int colType = q.getColumnType(i);
			numberCol[colIdx] = Util.isNumberType(colType);
//System.out.println(colName + "=" + colType);

			String tooltip = q.getColumnTypeName(i) + " " + colType;
			String comment =  cn.getComment(tname, colName);
			if (comment != null && comment.length() > 0) tooltip += " " + comment;
		
			boolean highlight=false;
			if (colName.equals(filterColumn)) highlight = true;
			
			String extraImage = "";
			if (colName.equals(sortColumn)) {
				if (sortDirection.equals("0"))
					extraImage = "<img src='image/sort-ascending.png'>";
				else
					extraImage = "<img src='image/sort-descending.png'>";
			}

			String colDisp = colName.toLowerCase();
			String cpasDisp = "";
			if (pkColList != null && pkColList.contains(colName)) colDisp = "<b>" + colDisp + "</b>";					

			pkLabel[i] = "<a " + ( highlight?"style='background-color:yellow;'" :"") + 
					" href=\"Javascript:doAction('" + colName + "', " + (colIdx + offset) + ");\" title=\"" + tooltip + "\">" +
					colDisp + "</a>" + extraImage + cpasDisp;

			
%>
<%-- <th class="headerRow"><a <%= ( highlight?"style='background-color:yellow;'" :"")%>
	href="Javascript:doAction('<%=colName%>', <%= colIdx + offset %>);" title="<%= tooltip %>"><%=colDisp%></a>
	<%= extraImage %>
</th>
 --%><%
	} 
%>
<!-- </tr>

 -->
<%
	int rowCnt = 0;
	String pkValues = ""; 

//System.out.println("pageNo=" + pgNo);
//System.out.println("linesPerPage=" + linesPerPage);
	q.rewind(linesPerPage, pgNo);
	
	while (q.next() && rowCnt < linesPerPage) {
		rowCnt++;
		String rowClass = "oddRow";
		if (rowCnt%2 == 0) rowClass = "evenRow";
%>
<!-- <tr class="simplehighlight">

 --><%
	if (hasPK && q.hasData() && dLink) {
		String keyValue = null;
	
		for (int i=0;q.hasData() && i<pkColList.size(); i++) {
			String v = q.getValue(pkColList.get(i));
//System.out.println("v=" + v);	
//System.out.println("pkColList.get(i)=" + pkColList.get(i));
			if (i==0) keyValue = v;
			else keyValue = keyValue + "^" + v; 
		}
		pkValues = keyValue;
		
		String linkUrl = "ajax/pk-link.jsp?table=" + tname + "&key=" + Util.encodeUrl(keyValue);
		String linkUrlTree = "data-link.jsp?table=" + tname + "&key=" + Util.encodeUrl(keyValue);
		
		pkDataLink[rowCnt-1] = "<a href='" + linkUrlTree + "'><img src=\"image/chingoo-icon.png\" width=16 height=16 border=0 title=\"Data Link\"></a>";
%>
<%-- 	<td class="<%= rowClass%>">
	<% if (pkLink && false) { %>
		<a class='inspect' href='<%= linkUrl %>'><img border=0 src="image/link.gif" title="Related Tables"></a>
		&nbsp;
	<% } %>
		<a href='<%= linkUrlTree %>'><img src="image/follow.gif" border=0 title="Data Link"></a>
	</td>
 --%><%
	}
if (fkLinkTab.size()>0 && dLink) {
%>
<%-- <td class="<%= rowClass%>">
 --%><% 
	for (int i=0;q.hasData() && i<fkLinkTab.size();i++) { 
		String t = fkLinkTab.get(i);
		String c = fkLinkCol.get(i);
		
		String keyValue = null;
		String[] colnames = c.split("\\,");
		for (int j=0; q.hasData() && j<colnames.length; j++) {
			String x = colnames[j].trim();
			String v = q.getValue(x);
//			System.out.println("x,v=" +x +"," + v);
			if (keyValue==null)
				keyValue = v;
			else
				keyValue += "^" + v;
		}
		
		String url = "ajax/fk-lookup.jsp?table=" + t + "&key=" + Util.encodeUrl(keyValue);
%>
<%-- <a class="inspect" href="<%= url%>"><%=t%><img border=0 src="image/view.png"></a>&nbsp;

 --%><%			} %>
<!-- </td>
 --><%		}
		colIdx=0;
		for  (int i = 0; q.hasData() && i < q.getColumnCount(); i++){

				colIdx++;
				String val = q.getValue(i);
				String colTypeName = q.getColumnTypeName(i);
				String valDisp = Util.escapeHtml(val);
				if (val != null && val.endsWith(" 00:00:00")) valDisp = val.substring(0, val.length()-9);
				if (val==null) valDisp = "<span class='nullstyle'>null</span>";
				if (val !=null && val.length() > 200) {
					String id = Util.getId();
					String id_x = Util.getId();
					valDisp = valDisp.substring(0,200) + "<a id='"+id_x+"' href='Javascript:toggleText2(" +id_x + "," +id +")'>...</a><span id='"+id+"' style='display: none;'>" + valDisp.substring(200) + "</span>";
					
					if (preFormat) valDisp = "<pre>" + val + "</pre>";			
				} else {
					if (preFormat) valDisp = "<pre>" + val + "</pre>";
				}

				String colName = q.getColumnLabel(i);
				String lTable = linkTable.get(colName);
				String keyValue = val;
				boolean isLinked = false;
				String linkUrl = "";
				String linkImage = "image/view.png";
				if (lTable != null  && dLink) {
					isLinked = true;
//					linkUrl = "ajax/fk-lookup.jsp?table=" + lTable + "&key=" + Util.encodeUrl(keyValue);
					linkUrl = "Javascript:showDialog('" + lTable + "','" + Util.encodeUrl(keyValue) + "' )";
				} else if (val != null && val.startsWith("BLOB ")) {
					isLinked = true;
					String tpkName = cn.getPrimaryKeyName(tbl);
					String tpkCol = cn.getConstraintCols(tbl, tpkName);
					//String tpkValue = q.getValue(tpkCol);
					String tpkValue = pkValues;
					
//					linkUrl ="blob.jsp?table=" + tbl + "&col=" + colName + "&key=" + Util.encodeUrl(tpkValue);
					String fname = "unknown";
					fname = q.getValue("filename");
					linkUrl ="blob_download?table=" + tbl + "&col=" + colName + "&key=" + Util.encodeUrl(tpkValue)+"&filename="+fname;
					linkImage ="image/download.gif";
				} else if (colTypeName.equals("CLOB")) {
					isLinked = true;
					String tpkName = cn.getPrimaryKeyName(tbl);
					String tpkCol = cn.getConstraintCols(tbl, tpkName);
					String tpkValue = pkValues;
					
//					linkUrl ="blob.jsp?table=" + tbl + "&col=" + colName + "&key=" + Util.encodeUrl(tpkValue);
					String fname = "download.txt";
					if (val!=null && val.startsWith("<?xml")) fname = "download.xml";
					if (val!=null && val.startsWith("<html")) fname = "download.html";
					
					linkUrl ="clob_download?table=" + tbl + "&col=" + colName + "&key=" + Util.encodeUrl(tpkValue)+"&filename="+fname;
					linkImage ="image/download.gif";
				}
				
				if (pkColIndex >0 && i == pkColIndex && false) {
					isLinked = true;
					linkUrl = "ajax/pk-link.jsp?table=" + tname + "&key=" + Util.encodeUrl(keyValue);
					linkImage = "image/link.gif";
				}

				if (pkColList != null && pkColList.contains(colName)) valDisp = "<span class='pk'>" + valDisp + "</span>";

				dataCell[rowCnt-1][colIdx-1] = valDisp;
				if (dLink && val!=null && !val.equals("") && isLinked && !linkUrl.startsWith("Javascript")) 
					dataCell[rowCnt-1][colIdx-1] += "<a target=_blank href=\"" + linkUrl  + "\"><img border=0 src='" + linkImage + "'></a>";
				
				if (dLink && val!=null && !val.equals("") && linkUrl.startsWith("Javascript"))
					dataCell[rowCnt-1][colIdx-1] += "<a href=\"" + linkUrl  + "\"><img border=0 src='" + linkImage + "'></a>";
				
%>
<%-- <td class="<%= rowClass%>" <%= (numberCol[colIdx])?"align=right":""%>><%=valDisp%>
<%= (val!=null && isLinked && !linkUrl.startsWith("Javascript")?"<a class='inspect' href=\"" + linkUrl  + "\"><img border=0 src='" + linkImage + "'></a>":"")%>
<%= (val!=null && isLinked && linkUrl.startsWith("Javascript")?"<a href=\"" + linkUrl  + "\"><img border=0 src='" + linkImage + "'></a>":"")%>
</td>
 --%><%
		}
%>
<!-- </tr>
 --><%		if (q.hasData()) counter++;
//		if (counter >= Def.MAX_ROWS) break;
		
//		if (!q.next()) break;
	}
	
	//q.close();

%>
<!-- </table>
 -->
<input id="recordCount" value="<%= q.getRecordCount() %>" type="hidden">

<%--
<%= counter %> rows found.<br/>
Elapsed Time <%= q.getElapsedTime() %>ms.<br/>
--%>

<table id="dataTable" border=1 class="gridBody">
<% if (dLink) { %>
<tr>
	<th class="headerRow"></th>
<% 
	for (int j=0; j<Math.min(linesPerPage, filteredCount);j++) {
%>
	<th class="headerRow"><%= (pkDataLink[j]==null?"&nbsp;":pkDataLink[j]) %></th>
<%
	}
%>
</tr>
<% } %>

<% 
	for (int i=0; i<q.getColumnCount();i++) {
%>
	<tr class="simplehighlight">
	<td style="background-color: #D6E7FF"><%= (pkLabel[i]==null?"&nbsp;":pkLabel[i]) %></td>
<% 
	for (int j=0; j<Math.min(linesPerPage, filteredCount);j++) {
%>
	<td <%= (numberCol[i+1])?"align=right":""%>><%= dataCell[j][i] %></td>
<%
	}
%>
	</tr>
<% 
	}
%>

</table>

<br/><br/>
