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
	if(!isset($_POST['groupid']) || !preg_match("/^[0-9]+$/", $_POST["groupid"]) || $_POST["groupid"] < 2)
	{
		echo "Hibás csoportazonosító!";
	}
	elseif(logoff_ajax()==-1)
	{
		echo err_session_timeout();
	}
	else
	{
		$con = connect();
		mysqli_query($con, "SET @p_response");
		mysqli_query($con, "CALL exit_from_chatgroup('" . mysqli_real_escape_string($con, $_POST['groupid']) . "', '" . mysqli_real_escape_string($con, $_SESSION['user_id']) . "', @p_response)");
		$q = "SELECT @p_response AS p_response";
		$kiir = "";
		$res = mysqli_query($con, $q);
		$row = mysqli_fetch_assoc($res);
		$kiir = $row['p_response'];
		mysqli_close($con);
		echo json_encode(array("resp"=>"$kiir"));
	}
}
else
{
	require_once("../error.php");
}
}
?>