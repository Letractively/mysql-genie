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
	String matchType = request.getParameter("matchType");
	String caseType = request.getParameter("caseType");
%>
<%

	ContentSearch cs = cn.contentSearch;  
	cs.cancel();
%>
