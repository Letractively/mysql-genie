	$.fn.showCol = function(col){
	    // Make sure col has value
	    if(!col){ col = 1; }
	    $('tr td:nth-child('+col+'), tr th:nth-child('+col+')', this).show();
	    return this;
	};	
	$.fn.hideCol = function(col){
	    // Make sure col has value
	    if(!col){ col = 1; }
	    $('tr td:nth-child('+col+'), tr th:nth-child('+col+')', this).hide();
	    return this;
	};		
	
	function hideColumn(id, col) {
		var tableId = 'table-'+ id;
		var cols = $("#hide-" + id).val();
		if (cols == "") cols = col;
		else cols += "," + col;
		
		$("#hide-"+id).val(cols);
		$('table#'+tableId).hideCol(col);
    }

	function showColumn(tableId, col) {
		$('table#'+tableId).showCol(col);
    }

	function loadData(id, showFK) {
		var sql = $("#sql-" + id).html();
		var divName = "div-" + id;
		
		var imgSrc = $("#img-" + id).attr("src");
		//alert(imgSrc);
		if (imgSrc.indexOf("plus") > 0) {
			$("#img-" + id).attr("src","image/minus.gif");
		} else {
			$("#img-" + id).attr("src","image/plus.gif");
			$("#" + divName).slideUp();
			return;
		}

		if ($("#" + divName).html().length > 10){
    		$("#" + divName).slideDown();
    		return;
    	}
		
		$("#sql").val(sql);
		$("#id").val(id);
		$("#pageNo").val("1");

		$("#showFK").val(showFK);
		$("#" + divName).hide();
		$.ajax({
			type: 'POST',
			url: "ajax/qry-simple.jsp",
			data: $("#form0").serialize(),
			success: function(data){
				$("#" + divName).html(data);
				setHighlight();
				$("#" + divName).slideDown();
			},
            error:function (jqXHR, textStatus, errorThrown){
            	alert(jqXHR.status + " " + errorThrown);
            }  
		});	
    	
	}

	function openQuery(id) {
		var sql = $("#sql-" + id).html();
		var divName = "div-" + id;
		//alert(sql);
		
		$("#sql").val(sql);
		document.form0.submit();
	}

    $(document).ready(function() {
    	setHighlight();
    });	    

    function showAllColumn() {
		$("table ").each(function() {
			var divName = $(this).attr('id');
			if (divName != null && divName.indexOf("table-")>=0) {
				showAllColumnTable(divName);
			}
		});
    }

    function showAllColumnTable(divName) {
   	 	var colCnt = numCol(divName);

   	    for (var col = 0; col < colCnt; col++) {
   	    	showColumn(divName, col+1);
   	    	var id = divName.substring(6);
   	    	$("#hide-"+id).val('');
   	    }
	}
    
	function hideNullColumn() {
		$("table ").each(function() {
			var divName = $(this).attr('id');
			if (divName != null && divName.indexOf("table-")>=0) {
				var id = divName.substring(6);
				hideNullColumnTable(id);
			}
		});
	}
	
    function hideNullColumnTable(id) {
    	var divName = id;
		if (divName.indexOf("table-")<0) divName = 'table-' + id;
    	var rowCount = $('#' + divName + ' tr').length;
    	
    	//if (rowCount > 2) return;
    	
   	    //var row = 1;
   	 	var hideCol = []; 
   	 	var colCnt = numCol(divName);
   	 	//alert(rowCount + "," +colCnt);
    	for (var col = 0; col < colCnt; col++) {
   	 		var nullValue = true;
       	 	for (var row=1; row<rowCount;row++) {
       	 		//console.log(divName);
	    		var value = $("#" + divName).children().children()[row].children[col].innerHTML;
    			if (value.indexOf(">null<")<=0) {
   				nullValue = false;
	    		}
   	    	}
   	    	if (nullValue) hideCol.push(col+1);
   	    }
   	    
   	 	for (var i = 0, l = hideCol.length; i < l; ++i) {
   	 		//alert('hide ' + hideCol[i] );
   	 		hideColumn(id, hideCol[i]);
   	    }
   	    
    }
    
    function numCol(table) {
        var maxColNum = 0;

        var i=0;
        var trs = $("#"+table).find("tr");

        for ( i=0; i<trs.length; i++ ) {
            maxColNum = Math.max(maxColNum, getColForTr(trs[i]));
        }

        return maxColNum;
    }
	
    function getColForTr(tr) {

        var tds = $(tr).find("td");

        var numCols = 0;

        var i=0;
        for ( i=0; i<tds.length; i++ ) {
            var span = $(tds[i]).attr("colspan");

            if ( span )
                numCols += parseInt(span);
            else {
                numCols++;
            }
        }
        return numCols;
    }

    function toggleFK() {
    	var img = $("#img-fk").attr("src"); 
    	//alert(img);
    	if (img.indexOf("minus") > 0) {
    		$("#img-fk").attr("src","image/plus.gif");
    		$('#div-fk').slideUp();
    	} else {
    		$("#img-fk").attr("src","image/minus.gif");
    		$('#div-fk').slideDown();
    	}
    }

    function toggleChild() {
    	var img = $("#img-child").attr("src"); 
    	//alert(img);
    	if (img.indexOf("minus") > 0) {
    		$("#img-child").attr("src","image/plus.gif");
    		$('#div-child').slideUp();
    	} else {
    		$("#img-child").attr("src","image/minus.gif");
    		$('#div-child').slideDown();
    	}

    	//$('#div-child').toggle();
    }

    function toggleText(arg1, arg2) {
    	$('#'+arg1).toggle();
    	$('#'+arg2).toggle();
    }
    
	function gotoPage(id, pageNo) {
		$("#pageNo").val(pageNo);

		reloadData(id);
	}
	    
	function reloadData(id) {
		var divName = "div-" + id;
		var sql = $("#sql-" + id).html();
		$("#sql").val(sql);
		$("#id").val(id);
		$("#sortColumn").val($("#sort-"+id).val());
		$("#sortDirection").val($("#sortdir-"+id).val());		

		//$('body').css('cursor', 'wait'); 
		$.ajax({
			type: 'POST',
			url: "ajax/qry-simple.jsp",
			data: $("#form0").serialize(),
			success: function(data){
				$("#"+divName).html(data);
				hideIfAny(id);
				
				setHighlight();
				//$('body').css('cursor', 'default'); 
			},
            error:function (jqXHR, textStatus, errorThrown){
            	alert(jqXHR.status + " " + errorThrown);
            }  
		});	
	}

	function setColumnMode(id, mode) {
		$("#modeHide-"+id).css("background-color", "");
		$("#modeSort-"+id).css("background-color", "");
		$("#modeHide-"+id).css("font-weight", "");
		$("#modeSort-"+id).css("font-weight", "");

		$("#mode-"+id).html(mode);
//		alert('mode=' + mode);
//		alert('mode2=' + $("#mode-"+id).html());
		if (mode =="sort") {
			$("#modeSort-"+id).css("background-color", "yellow");
			$("#modeSort-"+id).css("font-weight", "bold");
		} else if (mode == "hide") {
			$("#modeHide-"+id).css("background-color", "yellow");
			$("#modeHide-"+id).css("font-weight", "bold");

			hideNullColumnTable(""+id);
		}
		
	}
	
	function setColumn(id, colName, colIdx) {
		var mode = $("#mode-"+id).html();
//		alert(mode);
		if (mode==null) mode="hide";
		
		if (mode=='hide') {
			hideColumn(id, colIdx);
		} else if (mode=='sort') {
			//alert('sort');
			sort(id, colName);
		}
	}
	
	function sort(id, col) {
		$("#pageNo").val(1);
		var prevSortColumn = $("#sort-"+id).val();
		var prevSortDirection = $("#sortdir-"+id).val();
		var newSortDirection = "0";
		
		if (prevSortColumn==col && prevSortDirection=="0") { 
			newSortDirection = "1";  
		}
		$("#sort-"+id).val(col);
		$("#sortdir-"+id).val(newSortDirection);
		
		reloadData(id);
	}	

	function hideIfAny(id) {
		var hiddenCols = $("#hide-" + id).val();
		if (hiddenCols != '') {
			var cols = hiddenCols.split(",");
			for(var i = 0;i<cols.length;i++){
				hideColumn(id, cols[i]);
			}
		}
	}	
	
	function searchTable(id, key) {
		$("#pageNo").val(1);
		$("#searchValue").val(key);

		reloadData(id);
		$("#searchValue").val('');
	}

	function clearSearch(id) {
		$("#search"+id).val("");
		$("#pageNo").val(1);
		searchTable(id, '');
	}
	
	
	function showERD(tname) {
		
		var txt = $("#showERD").html();
		//console.log(txt);
		
		if (txt.indexOf("Show")>=0)
			$("#showERD").html("Hide ERD");
		else 
			$("#showERD").html("Show ERD");
		
		var v = $("#tableList1").html();
		if (v.length > 10) {
			if (txt.indexOf("Show")>=0)
				$("#tableList1").slideDown();
			else
				$("#tableList1").slideUp();
			return;
		}
		
		$("#tableList1").hide();
		$.ajax({
			url: "ajax/show-erd.jsp?tname=" + tname + "&t=" + (new Date().getTime()),
			success: function(data){
				$("#tableList1").html(data);
				$("#tableList1").slideDown();
			},
            error:function (jqXHR, textStatus, errorThrown){
            	alert(jqXHR.status + " " + errorThrown);
            }  
		});
	}

	function loadERD(tname) {
		$.ajax({
			url: "ajax/show-erd.jsp?tname=" + tname + "&t=" + (new Date().getTime()),
			success: function(data){
				$("#ERD").html(data);
			},
            error:function (jqXHR, textStatus, errorThrown){
            	alert(jqXHR.status + " " + errorThrown);
            }  
		});
	}

	
	function selectFromErd(tname) {
//		alert(tname);
		var sql = "SELECT * FROM " + tname;
		$("#sql").val(sql);
		document.form0.submit();
		
	}
	
	function hideDiv(divName) {
		$("#"+divName).slideUp();
	}

	function doQuery() {
		document.formQry.submit();
	}

	function doQueryNew() {
		document.formQry.target="_blank"; 
		document.formQry.submit();
	}

	function showDialog(table, key) {
		var id = "id"+(new Date().getTime());
		var temp ="<div id='" + id + "' title='" + table + "' >"
		$.ajax({
			url: "ajax/dialog.jsp?table=" + table + "&key=" + key,
			success: function(data){
				temp = temp + data + "</div>";
				$("BODY").append(temp);
				$("#"+id).dialog({ width: 700, height: 150 });
				setHighlight();
			},
            error:function (jqXHR, textStatus, errorThrown){
            	alert(jqXHR.status + " " + errorThrown);
            }  
		});		
	}

    function toggleDiv(imgId, divId) {
		var src = $("#" + imgId).attr('src');
		if (src.indexOf("minus")>0) {
			$("#"+divId).slideUp();
			$("#"+imgId).attr('src','image/plus.gif');
		} else {
			$("#"+divId).slideDown();
			$("#"+imgId).attr('src','image/minus.gif');
		}
    	
    }   
   
    function setHighlight() {
    	$('.simplehighlight').hover(function(){
    		$(this).children().addClass('datahighlight');
    	},function(){
    		$(this).children().removeClass('datahighlight');
    	});
    }
    
	function newQry() {
		var id = "id"+(new Date().getTime());
		var temp ="<div id='" + id + "' title='Query' >"
		$.ajax({
			url: "ajax/dialog-qry.jsp",
			success: function(data){
				temp = temp + data + "</div>";
				$("BODY").append(temp);
				$("#"+id).dialog({ width: 700, height: 400 });
				setHighlight();
			},
            error:function (jqXHR, textStatus, errorThrown){
            	alert(jqXHR.status + " " + errorThrown);
            }  
		});		
	}

	function doQry(id) {
		var sql = $("#input-"+id).val();
		$("#sql-"+id).html(sql);
		$("#sql").val(sql);
		$("#id").val(id);
		$("#div-"+id).html("<img src='image/loading.gif'/>");
//		alert(sql);
		$.ajax({
			url: "ajax/qry-simple.jsp",
			data: $("#form0").serialize(),
			success: function(data){
				$("#div-"+id).html(data);
				setHighlight();
			},
            error:function (jqXHR, textStatus, errorThrown){
            	alert(jqXHR.status + " " + errorThrown);
            }  
		});		
	}

	function editText(id) {
		$("#divText"+id).show();
		$("#divSql"+id).hide();		
	}
	
	function doTextQry(id) {
		var sql = $("#text-"+id).val();
		$("#sql-"+id).html(sql);
		$("#sql").val(sql);
		$("#id").val(id);
		
		$("#divSql"+id).html("<b>" + sql + "</b> <a href='Javascript:editText("+ id +")'>edit</a> <a href='Javascript:doTextQry("+ id +")'>rerun</a>");
		
		$("#divText"+id).hide();
		$("#divSql"+id).show();
		
		$("#div-"+id).html("<img src='image/loading.gif'/>");
//		alert(sql);
		$.ajax({
			url: "ajax/qry-work.jsp",
			data: $("#form0").serialize(),
			success: function(data){
				$("#div-"+id).html(data);
				setHighlight();
				hideNullColumnTable(""+id);
			},
            error:function (jqXHR, textStatus, errorThrown){
            	alert(jqXHR.status + " " + errorThrown);
            }  
		});		
	}
	
	function openWorksheet() {
		var temp = "";
		$("div ").each(function() {
			var divName = $(this).attr('id');
			if (divName != null && divName.indexOf("sql-")>=0) {
				var id = divName.substring(4);
				if ($("#div-" +id+":visible").length > 0) {
					var q = $("#" + divName).html();
					temp += q + "^";
				}
			}
		});
		//alert(temp);
		$("#sqls").val(temp);
		document.form_worksheet.submit();
	}
	
