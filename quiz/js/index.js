function show_start_generalquiz() {
	$('#dialogStartGeneralQuiz').html('<div id="d_quiz_options" style="width:100%; text-align:center; margin-top:20px; margin-bottom:30px;"><br>Betöltés...<br><br><center><img src="documents/images/ajax-loader.gif" width="40" /></center></div>');

	$("#dialogStartGeneralQuiz").dialog({
		maxWidth: 600,
		width: 600,
		height: 440,
		modal: true,
		position: { my: 'top', at: 'top+150' },
		open: function (event, ui) {
			$(".ui-dialog-titlebar-close").hide();

			jQuery.ajax({
				type: "POST",
				url: "ajax/load_quizoptions.php",
				cache: false,
				data: {},
				success: function (data) {
					setTimeout(function () {
						$('#d_quiz_options').html(data);
					}, 500);
				},
				fail: function () {
					alert('AJAX failed!');
				}
			});

		},
		buttons: {
			"Vissza": function () {
				$(this).dialog('destroy');
			}
		}
	});
}

function start_quizsegitseggelgyakorlo(x){
	if(x != -1 && x != -2){
		alert('Hibás paraméterek!');
	}
	else{
		jQuery.ajax({
			type: "POST",
			url: "ajax/startquiz_general.php",
			dataType: "json",
			beforeSend: function(){
				$('#dialogStartGeneralQuiz').dialog('destroy');
			},
			data: {quiztype: x},
			success: function(data){
				if(data.resp == "ok"){
					window.location.href = 'game.php';
				}
				else{
					alert(data.resp);
				}
			},
			fail: function(){
				alert('AJAX failed!');
			}
			
		});
	}
}

function show_next_level(){
	$('#dialogShowNextLevel').html('<div id="d_next_level" style="width:100%; text-align:center; margin-top:20px; margin-bottom:30px;"><br>Betöltés...<br><br><center><img src="documents/images/ajax-loader.gif" width="40" /></center></div>');
	$("#dialogShowNextLevel").dialog({
		maxWidth:600,
		width:600,
		height:250,
		modal:true,
		position: { my: 'top', at: 'top+150' },
		open: function(event, ui) {
			$(".ui-dialog-titlebar-close").hide();
			jQuery.ajax({
				type: "POST",
				url: "ajax/load_nextleveldata.php",
				cache:false,
				data: {},
				success: function(data){
					setTimeout(function(){
						$('#d_next_level').html(data);
					}, 1000);	
				},
				fail: function(){
					alert('AJAX failed!');
				}
			});
		},
		buttons: {
			"Bezárás": function(){
				$(this).dialog('destroy');
			}
		}
	});	
}

