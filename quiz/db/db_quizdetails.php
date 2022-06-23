<?php
if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {
	require_once("../error.php");
	die(); /*Direct Access Not Allowed */
	exit();
};

function db_isownquiz($id)
{
	$con = connect();
	if(!$con)
	{
		return false;
	}
	$res = mysqli_query($con, "SELECT accomplished_by FROM thema WHERE id_number = '" . mysqli_real_escape_string($con, $id) . "'");
	mysqli_close($con);
	if(!$res || mysqli_num_rows($res) != 1)
	{
		return false;
	}
	$row = mysqli_fetch_assoc($res);
	if($row['accomplished_by'] == $_SESSION['user'])
	{
		return true;
	}
	return false;
}

function db_getquizdata($id)
{
	$con = connect();
	if(!$con)
	{
		return false;
	}
	$q = "SELECT id_number, quiz_name, description, num_of_question, accept_questions, language, show_answers, time_to_answer, num_of_playing, access, start_date, end_date, requested_by, accomplished_by, accomplish_date, anonymus_accomplish, verification, pass_degree FROM thema WHERE id_number = '" . mysqli_real_escape_string($con, $id) . "' AND is_deleted = 0 AND phase = 3";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res || mysqli_num_rows($res) != 1)
	{
		return false;
	}
	return $res;
}

