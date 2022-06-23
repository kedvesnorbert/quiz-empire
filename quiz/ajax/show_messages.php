<?php
session_start();

require_once("../db/db_connect.php");
require_once("../includes/responses.php");
require_once("../db/db_inbox.php");
require_once("sessiontimeout.php");

if(!isset($_SESSION['user']))
{
    $_SESSION = array();
	session_destroy();
	header("location: ../login.php"); 
}
else
{

function show_viewbutton($idname, $id, $x)
{
	?>
	<button id="<?php echo $idname; ?>" class='btn btn-danger' onclick='mark_as_read("<?php echo $id; ?>", "<?php echo $x; ?>")'>Láttam</button><label id="<?php echo "seenlabel" . $id; ?>" style='margin-left: 15px;visibility:hidden;'><img src="documents/images/ajax-loader.gif" alt="Feldolgozás folyamatban..." width="100%"></label>
	<?php
}

function show_messagesection($x)
{
	if($x > 0){
		$res = db_messagedata($x);
	}
	else{
		$res = db_messagedata_system();
	}

	while($row = mysqli_fetch_assoc($res))
	{
		$t1 = nl2br($row['uzenet']);
		$t2 = $row['ido'];

		if($x <=0)
		{
			echo "<div class='p_messagep'>
						<div class='d-flex justify-content-between'>
							<div id='mybold_div'>SYSTEM &#8594; Én</div>
							<div>"; 
							if($row['latta'] == 0 && ($row['receiver_id'] == $_SESSION['user_id'] || $row['sender_id'] == 0))
							{
								show_viewbutton("seenbutton" . $row['id'], $row['id'], $x);
							}
							echo "</div>
						</div>
					<br>$t1<br><br><font style='font-style:italic;font-size:15px;'>$t2</font></div>";
		}
		else
		{
			if($row['sender_id'] != $_SESSION['user_id'] && $row['sender_id'] != 0)
			{
				echo "<div class='p_messagep'>
						<div class='d-flex justify-content-between'>
						<div id='mybold_div'>" . $row['to_username'] . " &#8594; Én</div>
						<div>"; 
						if($row['latta'] == 0 && ($row['receiver_id'] == $_SESSION['user_id'] || $row['sender_id'] == 0))
						{
							show_viewbutton("seenbutton" . $row['id'], $row['id'], $x);
						}
						echo "</div>
					</div>
					<br>$t1<br><br><font style='font-style:italic;font-size:15px;'>$t2</font></div>";
			}
			else
			{
				echo "<div class='p_messagep_my'>
						<div class='d-flex justify-content-between'>
						<div id='mybold_div'>Én &#8594; " . $row['to_username'] . "</div>
						<div>"; 
							if($row['latta'] == 0 && ($row['receiver_id'] == $_SESSION['user_id'] || $row['sender_id'] == 0))
							{
								show_viewbutton("seenbutton" . $row['id'], $row['id'], $x);
							}
							echo "</div>
						</div>
					<br>$t1<br><br><font style='font-style:italic;font-size:15px;'>$t2</font></div>";
			}
		}
		echo "<br>";
	}	
}

if (isset($_SERVER['HTTP_X_REQUESTED_WITH']) && ($_SERVER['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest')) 
{
	if(!isset($_POST['message_type']) || !preg_match("/^[0-9]+$/", $_POST['message_type']) || $_POST['message_type'] < 0 )
	{
		echo err_missing_data();
	}
	elseif(logoff_ajax()==-1)
	{
		echo err_session_timeout();
	}
	else
	{
		show_messagesection($_POST['message_type']);
	}
}
else
{
	require_once("../error.php");
}
}
?>