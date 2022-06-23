var nextq_loading = '<font color="black">Következő kérdés betöltése ... </font><img src="documents/images/ajax-loader.gif" width="2.4%"/>';

function validateMyForm1_B(){
	$("#quiz_time_header").html(nextq_loading);
    $("#bt1").css('visibility', 'visible');
    $("#bt2").css('visibility', 'visible');
    $("#bt3").css('visibility', 'visible');
    $("#bt4").css('visibility', 'visible');
	$('#bt1').css('pointer-events','none');
	$('#bt2').css('pointer-events','none');
	$('#bt3').css('pointer-events','none');
	$('#bt4').css('pointer-events','none');
	$("#exitbtn").css('visibility', 'hidden');
	
	jQuery.ajax({
		type: "POST",
		url: "ajax/quiz_showans.php",
		dataType: "json",
		cache:false,
		async: false,
		data: {validated: 1},
		success: function(data){
			resultObj = eval (data);
			if(resultObj[0] == "ok"){
				var correct = resultObj[1]; var cor = resultObj[2]; var corr = resultObj[3]; var cor4 = resultObj[4]; var contents = resultObj[5]; var contents1 = resultObj[6]; var contents2 = resultObj[7]; var contents3 = resultObj[8];
				
				if(contents == corr){
					$("#bt1").css("transition-delay","1s");
					$("#bt1").css("transition-duration","1s");
					$("#bt1").css("background-color","#32CD32");
				}
				else{
					$("#bt1").css("transition-delay","1s");
					$("#bt1").css("transition-duration","1s");
					$("#bt1").css("background-color","red");
				}	
			}
		},
		fail: function(){
			alert('AJAX failed!');
		}
		
	}); 
}

function validateMyForm1(){
	$("#quiz_time_header").html(nextq_loading);
    $("#bt1").css('visibility', 'visible');
    $("#bt2").css('visibility', 'visible');
    $("#bt3").css('visibility', 'visible');
    $("#bt4").css('visibility', 'visible');
	$('#bt1').css('pointer-events','none');
	$('#bt2').css('pointer-events','none');
	$('#bt3').css('pointer-events','none');
	$('#bt4').css('pointer-events','none');
	$("#exitbtn").css('visibility', 'hidden');
	jQuery.ajax({
		type: "POST",
		url: "ajax/quiz_showans.php",
		dataType: "json",
		cache:false,
		async: false,
		data: {validated: 1},
		success: function(data){
			resultObj = eval (data);
			if(resultObj[0] == "ok"){
				var correct = resultObj[1]; var cor = resultObj[2]; var corr = resultObj[3]; var cor4 = resultObj[4]; var contents = resultObj[5]; var contents1 = resultObj[6]; var contents2 = resultObj[7]; var contents3 = resultObj[8];
				
				if(contents == corr){
					$("#bt1").css("transition-delay","1s");
					$("#bt1").css("transition-duration","1s");
					$("#bt1").css("background-color","#32CD32");
				}
				else{
					$("#bt1").css("transition-delay","1s");
					$("#bt1").css("transition-duration","1s");
					$("#bt1").css("background-color","red");
					
					if(contents == corr){
						
							 var i = 0;
							 function change() {
								var doc = document.getElementById("bt1");
								var color = ["white", "32cd32"];
								doc.style.backgroundColor = color[i];
								i = (i + 1) % color.length;
							}
							setInterval(change, 700);         
					}
					if(contents1 == corr){
						
							 var i = 0;
							 function change() {
								var doc = document.getElementById("bt2");
								var color = ["white", "32cd32"];
								doc.style.backgroundColor = color[i];
								i = (i + 1) % color.length;
							}
							setInterval(change, 700);
					   
					}
					if(contents2 == corr){
						
							 var i = 0;
							 function change() {
								var doc = document.getElementById("bt3");
								var color = ["white", "32cd32"];
								doc.style.backgroundColor = color[i];
								i = (i + 1) % color.length;
							}
							setInterval(change, 700);
					   
					}
					if(contents3 == corr){
						
							 var i = 0;
							 function change() {
								var doc = document.getElementById("bt4");
								var color = ["white", "32cd32"];
								doc.style.backgroundColor = color[i];
								i = (i + 1) % color.length;
							}
							setInterval(change, 700);
					   
					}
				}
				
			}
		},
		fail: function(){
			alert('AJAX failed!');
		}
		
	}); 
}

