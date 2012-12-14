<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="chingoo.mysql.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	Connect cn = (Connect) session.getAttribute("CN");

	String object = request.getParameter("object");
	object = object.toUpperCase();
	System.out.println(cn.getUrlString() + " " + Util.getIpAddress(request) + " " + (new java.util.Date()) + "\nObject: " + object);

	String qry = "select LOWER(TABLE_NAME), 'TABLE' from information_schema.TABLES WHERE table_type='BASE TABLE' AND table_schema='"+ cn.getSchemaName()+"' UNION " + 	
			"SELECT LOWER(TABLE_NAME), 'VIEW' FROM INFORMATION_SCHEMA.VIEWS WHERE table_schema='"+ cn.getSchemaName()+"' UNION " +
			"SELECT LOWER(ROUTINE_NAME), 'ROUTINE' FROM INFORMATION_SCHEMA.ROUTINES WHERE routine_schema	='"+cn.getSchemaName()+"' order by 1"; 	
	
//	System.out.println(qry);
	List<String[]> list = cn.query(qry, 10000, true);

	String oType = "";
	for (int i=0;i<list.size();i++) {
		if (list.get(i)[1].equalsIgnoreCase(object)) {
			oType = list.get(i)[2];
			break;
		}
	}
	
	if (oType.equals("TABLE")) {
		response.sendRedirect("detail-table.jsp?table=" + object);
	} else if (oType.equals("VIEW")) {
		response.sendRedirect("detail-view.jsp?view=" + object);
	} else if (oType.equals("ROUTINE")) {
		response.sendRedirect("detail-package.jsp?name=" + object);
	} else {
		System.out.println("Unknown object: " + object + " " + oType);
	}
	
%>
