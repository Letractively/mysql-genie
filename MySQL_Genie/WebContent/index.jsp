<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	Connect cn = (Connect) session.getAttribute("CN");

	String title = "Genie " + cn.getUrlString();
%>

<html>
<head> 
	<title><%= title %></title>
	
	<script src="script/jquery.js" type="text/javascript"></script>
<!--     <script src="script/jquery.colorbox-min.js"></script> -->
	<script src="script/main.js?20120301" type="text/javascript"></script>

<!--     <link rel="stylesheet" href="css/colorbox.css" /> -->
    <link rel='stylesheet' type='text/css' href='css/style.css'>

	<link rel="icon" type="image/png" href="image/Genie-icon.png">
	
	<link rel="stylesheet" href="css/ui-lightness/jquery-ui-1.8.18.custom.css" type="text/css"/>
	<script src="script/jquery-ui-1.8.18.custom.min.js" type="text/javascript"></script>

<%--
	<script type="text/javascript" src="script/shCore.js"></script>
	<script type="text/javascript" src="script/shBrushSql.js"></script>
    <link href="css/shThemeDefault.css" rel="stylesheet" type="text/css" />
--%>
    
<script type="text/javascript">
var CATALOG="";
var to;
var to2;
var stack = [];
var stackFwd = [];

$(window).resize(function() {
	checkResize();
});
	
$(document).ready(function(){

//	$(".about").colorbox();

	setMode('table');
	checkResize();
	CATALOG = "<%= cn.getSchemaName()%>";
//	toggleKeepAlive();
	callserver();

	$('#searchFilter').change(function(){
		var filter = $(this).val().toUpperCase();
		searchWithFilter(filter);
 	})
 	
	$('#globalSearch').change(function(){
 		var keyword = $(this).val().toLowerCase();
 		globalSearch(keyword);
 	})
 	
})

	function aboutGenie() {
		// a workaround for a flaw in the demo system (http://dev.jqueryui.com/ticket/4375), ignore!
		$( "#dialog:ui-dialog" ).dialog( "destroy" );
	
		$( "#dialog-modal" ).dialog({
			height: 450,
			width: 500,
			modal: true,
			buttons: {
				Ok: function() {
					$( this ).dialog( "close" );
				}
			}			
		});
	}
	
	function toggleKeepAlive() {
		var t = $("#keepalivelink").html();
		if (t=="Off") {
			$("#keepalivelink").html("On");
			setTimeout("callserver()",1000);
		} else {
			$("#keepalivelink").html("Off");
			clearTimeout(to);
		}
	}

	function checkResize() {
		var w = $(window).width();
		var h = $(window).height();
	
		if (h > 500) {
			var diff = $('#outer-table').position().top - $('#outer-result1').position().top;
			//alert(diff);
			var newH = h - 80;

			var tmp = w - $('#outer-table').width() - $('#outer-result2').width() - 45; 

			$('#outer-table').height(newH-diff);
			$('#outer-result1').height(newH);
			$('#outer-result2').height(newH);
			
			if (tmp < 660) tmp = 660;
			$('#outer-result1').width(tmp);
			
		}
	}
	
function callserver() {
	var remoteURL = 'ping.jsp';
	$.get(remoteURL, function(data) {
		if (data.indexOf("true")>0)
			to = setTimeout("callserver()",600000);
		else {
			$("#inner-result1").html("Connection Closed.");
		}
	});
}	
</script>


</head> 

<body>

<table width=100%>
<td><img src="image/lamp.png"/></td>
<td valign=bottom><h3><%= cn.getUrlString() %></h3></td>
<td>
&nbsp;
<select name="schema" id="shcmeaList" onchange="loadSchema(this.options[this.selectedIndex].value);">
	<option></option>
<% for (int i=0; i<cn.getSchemas().size();i++) { %>
	<option value="<%=cn.getSchema(i)%>" <%= cn.getSchemaName().equals(cn.getSchema(i))?"SELECTED ":"" %>><%=cn.getSchema(i)%></option>
<% } %>
</select>

