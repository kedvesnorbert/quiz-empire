function myFunction() {
	  var x = document.getElementById("myDIV");
	  if (x.style.display === "none") {
		x.style.display = "block";
	  } else {
		x.style.display = "none";
	  }
}

function minKot()
{
	var a = document.getElementById('kerdszam').value;
	var b = Math.round(a * 1.45);
	var c = 'Kötelezően beküldendő: ';
	document.getElementById('kerdszamkot').value = c + b;
}

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

function updateCountDowncimMegj() {
	var remaining = 100 - jQuery('#cim').val().length;
    jQuery('#cimMegj').text(' (' + remaining + ')');
}

function updateCountDownleirasMegj() {
	var remaining = 999 - jQuery('#leiras').val().length;
    jQuery('#leirasMegj').text(' (' + remaining + ')');
}

function updateCountDownokMegj() {
	var remaining = 150 - jQuery('#ok').val().length;
    jQuery('#okMegj').text(' (' + remaining + ')');
}

function updateCountDownszamMegj() {
	var remaining = 2 - jQuery('#kerdszam').val().length;
    jQuery('#szamMegj').text(' ( ' + remaining + ' )');
}

function updateCountDownidoMegj() {
	var remaining = 2 - jQuery('#valsec').val().length;
    jQuery('#idoMegj').text(' ( ' + remaining + ' )');
}

function isValidDate(dateString) {
	var regExp = /^\d{4}-\d{2}-\d{2}$/;
	
	if(!dateString.match(regExp)){
		return false;  // Invalid format
	}
	
	var d = new Date(dateString);
	var dNum = d.getTime();
	
	if(!dNum && dNum !== 0){
		return false; // NaN value, Invalid date
	}
	return d.toISOString().slice(0,10) === dateString;
}

