package genie;

import java.sql.Blob;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashSet;
import java.util.Hashtable;
import java.util.List;
import java.util.StringTokenizer;

import javax.servlet.http.HttpServletRequest;


/**
 * Dynamic query class
 * This class makes database query upon creation and provides methods for data access 
 * 
 * @author spencer.hwang
 *
 */
public class Query {

	Connect cn;
	Statement stmt;
	ResultSet rs;
	String originalQry;
	String targetQry;
	QueryData qData;

	Date start = new Date();
	int elapsedTime;
	String message="";
	int currentRow = 0;

	int sortOrder[] = new int[1000];
	boolean hideRow[] = new boolean[1000];
	boolean isError = false;
	
	public Query(Connect cn, String qry) {
		this.cn = cn;
		originalQry = qry;
		
	    Date start = new Date();
	    Connection conn = cn.getConnection();

		try {
			stmt = conn.createStatement();
			
			String q2 = qry;
//			if (q2.toLowerCase().indexOf("limit ")<0) q2 += " LIMIT 200";
			
			String targetQry = processQuery(q2);
//			System.out.println("NEW QUERY: " + targetQry);	
			rs = stmt.executeQuery(targetQry);
			
			qData = new QueryData();
			qData.setColumns(rs);
			qData.setData(rs);

			for (int i=0; i<1000; i++) {
				sortOrder[i] = i;
				hideRow[i] = false;
			}

			rs.close();
			stmt.close();

		    cn.addQueryHistory(originalQry);

		} catch (SQLException e) {
			message = e.getMessage();
			isError = true;
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
//		cols = cols.replaceAll(" ", "");

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
//		System.out.println("newQry=" + newQry);
		return newQry;
	}

	public int getElapsedTime() {
		return this.elapsedTime;
	}
	
	public int getColumnCount() {
		return qData.columns.size();
	}
	
	public String getColumnLabel(int idx) {
		if (idx <0 || idx > qData.columns.size()-1) {
			return "Out of Index " + idx + " : " + qData.columns.size();
		}

		return qData.columns.get(idx).columnLabel;
	}
	
	public int getColumnType(int idx) {
		if (idx <0 || idx > qData.columns.size()-1) {
			return -1;
		}
		return qData.columns.get(idx).columnType;
	}

	public String getColumnTypeName(int idx) {
		if (idx <0 || idx > qData.columns.size()-1) {
			return "";
		}
		return qData.columns.get(idx).columnTypeName;
	}

	public boolean hasData() {
		return (qData != null && qData.columns != null && qData.rows.size() > 0);
	}
	
	public boolean hasMetaData() {
		return (qData != null && qData.columns != null && qData.columns.size() > 0);
	}
	
	public String getValue(int idx) {
		
		if (qData.rows.size() <= 0) return null;
		
		if (idx <0 || idx > qData.columns.size()-1) {
			return "Out of Index " + idx + " : " + qData.columns.size();
		}
		
		int rowId = sortOrder[currentRow];
		return qData.rows.get(rowId).row.get(idx).value;
	}
	
	public String getValue(String colName) {
		if (qData==null) return"";
		int colIndex = qData.getColumnIndex(colName);
		
		return getValue(colIndex);
	}

	public void rewind(int linePerPage, int pageNo) {
		int idx = 0;
		if (pageNo == 1)
			idx = -1;
		else
			idx = linePerPage * (pageNo-1) -1;
		
		currentRow = -1;
		for (int i=0; i <= idx; i++) next();
		
//		System.out.println("currentRow=" + currentRow);
	}
	
	public boolean next() {
		if (currentRow+1 >= qData.rows.size()) {
			currentRow = 0;
			return false;
		}

		currentRow ++;
		if (hideRow[sortOrder[currentRow]]) return next();
		return true;
	}
	
	public void sort(String col, String direction) {
		int newOrder[] = new int[1000];

		boolean isReverse = direction.equals("1");
		
		for (int i=0; i<1000; i++) newOrder[i] = 0;
		
		if (qData==null) {
			System.err.println("qData is null");
			return;
		}
		int colIdx = qData.getColumnIndex(col);

		if (colIdx < 0) {
			System.err.println("column " + col + " not found");
			return;
		}

		int size = qData.rows.size();
		
		// copy new order
		for (int i=0;i<size;i++) newOrder[i] = sortOrder[i];
		
		for (int i=0;i<size-1;i++) {
			for (int j=i+1;j<size;j++) {

				DataDef v1 = qData.rows.get(newOrder[i]).row.get(colIdx);
				DataDef v2 = qData.rows.get(newOrder[j]).row.get(colIdx);
			
				String typeName = qData.columns.get(colIdx).columnTypeName;
				
				boolean switchPos = false;
				if (v1.isNull && v2.isNull) {
					switchPos = false;
				} else if (v1.isNull) {
					switchPos = true;
				} else if (v2.isNull) {
					switchPos = false;
				} else if (v1.compareTo(v2, typeName) <= 0) {
					switchPos = false;
				} else {
					switchPos = true;
				}
				
				if (isReverse) {
					switchPos = !switchPos;
				}
				
				if (switchPos) {
					int temp = newOrder[i];
					newOrder[i] = newOrder[j];
					newOrder[j] = temp;
				}
				
				//System.out.println("v1=" + v1.value + " v2=" + v2.value);
			}
			//System.out.println(i + " -> " + (size - i -1));
		}

		for (int i=0;i<size;i++) sortOrder[i] = newOrder[i];

	}

/*	
	public void _sort(String col, String direction) {
		int newOrder[] = new int[1000];

		boolean isReverse = direction.equals("1");
		
		for (int i=0; i<1000; i++) newOrder[i] = 0;
		
		if (qData==null) {
			System.err.println("qData is null");
			return;
		}
		int colIdx = qData.getColumnIndex(col);

		if (colIdx < 0) {
			System.err.println("column " + col + " not found");
			return;
		}
		
		int size = qData.rows.size();
		for (int i=0;i<size-1;i++) {
			for (int j=i+1;j<size;j++) {

				DataDef v1 = qData.rows.get(i).row.get(colIdx);
				DataDef v2 = qData.rows.get(j).row.get(colIdx);
			
				String typeName = qData.columns.get(colIdx).columnTypeName;
				
				int t;
				if (v1.isNull) {
					t = i;
				} else if (v2.isNull) {
					t = j;
				} else if (v1.compareTo(v2, typeName) > 0) {
					t = i;
				} else {
					t = j;
				}
				
				if (isReverse) {
					t = (t==i)?j:i;
				}
				
				newOrder[t] ++;
				
				//System.out.println("v1=" + v1.value + " v2=" + v2.value);
			}
			//System.out.println(i + " -> " + (size - i -1));
		}

		// copy new Order to sortOrder
		for (int i=0;i<size;i++)
			sortOrder[newOrder[i]] = i;

		//System.out.println("new order=");
//		for (int i=0;i<size;i++)
//			System.out.println(sortOrder[i]);
		
	}
*/
	
	public List<String> getFilterList(String col) {

		int colIdx = qData.getColumnIndex(col);
		
		HashSet<String> set = new HashSet<String>();
		int size = qData.rows.size();
		for (int i=0;i<size;i++) {
			String value = qData.rows.get(i).row.get(colIdx).value;
			if (value != null)
			set.add(value);
		}

		List<String> list = new ArrayList<String>(set);
		Collections.sort(list);
		return list;
	}
	
	public List<FilterRecord> getFilterListWithCount(String col) {

		int colIdx = qData.getColumnIndex(col);
		
		HashSet<String> set = new HashSet<String>();
		Hashtable<String,String> counts = new Hashtable<String, String>(); 
		int size = qData.rows.size();
		for (int i=0;i<size;i++) {
			String value = qData.rows.get(i).row.get(colIdx).value;
			if (value != null)
			if (!set.contains(value)) {
				set.add(value);
				counts.put(value, "1");
			} else {
				String temp = counts.get(value);
				temp = "" + (Integer.parseInt(temp) + 1);
				counts.put(value, temp);
			}
		}

		List<String> list = new ArrayList<String>(set);
		Collections.sort(list);
		
//		for (int i=0; i < list.size(); i++) {
//			System.out.println(list.get(i) + " = " + counts.get(list.get(i)));
//		}
		List<FilterRecord> newList = new ArrayList<FilterRecord>();
		for (int i=0; i < list.size(); i++) {
			FilterRecord rec = new FilterRecord();
			rec.value = list.get(i);
			rec.count = Integer.parseInt(counts.get(list.get(i)));
			newList.add(rec);
		}
		
		return newList;
	}
	
	public void filter(String col, String val) {
		int colIdx = qData.getColumnIndex(col);
		int size = qData.rows.size();
		for (int i=0;i<size;i++) {
			DataDef v = qData.rows.get(i).row.get(colIdx);

			if (val.equals(v.value) || val.equals("")) 
				hideRow[i] = false;
			else
				hideRow[i] = true;
		}
	}

	public void search(String value) {
		
		int rowSize = qData.rows.size();
		int colSize = qData.columns.size();
		for (int i=0;i<rowSize;i++) {
			if (hideRow[i]) continue;

			hideRow[i] = true;
			for (int j=0;j<colSize;j++) {
				DataDef v = qData.rows.get(i).row.get(j);
				if (v.value != null && v.value.toLowerCase().contains(value.toLowerCase())) { 
					hideRow[i] = false;	// match found
				}
			}
		}
	}
	
	public void removeFilter() {
		for (int i=0; i<1000; i++) {
//			sortOrder[i] = i;
			hideRow[i] = false;
		}
	}

	public int getRecordCount() {
		return qData.rows.size();
	}

	public int getFilteredCount() {
		int cnt = 0;
		
		for (int i=0; i<qData.rows.size();i++) {
			if (!hideRow[i]) cnt++;
		}
		
		return cnt;
	}
	
	public int getTotalPage(int linesPerPage) {
		int res = (int) ((this.getFilteredCount()-1) / linesPerPage);
		
		return res + 1;
	}
	
	public boolean isError() {
		return this.isError;
	}
}
