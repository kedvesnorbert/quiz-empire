function show_questiondata(a, b, c, d, e, f, g, h, i, j, k, l, m, n){
	$('#dialogQuestionData').html("<div id='d_qd_header'><span id='dspans_title'>ID: </span>" + a + "<br><span id='dspans_title'>Témakör: </span>" + b + "<br><span id='dspans_title'>Beküldő: </span>" + c + " (<i>" + d + "</i>)<br>" + "</div><hr><br><center><b><span id='dd_question'></span></b><br><br><u><span id='dd_ans1'></span></u><br><span id='dd_ans2'></span><br><span id='dd_ans3'></span><br><span id='dd_ans4'></span></center><br><hr><span id='dspans_title'>Nehézség: </span>" + j + "<br><span id='dspans_title'>Aktivitás: </span>" + k + "<br><span id='dspans_title'>Ellenőrzés: </span>" + l + "<br><span id='dspans_title'>Népszerűség: </span>" + n);
	e = decodeURIComponent((e + '').replace(/\+/g, '%20'));
	f = decodeURIComponent((f + '').replace(/\+/g, '%20'));
	g = decodeURIComponent((g + '').replace(/\+/g, '%20'));
	h = decodeURIComponent((h + '').replace(/\+/g, '%20'));
	i = decodeURIComponent((i + '').replace(/\+/g, '%20'));
	$('#dd_question').append(document.createTextNode(e));
	$('#dd_ans1').append(document.createTextNode(f));
	$('#dd_ans2').append(document.createTextNode(g));
	$('#dd_ans3').append(document.createTextNode(h));
	$('#dd_ans4').append(document.createTextNode(i));

	$("#dialogQuestionData").dialog({
		maxWidth: 600,
		width: 600,
		height: 475,
		modal: true,
		open: function (event, ui) {
			$(".ui-dialog-titlebar-close").hide();
		},
		position: { my: 'top', at: 'top+150' },
		buttons: {
			"Bezárás": function () {
				$(this).dialog('destroy');
			}
		}
	});
}

function show_questioncomments(x) {
	$('#dialogQuestionComments').html("<br><center><div id='title_div'>A/Az " + x + " ID-jű kérdés megjegyzései</div><br><div id='content_div'><div id = 'loading_questiondiv'> </div></div>");

	jQuery.ajax({
		type: "POST",
		url: "ajax/load_question_comments.php",
		data: { questionid: x },
		cache: false,
		beforeSend: function () {
			$('#loading_questiondiv').append('<div id="loading_showquestiondiv" style="margin-top:10px;margin-bottom:10px;">Hozzászólások betöltése...<br><br><img src="../documents/images/ajax-loader.gif" alt="Feldolgozás folyamatban..." width="6%"></div>')
		},
		success: function (data) {
			setTimeout(function () {
				$("#loading_questiondiv").remove();
				$('#content_div').append(data);
			}, 1000);
		},
		fail: function () {
			alert("Failed!");
		}
	});

	$("#dialogQuestionComments").dialog({
		width: 700,
		height: 450,
		modal: true,
		open: function (event, ui) {
			$(".ui-dialog-titlebar-close").hide();
		},
		position: { my: 'top', at: 'top+150' },
		buttons: {
			"Bezárás": function () {
				$(this).dialog('destroy');
			}
		}
	});
}

function add_revoke_word(i){
	if ($('#q_words_ta').val().indexOf($('#idbtn' + i).text()) >= 0){
		$('#q_words_ta').val($('#q_words_ta').val().replace(($('#idbtn' + i).text() + ","), ''));
		$('#idbtn' + i).css('background-color', '');
	}
	else{
		$('#q_words_ta').val($('#q_words_ta').val() + $('#idbtn' + i).text() + ",");
		$('#idbtn' + i).css('background-color', '#ff7a7a');
	}
}

