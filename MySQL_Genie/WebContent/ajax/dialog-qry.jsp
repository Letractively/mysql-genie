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

	String id = Util.getId();
%>

<input id="input-<%= id %>" size=60><input type="button" value="Submit" onClick="Javascript:doQry(<%= id %>)"><br/>
<div id="sql-<%=id%>" style="display: none;"></div>
<div style="display: none;" id="hide-<%=id%>"></div>
<div style="display: none;" id="sort-<%=id%>"></div>
<div style="display: none;" id="sortdir-<%=id%>">0</div>
<div style="display: none;" id="mode-<%=id%>">sort</div>
<div id="div-<%=id%>">
</div>

