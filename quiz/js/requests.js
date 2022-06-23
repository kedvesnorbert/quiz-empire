$(document).ready(function(){
    $(".toggler").click(function(e){
        e.preventDefault();
        $('#detail'+$(this).attr('data-prod-cat')).toggle();
    });
});

function accomplish_req(x, y, z){
	var v_height = 230;
	var anonymous = 0;
	$('#dialogAccomplishRequest').html("<center><br>Elvállalod a/az <b>" + y + " </b>nevű kérés teljesítését?<br><br><b><font color='red'>Figyelem: </font></b>Csak egyszer van lehetőséged erre a műveletre.</center><br>");
	if(z == 1){
		$('#dialogAccomplishRequest').append("<input type='checkbox' id='anonymuskent' style='width:20px;height:20px;'>Teljesítés Anonymusként<br>(Megjegyzés: Jelöld be a fenti négyzetet, ha névtelenűl szeretnél a folyamat során szerepelni.)");
		v_height = 310;
	}
	$("#dialogAccomplishRequest").dialog({
		maxWidth:600,
		width:600,
		height:v_height,
		modal:true,
		open: function(event, ui) {
			$(".ui-dialog-titlebar-close").hide();
		},
		position: { my: 'top', at: 'top+150' },
		buttons: {
			"Igen": function(){
				if($("#anonymuskent").is(":checked")){
					anonymous = 1;
				}
				else{
					anonymous = 0;
				}
				jQuery.ajax({
					type: "POST",
					url: "ajax/accomplishrequest.php",
					data: {req_id: x, req_anonymous: anonymous},
					dataType: "json",
					cache: false,
					success: function(data){
						if(data.resp == "mindenok"){
							$('#spanbutton'+x).text("Folyamatban...");
							alert("Sikeresen jelentkeztél a kérés teljesítésére!");
						}
						else{
							alert(data.resp);
						}
					},
					fail: function(){
						alert("Failed!");
					}
					
				});
				$(this).dialog('destroy');
				
			},
			"Nem": function(){
				$(this).dialog('destroy');
			}
		}
	});	
}

function offerPoints(x){
	var offered_points = $('#myoffer'+x).val();
	if(offered_points.length == 0){
		alert("Nem írtál be semmit!");
	}
	else if(!offered_points.match(/^[0-9]+$/)){
		alert("Helyes pontértéket adj meg!");
	}
	else if(offered_points < 30){
		alert("Legalább 30 pontot kötelező megadni!");
	}
	else if(offered_points > 10000000){
		alert("Legfeljebb 10000000 pontot adhatsz meg!");
	}
	else if(!x.match(/^[0-9]+$/) || x < 1){
		alert("Hibás kérés azonosító!");
	}
	else{
		jQuery.ajax({
			type: "POST",
			url: "ajax/offerpoints.php",
			data: {reqoff_id: x, reqoff_points: offered_points},
			dataType: "json",
			cache: false,
			success: function(data){
				if(data.resp.match(/^[0-9]+$/)){
					$('#requestpoints'+x).text(data.resp);
					$('#myoffer'+x).val('');
					alert("Hozzáadtuk a felajánlott pontmennyiséget a kéréshez!");
				}
				else{
					alert(data.resp);
				}
			},
			fail: function(){
				alert("Failed!");
			}
			
		});
	}
}

function delete_myrequest(x, y){
	$('#dialogDelMyRequest').html("<center><br>Biztosan törölni szeretnéd a/az <b><u>" + y + "</u></b> nevű kérésedet?<br><br>Írd be a törlés okát!<br></center><br>");
	$('#dialogDelMyRequest').append("<center><input type='text' id='delreqreason' style='width:450px;height:25px;margin-bottom:10px;' maxlength='150'><br><i>(Megjegyzés: Ez a művelet nem vonható vissza.)</i></center>");
	
	$("#dialogDelMyRequest").dialog({
		maxWidth:600,
		width:600,
		height:300,
		modal:true,
		open: function(event, ui) {
			$(".ui-dialog-titlebar-close").hide();
		},
		position: { my: 'top', at: 'top+150' },
		buttons: {
			"Törlés": function(){
				var del_reason = $('#delreqreason').val();
				if(del_reason.length < 5){
					alert("A törlés oka legalább 5 karakterből álljon!");
				}
				else if(del_reason.length > 150){
					alert("A törlés oka legfeljebb 150 karakter lehet!");
				}
				else{
					jQuery.ajax({
						type: "POST",
						url: "ajax/delete_request.php",
						data: {delreq_id: x, delreq_reason: del_reason},
						dataType: "json",
						cache: false,
						success: function(data){
							if(data.resp == "mindenok"){
								var newRow = '<tr style="background-color:#7ED07E;"><td colspan="9"><i>&emsp;&emsp;Ezt a kérést törölték!<br>&emsp;&emsp;Nem áll rendelkezésre további információ!</i></td></tr>';
								$('#detail'+x).replaceWith(newRow);
								$('#requestpoints'+x).html("<i>0</i>");
								$('#requestvoters'+x).html("<i>0</i>");
								$('#requestquestions'+x).html("<i>0</i>");
								$('#requestusername'+x).html("<i>Nincs információ</i>");
								$('#requestdatetime'+x).html("<i>Nincs információ</i>");
								$('#spanbutton'+x).html("<i>Törölve</i>");
								alert("A kérésed törölve lett!");
							}
							else{
								alert(data.resp);
							}
						},
						fail: function(){
							alert("Failed!");
						}
						
					});
				}
				$(this).dialog('destroy');
			},
			"Mégsem": function(){
				$(this).dialog('destroy');
			}
		}
	});
}

function show_sentreqquestions(x, y){
	$('#dialogShowReqQuestionList').html("<br><center><div id='title_div'>" + y + " </div><br><br><div id='content_div'><div id = 'loading_reqquestiondiv'> </div></div>");
	
	jQuery.ajax({
		type: "POST",
		url: "ajax/load_reqquestions_towatch.php",
		data: {quizid: x},
		cache: false,
		beforeSend: function(){
			$('#loading_reqquestiondiv').append('<div id="loading_showquestiondiv" style="margin-top:10px;margin-bottom:10px;">Kérdések betöltése...<br><br><img src="documents/images/ajax-loader.gif" alt="Feldolgozás folyamatban..." width="6%"></div>')
		},
		success: function(data){
			setTimeout(function(){
				$("#loading_reqquestiondiv").remove();
				$('#content_div').append(data);
				
			}, 1500);
		},
		fail: function(){
			alert("Failed!");
		}
		
	});
	
	$("#dialogShowReqQuestionList").dialog({
		width:1000,
		height:650,
		modal:true,
		my: "center",
		at: "center",
		of: window, 
		open: function(event, ui) {
			$(".ui-dialog-titlebar-close").hide();
		},
		buttons: {
			"Bezárás": function(){
				$(this).dialog('destroy');
			}
		}
	});
	
}