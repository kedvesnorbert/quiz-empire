<?php
if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {
	require_once("../error.php");
	die(); /*Direct Access Not Allowed */
	exit();
};

function db_baratLista()
{
	$con = connect();
	if(!$con)
	{
		return false;
	}
	$q = "SELECT f.id1 azon, u.user nev FROM user u JOIN friend f ON f.id1 = u.id JOIN user u2 ON f.id2 = u2.id WHERE u2.user = '" . mysqli_real_escape_string($con, $_SESSION['user']) . "' AND f.status = 1 UNION SELECT f.id2 azon, u2.user nev FROM user u JOIN friend f ON f.id1 = u.id JOIN user u2 ON f.id2 = u2.id WHERE u.user = '" . mysqli_real_escape_string($con, $_SESSION['user']) . "' AND f.status = 1";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	if(mysqli_num_rows($res))
	{
		return $res;
	}
	return false;
}

function db_keszithetQuizt()
{
	$con = connect();
	if(!$con)
	{
		return false;
	}
	$q = "SELECT lawtosendquestion, lawtocreatequiz FROM user WHERE id='" . mysqli_real_escape_string($con, $_SESSION['user_id']) . "'";
	$res = mysqli_query($con, $q);
    mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	$row = mysqli_fetch_assoc($res);
	if($row['lawtosendquestion'] == 1 && $row['lawtocreatequiz'] == 1)
	{
		return true;
	}
	return false;
}

function db_getRang()
{
	$con = connect();
	if(!$con)
	{
		return false;
	}
	$res = mysqli_query($con, "SELECT level FROM user WHERE id='" . mysqli_real_escape_string($con, $_SESSION['user_id']) . "'");
	if(!$res)
	{
		return false;
	}
	$row = mysqli_fetch_assoc($res);
	mysqli_close($con);
	if($row['level'] > 4)
	{
		return true;
	}
	return false;
}



?>