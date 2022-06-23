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
require_once("../db/db_index.php");
require_once("../includes/responses.php");

if (isset($_SERVER['HTTP_X_REQUESTED_WITH']) && ($_SERVER['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest')) 
{
	$res = db_logout();
	if(!$res)
	{
		die(err_db());
	}
	$row = mysqli_fetch_assoc($res);
	if($row['is_success'] == 1)
	{
		$_SESSION = array();
		session_destroy();
	}
}
else
{
	require_once("../error.php");
}

}
?>
