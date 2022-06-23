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
	if(logoff_ajax()== -1)
	{
		echo json_encode(array("resp"=>err_session_timeout()));
	}
	elseif(isset($_POST['q_number']) && !empty($_POST['q_number']) && preg_match("/^[0-9]+$/", $_POST['q_number']) && $_POST['q_number'] >= 1)
	{
		$con = connect();
		if(!$con)
		{
			die(mysqli_connect_error());
		}
		$res = mysqli_query($con, "SELECT like_quiz('" . mysqli_real_escape_string($con, $_SESSION['user_id']) . "', '" . mysqli_real_escape_string($con, $_POST['q_number']) . "') AS p_response");
		mysqli_close($con);
		$row = mysqli_fetch_assoc($res);
		echo json_encode(array("resp"=>$row['p_response']));
	}
}
else
{
	require_once("../error.php");
}
}