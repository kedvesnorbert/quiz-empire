$(document).ready(function(){
    $(".togglerQ").click(function(e){
        e.preventDefault();
        $('#detailQ'+$(this).attr('data-prod-cat')).toggle();
    });
	
});

function redirectToView() {
     redirectPage = "quizgame.php";
     window.location = redirectPage;
     return false;
}

function show_beforestartquiz(x, y, z, t, v, p, n, l, w, j){
	var wheight=300;
	$("#dialogBeforeStartQuiz").html('');
	$("#dialogBeforeStartQuiz").html("<p id='dialogBeforeStartQuizTitle' style='text-align:center;'></p><br>");
	$("#dialogBeforeStartQuiz").append("<p id='dialogBeforeStartQuizNumQ' style='text-align:left;'></p>");
	$("#dialogBeforeStartQuiz").append("<p id='dialogBeforeStartQuizSecs' style='text-align:left;'></p>");
	$("#dialogBeforeStartQuizTitle").html(y);
	$("#dialogBeforeStartQuizNumQ").html("Kérdések száma: " + t);
	$("#dialogBeforeStartQuizSecs").html("Egy kérdésre jutó válaszidő: " + z + " másodperc");
	
	if(v==4){
		$("#dialogBeforeStartQuiz").append("<br><center>A folytatáshoz adja meg a kvíz jelszavát!<p></p></center>")
		$("#dialogBeforeStartQuiz").append("<center><div class='pwclass'><input type='password' id='dialogBeforeStartQuizPw' style='text-align:center;width:70%;height:30px;' required></div></center>");
		wheight=400;
	}
	$("#dialogBeforeStartQuiz").dialog({
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

function add_to_favorites(x, y){
	$("#dialogAddToFavorites").html("<center><br>Hozzáadod a kedvencekhez a következő kvízt: <b>" + y + "</b>?</center><br>");
	$("#dialogAddToFavorites").dialog({
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
					url: "ajax/addtofavorites.php",
					data: {fav_quizid: x},
					dataType: "json",
					cache: false,
					async: false,
					success: function(data){
						if(data.resp != "Sikeres művelet!"){
							alert(data.resp);
						}
						else{								
							$("#addToFavorites" + x).replaceWith("<button class='removeFromFavorites' id='removeFromFavorites" + x + "' onclick='remove_from_favorites(" + x + ", " + '"' + y + '"' +")'>Törlés a kedvencekből</button>");
						}
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

function remove_from_favorites(x, y){
	$("#dialogRemoveFromFavorites").html("<center><br>Eltávolítod a kedvencekből a következő kvízt: <b>" + y + "</b>?</center><br>");
	$("#dialogRemoveFromFavorites").dialog({
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
					url: "ajax/removefromfavorites.php",
					data: {notfav_quizid: x},
					dataType: "json",
					cache: false,
					async: false,
					success: function(data){
						if(data.resp != "Sikeres művelet!"){
							alert(data.resp);
						}
						else{								
							$("#removeFromFavorites"+x).replaceWith("<button class='addToFavorites' id='addToFavorites"+x+"' onclick='add_to_favorites("+x+", "+'"' + y+'"'+")'>Hozzáadás a kedvencekhez</button>");
						}
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