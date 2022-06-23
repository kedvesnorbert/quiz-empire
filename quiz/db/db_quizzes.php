<?php
if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {
	require_once("../error.php");
	die(); /*Direct Access Not Allowed */
	exit();
};

function db_quiz_list($pgeQz, $mitkeres, $holkeres, $kviznyelve, $quizlimit)
{
	$azonosito = $_SESSION['user_id'];
	$admine = $_SESSION['admin_user'];
	$mitkeres1 = $mitkeres;
	$mitkeres = '%' . $mitkeres . '%';
	if(!preg_match("/^[0-9]+$/", $pgeQz) || !preg_match("/^[0-9]+$/", $quizlimit) || $quizlimit < 1)
	{
		return false;
	}
	$con = connect();
	if (!$con)
	{
		return false;
	}
	$q = "SELECT t.*, (SELECT COUNT(f.quiz_id) AS van FROM favorite_quiz f JOIN user u ON (f.user_id = u.id) WHERE u.user = '" . mysqli_real_escape_string($con, $_SESSION['user']) . "' AND f.quiz_id = t.id_number) kedvenc, (SELECT COUNT(*) FROM quiz_played WHERE quiz_id = t.id_number) osszesalkalom, (SELECT COUNT(q.user_id) FROM quiz_played q JOIN user u ON (q.user_id = u.id) WHERE u.user = '" . mysqli_real_escape_string($con, $_SESSION['user']) . "' AND q.quiz_id = t.id_number) osszessajatalkalom FROM thema t WHERE t.id_number NOT IN (SELECT DISTINCT quiz_id FROM competition WHERE activity = 1) AND is_deleted = 0 AND phase = 3 AND quiz_name LIKE '" . mysqli_real_escape_string($con, $mitkeres) . "' ";
	if($kviznyelve == 1 || $kviznyelve == 2)
	{
		$q .= "AND t.language = '" . mysqli_real_escape_string($con, $kviznyelve) . "' ";
	}
	
	if($holkeres == 2)
	{
		$q .= "AND t.accomplished_by = '" . mysqli_real_escape_string($con, $_SESSION['user']) . "' ";
	}
	elseif($holkeres == 3)
	{
		$q .= "AND (t.start_date IS NULL OR t.start_date <= NOW()) AND (t.end_date IS NULL OR t.end_date >= NOW()) AND 
		(t.access = 4 OR t.access = 3 OR (t.access = 1 AND ( '" . mysqli_real_escape_string($con, $admine) . "' = 1 OR t.requested_by = '" . mysqli_real_escape_string($con, $_SESSION['user']) . "') ) OR
		(t.access = 2 AND ('" . mysqli_real_escape_string($con, $admine) . "' = 1 OR t.requested_by = '" . mysqli_real_escape_string($con, $_SESSION['user']) . "' OR  t.id_number IN 
			(SELECT DISTINCT quizid FROM permission_play_quiz WHERE userid = '" . mysqli_real_escape_string($con, $azonosito) . "') ) ) OR 
		(t.access = 5 AND ('" . mysqli_real_escape_string($con, $admine) . "' = 1 OR t.requested_by = '" . mysqli_real_escape_string($con, $_SESSION['user']) . "' OR '" . mysqli_real_escape_string($con, $azonosito) . "' IN 
			( SELECT f.id1 FROM user u JOIN friend f ON f.id1 = u.id JOIN user u2 ON f.id2 = u2.id WHERE u2.user = t.requested_by AND f.status = 1 UNION SELECT f.id2 FROM user u JOIN friend f ON f.id1 = u.id JOIN user u2 ON f.id2 = u2.id WHERE u.user = t.requested_by AND f.status = 1) ) )
		) ";
	}
	elseif($holkeres == 4)
	{
		$q .= "AND t.id_number IN (SELECT DISTINCT quiz_id FROM favorite_quiz WHERE user_id = '" . mysqli_real_escape_string($con, $azonosito) . "') ";
	}
	
	$q .= "ORDER BY t.accomplish_date DESC LIMIT $pgeQz, $quizlimit";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

function db_numrowsQuiz($mitkeres, $holkeres, $kviznyelve)
{
	$azonosito = $_SESSION['user_id'];
	$admine = $_SESSION['admin_user'];
	$mitkeres1 = $mitkeres;
	$mitkeres = $mitkeres . '%';
	
	$con = connect();
	if (!$con)
	{
		return false;
	}
	$q = "SELECT id_number FROM thema t WHERE t.id_number NOT IN (SELECT DISTINCT quiz_id FROM competition WHERE activity = 1) AND is_deleted = 0 AND phase = 3 AND quiz_name LIKE '" . mysqli_real_escape_string($con, $mitkeres) . "' ";
	if($kviznyelve == 1 || $kviznyelve == 2)
	{
		$q .= "AND t.language = '" . mysqli_real_escape_string($con, $kviznyelve) . "' ";
	}
	
	if($holkeres == 2)
	{
		$q .= "AND t.accomplished_by = '" . mysqli_real_escape_string($con, $_SESSION['user']) . "' ";
	}
	elseif($holkeres == 3)
	{
		$q .= "AND (t.start_date IS NULL OR t.start_date <= NOW()) AND (t.end_date IS NULL OR t.end_date >= NOW()) AND 
		(t.access = 4 OR t.access = 3 OR (t.access = 1 AND ( '" . mysqli_real_escape_string($con, $admine) . "' = 1 OR t.requested_by = '" . mysqli_real_escape_string($con, $_SESSION['user']) . "') ) OR
		(t.access = 2 AND ('" . mysqli_real_escape_string($con, $admine) . "' = 1 OR t.requested_by = '" . mysqli_real_escape_string($con, $_SESSION['user']) . "' OR  t.id_number IN 
			(SELECT DISTINCT quizid FROM permission_play_quiz WHERE userid = '" . mysqli_real_escape_string($con, $azonosito) . "') ) ) OR 
		(t.access = 5 AND ('" . mysqli_real_escape_string($con, $admine) . "' = 1 OR t.requested_by = '" . mysqli_real_escape_string($con, $_SESSION['user']) . "' OR '" . mysqli_real_escape_string($con, $azonosito) . "' IN 
			( SELECT f.id1 FROM user u JOIN friend f ON f.id1 = u.id JOIN user u2 ON f.id2 = u2.id WHERE u2.user = t.requested_by AND f.status = 1 UNION SELECT f.id2 FROM user u JOIN friend f ON f.id1 = u.id JOIN user u2 ON f.id2 = u2.id WHERE u.user = t.requested_by AND f.status = 1) ) )
		) ";
	}
	elseif($holkeres == 4)
	{
		$q .= "AND t.id_number IN (SELECT DISTINCT quiz_id FROM favorite_quiz WHERE user_id = '" . mysqli_real_escape_string($con, $azonosito) . "') ";
	}
	if ($res=mysqli_query($con, $q))
	{
		$rowcount=mysqli_num_rows($res);
		mysqli_free_result($res);
		mysqli_close($con);
		return $rowcount;
	}
	else
	{
		return false;
	}
}

?>