function db_getquizquestions($id)
{
	$con = connect();
	if(!$con)
	{
		return false;
	}
	$q = "SELECT DISTINCT username, COUNT(id) AS kerdes_szam FROM quiz_question WHERE quiz_id = '" . mysqli_real_escape_string($con, $id) . "' AND is_verified = 1 GROUP BY username";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

function db_getuserid($name)
{
	$con = connect();
	if(!$con)
	{
		return false;
	}
	$res = mysqli_query($con, "SELECT id FROM user WHERE user = '" . mysqli_real_escape_string($con, $name) . "'");
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	$row = mysqli_fetch_assoc($res);
	return $row['id'];
}

function db_friends_access_quiz_d($quizid)
{
	$con = connect();
	if (!$con)
	{
		return false;
	}
	$res = mysqli_query($con, "SELECT u.user username FROM permission_play_quiz p JOIN user u ON (p.userid = u.id) WHERE p.quizid = '" . mysqli_real_escape_string($con, $quizid) . "'");
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
	$res = mysqli_query($con, "SELECT u.user username FROM permission_submit_question p JOIN user u ON (p.userid = u.id) WHERE p.quizid = '" . mysqli_real_escape_string($con, $quizid) . "'");
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

function db_getquizrating_data($id)
{
	$uid = $_SESSION['user_id'];
	$con = connect();
	if (!$con)
	{
		return false;
	}
	$q = "SELECT (SELECT COUNT(*) darab FROM quiz_rating WHERE user_id='" . mysqli_real_escape_string($con, $uid) . "' AND quiz_id='" . mysqli_real_escape_string($con, $id) . "') AS bool_my_rating, (SELECT rating FROM quiz_rating WHERE user_id='" . mysqli_real_escape_string($con, $uid) . "' AND quiz_id='" . mysqli_real_escape_string($con, $id) . "') AS my_rating, COUNT(user_id) AS users_rating, SUM(rating)/COUNT(quiz_id) AS atl FROM quiz_rating WHERE quiz_id='" . mysqli_real_escape_string($con, $id) . "'";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

function db_getranglists($type, $id, $sorting, $direction)
{
	$con = connect();
	if (!$con)
	{
		return false;
	}
	if($type == 2)
	{
		$q = "SELECT u.user user, q.totalcorrect totalcorrect, t.num_of_question num_of_question, q.finishing_date idopont, t.quiz_name temakor, q.test_id test_id, q.score score, t.pass_degree sikeresseg, t.accomplished_by accomplished_by FROM user u JOIN quiz_played q ON (u.id = q.user_id) JOIN thema t ON (q.quiz_id = t.id_number) WHERE q.quiz_id = '" . mysqli_real_escape_string($con, $id) . "' AND DATE(q.finishing_date) = DATE(NOW()) AND u.deleteduser = 0 ";
	}
	elseif($type == 4)
	{
		$q = "SELECT u.user user, q.totalcorrect totalcorrect, t.num_of_question num_of_question, q.finishing_date idopont, t.quiz_name temakor, q.test_id test_id, q.score score, t.pass_degree sikeresseg, t.accomplished_by accomplished_by FROM user u JOIN quiz_played q ON (u.id = q.user_id) JOIN thema t ON (q.quiz_id = t.id_number) WHERE q.quiz_id = '" . mysqli_real_escape_string($con, $id) . "' AND u.deleteduser = 0 ";
	}
	elseif($type == 3)
	{
		$q = "SELECT DISTINCT(u.user) user, q.totalcorrect totalcorrect, t.num_of_question num_of_question, t.quiz_name temakor, q.test_id test_id, q.score score, t.pass_degree sikeresseg, t.accomplished_by accomplished_by, MIN(q.finishing_date) idopont FROM user u JOIN quiz_played q ON (u.id = q.user_id) JOIN thema t ON (q.quiz_id = t.id_number) WHERE q.quiz_id = '" . mysqli_real_escape_string($con, $id) . "' AND u.deleteduser = 0 GROUP BY u.user ";
	}
	elseif($type == 5)
	{
		$q = "SELECT u.user user, q.totalcorrect totalcorrect, t.num_of_question num_of_question, q.finishing_date idopont, t.quiz_name temakor, q.test_id test_id, q.score score, t.pass_degree sikeresseg, t.accomplished_by accomplished_by FROM user u JOIN quiz_played q ON (u.id = q.user_id) JOIN thema t ON (q.quiz_id = t.id_number) WHERE q.quiz_id = '" . mysqli_real_escape_string($con, $id) . "' AND u.user = '" . mysqli_real_escape_string($con, $_SESSION['user']) . "' AND u.deleteduser = 0 ";
	}
	elseif($type == 7)
	{
		$q = "SELECT u.user user, q.totalcorrect totalcorrect, t.num_of_question num_of_question, q.finishing_date idopont, t.quiz_name temakor, q.test_id test_id, q.score score, t.pass_degree sikeresseg, t.accomplished_by accomplished_by FROM user u JOIN quiz_played q ON (u.id = q.user_id) JOIN thema t ON (q.quiz_id = t.id_number) WHERE q.quiz_id = '" . mysqli_real_escape_string($con, $id) . "' AND YEAR(q.finishing_date) = YEAR(NOW()) AND u.deleteduser = 0 ";
	}
	else
	{
		$q = "SELECT u.user user, q.totalcorrect totalcorrect, t.num_of_question num_of_question, q.finishing_date idopont, t.quiz_name temakor, q.test_id test_id, q.score score, t.pass_degree sikeresseg, t.accomplished_by accomplished_by FROM user u JOIN quiz_played q ON (u.id = q.user_id) JOIN thema t ON (q.quiz_id = t.id_number) WHERE q.quiz_id = '" . mysqli_real_escape_string($con, $id) . "' AND u.deleteduser = 0 ";
	}
	
	if($sorting == 1)
	{
		$q .= "ORDER BY u.user ";
	}
	elseif($sorting == 2)
	{
		$q .= "ORDER BY q.score ";
	}
	elseif($sorting == 3)
	{
		$q .= "ORDER BY q.finishing_date ";
	}
	else
	{
		$q .= "ORDER BY q.score ";
	}
	
	if($direction == 1)
	{
		$q .= "ASC ";
	}
	else
	{
		$q .= "DESC ";
	}
	
	$q .= "LIMIT 1000";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
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

function db_isalready_liked($id)
{
	$uid = $_SESSION['user_id'];
	$con = connect();
	if (!$con)
	{
		return false;
	}
	$q = "SELECT COUNT(*) darab FROM quiz_like WHERE user_id='" . mysqli_real_escape_string($con, $uid) . "' AND quiz_id='" . mysqli_real_escape_string($con, $id) . "'";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	$row = mysqli_fetch_assoc($res);
	if($row['darab'] != 1)
	{
		return false;
	}
	return true;
}

function db_already_played($id)
{
	$uid = $_SESSION['user_id'];
	$con = connect();
	if (!$con)
	{
		return false;
	}
	$q = "SELECT * FROM quiz_played WHERE quiz_id='" . mysqli_real_escape_string($con, $id) . "' AND user_id = '" . mysqli_real_escape_string($con, $uid) . "'";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	if(mysqli_num_rows($res) > 0)
	{
		return true;
	}
	return false;
}

function db_commentsection($id, $offset, $limit)
{
	if(!preg_match("/^[0-9]+$/", $offset) || !preg_match("/^[0-9]+$/", $limit))
	{
		return false;
	}
	$con = connect();
	if (!$con)
	{
		return false;
	}
	$q = "SELECT CASE WHEN u.deleteduser = 0 THEN u.user ELSE 'Törölt felhasználó' END user, q.quiz_id AS quizid, q.user_id AS userid, q.comment_text AS hozzaszolas, q.comment_date AS idopont, q.is_deleted AS is_deleted, q.is_verified AS is_verified, q.moderation AS moderation, q.verification_time AS verification_time FROM quiz_comment q JOIN user u ON (q.user_id = u.id) WHERE q.quiz_id='" . mysqli_real_escape_string($con, $id) . "' AND q.is_deleted = 0 ORDER BY q.comment_date DESC LIMIT $offset, $limit";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

function db_getquizdata_forupdate($id)
{
	$con = connect();
	if(!$con)
	{
		return false;
	}
	$q = "SELECT is_request, accept_questions, num_of_playing, access, start_date, end_date, password, verification FROM thema WHERE phase = 3 AND is_deleted = 0 AND accomplished_by = '" . mysqli_real_escape_string($con, $_SESSION['user']) . "' AND is_request = 0 AND id_number = '" . mysqli_real_escape_string($con, $id) . "'";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

function db_baratLista()
{
	$con = connect();
	if(!$con)
	{
		return false;
	}
	$q = "SELECT f.id1 azon, u.user nev FROM user u JOIN friend f ON f.id1 = u.id JOIN user u2 ON f.id2 = u2.id WHERE u2.user = '" . mysqli_real_escape_string($con, $_SESSION['user']) . "' AND f.status = 1 AND u.deleteduser = 0 UNION SELECT f.id2 azon, u2.user nev FROM user u JOIN friend f ON f.id1 = u.id JOIN user u2 ON f.id2 = u2.id WHERE u.user = '" . mysqli_real_escape_string($con, $_SESSION['user']) . "' AND f.status = 1 AND u2.deleteduser = 0";
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

function getRang()
{
	$con = connect();
	if (!$con)
	{
		return false;
	}
	$res = mysqli_query($con, "SELECT level FROM user WHERE id='" . mysqli_real_escape_string($con, $_SESSION['user_id']) . "'");
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	$row = mysqli_fetch_assoc($res);
	if($row['level'] > 4)
	{
		return true;
	}
	return false;
}

function db_getbackgrounds($id)
{
	$con = connect();
	if(!$con)
	{
		return false;
	}
	$q = "SELECT id, image_path, posting_time, active FROM background WHERE quiz_id = '" . mysqli_real_escape_string($con, $id) . "' ORDER BY posting_time DESC";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

/* ajax/delete_backgroundimage.php */
function db_getBgImagePath($imgid)
{
	$con = connect();
	if(!$con)
	{
		return false;
	}
	$q = "SELECT image_path FROM background WHERE id = '" . mysqli_real_escape_string($con, $imgid) . "'";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

?>