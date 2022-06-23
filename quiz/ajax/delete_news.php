<?php
session_start();

require_once("../db/db_connect.php");
require_once("../db/db_index.php");
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
	elseif(!isset($_POST['delnew_id']) || !preg_match("/^[0-9]+$/", $_POST['delnew_id']) || $_POST['delnew_id'] < 1 || !isset($_POST['delnew_reason']) || strlen($_POST['delnew_reason'])< 5 || strlen($_POST['delnew_reason'])>100)
	{
		echo json_encode(array("resp"=>err_missing_data()));
	}
	else
	{
		$con = connect();	
		mysqli_query($con, "SET @p_response");
		mysqli_query($con, "CALL delete_news('" . mysqli_real_escape_string($con, $_SESSION['user_id']) . "', '" . mysqli_real_escape_string($con, $_POST['delnew_id']) . "', '" . mysqli_real_escape_string($con, $_POST['delnew_reason']) . "', @p_response)");
		$q = "SELECT @p_response AS uzenet";
		$res = mysqli_query($con, $q);
		$row = mysqli_fetch_assoc($res);
		$kiir = $row['uzenet'];
		mysqli_close($con);	
		if($kiir == "")
		{
			$res = db_getNewsFilesPath($_POST['delnew_id']);
			if(!$res)
			{
				die(err_db());
			}
			$row = mysqli_fetch_assoc($res);
			if(strlen($row['image_path'])< 1)
			{
				$row['image_path'] = "";
			}
			if(strlen($row['file_path'])< 1)
			{
				$row['file_path'] = "";
			}
			if($row['image_path'] != "")
			{
				unlink("../documents/images/newsimages/" . $row['image_path']);
			}
			if($row['file_path'] != "")
			{
				unlink("../documents/images/newsfiles/" . $row['file_path']);
			}
			$kiir = "mindenok";
		}
		echo json_encode(array("resp"=>"$kiir"));
	}
}
else
{
	require_once("../error.php");
}
}