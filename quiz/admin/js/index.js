function adminlog_out(){
	jQuery.ajax({
		type: "POST",
		url: "ajax/adminlogout.php",
		cache:false,
		data: {},
		success: function(data){
			location.reload();
		},
		fail: function(){
			alert('AJAX failed!');
		}
	});
}

function modify_competition(x, y){
	$("#dialogModifyCompetition" + x).html("<br><center><div id='title_div'>A/Az " + x + " ID-jű verseny módosítása</div></center><br><div id='content_div_up' class='content_div_up" + x + "'><center><div id = 'loading_competitiondiv'> </div></center></div>");

	jQuery.ajax({
		type: "POST",
		url: "ajax/load_competitiondata_forupdate.php",
		data: { competitionid: x, themaid: y },
		cache: false,
		beforeSend: function () {
			$('#loading_competitiondiv').append('<div id="loading_showquestiondiv" style="margin-top:10px;margin-bottom:10px;">Adatok betöltése...<br><br><img src="../documents/images/ajax-loader.gif" alt="Feldolgozás folyamatban..." width="6%"></div>')
		},
		success: function (data) {
			setTimeout(function () {
				$("#loading_competitiondiv").remove();
				$('.content_div_up' + x).append(data);
			}, 1000);
		},
		fail: function () {
			alert("Failed!");
		}
	});

	$("#dialogModifyCompetition" + x).dialog({
		maxWidth: 650,
		width: 650,
		height: 550,
		modal: true,
		open: function (event, ui) {
			$(".ui-dialog-titlebar-close").hide();
		},
		position: { my: 'top', at: 'top+150' },
		buttons: {
			"Módosítás": function () {
				if (x < 1 || !x.match(/^[0-9]+$/)) {
					alert("Hibás versenyazonosító!");
				}
				else {
					var p_themaid = $('.select_thema_forupdate' + x).val();
					var p_color = $('.select_color_forupdate' + x).val();
					var p_announcement = $('.select_anouncementdate_forupdate' + x).val();
					var p_startdate = $('.select_startdate_forupdate' + x).val();
					var p_enddate = $('.select_enddate_forupdate' + x).val();
					var p_activity = $('.select_activity_forupdate' + x).val();
					var p_rew1 = $('.select_reward1_forupdate' + x).val();
					var p_rew2 = $('.select_reward2_forupdate' + x).val();
					var p_rew3 = $('.select_reward3_forupdate' + x).val();
					var p_rew4 = $('.select_reward4_forupdate' + x).val();
					var p_rew5 = $('.select_reward5_forupdate' + x).val();
					var p_rew6 = $('.select_reward6_forupdate' + x).val();
					var p_rew7 = $('.select_reward7_forupdate' + x).val();

					if (p_themaid <= 0 || !p_themaid.match(/^[0-9]+$/)) {
						alert('Válaszd ki a témakört!');
					}
					else if (p_color.length < 1) {
						alert('Nem választottál ki színt!');
					}
					else if (p_color.length > 7 || !p_color.match(/[#]{1}[a-fA-F0-9]{6}$/)){
						alert('Helytelen szín érték!');
					}
					else if (p_announcement.length < 1) {
						alert('Nem választottad ki a bejelentés idejét!');
					}
					else if (!p_announcement.match(/([12]\d{3}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01]))$/)){
						alert('Helytelen a bejelentés ideje!');
					}
					else if (p_startdate.length < 1) {
						alert('Nem írtál be semmit az kezdés dátumához!');
					}
					else if (!p_startdate.match(/^\d\d\d\d-(0?[1-9]|1[0-2])-(0?[1-9]|[12][0-9]|3[01]) (([0-1]{1}[0-9]{1})|([2-2]{1}[0-3]{1})):([0-9]|[0-5][0-9]):([0-9]|[0-5][0-9])$/)){
						alert('Helytelen a kezdés dátuma!');
					}
					else if (p_enddate.length < 1) {
						alert('Nem írtál be semmit a lezárulás dátumához!');
					}
					else if (!p_enddate.match(/^\d\d\d\d-(0?[1-9]|1[0-2])-(0?[1-9]|[12][0-9]|3[01]) (([0-1]{1}[0-9]{1})|([2-2]{1}[0-3]{1})):([0-9]|[0-5][0-9]):([0-9]|[0-5][0-9])$/)) {
						alert('Helytelen a lezárulás dátuma!');
					}
					else if (p_activity != 0 && p_activity != 1) {
						alert('Válaszd ki az aktivitást!');
					}
					else if (p_rew1.length < 1 || !p_rew1.match(/^[0-9]+$/) || p_rew1 > 25000 || p_rew1 < 100) {
						alert('A jutalom 1 mező értéke minimum 100 és maximum 25000 pont lehet!');
					}
					else if (p_rew2.length < 1 || !p_rew2.match(/^[0-9]+$/) ) {
						alert('Helytelen a jutalom 2 mező értéke!');
					}
					else if (p_rew3.length < 1 || !p_rew3.match(/^[0-9]+$/)) {
						alert('Helytelen a jutalom 3 mező értéke!');
					}
					else if (p_rew4.length < 1 || !p_rew4.match(/^[0-9]+$/)) {
						alert('Helytelen a jutalom 4 mező értéke!');
					}
					else if (p_rew5.length < 1 || !p_rew5.match(/^[0-9]+$/)) {
						alert('Helytelen a jutalom 5 mező értéke!');
					}
					else if (p_rew6.length < 1 || !p_rew6.match(/^[0-9]+$/)) {
						alert('Helytelen a jutalom 6 mező értéke!');
					}
					else if (p_rew7.length < 1 || !p_rew7.match(/^[0-9]+$/)) {
						alert('Helytelen a jutalom 7 mező értéke!');
					}
					else if (parseInt(p_rew1) <= parseInt(p_rew2) || parseInt(p_rew2) <= parseInt(p_rew3) || parseInt(p_rew3) <= parseInt(p_rew4) || parseInt(p_rew4) <= parseInt(p_rew5) || parseInt(p_rew5) <= parseInt(p_rew6) || parseInt(p_rew6) <= parseInt(p_rew7)) {
						alert('A jutalmak nagysága szigorúan csökkenő érték legyen az elsőtől az utolsóig!');
					}
					else {
						jQuery.ajax({
							type: "POST",
							url: "ajax/update_competition.php",
							data: { p_competitionid: x, p_themaid: p_themaid, p_color: p_color, p_announcement: p_announcement, p_startdate: p_startdate, p_enddate: p_enddate, p_activity: p_activity, p_rew1: p_rew1, p_rew2: p_rew2, p_rew3: p_rew3, p_rew4: p_rew4, p_rew5: p_rew5, p_rew6: p_rew6, p_rew7: p_rew7 },
							dataType: "json",
							cache: false,
							async: false,
							success: function (data) {
								if (data.resp == "ok") {
									location.reload();
								}
								else {
									alert(data.resp);
								}
							},
							fail: function () {
								alert("Failed!");
							}
						});
						$(this).dialog('destroy');
					}
				}
			},
			"Mégsem": function () {
				$(this).dialog('destroy');
			}
		}
	});
}

