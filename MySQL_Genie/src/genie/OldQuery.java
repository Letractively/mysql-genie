package genie;

import java.sql.Blob;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Date;
import java.util.StringTokenizer;

import javax.servlet.http.HttpServletRequest;

/**
 * Dynamic query class
 * This class makes database query upon creation and provides methods for data access 
 * 
 * @author spencer.hwang
 *
 */
public class OldQuery {

	Connect cn;
	Statement stmt;
	ResultSet rs;
	String originalQry;
	String targetQry;
	HttpServletRequest request;

	Date start = new Date();
	int elapsedTime;
	String message="";
	
	public OldQuery(Connect cn, String qry, HttpServletRequest request) {
		this.cn = cn;
		originalQry = qry;
		this.request = request;
		
	    Date start = new Date();
	    Connection conn = cn.getConnection();

		try {
			stmt = conn.createStatement();
			
			String q2 = qry;
//			if (q2.toLowerCase().indexOf("limit ")<0) q2 += " LIMIT 200";
			
			String targetQry = processQuery(q2);
			//System.out.println(targetQry);	
			rs = stmt.executeQuery(targetQry);	
		} catch (SQLException e) {
			message = e.getMessage();
			System.out.println(e.toString());
		}
	}
	
	public String getMessage() {
		return message;
	}
	
	public String processQuery(String q) {
		
		String orig = q;
		String cols = "";
		String theRest = "";
		
		String temp = q.toUpperCase();
		if (temp.startsWith("SELECT ")) q = q.substring(7);
		
		temp = q.toUpperCase();
		int idx = temp.indexOf("FROM ");
		if (idx > 0) {
			cols = q.substring(0, idx);
			theRest = q.substring(idx);
		} else {
			cols = q;
			theRest = "";
		}
		 
		cols = cols.trim();	
		cols = cols.replaceAll(" ", "");

		String newCols = null;		
		StringTokenizer st = new StringTokenizer(cols,",");
		idx = 0;
		while (st.hasMoreTokens()) {
			idx ++;
			String token = st.nextToken().trim();
			
			if (newCols==null) newCols = token;
			else newCols += ", " + token;
		}

		String newQry = "SELECT " + newCols + " " + theRest;
		System.out.println("newQry=" + newQry);
		return newQry;
	}
	
	public ResultSet getResultSet() {
		return rs;
	}
	
	public String getColumnLabel(int idx) {
		String colName;
		
		try{
			colName = rs.getMetaData().getColumnLabel(idx);
		} catch (SQLException e) {
			colName = e.getMessage(); 
		}

		return colName;
	}
	
	public String getValue(int idx) {
		String val="";
		try {
			int cType = getColumnType(idx);
			
			if (cType==2004) {	// BLOB
				val="BLOB";
				
				Blob blob = rs.getBlob(idx);
				if (blob==null) {
					val = null;
				} else {
					val = "BLOB size=" + blob.length();
				}

			} else
				val = rs.getString(idx);
		} catch (SQLException e) {
			val = e.getMessage();
			int cType = getColumnType(idx);
			System.err.print("Column type: " + cType);
		}
		
		if (val != null && val.endsWith(" 00:00:00.0")) val = val.substring(0, val.length()-11);
		
		return val;
	}

	public String getBlob(int idx) {
		String val="";
		try {
			int cType = getColumnType(idx);
			
			if (cType==2004) {	// BLOB
				val="BLOB";
				
				Blob blob = rs.getBlob(idx);
				if (blob==null) {
					val = null;
				} else {
					byte[] bdata = blob.getBytes(1, (int)blob.length());
					val = new String(bdata);
				}

			} else
				val = rs.getString(idx);
		} catch (SQLException e) {
			val = e.getMessage();
			int cType = getColumnType(idx);
			System.err.print("Column type: " + cType);
		}
		
//		if (val != null && val.endsWith(" 00:00:00.0")) val = val.substring(0, val.length()-11);
//		System.out.print("BLOB=" + val);
		return val;
	}

	// get value by column name
	public String getValue(String colName) throws SQLException {
		int idx = 1;
		
		for (int i=1; i <= rs.getMetaData().getColumnCount();i++) {
			String cname = getColumnLabel(i);
			if (colName.equalsIgnoreCase(cname)) {
				idx = i;
				break;
			}
		}
		
		return getValue(idx);
	}

	public void close() {
		try {
			if (rs!=null) rs.close();
			if (stmt!=null) stmt.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			//e.printStackTrace();
		}

		Date end = new Date();
	    elapsedTime = (int) (end.getTime() - start.getTime());
//	    if (!this.originalQry.endsWith("LIMIT 100000"))

	    //cn.addQueryHistory(originalQry);
	}

	public int getElapsedTime() {
		return this.elapsedTime;
	}
	
	public int getColumnType(int idx) {
		int colType = 0;
		try {
			colType = rs.getMetaData().getColumnType(idx);
		} catch (SQLException e) {
		}
		
		//System.out.println("getColumnType(" + idx + ")=" + colType);
		return colType;
	}

	public String getColumnTypeName(int idx) {
		String colTypeName = "";
		try {
			colTypeName = rs.getMetaData().getColumnTypeName(idx);
		} catch (SQLException e) {
		}
		
		//System.out.println("getColumnType(" + idx + ")=" + colType);
		return colTypeName;
	}
}
