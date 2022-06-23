<?php
session_start();

if(!isset($_SESSION['user']))
{
    $_SESSION = array();
	session_destroy();
	header("location: ../login.php"); 
}
else
{
require_once("../db/db_connect.php");
require_once("../db/db_index.php");
require_once("sessiontimeout.php");
require_once("../includes/responses.php");
require_once("../view/view_error.php");
require_once("../view/view_index.php");

if (isset($_SERVER['HTTP_X_REQUESTED_WITH']) && ($_SERVER['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest')) 
{
	if(logoff_ajax()!= -1)
	{
		$res = db_already_started_quiz();
		if(!$res)
		{
			die(err_db());
		}
		if(mysqli_num_rows($res) == 0)
		{
			game_menu();
		}
		else
		{
			game_menu2();
		}
	}
	else
	{
		err_timeout();
	}
}
else
{
	require_once("../error.php");
}

}
?>
