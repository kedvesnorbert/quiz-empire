function validateHelp(x){
	if(x.match(/^[0-9]+$/) && x > 0 && x < 4){
		if(x == 3){
			$("#teljes").css('visibility', 'hidden');
			$('#felezo').attr("disabled", true);
			$('#negyedelo').attr("disabled", true);
		}
		else if(x == 2){
			$("#felezo").css('visibility', 'hidden');
			$('#teljes').attr("disabled", true);
			$('#negyedelo').attr("disabled", true);
		}
		else{
			$("#negyedelo").css('visibility', 'hidden');
			$('#teljes').attr("disabled", true);
			$('#felezo').attr("disabled", true);
		}
		
		jQuery.ajax({
			type: "POST",
			url: "ajax/quiz_helper.php",
			dataType: "json",
			cache:false,
			async: false,
			data: {help_type:x},
			success: function(data){
				resultObj = eval (data);
				
				if(x == 3 && resultObj[0] == "ok"){
					var r = resultObj[1]; var rr = resultObj[2]; var rrr = resultObj[3]; 
					var content1 = resultObj[4];var content2 = resultObj[5]; var content3 = resultObj[6]; var content4 = resultObj[7];
					$('#teljes').attr("disabled", true);
					$("#teljes").css('visibility', 'hidden');
					if(content1 == r){
						$("#bt1").css('visibility', 'hidden');
					}
					else if(content2 == r){
						$("#bt2").css('visibility', 'hidden');
					}
					else if(content3 == r){
						$("#bt3").css('visibility', 'hidden');
					}
					else if(content4 == r){
						$("#bt4").css('visibility', 'hidden');
					}
					if(content1 == rr){
						$("#bt1").css('visibility', 'hidden');
					}
					else if(content2 == rr){
						$("#bt2").css('visibility', 'hidden');
					}
					else if(content3 == rr){
						$("#bt3").css('visibility', 'hidden');
					}
					else if(content4 == rr){
						$("#bt4").css('visibility', 'hidden');
					}
					if(content1 == rrr){
						$("#bt1").css('visibility', 'hidden');
					}
					else if(content2 == rrr){
						$("#bt2").css('visibility', 'hidden');
					}
					else if(content3 == rrr){
						$("#bt3").css('visibility', 'hidden');
					}
					else if(content4 == rrr){
						$("#bt4").css('visibility', 'hidden');
					}
					
				}
				else if(x == 2 && resultObj[0] == "ok"){
					var r = resultObj[1]; 
					var rr = resultObj[2]; 
					var content1 = resultObj[3];
					var content2 = resultObj[4]; 
					var content3 = resultObj[5]; 
					var content4 = resultObj[6];
					$('#felezo').attr("disabled", true);
					$("#felezo").css('visibility', 'hidden');
					if(content1 == r){
						$("#bt1").css('visibility', 'hidden');
					}
					else if(content2 == r){
						$("#bt2").css('visibility', 'hidden');
					}
					else if(content3 == r){
						$("#bt3").css('visibility', 'hidden');
					}
					else if(content4 == r){
						$("#bt4").css('visibility', 'hidden');
					}
					if(content1 == rr){
						$("#bt1").css('visibility', 'hidden');
					}
					else if(content2 == rr){
						$("#bt2").css('visibility', 'hidden');
					}
					else if(content3 == rr){
						$("#bt3").css('visibility', 'hidden');
					}
					else if(content4 == rr){
						$("#bt4").css('visibility', 'hidden');
					}
				}
				else if(x == 1 && resultObj[0] == "ok"){
					var r = resultObj[1]; var content1 = resultObj[2]; var content2 = resultObj[3]; var content3 = resultObj[4]; var content4 = resultObj[5];
					$('#negyedelo').attr("disabled", true);
					$("#negyedelo").css('visibility', 'hidden');
					if(content1 == r){
						$("#bt1").css('visibility', 'hidden');
					}
					else if(content2 == r){
						$("#bt2").css('visibility', 'hidden');
					}
					else if(content3 == r){
						$("#bt3").css('visibility', 'hidden');
					}
					else if(content4 == r){
						$("#bt4").css('visibility', 'hidden');
					}
				}
				
			},
			fail: function(){
				alert('AJAX failed!');
			}
		});
	}
}

function validateMyForm1(){
	$('#teljes').attr("disabled", true);
	$('#felezo').attr("disabled", true);
	$('#negyedelo').attr("disabled", true);
    $("#bt1").css('visibility', 'visible');
    $("#bt2").css('visibility', 'visible');
    $("#bt3").css('visibility', 'visible');
    $("#bt4").css('visibility', 'visible');
	$('#bt1').css('pointer-events','none');
	$('#bt2').css('pointer-events','none');
	$('#bt3').css('pointer-events','none');
	$('#bt4').css('pointer-events','none');
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
	$('#teljes').attr("disabled", true);
	$('#felezo').attr("disabled", true);
	$('#negyedelo').attr("disabled", true);
    $("#bt1").css('visibility', 'visible');
    $("#bt2").css('visibility', 'visible');
    $("#bt3").css('visibility', 'visible');
    $("#bt4").css('visibility', 'visible');
	$('#bt1').css('pointer-events','none');
	$('#bt2').css('pointer-events','none');
	$('#bt3').css('pointer-events','none');
	$('#bt4').css('pointer-events','none');
	
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

function validateMyForm2(){
	$('#teljes').attr("disabled", true);
	$('#felezo').attr("disabled", true);
	$('#negyedelo').attr("disabled", true);
    $("#bt1").css('visibility', 'visible');
    $("#bt2").css('visibility', 'visible');
    $("#bt3").css('visibility', 'visible');
    $("#bt4").css('visibility', 'visible');
	$('#bt1').css('pointer-events','none');
	$('#bt2').css('pointer-events','none');
	$('#bt3').css('pointer-events','none');
	$('#bt4').css('pointer-events','none');
	
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

function validateMyForm3(){
	$('#teljes').attr("disabled", true);
	$('#felezo').attr("disabled", true);
	$('#negyedelo').attr("disabled", true);
    $("#bt1").css('visibility', 'visible');
    $("#bt2").css('visibility', 'visible');
    $("#bt3").css('visibility', 'visible');
    $("#bt4").css('visibility', 'visible');
	$('#bt1').css('pointer-events','none');
	$('#bt2').css('pointer-events','none');
	$('#bt3').css('pointer-events','none');
	$('#bt4').css('pointer-events','none');
	
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
	
window.onload = function(){

	(function(){
	var counter = 20;

	setInterval(function() {
    counter--;
    if (counter >= 0) {
      span = document.getElementById("count");
      span.innerHTML = counter;
    }
    if(counter <= 2){
        $("#negyedelo").css('visibility', 'hidden');
        $("#felezo").css('visibility', 'hidden');
        $("#teljes").css('visibility', 'hidden');
        
    }
    
    if(counter <= 2){
        $("#bt1").css('visibility', 'visible');
        $("#bt2").css('visibility', 'visible');
        $("#bt3").css('visibility', 'visible');
        $("#bt4").css('visibility', 'visible');
    }
    
    if (counter === 0) {
        clearInterval(counter);
    }

	}, 1000);

	})();

	document.onkeydown = function (e) {
		return false;
	}

	document.oncontextmenu = function (e) 
	{										
		 e.preventDefault();			
		 return false; 
	}
}