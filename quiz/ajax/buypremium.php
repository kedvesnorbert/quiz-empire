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
		if(logoff_ajax()==0)
		{
			$con = connect();
			if(!$con)
			{
				die(mysqli_connect_error());
			}
			$res = mysqli_query($con, "SELECT points_to_premium('" . mysqli_real_escape_string($con, $_SESSION['user']) . "') AS p_response");
			mysqli_close($con);
			$row = mysqli_fetch_assoc($res);
			$kiir = $row['p_response'];
			if($kiir == "ok")
			{
				$kiir = "Sikeres művelet!";
			}
			$r = db_get_premiumexpiredate();
			if(!$r)
			{
				die(err_db());
			}
			$ro = mysqli_fetch_assoc($r);
			$resp = array();
			array_push($resp, $ro['premium_expire']);
			array_push($resp, $ro['points']);
			array_push($resp, $kiir);
			echo json_encode($resp);
		}
		else
		{
			$resp = array();
			array_push($resp, err_session_timeout());
			echo json_encode($resp);
		}
	}
	else
	{
		require_once("../error.php");
	}

}
?>