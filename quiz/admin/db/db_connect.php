<?php
if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {
	require_once("../../error.php");
	die(); /*Direct Access Not Allowed */
	exit();
};

function connect()
{
	$host = "localhost";
	$user = "root";
	$pass = "";
	$db = "quiz";	
	$con = mysqli_connect($host, $user, $pass, $db);
	if (!$con)
	{
		return false;	
	}
	mysqli_query($con, "CALL connect_database()");
	return $con;
}

function superadmin()
{
	if($_SESSION['user_id'] == 15)
	{
		return true;
	}
	return false;
}
?>