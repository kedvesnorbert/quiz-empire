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
	require_once("../includes/responses.php");
	
	if (isset($_SERVER['HTTP_X_REQUESTED_WITH']) && ($_SERVER['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest')) 
	{
		if(logoff_ajax()==0)
		{
			$con = connect();
			mysqli_query($con, "SET	@p_response");
			mysqli_query($con, "CALL points_to_hiding_profile('" . mysqli_real_escape_string($con, $_SESSION['user']) . "', @p_response)");
			$q = "SELECT @p_response AS p_response";
			$res = mysqli_query($con, $q);
			$row = mysqli_fetch_assoc($res);
			mysqli_close($con);
			$kiir = $row['p_response'];
			$resp = array();
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