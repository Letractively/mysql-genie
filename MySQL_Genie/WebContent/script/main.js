var gMode = 'table';

function loadSchema(sName) {
	$("#searchFilter").val("");
	$("#inner-table").html("<img src='image/loading.gif'/>");
	$.ajax({
		url: "schema.jsp?schema=" + sName + "&t=" + (new Date().getTime()),
		success: function(data){
			$("#inner-table").html(data);
			checkResize();
			setMode('table');
			CATALOG = catName;
		},
        error:function (jqXHR, textStatus, errorThrown){
        	alert(jqXHR.status + " " + errorThrown);
        }  
	});	
}

function addHistory(value) {
	var current = $("#inner-result2").html();
	var newItem = "<li>" + value + "</li>"; 
	current = current.replace(newItem,"");
	$("#inner-result2").html(newItem + current);
	
	saveHistoryOnServer(value);
}

function saveForNavigation() {
	var current = $("#inner-result1").html();
	stack.push(current);
	
	stackFwd = [];
//	console.log(stackFwd.length);
	showNavButton();
}

function loadTable(tName) {
	saveForNavigation();
	var tableName = tName;
	$("#inner-result1").html("<img src='image/loading.gif'/>");

	$.ajax({
		url: "ajax/detail-table.jsp?table=" + tableName + "&t=" + (new Date().getTime()),
		success: function(data){
			$("#inner-result1").html(data);
			setHighlight();
			//alert(data);
			//$("body").css("cursor", "auto");
		   	_gaq.push(['_trackEvent', 'Table', tName]);
		   	_gaq.push(['_trackPageview', 'ajax/detail-table.jsp?table=' + tableName]);		   	
		},
        error:function (jqXHR, textStatus, errorThrown){
        	alert(jqXHR.status + " " + errorThrown);
        }  
	});	
	
	addHistory("<a href='Javascript:loadTable(\""+tName+"\")'>" + tName + "</a>");
}

function globalSearch(keyword) {
	keyword = keyword.trim();
	saveForNavigation();
	$("#inner-result1").html("<img src='image/loading.gif'/>");

	$.ajax({
		url: "ajax/global-search.jsp?keyword=" + keyword + "&t=" + (new Date().getTime()),
		success: function(data){
			$("#inner-result1").html(data);
		},
        error:function (jqXHR, textStatus, errorThrown){
        	alert(jqXHR.status + " " + errorThrown);
        }  
	});
	
	addHistory("<a href='Javascript:globalSearch(\""+keyword+"\")'>" + keyword + "</a>");
}

function loadView(vName) {
	saveForNavigation();
	$("#inner-result1").html("<img src='image/loading.gif'/>");

	$.ajax({
		url: "ajax/detail-view.jsp?view=" + vName + "&t=" + (new Date().getTime()),
		success: function(data){
			$("#inner-result1").html(data);
			SyntaxHighlighter.all();
		   	_gaq.push(['_trackEvent', 'View', vName]);
		   	_gaq.push(['_trackPageview', 'ajax/detail-view.jsp?table=' + vName]);		   	
		},
        error:function (jqXHR, textStatus, errorThrown){
        	alert(jqXHR.status + " " + errorThrown);
        }  
	});	
	addHistory("<a href='Javascript:loadView(\""+vName+"\")'>" + vName + "</a>");
}

function loadPackage(pName) {
	saveForNavigation();
	$("#inner-result1").html("<img src='image/loading.gif'/>");

	$.ajax({
		url: "ajax/detail-package.jsp?name=" + pName + "&t=" + (new Date().getTime()),
		success: function(data){
			$("#inner-result1").html(data);
		   	_gaq.push(['_trackEvent', 'Program', pName]);
		   	_gaq.push(['_trackPageview', 'ajax/detail-package.jsp?table=' + pName]);		   	
		},
        error:function (jqXHR, textStatus, errorThrown){
        	alert(jqXHR.status + " " + errorThrown);
        }  
	});	
	addHistory("<a href='Javascript:loadPackage(\""+pName+"\")'>" + pName + "</a>");
}

function loadSynonym(sName) {
	saveForNavigation();
	$("#inner-result1").html("<img src='image/loading.gif'/>");

	$.ajax({
		url: "ajax/detail-synonym.jsp?name=" + sName + "&t=" + (new Date().getTime()),
		success: function(data){
			$("#inner-result1").html(data);
		   	_gaq.push(['_trackEvent', 'Synonym', sName]);
		   	_gaq.push(['_trackPageview', 'ajax/detail-synonym.jsp?table=' + sName]);		   	
		},
        error:function (jqXHR, textStatus, errorThrown){
        	alert(jqXHR.status + " " + errorThrown);
        }  
	});	
	addHistory("<a href='Javascript:loadSynonym(\""+sName+"\")'>" + sName + "</a>");
}

