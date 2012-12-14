<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="java.sql.*" 
	import="chingoo.mysql.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%
	Connect cn = (Connect) session.getAttribute("CN");


	String cookieName = "url";
	Cookie cookies [] = request.getCookies ();
	Cookie myCookie = null;
	if (cookies != null) {
		for (int i = 0; i < cookies.length; i++) {
			if (cookies [i].getName().equals (cookieName)) {
				myCookie = cookies[i];
				break;
			}
		}	
	}
	
	String cookieUrls = "";
	if (myCookie != null) cookieUrls = myCookie.getValue();
	
	// default login info
	String temp = cn.getUrlString();
	int x = temp.indexOf("@");
	String initJdbcUrl = temp.substring(x+1);
	String initUserName = temp.substring(0,x);
	
/* 	// get the last login from cookie
	if (cookieUrls != null && cookieUrls.length()>1) {
		StringTokenizer st = new StringTokenizer(cookieUrls);
	    if (st.hasMoreTokens()) {
	    	String token = st.nextToken();
	    	int idx = token.indexOf("@");
	    	initUserName = token.substring(0, idx);
	    	initJdbcUrl = token.substring(idx+1);
	    }
	}
	 */
%>

<script type="text/javascript">
function setLogin(jdbcUrl, userId) {
	$("#url").val(jdbcUrl);
	$("#username").val(userId);
}

</script>

To compare schema object, you need to connect to 2nd database.
<br/><br/>

	<form action="schema-diff.jsp" method="POST" target="_blank">
    <table border=0>
    <tr>
    	<td>Database URL</td>
    	<td><input size=60 name="url" id="url" value="<%= initJdbcUrl %>"/></td>
    </tr>
    <tr>
    	<td>User Name</td>
    	<td><input name="username" id="username" value="<%= initUserName %>"/></td>
    </tr>
    <tr>
    	<td>Password</td>
    	<td><input name="password" type="password"/></td>
    </tr>
    </table>
    <input type="submit" value="Connect"/>
	</form>

<%
	StringTokenizer st = new StringTokenizer(cookieUrls);
    while (st.hasMoreTokens()) {
    	String token = st.nextToken();
    	int idx = token.indexOf("@");
    	String userid = token.substring(0, idx);
    	String jdbcUrl = token.substring(idx+1);
%>
<a href="javascript:setLogin('<%= jdbcUrl %>', '<%= userid %>')"><%= token %></a>
<br/>

<%
	}
%>
	