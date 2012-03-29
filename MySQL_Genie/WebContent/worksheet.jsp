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

<form>
<textarea id="qry_stmt" rows=3 cols=80>
</textarea>
<br/>
<input type="button" value="Query" onClick="openQry()">
<input type="button" value="Clear" onClick="clearQuery()">
</form>

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
	function clearQuery() {
		$("#qry_stmt").val('');	
	}
	function openQry() {
		var id = "id"+(new Date().getTime());
		var sql = $("#qry_stmt").val();
		$("#sql").val(sql);
		var temp ="<div id='" + id + "' title='" + sql + "' >";
		
		$.ajax({
			type: 'POST',
			url: "ajax/dialog-openqry.jsp",
			data: $("#form0").serialize(),
			success: function(data){
				temp = temp + data + "</div>";
				$("BODY").append(temp);
				$("#"+id).dialog({ width: 700, height: 400 });
				setHighlight();
			}
		});
	}    
	
	function doOpenQry(id) {
		var sql = $("#sql-"+id).html();
		$("#id").val(id);
		$.ajax({
			url: "ajax/qry-simple.jsp",
			data: $("#form0").serialize(),
			success: function(data){
				$("#div-"+id).html(data);
				setHighlight();
			}
		});		
	}	
</script>

</body>
</html>

