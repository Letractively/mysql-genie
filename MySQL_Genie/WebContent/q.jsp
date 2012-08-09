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
%>

<html>
<head> 
	<title>Q</title>
    <script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
    <script src="script/data-methods.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>
    <script src="script/worksheet-methods.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>

    <link rel='stylesheet' type='text/css' href='css/style.css?<%= Util.getScriptionVersion() %>'>
	<link rel="icon" type="image/png" href="image/Genie-icon.png">

	<link rel="stylesheet" href="css/ui-lightness/jquery-ui-1.8.18.custom.css" type="text/css"/>
	<script src="script/jquery-ui-1.8.18.custom.min.js" type="text/javascript"></script>
    
</head> 

<body>

<img src="image/icon_query.png" align="middle"/> <b>QUERY</b>
&nbsp;&nbsp;
<%= cn.getUrlString() %>

&nbsp;&nbsp;&nbsp;
<a href="Javascript:showHelp()">Help</a> |
<a href="Javascript:newQry()">New Query</a> |
<a href="worksheet.jsp">Work Sheet</a>

<br/>

<a href="Javascript:hideNullColumn()">Hide Null</a>
&nbsp;&nbsp;
<a href="Javascript:showAllColumn()">Show All</a>
&nbsp;&nbsp;

<h3>Query</h3>

<a href="Javascript:toggleQry()"><img style="float: left" id="qryDivImage" border="0" src="image/minus.gif"></a>
<div id="div-qry">
<form id="form1">
<textarea id="qry_stmt" name="sql" cols=60 rows=3>SELECT * FROM TAB</textarea>
<br/>
<input name="loc" type="radio" value="T" checked>Top
<input name="loc" type="radio" value="B">Bottom
<input type="button" value="Submit" onClick="submitSql()">
<input type="button" value="Clear" onClick="clearSql()">
</form>
</div>
<br clear="all">


<div style="display: none;">
<form name="form0" id="form0" action="q.jsp">
<input id="sql" name="sql" type="hidden" value=""/>
<input id="dataLink" name="dataLink" type="hidden" value="0"/>
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

<div id="baseline"></div>

<script type="text/javascript">

var id = 0;

function clearSql() {
	$("#qry_stmt").val("");
}

function removeDiv(id) {
	$("#remove-"+id).remove();
}

function toggleQry() {
	var src = $("#qryDivImage").attr('src');
	if (src.indexOf("minus")>0) {
		$("#div-qry").slideUp();
		$("#qryDivImage").attr('src','image/plus.gif');
	} else {
		$("#div-qry").slideDown();
		$("#qryDivImage").attr('src','image/minus.gif');
	}
}

function submitSql() {
	var sql = $("#qry_stmt").val();
	id = id + 1;
	var divName = "div-" + id;
	
	var loc = $('input[name=loc]:checked').val();
	//alert(loc);
	
	$("#sql").val(sql);
	$("#id").val(id);
	$("#pageNo").val("1");

	$("#showFK").val(showFK);
	$("#" + divName).hide();
	
	$.ajax({
		type: 'POST',
		url: "ajax/qry-simple.jsp",
		data: $("#form0").serialize(),
		success: function(data){
			var newDiv = 
			"<div id='remove-"+id+"'>" +
			"<div style='display: none;' id='sql-" + id + "'>" + sql + "</div>" +
			"<div style='display: none;' id='mode-" + id + "'>sort</div>" +
			"<div style='display: none;' id='hide-" + id + "'></div>" +
			"<div style='display: none;' id='sort-" + id + "'></div>" +
			"<div style='display: none;' id='sortdir-" + id + "'>0</div>" +
			"<b>" + sql + "</b>&nbsp;&nbsp;<a href='javascript:removeDiv("+id+")'>X</a><br/>" +
			"<div style='margin-left: 20px;' id='" + divName + "'>" +	data + "</div>" +
			"<br/><br/>" +
			"</div>";
			if (loc == "T")
				$("#baseline").prepend(newDiv);
			else
				$("#baseline").append(newDiv);
			setHighlight();
		},
        error:function (jqXHR, textStatus, errorThrown){
            alert(jqXHR.status + " " + errorThrown);
        }  
	});	
	
}

</script>

<script type="text/javascript">

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', '<%= Util.trackingId() %>']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

</script>

</body>
</html>

