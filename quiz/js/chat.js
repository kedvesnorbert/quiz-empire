var current_groupid = 1;
var toggle_count = 1;

$(document).ready(function () {
	$('#msg_text').keypress(function (e) {
		if (e.keyCode == 13)
			$('#send_msg_button').click();
	});
});

function toggle_chatdetails(){
	if (toggle_count%2 == 0){
		$("#third_msgdiv").css("display", "block");
		$("#second_msgdiv").css("width", "40%");
		$("#third_msgdiv").css("width", "30%");
	}
	else{
		$("#third_msgdiv").css("display", "none");
		$("#second_msgdiv").css("width", "70%");
	}
	toggle_count = toggle_count + 1;
}

function show_this_msglist(x){
	if(!x.match(/^[0-9]+$/)){
		current_groupid = 1;
	}
	else{
		current_groupid = x;
	}
	$("#firstdiv_first :button").css('border', "none");
	$('#groupname_div'+x).css("border","3px solid red");
	$('#chatlogs').html('<div id="chatlogs" style="width:100%; text-align:center; margin-top:20px; margin-bottom:30px;"><br>Loading chatlogs, please wait! (A BETÖLTÉS FOLYAMATBAN...) <br><br><center><img src="documents/images/ajax-loader.gif" width="40" /></center></div>');
	jQuery.ajax({
		type: "POST",
		url: "ajax/group_details.php",
		cache:false,
		data: {curr_group:current_groupid},
		success: function(data){
			$('#group_det_div').html(data);
			
		},
		fail: function(){
			alert('AJAX failed!');
		}
		
	});	
}

function submitChat(){
	if(document.getElementById("msg_text").value == '')  
	{
		alert("Írd be az üzeneted!");
		return;
	}
	$('#imageload').css('visibility','visible');
	var msg = document.getElementById("msg_text").value;
	var xmlhttp = new XMLHttpRequest();
	
	xmlhttp.onreadystatechange = function()
	{
		if(xmlhttp.readyState==4&&xmlhttp.status==200)
		{
			if(xmlhttp.responseText.search("<table ") != -1){
				document.getElementById('chatlogs').innerHTML = xmlhttp.responseText;
			}
			else{
				alert(xmlhttp.responseText);
			}
			$('#imageload').css('visibility','hidden');
		}
	}
	xmlhttp.open('GET', 'ajax/insert_msg.php?&msg='+encodeURIComponent(msg)+'&groupid='+current_groupid, true);
	xmlhttp.send();
	document.getElementById("msg_text").value = '';
}

$(document).ready(function(e)
{
	$.ajaxSetup({cache:false});
	setInterval(function() {		
		jQuery.ajax({
			type: "POST",
			url: "ajax/logs.php",
			cache:false,
			data: {curr_group:current_groupid},
			success: function(data){
				if(data.length > 4){
					$('#chatlogs').html(data);
				}
			},
			fail: function(){
				alert('AJAX failed!');
			}
		});	
	}, 2500);
	setInterval(function() {	
		jQuery.ajax({
			type: "POST",
			url: "ajax/my_groups.php",
			cache:false,
			data: {curr_group:current_groupid},
			success: function(data){
				if(data.length > 4){
					$('#my_groupsdiv').html(data);
				}
			},
			fail: function(){
				alert('AJAX failed!');
			}
		});	
		
	}, 5000);
});

