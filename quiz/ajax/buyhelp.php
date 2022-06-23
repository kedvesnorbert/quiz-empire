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
		if(isset($_POST['darabszam']) && !empty($_POST['darabszam']) && strlen($_POST['darabszam']) <= 3 && filter_var($_POST['darabszam'], FILTER_VALIDATE_INT) == true && $_POST['darabszam'] > 0 && $_POST['darabszam'] < 101)
		{	
			if(logoff_ajax()==0)
			{
				$con = connect();
				if(!$con)
				{
					die(mysqli_connect_error());
				}
				mysqli_query($con, "SET	@p_response");
				mysqli_query($con, "CALL buy_help('" . mysqli_real_escape_string($con, $_SESSION['user']) . "', '" . mysqli_real_escape_string($con, $_POST["darabszam"]) . "', @p_response)");
				$q = "SELECT @p_response AS p_response";
				$res = mysqli_query($con, $q);
				$row = mysqli_fetch_assoc($res);
				$kiir = $row['p_response'];
				mysqli_close($con);
				$r = db_get_num_of_helps();
				if($r)
				{
					$ro = mysqli_fetch_assoc($r);
					$counthelps = $ro['help'];
					$pointsleft = $ro['points'];
					$resp = array();
					array_push($resp, $counthelps);
					array_push($resp, $pointsleft);
					array_push($resp, $kiir);
					echo json_encode($resp);
				}
				else
				{
					$resp = array();
					array_push($resp, 0);
					array_push($resp, 0);
					array_push($resp, "Frissítsd az oldalt!");
					echo json_encode($resp);
				}
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
			$resp = array();
			array_push($resp, err_missing_data());
			echo json_encode($resp);
		}
	}
	else
	{
		require_once("../error.php");
	}

}
?>