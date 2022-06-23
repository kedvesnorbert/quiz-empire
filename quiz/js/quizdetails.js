/*JavaScript functions*/
function showDiv(divId, elem)
{
    document.getElementById(divId).style.display = elem.value == 2 ? 'block' : 'none';
}

function showDivJel(divId, elem)
{
    document.getElementById(divId).style.display = elem.value == 4 ? 'block' : 'none';
}

function showDiv2(divId, elem)
{
    document.getElementById(divId).style.display = elem.value == 3 ? 'block' : 'none';
}

function isValidDate(dateString) {
	var regExp = /^\d{4}-\d{2}-\d{2}$/;

	if (!dateString.match(regExp)) {
		return false;  // Invalid format
	}

	var d = new Date(dateString);
	var dNum = d.getTime();

	if (!dNum && dNum !== 0) {
		return false; // NaN value, Invalid date
	}
	return d.toISOString().slice(0, 10) === dateString;
}

/*AJAX functions*/

function rat1(x, y)
{
	jQuery.ajax({
	   type: "POST",
	   url: "ajax/rating.php",
	   data: {rating_number:y, q_number:x},
	   cache: false,
	   success: function(data)
	   {
			location.reload();
	   },
	   fail: function(){
		   alert('Sikertelen.');
	   }
	});
}

function like_quiz(x, y)
{
	jQuery.ajax({
	   type: "POST",
	   url: "ajax/likequiz.php",
	   data: {q_number:x},
	   dataType:"json",
	   cache: false,
	   success: function(data)
	   {
			if(data.resp == 0){
				$("#likes_div").append(y);
				$('#like_button').hide();
				$('#no_likes_text').remove();
			}
			else if(data.resp == 1)
			{
				$("#likes_div").append(", "+y);
				$('#like_button').hide();
				$('#no_likes_text').remove();
			}
			else{
				if(data.resp == -1){
					alert("Hibás adatok érkeztek a szerverhez!");
				}
				else if(data.resp == -2){
					alert("Saját kvízedet nem likeolhatod!");
				}
				else if(data.resp == -3){
					alert("Ezt a kvízt már likeoltad!");
				}
				else{
					alert(data.resp);
				}
			}
	   }
	});
}

function leave_comment(){
	var q_number = document.getElementById("commented_quizid").value;
	var my_comment = document.getElementById("textarea_input").value;
	if(my_comment=="" || my_comment.length < 5){
		alert('Írj be legalább 5 karakter hosszúságú szöveget!');
	}
	else{
		jQuery.ajax({
		   type: "POST",
		   url: "ajax/insert_comment.php",
		   data: {q_number:q_number, my_comment:my_comment},
		   dataType:"json",
		   cache: false,
		   beforeSend: function() {
				$("#loading_commentdiv").show();
		   },
		   success: function(data)
		   {
				if(data.resp != "1"){
					alert(data.resp);
					
				}
				else{
					document.getElementById("textarea_input").value = "";
					jQuery.ajax({
						type: "POST",
						url: "ajax/show_mycomment.php",
						data: {my_comment:my_comment},
						cache: false,
						success: function(data)
						{
							$("#first_one_commentdiv").hide().prepend(data).fadeIn(1500);
						}
					});
				}
				$("#loading_commentdiv").hide();
		   }
		});
		
	}
}