function posting_news(){
	$('#dialogPostNews').html('<table border="0" id="d_posting_news" style="width:100%; margin-top:5px; margin-bottom:20px;"><tr><td colspan="2"><input type="text" id="the_newstitle" name="the_newstitle" maxlength="50" placeholder="A hír címe" required><span id="d_requiredspan">(*)</span><tr><td colspan="2"><textarea id="the_newsdescription" name="the_newsdescription" maxlength="3000" placeholder=" A hír tartalma...amely minimum 25 karakterből kell álljon." required></textarea><span id="d_requiredspan">(*)</span><tr><td>Kép feltöltése<td><input type="file" id="the_newsimage" name="the_newsimage"><span id="d_notrequiredspan">Nem kötelező</span><tr><td>Fájlok csatolása<td><input type="file" id="the_newsfiles" name="the_newsfiles" ><span id="d_notrequiredspan">Nem kötelező</span><tr><td colspan="2" id="d_note_img"><span >Megjegyzés: Csak az alábbi képformátumok elfogadottak: .jpg, .jpeg, .png<br>A feltöltendő fájl típusai lehetnek: .zip, .pdf, .docx<br>A kép mérete MAX 2 MB lehet, míg a fájlok mérete összesen 4 MB</span></table>');
	$("#dialogPostNews").dialog({
		maxWidth:600,
		width:620,
		height:500,
		modal:true,
		position: { my: 'top', at: 'top+150' },
		open: function(event, ui) {
			$(".ui-dialog-titlebar-close").hide();
		},
		buttons: {
			"Küldés": function(){
				var newstitle = $("#the_newstitle").val();
				var newdescription = $("#the_newsdescription").val();
				var newskep = "";
				var newsfiles = "";
				
				if(newstitle.length < 5 || newstitle.length > 50){
					alert("A hír címe 5-50 karakter legyen!");
				}
				else if(newdescription.length < 5 || newdescription.length > 3000){
					alert("A hír leírása 25-3000 karakter legyen!");
				}
				else{
					var mindenok = true;
					if(document.getElementById("the_newsimage").files.length == 1)
					{
						var name = document.getElementById("the_newsimage").files[0].name;
						var ext = name.split('.').pop().toLowerCase();
						if(jQuery.inArray(ext, ['gif','png','jpg','jpeg']) == -1) 
						{
							alert("A kép formátuma érvénytelen!");
							mindenok = false;
						}
						var oFReader = new FileReader();
						oFReader.readAsDataURL(document.getElementById("the_newsimage").files[0]);
						var f = document.getElementById("the_newsimage").files[0];
						var fsize = (f.size||f.fileSize)/1024/1024;
						if(fsize > 2)
						{
							alert("A kép mérete túl nagy. Legfeljebb 2 MB méretű kép tölthető fel.");
							mindenok = false;
						}
						if(mindenok == true){
							newskep = document.getElementById('the_newsimage').files[0];
						}
					}
					else{
						newskep = "";
					}
					
					var mindenok_f = true;
					if(document.getElementById("the_newsfiles").files.length == 1)
					{
						var name = document.getElementById("the_newsfiles").files[0].name;
						var ext = name.split('.').pop().toLowerCase();
						if(jQuery.inArray(ext, ['zip','pdf','docx','pptx','jpg']) == -1) 
						{
							alert("A fájl formátuma érvénytelen!");
							mindenok_f = false;
						}
						var oFReader = new FileReader();
						oFReader.readAsDataURL(document.getElementById("the_newsfiles").files[0]);
						var f = document.getElementById("the_newsfiles").files[0];
						var fsize = (f.size||f.fileSize)/1024/1024;
						if(fsize > 4)
						{
							alert("A fájl mérete túl nagy. Legfeljebb 4 MB méretű fájl tölthető fel.");
							mindenok_f = false;
						}
						if(mindenok_f == true){
							newsfiles = document.getElementById('the_newsfiles').files[0];
						}
					}
					else{
						newsfiles = "";
					}
					
					if(mindenok_f == true && mindenok == true){
						var form_data = new FormData();
						form_data.append("the_newstitle", newstitle);
						form_data.append("the_newsdescription", newdescription);
						form_data.append("the_newsimage", document.getElementById('the_newsimage').files[0]);
						form_data.append("the_newsfiles", document.getElementById('the_newsfiles').files[0]);
						$.ajax({
							url:"ajax/postnews.php",
							method:"POST",
							data: form_data,
							contentType: false,
							cache: false,
							processData: false,
							beforeSend:function(){
								$('#dialogPostNewsAlert').html('<div id="d_sending_newsdata" style="width:100%; text-align:center; margin-top:20px; margin-bottom:30px;"><br>Közzétevés folyamatban...<br><br><center><img src="documents/images/ajax-loader.gif" width="40" /></center></div>');
								$("#dialogPostNewsAlert").dialog({
									maxWidth:600,
									width:600,
									height:200,
									modal:true,
									position: { my: 'top', at: 'top+150' },
									open: function(event, ui) {
										$(".ui-dialog-titlebar-close").hide();
									}
								});	
							},   
							success: function(data){
								setTimeout(function(){
									$('#dialogPostNewsAlert').dialog('destroy');
									if(data == "mindenok"){
										jQuery.ajax({
											type: "POST",
											url: "ajax/show_mynews.php",
											data: {},
											cache: false,
											success: function(data_)
											{
												$("#news_display").hide().prepend(data_).fadeIn(1500);
											}
										});
									}
									else{
										alert(data);
									}
								}, 2500);
								
							}
						});
					}
					$(this).dialog('destroy');
				}
				
			},
			"Mégsem": function(){
				$(this).dialog('destroy');
			}
		}
		
	});	
}

