<?php
if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {
	require_once("../error.php");
	die(); /*Direct Access Not Allowed */
	exit();
};

function db_using_usersearch()
{
	$con = connect();
	if(!$con)
	{
		return false;
	}
	$q = "SELECT lawtosearchuser FROM user WHERE id = '" . mysqli_real_escape_string($con, $_SESSION["user_id"]) . "'";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	$row = mysqli_fetch_assoc($res);
	if($row['lawtosearchuser'] == 1)
	{
		return true;
	}
	return false;
}

/*ajax/db_searchuser.php */
function db_getlastregistered()
{
	$con = connect();
	if (!$con)
	{
		return false;
	}
	$q = "SELECT id, user, level, registrtime, lastvisit FROM user WHERE deleteduser = 0 AND profilehiding = 0 ORDER BY registrtime DESC LIMIT 15";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

function db_keres($uservalue)
{
	$con = connect();
	if (!$con)
	{
		return false;
	}
	$nev = $uservalue . '%';
	$q = "SELECT id, user, level, registrtime, lastvisit FROM user WHERE user LIKE '" . mysqli_real_escape_string($con, $nev) . "' AND deleteduser = 0 AND profilehiding = 0 ORDER BY user LIMIT 100";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}



?>