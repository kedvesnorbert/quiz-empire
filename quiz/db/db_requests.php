<?php
if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {
	require_once("../error.php");
	die(); /*Direct Access Not Allowed */
	exit();
};

function db_getRang()
{
	$con = connect();
	if(!$con)
	{
		return false;
	}
	$res = mysqli_query($con, "SELECT level FROM user WHERE id='" . mysqli_real_escape_string($con, $_SESSION["user_id"]) . "'");
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

function db_request_list($pgeR, $mitkeres, $holkeres, $request_limit)
{
	$con = connect();
	if (!$con)
	{
		return false;
	}
	if(!preg_match("/^[0-9]+$/", $pgeR) || !preg_match("/^[0-9]+$/", $request_limit) || $request_limit < 1)
	{
		return false;
	}
	$azonosito = $_SESSION["user_id"];
	$mitkeres1 = $mitkeres;
	$mitkeres = '%' . $mitkeres . '%';
	$q = "SELECT *, (SELECT COUNT(DISTINCT user_id) FROM request_vote WHERE quiz_id = id_number) szavaz, (SELECT SUM(offered_points) FROM request_vote WHERE quiz_id = id_number) felajanlottpontok, (SELECT COUNT(*) FROM quiz_question WHERE quiz_id = id_number AND username = '" . mysqli_real_escape_string($con, $_SESSION['user']) . "') osszesk, (SELECT COUNT(*) FROM quiz_question WHERE quiz_id = id_number AND username = '" . mysqli_real_escape_string($con, $_SESSION['user']) . "' AND is_verified IS NOT NULL) ellenorzottk, (SELECT COUNT(*) FROM quiz_question WHERE quiz_id = id_number AND username = '" . mysqli_real_escape_string($con, $_SESSION['user']) . "' AND is_active = 1) elfogadottk FROM thema WHERE is_deleted = 0 AND is_request = 1 AND phase = 2 AND quiz_name LIKE '" . mysqli_real_escape_string($con, $mitkeres) . "' ";
	if($holkeres == 2)
	{
		$q .= "AND requested_by = '" . mysqli_real_escape_string($con, $_SESSION['user']) . "' ";
	}
	elseif($holkeres == 3)
	{
		$q .= "AND id_number IN ( SELECT DISTINCT quiz_id FROM request_vote WHERE user_id = '" . mysqli_real_escape_string($con, $azonosito) . "') ";
	}
	elseif($holkeres == 4)
	{
		$q .= "AND is_undertaken = 1 AND undertaken_by = '" . mysqli_real_escape_string($con, $_SESSION['user']) . "' ";
	}
	$q .= "ORDER BY request_date DESC LIMIT $pgeR, $request_limit";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

function db_numrowsReq($mitkeres, $holkeres)
{
	$con = connect();
	if (!$con)
	{
		return false;
	}
	$azonosito = $_SESSION['user_id'];
	$mitkeres1 = $mitkeres;
	$mitkeres = '%' . $mitkeres . '%';
	$q = "SELECT id_number FROM thema WHERE is_deleted = 0 AND is_request = 1 AND phase = 2 AND quiz_name LIKE '" . mysqli_real_escape_string($con, $mitkeres) . "' ";
	if($holkeres == 2)
	{
		$q .= "AND requested_by = '" . mysqli_real_escape_string($con, $_SESSION['user']) . "' ";
	}
	elseif($holkeres == 3)
	{
		$q .= "AND id_number IN ( SELECT DISTINCT quiz_id FROM request_vote WHERE user_id = '" . mysqli_real_escape_string($con, $azonosito) . "') ";
	}
	elseif($holkeres == 4)
	{
		$q .= "AND is_undertaken = 1 AND undertaken_by = '" . mysqli_real_escape_string($con, $_SESSION['user']) . "' ";
	}
	
	if ($res=mysqli_query($con, $q))
	{
		$rowcount=mysqli_num_rows($res);
		mysqli_free_result($res);
		mysqli_close($con);
		return $rowcount;
	}
	return false;
}

/*ajax/load_reqquestions_towatch.php */
function db_getquestions_quiz($quizid)
{
	$con = connect();
	if (!$con)
	{
		return false;
	}
	$res = mysqli_query($con, "SELECT q.question, q.ans1, q.is_verified FROM quiz_question q JOIN thema t ON (q.quiz_id = t.id_number) WHERE q.quiz_id = '" . mysqli_real_escape_string($con, $quizid) . "' AND t.is_request = 1 AND q.username = '" . mysqli_real_escape_string($con, $_SESSION['user']) . "' ORDER BY question");
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

?>