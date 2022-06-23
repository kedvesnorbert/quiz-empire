/*Insertkor*/
function updateCountdown() {
    var remaining = 254 - jQuery('#question').val().length;
    jQuery('#countdownQ').text('(' + remaining + ' karakter írható)');
}

function updateCountDownA1() {
	var remaining = 150 - jQuery('#ans1').val().length;
    jQuery('#countdownA1').text('(' + remaining + ' karakter írható)');
}

function updateCountDownA2() {
	var remaining = 150 - jQuery('#ans2').val().length;
    jQuery('#countdownA2').text('(' + remaining + ' karakter írható)');
}

function updateCountDownA3() {
	var remaining = 150 - jQuery('#ans3').val().length;
    jQuery('#countdownA3').text('(' + remaining + ' karakter írható)');
}

function updateCountDownA4() {
	var remaining = 150 - jQuery('#ans4').val().length;
    jQuery('#countdownA4').text('(' + remaining + ' karakter írható)');
}

function updateCountDownMegj() {
	var remaining = 150 - jQuery('#megj').val().length;
    jQuery('#countdownMegj').text('(' + remaining + ' karakter írható)');
}

jQuery(document).ready(function($) {
	updateCountdown();
    $('#question').change(updateCountdown);
    $('#question').keyup(updateCountdown);
	updateCountDownA1();
	$('#ans1').change(updateCountDownA1);
    $('#ans1').keyup(updateCountDownA1);
	updateCountDownA2();
	$('#ans2').change(updateCountDownA2);
    $('#ans2').keyup(updateCountDownA2);
	updateCountDownA3();
	$('#ans3').change(updateCountDownA3);
    $('#ans3').keyup(updateCountDownA3);
	updateCountDownA4();
	$('#ans4').change(updateCountDownA4);
    $('#ans4').keyup(updateCountDownA4);
	updateCountDownMegj();
	$('#megj').change(updateCountDownMegj);
    $('#megj').keyup(updateCountDownMegj);
	
	
});

/*AJAX functions*/

function sendNewQuestion(){
	var category = $('#category').val();
	var q = $('#question').val();
	var a1 = $('#ans1').val();
	var a2 = $('#ans2').val();
	var a3 = $('#ans3').val();
	var a4 = $('#ans4').val();
	var diff = $('#difficulty').val();
	var note = $('#megj').val();
	if(category <= 0){
		alert('Válaszd ki a témakört!');
	}
	else if(q.length < 1){
		alert('Nem írtál be semmit a kérdéshez!');
	}
	else if(a1.length < 1){
		alert('Nem írtál be semmit a helyes válaszhoz!');
	}
	else if(a2.length < 1){
		alert('Nem írtál be semmit az 1. helytelen válaszhoz!');
	}
	else if(a3.length < 1){
		alert('Nem írtál be semmit az 2. helytelen válaszhoz!');
	}
	else if(a3.length < 1){
		alert('Nem írtál be semmit az 3. helytelen válaszhoz!');
	}
	else if(q.length > 254){
		alert('A kérdés hossza MAX 254 karakter lehet!');
	}
	else if(a1.length > 150){
		alert('A HELYES válasz hossza MAX 150 karakter lehet!');
	}
	else if (a2.length > 150 ) {
		alert('Az 1. helytelen válasz hossza MAX 150 karakter lehet!');
	}
	else if (a3.length > 150) {
		alert('A 2. helytelen válasz hossza MAX 150 karakter lehet!');
	}
	else if (a4.length > 150) {
		alert('A 3. helytelen válasz hossza MAX 150 karakter lehet!');
	}
	else if(diff < 1 || diff > 2){
		alert('Válaszd ki a kérdés nehézségét!');
	}
	else if(note.length > 150){
		alert('A megjegyzés hossza MAX 150 karakter lehet!');
	}
	else if(a1 == a2 || a1 == a3 || a1 == a4 || a2 == a3 || a2 == a4 || a3 == a4 || q == a1 || q == a2 || q == a3 || q == a4){
		alert('Mindenik válasz különböző kell legyen, valamint a kérdés sem lehet egyenlő a válaszok bármelyikével!');
	}
	else{
		jQuery.ajax({
			type: "POST",
			url: "ajax/sendnewquestion.php",
			cache: false,
			data: {tema:category, question:q, ans1:a1, ans2:a2, ans3:a3, ans4:a4, diff:diff, megj:note},
			dataType: "json",
			beforeSend: function (){
				$('#loading_newquestiondiv').show();
			},
			success: function(data){
				if(data.resp == "Successfully inserted question!"){
					$('#question').val('');
					$('#ans1').val('');
					$('#ans2').val('');
					$('#ans3').val('');
					$('#ans4').val('');
					$('#megj').val('');
					alert('Köszönjük kérdésedet!');
				}
				else{
					alert(data.resp);
				}
				$('#loading_newquestiondiv').hide();
				
			},
			fail: function(){
				alert('JQuery AJAX failed!');
		    }
		});
	}
}

