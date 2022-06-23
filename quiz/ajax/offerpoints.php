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
	if(isset($_POST['reqoff_id']) && isset($_POST['reqoff_points']))
	{
		if(logoff_ajax()== -1)
		{
			echo json_encode(array("resp"=>err_session_timeout()));
		}
		elseif(!preg_match("/^[0-9]+$/", $_POST['reqoff_id']) || $_POST['reqoff_id'] < 1)
		{
			echo json_encode(array("resp"=>"Hibás kérés azonosító!"));
		}
		elseif(!preg_match("/^[0-9]+$/", $_POST['reqoff_points']) || $_POST['reqoff_points'] < 30 || $_POST['reqoff_points'] > 10000000)
		{
			echo json_encode(array("resp"=>"A felájanlott pontszám minimum 30 és maximum 10.000.000 legyen!"));
		}
		else
		{
			$con = connect();
			if(!$con)
			{
				die(mysqli_connect_error());
			}
			$res = mysqli_query($con, "SELECT offer_points_to_request('" . mysqli_real_escape_string($con, $_POST['reqoff_id']) . "', '" . mysqli_real_escape_string($con, $_SESSION['user']) . "', '" . mysqli_real_escape_string($con, $_POST['reqoff_points']) . "') AS p_response");
			mysqli_close($con);	
			$row = mysqli_fetch_assoc($res);
			$kiir = $row['p_response'];
			echo json_encode(array("resp"=>"$kiir"));
		}
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