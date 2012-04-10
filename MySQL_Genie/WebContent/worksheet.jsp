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
	String title = "Work Sheet";
	
	String sqls = request.getParameter("sqls");
	String sqlsStr[] = null;
	
	if (sqls != null) {
		sqlsStr = sqls.split("\\^");
	}

	String worksheetName = request.getParameter("name"); 
	
	if (worksheetName == null) worksheetName = "no name";

	String qry = "SELECT SQL_STMTS, coords FROM GENIE_WORK_SHEET where id ='" + Util.escapeQuote(worksheetName) + "'";
	List<String[]> loaded = cn.queryMultiCol(qry, 2, false);
%>

<html>
<head> 
	<title><%= title %>- <%= worksheetName %></title>
    <script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
    <script src="script/data-methods.js?20120405" type="text/javascript"></script>
    <script src="script/worksheet-methods.js?20120405" type="text/javascript"></script>
    <script src="script/jquery.stickynotes.js"></script>

    <link rel='stylesheet' type='text/css' href='css/style.css'>
    <link rel='stylesheet' type='text/css' href='css/jquery.stickynotes.css'>
	<link rel="icon" type="image/png" href="image/Genie-icon.png">

	<link rel="stylesheet" href="css/ui-lightness/jquery-ui-1.8.18.custom.css" type="text/css"/>
	<script src="script/jquery-ui-1.8.18.custom.min.js" type="text/javascript"></script>

	<style>
		input.text { margin-bottom:12px; width:95%; padding: .4em; }
		fieldset { padding:0; border:0; margin-top:25px; }
		.ui-dialog .ui-state-error { padding: .3em; }
		.validateTips { border: 1px solid transparent; padding: 0.3em; }
	</style>
	<script>
	</script>

    
</head> 

<body style="background-color:#ffffff;">

<div style="float: left;">
<img src="image/worksheet.png" align="middle"/> <b>WORK SHEET</b>
&nbsp;&nbsp;
<%= cn.getUrlString() %>

&nbsp;&nbsp;&nbsp;&nbsp;
<a href="Javascript:hideNullColumn()">Hide Null</a>
&nbsp;&nbsp;
<a href="Javascript:showAllColumn()">Show All</a>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<a href="Javascript:newQry()">New Query</a>
&nbsp;&nbsp;
<a href="Javascript:newNote()">New Note</a>


</div>

<div style="float: right;">

<div id="dialog-form" title="Rename Work Sheet">
	<form>
	<fieldset>
		<label for="name">Work Sheet Name</label>
		<input type="text" name="name1" id="name1" class="text ui-widget-content ui-corner-all" />
	</fieldset>
	</form>
</div>

<div id="dialog-form2" title="Load Work Sheet">
<div id="load-worksheet-list"></div>
</div>


<div id="rename-contain" class="ui-widget">
	Name: <span style="color: #0000FF;"><b><span id="worksheetNameDisp"><%= worksheetName %></span></b></span>
	<button id="rename1">Rename</button>
	<button id="save1">Save</button>
	<button id="clear1">Clear</button>
	<button id="load1">Load</button>
</div>


</div><!-- End demo -->
<br clear="all"/>

<div id="notes" style="width:100%; height:100%; background-color: #ffffff;">
</div>


<%--

<br>
<a style="float: left;" href="Javascript:toggleDiv('imgDiv1','div1')"><img id="imgDiv1" border=0 src="image/minus.gif"></a>
<div id="div1" style="float: left;">
<a href="Javascript:showHelp()">Help</a>
<div id="helper" style="display: none">

<table border=0 cellspacing=0>
<td valign=top width=250>

