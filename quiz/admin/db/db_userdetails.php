<?php
if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {
	require_once("../../error.php");
	die(); /*Direct Access Not Allowed */
	exit();
};

function db_getuser($id)
{
	$con = connect();
	if (!$con)
	{
		return false;
	}
	$q = "SELECT user FROM user WHERE id = '" . mysqli_real_escape_string($con, $id) . "'";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	$row = mysqli_fetch_assoc($res);
	return $row['user'];
}

function db_userstatusz($id)
{
	$con = connect();
	if (!$con)
	{
		return false;
	}
	$q = "SELECT user, deleteduser FROM user WHERE id = '" . mysqli_real_escape_string($con, $id) . "'";
	$res = mysqli_query($con, $q);
    mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	if(mysqli_num_rows($res) != 1)
	{
		return false;
	}
	return true;
}

function db_userdata($id)
{
	$con = connect();
	if (!$con)
	{
		return false;
	}	
	$q = "SELECT u.*, (SELECT COUNT(t.id_number) FROM thema t JOIN user u ON (t.accomplished_by = u.user) WHERE t.is_deleted = 0 AND t.phase = 3 AND u.id='" . $id . "') AS ownquizzes, (SELECT COUNT(*) FROM favorite_quiz WHERE user_id = u.id) AS favoritequizzes, (SELECT COUNT(*) FROM quiz_like WHERE user_id = u.id) AS likedquizzes, (SELECT COUNT(f.id1) FROM user u JOIN friend f ON f.id1 = u.id JOIN user u2 ON f.id2 = u2.id WHERE u2.id = '" . mysqli_real_escape_string($con, $id) . "' AND f.status = 1 AND u.deleteduser = 0) + (SELECT COUNT(f.id2) FROM user u JOIN friend f ON f.id1 = u.id JOIN user u2 ON f.id2 = u2.id WHERE u.id = '" . mysqli_real_escape_string($con, $id) . "' AND f.status = 1 AND u2.deleteduser = 0) AS friends, (SELECT COUNT(user_id) FROM group_member WHERE user_id = u.id) AS chatgroups, (SELECT COUNT(*) FROM thema WHERE is_request = 1 AND phase = 3 AND accomplished_by = u.user) AS accomplishedrequests, (SELECT COUNT(*) FROM news WHERE publisher_id = u.id AND is_deleted = 0) AS postednews, (SELECT COUNT(*) FROM quiz_comment WHERE user_id = u.id AND is_deleted = 0) AS quizcomments, (SELECT COUNT(*) FROM quiz_question WHERE username = u.user AND is_verified = 1) AS allquestionssent FROM user u WHERE u.id='" . mysqli_real_escape_string($con, $id) . "'";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;	
}

