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
	if(isset($_POST['delreq_id']) && isset($_POST['delreq_reason']))
	{
		if(logoff_ajax()== -1)
		{
			echo json_encode(array("resp"=>err_session_timeout()));
		}
		elseif(!preg_match("/^[0-9]+$/", $_POST['delreq_id']) || $_POST['delreq_id'] < 1)
		{
			echo json_encode(array("resp"=>"Hibás kérés azonosító!"));
		}
		elseif(strlen($_POST['delreq_reason']) < 5 || strlen($_POST['delreq_reason']) > 150)
		{
			echo json_encode(array("resp"=>"A törlés oka 5-150 karakter legyen!"));
		}
		else
		{
			$con = connect();	
			mysqli_query($con, "SET @p_response");
			mysqli_query($con, "CALL delete_request('" . mysqli_real_escape_string($con, $_POST['delreq_id']) . "', '" . mysqli_real_escape_string($con, $_SESSION['user']) . "', '" . mysqli_real_escape_string($con, $_POST['delreq_reason']) . "', @p_response)");
			$q = "SELECT @p_response AS p_response";
			$res = mysqli_query($con, $q);
			$row = mysqli_fetch_assoc($res);
			$kiir = $row['p_response'];
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