function scroll_data(){
	var q_number = document.getElementById("commented_quizid").value;
	var c_limit = 5;
	var c_offset = 0;
	var action = 'inactive';
	
	function load_data(c_limit, c_offset){
		$.ajax({
			type: "POST",
			url: "ajax/scroll_comments.php",
			data: {q_number:q_number, c_limit:c_limit, c_offset:c_offset},
			success: function(data){
				$("#various_div").append(data);
				$('#loading_comments_show').remove();
				
				if(data.length < 100){
					
					action = 'active';
				}
				else
				{					
					action = 'inactive';
					$('#no_comment_text_').remove();
					$("#various_div").append("<div id='loading_comments_show' ><img src='documents/images/ajax-loader.gif' alt='Feldolgozás folyamatban...' width='2%'></div>");
				}
			}
		});
	}
	
	if(action == 'inactive'){
		action = 'active';
		load_data(c_limit, c_offset);
	}
	
	window.onscroll = function() {
	if ((window.innerHeight + Math.ceil(window.pageYOffset)) >= document.body.offsetHeight && action == 'inactive') {
			action = 'active';
			c_offset = c_offset + c_limit;
			setTimeout(function () {
				load_data(c_limit, c_offset);
			}, 1500);
		}
	}
}

function show_deldialog(x, y, z){
	$("#dialogDelMyComment").html("<p style='text-align:center;'>Biztosan törölni szeretnéd ezt a hozzászólást?</p>");
	x = decodeURIComponent((x+'').replace(/\+/g, '%20'));
	$("#dialogDelMyComment").dialog({
		maxWidth:600,
		width:600,
		height:200,
		modal:true,
		open: function(event, ui) {
			$(".ui-dialog-titlebar-close").hide();
		},
		position: { my: 'top', at: 'top+150' },
		buttons: {
			"Törlés": function(){
				jQuery.ajax({
					type: "POST",
					url: "ajax/delete_mycomment.php",
					data: {j_comment: x, j_date: y, j_quiz: z},
					dataType: "json",
					cache: false,
					success: function(data){
						if(data.resp != "1"){
							alert(data.resp);
						}
						else{
							alert("A hozzászólásod törölve lett!");
						}
						
					},
					fail: function(){
						alert("Failed!");
					}
					
				});
				$(this).dialog('destroy');
				$(this).dialog('close');
			},
			"Mégsem": function(){
				$(this).dialog('destroy');
				$(this).dialog("close");
			}
		}
		
	});	
}

function show_beforestartquiz_det(x, y, z, t, v, p, n, l, w, j){
	var wheight=300;
	$("#dialogBeforeStartQuizDet").html('');
	$("#dialogBeforeStartQuizDet").html("<p id='dialogBeforeStartQuizTitle' style='text-align:center;'></p><br>");
	$("#dialogBeforeStartQuizDet").append("<p id='dialogBeforeStartQuizNumQ' style='text-align:left;'></p>");
	$("#dialogBeforeStartQuizDet").append("<p id='dialogBeforeStartQuizSecs' style='text-align:left;'></p>");
	$("#dialogBeforeStartQuizTitle").html(y);
	$("#dialogBeforeStartQuizNumQ").html("Kérdések száma: " + t);
	$("#dialogBeforeStartQuizSecs").html("Egy kérdésre jutó válaszidő: " + z + " másodperc");
	
	if(v==4){
		$("#dialogBeforeStartQuizDet").append("<br><center>A folytatáshoz adja meg a kvíz jelszavát!<p></p></center>")
		$("#dialogBeforeStartQuizDet").append("<center><div class='pwclass'><input type='password' id='dialogBeforeStartQuizPw' style='text-align:center;width:70%;height:30px;' required></div></center>");
		wheight=400;
	}
	$("#dialogBeforeStartQuizDet").dialog({
		maxWidth:600,
		width:600,
		height:wheight,
		modal:true,
		open: function(event, ui) {
			$(".ui-dialog-titlebar-close").hide();
		},
		position: { my: 'top', at: 'top+150' },
		//position: {my: "center middle", at:"center middle"},
		buttons: {
			"Indítás": function(){
				var kk = "`";
				if(v==4){
					kk = $('#dialogBeforeStartQuizPw').val();
				}
				if(kk.length<1){
					kk = " ";
					alert("Nem írtál be jelszót!");
				}
				else{
					jQuery.ajax({
						type: "POST",
						url: "ajax/startquiz.php",
						data: {bef_quizid: x, bef_pw: kk, bef_page: p, bef_name: n, bef_lang: l, bef_where: w, bef_fromquiz: j},
						dataType: "json",
						cache: false,
						success: function(data){
							if(data.resp != "ok" && data.resp != "Egy másik belépést észleltünk!"){
								alert(data.resp);
							}
							else{								
								window.location.href = 'quizgame.php';
							}
						},
						fail: function(){
							alert("Failed!");
						}
					});
					$('#dialogBeforeStartQuizPw').val('');
					$(this).dialog('destroy');
				}
			},
			"Mégsem": function(){
				$(this).dialog('destroy');
				$(this).dialog("close");
			}
		}
	});	
}

