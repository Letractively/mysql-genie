<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%!
	public String getCookie(HttpServletRequest request, String cookieName) {
		String value = null;
		
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
		
		if (myCookie != null) value = myCookie.getValue();		
		return value;
	}
%>

<%
	Connect cn = (Connect) session.getAttribute("CN");
	// if connected, redirect to home
	if (cn!=null && cn.isConnected()) {
		out.println("Connected.");
		return;
	}

	String url = request.getParameter("url");
	String username = request.getParameter("username");
	String password = request.getParameter("password");
	String email = request.getParameter("email");
	
	String ipAddress = Util.getIpAddress(request);
	
	cn = new Connect(url, username, password, ipAddress);
	cn.setUrl(request.getRequestURL().toString());
	cn.setUserAgent(request.getHeader("user-agent"));
	
	if (cn.isConnected()) {
		// you're connected.
		// assign the Connect object to session
		session.setAttribute("CN", cn);
		GenieManager.getInstance().addSession(cn);
	
		// get cookie
		String oldUrls = getCookie(request, "url");
		
		// set Cookie
		String newUrl = username + "@" + url;
		String newUrls = "";
		
		if (oldUrls != null) {
			oldUrls = oldUrls.replace(newUrl, "").trim();
			newUrls = newUrl + " " + oldUrls;
		} else
			newUrls = newUrl;
		
 		
		Cookie cookie = new Cookie ("url", newUrls);
		cookie.setMaxAge(365 * 24 * 60 * 60);
//		cookie.setPath("/");
		response.addCookie(cookie);
		
		if (email != null && email.length() > 2) {
			Cookie cookie2 = new Cookie ("email", email);
			cookie2.setMaxAge(365 * 24 * 60 * 60);
//			cookie.setPath("/");
			response.addCookie(cookie2);
			
			cn.setEmail(email);
		}

		// redirect to homepage
		out.println("Connected.");
		System.out.println("Connected.");
//		response.sendRedirect("ajax/connected.jsp");
		return;
	}
%>

	<b>Sorry, Genie could not connect to the database.</b>
	Message: <%= cn.getMessage() %>
	<br/><br/>
	
	<a href="javascript:history.back()">Try Again</a>
