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
	if(!isset($_POST['groupid']) || !preg_match("/^[0-9]+$/", $_POST["groupid"]) || $_POST["groupid"] < 2)
	{
		echo "Hibás csoport azonosító!";
	}
	elseif(logoff_ajax()==-1)
	{
		echo err_session_timeout();
	}
	else
	{
		show_friends_invite();
	}
}
else
{
	require_once("../error.php");
}
}
?>