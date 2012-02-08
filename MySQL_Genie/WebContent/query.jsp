<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="java.sql.*" 
	import="genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>


<%

	Connect cn = (Connect) session.getAttribute("CN");
	
	int counter = 0;
	String sql = request.getParameter("sql");
	if (sql==null) sql = "SELECT * FROM TAB";
	sql = sql.trim();
	if (sql.endsWith(";")) sql = sql.substring(0, sql.length()-1);
	if (sql.endsWith("/")) sql = sql.substring(0, sql.length()-1);
	sql = sql.replaceAll("&gt;",">").replace("&lt;","<");
	
	String norun = request.getParameter("norun");
	
	int lineLength = Util.countLines(sql);
	if (lineLength <3) lineLength = 3;
	
	QueryCache.getInstance().removeQuery(sql);
	Query q = new Query(cn, sql);

	if (!q.isError())
		QueryCache.getInstance().addQuery(sql, q);
	
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

<html>
<head> 
	<title>Genie - Query</title>
    <script src="script/jquery.js" type="text/javascript"></script>

    <script src="script/jquery.colorbox-min.js"></script>
    <script src="script/query-methods.js" type="text/javascript"></script>

    <link rel='stylesheet' type='text/css' href='css/style.css'>
    <link rel="stylesheet" href="css/colorbox.css" />
	<link rel="icon" type="image/png" href="image/Genie-icon.png">
    
    <script type="text/javascript">
	$(document).ready(function() {
		showTable('<%=tbl%>');
		setDoMode('sort');
		$(".inspect").colorbox({transition:"none", width:"800", height:"600"});
		var cnt = $("#recordCount").val();
		if (cnt != "0") $("#buttonsDiv").show('slow');
	});	    
	
    $(document).ready(function(){
		$('.simplehighlight').hover(function(){
			$(this).children().addClass('datahighlight');
		},function(){
			$(this).children().removeClass('datahighlight');
		});
      });
    </script>
</head> 

<body>

<img src="image/icon_query.png" align="middle"/>
<%= cn.getUrlString() %>

<br/><br/>

<div id="tableList1">
<a href="Javascript:showRelatedTables('<%=tbl%>')">Show Related Tables</a>
</div>

<a href="Javascript:toggleTableDetail()"><img  style="float: left" id="tableDetailImage" border="0" src="image/minus.gif"></a>
<div id="table-detail" style="float: left"></div>
<br clear="all"/>

<a href="Javascript:copyPaste('SELECT');">SELECT</a>&nbsp;
<a href="Javascript:copyPaste('COUNT(*)');">COUNT(*)</a>&nbsp;
<a href="Javascript:copyPaste('FROM');">FROM</a>&nbsp;
<a href="Javascript:copyPaste('WHERE');">WHERE</a>&nbsp;
<a href="Javascript:copyPaste('=');">=</a>&nbsp;
<a href="Javascript:copyPaste('LIKE');">LIKE</a>&nbsp;
<a href="Javascript:copyPaste('IS');">IS</a>&nbsp;
<a href="Javascript:copyPaste('NOT');">NOT</a>&nbsp;
<a href="Javascript:copyPaste('NULL');">NULL</a>&nbsp;
<a href="Javascript:copyPaste('AND');">AND</a>&nbsp;
<a href="Javascript:copyPaste('OR');">OR</a>&nbsp;
<a href="Javascript:copyPaste('IN');">IN</a>&nbsp;
<a href="Javascript:copyPaste('()');">()</a>&nbsp;
<a href="Javascript:copyPaste('EXISTS');">EXISTS</a>&nbsp;
<a href="Javascript:copyPaste('GROUP BY');">GROUP-BY</a>&nbsp;
<a href="Javascript:copyPaste('HAVING');">HAVING</a>&nbsp;
<a href="Javascript:copyPaste('ORDER BY');">ORDER-BY</a>&nbsp;
<a href="Javascript:copyPaste('DESC');">DESC</a>&nbsp;

<form name="form1" id="form1" method="post" action="query.jsp">
<textarea id="sql" name="sql" cols=100 rows=<%= lineLength %>><%= sql %></textarea><br/>
<input type="submit" value="Submit"/>
&nbsp;
<input type="button" value="Download" onClick="Javascript:download()"/>
</form>

<form name="form0" id="form0">
<textarea style="display: none;" id="sql" name="sql" ><%= sql %></textarea>
<input type="hidden" id="sortColumn" name="sortColumn" value="">
<input type="hidden" id="sortDirection" name="sortDirection" value="0">
<input type="hidden" id="hideColumn" name="hideColumn" value="">
<input type="hidden" id="filterColumn" name="filterColumn" value="">
<input type="hidden" id="filterValue" name="filterValue" value="">
<input type="hidden" id="searchValue" name="searchValue" value="">
<input type="hidden" id="pageNo" name="pageNo" value="1">
<input type="hidden" id="rowsPerPage" name="rowsPerPage" value="20">
<input type="hidden" id="dataLink" name="dataLink" value="1">
</form>

<%= q.getMessage() %>

<%
	if (norun!=null || !q.hasMetaData()) {
%>
<br/><br/>
<a href="Javascript:window.close()">Close</a>
<br/><br/>

</body>
</html>
<%
		return;		
	}
%>

<BR/>
<div id="buttonsDiv" style="display: none;">
<TABLE>
<TD><a class="qryBtn" id="modeSort" href="Javascript:setDoMode('sort')">Sort</a>
<TD><a class="qryBtn" id="modeCopy" href="Javascript:setDoMode('copy')">Copy&amp;Paste</a></TD>
<TD><a class="qryBtn" id="modeHide" href="Javascript:setDoMode('hide')">Hide Column</a>
	<span id="showAllCol" style="display: none;"><a href="Javascript:showAllColumn()">Show All Column</a>&nbsp;</span>
</TD>
</TD>
<TD><a class="qryBtn" id="modeFilter" href="Javascript:setDoMode('filter')">Filter</a></TD>
<TD><span id="filter-div"></span></TD>
</TABLE>
</div>
<BR/>

<div id="data-div">
<jsp:include page="ajax/qry.jsp">
	<jsp:param value="<%= sql%>" name="sql"/>
	<jsp:param value="1" name="pageNo"/>
	<jsp:param value="" name="sortColumn"/>
	<jsp:param value="0" name="sortDirection"/>
	<jsp:param value="" name="filterColumn"/>
	<jsp:param value="" name="filterValue"/>
	<jsp:param value="1" name="dataLink"/>
</jsp:include>
</div>

<br/>
<a href="Javascript:window.close()">Close</a>
<br/><br/>

</body>
</html>