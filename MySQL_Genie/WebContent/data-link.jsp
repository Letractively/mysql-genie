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
	Connect cn = (Connect) session.getAttribute("CN");

	String table = request.getParameter("table");
	String key = request.getParameter("key");
	List<String> refTabs = cn.getReferencedTables(table);

	String sql = cn.getPKLinkSql(table, key);
/*
	Query q = cn.queryCache.getQueryObject(sql);
	if (q==null) {
		q = new Query(cn, sql);
		cn.queryCache.addQuery(sql, q);
	}
*/
	Query q = new Query(cn, sql);

	// Foreign keys - For FK lookup
	List<ForeignKey> fks = cn.getForeignKeys(table);
//System.out.println("fks.size()=" + fks.size());	
	Hashtable<String, String>  linkTable = new Hashtable<String, String>();

	List<String> fkLinkTab = new ArrayList<String>();
	List<String> fkLinkCol = new ArrayList<String>();
	
	for (int i=0; i<fks.size(); i++) {
		ForeignKey rec = fks.get(i);
		String linkCol = cn.getConstraintCols(rec.tableName, rec.constraintName);
		String rTable = rec.rTableName;
		
		fkLinkTab.add(rTable);
		fkLinkCol.add(linkCol);
	}

	List<String> autoLoadFK = new ArrayList<String>();
	List<String> autoLoadChild = new ArrayList<String>();
	
	String title = table + " " + key;	
%>


<html>
<head> 
	<title><%= title %></title>
    <script src="script/jquery.js" type="text/javascript"></script>
    <script src="script/data-methods.js?20120302" type="text/javascript"></script>

    <script src="script/jquery.colorbox-min.js"></script>

    <link rel='stylesheet' type='text/css' href='css/style.css'>
    <link rel="stylesheet" href="css/colorbox.css" />
	<link rel="icon" type="image/png" href="image/Genie-icon.png">
    
	<link rel="stylesheet" href="css/ui-lightness/jquery-ui-1.8.18.custom.css" type="text/css"/>
	<script src="script/jquery-ui-1.8.18.custom.min.js" type="text/javascript"></script>
</head> 

<body>
<%
	String id = Util.getId();
%>

<img src="image/data-link.png" align="middle"/> <b>DATA LINK</b>
&nbsp;&nbsp;
<%= cn.getUrlString() %>

&nbsp;&nbsp;&nbsp;&nbsp;

<a href="Javascript:hideNullColumn()">Hide Null</a>
&nbsp;&nbsp;
<a href="Javascript:showAllColumn()">Show All</a>
&nbsp;&nbsp;
<a href="Javascript:newQry()">Query</a>
&nbsp;&nbsp;
<a id="showERD" href="Javascript:showERD('<%=table%>')">Show ERD</a>

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<a href="Javascript:openWorksheet()">Open Work Sheet</a>

<br/><br/>

<div id="tableList1" style="display: hidden; margin-left: 20px;">
</div>

<% if (fkLinkTab.size() > 0) {%>
	<b><a style="margin-left: 50px;" href="Javascript:toggleFK()">Foreign Key <img id="img-fk" border=0 src="image/minus.gif"></a></b><br/>
<div id="div-fk" style="margin-top:10px;">
<% } %>
<%
	for (int i=0; i<fkLinkTab.size(); i++) {
		String ft = fkLinkTab.get(i);
		String fc = fkLinkCol.get(i);
		
		String keyValue = null;
		String[] colnames = fc.split("\\,");
		boolean hasNull = false;
		for (int j=0; j<colnames.length; j++) {
			String x = colnames[j].trim();
			String v = (q==null?"":q.getValue(x));
//			System.out.println("x,v=" +x +"," + v);
			if (v==null) hasNull = true;
			if (keyValue==null)
				keyValue = v;
			else
				keyValue += "^" + v;
		}
		
		if (hasNull) continue;
		String fsql = cn.getPKLinkSql(ft, keyValue);
		id = Util.getId();
		autoLoadFK.add(id);
%>


<div id="div-fkk-<%=id%>">
<a style="margin-left: 70px;" href="javascript:loadData('<%=id%>',1)"><b><%=ft%></b> <img id="img-<%=id%>" align=middle src="image/plus.gif"></a>
&nbsp;&nbsp;<a href="javascript:openQuery('<%=id%>')"><img src="image/sql.png" align=middle  title="<%=fsql%>"/></a>
(<%= table %>.<%= fc %>)
&nbsp;&nbsp;<a href="javascript:hideDiv('div-fkk-<%=id%>')"><img src="image/clear.gif" border=0/></a>
<div style="display: none;" id="sql-<%=id%>"><%= fsql%></div>
<div style="display: none;" id="mode-<%=id%>">hide</div>
<div style="display: none;" id="hide-<%=id%>"></div>
<div id="div-<%=id%>" style="margin-left: 70px; display: none;"></div>
<br/>
</div>
<% } %>

