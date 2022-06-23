function minKot1()
{
	var a = document.getElementById('kerdszam1').value;
	var b = Math.round(a * 1.45);
	var c = 'Kötelezően beküldendő: ';
	document.getElementById('kerdszamkot2').value = c + b;
}

function updateCountDowncimMegj1() {
	var remaining = 50 - jQuery('#cim1').val().length;
    jQuery('#cimMegj1').text(' (' + remaining + ')');
}

function updateCountDownleirasMegj1() {
	var remaining = 999 - jQuery('#leiras1').val().length;
    jQuery('#leirasMegj1').text(' (' + remaining + ')');
}


function updateCountDownidoMegj1() {
	var remaining = 2 - jQuery('#valsec1').val().length;
    jQuery('#idoMegj1').text(' ( ' + remaining + ' )');
}

function show_similar_quiznames() {
	var searching = $('#cim1').val();
	if (searching.length < 4) {
		return false;
	}
	$('#dialogShowSimilarQuiznames').html('<div id="d_sim_quiznames" style="width:100%; text-align:center; margin-top:20px; margin-bottom:30px;"><br>Betöltés...<br><br><center><img src="documents/images/ajax-loader.gif" width="40" /></center></div>');
	$("#dialogShowSimilarQuiznames").dialog({
		maxWidth: 600,
		width: 600,
		height: 350,
		modal: true,
		position: { my: 'top', at: 'top+150' },
		open: function (event, ui) {
			$(".ui-dialog-titlebar-close").hide();
			jQuery.ajax({
				type: "POST",
				url: "ajax/show_similarresults.php",
				cache: false,
				dataType: "json",
				data: { searching: searching },
				success: function (data) {
					setTimeout(function () {
						if (data.resp.length > 0) {
							$('#d_sim_quiznames').html("<i>Figyelem! Hasonló kvízek az oldalon:</i><br><br>" + data.resp + "<br><br>Javasoljuk, hogy nevezd át a kvízed címét, vagy egy másik témakörben próbálkozz kvízt beküldeni!");
						}
						else {
							$('#d_sim_quiznames').html("Szuper! Nem található hasonló nevű/témájú kvíz az oldalon.");
						}
					}, 1000);
				},
				fail: function () {
					alert('AJAX failed!');
				}
			});
		},
		buttons: {
			"Bezárás": function () {
				$(this).dialog('destroy');
			}
		}
	});
}

