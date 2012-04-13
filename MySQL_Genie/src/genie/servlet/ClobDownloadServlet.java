package genie.servlet;

import java.io.BufferedInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.sql.Blob;
import java.sql.Clob;
import java.sql.ResultSet;
import java.sql.SQLException;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import genie.Connect;
import genie.OldQuery;
import genie.Util;

public class ClobDownloadServlet extends HttpServlet {

    public void doGet(HttpServletRequest req,HttpServletResponse res) throws ServletException,IOException {
    	int counter = 0;
    	HttpSession session = req.getSession();
    	Connect cn = (Connect) session.getAttribute("CN");

    	String fileName = req.getParameter("filename");
    	String table = req.getParameter("table");
    	String col = req.getParameter("col");
    	String key = req.getParameter("key");
    	
    	String pkName = cn.getPrimaryKeyName(table);
    	String conCols = cn.getConstraintCols(table, pkName);
    	
    	String condition = Util.buildCondition(conCols, key);
    	
//    	String sql = "SELECT " + col + " FROM " + table + " WHERE " + conCols + "='" + key +"'";
    	String sql = "SELECT " + col + " FROM " + table + " WHERE " + condition;
    	if (sql.endsWith(";")) sql = sql.substring(0, sql.length()-1);
    	sql = sql.replaceAll("&gt;",">").replace("&lt;","<");
    	
    	System.out.println(req.getRemoteAddr()+": " + sql +";");
    	
    	OldQuery q = new OldQuery(cn, sql, req);
    	ResultSet rs = q.getResultSet();
    	
    	// get table name
    	String tbl = null;
    	//String temp = sql.replaceAll("\n", " ").trim();
    	String temp=sql.replaceAll("[\n\r\t]", " ");
    	
    	int idx = temp.toUpperCase().indexOf(" FROM ");
    	if (idx >0) {
    		temp = temp.substring(idx + 6);
    		idx = temp.indexOf(" ");
    		if (idx > 0) temp = temp.substring(0, idx).trim();
    		
    		tbl = temp.trim();
    		
    		
    		idx = tbl.indexOf(" ");
    		if (idx > 0) tbl = tbl.substring(0, idx);
    		
    	}

    	String fileType = "txt";
    	int j = fileName.indexOf(".");
    	if (j >0) fileType = fileName.substring(j+1);
    	
    	res.setHeader("cache-control", "must-revalidate");
    	if (fileType.trim().equalsIgnoreCase("txt"))
    	{
    		res.setContentType( "text/plain" );
    	}
    	else if (fileType.trim().equalsIgnoreCase("doc"))
    	{
    		res.setContentType( "application/msword" );
    	}
    	else if (fileType.trim().equalsIgnoreCase("xls"))
    	{
    		res.setContentType( "application/vnd.ms-excel" );
    	}
    	else if (fileType.trim().equalsIgnoreCase("pdf"))
    	{
    		res.setContentType( "application/pdf" );
    	}
    	else if (fileType.trim().equalsIgnoreCase("ppt"))
    	{
    		res.setContentType( "application/ppt" );
    	}
    	else
    	{
    		res.setContentType( "application/octet-stream" );
    	}
    	
    	res.setHeader("Content-Disposition","attachment; filename=\""+fileName+"\"");
    	res.setHeader("cache-control", "no-cache");

    	
    	//Set the content header information
    	String contentDisposition = "attachment; filename=";
    	ServletOutputStream os = null;

    	ServletContext sc = getServletContext();
    	String mimetype = sc.getMimeType(fileName);

    	int length = contentDisposition.length() + fileName.length();
    	StringBuffer sb = new StringBuffer(length);
    	sb.append(contentDisposition).append(fileName);

    	res.setContentType(mimetype);
//    	response.setHeader("Content-Disposition", sb.toString());


    	boolean hasData = false;
    	
    	try {
	    	if (rs != null) hasData = rs.next();
	    	int colIdx = 0;
	    	for  (int i = 1; rs != null && i<= rs.getMetaData().getColumnCount(); i++){
	    		int colType = q.getColumnType(i);
	    		String val = q.getBlob(i);
	
	    		Clob blob1 = rs.getClob(i);
	    		InputStream in = new BufferedInputStream(blob1.getAsciiStream());
	    		os = res.getOutputStream();
	    		int b = -1;
	    		b = in.read();
	    		while(b != -1) {
	    		os.write(b);
	    		b = in.read();
	    		}
	
	    		os.flush();
	    		in.close();
	    		os.close();
	    	}
		} catch (SQLException e) {
			e.printStackTrace();
		}
    }
}