function validateMyForm4(){
	$("#quiz_time_header").html(nextq_loading);
    $("#bt1").css('visibility', 'visible');
    $("#bt2").css('visibility', 'visible');
    $("#bt3").css('visibility', 'visible');
    $("#bt4").css('visibility', 'visible');
	$('#bt1').css('pointer-events','none');
	$('#bt2').css('pointer-events','none');
	$('#bt3').css('pointer-events','none');
	$('#bt4').css('pointer-events','none');
	$("#exitbtn").css('visibility', 'hidden');
	
	jQuery.ajax({
		type: "POST",
		url: "ajax/quiz_showans.php",
		dataType: "json",
		cache:false,
		async: false,
		data: {validated: 4},
		success: function(data){
			resultObj = eval (data);
			if(resultObj[0] == "ok"){
				var correct = resultObj[1]; var cor = resultObj[2]; var corr = resultObj[3]; var cor4 = resultObj[4]; var contents = resultObj[5]; var contents1 = resultObj[6]; var contents2 = resultObj[7]; var contents3 = resultObj[8];
				
				if(contents == corr){
					$("#bt4").css("transition-delay","1s");
					$("#bt4").css("transition-duration","1s");
					$("#bt4").css("background-color","#32CD32");
				}
				else{
					$("#bt4").css("transition-delay","1s");
					$("#bt4").css("transition-duration","1s");
					$("#bt4").css("background-color","red");
					
					if(contents3 == corr){
						
							 var i = 0;
							 function change() {
								var doc = document.getElementById("bt1");
								var color = ["white", "32cd32"];
								doc.style.backgroundColor = color[i];
								i = (i + 1) % color.length;
							}
							setInterval(change, 700);         
					}
					if(contents1 == corr){
						
							 var i = 0;
							 function change() {
								var doc = document.getElementById("bt2");
								var color = ["white", "32cd32"];
								doc.style.backgroundColor = color[i];
								i = (i + 1) % color.length;
							}
							setInterval(change, 700);
					   
					}
					if(contents2 == corr){
						
							 var i = 0;
							 function change() {
								var doc = document.getElementById("bt3");
								var color = ["white", "32cd32"];
								doc.style.backgroundColor = color[i];
								i = (i + 1) % color.length;
							}
							setInterval(change, 700);
					   
					}
					if(contents == corr){
						
							 var i = 0;
							 function change() {
								var doc = document.getElementById("bt4");
								var color = ["white", "32cd32"];
								doc.style.backgroundColor = color[i];
								i = (i + 1) % color.length;
							}
							setInterval(change, 700);
					}
				}
				
			}
		},
		fail: function(){
			alert('AJAX failed!');
		}
		
	});
}

function validateMyForm4_B(){
	$("#quiz_time_header").html(nextq_loading);
    $("#bt1").css('visibility', 'visible');
    $("#bt2").css('visibility', 'visible');
    $("#bt3").css('visibility', 'visible');
    $("#bt4").css('visibility', 'visible');
	$('#bt1').css('pointer-events','none');
	$('#bt2').css('pointer-events','none');
	$('#bt3').css('pointer-events','none');
	$('#bt4').css('pointer-events','none');
	$("#exitbtn").css('visibility', 'hidden');
	
	jQuery.ajax({
		type: "POST",
		url: "ajax/quiz_showans.php",
		dataType: "json",
		cache:false,
		async: false,
		data: {validated: 4},
		success: function(data){
			resultObj = eval (data);
			if(resultObj[0] == "ok"){
				var correct = resultObj[1]; var cor = resultObj[2]; var corr = resultObj[3]; var cor4 = resultObj[4]; var contents = resultObj[5]; var contents1 = resultObj[6]; var contents2 = resultObj[7]; var contents3 = resultObj[8];
				
				if(contents == corr){
					$("#bt4").css("transition-delay","1s");
					$("#bt4").css("transition-duration","1s");
					$("#bt4").css("background-color","#32CD32");
				}
				else{
					$("#bt4").css("transition-delay","1s");
					$("#bt4").css("transition-duration","1s");
					$("#bt4").css("background-color","red");
				}
				
			}
		},
		fail: function(){
			alert('AJAX failed!');
		}
	});
}

