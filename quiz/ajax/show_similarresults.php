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
		if(isset($_POST['searching']) && strlen($_POST['searching'])>3 && logoff_ajax()== 0)
		{
			$con = connect();
			if(!$con)
			{
				die(mysqli_connect_error());
			}
			$keres = '%' . mysqli_real_escape_string($con, $_POST['searching']) . '%';
			$q = "SELECT quiz_name FROM thema WHERE quiz_name LIKE '" . $keres . "' AND is_deleted = 0 ORDER BY quiz_name";
			$res = mysqli_query($con, $q);
			mysqli_close($con);
			$list_results = array();
			while($row = mysqli_fetch_assoc($res))
			{
				array_push($list_results, $row['quiz_name']);
			}
			$commaList = implode('<br>', $list_results);
			echo json_encode(array("resp"=>$commaList));
		}
	}
	else
	{
		require_once("../error.php");
	}
}
?>