function db_lastplayedquizzes($id)
{
	$con = connect();
	if (!$con)
	{
		return false;
	}
	$q = "SELECT q.test_id, q.is_verified, t.quiz_name temakor, q.totalcorrect totalcorrect, t.num_of_question numofquestion, q.finishing_date idopont, t.pass_degree sikeresseg, q.score score FROM quiz_played q JOIN thema t ON (q.quiz_id = t.id_number) WHERE q.user_id = '" . mysqli_real_escape_string($con, $id) . "' ORDER BY q.finishing_date DESC LIMIT 20";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

function db_alldistinctplayed($userid)
{
	$con = connect();
	if (!$con)
	{
		return false;
	}
	$q = "SELECT q.quiz_id quiz_id, q.test_id test_id, t.num_of_question numofquestion, t.quiz_name temakor, COUNT(q.quiz_id) darab, MAX(q.totalcorrect) legjobb, MAX(q.score) legjobbscore, t.pass_degree sikeresseg FROM thema t JOIN quiz_played q ON (t.id_number = q.quiz_id) WHERE q.user_id = '" . mysqli_real_escape_string($con, $userid) . "' GROUP BY t.quiz_name, q.quiz_id ORDER BY t.quiz_name";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

function db_allattempts($uid)
{
	$con = connect();
	if (!$con)
	{
		return false;
	}
	$q = "SELECT q.totalcorrect totalcorrect, t.num_of_question numofquestion, t.pass_degree sikeresseg, q.finishing_date idopont, q.score score, q.test_id test_id, q.quiz_id quiz_id, t.quiz_name temakor FROM quiz_played q JOIN thema t ON (q.quiz_id = t.id_number) WHERE q.user_id = " . mysqli_real_escape_string($con, $uid) . " ORDER BY t.quiz_name, q.finishing_date";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

function db_quiz_in_process($username)
{
	$con = connect();
	if (!$con)
	{
		return false;
	}
	$q = "SELECT * FROM thema WHERE is_deleted = 0 AND is_request = 0 AND phase < 3 AND requested_by = '" . mysqli_real_escape_string($con, $username) . "'";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

function db_getquestion_stat($bekuldo)
{
	$con = connect();
	if (!$con)
	{
		return false;
	}
	$q = " SELECT id_number AS temakorid, (SELECT COUNT(*) FROM quiz_question WHERE quiz_id = temakorid AND username = '" . mysqli_real_escape_string($con, $bekuldo) . "') AS osszesk, (SELECT COUNT(*) FROM quiz_question WHERE quiz_id = temakorid AND username = '" . mysqli_real_escape_string($con, $bekuldo) . "' AND is_verified IS NOT NULL) AS ellenorzottk, (SELECT COUNT(*) FROM quiz_question WHERE quiz_id = temakorid AND username = '" . mysqli_real_escape_string($con, $bekuldo) . "' AND is_verified = 1) AS elfogadottk FROM thema WHERE requested_by = '" . mysqli_real_escape_string($con, $bekuldo) . "' AND is_deleted = 0 AND is_request = 0 AND phase < 3";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

function db_ownquizzes($userid)
{
    $con = connect();
	if (!$con)
	{
		return false;
	}
    $q = "SELECT id_number, quiz_name, (SELECT COUNT(quiz_id) FROM quiz_played WHERE quiz_id = id_number) played, (SELECT COUNT(quiz_id) FROM quiz_like WHERE quiz_id = id_number) likes, (SELECT SUM(rating)/COUNT(quiz_id) FROM quiz_rating WHERE quiz_id = id_number) rating, (SELECT COUNT(id) FROM quiz_question WHERE quiz_id = id_number AND is_active = 1) questions, (SELECT COUNT(quiz_id) FROM quiz_comment WHERE quiz_id = id_number) comments FROM thema WHERE phase = 3 AND accomplished_by = (SELECT user FROM user WHERE id = '" . mysqli_real_escape_string($con, $userid) . "')";
    $res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

function db_logins($userid)
{
	$con = connect();
	if (!$con)
	{
		return false;
	}
    $q = "SELECT l.* FROM login l WHERE username = (SELECT user FROM user WHERE id = '" . mysqli_real_escape_string($con, $userid) . "') AND is_success = 1 ORDER BY login_date DESC LIMIT 200";
    $res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

function db_userwarns($userid)
{
	$con = connect();
	if (!$con)
	{
		return false;
	}
    $q = "SELECT w.*, (SELECT user FROM user WHERE id = w.deletedby) deletedbyusername FROM warn w WHERE w.userid = '" . mysqli_real_escape_string($con, $userid) . "'";
    $res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

function db_userpremiums($userid)
{
	$con = connect();
	if (!$con)
	{
		return false;
	}
    $q = "SELECT p.*, (SELECT user FROM user WHERE id = p.adminid) givenbyusername, (SELECT user FROM user WHERE id = p.deletedby) deletedbyusername FROM premium p WHERE p.userid = '" . mysqli_real_escape_string($con, $userid) . "'";
    $res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

/*load_userlawdata.php */
function db_getuserlawdata($userid)
{
    $con = connect();
	if (!$con)
	{
		return false;
	}
    $q = "SELECT lawtousechat, lawtosendquestion, lawtopostnews, lawtosearchuser, lawtoeditfaq, lawtogetpoints, lawtosendmail, lawtouserequests, lawtocreatequiz FROM user WHERE id = '" . mysqli_real_escape_string($con, $userid) . "'";
    $res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

/*load_userlawdata_tomodify.php */
function db_getuserlawdatatomodify($userid)
{
    $con = connect();
	if (!$con)
	{
		return false;
	}
    $q = "SELECT id, lawtousechat, lawtosendquestion, lawtopostnews, lawtosearchuser, lawtoeditfaq, lawtogetpoints, lawtosendmail, lawtouserequests, lawtocreatequiz, keep_level, level, points, help, questiontype, (SELECT COUNT(*) FROM premium WHERE userid = '" . mysqli_real_escape_string($con, $userid) . "' AND price = 0 AND minuspoints = 0 AND is_active = 1) freepremium FROM user WHERE id = '" . mysqli_real_escape_string($con, $userid) . "'";
    $res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

/*load_userprofilehidingdata.php */
function db_getuserprofilehidingdata($userid)
{
    $con = connect();
	if (!$con)
	{
		return false;
	}
    $q = "SELECT profilehiding, profilehiding_expire FROM user WHERE id = '" . mysqli_real_escape_string($con, $userid) . "'";
    $res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

/*load_useradmindata.php */
function db_getuseradmindata($userid)
{
    $con = connect();
	if (!$con)
	{
		return false;
	}
    $q = "SELECT adminuser FROM user WHERE id = '" . mysqli_real_escape_string($con, $userid) . "' AND deleteduser = 0";
    $res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

?>