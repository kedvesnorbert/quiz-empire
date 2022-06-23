<?php
session_start();

require_once("../db/db_connect.php");
require_once("../db/db_profile.php");
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
	if(!isset($_POST['updated_id']) || !preg_match("/^[0-9]+$/", $_POST['updated_id']) || $_POST['updated_id'] < 0 || $_POST['updated_id'] > 2)
	{
		echo json_encode(array("resp"=>err_missing_data()));
	}
	elseif(logoff_ajax()==-1)
	{
		echo json_encode(array("resp"=>err_session_timeout()));
	}
	else
	{
		if(db_update_acceptingmsg($_POST['updated_id']) == true)
		{
			echo json_encode(array("resp"=>"A módosítás sikerűlt!"));
		}
		else
		{
			echo json_encode(array("resp"=>"Nem történt módosulás."));
		}
	}
}
else
{
	require_once("../error.php");
}
}
?>