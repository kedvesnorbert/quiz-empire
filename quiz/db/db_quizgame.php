<?php
if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {
	require_once("../error.php");
	die(); /*Direct Access Not Allowed */
	exit();
};

function db_getBackgroundImage()
{
	$con = connect();
	if(!$con)
	{
		return false;
	}
	$q = "SELECT image_path FROM background WHERE quiz_id = '" . mysqli_real_escape_string($con, $_SESSION['whichType']) . "' AND active = 1";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

function db_getquestion()
{
	$con = connect();
	if(!$con)
	{
		return false;
	}
	if($_SESSION['whichType'] < 1)
	{
		return false;
	}
	$q = "SELECT * FROM live_question WHERE bool = 0 AND type = '" . mysqli_real_escape_string($con, $_SESSION['whichType']) . "' AND user = '" . mysqli_real_escape_string($con, $_SESSION['user']) . "' ORDER BY RAND() LIMIT 1";
	$res = mysqli_query($con ,$q);
	if(!$res)
	{
		return false;
	}
	if(mysqli_num_rows($res) == 0)
	{
		return false;
	}
    mysqli_close($con);	
	return $res;
}

function db_updatequestion_answered($helyes, $jeloltvalasz)
{
	$con = connect();
	if(!$con)
	{
		return false;
	}
	$q = "UPDATE live_question SET bool = 1, position = '" . mysqli_real_escape_string($con, $_SESSION['numberofquestion']) . "', correct = '" . mysqli_real_escape_string($con, $helyes) . "', own_answer = '" . mysqli_real_escape_string($con, $jeloltvalasz) . "' WHERE id = '" . mysqli_real_escape_string($con, $_SESSION['currentquestionid']) . "' AND user= '" . mysqli_real_escape_string($con, $_SESSION['user']) . "'";
    $res = mysqli_query($con, $q);
	if(!$res)
	{
		return false;
	}
	mysqli_close($con);
	return true;
}

?>