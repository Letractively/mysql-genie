<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="chingoo.mysql.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	String owner = request.getParameter("owner");
	String syn = request.getParameter("name");
	Connect cn = (Connect) session.getAttribute("CN");

	// incase owner is null & table has owner info
	if (owner==null && syn!=null && syn.indexOf(".")>0) {
		int idx = syn.indexOf(".");
		owner = syn.substring(0, idx);
		syn = syn.substring(idx+1);
	}
		
	String catalog = cn.getSchemaName();

	String qry = "SELECT TABLE_OWNER, TABLE_NAME FROM USER_SYNONYMS WHERE SYNONYM_NAME='" + syn +"'";
	List<String[]> list = cn.query(qry);
	
	String oname = "";
	if (list.size()>0) {
		owner = list.get(0)[1];
		oname = list.get(0)[2];
	}
	
	qry = "SELECT OBJECT_TYPE FROM ALL_OBJECTS WHERE OWNER='" + owner +
			"' AND OBJECT_NAME='" + oname + "' ORDER BY OBJECT_TYPE";
	List<String> list2 = cn.queryMulti(qry);
	
	String otype = "";
	if (list2.size()>0) {
		otype = list2.get(0);
	}
	
%>
<h2>SYNONYM: <%= syn %> &nbsp;&nbsp;</h2>

&nbsp;&nbsp;&nbsp;<%= owner %>.<%= oname %>  (<%= otype %>)

<% if (otype.equals("TABLE")) { %>
	<jsp:include page="detail-table.jsp">
		<jsp:param value="<%= owner %>" name="owner"/>
		<jsp:param value="<%= oname %>" name="table"/>
	</jsp:include>
<% } else if (otype.equals("PACKAGE")) { %>
	<jsp:include page="detail-package.jsp">
		<jsp:param value="<%= owner %>" name="owner"/>
		<jsp:param value="<%= oname %>" name="name"/>
	</jsp:include>
<% } else if (otype.equals("VIEW")) { %>
	<jsp:include page="detail-view.jsp">
		<jsp:param value="<%= owner %>" name="owner"/>
		<jsp:param value="<%= oname %>" name="view"/>
	</jsp:include>
<% } %>	
