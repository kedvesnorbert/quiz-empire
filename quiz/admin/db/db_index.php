<?php
if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {
	require_once("../../error.php");
	die(); /*Direct Access Not Allowed */
	exit();
};


/*ajax/logout.php */
function db_adminlogout()
{
    $con = connect();
	if(!$con)
    {
		return false;
	}
	$q = "SELECT logout('" . mysqli_real_escape_string($con, $_SESSION['adminuser']) . "', 1, 1, '" . mysqli_real_escape_string($con, $_SESSION['login_time']) . "') AS is_success";
	$res = mysqli_query($con, $q);
    mysqli_close($con);
    if(!$res)
    {
        return false;
    }
    return $res;
}

function db_allcompetition()
{
    $con = connect();
    if(!$con)
    {
        return false;
    }
    $q = "SELECT c.*, t.quiz_name, (NOW() > c.enddate) AS is_expired FROM competition c JOIN thema t ON (c.quiz_id = t.id_number) ORDER BY c.enddate DESC LIMIT 100";
    $res = mysqli_query($con, $q);
    mysqli_close($con);
    if(!$res)
    {
        return false;
    }
    return $res;
}

function db_competitiondata_forupdate($id)
{
    $con = connect();
    if(!$con)
    {
        return false;
    }
    $q = "SELECT * FROM competition c WHERE id = '" . mysqli_real_escape_string($con, $id) . "'";
    $res = mysqli_query($con, $q);
    mysqli_close($con);
    if(!$res)
    {
        return false;
    }
    return $res;
}

function db_quizlist_forupdate()
{
    $con = connect();
	if (!$con)
	{
		return false;
	}
    $q = "SELECT id_number, quiz_name FROM thema WHERE phase = 3 ORDER BY quiz_name";
    $res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

?>