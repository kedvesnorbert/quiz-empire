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
require_once("sessiontimeout.php");

function check_service($a)
{
	if($a == 1){
		$con = connect();
		if(!$con)
		{
			return null;
		}
		mysqli_query($con, "SET @p_response");
		mysqli_query($con, "CALL maintenance_time('" . mysqli_real_escape_string($con, $_SESSION['user']) . "', @p_response)");
		$q = "SELECT @p_response AS p_response";
		$res = mysqli_query($con, $q);
		$row = mysqli_fetch_assoc($res);
		$kiir = $row['p_response'];
		if($kiir == "ok")
		{
			$_SESSION = array();
			session_destroy();
		}
	}
}

if (isset($_SERVER['HTTP_X_REQUESTED_WITH']) && ($_SERVER['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest')) 
{
	if(logoff_ajax_onlycheck()==-1)
	{
		;
	}
	else
	{
		check_service(0);
		echo json_encode(array("resp"=>"nem"));
		//check_service(1);
		//echo json_encode(array("resp"=>"igen"));
	}
}
else
{
	require_once("../error.php");
}
}
?>