<?php
if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {
	require_once("../error.php");
	die(); /*Direct Access Not Allowed */
	exit();
};

function db_getuserdata($user)
{
	$con = connect();
	if(!$con)
	{
		return false;
	}
	$q = "SELECT u.id, u.adminuser, u.user, (SELECT COUNT(*) FROM live_question WHERE user = u.user) AS is_quizstarted, (SELECT COUNT(*) FROM live_question WHERE user = u.user AND correct = 1) AS all_totalcorrect, (SELECT DISTINCT(type) FROM live_question WHERE user = u.user) AS quizid FROM user u WHERE u.user = '" . mysqli_real_escape_string($con, $user) . "' OR u.email = '" . mysqli_real_escape_string($con, $user) . "'";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

?>