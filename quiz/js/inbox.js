$(document).ready(function () {
	show_this_messages(0);
});


function show_this_messages(x){
	$('#description_div').empty();
	$("#senders_div :button").css('border', "none");
	$('#sendername_div'+x).css("border","3px solid black");

	jQuery.ajax({
		type: "POST",
		url: "ajax/show_messages.php",
		cache:false,
		data: {message_type:x},
		beforeSend: function(){
			//$('#sendername_div'+x).prop('disabled', true);
			$("#senders_div :button").prop('disabled', true);
			$('#description_div').html('<div id="loading_showmessagediv" style="margin-top:50px;">Betöltés folyamatban...<br><br><img src="documents/images/ajax-loader.gif" alt="Feldolgozás folyamatban..." width="2%"></div>');
		},
		success: function(data){
			setTimeout(function(){
				$("#loading_showmessagediv").remove();
				$("#description_div").append(data);
				//$('#sendername_div'+x).prop('disabled', false);
				$("#senders_div :button").prop('disabled', false);
			}, 2000);
			
		},
		fail: function(){
			alert('AJAX failed!');
		}
		
	});
}

function mark_as_read(x, y){
	if(!x.match(/^[0-9]+$/) || !y.match(/^[0-9]+$/)){
		alert('Hibás paraméterek!');
	}
	else{
		jQuery.ajax({
		type: "POST",
		url: "ajax/mark_messages_read.php",
		dataType: "json",
		cache:false,
		data: {message_id:x, message_db:y},
		beforeSend: function(){
			$('#seenlabel'+x).css('visibility', 'visible');
			$("#seenbutton"+x).prop('disabled', true);
		},
		success: function(data){
			setTimeout(function(){
				$('#seenlabel'+x).css('visibility', 'hidden');
				$("#seenbutton"+x).prop('disabled', false);
				if(data.resp == ""){
					$("#seenbutton"+x).remove();
				}
				else{
					alert(data.resp);
				}
			}, 1000);
			
		},
		fail: function(){
			alert('AJAX failed!');
		}
		
	});
	}
	
}