function updateMyQuiz()
{
	var quizid = $("#quizid").val();
	var upquiz_elerheto = $("#kvizelerhetoseg").val();
	var upquiz_elerhetofriends;
	if($("#elerheto_select").length){
		upquiz_elerhetofriends = $("#elerheto_select").val();
	}
	else{
		upquiz_elerhetofriends = "";
	}
	var upquiz_newpw1;
	if($("#pwt1").length){
		upquiz_newpw1 = $("#pwt1").val();
	}
	else{
		upquiz_newpw1 = "";
	}
	var upquiz_newpw2;
	if($("#pwt2").length){
		upquiz_newpw2 = $("#pwt2").val();
	}
	else{
		upquiz_newpw2 = "";
	}
	var upquiz_numofplaying = $("#numofplaying").val();
	var upquiz_kerdesfogadas = $("#kerdfogadas").val();
	var upquiz_fogadkerdes;
	if($("#fogad_select").length){
		upquiz_fogadkerdes = $("#fogad_select").val();
	}
	else{
		upquiz_fogadkerdes = "";
	}
	var upquiz_startd;
	if($("#startd").length){
		upquiz_startd = $("#startd").val();
	}
	else{
		upquiz_startd = "";
	}
	var upquiz_endd;
	if($("#endd").length){
		upquiz_endd = $("#endd").val();
	}
	else{
		upquiz_endd = "";
	}
	var upquiz_verify = $("#verifycurrent").val();
	var upquiz_oldpw;
	if($("#pwtcurrent").length){
		upquiz_oldpw = $("#pwtcurrent").val();
	}
	else{
		upquiz_oldpw = "";
	}
	var upquiz_accpw = $("#mypasscurrent").val();
	
	var std_a = new Date(upquiz_startd);
	var end_b = new Date(upquiz_endd);
	var nowdate = (new Date()).toISOString().split('T')[0];

	if(!quizid.match(/^[0-9]+$/)){
		alert("Hibás kvíz azonosító!");
	}
	else if (!upquiz_elerheto.match(/^[0-9]+$/) || upquiz_elerheto > 5 || upquiz_elerheto < 1){
		alert("Hiba a kvíz elérhetőségének kiválasztásakor!");
	}
	else if (!upquiz_numofplaying.match(/^[0-9]+$/) || upquiz_numofplaying > 6 || upquiz_numofplaying < 1){
		alert("Hiba a próbálkozások számának kiválasztásakor!");
	}
	else if (!upquiz_kerdesfogadas.match(/^[0-9]+$/) || upquiz_kerdesfogadas > 5 || upquiz_kerdesfogadas < 1){
		alert("Hiba a kérdések fogadásának kiválasztásakor!");
	}
	else if (!upquiz_verify.match(/^[0-9]+$/) || upquiz_verify > 1000000 || upquiz_verify < 0){
		alert("Hiba az ellenőrizhetési lehetőség megadásánál!");
	}
	else if (upquiz_elerheto == 2 && upquiz_elerhetofriends.length < 1){
		alert("Jelöld be legalább 1 barátodat, akik elérhetik a kvízt!");
		$([document.documentElement, document.body]).animate({
			scrollTop: $("#kvizelerhetoseg").offset().top
		}, 2000);
		$('#quizelerh_msg').text("Hibás adat! Jelöld be legalább 1 barátodat!");
	}
	else if(upquiz_elerheto == 4 && (upquiz_newpw1.length < 1 || upquiz_newpw2.length < 1 || upquiz_newpw1 != upquiz_newpw2 || upquiz_newpw1.length > 30 || upquiz_newpw2.length > 30)){
		alert("Hiba! A kvíz új jelszava nem lehet üres, maximum 30 karakterből állhat, és a két jelszónak ugyanaz kell lennie!");
		$([document.documentElement, document.body]).animate({
			scrollTop: $("#kvizelerhetoseg").offset().top
		}, 2000);
		$('#quizpwnew_msg').text("Hibás adat! A kvíz új jelszavát vagy nem adtad meg, vagy hosszabb 30 karakternél, vagy nem talál a két jelszó!");
	}
	else if (upquiz_kerdesfogadas == 3 && upquiz_fogadkerdes.length < 1){
		alert("Válassz a barátaid közül (legalább 1-et), akiknek engedélyezed a kérdések beküldését a kvízedhez!");
		$([document.documentElement, document.body]).animate({
			scrollTop: $("#kerdfogadas").offset().top
		}, 2000);
		$('#quizkerdbekuld_msg').text("Hibás adat! Válaszd ki legalább 1 barátodat a listából!");
	}
	else if (upquiz_startd.length > 0 && isValidDate(upquiz_startd) == false){
		alert("A kezdő dátum helytelen!");
		$([document.documentElement, document.body]).animate({
			scrollTop: $("#startd").offset().top
		}, 2000);
	}
	else if (upquiz_endd.length > 0 && isValidDate(upquiz_endd) == false) {
		alert("A második dátum (befejezés dátuma) helytelen!");
		$([document.documentElement, document.body]).animate({
			scrollTop: $("#endd").offset().top
		}, 2000);
	}
	else if (upquiz_startd.length > 0 && upquiz_endd.length > 0 && (end_b - std_a) < 86400000) {
		alert('A két dátum között legyen legalább 1 nap! A kezdő dátum nem lehet nagyobb a második dátumnál');
		$([document.documentElement, document.body]).animate({
			scrollTop: $("#startd").offset().top
		}, 2000);
	}
	else if (upquiz_endd.length > 0 && nowdate > upquiz_endd) {
		alert('A második dátum nem lehet kisebb a mai napnál!');
		$([document.documentElement, document.body]).animate({
			scrollTop: $("#startd").offset().top
		}, 2000);
	}
	else if(upquiz_accpw.length < 1){
		alert("Nem adtad meg a fiókod jelszavát!");
	}
	else{
		jQuery.ajax({
		   type: "POST",
		   url: "ajax/update_myquiz.php",
		   data: {quizid:quizid, kvizelerhetoseg:upquiz_elerheto, elerheto:upquiz_elerhetofriends, pass1:upquiz_newpw1, pass2:upquiz_newpw2, numofplaying:upquiz_numofplaying, kerdfogadas:upquiz_kerdesfogadas, fogad:upquiz_fogadkerdes, startd:upquiz_startd, endd:upquiz_endd, verifycurrent:upquiz_verify, passcurrent:upquiz_oldpw, mypasscurrent:upquiz_accpw},
		   dataType: "json",
		   cache: false,
		   success: function(data)
		   {
				if(data.resp == ""){
					alert("Az adatok módosultak!");
					location.reload();
					window.scrollTo(0, 0);
				}
				else{
					alert(data.resp);
				}
		   },
		   fail: function(){
			   alert('Sikertelen.');
		   }
		});
	}
}