function validateMyForm2(){
	$("#quiz_time_header").html(nextq_loading);
    $("#bt1").css('visibility', 'visible');
    $("#bt2").css('visibility', 'visible');
    $("#bt3").css('visibility', 'visible');
    $("#bt4").css('visibility', 'visible');
	$('#bt1').css('pointer-events','none');
	$('#bt2').css('pointer-events','none');
	$('#bt3').css('pointer-events','none');
	$('#bt4').css('pointer-events','none');
	$("#exitbtn").css('visibility', 'hidden');
	
	jQuery.ajax({
		type: "POST",
		url: "ajax/quiz_showans.php",
		dataType: "json",
		cache:false,
		async: false,
		data: {validated: 2},
		success: function(data){
			resultObj = eval (data);
			if(resultObj[0] == "ok"){
				var correct = resultObj[1]; var cor = resultObj[2]; var corr = resultObj[3]; var cor4 = resultObj[4]; var contents = resultObj[5]; var contents1 = resultObj[6]; var contents2 = resultObj[7]; var contents3 = resultObj[8];
				
				if(contents == corr){
					$("#bt2").css("transition-delay","1s");
					$("#bt2").css("transition-duration","1s");
					$("#bt2").css("background-color","#32CD32");
				}
				else{
					$("#bt2").css("transition-delay","1s");
					$("#bt2").css("transition-duration","1s");
					$("#bt2").css("background-color","red");
					
					if(contents1 == corr){
						
							 var i = 0;
							 function change() {
								var doc = document.getElementById("bt1");
								var color = ["white", "32cd32"];
								doc.style.backgroundColor = color[i];
								i = (i + 1) % color.length;
							}
							setInterval(change, 700);         
					}
					if(contents == corr){
						
							 var i = 0;
							 function change() {
								var doc = document.getElementById("bt2");
								var color = ["white", "32cd32"];
								doc.style.backgroundColor = color[i];
								i = (i + 1) % color.length;
							}
							setInterval(change, 700);
					   
					}
					if(contents2 == corr){
						
							 var i = 0;
							 function change() {
								var doc = document.getElementById("bt3");
								var color = ["white", "32cd32"];
								doc.style.backgroundColor = color[i];
								i = (i + 1) % color.length;
							}
							setInterval(change, 700);
					   
					}
					if(contents3 == corr){
						
							 var i = 0;
							 function change() {
								var doc = document.getElementById("bt4");
								var color = ["white", "32cd32"];
								doc.style.backgroundColor = color[i];
								i = (i + 1) % color.length;
							}
							setInterval(change, 700);
					}
				}
				
			}
		},
		fail: function(){
			alert('AJAX failed!');
		}
		
	});
}

function validateMyForm2_B(){
	$("#quiz_time_header").html(nextq_loading);
    $("#bt1").css('visibility', 'visible');
    $("#bt2").css('visibility', 'visible');
    $("#bt3").css('visibility', 'visible');
    $("#bt4").css('visibility', 'visible');
	$('#bt1').css('pointer-events','none');
	$('#bt2').css('pointer-events','none');
	$('#bt3').css('pointer-events','none');
	$('#bt4').css('pointer-events','none');
	$("#exitbtn").css('visibility', 'hidden');
	
	jQuery.ajax({
		type: "POST",
		url: "ajax/quiz_showans.php",
		dataType: "json",
		cache:false,
		async: false,
		data: {validated: 2},
		success: function(data){
			resultObj = eval (data);
			if(resultObj[0] == "ok"){
				var correct = resultObj[1]; var cor = resultObj[2]; var corr = resultObj[3]; var cor4 = resultObj[4]; var contents = resultObj[5]; var contents1 = resultObj[6]; var contents2 = resultObj[7]; var contents3 = resultObj[8];
				
				if(contents == corr){
					$("#bt2").css("transition-delay","1s");
					$("#bt2").css("transition-duration","1s");
					$("#bt2").css("background-color","#32CD32");
				}
				else{
					$("#bt2").css("transition-delay","1s");
					$("#bt2").css("transition-duration","1s");
					$("#bt2").css("background-color","red");
				}
				
			}
		},
		fail: function(){
			alert('AJAX failed!');
		}
		
	});
}