</td>

<td>
<a href="index.jsp">Home</a> |
<a href="query.jsp" target="_blank">Query</a> |
<a href="worksheet.jsp" target="_blank">Work Sheet</a> |
<a href="javascript:queryHistory()">History</a> |
<a href="javascript:clearCache()">Clear Cache</a> |
<a href="logout.jsp">Log out</a>
&nbsp;
&nbsp;

<%--
Keep Alive <a id="keepalivelink" href="Javascript:toggleKeepAlive()">Off</a>
--%>

<!-- <a class='about' href='ajax/about-genie.jsp'>About Genie</a> -->

<a href='Javascript:aboutGenie()'>About Genie</a>
</td>
<td align=right>
<b>Search</b> <input id="globalSearch" style="width: 200px;"/>
<a href="Javascript:clearField2()"><img border=0 src="image/clear.gif"></a>
</td>
</table>


<table border=0 cellspacing=0>
<td valign=top width=250>

<a class="mainBtn" href="Javascript:setMode('table')" id="selectTable">Table</a> | 
<a class="mainBtn" href="Javascript:setMode('view')" id="selectView">View</a> | 
<%--
<a class="mainBtn" href="Javascript:setMode('synonym')" id="selectSynonym">Synonym</a> | 
 --%>
<a class="mainBtn" href="Javascript:setMode('package')" title="Package, Type, Function & Procedure" id="selectPackage">Program</a>| 
<a class="mainBtn" href="Javascript:setMode('tool')" id="selectTool">Tool</a>

<!-- | <a href="Javascript:setMode('tool')" id="selectTool">Tool</a> -->
<%-- <% if (cn.hasDbaRole()) { %> --%>
<!-- | <a href="Javascript:setMode('dba')" id="selectDBA">DBA</a> -->
<%-- <% }  else { %> --%>
<!-- | not DBA -->
<%-- <% } %> --%>


<br/>

<b>Search</b> <input id="searchFilter" style="width: 180px;"/>
<a href="Javascript:clearField()"><img border=0 src="image/clear.gif"></a>
<div id="outer-table">
<div id="inner-table">
</div>
</div>
</td>
<td valign=top>
<div id="outer-result1">
	<div id="inner-nav">
		<a href="Javascript:goBack()"><img id="imgBackward" src="image/blue_arrow_left.png" title="back" border="0" style="display:none;"></a>
		&nbsp;&nbsp;
		<a href="Javascript:goFoward()"><img id="imgForward" src="image/blue_arrow_right.png" title="forward" border="0" style="display:none;"></a>
	</div>
	<div id="inner-result1"><img src="image/genie_bw.png"/></div>
</div>
</td>
<td valign=top>
<div id="outer-result2">
	<div id="inner-result2"></div>
</div>
</td>
</table>
<form id="FORM_query" name="FORM_query" action="query.jsp" target="_blank" method="post">
<input id="sql" name="sql" type="hidden"/>
<input name="norun" type="hidden" value="YES"/>
</form>


<div id="dialog-modal" title="About MySQL Genie" style="display:none; background: #ffffff;">
<img src="image/genie2.jpg" align="center" />
<br/>
Thanks for using MySQL Genie.<br/>

Genie is open-source web-based tool for MySQL database.<br/>
Genie will help you navigate through database objects and their relationships.<br/> 

<br/>
If you have any question or suggestion, please feel free to contact me.
<br/><br/>

Please download the latest version here:<br/>
<a href="http://code.google.com/p/mysql-genie/">http://code.google.com/p/mysql-genie/</a>
<br/><br/>

Apr. 5, 2012<br/>
Spencer Hwang - the creator of Genie<br/>
<a href="mailto:spencer.hwang@gmail.com">spencer.hwang@gmail.com</a>

</div>

	
</body>
</html>