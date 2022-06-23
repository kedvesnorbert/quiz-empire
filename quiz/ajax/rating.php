<?php
session_start();

require_once("../db/db_connect.php");
require_once("sessiontimeout.php");

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
	if(isset($_POST['rating_number']) && !empty($_POST['rating_number']) && preg_match("/^[0-9]+$/", $_POST['rating_number']) && $_POST['rating_number']>=1 && $_POST['rating_number']<=5 && isset($_POST['q_number']) && !empty($_POST['q_number']) && preg_match("/^[0-9]+$/", $_POST['q_number']) && $_POST['q_number'] >= 1 && logoff_ajax()== 0)
	{
		$con = connect();
		if(!$con)
		{
			die(mysqli_connect_error());
		}
		mysqli_query($con, "SELECT quizrating('" . mysqli_real_escape_string($con, $_SESSION['user_id']) . "', '" . mysqli_real_escape_string($con, $_POST['q_number']) . "', '" . mysqli_real_escape_string($con, $_POST['rating_number']) . "')");
		mysqli_close($con);
	}
}
else
{
	require_once("../error.php");
}
}
?>