function show_correctingquestion_dialog(id){
	$("#dialogShowCorrectingQuestion" + id).dialog({
		maxWidth: 900,
		width: 800,
		height: 650,
		modal: true,
		position: { my: 'top', at: 'top+150' },
		open: function (event, ui) {
			$(".ui-dialog-titlebar-close").hide();
		},
		buttons: {
			"Bezárás": function () {
				$(this).dialog('destroy');
			}
		}
	});
}

function sendUpdatedQuestion(x){
	x = decodeURIComponent((x + '').replace(/\+/g, '%20'));
	var category = $('#uptemakor'+x).val();
	var q = $('#questionM'+x).val();
	var a1 = $('#ans1M'+x).val();
	var a2 = $('#ans2M'+x).val();
	var a3 = $('#ans3M'+x).val();
	var a4 = $('#ans4M'+x).val();
	var note = $('#megjM'+x).val();
	if(category <= 0){
		alert('Válaszd ki a témakört!');
	}
	else if(q.length < 5){
		alert('Legalább 5 karakter legyen a kérdés!');
	}
	else if (!q.match(/^([A-Z]|\x22[A-Z0-9]|\x27[A-Z0-9])(.|s)*[?]$/)){
		alert('A kérdés Nagybetűvel kezdődjön; Kezdődhet idézőjellel (\"), vagy aposztróffal (\'), amelyet ugyancsak nagybetű, vagy szám kell kövessen! A kérdést kérdőjellel zárd, vigyázva, hogy extra karakterek ne maradjanak a kérdőjel után! Legalább 5 karaktert írj!');
	}
	else if(a1.length < 1){
		alert('Nem írtál be semmit a helyes válaszhoz!');
	}
	else if(a2.length < 1){
		alert('Nem írtál be semmit az 1. helytelen válaszhoz!');
	}
	else if(a3.length < 1){
		alert('Nem írtál be semmit az 2. helytelen válaszhoz!');
	}
	else if(a4.length < 1){
		alert('Nem írtál be semmit az 3. helytelen válaszhoz!');
	}
	else if(q.length > 254){
		alert('A kérdés hossza MAX 254 karakter lehet!');
	}
	else if(a1.length > 150 || a2.length > 150 || a3.length > 150 || a4.length > 150){
		alert('A válaszok hossza MAX 150 karakter lehet!');
	}
	else if(note.length > 150){
		alert('A megjegyzés hossza MAX 150 karakter lehet!');
	}
	else if(a1 == a2 || a1 == a3 || a1 == a4 || a2 == a3 || a2 == a4 || a3 == a4 || q == a1 || q == a2 || q == a3 || q == a4){
		alert('Mindenik válasz különböző kell legyen, valamint a kérdés sem lehet egyenlő a válaszok bármelyikével!');
	}
	else{
		jQuery.ajax({
			type: "POST",
			url: "ajax/sendupdatedquestion.php",
			cache: false,
			data: {quest_id:x, tema:category, question:q, ans1:a1, ans2:a2, ans3:a3, ans4:a4, megj:note},
			dataType: "json",
			beforeSend: function (){
				$('#loading_newquestiondiv').show();
			},
			success: function(data){
				if(data.resp == 'mindenok'){
					alert('Köszönjük a javítást!');
					window.location.replace(location);
				}
				else{
					alert(data.resp);
				}
				$('#loading_newquestiondiv').hide();
			},
			fail: function(){
				alert('AJAX failed!');
			}
		});
		
	}
}
