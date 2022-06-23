function searching_users(){
	var useritem = $('#search_input').val();
	if(useritem.length < 1 || useritem.length > 30){
		alert("A keresendő kifejezés hossza 1-30 karakter lehet!");
	}
	else{
		jQuery.ajax({
			type: "POST",
			url: "ajax/show_users.php",
			cache:false,
			beforeSend: function(){
				$("#search_button").prop('disabled', true);
				$('#processing_image').css('visibility', 'visible');
			},
			data: {searching_item:useritem},
			success: function(data){
				setTimeout(function(){
					$('#processing_image').css('visibility', 'hidden');
					$('#results_div').html(data);
					$("#search_button").prop('disabled', false);
				}, 1000);
			},
			fail: function(){
				alert('AJAX failed!');
			}
		});	
	}
}

$(document).ready(function(){
    jQuery.ajax({
		type: "POST",
		url: "ajax/show_users.php",
		cache:false,
		beforeSend: function(){
			$("#search_button").prop('disabled', true);
			$('#processing_image').css('visibility', 'visible');
		},
		data: {searching_item:"@!#%^&*"},
		success: function(data){
			setTimeout(function(){
				$('#processing_image').css('visibility', 'hidden');
				$('#results_div').html(data);
				$("#search_button").prop('disabled', false);
			}, 500);
		},
		fail: function(){
			alert('AJAX failed!');
		}
	});	
});
