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
	if(isset($_POST['req_id']) && isset($_POST['req_anonymous']))
	{
		if(logoff_ajax()== -1)
		{
			echo json_encode(array("resp"=>err_session_timeout()));
		}
		elseif(!preg_match("/^[0-9]+$/", $_POST['req_id']) || $_POST['req_id'] < 1)
		{
			echo json_encode(array("resp"=>"Hibás kérés azonosító!"));
		}
		elseif($_POST['req_anonymous'] != 0 && $_POST['req_anonymous'] != 1)
		{
			echo json_encode(array("resp"=>"HIBA! Helytelen érték a Teljesítés Anonymusként mezőben!"));
		}
		else
		{
			$con = connect();	
			mysqli_query($con, "SET @p_uzenet");
			mysqli_query($con, "CALL accomplish_request('" . mysqli_real_escape_string($con, $_POST['req_id']) . "', '" . mysqli_real_escape_string($con, $_SESSION['user']) . "', '" . mysqli_real_escape_string($con, $_POST['req_anonymous']) . "', @p_uzenet)");
			$q = "SELECT @p_uzenet AS uzenet";
			$res = mysqli_query($con, $q);
			$row = mysqli_fetch_assoc($res);
			$kiir = $row['uzenet'];
			mysqli_close($con);	
			if($kiir == "Sikeres művelet!")
			{
				$kiir = "mindenok";
			}
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