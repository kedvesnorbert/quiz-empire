<?php
if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {
	require_once("../../error.php");
	die(); /*Direct Access Not Allowed */
	exit();
};

function db_getadminuserdata($user)
{
	$con = connect();
	if(!$con)
	{
		return false;
	}
	$q = "SELECT id, adminuser, user FROM user WHERE (user = '" . mysqli_real_escape_string($con, $user) . "' OR email = '" . mysqli_real_escape_string($con, $user) . "') AND adminuser = 1";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

?>