<html xmlns="http://www.w3.org/1999/xhtml">
<head>

	<style type="text/css">
	 #box 
	 {
	 	width: 300px;
	 	height: 200px;
	 	background: red; 
	 }
	</style>
	<script type="text/javascript" src="http://code.jquery.com/jquery-1.7.min.js"></script>
	
<script type="text/javascript">
	$(function() {
		$('a').click(function() {
			$('#box').toggle(1000);
		});
	});
		
</script>
</head>

<body>
JQuery
	<div id="box"></div>
	<a href="#">Click me</a>
</body>
</html>