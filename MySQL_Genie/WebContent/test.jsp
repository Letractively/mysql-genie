<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="java.sql.*" 
	import="genie.Connect" 
	pageEncoding="ISO-8859-1"
%>

<%!
	public String processGenie(String q) {
		String cols = "";
		String theRest = "";
		
		String temp = q.toUpperCase();
		if (temp.startsWith("SELECT ")) q = q.substring(7);
		
		temp = q.toUpperCase();
		int idx = temp.indexOf("FROM ");
		if (idx > 0) {
			cols = q.substring(0, idx);
			theRest = q.substring(idx);
		}
		cols = cols.trim();		
		System.out.println("cols=" + cols);

		String newCols = null;		
		StringTokenizer st = new StringTokenizer(cols,",");
		while (st.hasMoreTokens()) {
			String token = st.nextToken().trim();
			
			System.out.println("[" + token + "]");
			if (token.startsWith("genie(") && token.endsWith(")")) {
				token = genie(token);
			}
			
			if (newCols==null) newCols = token;
			else newCols += ", " + token;
		}

		return "SELECT " + newCols + " " + theRest;
	}
	
	public String genie(String src) {
		String temp = src.substring(6,src.length()-1).trim();
		
		StringTokenizer st = new StringTokenizer(temp, "->");
		
		String srcCol = st.nextToken();
		String target = st.nextToken();
		
		int idx = target.lastIndexOf(".");
		String table = target.substring(0, idx);
		String targetCol = target.substring(idx+1);
	
		return "(SELECT " + targetCol + " FROM " + table + " WHERE " + srcCol + "=A." + srcCol + " LIMIT 1) AS " + targetCol;
	}
	
	
%>


<%
	int counter = 0;
	String message = "";
	String sql = request.getParameter("sql");
	String submit = request.getParameter("submit");
	
	Connect cn = (Connect) session.getAttribute("CN");
	Connection conn = cn.getConnection();


%>

cn.genie("10016", "CATEGORY", prm_disp, cat_code) = <%= cn.genie("10016", "CATEGORY", "prm_disp", "cat_code") %>
<br/>
cn.genie("10056", "CATEGORY", prm_disp, cat_code) = <%= cn.genie("10056", "CATEGORY", "prm_disp", "cat_code") %>

cn.genie("10016", "CATEGORY.prm_disp") = <%= cn.genie("10016", "CATEGORY.prm_disp") %>
<br/>
cn.genie("10056", "CATEGORY.prm_disp") = <%= cn.genie("10056", "CATEGORY.prm_disp") %>

<br/>
genie '<%= processGenie("select city_code, genie(city_code->im.CITY.name), genie(city_code->im.CITY.state)  from imp_2.LISTING") %>'