function show_similarquestions(x, y, z, r){
	Array.prototype.diff = function (arr2) {
		var ret = [];
		this.sort();
		arr2.sort();
		for (var i = 0; i < this.length; i += 1) {
			if (arr2.indexOf(this[i]) == -1) {
				ret.push(this[i]);
			}
		}
		return ret;
	};

	$('#dialogSimilarQuestions').html("<textarea id='q_words_ta'></textarea><center><div id='q_search_btns'></div><br><br><div id='questiongiven_div'></div><div id = 'loading_similiarquestions_div'></div><div id='questionscontent_div'><center><font color='red'>Kattints a szavakra, amelyekre rá szeretnél keresni a kérdések szövegében, majd lépj a Keresés gombra!</font></center></div></center>");
	y = decodeURIComponent((y + '').replace(/\+/g, '%20'));
	z = decodeURIComponent((z + '').replace(/\+/g, '%20'));
	t = y;
	$('#questiongiven_div').html("<center><b><span id='question_span'></span> ( <i><span id='ans1_span'></span> )</i></b></center><br>");
	
	$('#question_span').append(document.createTextNode(t));
	$('#ans1_span').append(document.createTextNode(z));
	
	y = y.split(/\s+/).join(' ').toLowerCase();
	y = y.replace(/[\/\\#,+()$~%:?<>{}]/g, '');
	y = y.split(/[ ]/);
	y = Array.from(new Set(y));

	if(x == 1){
		y = y.diff(hun_stopwords);
	}
	else{
		y = y.diff(eng_stopwords);
	}
	
	for(var i=0; i< y.length; ++i){
		$('#q_search_btns').append("<button class='search_wbtns' id='idbtn" + i + "' onclick='add_revoke_word(" + i + ")'>" + y[i] + "</button>");
	}
	
	$("#dialogSimilarQuestions").dialog({
		width: 900,
		height: 550,
		modal: true,
		open: function (event, ui) {
			$(".ui-dialog-titlebar-close").hide();
		},
		position: { my: 'top', at: 'top+150' },
		buttons: {
			"Keresés": function () {
				var modified_string = $('#q_words_ta').val();
				if(modified_string.length < 1){
					alert("Nem választottál ki egy szót sem a kereséshez!");
				}
				else{
					jQuery.ajax({
						type: "POST",
						url: "ajax/load_similar_questions.php",
						data: { qstring: modified_string, qid: r },
						cache: false,
						beforeSend: function () {
							$('#loading_similiarquestions_div').append('<div id="loading_showquestiondiv" style="margin-top:10px;margin-bottom:10px;">Betöltés folyamatban...<br><br><img src="../documents/images/ajax-loader.gif" alt="Feldolgozás folyamatban..." width="6%"></div>');
							$('#questionscontent_div').html('');
						},
						success: function (data) {
							setTimeout(function () {
								$("#loading_similiarquestions_div").html('');
								$('#questionscontent_div').html(data);
							}, 1000);
						},
						fail: function () {
							alert("Failed!");
						}
					});
				}
			},
			"Bezárás": function () {
				$(this).dialog('destroy');
			}
		}
	});
}

function accept_question(x){
	$('#dialogAcceptQuestion').html("<center><div id='acceptquestion_title'>Biztos, hogy ELFOGADOD a/az <u><i>" + x + "</i></u> azonosítójú kérdést?</div></center><input type='checkbox' id='accept_statement'>Kijelentem, hogy elolvastam a kérdés adatlapját, megjegyzéseit és ellenőriztem, hogy nem duplikált a kérdés.");

	if (x > 0 && x.match(/^[0-9]+$/)) {
		$("#dialogAcceptQuestion").dialog({
			maxWidth: 600,
			width: 600,
			height: 275,
			modal: true,
			open: function (event, ui) {
				$(".ui-dialog-titlebar-close").hide();
			},
			position: { my: 'top', at: 'top+150' },
			buttons: {
				"Elfogadás": function () {
					if ($('#accept_statement').prop("checked") == false) {
						alert("A folytatáshoz el kell fogadni a feltételt! Jelöld be a négyzetet!");
					}
					else {
						jQuery.ajax({
							type: "POST",
							url: "ajax/accept_question.php",
							data: { p_questionid: x },
							dataType: "json",
							cache: false,
							success: function (data) {
								if (data.resp == "ok") {
									$('.mainrowQuestion' + x).remove();
									$('.detailsQuestion' + x).remove();
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
	else {
		alert("Hibás bemeneti adat!");
	}
}

function get_selected_modreason() {
	var com = $("#select_moderator_reason option:selected").text();
	var x = $('.moderator_reasontextarea').attr('id');
	$('#' + x).append(" " + com);
}

function sendback_forupdate(x){
	$("#dialogSendBackForUpdate").html("<center><div id='sendbackquestion_title'>Biztos, hogy visszaküldöd javításra a/az <u><i>" + x + "</i></u> azonosítójú kérdést?</div></center><br><select id='select_moderator_reason' onchange='get_selected_modreason()'><option value='' disabled selected>Válassz okot, vagy írj sajátot!</option><option value='1'>(Túl sok) Helyesírási hiba!.</option><option value='2'>Rossz témakörválasztás.</option><option value='3'>Hibás adat/Helytelen a kérdés.</option><option value='4'>A kérdés túl bonyolult/nem egyértelmű a megfogalmazás.</option></select><br><textarea id='moderator_reasontextarea'" + x + " class='moderator_reasontextarea'></textarea><span style='font-style:italic;font-size:12pt;'>A fenti textbox-ban megadott moderátori szöveg fog hozzáfűződni a kérdés commentjeihez és jut el a felhasználóhoz.</span>\n");
	$("#dialogSendBackForUpdate").dialog({
		maxWidth: 650,
		width: 650,
		height: 400,
		modal: true,
		open: function (event, ui) {
			$(".ui-dialog-titlebar-close").hide();
		},
		position: { my: 'top', at: 'top+150' },
		buttons: {
			"Visszaküldés javításra": function () {
				var moderator_comment = $('.moderator_reasontextarea').val();
				
				if (x < 1 || !x.match(/^[0-9]+$/)) {
					alert("Hibás kérdésazonosító!");
				}
				else if (moderator_comment.length < 5 || moderator_comment.length > 400) {
					alert('A moderátori comment 5-400 karakter lehet és csak betűket/számokat/szóközöket tartalmazhat!');
				}
				else {
					jQuery.ajax({
						type: "POST",
						url: "ajax/sendback_question_forupdate.php",
						data: { p_questionid: x, p_moderatorcomment: moderator_comment },
						dataType: "json",
						cache: false,
						success: function (data) {
							if (data.resp == "ok") {
								$('.mainrowQuestion' + x).remove();
								$('.detailsQuestion' + x).remove();
							}
							else {
								alert(data.resp);
							}
						},
						fail: function () {
							alert("Failed!");
						}
					});
				}
				$(this).dialog('destroy');
			},
			"Mégsem": function () {
				$(this).dialog('destroy');
			}
		}
	});
}

function get_selected_moddelreason() {
	var com = $("#select_moderator_deletereason option:selected").text();
	var x = $('.moderator_delreasontextarea').attr('id');
	$('#' + x).append(" " + com);
}

function reject_question(x) {
	$("#dialogRejectQuestion").html("<center><div id='rejectquestion_title'>Biztos, hogy törlöd a/az <u><i>" + x + "</i></u> azonosítójú kérdést?</div></center><br><select id='select_moderator_deletereason' onchange='get_selected_moddelreason()'><option value='' disabled selected>Válassz okot, vagy írj sajátot!</option><option value='1'>(Túl sok) Helyesírási hiba!.</option><option value='2'>Rossz témakörválasztás.</option><option value='3'>Hibás adat/Helytelen a kérdés.</option><option value='4'>A kérdés túl bonyolult/nem egyértelmű a megfogalmazás.</option><option value='5'>Tiltott témájú kérdés.</option></select><br><textarea id='moderator_delreasontextarea'" + x + " class='moderator_delreasontextarea'></textarea><span style='font-style:italic;font-size:12pt;'>A fenti textbox-ban megadott moderátori szöveg fog hozzáfűződni a kérdés commentjeihez és jut el a felhasználóhoz.</span><br><span id='minusp_title'>Pontszám levonása</span> <input type='text' id='minuspoints' placeholder='0-100 közötti érték' value='0' maxlength='3'><br><span style='font-style:italic;font-size:12pt;'>Csak 0 és 100 közötti pontszám vonható le!</span>\n");
	$("#dialogRejectQuestion").dialog({
		maxWidth: 650,
		width: 650,
		height: 450,
		modal: true,
		open: function (event, ui) {
			$(".ui-dialog-titlebar-close").hide();
		},
		position: { my: 'top', at: 'top+150' },
		buttons: {
			"Elutasítás": function () {
				var moderator_delcomment = $('.moderator_delreasontextarea').val();
				var moderator_minuspoints = $('#minuspoints').val();
				if (x < 1 || !x.match(/^[0-9]+$/)) {
					alert("Hibás kérdésazonosító!");
				}
				else if (moderator_delcomment.length < 5 || moderator_delcomment.length > 400) {
					alert('A moderátori comment 5-400 karakter lehet és csak betűket/számokat/szóközöket tartalmazhat!');
				}
				else if (moderator_minuspoints < 0 || moderator_minuspoints > 100 || !moderator_minuspoints.match(/^[0-9]+$/)) {
					alert("A mínuszpontok 0-100 közötti érték lehet!");
				}
				else {
					jQuery.ajax({
						type: "POST",
						url: "ajax/reject_question.php",
						data: { p_questionid: x, p_moderatorcomment: moderator_delcomment, p_minuspoints: moderator_minuspoints },
						dataType: "json",
						cache: false,
						success: function (data) {
							if (data.resp == "ok") {
								$('.mainrowQuestion' + x).remove();
								$('.detailsQuestion' + x).remove();
							}
							else {
								alert(data.resp);
							}
						},
						fail: function () {
							alert("Failed!");
						}
					});
				}
				$(this).dialog('destroy');
			},
			"Mégsem": function () {
				$(this).dialog('destroy');
			}
		}
	});
}

function inactivate_question(x){
	$("#dialogInactivateQuestion").html("<center><div id='inactivatequestion_title'>Biztos, hogy inaktiválod a/az <u><i>" + x + "</i></u> azonosítójú kérdést?</div></center><br><p id='note_inactivateq'>Ennek hatására a kérdés nem fog megjelenni a kvízek során.</p>");
	$("#dialogInactivateQuestion").dialog({
		maxWidth: 650,
		width: 650,
		height: 250,
		modal: true,
		open: function (event, ui) {
			$(".ui-dialog-titlebar-close").hide();
		},
		position: { my: 'top', at: 'top+150' },
		buttons: {
			"Inaktiválás": function () {
				if (x < 1 || !x.match(/^[0-9]+$/)) {
					alert("Hibás kérdésazonosító!");
				}
				else {
					jQuery.ajax({
						type: "POST",
						url: "ajax/question_activation.php",
						data: { p_questionid: x, p_action: 0 },
						dataType: "json",
						cache: false,
						success: function (data) {
							if (data.resp == "ok") {
								$("#inactivateQuestion" + x).replaceWith("<button class='activateQuestion' id='activateQuestion" + x + "' onclick='activate_question(\"" + x + "\")'>Kérdés aktiválása</button>");
							}
							else {
								alert(data.resp);
							}
						},
						fail: function () {
							alert("Failed!");
						}
					});
				}
				$(this).dialog('destroy');
			},
			"Mégsem": function () {
				$(this).dialog('destroy');
			}
		}
	});
}

function activate_question(x) {
	$("#dialogActivateQuestion").html("<center><div id='inactivatequestion_title'>Biztos, hogy aktiválod a/az <u><i>" + x + "</i></u> azonosítójú kérdést?</div></center><br><p id='note_inactivateq'>Ennek hatására a kérdés újra megjelenhet a kvízek során.</p>");
	$("#dialogActivateQuestion").dialog({
		maxWidth: 650,
		width: 650,
		height: 250,
		modal: true,
		open: function (event, ui) {
			$(".ui-dialog-titlebar-close").hide();
		},
		position: { my: 'top', at: 'top+150' },
		buttons: {
			"Aktiválás": function () {
				if (x < 1 || !x.match(/^[0-9]+$/)) {
					alert("Hibás kérdésazonosító!");
				}
				else {
					jQuery.ajax({
						type: "POST",
						url: "ajax/question_activation.php",
						data: { p_questionid: x, p_action: 1 },
						dataType: "json",
						cache: false,
						async: false,
						success: function (data) {
							if (data.resp == "ok") {
								$("#activateQuestion" + x).replaceWith("<button class='inactivateQuestion' id='inactivateQuestion" + x + "' onclick='inactivate_question(\"" + x + "\")'>Kérdés inaktiválása</button>");
							}
							else {
								alert(data.resp);
							}
						},
						fail: function () {
							alert("Failed!");
						}
					});
				}
				$(this).dialog('destroy');
			},
			"Mégsem": function () {
				$(this).dialog('destroy');
			}
		}
	});
}

function update_question_secret(x, y){
	$(".dialogUpdateQuestionSecret" + x).html("<br><center><div id='title_div'>A/Az " + x + " ID-jű kérdés módosítása</div></center><br><div id='content_div_up' class='content_div_up" + x + "'><center><div id = 'loading_questiondiv'> </div></center></div>");

	jQuery.ajax({
		type: "POST",
		url: "ajax/load_questiondata_forupdate.php",
		data: { questionid: x, themaid: y },
		cache: false,
		beforeSend: function () {
			$('#loading_questiondiv').append('<div id="loading_showquestiondiv" style="margin-top:10px;margin-bottom:10px;">Adatok betöltése...<br><br><img src="../documents/images/ajax-loader.gif" alt="Feldolgozás folyamatban..." width="6%"></div>')
		},
		success: function (data) {
			setTimeout(function () {
				$("#loading_questiondiv").remove();
				$('.content_div_up' + x).append(data);
				$(".select_questiontext_forupdate" + x).val(decodeURIComponent(($(".select_questiontext_forupdate" + x).val() + '').replace(/\+/g, '%20')));
				$(".select_ans1_forupdate" + x).val(decodeURIComponent(($(".select_ans1_forupdate" + x).val() + '').replace(/\+/g, '%20')));
				$(".select_ans2_forupdate" + x).val(decodeURIComponent(($(".select_ans2_forupdate" + x).val() + '').replace(/\+/g, '%20')));
				$(".select_ans3_forupdate" + x).val(decodeURIComponent(($(".select_ans3_forupdate" + x).val() + '').replace(/\+/g, '%20')));
				$(".select_ans4_forupdate" + x).val(decodeURIComponent(($(".select_ans4_forupdate" + x).val() + '').replace(/\+/g, '%20')));
			}, 1000);
		},
		fail: function () {
			alert("Failed!");
		}
	});

	$(".dialogUpdateQuestionSecret"+x).dialog({
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
					alert("Hibás kérdésazonosító!");
				}
				else {
					var p_themaid = $('.select_thema_forupdate'+x).val();
					var p_diff = $('.select_diff_forupdate' + x).val();
					var p_question = $('.select_questiontext_forupdate' + x).val();
					var p_ans1 = $('.select_ans1_forupdate' + x).val();
					var p_ans2 = $('.select_ans2_forupdate' + x).val();
					var p_ans3 = $('.select_ans3_forupdate' + x).val();
					var p_ans4 = $('.select_ans4_forupdate' + x).val();
					var p_reverifiy = $('.select_makeunverified' + x).prop("checked");
					if(p_reverifiy == true){
						p_reverifiy = 1;
					}
					else{
						p_reverifiy = 0;
					}

					if (p_themaid <= 0 || !p_themaid.match(/^[0-9]+$/)) {
						alert('Válaszd ki a témakört!');
					}
					else if (p_question.length < 1) {
						alert('Nem írtál be semmit a kérdéshez!');
					}
					else if (p_ans1.length < 1) {
						alert('Nem írtál be semmit a helyes válaszhoz!');
					}
					else if (p_ans2.length < 1) {
						alert('Nem írtál be semmit az 1. helytelen válaszhoz!');
					}
					else if (p_ans3.length < 1) {
						alert('Nem írtál be semmit az 2. helytelen válaszhoz!');
					}
					else if (p_ans4.length < 1) {
						alert('Nem írtál be semmit az 3. helytelen válaszhoz!');
					}
					else if (p_question.length > 254) {
						alert('A kérdés hossza MAX 254 karakter lehet!');
					}
					else if (p_ans1.length > 150 || p_ans2.length > 150 || p_ans3.length > 150 || p_ans4.length > 150) {
						alert('A válaszok hossza MAX 150 karakter lehet!');
					}
					else if (p_diff < 1 || p_diff > 2 || !p_diff.match(/^[0-9]+$/)) {
						alert('Válaszd ki a nehézségi szintet!');
					}
					else if (p_ans1 == p_ans2 || p_ans1 == p_ans3 || p_ans1 == p_ans4 || p_ans2 == p_ans3 || p_ans2 == p_ans4 || p_ans3 == p_ans4 || p_question == p_ans1 || p_question == p_ans2 || p_question == p_ans3 || p_question == p_ans4) {
						alert('Mindenik válasz különböző kell legyen, valamint a kérdés sem lehet egyenlő a válaszok bármelyikével!');
					}
					else{
						jQuery.ajax({
							type: "POST",
							url: "ajax/update_question_in_secret.php",
							data: { p_questionid: x, p_themaid: p_themaid, p_diff: p_diff, p_questiontext: p_question, p_ans1: p_ans1, p_ans2: p_ans2, p_ans3: p_ans3, p_ans4: p_ans4, p_reverify: p_reverifiy },
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

function delete_question(x){
	$("#dialogDeleteQuestion").html("<center><div id='deletequestion_title'>Biztos, hogy TÖRLÖD a/az <u><i>" + x + "</i></u> azonosítójú kérdést?</div></center><br><p id='note_delq'>Ennek hatására a kérdés végleg törlődik az adatbáziból és nyoma sem marad.</p>");
	$("#dialogDeleteQuestion").dialog({
		maxWidth: 650,
		width: 650,
		height: 250,
		modal: true,
		open: function (event, ui) {
			$(".ui-dialog-titlebar-close").hide();
		},
		position: { my: 'top', at: 'top+150' },
		buttons: {
			"Törlés véglegesen": function () {
				if (x < 1 || !x.match(/^[0-9]+$/)) {
					alert("Hibás kérdésazonosító!");
				}
				else {
					jQuery.ajax({
						type: "POST",
						url: "ajax/delete_question_permanently.php",
						data: { p_questionid: x },
						dataType: "json",
						cache: false,
						async: false,
						success: function (data) {
							if (data.resp == "ok") {
								$('.mainrowQuestion' + x).remove();
								$('.detailsQuestion' + x).remove();
							}
							else {
								alert(data.resp);
							}
						},
						fail: function () {
							alert("Failed!");
						}
					});
				}
				$(this).dialog('destroy');
			},
			"Mégsem": function () {
				$(this).dialog('destroy');
			}
		}
	});
}

$(document).ready(function () {
	$(".toggler_question").click(function (e) {
		e.preventDefault();
		$('.detailsQuestion' + $(this).attr('data-prod')).toggle();
	});
});