function sendNewRequest(){
	var req_cim = $("#cim1").val();
	var req_leiras = $("#leiras1").val();
	var req_points = $("#points").val();
	var req_nyelv = $("#nyelv1").val();
	var req_kerdszam = $("#kerdszam1").val();
	var req_kerdszamkot = 0; 
	if($("#kerdszamkot1").val().length > 0){
		if($("#kerdszamkot1").val().match(/^[0-9]+$/) && $("#kerdszamkot1").val() < 100){
			req_kerdszamkot = $("#kerdszamkot1").val();
		}
		else{
			req_kerdszamkot = -1;
		}
	}
	var req_valsec = $("#valsec1").val();
	var req_showcorr = $("#showcorr1").val();
	var req_anonymus = 0;
	if($("#rejtetten1").length){
		if($("#rejtetten1").is(":checked")){
			req_anonymus = 1;
		}
		else{
			req_anonymus = 0;
		}
	}
	else{
		req_anonymus = 0;
	}
	var req_szabalyzat = $('#szabalyzat_check1');
	if(req_szabalyzat.is(':checked')){
		var sza = 1;
	}
	else{
		var sza = 0;
	}
	
	if(req_cim.length < 1){
		alert("Nem írtad be a kvíz címét!");
	}
	else if(req_cim.length > 100){
		alert("A kvíz címe legfeljebb 100 karakter hosszú lehet!");
	}
	else if(req_leiras.length < 30){
		alert("Adj meg egy legalább 30 karakter hosszú leírást a kvízről!");
	}
	else if(req_leiras.length > 999){
		alert("A leírás hossza maximum 999 karakter hosszú lehet!");
	}
	else if(!req_points.match(/^[0-9]+$/)){
		alert("Helytelen értéket adtál meg a felajánlott pontok számánál!");
	}
	else if(req_points < 100){
		alert("Legalább 100 pontot kötelező felajánlani a kérésre!");
	}
	else if(req_nyelv < 1){
		alert("Nem választottad ki a kvíz nyelvét!");
	}
	else if(req_kerdszam.length < 1){
		alert("Írd be, hogy hány kérdésből álljon a kvíz!");
	}
	else if(!req_kerdszam.match(/^[0-9]+$/)){
		alert("Helytelen értéket adtál meg a kérdések számánál!");
	}
	else if(req_kerdszam < 13){
		alert("A kvíz kötelezően minimum 13 kérdésből kell álljon!");
	}
	else if(req_kerdszam > 45){
		alert("A kvíz legfeljebb 45 kérdésből állhat!");
	}
	else if(req_kerdszamkot == -1){
		alert("Az általad kért kérdések száma hibás! Maximum 99 kérdést kérhetsz");
	}
	else if(req_valsec.length < 1){
		alert("Írd be a válaszolási időt (másodpercekben kifejezve)!");
	}
	else if(!req_valsec.match(/^[0-9]+$/)){
		alert("Helytelen értéket adtál meg a válaszolási időnél!");
	}
	else if(req_valsec < 15){
		alert("A válaszolási idő egy kérdésre minimum 15 másodperc kell legyen!");
	}
	else if(req_valsec > 99){
		alert("A válaszolási idő egy kérdésre maximum 99 másodperc lehet!");
	}
	else if(req_showcorr != 1 && req_showcorr != 2){
		alert('Nem választottad ki, hogy a helyes válaszokat megmutassa a kért kvízed, vagy sem!');
	}
	else if(req_anonymus != 0 && req_anonymus != 1){
		alert('Hiba a kérés Anonymusként mező bejelölésénél!');
	}
	else if(sza != 1){
		alert('A szabályzat elfogadása kötelező!');
	}
	else{
		jQuery.ajax({
			type: "POST",
			url: "ajax/sendnewrequest.php",
			cache: false,
			data: {cim1: req_cim, leiras1: req_leiras, points: req_points, nyelv1: req_nyelv, kerdszam1: req_kerdszam, kerdszamkot1: req_kerdszamkot, valsec1: req_valsec, showcorr1: req_showcorr, rejtetten1: req_anonymus, acceptconditions1: sza},
			dataType: "json",
			beforeSend: function (){
				$('#loading_newrequestdiv').show();
			},
			success: function(data){
				if(data.resp == "mindenok"){
					$('#cim1').val('');
					$('#leiras1').val('');
					$('#kerdszam1').val('');
					$('#valsec1').val('');
					$('#kerdszamkot1').val('');
					$('#nyelv1').val('0');
					$('#showcorr1').val('1');
					$('#points').val('100');
					$('#rejtetten1').prop('checked', false);
					$('#szabalyzat_check1').prop('checked', false);
					alert('A kérésedet sikeresen elküldted!');
				}
				else{
					alert(data.resp);
				}
				$('#loading_newrequestdiv').hide();
				
			},
			fail: function(){
				alert('JQuery AJAX failed!');
		    }
		});
	}
}


jQuery(document).ready(function($) {
    updateCountDowncimMegj1();
    $('#cim1').change(updateCountDowncimMegj1);
    $('#cim1').keyup(updateCountDowncimMegj1);
	updateCountDownleirasMegj1();
	$('#leiras1').change(updateCountDownleirasMegj1);
    $('#leiras1').keyup(updateCountDownleirasMegj1);
	updateCountDownidoMegj1();
	$('#valsec1').change(updateCountDownidoMegj1);
    $('#valsec1').keyup(updateCountDownidoMegj1);
});