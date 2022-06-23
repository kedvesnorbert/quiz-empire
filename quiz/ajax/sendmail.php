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
	if(!isset($_POST['message_content']) || strlen($_POST['message_content']) < 5 || strlen($_POST['message_content']) > 5000 ||
	!isset($_POST['receiver']) || strlen($_POST['receiver']) < 3 || strlen($_POST['receiver']) > 25)
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
		mysqli_query($con, "SET @p_response");
		mysqli_query($con, "CALL send_private_message('" . mysqli_real_escape_string($con, $_SESSION['user']) . "', '" . mysqli_real_escape_string($con, $_POST['receiver']) . "', '" . mysqli_real_escape_string($con, $_POST['message_content']) . "', @p_response)");
		$q = "SELECT @p_response AS p_response";
		$res = mysqli_query($con, $q);
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