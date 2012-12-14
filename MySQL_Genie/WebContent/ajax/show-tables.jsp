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
<select size=1 id="selectTable" name=""selectTable"" onChange="showTable(this.options[this.selectedIndex].value);"">
	<option></option>
<% for (int i=0; i<cn.getTables().size();i++) { %>
	<option value="<%=cn.getTable(i)%>"><%=cn.getTable(i)%></option>
<% } %>
</select>

<input id="input-table" size=30 value="" onChange="showTable(this.value)"/>

