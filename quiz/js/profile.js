function osszesenFizetendo(x, y){
	var a = document.getElementById('set4').value;
	if(y == 1)
	{
		var b = a * 4;
	}
	else
	{
		if(x == 5){
			var b = a * 8;
		}
		else if(x == 4){
			var b = a * 12;
		}
		else if(x == 3){
			var b = a * 18;
		}
		else if(x == 2){
			var b = a * 24;
		}
		else{
			var b = '-';
		}
	}
	if(b < 0){
		b = '-'
	}
	var c = 'Fizetendő: ';
	document.getElementById('paid_id').value = c + b + " pont";
}

function delmyaccount(){
	$('#dialogDeleteMyAccount').html("<center><br><b>Biztosan törlöd a fiókodat?</b></center><br><br><i>Ez a művelet nem vonható vissza!</i><br><br><center><input type='password' id='pw_delaccount' placeholder='Add meg a jelszavadat!'></center>");
	$("#dialogDeleteMyAccount").dialog({
		maxWidth:600,
		width:600,
		height:300,
		modal:true,
		open: function(event, ui) {
			$(".ui-dialog-titlebar-close").hide();
		},
		position: { my: 'top', at: 'top+150' },
		buttons: {
			"Igen": function(){
				var pw = $('#pw_delaccount').val();
				if(pw.length < 1){
					alert('Nem adtad meg a jelszavadat!');
				}
				else if(pw.length < 6){
					alert('A jelszavak hossza minimum 6 karakter kell legyen!');
				}
				else if(pw.length > 100){
					alert('A jelszavak hossza maximum 100 karakter lehet!');
				}
				else if(!pw.match(/^(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{6,100}$/)){
					alert('A jelszó tartalmazzon kis-és nagybetűket, legalább 1 számjegyet!');
				}
				else if(!pw.match(/^\S*$/)){
					alert('A jelszó ne tartalmazzon szóközt!');
				}
				else{
					jQuery.ajax({
						type: "POST",
						url: "ajax/deleteownaccount.php",
						cache: false,
						data: {pw:pw},
						dataType: "json",
						success: function(data){
							if(data.resp == 'ok'){
								location.href='index.php';
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
				
				$(this).dialog('destroy');
				
			},
			"Mégsem": function(){
				$(this).dialog('destroy');
			}
		}
	});	
}

function changepw(){
	var pw1 = $('#pw1').val();
	var pw2 = $('#pw2').val();
	var pw = $('#pw').val();
	if(pw1.length < 1){
		alert('Nem írtál be semmit az új jelszóhoz!');
	}
	else if(pw2.length < 1){
		alert('Nem írtál be semmit az új jelszó megerősítéséhez!');
	}
	else if(pw.length < 1){
		alert('Nem adtad meg a jelenlegi jelszavadat!');
	}
	else if(pw1.length < 6 || pw2.length < 6 || pw.length < 6){
		alert('A jelszavak hossza minimum 6 karakter kell legyen!');
	}
	else if(pw1.length > 100 || pw2.length > 100 || pw.length > 100){
		alert('A jelszavak hossza maximum 100 karakter lehet!');
	}
	else if(pw1 != pw2){
		alert('Nem talál a két jelszó!');
	}
	else if(!pw1.match(/^(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{6,100}$/) || !pw.match(/^(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{6,100}$/)){
		alert('A jelszó tartalmazzon kis-és nagybetűket, legalább 1 számjegyet!');
	}
	else if(!pw1.match(/^\S*$/) || !pw.match(/^\S*$/)){
		alert('A jelszó ne tartalmazzon szóközt!');
	}
	else{
		jQuery.ajax({
			type: "POST",
			url: "ajax/changepassword.php",
			cache: false,
			data: {pw1:pw1, pw2:pw2, pw:pw},
			dataType: "json",
			beforeSend: function (){
				$("#loading_commentdiv").show();
			},
			success: function(data){
				if(data.resp == 'mindenok'){
					$('#pw1').val('');
					$('#pw2').val('');
					$('#pw').val('');
					alert("A jelszavadat sikeresen megváltoztattad!");
				}
				else{
					alert(data.resp);
				}
				$("#loading_commentdiv").hide();
			},
			fail: function(){
				alert('AJAX failed!');
			}
		});
	}
}

function buyhelp(){
	var db = $('#set4').val();
	if(db.length < 1){
		$('#alert_gethelp').html('Nem írtál be semmit!');
	}
	else if(db.length > 3){
		$('#alert_gethelp').html('Egyszerre maximum 99 segítséget vásárolhatsz!');
	}
	else if(db < 1 || db > 99){
		$('#alert_gethelp').html('Csak 1 és 99 közötti szám fogadható el!');
	}
	else if(!db.match(/^[0-9]+$/)){
		$('#alert_gethelp').html('Adj meg egy helyes értéket 1 és 99 között!');
	}
	else{
		jQuery.ajax({
			type: "POST",
			url: "ajax/buyhelp.php",
			cache:false,
			data: {darabszam:db},
			dataType: "json",
			beforeSend: function(){
				$('#alert_gethelp').html('Feldolgozás folyamatban...');
			},
			success: function(data){
				resultObj = eval (data);
				$('#alert_gethelp').html('');
				$('#set4').val('');
				if(resultObj.length == 3){
					$('#segitsegekid').text(resultObj[0]);
					$('#sajatpontokid').text(resultObj[1]);
				}
				alert(resultObj[resultObj.length-1]);
				
			},
			fail: function(){
				alert('AJAX failed!');
			}
		});
	}
}

function hideprofil(){
	$('#dialogHideProfil').html("<center><br>Biztosan be szeretnéd állítani a profilod rejtettségét a következő 30 napra?</center><br>");
	$("#dialogHideProfil").dialog({
		maxWidth:600,
		width:600,
		height:220,
		modal:true,
		open: function(event, ui) {
			$(".ui-dialog-titlebar-close").hide();
		},
		position: { my: 'top', at: 'top+150' },
		buttons: {
			"Igen": function(){
				jQuery.ajax({
					type: "POST",
					url: "ajax/hideprofil.php",
					data: {},
					dataType: "json",
					cache: false,
					success: function(data){
						resultObj = eval (data);
						alert(resultObj[0]);
						
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


function buypremium(){
	$('#dialogBuyPremium').html("<center><br>Biztosan megvásárolod az oldal Prémium tagságát az elkövetkező 30 napra?<br><br>Figyelem: ez a beállítás <b><u>15000 pontba</u></b> kerül.</center><br>");
	$("#dialogBuyPremium").dialog({
		maxWidth:600,
		width:600,
		height:265,
		modal:true,
		open: function(event, ui) {
			$(".ui-dialog-titlebar-close").hide();
		},
		position: { my: 'top', at: 'top+150' },
		buttons: {
			"Igen": function(){
				jQuery.ajax({
					type: "POST",
					url: "ajax/buypremium.php",
					data: {},
					dataType: "json",
					cache: false,
					success: function(data){
						resultObj = eval (data);
						if(Date.parse(resultObj[0])){
							$('#buypremiumid').html("<font color='blue'>VAN,<br>Lejár: " + resultObj[0] + "</font>");
							$('#sajatpontokid').text(resultObj[1]);
						}
						alert(resultObj[resultObj.length-1]);
						
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

function make_friend(x){
	if(!x.match(/^[0-9]+$/)){
		alert("Hibás user azonosító!");
	}
	else{
		jQuery.ajax({
			type: "POST",
			url: "ajax/make_friend.php",
			data: {friend_id: x},
			dataType: "json",
			beforeSend: function(){
				$('#makefriend_loading').show();
			},
			cache: false,
			success: function(data){
				if(data.resp == "ok"){
					$('#mark_as_friend').remove();
					$('#mark_as_friend_span').text("Várakozás a barátság megerősítésére");
					alert("Jelölés elküldve!");
				}
				else{
					alert(data.resp);
				}
				$('#makefriend_loading').hide();
			},
			fail: function(){
				alert("Failed!");
			}
			
		});
	}
}

function validate_almostfriendship(x, y){
	if(!x.match(/^[0-9]+$/) || !y.match(/^[0-9]+$/)){
		alert("Hibás user-, vagy műveletazonosító!");
	}
	else{
		jQuery.ajax({
			type: "POST",
			url: "ajax/validate_friend.php",
			data: {friend_id: x, act_id: y},
			dataType: "json",
			beforeSend: function(){
				$('#accept_friendship'+x).prop('disabled', true);
				$('#delete_friendship'+x).prop('disabled', true);
			},
			cache: false,
			success: function(data){
				$('#accept_friendship'+x).prop('disabled', false);
				$('#delete_friendship'+x).prop('disabled', false);
				if(data.resp == "ok0" || data.resp == "ok1"){
					if(data.resp == "ok1"){
						alert("Elfogadtad ezt a felhasználót barátodnak. Erről most értesítettük őt.");
						var a = $('#almostfriend'+x);
						$('#no_friends').remove();
						$('#accept_friendship'+x).remove();
						$('#delete_friendship'+x).remove();
						$('.friends_maindiv').append("<p> </p>");
						$('.friends_maindiv').append(a);
					}
					else{
						$('#almostfriend'+x).remove();
					}
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

function del_friendship(x){
	if(!x.match(/^[0-9]+$/)){
		alert("Hibás userazonosító!");
	}
	else{
		jQuery.ajax({
			type: "POST",
			url: "ajax/delete_friend.php",
			data: {friend_id: x},
			dataType: "json",
			beforeSend: function(){
				$('#del_friendship'+x).prop('disabled', true);
			},
			cache: false,
			success: function(data){
				$('#del_friendship'+x).prop('disabled', false);
				if(data.resp == "ok"){
					alert("Törölted ezt a felhasználót a barátaid közül!");
					$('#friend'+x).remove();
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

function block_user(x){
	if(!x.match(/^[0-9]+$/)){
		alert("Hibás userazonosító!");
	}
	else{
		jQuery.ajax({
			type: "POST",
			url: "ajax/block_user.php",
			data: {friend_id: x},
			dataType: "json",
			beforeSend: function(){
				$('#block_user_id').prop('disabled', true);
			},
			cache: false,
			success: function(data){
				$('#block_user_id').prop('disabled', false);
				if(data.resp == "ok"){
					alert("Letiltottad ezt a felhasználót!");
					$('#enable_user_id').show();
					$('#block_user_id').hide();
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

function enable_user(x){
	if(!x.match(/^[0-9]+$/)){
		alert("Hibás userazonosító!");
	}
	else{
		jQuery.ajax({
			type: "POST",
			url: "ajax/enable_user.php",
			data: {friend_id: x},
			dataType: "json",
			beforeSend: function(){
				$('#enable_user_id').prop('disabled', true);
			},
			cache: false,
			success: function(data){
				$('#enable_user_id').prop('disabled', false);
				if(data.resp == "ok"){
					alert("Engedélyezted ezt a felhasználót!");
					$('#block_user_id').show();
					$('#enable_user_id').hide();
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

function send_mail(x, y){
	if(!x.match(/^[0-9]+$/)){
		alert("Hibás userazonosító!");
	}
	else{
		jQuery.ajax({
			type: "POST",
			url: "ajax/lawto_sendmail.php",
			data: {friend_id: x},
			dataType: "json",
			beforeSend: function(){
				$('#send_mail_id').prop('disabled', true);
				$('#sendmail_loading').show();
			},
			cache: false,
			success: function(data){
				$('#send_mail_id').prop('disabled', false);
				$('#sendmail_loading').hide();
				if(data.resp == 0){
					sending_mail(x, y);
				}
				else if(data.resp == 1){
					alert("Üzenetküldés megtagadva! Ok: Nincs jogod üzenetet küldeni!");
				}
				else if(data.resp == 2){
					alert("Üzenetküldés megtagadva! Ok: Tiltott felhasználó!");
				}
				else if(data.resp == 3){
					alert("Üzenetküldés megtagadva! A felhasználó csak adminoktól fogad üzenetet!");
				}
				else if(data.resp == 4){
					alert("Üzenetküldés megtagadva! A felhasználó csak adminoktól és barátoktól fogad üzenetet!");
				}
				else{
					alert("Hiba történt az üzenet küldésénél. Próbáld újra később!");
				}
			},
			fail: function(){
				alert("Failed!");
			}
			
		});
		
	}
}

function sending_mail(x, y){
	$('#dialogSendMessage').html("<br><center><div id='to_whom'>Címzett: <input type='text' id='cimzett_input'></div><br><textarea autofocus id='message_textarea' placeholder='Írd be az üzeneted! ...' maxlength='5000'></textarea></center><span id='span_messagelength' style='float:right; width:26%; margin-top:10px;'>0 / 5000 karakter</span><br>");
	updateCountdownMessage();
    $('#message_textarea').change(updateCountdownMessage);
    $('#message_textarea').keyup(updateCountdownMessage);
	$('#cimzett_input').val(y);
	$("#dialogSendMessage").dialog({
		maxWidth:600,
		width:700,
		height:435,
		modal:true,
		my: "center",
		at: "center",
		of: window, 
		open: function(event, ui) {
			$(".ui-dialog-titlebar-close").hide();
		},
		buttons: {
			"Küldés": function(){
				//alert($('#message_textarea').val());
				var len = $('#message_textarea').val().length;
				if(len < 5){
					alert("Az üzenet hossza legalább 5 karakter legyen!");
				}
				else if(len > 5000){
					alert("Az üzenet hossza legfeljebb 5000 karakter hosszúságú lehet!");
				}
				else{
					jQuery.ajax({
						type: "POST",
						url: "ajax/sendmail.php",
						data: {receiver: $('#cimzett_input').val(), message_content: $('#message_textarea').val()},
						dataType: "json",
						cache: false,
						success: function(data){
							if(data.resp == "ok"){
								alert("Az üzenetet elküldtük!");
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
				}
				
			},
			"Mégsem": function(){
				$(this).dialog('destroy');
			}
		}
	});
	
}

function show_sentquestions(x, y){
	$('#dialogShowQuestionList').html("<br><center><div id='title_div'>" + y + " </div><br><br><div id='content_div'><div id = 'loading_questiondiv'> </div></div>");
	
	jQuery.ajax({
		type: "POST",
		url: "ajax/load_questions_towatch.php",
		data: {quizid: x},
		cache: false,
		beforeSend: function(){
			$('#loading_questiondiv').append('<div id="loading_showquestiondiv" style="margin-top:10px;margin-bottom:10px;">Kérdések betöltése...<br><br><img src="documents/images/ajax-loader.gif" alt="Feldolgozás folyamatban..." width="3%"></div>')
		},
		success: function(data){
			setTimeout(function(){
				$("#loading_questiondiv").remove();
				$('#content_div').append(data);
				
			}, 1500);
		},
		fail: function(){
			alert("Failed!");
		}
		
	});
	
	$("#dialogShowQuestionList").dialog({
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

function update_accepting_msg(){
	var x = $('#accept_message_type').val();
	if(x == 0 || x == 1 || x == 2){
		jQuery.ajax({
			type: "POST",
			url: "ajax/update_acceptmessages.php",
			data: {updated_id: x},
			dataType: "json",
			beforeSend: function(){
				$('#update_acceptmsg').show();
			},
			cache: false,
			success: function(data){
				$('#update_acceptmsg').hide();
				alert(data.resp);
			},
			fail: function(){
				alert("Failed!");
			}
			
		});
	}
	else{
		alert("Hibás bemenet!");
	}
}

function updateCountdownMessage() {
    var remaining = jQuery('#message_textarea').val().length;
    jQuery('#span_messagelength').text('(' + remaining + ' / 5000 karakter)');
}

function new_background(qid) {
	$('#dialogAddNewBackground').html('<span id="bgnotes_title">Megkötések:</span><div id="bgnotes"><br>- Csak az alábbi képformátumok elfogadottak: .jpg, .jpeg, .png .<br>- Egyszerre csak egy képet lehet feltölteni.<br>- A kép mérete legfeljebb 500 KB (0.5 MB) lehet.<br>- Csak 50 darab képet tölthetsz fel. (Törölj a már feltöltött képekből, ha újat szeretnél beküldeni és elérted a limitet.)</div><div id="d_addbackground" class="custom-file mb-3" align="center"><input type="file" id="bgimage" name="bgimage" class="custom-file-input"><label class="custom-file-label" for="bgimage">Válaszd ki a képet!</label></div>');
	$("#dialogAddNewBackground").dialog({
		maxWidth: 600,
		width: 620,
		height: 350,
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
					if (name.length > 50) {
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
							$('.dialogAddNewBackgroundAlert' + qid).html('<div style="width:100%; text-align:center; margin-top:20px; margin-bottom:30px;"><br>Közzétevés folyamatban...<br><br><center><img src="documents/images/ajax-loader.gif" width="35" /></center></div>');
							$(".dialogAddNewBackgroundAlert" + qid).dialog({
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
								$('.dialogAddNewBackgroundAlert' + qid).dialog('destroy');
								if (data == "ok") {
									alert("A képet sikeresen elküldted!");
								}
								else {
									alert(data);
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

$(document).ready(function(){
    $(".togglerQ").click(function(e){
        e.preventDefault();
        $('.detailQ'+$(this).attr('data-prod-cat')).toggle();
    });
	
	$(".togglerOwnPQ").click(function(e){
        e.preventDefault();
        $('.detailsOwnPQuiz'+$(this).attr('data-prod')).toggle();
    });
	
	
});
