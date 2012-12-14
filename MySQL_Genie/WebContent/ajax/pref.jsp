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
%>

<form id="form0" name="form0">
<table>
<%-- <tr>
	<td>Query Max Rows</td>
	<td><input id="qry_rows" name="qry_rows" size="10" value="<%= cn.QRY_ROWS %>"> (MAX = <%= Def.MAX_ROWS %>)</td>
</tr>
 --%><tr>
	<td>&nbsp;</td>
	<td>
		<input id="saveButton" type="button" value="Save" onclick="savePref()">
	</td>
</tr>
</table>

</form>

<script type="text/javascript">
<!--
function savePref() {
	var val = $("#qry_rows").val();
	//alert(val);

	$.ajax({
		type: 'POST',
		url: "ajax/save-pref.jsp",
		data: $("#form0").serialize(),
		success: function(data){
			//$("#qry_rows").val('200');
		},
        error:function (jqXHR, textStatus, errorThrown){
            alert(jqXHR.status + " " + errorThrown);
        }  
	});	
	
	
}
//-->
</script>
