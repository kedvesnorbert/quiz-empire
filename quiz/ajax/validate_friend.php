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
	if(!isset($_POST['friend_id']) || !preg_match("/^[0-9]+$/", $_POST['friend_id']) || $_POST['friend_id'] < 0 ||
	!isset($_POST['act_id']) || !preg_match("/^[0-9]+$/", $_POST['act_id']) || $_POST['act_id'] < 0)
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
		if(!$con)
		{
			die(mysqli_connect_error());
		}
		mysqli_query($con, "SET @p_message");
		mysqli_query($con, "CALL friendship_action('" . mysqli_real_escape_string($con, $_POST['friend_id']) . "', '" . mysqli_real_escape_string($con, $_SESSION['user']) . "', '" . mysqli_real_escape_string($con, $_POST['act_id']) . "', @p_message)");
		$q = "SELECT @p_message AS uzenet";
		$res = mysqli_query($con, $q);
		$row = mysqli_fetch_assoc($res);
		$kiir = $row['uzenet'];
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