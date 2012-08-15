<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%--

	public String 

--%>


<%
Connect cn = (Connect) session.getAttribute("CN");

String table = request.getParameter("tname");
String owner = request.getParameter("owner");

// incase owner is null & table has owner info
if (owner==null && table!=null && table.indexOf(".")>0) {
	int idx = table.indexOf(".");
	owner = table.substring(0, idx);
	table = table.substring(idx+1);
}

System.out.println("owner=" + owner);

//String catalog = null;
String tname = table;
int idx = table.indexOf(".");
/* 	if (idx>0) {
	catalog = table.substring(0, idx);
	tname = table.substring(idx+1);
}
if (catalog==null) catalog = cn.getSchemaName();
*/
if (owner==null) owner = cn.getSchemaName();

	String pkName = cn.getPrimaryKeyName(tname);
ArrayList<String> pk = cn.getPrimaryKeys(owner, tname);
if (pkName == null && owner != null) pkName = cn.getPrimaryKeyName(owner, tname);

String pkCols = cn.getConstraintCols(owner, pkName);
if (pkName != null && pkCols.equals(""))
	pkCols = cn.getConstraintCols(owner, pkName);

List<ForeignKey> fks = cn.getForeignKeys(tname);
if (owner != null) fks = cn.getForeignKeys(owner, tname);

List<String> refTabs = cn.getReferencedTables(tname);

List<TableCol> list = cn.getTableDetail(owner, tname);	
%>


<html>
<head> 
	<title>Genie - ERD</title>
    <script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
    <script src="script/data-methods.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>

    <link rel='stylesheet' type='text/css' href='css/style.css?<%= Util.getScriptionVersion() %>'>
	<link rel="icon" type="image/png" href="image/Genie-icon.png">

<style>
text
{
    pointer-events: none;
}
</style>

</head> 

<body>

<img src="image/data-link.png" align="middle"/>
<%= cn.getUrlString() %>

<br/>

<h3>ERD</h3>

<?xml version="1.0" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" 
  "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="1600" height="1400">
  <desc>ERD for <%= tname %></desc>

  <script type="application/ecmascript"> <![CDATA[
    function obj_click(evt, tname) {
      var circle = evt.target;
      var currentRadius = circle.getAttribute("r");
      
      //alert(tname);
      window.location="erd_svg.jsp?tname=" + tname;
      
    }

    function obj_over(evt) {
      var circle = evt.target;
      circle.setAttribute("fill", "yellow");
    }

    function obj_out(evt) {
      var circle = evt.target;
      circle.setAttribute("fill", "rgb(200,200,200)");
    }
    
    function qry_over(evt) {
      var img = evt.target;
      img.setAttribute("width", "20");
      img.setAttribute("height", "20");
    }

    function qry_out(evt) {
      var img = evt.target;
      img.setAttribute("width", "16");
      img.setAttribute("height", "16");
    }

    function qry(evt, tname) {
      $("#sql").val("SELECT * FROM " + tname);
      $("#form_qry").submit();
    }
  ]]> </script>


<%
	int cx = 120;
	int cy = 250;
	int cr = 80;
%>

  <!-- Main table -->

<% 
HashSet <String> hsTable = new HashSet<String>();

int seq=1;
int radius = 80;
for (ForeignKey rec: fks) {
	if (hsTable.contains(rec.rTableName)) 
		continue;
	else
		hsTable.add(rec.rTableName);
		
	List<TableCol> list1 = cn.getTableDetail(rec.rOwner, rec.rTableName);
	ArrayList<String> pk1 = cn.getPrimaryKeys(rec.rOwner, rec.rTableName);
	
	int x = seq * 170 - 50;
	int y = 40;
%>

  <linex x1="<%= cx %>" y1="<%= cy %>" x2="<%= x %>" y2="<%= y + 50 %>" style="stroke:rgb(255,0,0);stroke-width:2"/>  
  <line x1="<%= x %>" y1="<%= y + 80 %>" x2="<%= x %>" y2="<%= y + 50 %>" style="stroke:rgb(255,0,0);stroke-width:2"/>  
  
  <rect onclick="obj_click(evt, '<%= rec.rTableName %>')" onmouseover="obj_over(evt)" onmouseout="obj_out(evt)" x="<%= x - 80 %>" y="<%= y - 30 %>" rx="20" ry="20" width="160" height="80" fill="rgb(200,200,200)" stroke="black" stroke-width="2"/>
  <text onclick="obj_click(evt, '<%= rec.rTableName %>')" x="<%= x %>" y="<%= y %>" font-family="Arial" font-size="12" text-anchor="middle" fill="black"><%= rec.rTableName %></text>
  <text onclick="obj_click(evt, '<%= rec.rTableName %>')" x="<%= x %>" y="<%= y + 15 %>" font-family="Arial" font-size="12" text-anchor="middle" fill="rgb(150,50,50)"><%= cn.getTableRowCount(rec.rTableName) %></text>
  <image onmouseover="qry_over(evt)" onmouseout="qry_out(evt)" onclick="qry(evt, '<%= rec.rTableName %>')" x="<%= x - 8 %>" y="<%= y + 20 %>" width="16" height="16" preserveAspectRatio="none" xlink:href="image/icon_query.png"></image>
  <line x1="<%= x %>" y1="<%= 90 %>" x2="<%= x - 5 %>" y2="<%= 100 %>" style="stroke:rgb(255,0,0);stroke-width:2"/>  
  <line x1="<%= x %>" y1="<%= 90 %>" x2="<%= x + 5 %>" y2="<%= 100 %>" style="stroke:rgb(255,0,0);stroke-width:2"/>  
  
<%
	seq++;
}
if (seq > 1) {
%>
 
  <line x1="<%= 120 %>" y1="<%= 120 %>" x2="<%= (seq-1) * 170 - 50 %>" y2="<%= 120 %>" style="stroke:rgb(255,0,0);stroke-width:2"/>  
  <line x1="<%= cx %>" y1="<%= 120 %>" x2="<%= cx %>" y2="<%= cy - cr %>" style="stroke:rgb(255,0,0);stroke-width:2"/>  
  <line x1="<%= cx %>" y1="<%= 90 %>" x2="<%= cx - 5 %>" y2="<%= 100 %>" style="stroke:rgb(255,0,0);stroke-width:2"/>  
  <line x1="<%= cx %>" y1="<%= 90 %>" x2="<%= cx + 5 %>" y2="<%= 100 %>" style="stroke:rgb(255,0,0);stroke-width:2"/>  
<%
}

