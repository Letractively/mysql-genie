<%@ page language="java" 
	import="java.util.*" 
	import="genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>


<%
	session.removeAttribute("CN");

	String cookieName = "url";
	String email = "";
	Cookie cookies [] = request.getCookies ();
	Cookie myCookie = null;
	if (cookies != null) {
		for (int i = 0; i < cookies.length; i++) {
			if (cookies [i].getName().equals (cookieName)) {
				myCookie = cookies[i];
				break;
			}
		}	
		for (int i = 0; i < cookies.length; i++) {
			if (cookies [i].getName().equals ("email")) {
				email = cookies[i].getValue();
				break;
			}
		}	
	}
	
	String cookieUrls = "";
	if (myCookie != null) cookieUrls = myCookie.getValue();
	
	// default login info
	String initJdbcUrl = "jdbc:mysql://localhost:3306/test";
	String initUserName = "root";
	
	// get the last login from cookie
	if (cookieUrls != null && cookieUrls.length()>1) {
		StringTokenizer st = new StringTokenizer(cookieUrls);
	    if (st.hasMoreTokens()) {
	    	String token = st.nextToken();
	    	int idx = token.indexOf("@");
	    	initUserName = token.substring(0, idx);
	    	initJdbcUrl = token.substring(idx+1);
	    }
	}
	
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
    <title>Genie</title>
	<meta name="description" content="Genie is an open-source, web based MySQL database schema navigator." />
	<meta name="keywords" content="MySQL Web Database OpenSource JDBC" />
	<meta name="author" content="Spencer Hwang" />

    <link rel='stylesheet' type='text/css' href='css/style.css?<%= Util.getScriptionVersion() %>'> 
	<link rel="icon" type="image/png" href="image/Genie-icon.png">
    <script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
    <script type="text/javascript">
    	function setLogin(jdbcUrl, userId) {
    		$("#url").val(jdbcUrl);
    		$("#username").val(userId);
    	}
    </script>
  </head>
  
  <body>
  <img src="image/genie2.jpg"  title="Version <%= Util.getVersionDate() %>"/>
    <h2>Welcome to MySQL Genie.</h2>

<b>Connect to database</b>
	<form action="connect_new.jsp" method="POST">
    <table border=0>
    <tr>
    	<td>JDBC URL</td>
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
    <tr>
    	<td>Your Email</td>
    	<td><input name="email" id="email" value="<%= email %>"/> Genie will send you email.</td>
    </tr>
    </table>
    <input type="submit" value="Connect"/>
	</form>

<br/>


<div>

<%
	StringTokenizer st = new StringTokenizer(cookieUrls);
    while (st.hasMoreTokens()) {
    	String token = st.nextToken();
    	int idx = token.indexOf("@");
    	String userid = token.substring(0, idx);
    	String jdbcUrl = token.substring(idx+1);
%>
<a href="javascript:setLogin('<%= jdbcUrl %>', '<%= userid %>')"><%= token %></a>
<a href="remove-cookie.jsp?value=<%= token %>"><img border=0 src="image/clear.gif"></a>
<br/>

<%
	}
%>
</div>

  </body>
</html>
