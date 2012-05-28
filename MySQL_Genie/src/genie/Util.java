package genie;

import java.io.UnsupportedEncodingException;

import org.apache.commons.lang3.StringEscapeUtils;
import org.apache.commons.lang3.StringUtils;
import java.util.ArrayList;
import java.util.List;
import java.util.HashSet;
import java.util.Set;

/**
 * Utility class for Genie
 * 
 * @author spencer.hwang
 *
 */
public class Util {

	static int counter = 0;
	
	public static int countLines(String str) {
		String[] lines = str.split("\r\n|\r|\n");
		return lines.length;
	}
	
	public static int countMatches(String str, String value) {
		int count = StringUtils.countMatches(str, value);
		return count;
	}
	
	public static String buildCondition(String col, String key) {
		String res="1=1";
		
		if (key==null) key = "is null";
		
		if (key==null || col==null) return null;
//System.out.println("col= " + col);
//System.out.println("key= " + key);
		
		String[] cols = col.split(",");
		String[] keys = key.split("\\^");
		
		if (cols.length != keys.length) {
			
			//System.out.println(col + " " + key);
			//System.out.println(cols.length + " " + keys.length);
			return "ERROR";
		}
		
		for(int i =0; i < cols.length; i++) {
			
			if (keys[i].equals("is null"))
				res = res + " AND " + cols[i].trim() + " IS NULL";
			else if (keys[i].length()==10 && keys[i].substring(4,5).endsWith("-")) { // date 
				res = res + " AND " + cols[i].trim() + "= to_date('" + keys[i] + "','yyyy-mm-dd')";
			} else if (keys[i].length()==19 && keys[i].substring(4,5).endsWith("-")) { // date 
				res = res + " AND " + cols[i].trim() + "= to_date('" + keys[i] + "','yyyy-mm-dd hh24:mi:ss')";
			} else if (keys[i].length()==21 && keys[i].substring(4,5).endsWith("-")) { // date 
				res = res + " AND " + cols[i].trim() + "= to_date('" + keys[i].substring(0,19) + "','yyyy-mm-dd hh24:mi:ss')";
			} else {
				res = res + " AND " + cols[i].trim() + "='" + keys[i] + "'";
			}
		}
			
		return res.replace("1=1 AND ", "");
	}
	
	public static String escapeHtml(String str) {
		return StringEscapeUtils.escapeHtml3(str);
	}
	
	public static String encodeUrl(String str) throws UnsupportedEncodingException {
		if (str==null) return null;
		//return java.net.URLEncoder.encode(str, "ISO-8859-1");
		return java.net.URLEncoder.encode(str, "UTF-8");
	}
	
	public static String escapeQuote(String str) {
		return str.replaceAll("'", "''");
	}
	
	public static String getId() {
		counter++;
		
		return "" + counter;
	}
	
	public static boolean isNumberType(int typeId) {
		boolean res = false;
		
		int[] types = {2,3,4,5,7,8,-5};
		
		for (int i : types) {
			if (typeId == i) {
				res = true;
				break;
			}
		}

		return res;
	}

	
	public static List<String> getTables(String sql) {
		List<String> tables = new ArrayList<String>();
		Set<String> tbls = new HashSet<String>();
		
		
		String temp=sql.replaceAll("[\n\r\t]", " ");
		temp = temp.replaceAll(" from ", " FROM ");

		String froms[] = temp.split(" FROM ");
		
		for (int i=1; i < froms.length; i++) {
			String str = froms[i];
			//System.out.println(i + ": " + str);
			if (str.startsWith("(")) continue;
			
			int idx = str.indexOf(" WHERE ");
			if (idx > 0) str = str.substring(0, idx);

			//System.out.println("*** " + i + ": " + str);
			
			String a[] = str.split(",");
			for (int j=0; j<a.length; j++) {
				String tname = a[j].trim();
				int x = tname.indexOf(" ");
				if (x > 0) tname = tname.substring(0, x).trim();
				//System.out.println(j + "=" +tname);
				
				tbls.add(tname);
			}			
		}
		
		tables.addAll(tbls);
		
		return tables;
	}

	public static String getMainTable(String sql) {
		String tname = "";
		String temp=sql.replaceAll("[\n\r\t]", " ").toUpperCase();

		String froms[] = temp.split(" FROM ");
		
		for (int i=1; i < froms.length; i++) {
			String str = froms[i];
			//System.out.println(i + ": " + str);
			if (str.startsWith("(")) continue;
			
			int idx = str.indexOf(" WHERE ");
			if (idx > 0) str = str.substring(0, idx);

			//System.out.println("*** " + i + ": " + str);
			
			String a[] = str.split(",");
			for (int j=0; j<a.length; j++) {
				tname = a[j].trim();
				return tname;
			}			
		}
		
		return tname;
	}
	
	
	public static String getVersionDate() {
		return "May 28, 2012";
	}

	public static String getScriptionVersion() {
		return "20120528";
	}
}