function new_background(qid, act) {
	$('#dialogAddNewBackground').html('<span id="bgnotes_title">Megkötések:</span><div id="bgnotes"><br>- Csak az alábbi képformátumok elfogadottak: .jpg, .jpeg, .png .<br>- Egyszerre csak egy képet lehet feltölteni.<br>- A kép mérete legfeljebb 500 KB (0.5 MB) lehet.<br>- Csak 50 darab képet tölthetsz fel. (Törölj a már feltöltött képekből, ha újat szeretnél beküldeni és elérted a limitet.)</div><br><div id="d_addbackground" align="center"><input type="file" id="bgimage" class="form-control" name="bgimage"></div>');
	$("#dialogAddNewBackground").dialog({
		maxWidth: 600,
		width: 620,
		height: 360,
		modal: true,
		position: { my: 'top', at: 'top+150' },
		open: function (event, ui) {
			$(".ui-dialog-titlebar-close").hide();
		},
		buttons: {
			"Feltöltés": function () {
				var newskep = "";
				var mindenok = true;
				if (document.getElementById("bgimage").files.length == 1) {
					var name = document.getElementById("bgimage").files[0].name.toLowerCase();
					if(name.length > 50){
						alert('A kép neve túl hosszú. Nevezd át a feltöltés folytatásához. Max 50 karakter hosszú lehet!');
						mindenok = false;
					}
					var ext = name.split('.').pop().toLowerCase();
					if (jQuery.inArray(ext, ['png', 'jpg', 'jpeg']) == -1) {
						alert("A kép formátuma érvénytelen!");
						mindenok = false;
					}
					var oFReader = new FileReader();
					oFReader.readAsDataURL(document.getElementById("bgimage").files[0]);
					var f = document.getElementById("bgimage").files[0];
					var fsize = (f.size || f.fileSize) / 1024 / 1024;
					if (fsize > 0.5) {
						alert("A kép mérete túl nagy. Legfeljebb 0.5 MB méretű kép tölthető fel.");
						mindenok = false;
					}
					if (mindenok == true) {
						newskep = document.getElementById('bgimage').files[0];
					}
				}
				else {
					newskep = "";
					mindenok = false;
					alert('Nem lett kép kiválasztva, vagy túl sok képet akarsz feltölteni egyszerre!');
				}

				if (mindenok == true) {
					var form_data = new FormData();
					form_data.append("p_quizid", qid);
					form_data.append("p_bgimage", document.getElementById('bgimage').files[0]);
					$.ajax({
						url: "ajax/upload_bgimage.php",
						method: "POST",
						data: form_data,
						contentType: false,
						cache: false,
						processData: false,
						beforeSend: function () {
							$('#dialogAddNewBackgroundAlert').html('<div style="width:100%; text-align:center; margin-top:20px; margin-bottom:30px;"><br>Közzétevés folyamatban...<br><br><center><img src="documents/images/ajax-loader.gif" width="35" /></center></div>');
							$("#dialogAddNewBackgroundAlert").dialog({
								maxWidth: 600,
								width: 600,
								height: 300,
								modal: true,
								position: { my: 'top', at: 'top+150' },
								open: function (event, ui) {
									$(".ui-dialog-titlebar-close").hide();
								}
							});
						},
						success: function (data) {
							setTimeout(function () {
								$('#dialogAddNewBackgroundAlert').dialog('destroy');
								if (data == "ok") {
									alert("A képet sikeresen elküldted!");
								}
								else {
									alert(data);
								}
								if(act == 8){
									location.reload();
								}
							}, 2500);
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

function delete_mybgimg(x){
	if (window.confirm("Biztos, hogy törlöd ezt a képet?")) {
		jQuery.ajax({
			type: "POST",
			url: "ajax/delete_backgroundimage.php",
			data: { p_imgid: x },
			dataType: "json",
			cache: false,
			success: function (data) {
				if (data.resp == "ok") {
					alert("Törölted a képet!");
					location.reload();
				}
				else {
					alert(data.resp);
				}
			},
			fail: function () {
				alert('Sikertelen.');
			}
		});
	}
}

$(document).ready(function(){
	scroll_data();
});



