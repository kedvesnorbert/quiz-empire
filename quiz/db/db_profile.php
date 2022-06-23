<?php
if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {
	require_once("../error.php");
	die(); /*Direct Access Not Allowed */
	exit();
};

function db_userstatusz($id)
{
	$con = connect();
	if (!$con)
	{
		return -1;
	}
	$q = "SELECT user, deleteduser, profilehiding FROM user WHERE id = '" . mysqli_real_escape_string($con, $id) . "'";
	$res = mysqli_query($con, $q);
	if(!$res)
	{
		return -1;
	}
	if(mysqli_num_rows($res) < 1)
	{
		return -1;
	}
	$row = mysqli_fetch_assoc($res);
	mysqli_close($con);
	if($row['user'] == $_SESSION['user'])
	{
		return 1;
	}
	if($row['profilehiding'] == 1)
	{
		return -1;
	}
	if($row['deleteduser'] != 0)
	{
		return -2;
	}
	return 0;
}

function db_getid()
{
	$con = connect();
	if (!$con)
	{
		return false;
	}
	$q = "SELECT id FROM user WHERE user = '" . mysqli_real_escape_string($con, $_SESSION['user']) . "'";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	$row = mysqli_fetch_assoc($res);
	return $row['id'];
}

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

function db_getuserdata($id)
{
	$con = connect();
	if (!$con)
	{
		return false;
	}
	$res = mysqli_query($con, "SELECT level, premium FROM user WHERE id = '" . mysqli_real_escape_string($con, $id) . "'");
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

function db_listarolam($id)
{
	$con = connect();
	if (!$con)
	{
		return false;
	}
	$q = "SELECT u.*, (SELECT COUNT(t.id_number) FROM thema t JOIN user u ON (t.accomplished_by = u.user) WHERE t.is_deleted = 0 AND t.phase = 3 AND u.id='" . mysqli_real_escape_string($con, $id) . "') AS ownquizzes, (SELECT COUNT(*) FROM favorite_quiz WHERE user_id = u.id) AS favoritequizzes, (SELECT COUNT(f.id1) FROM user u JOIN friend f ON f.id1 = u.id JOIN user u2 ON f.id2 = u2.id WHERE u2.id = '" . mysqli_real_escape_string($con, $id) . "' AND f.status = 1 AND u.deleteduser = 0) + (SELECT COUNT(f.id2) FROM user u JOIN friend f ON f.id1 = u.id JOIN user u2 ON f.id2 = u2.id WHERE u.id = '" . mysqli_real_escape_string($con, $id) . "' AND f.status = 1 AND u2.deleteduser = 0) AS friends, (SELECT COUNT(user_id) FROM group_member WHERE user_id = u.id) AS chatgroups, (SELECT COUNT(*) FROM thema WHERE is_request = 1 AND phase = 3 AND accomplished_by = u.user) AS accomplishedrequests, (SELECT COUNT(*) FROM news WHERE publisher_id = u.id AND is_deleted = 0) AS postednews, (SELECT COUNT(*) FROM quiz_comment WHERE user_id = u.id AND is_deleted = 0) AS quizcomments, (SELECT COUNT(*) FROM quiz_question WHERE username = u.user AND is_verified = 1) AS allquestionssent FROM user u WHERE u.id='" . mysqli_real_escape_string($con, $id) . "'";
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
	$q = "SELECT q.totalcorrect totalcorrect, t.num_of_question numofquestion, t.pass_degree sikeresseg, q.finishing_date idopont, q.score score, q.test_id test_id, q.quiz_id quiz_id, t.quiz_name temakor FROM quiz_played q JOIN thema t ON (q.quiz_id = t.id_number) WHERE q.user_id = '" . mysqli_real_escape_string($con, $uid) . "' ORDER BY t.quiz_name, q.finishing_date";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

function db_sajatkvizek_folyamatban()
{
	$con = connect();
	if (!$con)
	{
		return false;
	}
	$q = "SELECT * FROM thema WHERE is_deleted = 0 AND is_request = 0 AND phase < 3 AND requested_by = '" . mysqli_real_escape_string($con, $_SESSION['user']) . "'";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

function db_warn($userid)
{
	$con = connect();
	if(!$con)
	{
		return false;
	}
	$q = "SELECT warn FROM user WHERE id='" . mysqli_real_escape_string($con, $userid) . "'";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		die(err_db());
	}
	$row = mysqli_fetch_assoc($res);
	if($row['warn'] != 0)
	{
		return true;
	}
	return false;	
}

function db_getfriend_status($b)
{
	$con = connect();
	if (!$con)
	{
		return false;
	}
	$res = mysqli_query($con, "SELECT get_friendship_status('" . mysqli_real_escape_string($con, $_SESSION['user']) . "', '" . mysqli_real_escape_string($con, db_getuser($b)) . "') AS p_response");
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	$row = mysqli_fetch_assoc($res);
	return $row['p_response'];
}

function db_baratLista($x)
{
	$con = connect();
	if(!$con)
	{
		return false;
	}
	if($x == 1){
		$q = "SELECT f.id1 azon, u.user nev, u.points points, u.lastvisit lastvisit, u.level rang FROM user u JOIN friend f ON f.id1 = u.id JOIN user u2 ON f.id2 = u2.id WHERE u2.user = '" . mysqli_real_escape_string($con, $_SESSION["user"]) . "' AND f.status = 1 AND u.deleteduser = 0 UNION (SELECT f.id2 azon, u2.user nev, u2.points points, u2.lastvisit lastvisit, u2.level rang FROM user u JOIN friend f ON f.id1 = u.id JOIN user u2 ON f.id2 = u2.id WHERE u.user = '" . mysqli_real_escape_string($con, $_SESSION["user"]) . "' AND f.status = 1 AND u2.deleteduser = 0)";
	}
	elseif($x == 0)
	{
		$q = "SELECT f.id1 azon, u.user nev, u.points points, u.lastvisit lastvisit, u.level rang FROM user u JOIN friend f ON f.id1 = u.id JOIN user u2 ON f.id2 = u2.id WHERE u2.user = '" . mysqli_real_escape_string($con, $_SESSION["user"]) . "' AND f.status = 0 AND u.deleteduser = 0";
	}
	else{
		$q = "SELECT f.id2 azon, u2.user nev, u2.points points, u2.lastvisit lastvisit, u2.level rang FROM user u JOIN friend f ON f.id1 = u.id JOIN user u2 ON f.id2 = u2.id WHERE u.user = '" . mysqli_real_escape_string($con, $_SESSION["user"]) . "' AND f.status = -1 AND u2.deleteduser = 0";
	}
	
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

function db_getacceptingmsg()
{
	$con = connect();
	if (!$con)
	{
		return false;
	}
	$res = mysqli_query($con, "SELECT accept_privmessage FROM user WHERE user = '" . mysqli_real_escape_string($con, $_SESSION['user']) . "'");
	mysqli_close($con);
	if(!$res || mysqli_num_rows($res)!=1)
	{
		die(err_db());
	}
	$row = mysqli_fetch_assoc($res);
	return $row['accept_privmessage'];
}

/*ajax/buyhelp.php */
function db_get_num_of_helps()
{
	$con = connect();
	if(!$con)
	{
		return false;
	}
	$res = mysqli_query($con, "SELECT help, points FROM user WHERE user = '" . mysqli_real_escape_string($con, $_SESSION['user']) . "'");
	if(!$res)
	{
		return false;
	}
	mysqli_close($con);
	return $res;
}

/*ajax/buypremium.php */
function db_get_premiumexpiredate()
{
	$con = connect();
	if(!$con)
	{
		return false;
	}
	$res = mysqli_query($con, "SELECT premium_expire, points FROM user WHERE user = '" . mysqli_real_escape_string($con, $_SESSION['user']) . "'");
	if(!$res)
	{
		return false;
	}
	mysqli_close($con);
	return $res;
}

/* ajax/load_questions_towatch.php */
function db_getquestions_quiz($quizid)
{
	$con = connect();
	if (!$con)
	{
		return false;
	}
	$res = mysqli_query($con, "SELECT q.question, q.ans1, q.is_verified FROM quiz_question q JOIN thema t ON (q.quiz_id = t.id_number) WHERE q.quiz_id = '" . mysqli_real_escape_string($con, $quizid) . "' AND t.is_request = 0 AND t.requested_by = '" . mysqli_real_escape_string($con, $_SESSION['user']) . "' ORDER BY question");
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

/*ajax/update_acceptmessages.php */
function db_update_acceptingmsg($newvalue)
{
	$con = connect();
	if (!$con)
	{
		return false;
	}
	$q = "UPDATE user SET accept_privmessage = '" . mysqli_real_escape_string($con, $newvalue) . "' WHERE user = '" . mysqli_real_escape_string($con, $_SESSION['user']) . "'";
	$res = mysqli_query($con, $q);
	if(mysqli_affected_rows($con)==1)
	{
		mysqli_close($con);
		return true;
	}
	mysqli_close($con);
	return false;
}

?>