function sendquiz_validation(){
	var cim = $('#cim').val();
	var leiras = $('#leiras').val();
	var ok = $('#ok').val();
	var nyelv = $('#nyelv').val();
	var kvizelerhetoseg = $('#kvizelerhetoseg').val();
	var friends_e = $('#elerheto_select').val();
	var pwt1 = $('#pwt1').val();
	var pwt2 = $('#pwt2').val();
	var numofplaying = $('#numofplaying').val();
	var kerdszam = $('#kerdszam').val();
	var kerdfogadas = $('#kerdfogadas').val();
	var fogad_select = $('#fogad_select').val();
	var valsec = $('#valsec').val();
	var showcorr = $('#showcorr').val();
	var startdate = $('#startd').val();
	var enddate = $('#endd').val();
	var rejtetten = $('#rejtetten');
	var szabalyzat_check = $('#szabalyzat_check');
	
	if(rejtetten.is(':checked')){
		var re = 1;
	}
	else{
		var re = 0;
	}
	
	if(szabalyzat_check.is(':checked')){
		var sza = 1;
	}
	else{
		var sza = 0;
	}
	
	var std_a = new Date(startdate);
	var end_b = new Date(enddate);
	var nowdate = (new Date()).toISOString().split('T')[0];
	
	//alert(cim + "<br>" + leiras + "<br>" + ok + "<br>" + nyelv + "<br>" + kvizelerhetoseg + "<br>" + friends_e + "<br>" + pwt1 + "<br>" + pwt2 + "<br>" + numofplaying + "<br>" + kerdszam + "<br>" + kerdfogadas + "<br>" + fogad_select + "<br>" + valsec + "<br>" + showcorr + "<br>" + startdate + "<br>" + enddate + "<br>" + re + "<br>" + sza + "<br>");
	
	if(cim.length < 1){
		alert("Nem írtad be a kvíz címét!");
		$([document.documentElement, document.body]).animate({
			scrollTop: $("#cimMegj").offset().top
		}, 2000);
		return false;
	}
	else if(cim.length > 100){
		alert("A kvíz címe legfeljebb 100 karakter hosszú lehet!");
		$([document.documentElement, document.body]).animate({
			scrollTop: $("#cimMegj").offset().top
		}, 2000);
		return false;
	}
	else if(leiras.length < 30){
		alert("Adj meg egy legalább 30 karakter hosszú leírást a kvízről!");
		$([document.documentElement, document.body]).animate({
			scrollTop: $("#leirasMegj").offset().top
		}, 2000);
		return false;
	}
	else if(leiras.length > 999){
		alert("A leírás hossza maximum 999 karakter hosszú lehet!");
		$([document.documentElement, document.body]).animate({
			scrollTop: $("#leirasMegj").offset().top
		}, 2000);
		return false;
	}
	else if(ok.length < 5){
		alert("Az létrehozás okát fejtsd ki minimum 5 karakterben!");
		$([document.documentElement, document.body]).animate({
			scrollTop: $("#okMegj").offset().top
		}, 2000);
		return false;
	}
	else if(ok.length > 150){
		alert("A létrehozás oka legfeljebb 150 karakter hosszú lehet!");
		$([document.documentElement, document.body]).animate({
			scrollTop: $("#okMegj").offset().top
		}, 2000);
		return false;
	}
	else if(nyelv < 1){
		alert("Nem választottad ki a kvíz nyelvét!");
		$([document.documentElement, document.body]).animate({
			scrollTop: $("#nyelv").offset().top
		}, 2000);
		return false;
	}
	else if(kvizelerhetoseg < 1){
		alert("Nem választottad ki a kvíz elérhetőséget!");
		$([document.documentElement, document.body]).animate({
			scrollTop: $("#kvizelerhetoseg").offset().top
		}, 2000);
		return false;
	}
	else if(kvizelerhetoseg == 2 && friends_e.length < 1){
		alert("Válassz a barátaid közül (legalább 1-et), akik hozzáférhetnek a kvízedhez!");
		$([document.documentElement, document.body]).animate({
			scrollTop: $("#elerheto_select").offset().top
		}, 2000);
		$('#quizelerh_msg').text("Hibás adat! Jelöld be legalább 1 barátodat!");
		
		return false;
	}
	else if(kvizelerhetoseg == 4 && (pwt1.length < 1 || pwt2.length < 1)){
		alert("Írd be a kvíz jelszavát!");
		$([document.documentElement, document.body]).animate({
			scrollTop: $("#quizpws").offset().top
		}, 2000);
		$('#quizpws_msg').text("Hibás adat! Írd be a kvíz jelszavát!");
		return false;
	}
	else if(kvizelerhetoseg == 4 && pwt1 != pwt2){
		alert("Nem talál a két jelszó!");
		$([document.documentElement, document.body]).animate({
			scrollTop: $("#quizpws").offset().top
		}, 2000);
		$('#quizpws_msg').text("Hibás adat! Töltsd ki újra, mert nem talál a két jelszó!!");
		return false;
	}
	else if(numofplaying < 1){
		alert("Válaszd ki, hogy hányszor lehessen lejátszani a kvízt!");
		$([document.documentElement, document.body]).animate({
			scrollTop: $("#numofplaying").offset().top
		}, 2000);
		return false;
	}
	else if(kerdszam.length < 1){
		alert("Írd be, hogy hány kérdésből álljon a kvíz!");
		$([document.documentElement, document.body]).animate({
			scrollTop: $("#kerdszam").offset().top
		}, 2000);
		return false;
	}
	else if(!kerdszam.match(/^[0-9]+$/)){
		alert("Helytelen értéket adtál meg a kérdések számánál!");
		$([document.documentElement, document.body]).animate({
			scrollTop: $("#kerdszam").offset().top
		}, 2000);
		return false;
	}
	else if(kerdszam < 13){
		alert("A kvíz kötelezően minimum 13 kérdésből kell álljon!");
		$([document.documentElement, document.body]).animate({
			scrollTop: $("#kerdszam").offset().top
		}, 2000);
		return false;
	}
	else if(kerdszam > 45){
		alert("A kvíz legfeljebb 45 kérdésből állhat!");
		$([document.documentElement, document.body]).animate({
			scrollTop: $("#kerdszam").offset().top
		}, 2000);
		return false;
	}
	else if(kerdfogadas < 1){
		alert("Válaszd ki, hogy kiknek engedélyezed a kérdések beküldését a kvízedhez!");
		$([document.documentElement, document.body]).animate({
			scrollTop: $("#kerdfogadas").offset().top
		}, 2000);
		return false;
	}
	else if(kerdfogadas == 3 && fogad_select.length < 1){
		alert("Válassz a barátaid közül (legalább 1-et), akiknek engedélyezed a kérdések beküldését a kvízedhez!");
		$([document.documentElement, document.body]).animate({
			scrollTop: $("#fogad_select").offset().top
		}, 2000);
		$('#quizkerdbekuld_msg').text("Hibás adat! Válaszd ki legalább 1 barátodat a listából!");
		return false;
	}
	else if(valsec.length < 1){
		alert("Írd be a válaszolási időt (másodpercekben kifejezve)!");
		$([document.documentElement, document.body]).animate({
			scrollTop: $("#valsec").offset().top
		}, 2000);
		return false;
	}
	else if(!valsec.match(/^[0-9]+$/)){
		alert("Helytelen értéket adtál meg a válaszolási időnél!");
		$([document.documentElement, document.body]).animate({
			scrollTop: $("#valsec").offset().top
		}, 2000);
		return false;
	}
	else if(valsec < 15){
		alert("A válaszolási idő egy kérdésre minimum 15 másodperc kell legyen!");
		$([document.documentElement, document.body]).animate({
			scrollTop: $("#valsec").offset().top
		}, 2000);
		return false;
	}
	else if(valsec > 99){
		alert("A válaszolási idő egy kérdésre maximum 99 másodperc lehet!");
		$([document.documentElement, document.body]).animate({
			scrollTop: $("#valsec").offset().top
		}, 2000);
		return false;
	}
	else if(showcorr != 1 && showcorr != 2){
		alert('Nem választottad ki, hogy a helyes válaszokat megmutassa a kvízed, vagy sem!');
		$([document.documentElement, document.body]).animate({
			scrollTop: $("#showcorr").offset().top
		}, 2000);
		return false;
	}
	else if(startdate.length > 0 && isValidDate(startdate) == false){
		alert("A kezdő dátum helytelen!");
		$([document.documentElement, document.body]).animate({
			scrollTop: $("#startd").offset().top
		}, 2000);
		return false;
	}
	else if(enddate.length > 0 && isValidDate(enddate) == false){
		alert("A második dátum helytelen!");
		$([document.documentElement, document.body]).animate({
			scrollTop: $("#startd").offset().top
		}, 2000);
		return false;
	}
	else if(startdate.length > 0 && enddate.length > 0 && (end_b-std_a) < 86400000){
		alert('A két dátum között legyen legalább 1 nap! A kezdő dátum nem lehet nagyobb a második dátumnál');
		$([document.documentElement, document.body]).animate({
			scrollTop: $("#startd").offset().top
		}, 2000);
		return false;
	}
	else if(startdate.length > 0 && nowdate > startdate){
		alert('A kezdő dátum nem lehet kisebb a mai napnál!');
		$([document.documentElement, document.body]).animate({
			scrollTop: $("#startd").offset().top
		}, 2000);
		return false;
	}
	else if(enddate.length > 0 && nowdate > enddate){
		alert('A második dátum nem lehet kisebb a mai napnál!');
		$([document.documentElement, document.body]).animate({
			scrollTop: $("#startd").offset().top
		}, 2000);
		return false;
	}
	else if(sza != 1){
		alert('A szabályzat elfogadása kötelező!');
		$([document.documentElement, document.body]).animate({
			scrollTop: $("#szabalyzat_check").offset().top
		}, 2000);
		return false;
	}
	else{
		return true;
	}
}

function show_similar_quiznames() {
	var searching = $('#cim').val();
	if(searching.length < 4){
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
				data: { searching: searching},
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

jQuery(document).ready(function($) {
    updateCountDowncimMegj();
    $('#cim').change(updateCountDowncimMegj);
    $('#cim').keyup(updateCountDowncimMegj);
	updateCountDownleirasMegj();
	$('#leiras').change(updateCountDownleirasMegj);
    $('#leiras').keyup(updateCountDownleirasMegj);
	updateCountDownokMegj();
	$('#ok').change(updateCountDownokMegj);
    $('#ok').keyup(updateCountDownokMegj);
	updateCountDownszamMegj();
	$('#kerdszam').change(updateCountDownszamMegj);
    $('#kerdszam').keyup(updateCountDownszamMegj);
	updateCountDownidoMegj();
	$('#valsec').change(updateCountDownidoMegj);
    $('#valsec').keyup(updateCountDownidoMegj);

});




