var doMode = 'copy';
var qryPage = 'ajax/qry.jsp';

	function download() {
		$("#form1").attr("action", "download.jsp");
		$("#form1").submit();
		$("#form1").attr("action", "query.jsp");
	}
	
	function endsWith(str, suffix) {
    	return str.indexOf(suffix, str.length - suffix.length) !== -1;
	}
	
	function startsWith (str, prefix) {
		if( str.indexOf(prefix) == 0 ) return true;
   		return false;
	}
	
	function web() {
		$('#dataTable td')
			.each(
				function() {
					var value = $(this).html();
					if (startsWith(value.toLowerCase(), "http://") && (endsWith(value.toLowerCase(), ".jpg") || endsWith(value.toLowerCase(), ".gif") || endsWith(value.toLowerCase(), ".png"))) {
						value = "<img src='" + value + "'>" + "<br>" + value ;
						$(this).html(value);
					} else if (startsWith(value.toLowerCase(), "http://")) {
						value = "<br>" + "<a href='" + value + "' target=_blank>open</a>" + "<br>" + value ;
						$(this).html(value);
					} else if (startsWith(value.toLowerCase(), "www.")) {
						value = "<a href='http://" + value + "' target=_blank>open</a>" + "<br>" + value ;
						$(this).html(value);
					}
				}
			);
	}
	
	$.fn.hideCol = function(col){
	    // Make sure col has value
	    if(!col){ col = 1; }
	    $('tr td:nth-child('+col+'), tr th:nth-child('+col+')', this).hide();
	    return this;
	};	
	
	$.fn.showCol = function(col){
	    // Make sure col has value
	    if(!col){ col = 1; }
	    $('tr td:nth-child('+col+'), tr th:nth-child('+col+')', this).show();
	    return this;
	};	
	
	function hide(col) {
		$('table#dataTable').hideCol(col);
	}
	
	function show(col) {
		$('table#dataTable').showCol(col);
	}
	
	function hideInspectComment() {
		$('table#inspectTable').hideCol(3);
	}	
	
	function showTable(tbl) {
		
		if (tbl == "") return;
		
		$("#table-detail").append("<div id='wait'><img src='image/loading.gif'/></div>");
		$("#table-detail").hide();
		$.ajax({
			url: "ajax/table_col.jsp?table=" + tbl + "&t=" + (new Date().getTime()),
			success: function(data){
				$("#wait").remove();
				$("#table-detail").append(data);
				$("#table-detail").slideDown();
			},
            error:function (jqXHR, textStatus, errorThrown){
            	alert(jqXHR.status + " " + errorThrown);
            }  
		});	
	}

	function toggleHelp() {
		var src = $("#helpDivImage").attr('src');
		if (src.indexOf("minus")>0) {
			$("#div-help").slideUp();
			$("#helpDivImage").attr('src','image/plus.gif');
		} else {
			$("#div-help").slideDown();
			$("#helpDivImage").attr('src','image/minus.gif');
		}
	}
	
	function gotoPage(pageNo) {
		$("#pageNo").val(pageNo);
		$("#data-div").html("<div id='wait'><img src='image/loading.gif'/></div>");

		reloadData();
	}
	
	function showTableCols(tbl) {
		$("#tableColumns").html("<div id='wait'><img src='image/loading.gif'/></div>");
		
		$.ajax({
			url: "table_col2.jsp?table=" + tbl + "&t=" + (new Date().getTime()),
			success: function(data){
				$("#tableColumns").html(data);
			},
            error:function (jqXHR, textStatus, errorThrown){
            	alert(jqXHR.status + " " + errorThrown);
            }  
		});	
	}

	function setTranspose() {
		if (qryPage == "ajax/qry.jsp") {
			qryPage = "ajax/qry-v.jsp";
		} else {
			qryPage = "ajax/qry.jsp";
		}
		reloadData();
	}
	function setDoMode(mode) {
		var select = "";

		doMode = mode;

		$("#modeCopy").css("font-weight", "");
		$("#modeHide").css("font-weight", "");
		$("#modeSort").css("font-weight", "");
		$("#modeFilter").css("font-weight", "");

		$("#modeCopy").css("background-color", "");
		$("#modeHide").css("background-color", "");
		$("#modeSort").css("background-color", "");
		$("#modeFilter").css("background-color", "");

		if (mode == "copy") {
			select = "modeCopy";
		} else if (mode == "hide") {
			select = "modeHide";
			hideNullColumnTableMaster();
		} else if (mode == "sort") {
			select = "modeSort";
		} else if (mode == "filter") {
			select = "modeFilter";
			filter('0');
		}
		
		$("#" + select).css("font-weight", "bold");
		$("#" + select).css("background-color", "yellow");
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

    function hideNullColumnTableMaster() {
    	var divName = "dataTable";
    	var rowCount = $('#' + divName + ' tr').length;
    	
    	//if (rowCount > 2) return;
    	
   	    //var row = 1;
   	 	var hideCol = []; 
   	 	var colCnt = numCol(divName);
   	 	//alert(rowCount + "," +colCnt);
    	for (var col = 0; col < colCnt; col++) {
   	 		var nullValue = true;
       	 	for (var row=1; row<rowCount;row++) {
	    		var value = $("#" + divName).children().children()[row].children[col].innerHTML;
    			if (value.indexOf(">null<")<=0) {
   				nullValue = false;
	    		}
   	    	}
   	    	if (nullValue) hideCol.push(col+1);
   	    }
   	    
   	 	for (var i = 0, l = hideCol.length; i < l; ++i) {
   	 		//alert('hide ' + hideCol[i] );
   	 		hideX(hideCol[i]);
   	    }
   	    
    }

    function hideX(idx) {
		var cols = $("#hideColumn").val();
		if (cols == "") cols = idx;
		else cols += "," + idx;
		
		$("#hideColumn").val(cols);
		hide(idx);
		$("#showAllCol").show();    	
    }
    
	function doAction(val, idx) {
		if (doMode=='copy') {
			copyPaste(val);
		} else if (doMode=='hide') {
			hideX(idx);
		} else if (doMode=='sort') {
			sort(val);
		} else if (doMode=='filter') {
			filter(val);
		} else {
			alert("mode=" + doMode);
		}
	}

	function showAllColumn() {
		var hiddenCols = $("#hideColumn").val();
		if (hiddenCols != '') {
			var cols = hiddenCols.split(",");
			for(var i = 0;i<cols.length;i++){
				show(cols[i]);
			}
		}

		$("#showAllCol").hide();
		$("#hideColumn").val('');
	}
	
	function sort(col) {
		$("#pageNo").val(1);
		$("#data-div").html("<div id='wait'><img src='image/loading.gif'/></div>");
		var prevSortColumn = $("#sortColumn").val();
		var prevSortDirection = $("#sortDirection").val();
		var newSortDirection = "0";
		
		if (prevSortColumn==col && prevSortDirection=="0") { 
			newSortDirection = "1";  
		}
		$("#sortColumn").val(col);
		$("#sortDirection").val(newSortDirection);
		
		reloadData();
	}

	function filter(col) {
		$("#filter-div").html("<div id='wait'><img src='image/loading.gif'/></div>");
		$("#filterColumn").val(col);
		$("#filterValue").val('');
		
		$.ajax({
			type: 'POST',
			url: "ajax/filter.jsp",
			data: $("#form0").serialize(),
			success: function(data){
				$("#filter-div").append(data);
				$("#wait").remove();
				reloadData();
			},
            error:function (jqXHR, textStatus, errorThrown){
            	alert(jqXHR.status + " " + errorThrown);
            }  
		});	
	}	
	
	function reloadData() {
		$("#data-div").html("<div id='wait'><img src='image/loading.gif'/></div>");
		
		//$('body').css('cursor', 'wait'); 
		$.ajax({
			type: 'POST',
			url: qryPage,
			data: $("#form0").serialize(),
			success: function(data){
				$("#data-div").append(data);
				$("#wait").remove();
				hideIfAny();
				
				setHighlight();
				//$('body').css('cursor', 'default'); 
			},
            error:function (jqXHR, textStatus, errorThrown){
            	alert(jqXHR.status + " " + errorThrown);
            }  
		});	
	}
	
	function applyFilter(value) {
		$("#pageNo").val(1);
		$("#filterValue").val(value);
		$("#data-div").html("<div id='wait'><img src='image/loading.gif'/></div>");
		
		reloadData();
	}

	function hideIfAny() {
		var hiddenCols = $("#hideColumn").val();
		if (hiddenCols != '') {
			var cols = hiddenCols.split(",");
			for(var i = 0;i<cols.length;i++){
				hide(cols[i]);
			}
		}
	}

	function rowsPerPage(rows) {
		$("#rowsPerPage").val(rows);
		$("#pageNo").val(1);
		$("#data-div").html("<div id='wait'><img src='image/loading.gif'/></div>");
		
		reloadData();
	}

	function removeFilter() {
		$("#pageNo").val(1);
		$("#filter-div").html('');
		$("#filterValue").val('');
		$("#filterColumn").val('');
		$("#data-div").html("<div id='wait'><img src='image/loading.gif'/></div>");
		
		reloadData();
	}
	
	function copyPaste(val) {
//		$("#sql1").insertAtCaret(" " + val);
		$("#sql1").insertAtCaret2(val);		
	}

	function removeDiv(divId) {
		$("#"+divId).remove();
	}	
	
$.fn.insertAtCaret = function (tagName) {
	return this.each(function(){
		if (document.selection) {
			//IE support
			this.focus();
			sel = document.selection.createRange();
			sel.text = tagName;
			this.focus();
		}else if (this.selectionStart || this.selectionStart == '0') {
			//MOZILLA/NETSCAPE support
			startPos = this.selectionStart;
			endPos = this.selectionEnd;
			scrollTop = this.scrollTop;
			this.value = this.value.substring(0, startPos) + tagName + this.value.substring(endPos,this.value.length);
			this.focus();
			this.selectionStart = startPos + tagName.length;
			this.selectionEnd = startPos + tagName.length;
			this.scrollTop = scrollTop;
		} else {
			this.value += tagName;
			this.focus();
		}
	});
};	
	
$.fn.insertAtCaret2 = function (tagName) {
	return this.each(function(){
		if (document.selection) {
			//IE support
			this.focus();
			sel = document.selection.createRange();
			sel.text = tagName;
			this.focus();
		}else if (this.selectionStart || this.selectionStart == '0') {
			//MOZILLA/NETSCAPE support
			startPos = this.selectionStart;
			endPos = this.selectionEnd;
			scrollTop = this.scrollTop;
			var x = this.value.substring(startPos-1, startPos);
			//alert("[" + x + "]");
			if (x != ' ') tagName = ' ' + tagName; 
			this.value = this.value.substring(0, startPos) + tagName + this.value.substring(endPos,this.value.length);
			this.focus();
			this.selectionStart = startPos + tagName.length;
			this.selectionEnd = startPos + tagName.length;
			this.scrollTop = scrollTop;
		} else {
			this.value += tagName;
			this.focus();
		}
	});
};	

function selectOption(select_id, option_val) {
    $('#'+select_id+' option:selected').removeAttr('selected');
    $('#'+select_id+' option[value='+option_val+']').attr('selected','selected');       
}

function linkPk(tname, cname, value, backTable) {
	$.ajax({
		url: "ajax/pk-link-query.jsp?table=" + tname + "&col=" + cname +
			"&backTable=" + backTable +
			"&key=" + value + "&t=" + (new Date().getTime()),
		success: function(data){
			$("#pkLink").html(data);
		},
        error:function (jqXHR, textStatus, errorThrown){
        	alert(jqXHR.status + " " + errorThrown);
        }  
	});		
}

function backTolinkPk(tname, value) {
	$.ajax({
		url: "ajax/pk-link.jsp?table=" + tname +  
			"&key=" + value + "&t=" + (new Date().getTime()),
		success: function(data){
			$("#pkLink").html(data);
		},
        error:function (jqXHR, textStatus, errorThrown){
        	alert(jqXHR.status + " " + errorThrown);
        }  
	});		
}

function showTables() {
	$("#tableList1").html("<div id='wait'><img src='image/loading.gif'/></div>");
	
	$.ajax({
		url: "ajax/show-tables.jsp?t=" + (new Date().getTime()),
		success: function(data){
			$("#tableList1").html(data);
			$("#wait").remove();
		},
        error:function (jqXHR, textStatus, errorThrown){
        	alert(jqXHR.status + " " + errorThrown);
        }  
	});
}

function showRelatedTables(tname) {
	$("#tableList1").html("<div id='wait'><img src='image/loading.gif'/></div>");
	
	$.ajax({
		url: "ajax/show-rel-tables.jsp?tname=" + tname + "&t=" + (new Date().getTime()),
		success: function(data){
			$("#tableList1").html(data);
			$("#wait").remove();
		},
        error:function (jqXHR, textStatus, errorThrown){
        	alert(jqXHR.status + " " + errorThrown);
        }  
	});
}

function showTableLink() {
	$("#hideTableLink").show();
	$("#showTableLink").hide();
}


function hideTableLink() {
	$("#hideTableLink").hide();
	$("#showTableLink").show();
}

function searchRecords(filter) {
	
	$("#search").attr("onchange" , "");
	
	$("#pageNo").val(1);
	$("#data-div").html("<div id='wait'><img src='image/loading.gif'/></div>");
	$("#searchValue").val(filter);
	
	reloadData();
}

function clearSearch() {
	$("#search").val("");
	searchRecords('');
}

function doQuery() {
	document.formQry.submit();
}

function doQueryNew() {
	document.formQry.target="_blank"; 
	document.formQry.submit();
}

function toggleDataLink() {
	var v = $("#dataLink").val();
	v = (v=="1"?"0":"1");
	$("#dataLink").val(v);
//	alert(v);
	reloadData();
}

function togglePreFormat() {
	var v = $("#preFormat").val();
	v = (v=="1"?"0":"1");
	$("#preFormat").val(v);
//	alert(v);
	reloadData();
}

function toggleText(arg1, arg2) {
	$('#'+arg1).toggle();
	$('#'+arg2).toggle();
}

function toggleText2(arg1, arg2) {
	$('#'+arg1).remove();
	$('#'+arg2).toggle();
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
	showTable(tname);
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

function openQuery(id) {
	var sql = $("#sql-" + id).html();
	var divName = "div-" + id;
	//alert(sql);
	
	$("#sql1").val(sql);
	document.form1.submit();	
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

function setHighlight() {
	$('.simplehighlight').hover(function(){
		$(this).children().addClass('datahighlight');
	},function(){
		$(this).children().removeClass('datahighlight');
	});
}
