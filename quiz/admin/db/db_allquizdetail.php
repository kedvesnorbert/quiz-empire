<?php
if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {
	require_once("../../error.php");
	die(); /*Direct Access Not Allowed */
	exit();
};

function db_getquiz_main_data($id)
{
	$con = connect();
	if(!$con)
	{
		return false;
	}
	$q = "SELECT quiz_name, language, accomplished_by FROM thema WHERE id_number = '" . mysqli_real_escape_string($con, $id) . "' AND phase = 3";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res || mysqli_num_rows($res) != 1)
	{
		return false;
	}
	return $res;
}

function db_getquizdata($id)
{
	$con = connect();
	if(!$con)
	{
		return false;
	}
	$q = "SELECT t.*, u.id accomplish_userid, (SELECT id FROM user WHERE user = t.requested_by) requestedby_id, (SELECT COUNT(quiz_id) FROM favorite_quiz WHERE quiz_id = '" . mysqli_real_escape_string($con, $id) . "') favoritequiz, (SELECT COUNT(*) FROM quiz_like WHERE quiz_id = '" . mysqli_real_escape_string($con, $id) . "') quizlike, (SELECT CASE WHEN 0 != (SELECT COUNT(quiz_id) FROM quiz_rating WHERE quiz_id = '" . mysqli_real_escape_string($con, $id) . "') THEN SUM(rating)/COUNT(quiz_id) ELSE 0 END FROM quiz_rating WHERE quiz_id = '" . mysqli_real_escape_string($con, $id) . "') quizrating, (SELECT COUNT(quiz_id) FROM background WHERE quiz_id = '" . mysqli_real_escape_string($con, $id) . "' AND active = 1) backgrounds, (SELECT COUNT(quiz_id) FROM quiz_played WHERE quiz_id = '" . mysqli_real_escape_string($con, $id) . "') quizplayed, (SELECT CASE WHEN 0 != (SELECT COUNT(finishing_date) FROM quiz_played WHERE quiz_id = '" . mysqli_real_escape_string($con, $id) . "') THEN MAX(finishing_date) ELSE 'Még nem volt lejátszva' END FROM quiz_played) lastplayedquiz, (SELECT COUNT(*) FROM quiz_question WHERE quiz_id = '" . mysqli_real_escape_string($con, $id) . "' AND is_verified = 1) allactivequestion, (SELECT COUNT(quiz_id) FROM quiz_comment WHERE quiz_id = '" . mysqli_real_escape_string($con, $id) . "' AND is_deleted = 0) quizcomments FROM thema t JOIN user u ON (t.accomplished_by = u.user) WHERE t.id_number = '" . mysqli_real_escape_string($con, $id) . "' AND t.phase = 3";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res || mysqli_num_rows($res) != 1)
	{
		return false;
	}
	return $res;
}

function db_friends_access_quiz_d($quizid)
{
	$con = connect();
	if (!$con)
	{
		return false;
	}
	$res = mysqli_query($con, "SELECT u.user username, u.id id FROM permission_play_quiz p JOIN user u ON (p.userid = u.id) WHERE p.quizid = '" . mysqli_real_escape_string($con, $quizid) . "'");
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

function db_friends_sendquestion($quizid)
{
	$con = connect();
	if (!$con)
	{
		return false;
	}
	$res = mysqli_query($con, "SELECT u.user username, u.id id FROM permission_submit_question p JOIN user u ON (p.userid = u.id) WHERE p.quizid = '" . mysqli_real_escape_string($con, $quizid) . "'");
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

function db_userfriends($userid)
{
	$con = connect();
	if(!$con)
	{
		return false;
	}
	$q = "SELECT f.id1 azon, u.user nev FROM user u JOIN friend f ON f.id1 = u.id JOIN user u2 ON f.id2 = u2.id WHERE u2.id = '" . mysqli_real_escape_string($con, $userid) . "' AND f.status = 1 AND u.deleteduser = 0 UNION SELECT f.id2 azon, u2.user nev FROM user u JOIN friend f ON f.id1 = u.id JOIN user u2 ON f.id2 = u2.id WHERE u.id = '" . mysqli_real_escape_string($con, $userid) . "' AND f.status = 1 AND u2.deleteduser = 0";
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

function db_quizlikes($id)
{
	$con = connect();
	if (!$con)
	{
		return false;
	}
	$q = "SELECT u.id userid, u.user username FROM user u JOIN quiz_like q ON (u.id = q.user_id) WHERE q.quiz_id = '" . mysqli_real_escape_string($con, $id) . "' ORDER BY q.liking_date";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

?>