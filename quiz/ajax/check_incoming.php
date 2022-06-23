<?php
session_start();

require_once("../db/db_connect.php");
require_once("sessiontimeout.php");
require_once("../includes/responses.php");

if(!isset($_SESSION['user']))
{
    $_SESSION = array();
	session_destroy();
	header("location: ../login.php"); 
}
else
{

function unread_messages()
{
	$con = connect();
	if(!$con)
	{
		return false;
	}
	$log_types = inbox_msg_types();
	$q = "SELECT COUNT(*) AS darab FROM log_data WHERE log_type IN (" . $log_types . ") AND username='" . mysqli_real_escape_string($con, $_SESSION['user']) . "' AND is_seen = 0 UNION SELECT COUNT(*) AS darab FROM private_message WHERE receiver_id='" . mysqli_real_escape_string($con, $_SESSION['user_id']) . "' AND read_msg = 0";
	$osszesen = 0;
	$res = mysqli_query($con, $q);
	while($row = mysqli_fetch_assoc($res))
	{
		$osszesen += $row['darab'];
	}
	
	mysqli_close($con);
	return $osszesen;
}

if (isset($_SERVER['HTTP_X_REQUESTED_WITH']) && ($_SERVER['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest')) 
{
	if(logoff_ajax_onlycheck()!= -1)
	{
		$er = unread_messages();
		echo json_encode(array("resp"=>"$er"));
	}
}
else
{
	require_once("../error.php");
}

	
}


?>
