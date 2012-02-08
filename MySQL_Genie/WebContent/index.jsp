<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	Connect cn = (Connect) session.getAttribute("CN");
%>

<html>
<head> 
	<title>Genie</title>
	
	<script src="script/jquery.js" type="text/javascript"></script>
    <script src="script/jquery.colorbox-min.js"></script>
	<script src="script/main.js" type="text/javascript"></script>

    <link rel="stylesheet" href="css/colorbox.css" />
    <link rel='stylesheet' type='text/css' href='css/style.css'> 

	<link rel="icon" type="image/png" href="image/Genie-icon.png">
<%--
	<script type="text/javascript" src="script/shCore.js"></script>
	<script type="text/javascript" src="script/shBrushSql.js"></script>
    <link href="css/shThemeDefault.css" rel="stylesheet" type="text/css" />
--%>
    
<script type="text/javascript">
var CATALOG="";
var to;
var to2;
$(window).resize(function() {
	checkResize();
});
	
$(document).ready(function(){

	$(".about").colorbox();

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
			var newH = h - 70;

			var tmp = w - $('#outer-table').width() - $('#outer-result2').width() - 35; 

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

<table width=98%>
<td><img src="image/lamp.png"/></td>
<td><%= cn.getUrlString() %></td>
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
<a href="javascript:queryHistory()">Query History</a> |
<a href="javascript:clearCache()">Clear Cache</a> |
<a href="logout.jsp">Log out</a>
&nbsp;
&nbsp;

<%--
Keep Alive <a id="keepalivelink" href="Javascript:toggleKeepAlive()">Off</a>
--%>

<a class='about' href='ajax/about-genie.jsp'>About Genie</a>

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
	<div id="inner-result1"><img src="image/genie_bw.png"/></div>
</div>
</td>
<td valign=top>
<div id="outer-result2">
	<div id="inner-result2"></div>
</div>
</td>
</table>

<br/>

<form id="FORM_query" name="FORM_query" action="query.jsp" target="_blank" method="post">
<input id="sql" name="sql" type="hidden"/>
<input name="norun" type="hidden" value="YES"/>
</form>


