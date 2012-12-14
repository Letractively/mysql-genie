<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="chingoo.mysql.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	Connect cn = (Connect) session.getAttribute("CN");

	String searchKey = request.getParameter("searchKey");
	String inclTable = request.getParameter("inclTable");
	String exclTable = request.getParameter("exclTable");
//	String owner = request.getParameter("owner");
	String matchType = request.getParameter("matchType");
	String caseType = request.getParameter("caseType");
	
	if (searchKey != null) searchKey = searchKey.trim();
%>

<%-- searchKey=<%=searchKey%> <br/>
inclTable=<%=inclTable%> <br/>
exclTable=<%=exclTable%> <br/>
matchType=<%=matchType%> <br/>
caseType=<%=caseType%> <br/>
 --%>

<%

	ContentSearch cs = cn.contentSearch;
	List<String> tables = cs.search(cn, searchKey, inclTable, exclTable, matchType, caseType);
%>
Found in <%= tables.size() %> table(s).<br/><br/>

<% 
	int i = 0;
	for (String tname : tables) {
		i ++;
		String temp[] = tname.split("\\.");
		
		String qry = "SELECT * FROM " + temp[0] + " WHERE ";
		
		if (matchType.equals("partial")) {
			if (caseType.equals("ignore"))
				qry += "lower(" + temp[1] + ") like '%" + Util.escapeQuote(searchKey.toLowerCase()) + "%'";
			else
				qry += temp[1] + " like '%" + Util.escapeQuote(searchKey) + "%'";
		} else {
			if (caseType.equals("ignore"))
				qry += "lower(" + temp[1] + ") = '" + Util.escapeQuote(searchKey.toLowerCase()) + "'";
			else
				qry += temp[1] + " = '" + Util.escapeQuote(searchKey) + "'";
		}
%>
&nbsp;&nbsp;<%= tname %>
<div style="display:none;" id="qry-<%=i%>"><%= qry %></div>
<a href="Javascript:openQuery('<%= "qry-" + i %>')"><img src="image/view.png"></a>

<br/>
<% } %>
