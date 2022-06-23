<?php
session_start();

require_once("../db/db_connect.php");
require_once("sessiontimeout.php");
require_once("../includes/responses.php");
require_once("../db/db_chat.php");
require_once("../view/view_chat.php");

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
	if(logoff_ajax_onlycheck()== -1)
	{
		echo err_session_timeout();
	}
	elseif(!isset($_POST["curr_group"]) || !preg_match("/^[0-9]+$/", $_POST['curr_group']) || $_POST['curr_group'] <= 0)
	{
		echo "Hibás csoport azonosító!";
	}
	else
	{
		show_mygroups();
	}
}
else
{
	require_once("../error.php");
}

	
}


?>
