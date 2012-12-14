<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="chingoo.mysql.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%
	String qry_rows = request.getParameter("qry_rows");
	Connect cn = (Connect) session.getAttribute("CN");

	if (qry_rows != null) {
		int rows = Integer.parseInt(qry_rows);
		
/* 		if (rows <= Def.MAX_ROWS) {
			cn.QRY_ROWS = rows;
		}
 */	}
%>
