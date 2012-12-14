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

	String table = request.getParameter("table");
	String key = request.getParameter("key");
	
	String pkName = cn.getPrimaryKeyName(table);
	String conCols = cn.getConstraintCols(table, pkName);
	
	String condition = Util.buildCondition(conCols, key);

	String sql = "SELECT * FROM " + table + " WHERE " + condition;
	if (sql.endsWith(";")) sql = sql.substring(0, sql.length()-1);
	sql = sql.replaceAll("&gt;",">").replace("&lt;","<");
	
	String id = Util.getId();
%>
<div id="sql-<%=id%>" style="display: none;"><%= sql %></div>
<%= sql %>
&nbsp;
<a href="javascript:openQuery('<%=id%>')"><img src="image/sql.png" border="0"></a>
&nbsp;
<%-- <a href="Javascript:hideNullColumnTable('<%=id%>')">Hide Null</a> --%>
<div id="div-<%=id%>">
<jsp:include page='qry-work.jsp'>
	<jsp:param value="<%= sql %>" name="sql"/>
	<jsp:param value="0" name="dataLink"/>
	<jsp:param value="<%= id %>" name="id"/>
</jsp:include>
</div>

<script type="text/javascript">
//	hideNullColumn("" + <%= id %>);
	hideNullColumnTable("" + <%= id %>);	
</script>
