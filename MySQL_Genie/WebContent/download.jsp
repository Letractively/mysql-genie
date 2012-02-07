<%@ page language="java" 
	import="java.util.*"
	import="java.util.Date" 
	import="java.sql.*" 
	import="genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	response.setContentType("text/csv");
	String disposition = "attachment; fileName=data.csv";
    response.setHeader("Content-Disposition", disposition);
	
	String sql = request.getParameter("sql");
	if (sql.endsWith(";")) sql = sql.substring(0, sql.length()-1);
	Connect cn = (Connect) session.getAttribute("CN");
	
	String q2 = sql;
//	if (q2.toLowerCase().indexOf("limit ")<0) q2 += " LIMIT 100000";

	OldQuery q = new OldQuery(cn, q2, request);
	ResultSet rs = q.getResultSet();
	
	out.println("database,"+ cn.getUrlString() + " catalog: " + cn.getSchemaName());
	
	String q1 = sql.replaceAll("\n", " ").trim();
	out.println("query,\"" + q1 + "\",");
	out.println();

	boolean hasData = false;
	if (rs != null) hasData = rs.next();
	int colIdx = 0;	
	for  (int i = 1; i<= rs.getMetaData().getColumnCount(); i++){
		String colName = q.getColumnLabel(i);

		if (hasData) {
			colIdx ++;		
			out.print("\"" + colName + "\",");
		}
	}
	out.println();	

	int counter = 0;
	while (rs != null && hasData) {
		for  (int i = 1; i<= rs.getMetaData().getColumnCount(); i++){

			colIdx++;
			String val = q.getValue(i);
			if (val != null && val.endsWith(" 00:00:00")) val = val.substring(0, val.length()-9);
			out.print("\"" + val + "\",");
		}
		counter++;
		out.println();	
		if (counter >= 1000000) break;
		if (!rs.next()) break;
	}
	
	q.close();
	
%>