function new_competition(){
	$("#dialogNewCompetition").html("<br><center><div id='title_div'>Új verseny</div></center><br><div id='content_div_up1'><center><div id = 'loading_competitiondiv'> </div></center></div>");

	jQuery.ajax({
		type: "POST",
		url: "ajax/load_competitiondata_tocreate.php",
		data: { },
		cache: false,
		beforeSend: function () {
			$('#loading_competitiondiv').append('<div id="loading_showquestiondiv" style="margin-top:10px;margin-bottom:10px;">Adatok betöltése...<br><br><img src="../documents/images/ajax-loader.gif" alt="Feldolgozás folyamatban..." width="6%"></div>')
		},
		success: function (data) {
			setTimeout(function () {
				$("#loading_competitiondiv").remove();
				$('#content_div_up1').append(data);
			}, 1000);
		},
		fail: function () {
			alert("Failed!");
		}
	});

	$("#dialogNewCompetition").dialog({
		maxWidth: 650,
		width: 650,
		height: 550,
		modal: true,
		open: function (event, ui) {
			$(".ui-dialog-titlebar-close").hide();
		},
		position: { my: 'top', at: 'top+150' },
		buttons: {
			"Létrehozás": function () {
				var p_themaid = $('#select_thema_tocreate').val();
				var p_color = $('#select_color_tocreate').val();
				var p_announcement = $('#select_anouncementdate_tocreate').val();
				var p_startdate = $('#select_startdate_tocreate').val();
				var p_enddate = $('#select_enddate_tocreate').val();
				var p_activity = $('#select_activity_tocreate').val();
				var p_rew1 = $('#select_reward1_tocreate').val();
				var p_rew2 = $('#select_reward2_tocreate').val();
				var p_rew3 = $('#select_reward3_tocreate').val();
				var p_rew4 = $('#select_reward4_tocreate').val();
				var p_rew5 = $('#select_reward5_tocreate').val();
				var p_rew6 = $('#select_reward6_tocreate').val();
				var p_rew7 = $('#select_reward7_tocreate').val();

				if (p_themaid <= 0 || !p_themaid.match(/^[0-9]+$/)) {
					alert('Válaszd ki a témakört!');
				}
				else if (p_color.length < 1) {
					alert('Nem választottál ki színt!');
				}
				else if (p_color.length > 7 || !p_color.match(/[#]{1}[a-fA-F0-9]{6}$/)) {
					alert('Helytelen szín érték!');
				}
				else if (p_announcement.length < 1) {
					alert('Nem választottad ki a bejelentés idejét!');
				}
				else if (!p_announcement.match(/([12]\d{3}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01]))$/)) {
					alert('Helytelen a bejelentés ideje!');
				}
				else if (p_startdate.length < 1) {
					alert('Nem írtál be semmit az kezdés dátumához!');
				}
				else if (!p_startdate.match(/^\d\d\d\d-(0?[1-9]|1[0-2])-(0?[1-9]|[12][0-9]|3[01]) (([0-1]{1}[0-9]{1})|([2-2]{1}[0-3]{1})):([0-9]|[0-5][0-9]):([0-9]|[0-5][0-9])$/)) {
					alert('Helytelen a kezdés dátuma!');
				}
				else if (p_enddate.length < 1) {
					alert('Nem írtál be semmit a lezárulás dátumához!');
				}
				else if (!p_enddate.match(/^\d\d\d\d-(0?[1-9]|1[0-2])-(0?[1-9]|[12][0-9]|3[01]) (([0-1]{1}[0-9]{1})|([2-2]{1}[0-3]{1})):([0-9]|[0-5][0-9]):([0-9]|[0-5][0-9])$/)) {
					alert('Helytelen a lezárulás dátuma!');
				}
				else if (p_activity != 0 && p_activity != 1) {
					alert('Válaszd ki az aktivitást!');
				}
				else if (p_rew1.length < 1 || !p_rew1.match(/^[0-9]+$/) || p_rew1 > 25000 || p_rew1 < 100) {
					alert('A jutalom 1 mező értéke minimum 100 és maximum 25000 pont lehet!');
				}
				else if (p_rew2.length < 1 || !p_rew2.match(/^[0-9]+$/)) {
					alert('Helytelen a jutalom 2 mező értéke!');
				}
				else if (p_rew3.length < 1 || !p_rew3.match(/^[0-9]+$/)) {
					alert('Helytelen a jutalom 3 mező értéke!');
				}
				else if (p_rew4.length < 1 || !p_rew4.match(/^[0-9]+$/)) {
					alert('Helytelen a jutalom 4 mező értéke!');
				}
				else if (p_rew5.length < 1 || !p_rew5.match(/^[0-9]+$/)) {
					alert('Helytelen a jutalom 5 mező értéke!');
				}
				else if (p_rew6.length < 1 || !p_rew6.match(/^[0-9]+$/)) {
					alert('Helytelen a jutalom 6 mező értéke!');
				}
				else if (p_rew7.length < 1 || !p_rew7.match(/^[0-9]+$/)) {
					alert('Helytelen a jutalom 7 mező értéke!');
				}
				else if (parseInt(p_rew1) <= parseInt(p_rew2) || parseInt(p_rew2) <= parseInt(p_rew3) || parseInt(p_rew3) <= parseInt(p_rew4) || parseInt(p_rew4) <= parseInt(p_rew5) || parseInt(p_rew5) <= parseInt(p_rew6) || parseInt(p_rew6) <= parseInt(p_rew7)) {
					alert('A jutalmak nagysága szigorúan csökkenő érték legyen az elsőtől az utolsóig!');
				}
				else {
					jQuery.ajax({
						type: "POST",
						url: "ajax/create_competition.php",
						data: { p_themaid: p_themaid, p_color: p_color, p_announcement: p_announcement, p_startdate: p_startdate, p_enddate: p_enddate, p_activity: p_activity, p_rew1: p_rew1, p_rew2: p_rew2, p_rew3: p_rew3, p_rew4: p_rew4, p_rew5: p_rew5, p_rew6: p_rew6, p_rew7: p_rew7 },
						dataType: "json",
						cache: false,
						async: false,
						success: function (data) {
							if (data.resp == "ok") {
								location.reload();
							}
							else {
								alert(data.resp);
							}
						},
						fail: function () {
							alert("Failed!");
						}
					});
					$(this).dialog('destroy');
				}
				
			},
			"Mégsem": function () {
				$(this).dialog('destroy');
			}
		}
	});
}

