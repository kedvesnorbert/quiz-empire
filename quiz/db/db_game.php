<?php
if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {
	require_once("../error.php");
	die(); /*Direct Access Not Allowed */
	exit();
};

function db_getquestion_update()
{
	$con = connect();
	if(!$con)
	{
		return false;
	}
	if($_SESSION['whichType'] <= 0 && $_SESSION['whichType'] >= -2)
	{
		$q = "SELECT * FROM live_question WHERE bool = 0 AND type = '" . mysqli_real_escape_string($con, $_SESSION['whichType']) . "' AND user = '" . mysqli_real_escape_string($con, $_SESSION['user']) . "' ORDER BY RAND() LIMIT 1";
	}
	else
	{
		return false;
	}
	$res = mysqli_query($con, $q);
	if(!$res)
	{
		return false;
	}
	if(mysqli_num_rows($res) == 0)
	{
		return false;
	}
	return $res;
}

function db_updatequizquestion($id)
{
    $con = connect();
    if(!$con)
    {
        return false;
    }
    $q = "UPDATE live_question SET bool = 1 WHERE id = '" . mysqli_real_escape_string($con, $id) . "' AND user= '" . mysqli_real_escape_string($con, $_SESSION['user']) . "'";
    $res = mysqli_query($con, $q);
    mysqli_close($con);	
	if(!$res)
	{
		return false;
	}
    return true;
}

function db_delete_gyakorloquestions()
{
    $con = connect();
    if(!$con)
    {
        return false;
    }
    $res = mysqli_query($con, "DELETE FROM live_question WHERE type = -2 AND user = '" . mysqli_real_escape_string($con, $_SESSION['user']) . "'");
    mysqli_close($con);
    if(!$res)
    {
        return false;
    }
    return true;
}