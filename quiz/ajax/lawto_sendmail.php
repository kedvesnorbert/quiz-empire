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

if (isset($_SERVER['HTTP_X_REQUESTED_WITH']) && ($_SERVER['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest')) 
{
	if(!isset($_POST['friend_id']) || !preg_match("/^[0-9]+$/", $_POST['friend_id']) || $_POST['friend_id'] < 0)
	{
		echo json_encode(array("resp"=>err_missing_data()));
	}
	elseif(logoff_ajax()==-1)
	{
		echo json_encode(array("resp"=>err_session_timeout()));
	}
	else
	{
		$con = connect();	
		$res = mysqli_query($con, "SELECT status_send_message('" . mysqli_real_escape_string($con, $_SESSION['user_id']) . "', '" . mysqli_real_escape_string($con, $_POST['friend_id']) . "') AS p_response");
		$row = mysqli_fetch_assoc($res);
		$kiir = $row['p_response'];
		mysqli_close($con);
		echo json_encode(array("resp"=>"$kiir"));
	}
}
else
{
	require_once("../error.php");
}
}
?>