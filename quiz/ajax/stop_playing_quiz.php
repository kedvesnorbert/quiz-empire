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
		if($_SESSION['isCompetition'] == 0 && $_SESSION['num_of_question'] != $_SESSION['numberofquestion'])
		{	
			$_SESSION['numberofquestion'] = $_SESSION['num_of_question'];
			echo json_encode(array("resp"=>"ok"));
		}
		else
		{
			echo json_encode(array("resp"=>err_missing_data()));
		}
	}
	else
	{
		require_once("../error.php");
	}
}
?>