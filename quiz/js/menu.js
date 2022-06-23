$(document).ready(function()
{		
	jQuery.ajax({
		type: "POST",
		url: "ajax/check_incoming.php",
		cache:false,
		dataType: "json",
		data: {},
		success: function(data){
			if(data.resp > 0){
				$(".badge").css('visibility','visible');
				$(".badge").text(data.resp);
				//$('.badge').fadeIn(700).delay(5000).fadeOut(1500);
				$('.badge').fadeIn(700);
				
			}
			else{
				$(".badge").css('visibility','hidden');
			}
		},
		fail: function(){
			alert('AJAX failed!');
		}
	});	
	
	setInterval(function() {
		jQuery.ajax({
			type: "POST",
			url: "ajax/check_service_maintenance.php",
			cache:false,
			dataType: "json",
			data: {},
			success: function(data){
				if(data.resp == "igen"){
					window.location.reload();
				}
			},
			fail: function(){
				alert('AJAX failed!');
			}
		});	
		
	}, 120000);
	
});

function log_out() {
	jQuery.ajax({
		type: "POST",
		url: "ajax/logout.php",
		cache: false,
		data: {},
		success: function (data) {
			location.reload();
		},
		fail: function () {
			alert('AJAX failed!');
		}
	});
}