seq = 1;
int cnt2 = 1;
int y = 450;
for (String tbl: refTabs) {
	String cnt = cn.getTableRowCount(tbl);
//	if (cnt.equals("0")) continue;

	if (seq > 5) {
		seq = 1;
		y = y + 100;
	}
	int x = seq * 170 - 50;
	
	if (cnt2 <=5) {
%>
  <line x1="<%= x %>" y1="<%= y - 60 %>" x2="<%= x %>" y2="<%= y -30 %>" style="stroke:rgb(0,0,255);stroke-width:2"/>  
<%  } else { %>
  <line x1="<%= x %>" y1="<%= y - 50 %>" x2="<%= x %>" y2="<%= y -30 %>" style="stroke:rgb(0,0,255);stroke-width:2"/>  
<%  } %>

  <rect onclick="obj_click(evt, '<%= tbl %>')" onmouseover="obj_over(evt)" onmouseout="obj_out(evt)" x="<%= x - 80 %>" y="<%= y - 30 %>" rx="20" ry="20" width="160" height="80" fill="rgb(200,200,200)" stroke="black" stroke-width="2"/>
  <text onclick="obj_click(evt, '<%= tbl %>')" x="<%= x %>" y="<%= y %>" font-family="Arial" font-size="10" text-anchor="middle" fill="black"><%= tbl %></text>
  <text onclick="obj_click(evt, '<%= tbl %>')" x="<%= x %>" y="<%= y + 15 %>" font-family="Arial" font-size="12" text-anchor="middle" fill="rgb(150,50,50)"><%= cn.getTableRowCount(tbl) %></text>
  <image onmouseover="qry_over(evt)" onmouseout="qry_out(evt)" onclick="qry(evt, '<%= tbl %>')" x="<%= x - 8 %>" y="<%= y + 20 %>" width="16" height="16" preserveAspectRatio="none" xlink:href="image/icon_query.png"></image>

<%
	seq++;
	cnt2++;
}
if (cnt2 > 1) {
	if (cnt2 > 5) seq = 6;
%>
  <line x1="<%= 120 %>" y1="<%= 390 %>" x2="<%= (seq-1) * 170 - 50 %>" y2="<%= 390 %>" style="stroke:rgb(0,0,255);stroke-width:2"/>  
  <line x1="<%= cx %>" y1="<%= 390 %>" x2="<%= cx %>" y2="<%= cy + cr %>" style="stroke:rgb(0,0,255);stroke-width:2"/>  
  <line x1="<%= cx %>" y1="<%= 330 %>" x2="<%= cx - 5 %>" y2="<%= 340 %>" style="stroke:rgb(0,0,255);stroke-width:2"/>  
  <line x1="<%= cx %>" y1="<%= 330 %>" x2="<%= cx + 5 %>" y2="<%= 340 %>" style="stroke:rgb(0,0,255);stroke-width:2"/>  
<%
}
%>

  <circle cx="<%= cx %>" cy="<%= cy %>" r="<%= cr %>" fill="yellow" stroke="black" stroke-width="2"/>
  <text x="<%= cx %>" y="<%= cy + 5 %>" font-family="Arial" font-size="12" text-anchor="middle" fill="black"><%= tname %></text>
  <text x="<%= cx %>" y="<%= cy + 20 %>" font-family="Arial" font-size="12" text-anchor="middle" fill="rgb(150,50,50)"><%= cn.getTableRowCount(tname) %></text>
  <image onclick="qry(evt, '<%= tname %>')" x="<%= cx - 10 %>" y="<%= cy + 30 %>" width="32" height="32" preserveAspectRatio="none" xlink:href="image/icon_query.png"></image>


</svg>

<form id="form_qry" target="_blank" action="query.jsp" method="post">
<input id="sql" name="sql" type="hidden">
<input name="norun" type="hidden" value="y">
</form>

<script type="text/javascript">

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', '<%= Util.trackingId() %>']);
  _gaq.push(['_trackPageview']);

  _gaq.push(['_trackEvent', 'Erd2', '<%= table %>']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

</script>

</body>
</html>
