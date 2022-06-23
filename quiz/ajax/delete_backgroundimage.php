<?php
session_start();

require_once("../db/db_connect.php");
require_once("../db/db_quizdetails.php");
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
	elseif(!isset($_POST['p_imgid']) || !preg_match("/^[0-9]+$/", $_POST['p_imgid']) || $_POST['p_imgid'] < 1)
	{
		echo json_encode(array("resp"=>err_missing_data()));
	}
	else
	{
		$res_s = db_getBgImagePath($_POST['p_imgid']);
		if(!$res_s)
		{
			die(err_db());
		}
		$con = connect();	
		$res = mysqli_query($con, "SELECT delete_backgroundimage('" . mysqli_real_escape_string($con, $_POST['p_imgid']) . "', '" . mysqli_real_escape_string($con, $_SESSION['user_id']) . "') AS uzenet");
		$row = mysqli_fetch_assoc($res);
		$kiir = $row['uzenet'];
		mysqli_close($con);	
		if($kiir == "ok")
		{
			$row_s = mysqli_fetch_assoc($res_s);
			unlink("../" . $row_s['image_path']);
		}
		echo json_encode(array("resp"=>"$kiir"));
	}
}
else
{
	require_once("../error.php");
}
}