function validateMyForm3(){
	$("#quiz_time_header").html(nextq_loading);
    $("#bt1").css('visibility', 'visible');
    $("#bt2").css('visibility', 'visible');
    $("#bt3").css('visibility', 'visible');
    $("#bt4").css('visibility', 'visible');
	$('#bt1').css('pointer-events','none');
	$('#bt2').css('pointer-events','none');
	$('#bt3').css('pointer-events','none');
	$('#bt4').css('pointer-events','none');
	$("#exitbtn").css('visibility', 'hidden');
	
	jQuery.ajax({
		type: "POST",
		url: "ajax/quiz_showans.php",
		dataType: "json",
		cache:false,
		async: false,
		data: {validated: 3},
		success: function(data){
			resultObj = eval (data);
			if(resultObj[0] == "ok"){
				var correct = resultObj[1]; var cor = resultObj[2]; var corr = resultObj[3]; var cor4 = resultObj[4]; var contents = resultObj[5]; var contents1 = resultObj[6]; var contents2 = resultObj[7]; var contents3 = resultObj[8];
				
				if(contents == corr){
					$("#bt3").css("transition-delay","1s");
					$("#bt3").css("transition-duration","1s");
					$("#bt3").css("background-color","#32CD32");
				}
				else{
					$("#bt3").css("transition-delay","1s");
					$("#bt3").css("transition-duration","1s");
					$("#bt3").css("background-color","red");
					
					if(contents1 == corr){
						
							 var i = 0;
							 function change() {
								var doc = document.getElementById("bt1");
								var color = ["white", "32cd32"];
								doc.style.backgroundColor = color[i];
								i = (i + 1) % color.length;
							}
							setInterval(change, 700);         
					}
					if(contents2 == corr){
						
							 var i = 0;
							 function change() {
								var doc = document.getElementById("bt2");
								var color = ["white", "32cd32"];
								doc.style.backgroundColor = color[i];
								i = (i + 1) % color.length;
							}
							setInterval(change, 700);
					   
					}
					if(contents == corr){
						
							 var i = 0;
							 function change() {
								var doc = document.getElementById("bt3");
								var color = ["white", "32cd32"];
								doc.style.backgroundColor = color[i];
								i = (i + 1) % color.length;
							}
							setInterval(change, 700);
					   
					}
					if(contents3 == corr){
						
							 var i = 0;
							 function change() {
								var doc = document.getElementById("bt4");
								var color = ["white", "32cd32"];
								doc.style.backgroundColor = color[i];
								i = (i + 1) % color.length;
							}
							setInterval(change, 700);
					}
				}
			}
		},
		fail: function(){
			alert('AJAX failed!');
		}
		
	});	
}

function validateMyForm3_B(){
	$("#quiz_time_header").html(nextq_loading);
    $("#bt1").css('visibility', 'visible');
    $("#bt2").css('visibility', 'visible');
    $("#bt3").css('visibility', 'visible');
    $("#bt4").css('visibility', 'visible');
	$('#bt1').css('pointer-events','none');
	$('#bt2').css('pointer-events','none');
	$('#bt3').css('pointer-events','none');
	$('#bt4').css('pointer-events','none');
	$("#exitbtn").css('visibility', 'hidden');
	
	jQuery.ajax({
		type: "POST",
		url: "ajax/quiz_showans.php",
		dataType: "json",
		cache:false,
		async: false,
		data: {validated: 3},
		success: function(data){
			resultObj = eval (data);
			if(resultObj[0] == "ok"){
				var correct = resultObj[1]; var cor = resultObj[2]; var corr = resultObj[3]; var cor4 = resultObj[4]; var contents = resultObj[5]; var contents1 = resultObj[6]; var contents2 = resultObj[7]; var contents3 = resultObj[8];
				
				if(contents == corr){
					$("#bt3").css("transition-delay","1s");
					$("#bt3").css("transition-duration","1s");
					$("#bt3").css("background-color","#32CD32");
				}
				else{
					$("#bt3").css("transition-delay","1s");
					$("#bt3").css("transition-duration","1s");
					$("#bt3").css("background-color","red");
				}
			}
		},
		fail: function(){
			alert('AJAX failed!');
		}
		
	});	
}

function stop_playing(){
	
	$("#dialogLeaveQuiz").dialog({
		maxWidth: 600,
		width: 600,
		height: 200,
		modal: true,
		open: function (event, ui) {
			$(".ui-dialog-titlebar-close").hide();
		},
		position: { my: 'top', at: 'top+150' },
		buttons: {
			"Kilépés": function () {
				jQuery.ajax({
					type: "POST",
					url: "ajax/stop_playing_quiz.php",
					dataType: "json",
					cache:false,
					data: {},
					success: function(data){
						if(data.resp == "ok"){
							location.reload();
						}
					},
					fail: function(){
						alert('AJAX failed!');
					}
				});
				

			},
			"Mégsem": function () {
				$(this).dialog('destroy');
			}
		}
	});
}

window.onload = function(){

	(function(){
	var counter = $("#time_left_ans").val();
	var wait_seconds = $("#time_left_ans").val() - 3;

	setInterval(function() {
    counter--;
	
	if(counter < 10){
		document.getElementById("quiz_time_header").style.color = "red";
	}
	
    if (counter >= 0) {
      span = document.getElementById("count");
      span.innerHTML = counter;
    }
    
    if (counter === 0) {
        clearInterval(counter);
    }

	}, 1000);

	})();
	
	history.pushState(null, null, location.href);
	window.onpopstate = function()
	{
		history.go(1);
	};
	
	document.onkeydown = function (e) {
        return false;
	}
	
	document.oncontextmenu = function (e) 
	{										
		 e.preventDefault();			//blokkolja a billentyuzet helyi menu gombjat
		 return false; 
	}
	
}