function loadTool(name) {
	saveForNavigation();
	$("#inner-result1").html("<img src='image/loading.gif'/>");

	$.ajax({
		url: "ajax/detail-tool.jsp?name=" + name + "&t=" + (new Date().getTime()),
		success: function(data){
			$("#inner-result1").html(data);
		   	_gaq.push(['_trackEvent', 'Tool', name]);
		   	_gaq.push(['_trackPageview', 'ajax/detail-tool.jsp?table=' + name]);		   	
		},
        error:function (jqXHR, textStatus, errorThrown){
        	alert(jqXHR.status + " " + errorThrown);
        }  
	});	
	addHistory("<a href='Javascript:loadTool(\""+name+"\")'>" + name + "</a>");
}

function loadDba(name) {
	saveForNavigation();
	$("#inner-result1").html("<img src='image/loading.gif'/>");

	$.ajax({
		url: "ajax/detail-dba.jsp?name=" + name + "&t=" + (new Date().getTime()),
		success: function(data){
			$("#inner-result1").html(data);
		},
        error:function (jqXHR, textStatus, errorThrown){
        	alert(jqXHR.status + " " + errorThrown);
        }  
	});	
	addHistory("<a href='Javascript:loadDba(\""+name+"\")'>" + name + "</a>");
}

function selectAll(tab) {
	var form = "FORM_" + tab;
    $("#" + form +" input[type='checkbox']:not([disabled='disabled'])").attr('checked', true);
}

function selectNone(tab) {
	var form = "FORM_" + tab;
    $("#" + form + " input[type='checkbox']:not([disabled='disabled'])").attr('checked', false);
}

function buildQuery(table) {
	var sList = "";
	var boxes = $(":checkbox:checked");

	$(':checkbox:checked').each(function () {
		if (sList=='') sList = this.name;
		else
			sList += ", " + this.name;
	});
	
	if (sList=='') sList = "*";
	
	var query = "SELECT " + sList + "\n" + "FROM " + table
	
	//alert(query);
	//document.forms["query"].sql.value = query;
}