function delete_competition(x) {
	$("#dialogDeleteCompetition" + x).html("<br><center><div id='title_div'>Biztos, hogy törlöd a/az " + x + " ID-jű versenyt?</div></center><br><div id='content_delcompetition'><u>Megjegyzés:</u> Ezzel végleg törlésre kerül a verseny. A művelet nem vonható vissza.</div>");

	$("#dialogDeleteCompetition" + x).dialog({
		maxWidth: 650,
		width: 650,
		height: 300,
		modal: true,
		open: function (event, ui) {
			$(".ui-dialog-titlebar-close").hide();
		},
		position: { my: 'top', at: 'top+150' },
		buttons: {
			"Törlés": function () {
				if (x < 1 || !x.match(/^[0-9]+$/)) {
					alert("Hibás versenyazonosító!");
				}
				else {
					jQuery.ajax({
						type: "POST",
						url: "ajax/delete_competition.php",
						data: { p_competitionid: x },
						dataType: "json",
						cache: false,
						async: false,
						success: function (data) {
							if (data.resp == "ok") {
								location.reload();
							}
							else {
								alert(data.resp);
							}
						},
						fail: function () {
							alert("Failed!");
						}
					});
					$(this).dialog('destroy');
					
				}
			},
			"Mégsem": function () {
				$(this).dialog('destroy');
			}
		}
	});
}