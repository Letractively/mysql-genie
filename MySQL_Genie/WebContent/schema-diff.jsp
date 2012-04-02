<%@ page language="java" 
	import="java.util.*" 
	import="genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"	
%>

<%

	Connect cn = (Connect) session.getAttribute("CN");
	// if connected, redirect to home
	if (cn==null || !cn.isConnected()) {
		response.sendRedirect("login.jsp");
		return;
	}


	String url = request.getParameter("url");
	String username = request.getParameter("username");
	String password = request.getParameter("password");
	
	Connect cn2 = new Connect(url, username, password, request.getRemoteAddr(), false);	
	
	boolean connected = cn2.isConnected();
	
	if (connected) {
		session.setAttribute("CN2", cn2);
	}
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
    <title>Schema Diff - Genie</title>
    <link rel='stylesheet' type='text/css' href='css/style.css'> 
    <link rel='stylesheet' type='text/css' href='css/slideshow.css'> 
	<link rel="icon" type="image/png" href="image/Genie-icon.png">
    
    <script src="script/jquery.js" type="text/javascript"></script>
    <script type="text/javascript">
    var to2;
    
    function startCompareRoutine() {
    	$("#comparisonProgress").html("");
    	
    	checkProgress();
    	$("#comparisonResult").html("Comparing...");
		$("#comparisonResult").append("<div id='wait'><img src='image/loading.gif'/></div>");

		$.ajax({
			type: 'POST',
			url: "ajax/compare-behind.jsp",
			data: $("#form0").serialize(),
			success: function(data){
				$("#comparisonResult").html(data);
				$("#wait").remove();
				checkProgress();
				setReady();
			}
		});	
    	
    }    
    
    function checkProgress() {
    	clearTimeout(to2);
    	var current = $("#comparisonProgress").html();
		$.ajax({
			type: 'POST',
			url: "ajax/compare-progress.jsp",
			success: function(data){
				if (current != data) {
	    			$("#comparisonProgress").html(data);
				}
				
				if (data.indexOf("Finished") == 0)
					clearTimeout(to2);
				else
					to2 = setTimeout("checkProgress()",1000);
			}
		});	    	
    }
    
    function startCompare() {
    	$("#startButton").attr("disabled", true);
    	$("#stopButton").attr("disabled", false);
    	startCompareRoutine();
    }
    
    function stopCompare() {
    	
    	clearTimeout(to2);
		$.ajax({
			type: 'POST',
			url: "ajax/cancel-compare.jsp",
			data: $("#form0").serialize(),
			success: function(data){
		    	setReady();
			}
		});	    	

    }
    
    function setReady() {
    	$("#startButton").attr("disabled", false);
    	$("#stopButton").attr("disabled", true);
    }
    
    function showDivA() {
    	$("#divA").show();
    	$("#divB").hide();
    }

    function showDivB() {
    	$("#divB").show();
    	$("#divA").hide();
    }

    function setReady2() {
    	$("#startButton2").attr("disabled", false);
    	$("#stopButton2").attr("disabled", true);
    }
    
    function startCompare2() {
    	$("#startButton2").attr("disabled", true);
    	$("#stopButton2").attr("disabled", false);
    	startCompareRoutine2();
    }
    
    function stopCompare2() {
    	
    	clearTimeout(to2);
		$.ajax({
			type: 'POST',
			url: "ajax/cancel-compare.jsp",
			data: $("#form0").serialize(),
			success: function(data){
		    	setReady2();
			}
		});	    	

    }    
    
    function startCompareRoutine2() {
    	$("#comparisonResult").html("Comparing...");
		$("#comparisonResult").append("<div id='wait'><img src='image/loading.gif'/></div>");

		$.ajax({
			type: 'POST',
			url: "ajax/compare-behind.jsp",
			data: $("#form2").serialize(),
			success: function(data){
				$("#comparisonResult").html(data);
				$("#wait").remove();
				setReady2();
			}
		});	
    	
    }      

    </script>
  </head>
  
<body>

<%
	if (!connected) {
%>
	<b>Sorry, Genie could not connect to the database.</b><br/>
	Message: <%= cn.getMessage() %>
	<br/><br/>
	<br/><br/>
	<a href="Javascript:window.close()">Close</a>
<%	
		return;
	}
%>

<h2><img src="image/diff.jpg" align="bottom"/> Schema Diff</h2>

<b>
Schema 1: <%= cn.getUrlString() %>
<br/>
Schema 2: <%= cn2.getUrlString() %>
</b><br/><br/>


<div id="divA">
<a href="Javascript:showDivB();">Compare Data By Query</a>

<form name="form0" id="form0">
<table style="margin-left: 40px;">
<tr>
	<td>Object</td>
	<td>
		<input name="object" type="radio" value="T" checked>Table
		<input name="object" type="radio" value="V">View
<!-- 		<input name="object" type="radio" value="S">Synonym
 -->		<input name="object" type="radio" value="TR">Trigger 
		<input name="object" type="radio" value="P">Program
	</td>
</tr>
<tr>
	<td>Include</td>
	<td>
		<input name="incl">
	</td>
</tr>
<tr>
	<td>Exclude</td>
	<td>
		<input name="excl">
	</td>
</tr>
<tr>
	<td colspan=2>
		<input id="startButton" type="button" value="Start Compare" onClick="javascript:startCompare()">
		<input id="stopButton" type="button" value="Stop" disabled="true"  onClick="javascript:stopCompare()">
	</td>
</tr>
</table>
</form>

<br/>
<div id="progressDiv" style="margin-left: 40px; border: 1px solid #D9D9D9; width: 400px; height: 200px; overflow: auto;">
	<div id="comparisonProgress"></div>
</div>

</div>

<div id="divB" style="display: none;">
<a href="Javascript:showDivA();">Compare Schema</a>
<form name="form1" id="form2">
<table style="margin-left: 40px;">
<tr>
	<td>Query statement<br/>
		<input name="object" type="hidden" value="S">
		<textarea id="text_sql" name="text_sql" rows=5 cols=60></textarea>
	</td>
</tr>
<tr>
	<td colspan=2>
		<input id="startButton2" type="button" value="Start Compare" onClick="javascript:startCompare2()">
		<input id="stopButton2" type="button" value="Stop" disabled="true"  onClick="javascript:stopCompare2()">
	</td>
</tr>
</table>
</form>
</div>


<br/><br/>

<div id="comparisonResult">
</div>




<%
%>
	
</body>
</html>
