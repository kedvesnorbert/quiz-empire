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
	if($_POST['notfav_quizid'] && !empty($_POST['notfav_quizid']) && preg_match("/^[0-9]+$/", $_POST['notfav_quizid']) && $_POST['notfav_quizid']>=1 && logoff_ajax()== 0)
	{
		$con = connect();	
		mysqli_query($con, "SET @p_response");
		mysqli_query($con, "CALL remove_from_favorites('" . mysqli_real_escape_string($con, $_SESSION['user']) . "', '" . mysqli_real_escape_string($con, $_POST['notfav_quizid']) . "', @p_response)");
		$q = "SELECT @p_response AS p_response";
		$res = mysqli_query($con, $q);
		$row = mysqli_fetch_assoc($res);
		$kiir = $row['p_response'];
		mysqli_close($con);		
		echo json_encode(array("resp"=>"$kiir"));
	}
	elseif(logoff_ajax()==-1)
	{
		echo json_encode(array("resp"=>err_session_timeout()));
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