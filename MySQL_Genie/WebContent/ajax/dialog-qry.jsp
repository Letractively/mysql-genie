<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="java.sql.*" 
	import="chingoo.mysql.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%
	int counter = 0;
	Connect cn = (Connect) session.getAttribute("CN");

	String id = Util.getId();
	String sql = request.getParameter("sql");
	if (sql==null) sql="";
%>

<div id="divText<%=id%>">
<textarea rows=2 cols=60 id='text-<%=id %>'><%=sql%></textarea>
<br/>
<input type="button" value="Submit" onClick="doTextQry(<%=id%>)">
</div>

<div id="divSql<%=id%>" style="display: none;"></div>

<div id="sql-<%=id%>" style="display: none;"></div>
<div style="display: none;" id="hide-<%=id%>"></div>
<div style="display: none;" id="sort-<%=id%>"></div>
<div style="display: none;" id="sortdir-<%=id%>">0</div>
<div style="display: none;" id="mode-<%=id%>">sort</div>

<div id="div-<%=id%>">
</div>

<% if (sql != null && sql.length() > 0) { %>
<script type="text/javascript">
doTextQry(<%=id%>);
</script>
<% } %>