function creating_newgroup(){
	$('#dialogCreateNewGroup').html("<br><table id='d_newgrouptable'><tr><td> Csoport neve </td><td><input type='text' id='d_newgroup' maxlength='25'></td><tr><td></td><td><div id='loading_friendsdiv'></div></td><tr><td>Tagok kiválasztása</td><td><select id='d_friendstogroup' multiple></td></select><tr><td>További tagok felvétele</td><td><select id='d_whocaninvitemembers'><option value='0'>Csak én</option><option value='1'>Mindenki a csoportból</option></select></td><tr><td colspan='2'><div id='d_notafriend'></div></td>");
	
	jQuery.ajax({
		type: "POST",
		url: "ajax/load_friends.php",
		data: {},
		cache: false,
		beforeSend: function(){
			$('#loading_friendsdiv').append('<div id="loading_showfriendsdiv" style="margin-top:10px;margin-bottom:10px;">Barátok betöltése...<img src="documents/images/ajax-loader.gif" alt="Feldolgozás folyamatban..." width="12%"></div>')
		},
		success: function(data){
			setTimeout(function(){
				$("#loading_friendsdiv").remove();
				if(data == "no_friends"){
					$('#d_notafriend').html("<font color='darkred'>Jelenleg egy barátod sincs! Emiatt nem hozhatsz létre új csoportot!</font>");
				}
				else{
					$('#d_friendstogroup').append(data);
				}
			}, 1500);
			
			
		},
		fail: function(){
			alert("Failed!");
		}
		
	});
	
	
	$("#dialogCreateNewGroup").dialog({
		maxWidth:600,
		width:600,
		height:500,
		modal:true,
		open: function(event, ui) {
			$(".ui-dialog-titlebar-close").hide();
		},
		position: { my: 'top', at: 'top+150' },
		buttons: {
			"Létrehozás": function(){
				var ids = $('#d_friendstogroup').val();
				var name_group = $('#d_newgroup').val();
				var who_can_invite = $('#d_whocaninvitemembers').val();
				if(ids.length < 1){
					alert("Nem választottál ki tagokat! Legalább 1 barátodat meg kell hívnod a csoportba!");
				}
				else if(name_group.length < 5 || name_group.length > 25){
					alert("A csoport neve 5-25 karakter lehet!");
				}
				else if(who_can_invite != 0 && who_can_invite != 1){
					alert("Hiba a további tagok meghívása kiválasztásánál!");
				}
				else{
					jQuery.ajax({
						type: "POST",
						url: "ajax/create_newgroup.php",
						data: {name_group: name_group, group_invitemembers: ids, group_whocaninvite: who_can_invite},
						dataType: "json",
						cache: false,
						success: function(data){
							if(data.resp == "ok"){
								alert("A csoport létrejött!");
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

function add_new_member(csoport){
	if(!csoport.match(/^[0-9]+$/) || csoport == 1){
		alert("Hibás csoport azonosító!");
	}
	else{
		$('#dialogAddNewMember').html("<br><p id='d_addnewmember_p'>Válaszd ki a barátodat a listából!</p><br><div id='loading_friendstoinvitediv'></div><center><select id='d_addnewmember_select'></select></center><br><p id='d_addnewmember_notep'>Megjegyzés: Egyszerre csak 1 barátodat adhatod hozzá a csoporthoz!</p><div id='d_notafriend'></div>");
	
		jQuery.ajax({
			type: "POST",
			url: "ajax/load_friends_to_invite.php",
			data: {groupid: csoport},
			cache: false,
			beforeSend: function(){
				$('#loading_friendstoinvitediv').append('<div id="loading_showfriendstoinvitediv" style="margin-top:10px;margin-bottom:10px;">Barátok betöltése...<img src="documents/images/ajax-loader.gif" alt="Feldolgozás folyamatban..." width="7%"></div>')
			},
			success: function(data){
				setTimeout(function(){
					$("#loading_friendstoinvitediv").remove();
					if(data == "no_friends"){
						$('#d_notafriend').html("<font color='darkred'>Úgy tűnik jelenleg nem áll módodban hozzáadni tagokat a csoporthoz!</font>");
					}
					else{
						$('#d_addnewmember_select').append(data);
					}
				}, 1500);
				
				
			},
			fail: function(){
				alert("Failed!");
			}
			
		});
		
		
		$("#dialogAddNewMember").dialog({
			maxWidth:600,
			width:600,
			height:370,
			modal:true,
			open: function(event, ui) {
				$(".ui-dialog-titlebar-close").hide();
			},
			position: { my: 'top', at: 'top+150' },
			buttons: {
				"Hozzáadás": function(){
					var friend_id = $('#d_addnewmember_select').val();
					if(friend_id == null){
						alert("Nem választottad ki a barátodat!");
					}
					else if(!friend_id.match(/^[0-9]+$/)){
						alert("Nem választottad ki a barátodat!!!");
					}
					else{
						jQuery.ajax({
							type: "POST",
							url: "ajax/invite_member.php",
							data: {invited_friend: friend_id, groupid: csoport},
							dataType: "json",
							cache: false,
							success: function(data){
								if(data.resp == ""){
									alert("A barátodat felvetted ebbe a csoportba!");
									jQuery.ajax({
										type: "POST",
										url: "ajax/group_details.php",
										cache:false,
										data: {curr_group:current_groupid},
										success: function(data){
											$('#group_det_div').html(data);
											
										},
										fail: function(){
											alert('AJAX failed!');
										}
										
									});	
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
}

function remove_from_thisgroup(csoport, userid, z){
	if(!csoport.match(/^[0-9]+$/) || csoport == 1){
		alert("Hibás csoport azonosító!");
	}
	else if(!userid.match(/^[0-9]+$/)){
		alert("Hibás felhasználó azonosító!");
	}
	else{
		$('#dialogRemoveMember').html("<br><p id='d_removemember_p'>Biztosan el szeretnéd távolítani a/az <b><u>" + z + "</u></b> nevű tagot a csoportból?<br></p>");
		
		$("#dialogRemoveMember").dialog({
			maxWidth:600,
			width:600,
			height:230,
			modal:true,
			open: function(event, ui) {
				$(".ui-dialog-titlebar-close").hide();
			},
			position: { my: 'top', at: 'top+150' },
			buttons: {
				"Igen": function(){
					jQuery.ajax({
						type: "POST",
						url: "ajax/removefromgroup.php",
						data: {groupid: csoport, userid: userid},
						dataType: "json",
						cache: false,
						success: function(data){
							if(data.resp == ""){
								alert("Eltávolítottad a csoportból a felhasználót!");
								jQuery.ajax({
									type: "POST",
									url: "ajax/group_details.php",
									cache:false,
									data: {curr_group:csoport},
									success: function(data){
										$('#group_det_div').html(data);
										
									},
									fail: function(){
										alert('AJAX failed!');
									}
									
								});	
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
		
				},
				"Mégsem": function(){
					$(this).dialog('destroy');
				}
			}
		});	
	}
}

function exit_thisgroup(csoport, csopnev){
	if(!csoport.match(/^[0-9]+$/) || csoport == 1){
		alert("Hibás csoport azonosító!");
	}
	else{
		$('#dialogExitGroup').html("<br><p id='d_removemember_p'>Kilépsz a/az <b><u>" + csopnev + "</u></b> nevű csoportból?<br><br></p><p style='align:left;color:red;'>A csoport elhagyása után már nem fogod látni az üzeneteket. <br>Figyelem! Ez a művelet nem vonható vissza.</p>");
		
		$("#dialogExitGroup").dialog({
			maxWidth:600,
			width:600,
			height:280,
			modal:true,
			open: function(event, ui) {
				$(".ui-dialog-titlebar-close").hide();
			},
			position: { my: 'top', at: 'top+150' },
			buttons: {
				"Igen": function(){
					jQuery.ajax({
						type: "POST",
						url: "ajax/exit_group.php",
						data: {groupid: csoport},
						dataType: "json",
						cache: false,
						success: function(data){
							if(data.resp == ""){
								alert("Kiléptél a csoportból!");
								jQuery.ajax({
									type: "POST",
									url: "ajax/group_details.php",
									cache:false,
									data: {curr_group:csoport},
									success: function(data){
										$('#group_det_div').html(data);
										
									},
									fail: function(){
										alert('AJAX failed!');
									}
									
								});
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
		
				},
				"Mégsem": function(){
					$(this).dialog('destroy');
				}
			}
		});	
	}
}

function delete_thisgroup(csoport, csopnev){
	if(!csoport.match(/^[0-9]+$/) || csoport == 1){
		alert("Hibás csoport azonosító!");
	}
	else{
		$('#dialogDeleteGroup').html("<br><p id='d_removemember_p'>Biztosan törölni szeretnéd a/az <b><u>" + csopnev + "</u></b> nevű csoportot?<br><br></p><p style='align:left;color:red;'>Megjegyzés: A csoportot ezzel végleg lezárod. <br>Figyelem! Ez a művelet nem vonható vissza.</p>");
		
		$("#dialogDeleteGroup").dialog({
			maxWidth:600,
			width:600,
			height:280,
			modal:true,
			open: function(event, ui) {
				$(".ui-dialog-titlebar-close").hide();
			},
			position: { my: 'top', at: 'top+150' },
			buttons: {
				"Csoport törlése": function(){
					jQuery.ajax({
						type: "POST",
						url: "ajax/delete_group.php",
						data: {groupid: csoport},
						dataType: "json",
						cache: false,
						success: function(data){
							if(data.resp == ""){
								alert("Törölted a csoportot!");
								jQuery.ajax({
									type: "POST",
									url: "ajax/group_details.php",
									cache:false,
									data: {curr_group:csoport},
									success: function(data){
										$('#group_det_div').html(data);
										
									},
									fail: function(){
										alert('AJAX failed!');
									}
									
								});
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
		
				},
				"Mégsem": function(){
					$(this).dialog('destroy');
				}
			}
		});	
	}
}

function chat_history(csoport){
	if (!csoport.match(/^[0-9]+$/) || csoport == 1) {
		alert("Hibás csoport azonosító!");
	}
	else {
		$('#dialogChatHistory').html('<div id="loading_chathistorydiv" style="margin-top:10px; margin-bottom:10px;">Előzmények betöltése...<br><br><img src="documents/images/ajax-loader.gif" alt="Feldolgozás folyamatban..." width="8%"></div><div id="historydata"></div>');

		$("#dialogChatHistory").dialog({
			maxWidth: 800,
			width: 700,
			height: 400,
			modal: true,
			open: function (event, ui) {
				$(".ui-dialog-titlebar-close").hide();

				jQuery.ajax({
					type: "POST",
					url: "ajax/show_chathistory.php",
					data: { groupid: csoport },
					cache: false,
					success: function (data) {
						setTimeout(function () {
							$('#dialogChatHistory').html(data);
						}, 1000);

					},
					fail: function () {
						alert("Failed!");
					}
				});

			},
			position: { my: 'top', at: 'top+150' },
			buttons: {
				"Bezárás": function () {
					$(this).dialog('destroy');
				}
			}
		});
	}
}