function delete_this_news(x, y){
	if(!x.match(/^[0-9]+$/)){
		alert('Hibás paraméterek!');
	}
	else{
		$('#dialogDeleteThisNews').html("<center><br>Biztosan törölni szeretnéd a/az <b><u>" + y + "</u></b> hírt?<br><br>Írd be a törlés okát!<br></center><br>");
		$('#dialogDeleteThisNews').append("<center><input type='text' id='delnewsreason' style='width:450px;height:30px;margin-bottom:10px;' maxlength='150'><br><i>(Megjegyzés: Ez a művelet nem vonható vissza.)</i></center>");
		
		$("#dialogDeleteThisNews").dialog({
			maxWidth:600,
			width:600,
			height:330,
			modal:true,
			open: function(event, ui) {
				$(".ui-dialog-titlebar-close").hide();
			},
			position: { my: 'top', at: 'top+150' },
			buttons: {
				"Törlés": function(){
					var del_reason = $('#delnewsreason').val();
					if(del_reason.length < 5){
						alert("A törlés oka legalább 5 karakterből álljon!");
					}
					else if(del_reason.length > 150){
						alert("A törlés oka legfeljebb 100 karakter lehet!");
					}
					else{
						jQuery.ajax({
							type: "POST",
							url: "ajax/delete_news.php",
							data: {delnew_id: x, delnew_reason: del_reason},
							dataType: "json",
							cache: false,
							success: function(data){
								if(data.resp == "mindenok"){
									$(".one_new_divclass"+x).remove();
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
}

function scroll_news(){
	var n_limit = 5;
	var n_offset = 0;
	var n_action = 'inactive';
	
	function load_newsdata(n_limit, n_offset){
		$.ajax({
			type: "POST",
			url: "ajax/scroll_news.php",
			data: {n_limit:n_limit, n_offset:n_offset},
			success: function(data){
				$("#news_display").append(data);
				$('#loading_news_show').remove();
				if(data.length < 100){
					
					n_action = 'active';
				}
				else
				{					
					n_action = 'inactive';
					
					$("#news_display").append("<div id='loading_news_show' ><img src='documents/images/ajax-loader.gif' alt='Feldolgozás folyamatban...' width='2%'></div>");
					
				}
			}
		});
	}
	
	if(n_action == 'inactive'){
		n_action = 'active';
		load_newsdata(n_limit, n_offset);
	}
	
	window.onscroll = function() {
	if ((window.innerHeight + Math.ceil(window.pageYOffset)) >= document.body.offsetHeight && n_action == 'inactive') {
			n_action = 'active';
			n_offset = n_offset + n_limit;
			setTimeout(function(){
				load_newsdata(n_limit, n_offset);
			}, 1500);
		}
	}
	
}

function display_comp_countdown(){
	Date.prototype.addHours= function(h){
		this.setHours(this.getHours()+h);
		return this;
	}
	
	if(!$('#comp_enddate').length)
	{
		;
	}
	else{
		var countDownDate = new Date($('#comp_enddate').val()).getTime();	//meddig tart

		var x = setInterval(function() {

			var now = new Date().addHours(0).getTime();
			var distance = countDownDate - now;

			var days = Math.floor(distance / (1000 * 60 * 60 * 24));
			var hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
			var minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
			var seconds = Math.floor((distance % (1000 * 60)) / 1000);
			
			document.getElementById("demo").innerHTML = days + " nap " + hours + " óra " + minutes + " perc " + seconds + " mp ";
			
			if (distance < 0) {
				clearInterval(x);
				document.getElementById("demo").innerHTML = "LEJÁRT!";
			}
		}, 1000);
	}
}

function display_comp_details(){
	jQuery.ajax({
		type: "POST",
		url: "ajax/show_beforecompetitiondata.php",
		data: {},
		cache: false,
		beforeSend: function(){
			$("#dialogBeforeCompetition").html('<center><div id="loading_compdatadiv" style="margin-top:50px;">A kvíz adatainak betöltése...<br><br><img src="documents/images/ajax-loader.gif" alt="Feldolgozás folyamatban..." width="5%"></div></center>');
		},
		success: function(data){
			setTimeout(function(){
				$("#dialogBeforeCompetition").html(data);
			}, 1000);
		},
		fail: function(){
			alert("Failed!");
		}
	});
	
	
	$("#dialogBeforeCompetition").dialog({
		maxWidth:650,
		width:650,
		height:540,
		modal:true,
		open: function(event, ui) {
			$(".ui-dialog-titlebar-close").hide();
		},
		position: { my: 'top', at: 'top+150' },
		buttons: {
			"Kvíz indítása": function(){
				jQuery.ajax({
					type: "POST",
					url: "ajax/accessing_competition.php",
					data: {},
					dataType: "json",
					cache: false,
					success: function(data){
						if(data.resp == "mindenok"){
							window.location.href='quizgame.php';
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
			"Mégsem": function(){
				$(this).dialog('destroy');
			}
		}
	});	
}	
	
function show_competition_ranglist() {
	jQuery.ajax({
		type: "POST",
		url: "ajax/show_competitionranglist.php",
		data: {},
		cache: false,
		beforeSend: function () {
			$("#dialogShowCompetitionRanglist").html('<center><div id="loading_compdatadiv" style="margin-top:50px;">Ranglista betöltése...<br><br><img src="documents/images/ajax-loader.gif" alt="Feldolgozás folyamatban..." width="5%"></div></center>');
		},
		success: function (data) {
			setTimeout(function () {
				$("#dialogShowCompetitionRanglist").html(data);
			}, 1000);
		},
		fail: function () {
			alert("Failed!");
		}
	});

	$("#dialogShowCompetitionRanglist").dialog({
		maxWidth: 650,
		width: 650,
		height: 540,
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

$(document).ready(function(){
	scroll_news();
	display_comp_countdown();
});