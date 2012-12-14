<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="java.sql.*" 
	import="chingoo.mysql.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%
	Connect cn = (Connect) session.getAttribute("CN");
%>

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

<script type="text/javascript">

$('#searchFilter').change(function(){
	var filter = $(this).val().toUpperCase();
	searchWithFilter(filter);
})
	
</script>