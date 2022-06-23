<?php

if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {
	require_once("../error.php");
	die(); /*Direct Access Not Allowed */
	exit();
};

function check_functions()
{
	$con = connect();
	if(!$con)
	{
		return;
	}
	$q = "CALL verify_procedures('" . mysqli_real_escape_string($con, $_SESSION['user']) . "')";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		die(err_db());
	}
}

function free_premium()
{
	$con = connect();
	db_free_premium();
}

check_functions();

?>