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
	String title = "Worksheet";
	
	String sqls = request.getParameter("sqls");
	String sqlsStr[] = null;
	
	if (sqls != null) {
		sqlsStr = sqls.split("!");
	}
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

	<link rel="stylesheet" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.17/themes/base/jquery-ui.css" type="text/css" media="all" />
	<script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.17/jquery-ui.min.js" type="text/javascript"></script>
    
</head> 

<body>

<img src="image/worksheet.png" align="middle"/> <b>WORKSHEET</b>
&nbsp;&nbsp;
<%= cn.getUrlString() %>

<br/>
<a href="Javascript:hideNullColumn()">Hide Null</a>
&nbsp;&nbsp;
<a href="Javascript:showAllColumn()">Show All</a>
&nbsp;&nbsp;
<a href="Javascript:newQry()">Query</a>
&nbsp;&nbsp;

<br>
<a href="Javascript:toggleDiv('imgDiv1','div1')"><img id="imgDiv1" src="image/minus.gif"></a>
<div id="div1">
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
<!-- 
	<br/>
	&nbsp;&nbsp;&nbsp;
	<a href="Javascript:copyPaste('LOWER( )');">LOWER( )</a>&nbsp;
	<a href="Javascript:copyPaste('UPPER( )');">UPPER( )</a>&nbsp;
	<a href="Javascript:copyPaste('SUBSTR( )');">SUBSTR( )</a>&nbsp;
	<a href="Javascript:copyPaste('TRIM( )');">TRIM( )</a>&nbsp;
	<a href="Javascript:copyPaste('LENGTH( )');">LENGTH( )</a>&nbsp;
	&nbsp;&nbsp;&nbsp;
	<a href="Javascript:copyPaste('TO_DATE( )');">TO_DATE( )</a>&nbsp;
	<a href="Javascript:copyPaste('TO_NUMBER( )');">TO_NUMBER( )</a>&nbsp;
	<a href="Javascript:copyPaste('TO_CHAR( )');">TO_CHAR( )</a>&nbsp;

 -->
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

	function clearQuery() {
		$("#qry_stmt").val('');	
	}
	function runQry() {
		var sql = $("#qry_stmt").val();
		openQry(sql);
	}
	
	function openQry(sql) {
		//var id = "id"+(new Date().getTime());
		gid = gid + 1;
		var id = "id-" + gid;
		var temp ="<div id='" + id + "' title=\"" + sql + "\"' >";
		//alert(temp);
		//alert(encodeURI(sql));
		$.ajax({
			url: "ajax/dialog-openqry.jsp?sql=" + encodeURI(sql),
			success: function(data){
				temp = temp + data + "</div>";
				$("BODY").append(temp);
				$("#"+id).dialog({ width: 700, height: 400 });
				setHighlight();
			}
		});
	}    
	
	function openQryIndex(sql, idx) {
		//var id = "id"+(new Date().getTime());
		gid = gid + 1;
		var id = "id-" + gid;
		var temp ="<div id='" + id + "' title=\"" + sql + "\"' >";
		//alert(temp);
		//alert(encodeURI(sql));
		$.ajax({
			url: "ajax/dialog-openqry.jsp?sql=" + encodeURI(sql),
			success: function(data){
				temp = temp + data + "</div>";
				$("BODY").append(temp);
				$("#"+id).dialog({ width: 700, height: 200 });
				$("#"+id).dialog("option", "position", [200 + idx*50, 200 + idx*50]);
				//alert($("#"+id + " > table[0]").height());
				setHighlight();
			}
		});
	}    
	
	function doOpenQry(id) {
		var sql = $("#sql-"+id).html();
		//$("#id").val(id);
		$("#div-"+id).html("<img src='image/loading.gif'/>");
		$.ajax({
			url: "ajax/qry-simple.jsp?id=" + id  + "&sql="+ encodeURI(sql),
			success: function(data){
				$("#div-"+id).html(data);
				setHighlight();
			}
		});		
	}	
	
	function showHelp() {
		$("#helper").slideToggle();
	}	
	
	function setMode(mode) {
		var gotoUrl = "";
		var select = "";
		
		if (mode == "table") {
			gotoUrl = "ajax/list-table.jsp";
			select = "selectTable";
		} else if (mode == "view") {
			gotoUrl = "ajax/list-view.jsp";
			select = "selectView";
		}

		$("#selectTable").css("font-weight", "");
		$("#selectView").css("font-weight", "");
		$("#selectTable").css("background-color", "");
		$("#selectView").css("background-color", "");

		cleanPage();
		$("#inner-helper").html("<img src='image/loading.gif'/>");
		$.ajax({
			url: gotoUrl,
			success: function(data){
				$("#inner-helper").html(data);
			}
		});
		
		$("#" + select).css("font-weight", "bold");
		$("#" + select).css("background-color", "#d0d0ff");
		
		gMode = mode;
	}

	function cleanPage() {
		$("#searchFilter").val("");
		$("#inner-helper").html('');
	}

	function searchWithFilter(filter) {
		var mode = gMode;
		var gotoUrl = "";
		
		if (mode == "table") {
			gotoUrl = "ajax/list-table.jsp?filter=" + filter;
		} else if (mode == "view") {
			gotoUrl = "ajax/list-view.jsp?filter=" + filter;
		}

		$.ajax({
			url: gotoUrl,
			success: function(data){
				$("#inner-helper").html(data);
			}
		});
		
	}

	function loadTable(tName) {
		var tableName = tName;
		$("#inner-detail").html("<img src='image/loading.gif'/>");

		$.ajax({
			url: "ajax/detail-help-table.jsp?table=" + tableName + "&t=" + (new Date().getTime()),
			success: function(data){
				$("#inner-detail").html(data);
			}
		});	
	}

	function loadView(tName) {
		var tableName = tName;
		$("#inner-detail").html("<img src='image/loading.gif'/>");

		$.ajax({
			url: "ajax/detail-help-table.jsp?table=" + tableName + "&t=" + (new Date().getTime()),
			success: function(data){
				$("#inner-detail").html(data);
			}
		});	
	}
	
	function clearField() {
		$("#searchFilter").val("");
		searchWithFilter('');
	}

	function copyPaste(val) {
		$("#qry_stmt").insertAtCaret(" " + val);
	}
	
	$.fn.insertAtCaret = function (tagName) {
		return this.each(function(){
			if (document.selection) {
				//IE support
				this.focus();
				sel = document.selection.createRange();
				sel.text = tagName;
				this.focus();
			}else if (this.selectionStart || this.selectionStart == '0') {
				//MOZILLA/NETSCAPE support
				startPos = this.selectionStart;
				endPos = this.selectionEnd;
				scrollTop = this.scrollTop;
				this.value = this.value.substring(0, startPos) + tagName + this.value.substring(endPos,this.value.length);
				this.focus();
				this.selectionStart = startPos + tagName.length;
				this.selectionEnd = startPos + tagName.length;
				this.scrollTop = scrollTop;
			} else {
				this.value += tagName;
				this.focus();
			}
		});
	};	
			
	$(document).ready(function(){

		setMode('table');

		$('#searchFilter').change(function(){
			var filter = $(this).val().toUpperCase();
			searchWithFilter(filter);
	 	})
	 	
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
	 	
	})	
</script>

</body>
</html>

