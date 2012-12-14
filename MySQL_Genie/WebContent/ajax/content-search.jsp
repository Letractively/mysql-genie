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
<form id="form0" name="form0">
<input hidden="radio" name="caseType" value="sensitive">
<table>
<tr>
	<td>Search For</td>
	<td><input id="searchKey" name="searchKey" size="30"> (search keyword/phrase)</td>
</tr>
<tr>
	<td>Include Table</td>
	<td><input name="inclTable" size="30">partial table name to include (multiple)</td>
</tr>
<tr>
	<td>Exclude Table</td>
	<td><input name="exclTable" size="30">partial table name to exclude (multiple)</td>
</tr>
<!-- <tr>
	<td>Owner</td>
	<td>
		<input type="radio" name="owner" value="mine" checked>My User
		<input type="radio" name="owner" value="other">Other Users (Synonym)
	</td>
</tr>
 -->
<tr>
	<td>Match Type</td>
	<td>
		<input type="radio" name="matchType" value="exact" checked>Exact match
		<input type="radio" name="matchType" value="partial">Partial match
	</td>
</tr>
<!-- <tr>
	<td>Case</td>
	<td>
		<input type="radio" name="caseType" value="ignore" checked>Ignore Case
		<input type="radio" name="caseType" value="sensitive">Case Sensitive
	</td>
</tr>
 -->
<tr>
	<td>&nbsp;</td>
	<td>
		<input id="startButton" type="button" value="Start Search" onclick="startSearch()">
		<input id="cancelButton" type="button" disabled=true value="Stop" onclick="cancelSearch()">
	</td>
</tr>
</table>

</form>

<div id="searchResult">
</div>

<br/><br/>

<div id="progressDiv" style="display: none; margin-left: 40px; border: 1px solid #D9D9D9; width: 400px; height: 200px; overflow: auto;">
	<div id="searchProgress"></div>
</div>

<br clear=all>

<form id="form_qry" target=_blank method="post" action="query.jsp">
<input id="sql" name="sql" value="" style="display: none;">
</form>