function runQuery(catalog,tab) {
	var sList = "";
	var form = "DIV_" + tab; 

	$("#" + form + ' :checkbox:checked').each(function () {
		if (sList=='') sList = this.name;
		else
			sList += ", " + this.name;
	});
	
	if (sList=='') sList = "*";
	
//	var query = "SELECT " + sList + "\n" + "FROM " + catalog + "." + tab + " A"
	var query = "SELECT " + sList + "\n" + "FROM " + tab + " A"
	
//	alert(query);
	$("#sql").val(query);
	$("#FORM_query").submit();
	//document.forms["FORM_query"].sql.value = query;
	//document.forms["FORM_query"].submit();
}


	function cleanPage() {
		$("#searchFilter").val("");
		$("#inner-table").html('');
		//$("#inner-result1").html('');
	}
	
	function setMode(mode) {
		var gotoUrl = "";
		var select = "";
		
		if (mode == "table") {
			gotoUrl = "ajax/list-table.jsp";
			select = "selectTable";
		} else if (mode == "view") {
			gotoUrl = "ajax/list-view.jsp";
			select = "selectView";
		} else if (mode == "package") {
			gotoUrl = "ajax/list-package.jsp";
			select = "selectPackage";
//		} else if (mode == "type") {
//			gotoUrl = "ajax/list-type.jsp";
//			select = "selectType";
		} else if (mode == "synonym") {
			gotoUrl = "ajax/list-synonym.jsp";
			select = "selectSynonym";
		} else if (mode == "tool") {
			gotoUrl = "ajax/list-tool.jsp";
			select = "selectTool";
		} else if (mode == "dba") {
			gotoUrl = "ajax/list-dba.jsp";
			select = "selectDba";
		}

		$("#selectTable").css("font-weight", "");
		$("#selectView").css("font-weight", "");
		$("#selectPackage").css("font-weight", "");
		$("#selectSynonym").css("font-weight", "");
		$("#selectTool").css("font-weight", "");
		$("#selectDba").css("font-weight", "");

		$("#selectTable").css("background-color", "");
		$("#selectView").css("background-color", "");
		$("#selectPackage").css("background-color", "");
		$("#selectSynonym").css("background-color", "");
		$("#selectTool").css("background-color", "");
		$("#selectDba").css("background-color", "");

		cleanPage();
		$("#inner-table").html("<img src='image/loading.gif'/>");
		$.ajax({
			url: gotoUrl,
			success: function(data){
				$("#inner-table").html(data);
			},
            error:function (jqXHR, textStatus, errorThrown){
            	alert(jqXHR.status + " " + errorThrown);
            }  
		});

		$("#" + select).css("font-weight", "bold");
		$("#" + select).css("background-color", "#d0d0ff");
		
		gMode = mode;
	}
	
	function searchWithFilter(filter) {
		var mode = gMode;
		var gotoUrl = "";
		
		if (mode == "table") {
			gotoUrl = "ajax/list-table.jsp?filter=" + filter;
		} else if (mode == "view") {
			gotoUrl = "ajax/list-view.jsp?filter=" + filter;
		} else if (mode == "package") {
			gotoUrl = "ajax/list-package.jsp?filter=" + filter;
		} else if (mode == "type") {
			gotoUrl = "ajax/list-type.jsp?filter=" + filter;
		} else if (mode == "synonym") {
			gotoUrl = "ajax/list-synonym.jsp?filter=" + filter;
		} else if (mode == "tool") {
			gotoUrl = "ajax/list-tool.jsp?filter=" + filter;
		} else if (mode == "dba") {
			gotoUrl = "ajax/list-dba.jsp?filter=" + filter;
		}

		$.ajax({
			url: gotoUrl,
			success: function(data){
				$("#inner-table").html(data);
			},
            error:function (jqXHR, textStatus, errorThrown){
            	alert(jqXHR.status + " " + errorThrown);
            }  
		});
		
	}
	
	function clearField() {
		$("#searchFilter").val("");
		searchWithFilter('');
	}
	
	function clearField2() {
		$("#globalSearch").val("");
		$("#globalSearch").focus();
	}	
	
	function queryHistory() {
		saveForNavigation();
		$("#inner-result1").html("<img src='image/loading.gif'/>");
		
		$.ajax({
			url: "ajax/query-history.jsp",
			success: function(data){
				$("#inner-result1").html(data);
			},
            error:function (jqXHR, textStatus, errorThrown){
            	alert(jqXHR.status + " " + errorThrown);
            }  
		});
	}
	
	function clearCache() {
		var remoteURL = 'ajax/clear-cache.jsp';
		$.get(remoteURL, function(data) {
			alert('Cache Cleared!');
		});
	}
	
	
		
    function startSearch() {
    	var key = $("#searchKey").val();
    	if (key.trim() == "") {
    		alert("Please enter search keyword");
    		return;
    	}
    	
    	$("#startButton").attr("disabled", true);
    	$("#cancelButton").attr("disabled", false);
    	
    	$("#searchProgress").html("");
    	checkProgress();
    	$("#progressDiv").show();
    	
    	$("#searchResult").html("Searching...  <a href='javascript:skipCurrent()'>skip current table</a>");    	
		$("#searchResult").append("<div id='wait'><img src='image/loading.gif'/></div>");
		$.ajax({
			type: 'POST',
			url: "ajax/search-behind.jsp",
			data: $("#form0").serialize(),
			success: function(data){
				$("#searchResult").html(data);
				$("#wait").remove();
				checkProgress();
				readySearch();
			},
            error:function (jqXHR, textStatus, errorThrown){
            	alert(jqXHR.status + " " + errorThrown);
            }  
		});	
    	
    }

    function readySearch() {
    	$("#startButton").attr("disabled", false);
    	$("#cancelButton").attr("disabled", true);
    	//clearTimeout(to2);
    }
    
    function cancelSearch() {
    	clearTimeout(to2);
		$.ajax({
			type: 'POST',
			url: "ajax/cancel-search.jsp",
			data: $("#form0").serialize(),
			success: function(data){
				checkProgress();
				readySearch();
//				alert('Search Cancelled');
			},
            error:function (jqXHR, textStatus, errorThrown){
            	alert(jqXHR.status + " " + errorThrown);
            }  
		});	
    }    
    
    function checkProgress() {
    	clearTimeout(to2);
    	var current = $("#searchProgress").html();
		$.ajax({
			type: 'POST',
			url: "ajax/search-progress.jsp",
			success: function(data){
				if (current != data) {
	    			$("#searchProgress").html(data);
				}
				
				if (data.indexOf("Finished") == 0)
					clearTimeout(to2);
				else
					to2 = setTimeout("checkProgress()",1000);
			},
            error:function (jqXHR, textStatus, errorThrown){
            	alert(jqXHR.status + " " + errorThrown);
            }  
		});	    	
    }	

    function openQuery(divId) {
    	var sql = $("#"+divId).html();
    	$("#sql").val(sql);
    	$("#form_qry").submit();
    	//alert(sql);
    }
    

    function runToolQuery(cnt) {
    	var p1, p2, p3, p4, p5;
    	
    	if (cnt >=1) p1 = $("#param-1").val();
    	if (cnt >=2) p2 = $("#param-2").val();
    	if (cnt >=3) p3 = $("#param-3").val();
    	if (cnt >=4) p4 = $("#param-4").val();
    	if (cnt >=5) p5 = $("#param-5").val();
    	
    	var sql = $("#paramQuery").html();
//    	alert(sql);
    	if (cnt >=1) sql = sql.replace("[1]", p1);
    	if (cnt >=2) sql = sql.replace("[2]", p2);
    	if (cnt >=3) sql = sql.replace("[3]", p3);
    	if (cnt >=4) sql = sql.replace("[4]", p4);
    	if (cnt >=5) sql = sql.replace("[5]", p5);
//    	alert(sql);
    	$("#param-sql").val(sql);
    	
		$("#paramQueryResult").html("<div id='wait'><img src='image/loading.gif'/></div>");
    	$.ajax({
			type: 'POST',
    		url: "ajax/detail-tool-query.jsp",
			data: $("#formParam").serialize(),
    		success: function(data){
    			$("#paramQueryResult").html(data);
    		},
            error:function (jqXHR, textStatus, errorThrown){
            	alert(jqXHR.status + " " + errorThrown);
            }  
    	});
    	
    }

    
    function toolQuery() {
    	document.form1.submit();
    }
    
    function goBack() {
    	if (stack.length>0) {
    		var current = $("#inner-result1").html();
    		var data = stack.pop();
    		$("#inner-result1").html(data);
    		stackFwd.push(current);
    		showNavButton();
    	}
    }
    
    function goFoward() {
    	if (stackFwd.length>0) {
    		var current = $("#inner-result1").html();
    		var data = stackFwd.pop();
    		$("#inner-result1").html(data);
    		stack.push(current);
    		showNavButton();
    	}
    }
    
    function showNavButton() {
    	if (stack.length > 0 )
    		$("#imgBackward").show();
    	else
    		$("#imgBackward").hide();

    	if (stackFwd.length > 0 )
			$("#imgForward").show();
		else
			$("#imgForward").hide();
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
    
    function skipCurrent() {
		$.ajax({
			type: 'POST',
			url: "ajax/skip-search.jsp",
			data: $("#form0").serialize(),
			success: function(data){
				checkProgress();
//				readySearch();
			},
            error:function (jqXHR, textStatus, errorThrown){
            	alert(jqXHR.status + " " + errorThrown);
            }  
		});	
    }
    
    function createChingooTable() {
		$.ajax({
			type: 'POST',
			url: "ajax/create-table.jsp",
			success: function(data){
				alert('Done');
				loadTool("User Defined Page");
			},
            error:function (jqXHR, textStatus, errorThrown){
            	alert(jqXHR.status + " " + errorThrown);
            }  
		});	
    }
    
    function createChingooTable2() {
		$.ajax({
			type: 'POST',
			url: "ajax/create-table2.jsp",
			success: function(data){
				alert('Done');
				loadTool("Saved Query");
			},
            error:function (jqXHR, textStatus, errorThrown){
            	alert(jqXHR.status + " " + errorThrown);
            }  
		});	
    }

    function createChingooTable2() {
		$.ajax({
			type: 'POST',
			url: "ajax/create-table2.jsp",
			success: function(data){
				alert('Done');
				loadTool("Saved Query");
			},
            error:function (jqXHR, textStatus, errorThrown){
            	alert(jqXHR.status + " " + errorThrown);
            }  
		});	
    }
    
    function runSQ(id) {
    	var sql = $("#SQ-"+id).html();
    	$("#SQ_sql").val(sql);
    	$("#form_SQ").submit();
    }
    
    function saveHistoryOnServer(value) {
    	$.ajax({
    		url: "save-history.jsp?value=" + value + "&t=" + (new Date().getTime()),
    		success: function(data){
    		}  
    	});	
    }	
    
    function setHighlight() {
    	$('.simplehighlight').hover(function(){
    		$(this).children().addClass('datahighlight');
    	},function(){
    		$(this).children().removeClass('datahighlight');
    	});
    }
    
	function loadObject(oName) {
		saveForNavigation();
		var objectName = oName;
		$("#inner-result1").html("<img src='image/loading.gif'/>");

		$.ajax({
			url: "ajax/detail-object.jsp?object=" + objectName + "&t=" + (new Date().getTime()),
			success: function(data){
				$("#inner-result1").html(data);
			   	setHighlight();
				//alert(data);
				//$("body").css("cursor", "auto");
			   	_gaq.push(['_trackEvent', 'Object', 'Object ' + oName]);
			},
	        error:function (jqXHR, textStatus, errorThrown){
	            alert(jqXHR.status + " " + errorThrown);
	        }  
		});	
		
		addHistory("<a href='Javascript:loadObject(\""+oName+"\")'>" + oName + "</a>");
	}	
	