<a class="mainBtn" href="Javascript:setMode('table')" id="selectTable">Table</a> | 
<a class="mainBtn" href="Javascript:setMode('view')" id="selectView">View</a> 
&nbsp;
<b>Search</b> <input id="searchFilter" style="width: 140px;"/>
<a href="Javascript:clearField()"><img border=0 src="image/clear.gif"></a>
<div id="outer-helper">
<div id="inner-helper">
</div>
</div>
</td>
<td valign=bottom>
<div id="outer-detail">
<div id="inner-detail">
</td>
</table>


	<div>
	<a href="Javascript:copyPaste('SELECT');">SELECT</a>&nbsp;
	<a href="Javascript:copyPaste('*');">*</a>&nbsp;
	<a href="Javascript:copyPaste('FROM');">FROM</a>&nbsp;
	<a href="Javascript:copyPaste('WHERE');">WHERE</a>&nbsp;
	<a href="Javascript:copyPaste('=');">=</a>&nbsp;
	<a href="Javascript:copyPaste('LIKE');">LIKE</a>&nbsp;
	<a href="Javascript:copyPaste('\'%\'');">'%'</a>&nbsp;
	<a href="Javascript:copyPaste('IS');">IS</a>&nbsp;
	<a href="Javascript:copyPaste('NOT');">NOT</a>&nbsp;
	<a href="Javascript:copyPaste('NULL');">NULL</a>&nbsp;
	<a href="Javascript:copyPaste('AND');">AND</a>&nbsp;
	<a href="Javascript:copyPaste('OR');">OR</a>&nbsp;
	<a href="Javascript:copyPaste('IN');">IN</a>&nbsp;
	<a href="Javascript:copyPaste('( )');">( )</a>&nbsp;
	<a href="Javascript:copyPaste('EXISTS');">EXISTS</a>&nbsp;
	<a href="Javascript:copyPaste('ORDER BY');">ORDER-BY</a>&nbsp;
	<a href="Javascript:copyPaste('DESC');">DESC</a>&nbsp;

 	<br/>
	&nbsp;&nbsp;&nbsp;
	<a href="Javascript:copyPaste('GROUP BY');">GROUP-BY</a>&nbsp;
	<a href="Javascript:copyPaste('HAVING');">HAVING</a>&nbsp;
	<a href="Javascript:copyPaste('COUNT(*)');">COUNT(*)</a>&nbsp;
	<a href="Javascript:copyPaste('SUM( )');">SUM( )</a>&nbsp;
	<a href="Javascript:copyPaste('AVG( )');">AVG( )</a>&nbsp;
	<a href="Javascript:copyPaste('MIN( )');">MIN( )</a>&nbsp;
	<a href="Javascript:copyPaste('MAX( )');">MAX( )</a>&nbsp;
	
	</div>
</div>
<form>
<textarea id="qry_stmt" rows=3 cols=80>
</textarea>
<br/>
<input type="button" value="Query" onClick="runQry()">
<input type="button" value="Clear" onClick="clearQuery()">
</form>
</div>
<br/><br/>
--%>


<div style="display: none;">
<form name="form0" id="form0" action="query.jsp">
<input id="sql" name="sql" type="hidden" value=""/>
<input id="id" name="id" type="hidden" value=""/>
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
 
<script type="text/javascript">
	var gMode = "table";
	var gid = 0;
	var DBSTR = "<%= cn.getUrlString() %>";
	var gWorksheetName = "<%= worksheetName %>";

	var edited = function(note) {
		//alert("Edited note with id " + note.id + ", new text is: " + note.text);
	}
	var created = function(note) {
		//alert("Created note with id " + note.id + ", text is: " + note.text);
	}
	
	var deleted = function(note) {
		//alert("Deleted note with id " + note.id + ", text is: " + note.text);
	}
	
	var moved = function(note) {
		//alert("Moved note with id " + note.id + ", text is: " + note.text);
	}	
	
	var resized = function(note) {
		//alert("Resized note with id " + note.id + ", text is: " + note.text);
	}					

 	$(document).ready(function(){
		var options = {
			notes:[{"id":1,
			      "text":"Note",
				  "pos_x": 50,
				  "pos_y": 50,	
				  "width": 200,							
				  "height": 200,													
			    }]
			,resizable: true
			,controls: true 
			,editCallback: edited
			,createCallback: created
			,deleteCallback: deleted
			,moveCallback: moved					
			,resizeCallback: resized					
			
		};
		$("#notes").stickyNotes(options);

		$("div.jSticky-medium").each(function() {
			$(this).remove();
		});

	});
	
	$(document).ready(function(){

		setMode('table');

		$('#searchFilter').change(function(){
			var filter = $(this).val().toUpperCase();
			searchWithFilter(filter);
	 	})
	 	
	 	showLoadWorksheet();
	 	
<% if (sqls != null) { 
	 int idx = 0;
	 for (String s : sqlsStr) {
		 idx ++;
%>
		openQryIndex("<%=s%>", <%= idx %>);
<%
	 }
 }
%>

//		var sqls = localStorage.getItem(DBSTR + ' genie-worksheet-sql');
	})	
</script>



<form id="form-save" name="form-save">
<input type="hidden" id="save-name" name="name" value=""/>
<input type="hidden" id="save-sqls" name="sqls" value=""/>
<input type="hidden" id="save-coords" name="coords" value=""/>
</form>

<form id="form-load" name="form-load" method="GET">
<input type="hidden" id="load-name" name="name" value=""/>
</form>

<%
	String s1="";
	String s2="";
	if (loaded.size() >= 1) {
		s1 = loaded.get(0)[1];
		s2 = loaded.get(0)[2];
	}
%>
<div id="loadedSqls" style="display:none;"><%= Util.escapeHtml(s1) %></div>
<div id="loadedCoords" style="display:none;"><%= Util.escapeHtml(s2) %></div>

</body>
</html>