<% if (fkLinkTab.size() > 0) {%>
	<img style="margin-left: 70px;" src="image/arrow_up.jpg"><br/>
</div>
<% } %>




<%
	id = Util.getId();
%>

<b><%= table %></b>
&nbsp;&nbsp;<a href="javascript:openQuery('<%=id%>')"><img src="image/sql.png" title="<%=sql%>"/></a>
<div style="display: none;" id="sql-<%=id%>"><%= sql%></div>
<div style="display: none;" id="mode-<%=id%>">hide</div>
<div style="display: none;" id="hide-<%=id%>"></div>
<br/>
<div id="div-<%=id %>" style1="padding: 5px; background-color: gray;">
<jsp:include page="ajax/qry-simple.jsp">
	<jsp:param value="<%= sql %>" name="sql"/>
	<jsp:param value="0" name="dataLink"/>
	<jsp:param value="<%= id %>" name="id"/>
</jsp:include>
</div>
<br/>















<div style="display: none;">
<form name="form0" id="form0" action="query.jsp">
<input id="sql" name="sql" type="hidden" value=""/>
<input id="dataLink" name="dataLink" type="hidden" value="1"/>
<input id="id" name="id" type="hidden" value=""/>
<input id="showFK" name="showFK" type="hidden" value="0"/>
<input type="hidden" id="sortColumn" name="sortColumn" value="">
<input type="hidden" id="sortDirection" name="sortDirection" value="0">
<input type="hidden" id="hideColumn" name="hideColumn" value="">
<input type="hidden" id="filterColumn" name="filterColumn" value="">
<input type="hidden" id="filterValue" name="filterValue" value="">
<input type="hidden" id="searchValue" name="searchValue" value="">
<input type="hidden" id="pageNo" name="pageNo" value="1">
<input type="hidden" id="rowsPerPage" name="rowsPerPage" value="20">
</form>
</div>


<%
	// Primary Key for PK Link
	String pkName = cn.getPrimaryKeyName(table);
	String pkCols = null;
	String pkColName = null;
	int pkColIndex = -1;
	if (pkName != null) {
		pkCols = cn.getConstraintCols(table, pkName);
		int colCount = Util.countMatches(pkCols, ",") + 1;
		pkColName = pkCols;
	}

	int cntRef = 0;
	for (int i=0; i<refTabs.size(); i++) {
		String refTab = refTabs.get(i);
//System.out.println("refTab="+refTab);		
		String fkColName = cn.getRefConstraintCols(table, refTab);
//System.out.println("fkColName="+fkColName);		
		int recCount = cn.getPKLinkCount(refTab, fkColName , key);
		if (recCount==0) continue;
		String refsql = cn.getRelatedLinkSql(refTab, fkColName, key);

		id = Util.getId();
		autoLoadChild.add(id);
		cntRef++;
%>

<% if (cntRef == 1) {%>
	<b><a style="margin-left: 50px;" href="Javascript:toggleChild()">Child Table <img id="img-child" src="image/minus.gif"></a></b><br/>
<div id="div-child">
	<img style="margin-left: 70px;" src="image/arrow_up.jpg"><br/>
<% } %>

<div id="div-child-<%=id%>">
<a style="margin-left: 70px;" href="javascript:loadData('<%=id%>',0)"><b><%= refTab %></b> (<%= recCount %>) <img id="img-<%=id%>" align=middle src="image/plus.gif"></a>
&nbsp;&nbsp;<a href="javascript:openQuery('<%=id%>')"><img src="image/sql.png" align=middle  title="<%=refsql%>"/></a>
&nbsp;&nbsp;<a href="javascript:hideDiv('div-child-<%=id%>')"><img src="image/clear.gif" border=0/></a>
<div style="display: none;" id="sql-<%=id%>"><%= refsql%></div>
<div style="display: none;" id="hide-<%=id%>"></div>
<div style="display: none;" id="sort-<%=id%>"></div>
<div style="display: none;" id="sortdir-<%=id%>">0</div>
<div style="display: none;" id="mode-<%=id%>">sort</div>
<div id="div-<%=id%>" style="margin-left: 70px; display: none;"></div>
<br/>
</div>
<%	
	}	
%>

<% if (cntRef > 0) {%>
</div>
<% } %>

<br/><br/>
<a href="Javascript:window.close()">Close</a>
<br/><br/>

<script type="text/javascript">
$(document).ready(function() {
	$(".inspect").colorbox({transition:"none", width:"800", height:"600"});
<%
	for (String id1: autoLoadFK) {
%>
	loadData(<%=id1%>,1);
<%
	}
%>

<%
if (autoLoadChild.size() <= 5) {
	for (String id1: autoLoadChild) {
%>
loadData(<%=id1%>,0);
<%
	}
}
%>
});	    
</script>

<form name="form_worksheet" target="_blank" action="worksheet.jsp" method="post">
<input id="sqls" name="sqls" type="hidden">
</form>

</body>
</html>

