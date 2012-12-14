<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="chingoo.mysql.Connect" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%! 
	final int MAX_CACHE_LIST = 500;
	final int MAX_DISPLAY_LIST = 50;

	public String getNumRows (String numRows) {
		if (numRows==null) numRows = "";
		else {
			int n = Integer.parseInt(numRows);
			if (n < 1000) {
				numRows = numRows;
			} else if (n < 1000000) {
				numRows = Math.round(n /1000) + "K";
			} else {
				numRows = (Math.round(n /100000) / 10.0 )+ "M";
			}
		}
		return numRows;
	}

%>
<%
	Connect cn = (Connect) session.getAttribute("CN");
	String term = request.getParameter("term");
	String filter = term;
	
	String xterm = (String) session.getAttribute("xterm");
	ArrayList<String> xlist = (ArrayList<String>) session.getAttribute("xlist");
//System.out.println("xterm=" + xterm);
//System.out.println("xlist=" + xlist.size());
	
	String qry = "select LOWER(TABLE_NAME) from information_schema.TABLES WHERE table_type='BASE TABLE' AND table_schema='"+ cn.getSchemaName()+"' UNION " + 	
				"SELECT LOWER(TABLE_NAME) FROM INFORMATION_SCHEMA.VIEWS WHERE table_schema='"+ cn.getSchemaName()+"' UNION " +
				"SELECT LOWER(ROUTINE_NAME) FROM INFORMATION_SCHEMA.ROUTINES WHERE routine_schema	='"+cn.getSchemaName()+"' order by 1"; 	
	List<String[]> list = cn.query(qry, 10000, true);
	
	int totalCnt = list.size();
	int selectedCnt = 0;
	if (filter !=null) filter = filter.toLowerCase();
	List<String> res1 = null;
	
	res1 = new ArrayList<String>();
	if (xlist != null && term.startsWith(xterm) && xlist.size() < MAX_CACHE_LIST) {
		int cnt = 0;
		for (int i=0; i<xlist.size();i++) {
			if (xlist.get(i).contains(filter)) { 
				res1.add(xlist.get(i));
				cnt ++;
			}
			if (cnt >= MAX_CACHE_LIST) break; 
		}	
	} else {
		int cnt = 0;
		for (int i=0; i<list.size();i++) {
			if (list.get(i)[1].startsWith(filter)) { 
				res1.add(list.get(i)[1]);
				cnt ++;
			}
			if (cnt >= MAX_CACHE_LIST) break; 
		}	

		if (cnt < MAX_CACHE_LIST) {
			for (int i=0; i<list.size();i++) {
				if (!list.get(i)[1].startsWith(filter) && list.get(i)[1].contains(filter)) {
					res1.add(list.get(i)[1]);
					cnt ++;
				}
				if (cnt >= MAX_CACHE_LIST) break; 
			}	
		}
	}
	session.setAttribute("xterm", term);
	session.setAttribute("xlist", res1);
%>

[
<%	
for (int i=0; i<res1.size() && i < MAX_DISPLAY_LIST;i++) {
%>
<%=(i>0?",":"")%>{"value": "<%=res1.get(i)%>", "label": "<%=res1.get(i)%>", "desc": "<%= cn.getTableRowCount(res1.get(i).toUpperCase()) %>"} 
<% 
} 
%>
]

