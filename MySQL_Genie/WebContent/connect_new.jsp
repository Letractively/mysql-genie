<%@ page language="java" 
	import="java.util.*" 
	import="genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"	
%>

<%
	Connect cn = (Connect) session.getAttribute("CN");
	// if connected, redirect to home
	if (cn!=null && cn.isConnected()) {
		response.sendRedirect("index.jsp");
		return;
	}

	String url = request.getParameter("url");
	String username = request.getParameter("username");
	String password = request.getParameter("password");
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
    <title>Genie</title>
    <link rel='stylesheet' type='text/css' href='css/style.css'> 
    <link rel='stylesheet' type='text/css' href='css/slideshow.css'> 
	<link rel="icon" type="image/png" href="image/Genie-icon.png">
    
    <script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
    
<script type="text/javascript">
$(document).ready(function(){
//	$("#loadingDiv").append("<div id='wait'><img src='image/loading_big.gif'/></div>");
	$.ajax({
		type: 'POST',
		url: "connect_behind.jsp?",
		data: $("#form0").serialize(),
		success: function(data){
			$("#loadingDiv").append(data);
//			$("#wait").remove();
			if (data.indexOf("Connected.") != -1) {
				$(location).attr('href',"index.jsp");
			} else {
				stopShow();
			}
		},
        error:function (jqXHR, textStatus, errorThrown){
        	alert(jqXHR.status + " " + errorThrown);
        }  
	});	
})

function slideSwitch() {
    var $active = $('#slideshow IMG.active');

    if ( $active.length == 0 ) $active = $('#slideshow IMG:last');

    var $next =  $active.next().length ? $active.next()
        : $('#slideshow IMG:first');

    $active.addClass('last-active');

    $next.css({opacity: 0.0})
        .addClass('active')
        .animate({opacity: 1.0}, 1000, function() {
            $active.removeClass('active last-active');
        });
}

$(function() {
    setInterval( "slideSwitch()", 2000 );
});

function stopShow() {
	$("#slideshow").html('');
	$("#waiting").hide();
}

</script>
    
  </head>
  
  <body>
  
  <form id="form0" name="form0">
  	<input name="url" type="hidden" value="<%= url %>">
  	<input name="username" type="hidden" value="<%= username %>">
  	<input name="password" type="hidden" value="<%= password %>">
  </form>
  
  <img src="image/genie2.jpg"/>
    <h2>Connecting &amp; Loading Database Objects...</h2>

	<div id="loadingDiv"></div>

	<br/>
	Genie is loading data dictionary.
	- Tables, Comments, Constraints, Primary &amp; Foreign keys.
	
<div id="slideshow">
    <img src="image/nature1.jpg" alt="" class="active" />
    <img src="image/nature2.jpg" alt=""/>
    <img src="image/nature3.jpg" alt=""/>
    <img src="image/nature4.jpg" alt=""/>
    <img src="image/nature5.jpg" alt=""/>
</div>
<img id="waiting" src="image/waiting_big.gif" class="waitontop">  
	
  </body>
</html>
