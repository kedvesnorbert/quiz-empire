<?php
if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {
	require_once("../error.php");
	die(); /*Direct Access Not Allowed */
	exit();
};

function db_getRang()
{
	$con = connect();
	if(!$con)
	{
		return false;
	}
	$res = mysqli_query($con, "SELECT level, lawtouserequests FROM user WHERE user='" . mysqli_real_escape_string($con, $_SESSION['user']) . "'");
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

?>