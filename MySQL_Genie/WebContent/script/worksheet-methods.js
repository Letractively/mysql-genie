	$(function() {
		// a workaround for a flaw in the demo system (http://dev.jqueryui.com/ticket/4375), ignore!
		$( "#dialog:ui-dialog" ).dialog( "destroy" );
		
		var name = $( "#name1" ),
			allFields = $( [] ).add( name ),
			tips = $( ".validateTips" );

		function updateTips( t ) {
			tips
				.text( t )
				.addClass( "ui-state-highlight" );
			setTimeout(function() {
				tips.removeClass( "ui-state-highlight", 1500 );
			}, 500 );
		}

		function checkLength( o, n, min, max ) {
			if ( o.val().length > max || o.val().length < min ) {
				o.addClass( "ui-state-error" );
				updateTips( "Length of " + n + " must be between " +
					min + " and " + max + "." );
				return false;
			} else {
				return true;
			}
		}

		function checkRegexp( o, regexp, n ) {
			if ( !( regexp.test( o.val() ) ) ) {
				o.addClass( "ui-state-error" );
				updateTips( n );
				return false;
			} else {
				return true;
			}
		}
		
		$( "#dialog-form" ).dialog({
			autoOpen: false,
			height: 240,
			width: 350,
			modal: true,
			buttons: {
				"Rename": function() {
					var bValid = true;
					allFields.removeClass( "ui-state-error" );

					bValid = bValid && checkLength( name, "name1", 3, 100 );

					if ( bValid ) {
						renameWorksheet(name.val());
						//alert(name.val());
						$( this ).dialog( "close" );
					}
				},
				Cancel: function() {
					$( this ).dialog( "close" );
				}
			},
			close: function() {
				allFields.val( "" ).removeClass( "ui-state-error" );
			}
		});

		$( "#rename1" )
			.button()
			.click(function() {
				$( "#dialog-form" ).dialog( "open" );
			});
		
		$( "#clear1" )
			.button()
			.click(function() {
				clearWorksheet();
		});
		
		$( "#save1" )
			.button()
			.click(function() {
				saveWorksheet();
		});		

		$( "#load1" )
			.button()
			.click(function() {
				//alert('load');
				$( "#dialog-form2" ).dialog( "open" );
				loadWorksheet();
		});		
	
		$( "#dialog-form2" ).dialog({
			autoOpen: false,
			height: 300,
			width: 450,
			modal: true,
			buttons: {
				Cancel: function() {
					$( this ).dialog( "close" );
				}
			},
			close: function() {
				allFields.val( "" ).removeClass( "ui-state-error" );
			}
		});
		
	});

	
	
	
	
	
	
	
	
	
	function htmlDecode(input){
		var e = document.createElement('div');
		e.innerHTML = input;
		return e.childNodes.length === 0 ? "" : e.childNodes[0].nodeValue;
	}
	
	function renameWorksheet(newName) {
		gWorksheetName = newName;
		$(document).attr('title', 'Work Sheet - ' + gWorksheetName);	
		$("#worksheetNameDisp").html(gWorksheetName);
	}
	
	function clearWorksheet(){
		//temp2 = "";
		$("div.ui-dialog").each(function() {
			var nm = $(this).attr('aria-labelledby');
			//alert(nm);
			if (nm != 'ui-dialog-title-dialog-form' && nm != 'ui-dialog-title-dialog-form2' && nm != 'ui-dialog-title-idHelp') {
				$(this).remove();
			}
		});	
		
		$("div.jSticky-medium").each(function() {
			$(this).remove();
		});	
	}
	
	function saveWorksheet() {
		//alert(gWorksheetName);
		var temp = "";
		$("div ").each(function() {
			var divName = $(this).attr('id');
			if (divName != null && divName.indexOf("divSql")>=0) {
				var id = divName.substring(6);
				if ($("#" +divName+":visible").length > 0) {
					var q = $("#" + divName+" b").html();
					temp += htmlDecode(q) + "!^!";
				} else {
					if ($("#divText" +id+":visible").length > 0) {
						var q = $("#text-" + id).val();
						temp += htmlDecode(q) + "!^!";
					}
				}
			}
		});
		$("p").each(function() {
			var divName = $(this).attr('id');
			if (divName != null && divName.indexOf("p-note-")>=0) {
				var q = 'note:' + $("#" + divName).html();
				temp += htmlDecode(q) + "!^!";
			}
		});
		$("div.jStickyNote textarea").each(function() {
			if ($(this).is(':visible')) {
				var q = 'note:' + $(this).val();
				temp += htmlDecode(q) + "!^!";
			}
		});		
/*		
		$("textarea").each(function() {
			
			//alert("zzz");
			var divName = $(this).attr('id');
			//alert("divName=" + divName);
			if (divName != null && divName.indexOf("textarea-note-")>=0) {
				//alert(divName);
				var q = 'note:' + $("#" + divName).val();
				temp += htmlDecode(q) + "!^!";
			}
		});			
*/
//		alert(temp);
		
		temp2 = "";
		$("div.ui-dialog").each(function() {

			
			var nm = $(this).attr('aria-labelledby');
			if ($(this).is(':visible') && nm != 'ui-dialog-title-idHelp') {
				var pos = $(this).position();
				var divName = pos.left + "," + pos.top + "," + $(this).width() + "," + $(this).height();
 				temp2 += divName + "!^!";
			}
		});
		$("div.jSticky-medium").each(function() {
			var pos = $(this).position();
			if ($(this).is(':visible')) {
				var divName = pos.left + "," + pos.top + "," + $(this).width() + "," + $(this).height();
 				temp2 += divName + "!^!";
			}
		});			
		
//		alert(temp2);
		
		saveToDb(gWorksheetName, temp, temp2);
	}

	function saveToDb(wName, sqls, coords) {
		$("#save-name").val(wName);
		$("#save-sqls").val(sqls);
		$("#save-coords").val(coords);
		
		$.ajax({
			type: 'POST',
			url: "ajax/worksheet-save.jsp",
			data: $("#form-save").serialize(),
			success: function(data){
				alert('Saved');
			},
            error:function (jqXHR, textStatus, errorThrown){
                alert(jqXHR.status + " " + errorThrown);
            }  
		});			
	}

	function loadWorksheet() {
		$("#load-worksheet-list").html("Loading...");
		$.ajax({
			url: "ajax/worksheet-list.jsp",
			success: function(data){
				$("#load-worksheet-list").html(data);
			},
            error:function (jqXHR, textStatus, errorThrown){
                alert(jqXHR.status + " " + errorThrown);
            }  
		});			
		
	}	
	
	function loadWS(wsname) {
		$("#dialog-form2").dialog( "close" );
		
		//alert('to load ' + wsname);
		
		// load the worksheet
		$("#load-name").val(wsname);
		$("#form-load").submit();
		
	}
	
	function deleteWS(wsname) {
		
		if (!confirm("Are you sure you want to delete?")) return;
	
		
		$("#load-name").val(wsname);
		$.ajax({
			url: "ajax/worksheet-delete.jsp",
			type: 'POST',
			data: $("#form-load").serialize(),
			success: function(data){
				loadWorksheet();
			},
            error:function (jqXHR, textStatus, errorThrown){
                alert(jqXHR.status + " " + errorThrown);
            }  
		});			
		
	}
	
	function showLoadWorksheet() {
		var sqls = htmlDecode( $("#loadedSqls").html() );
		var positions = $("#loadedCoords").html();
		var s = sqls.split("!^!");
		var p = positions.split("!^!");
		
//		alert(sqls);
//		alert(positions);
		
		for (i=0;i<s.length;i++) {
//			alert(i + ":" + s[i] + " " + p[i]);
			
			var t = p[i].split(",");
			var left = t[0];
			var top = t[1];
			var width = t[2];
			var height = t[3];
			
			if (s[i].length > 1 && s[i].indexOf('note:')==0) {
				//alert(s[i]);
				var note = s[i].substring(5);
				openNotePos(note, left, top, width, height);
			} else {
				if (s[i].length > 1)
					openQryPos(s[i], left, top, width, height);
			}
		}	
	}	
	
	function clearQuery() {
		$("#qry_stmt").val('');	
	}
	function runQry() {
		var sql = $("#qry_stmt").val();
		openQry(sql);
	}
	
	function openQry(sql) {
		//var id = "id"+(new Date().getTime());
		gid = gid + 1;
		var id = "id-" + gid;
		var temp ="<div id='" + id + "' title='Query' >";
		//alert(temp);
		//alert(encodeURI(sql));
		$.ajax({
			url: "ajax/dialog-qry.jsp?sql=" + encodeURI(sql),
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
	
	function openQryIndex(sql, idx) {
		//var id = "id"+(new Date().getTime());
		gid = gid + 1;
		var id = "id-" + gid;
		var temp ="<div id='" + id + "' title='Query' >";
		//alert(temp);
		//alert(encodeURI(sql));
		$.ajax({
			url: "ajax/dialog-qry.jsp?sql=" + encodeURI(sql),
			success: function(data){
				temp = temp + data + "</div>";
				$("BODY").append(temp);
				$("#"+id).dialog({ width: 700, height: 200 });
				$("#"+id).dialog("option", "position", [200 + idx*50, 200 + idx*50]);
				//alert($("#"+id + " > table[0]").height());
				setHighlight();
			},
            error:function (jqXHR, textStatus, errorThrown){
            	alert(jqXHR.status + " " + errorThrown);
            }  
		});
	}
	
	function openQryPos(sql, l, t, w, h) {
		//var id = "id"+(new Date().getTime());
		gid = gid + 1;
		var id = "id-" + gid;
		var temp ="<div id='" + id + "' title='Query' >";
		//alert(temp);
		
		$.ajax({
			url: "ajax/dialog-qry.jsp?sql=" + encodeURI(sql),
			success: function(data){
				temp = temp + data + "</div>";
				$("BODY").append(temp);
				$("#"+id).dialog({ width: w, height: h });
				$("#"+id).dialog("option", "position", [Number(l), Number(t)]);
				setHighlight();
//				alert(l + "," + t);
			},
            error:function (jqXHR, textStatus, errorThrown){
            	alert(jqXHR.status + " " + errorThrown);
            }  
		});
	}    

	function openNotePos(note, l, t, w, h) {
		
		jQuery.fn.stickyNotes.createNote2(note, l, t, w, h);
		
/*		
		gid = gid + 1;
		var id = "id-" + gid;
		var options = {
				notes:[{"id":id,
				      "text":note,
					  "pos_x": l,
					  "pos_y": t,	
					  "width": w,							
					  "height": h,													
				    }]
				,resizable: true
				,controls: true 
				,editCallback: edited
				,createCallback: created
				,deleteCallback: deleted
				,moveCallback: moved					
				,resizeCallback: resized					
				
			};
			$("#notes").stickyNotes(options);
*/			
	}    

	function showHelp() {
		$("#helper").slideToggle();
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
		}

		$("#selectTable").css("font-weight", "");
		$("#selectView").css("font-weight", "");
		$("#selectTable").css("background-color", "");
		$("#selectView").css("background-color", "");

		cleanPage();
		$("#inner-helper").html("<img src='image/loading.gif'/>");
		$.ajax({
			url: gotoUrl,
			success: function(data){
				$("#inner-helper").html(data);
			},
            error:function (jqXHR, textStatus, errorThrown){
            	alert(jqXHR.status + " " + errorThrown);
            }  
		});
		
		$("#" + select).css("font-weight", "bold");
		$("#" + select).css("background-color", "#d0d0ff");
		
		gMode = mode;
	}

	function cleanPage() {
		$("#searchFilter").val("");
		$("#inner-helper").html('');
	}

	function searchWithFilter(filter) {
		var mode = gMode;
		var gotoUrl = "";
		
		if (mode == "table") {
			gotoUrl = "ajax/list-table.jsp?filter=" + filter;
		} else if (mode == "view") {
			gotoUrl = "ajax/list-view.jsp?filter=" + filter;
		}

		$.ajax({
			url: gotoUrl,
			success: function(data){
				$("#inner-helper").html(data);
			},
            error:function (jqXHR, textStatus, errorThrown){
            	alert(jqXHR.status + " " + errorThrown);
            }  
		});
		
	}

	function loadTable(tName) {
		var tableName = tName;
		$("#inner-detail").html("<img src='image/loading.gif'/>");

		$.ajax({
			url: "ajax/detail-help-table.jsp?table=" + tableName + "&t=" + (new Date().getTime()),
			success: function(data){
				$("#inner-detail").html(data);
			},
            error:function (jqXHR, textStatus, errorThrown){
            	alert(jqXHR.status + " " + errorThrown);
            }  
		});	
	}

	function loadView(tName) {
		var tableName = tName;
		$("#inner-detail").html("<img src='image/loading.gif'/>");

		$.ajax({
			url: "ajax/detail-help-table.jsp?table=" + tableName + "&t=" + (new Date().getTime()),
			success: function(data){
				$("#inner-detail").html(data);
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

	function copyPaste(val) {
		$("#qry_stmt").insertAtCaret(" " + val);
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
			
	function newNote() {
		jQuery.fn.stickyNotes.createNote();
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
	
	function showHelp() {
		var id = "idHelp"; //+(new Date().getTime());
		var temp ="<div id='" + id + "' title='Help' >"
		$.ajax({
			url: "ajax/dialog-help.jsp",
			success: function(data){
				temp = temp + data + "</div>";
				$("BODY").append(temp);
				$("#"+id).dialog({ width: 720, height: 400 });
				setMode('table');
			},
            error:function (jqXHR, textStatus, errorThrown){
                alert(jqXHR.status + " " + errorThrown);
            }  
		});				
	}
	