<?php
if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {
	require_once("../../error.php");
	die(); /*Direct Access Not Allowed */
	exit();
};

function db_quizlist($pge, $keresendoNev, $holKeres, $kvizFazis, $kvizTipus, $limit)
{
	if(!preg_match("/^[0-9]+$/", $pge) || !preg_match("/^[0-9]+$/", $limit))
    {
        return false;
    }
    $con = connect();
	if (!$con)
    {
        return false;
    }
	$q = "SELECT t.*, (SELECT COUNT(*) FROM quiz_question WHERE quiz_id = t.id_number AND username = t.requested_by) AS ownquiz_allquestion, (SELECT COUNT(*) FROM quiz_question WHERE quiz_id = t.id_number AND username = t.requested_by AND is_verified IS NOT NULL) AS ownquiz_verifiedquestion, (SELECT COUNT(*) FROM quiz_question WHERE quiz_id = t.id_number AND username = t.requested_by AND is_verified = 1) AS ownquiz_accepted, (SELECT COUNT(*) FROM quiz_question WHERE quiz_id = t.id_number AND username = t.undertaken_by) AS request_allquestion, (SELECT COUNT(*) FROM quiz_question WHERE quiz_id = t.id_number AND username = t.undertaken_by AND is_verified IS NOT NULL) AS request_verifiedquestion, (SELECT COUNT(*) FROM quiz_question WHERE quiz_id = t.id_number AND username = t.undertaken_by AND is_verified = 1) AS request_accepted, (SELECT COUNT(*) FROM quiz_question WHERE quiz_id = t.id_number AND username = t.undertaken_by AND is_verified IS NULL) AS request_verifiedallquestion, (SELECT COUNT(DISTINCT user_id) FROM request_vote WHERE quiz_id = t.id_number) AS request_votes, (SELECT SUM(offered_points) FROM request_vote WHERE quiz_id = t.id_number) AS request_offeredpoints, (SELECT CASE WHEN t.byuser_minreq_quest IS NULL THEN t.minimum_requested_quest ELSE GREATEST(t.minimum_requested_quest, t.byuser_minreq_quest) END) AS requested_questions FROM thema t WHERE "; 
		
	if($holKeres == 4)
    {
	    $q .= "t.accomplished_by = '" . mysqli_real_escape_string($con, $keresendoNev) . "' ";
    }
	elseif($holKeres == 3)
    {
        $q .= "t.id_number = '" . mysqli_real_escape_string($con, $keresendoNev) . "' ";
    }
	elseif($holKeres == 2)
    {
        $keresendoNev = '%' . $keresendoNev . '%';
		$q .= "t.description LIKE '" . mysqli_real_escape_string($con, $keresendoNev) . "' ";
    }
	else
    {
        $keresendoNev = $keresendoNev . '%';
		$q .= "t.quiz_name LIKE '" . mysqli_real_escape_string($con, $keresendoNev) . "' ";
    }

	if($kvizFazis == 5)
    {
        $q .= "AND t.is_deleted = 0 AND ((t.is_request = 1 AND (t.phase = 1 OR (t.phase = 2 AND t.is_undertaken = 1 AND (SELECT COUNT(*) FROM quiz_question WHERE quiz_id = t.id_number AND username = t.undertaken_by) >= (SELECT CASE WHEN t.byuser_minreq_quest IS NULL THEN t.minimum_requested_quest ELSE GREATEST(t.minimum_requested_quest, t.byuser_minreq_quest) END) AND (SELECT COUNT(*) FROM quiz_question WHERE quiz_id = t.id_number AND username = t.undertaken_by AND is_verified = 1) >= (SELECT CASE WHEN t.byuser_minreq_quest IS NULL THEN t.minimum_requested_quest ELSE GREATEST(t.minimum_requested_quest, t.byuser_minreq_quest) END) AND (SELECT COUNT(*) FROM quiz_question WHERE quiz_id = t.id_number AND username = t.undertaken_by AND is_verified IS NULL) = 0 ) OR (t.phase = 2 AND t.is_undertaken = 1 AND NOW() > t.accomplish_deadline AND (SELECT COUNT(*) FROM quiz_question WHERE quiz_id = t.id_number AND username = t.undertaken_by) < (SELECT CASE WHEN t.byuser_minreq_quest IS NULL THEN t.minimum_requested_quest ELSE GREATEST(t.minimum_requested_quest, t.byuser_minreq_quest) END)) ) ) OR (t.is_request = 0 AND (t.phase = 1 OR (t.phase = 2 AND (SELECT COUNT(*) FROM quiz_question WHERE quiz_id = t.id_number AND username = t.requested_by) >= t.minimum_requested_quest AND (SELECT COUNT(*) FROM quiz_question WHERE quiz_id = t.id_number AND username = t.requested_by AND is_verified = 1) >= t.minimum_requested_quest)) ) ) ";
    }
    elseif($kvizFazis == 4)
    {
        $q .= "AND t.is_deleted = 1 ";
    }	
	elseif($kvizFazis == 3)
    {
        $q .= "AND t.phase = 3 AND t.is_deleted = 0 ";
    }
	elseif($kvizFazis == 2)
    {
        $q .= "AND t.phase = 2 AND t.is_deleted = 0 ";
    }
	elseif($kvizFazis == 1)
    {
        $q .= "AND t.phase = 1 AND t.is_deleted = 0 ";
    }

	if($kvizTipus == 1)
    {
        $q .= "AND t.is_request = 0 ";
    }	
	elseif($kvizTipus == 2)
    {
        $q .= "AND t.is_request = 1 ";
    }
    
	$q .= "ORDER BY t.request_date ASC LIMIT $pge, $limit";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
    if(!$res)
    {
        return false;
    }
	return $res;
}

function db_numrows_quizlist($keresendoNev, $holKeres, $kvizFazis, $kvizTipus)
{
	$con = connect();
	if (!$con)
    {
        return false;
    }
	$q = "SELECT t.id_number FROM thema t WHERE "; 
		
	if($holKeres == 4)
    {
	    $q .= "t.accomplished_by = '" . mysqli_real_escape_string($con, $keresendoNev) . "' ";
    }
	elseif($holKeres == 3)
    {
        $q .= "t.id_number = '" . mysqli_real_escape_string($con, $keresendoNev) . "' ";
    }
	elseif($holKeres == 2)
    {
        $keresendoNev = '%' . $keresendoNev . '%';
		$q .= "t.description LIKE '" . mysqli_real_escape_string($con, $keresendoNev) . "' ";
    }
	else
    {
        $keresendoNev = $keresendoNev . '%';
		$q .= "t.quiz_name LIKE '" . mysqli_real_escape_string($con, $keresendoNev) . "' ";
    }

	if($kvizFazis == 5)
    {
        $q .= "AND t.is_deleted = 0 AND ((t.is_request = 1 AND (t.phase = 1 OR (t.phase = 2 AND t.is_undertaken = 1 AND (SELECT COUNT(*) FROM quiz_question WHERE quiz_id = t.id_number AND username = t.undertaken_by) >= (SELECT CASE WHEN t.byuser_minreq_quest IS NULL THEN t.minimum_requested_quest ELSE GREATEST(t.minimum_requested_quest, t.byuser_minreq_quest) END) AND (SELECT COUNT(*) FROM quiz_question WHERE quiz_id = t.id_number AND username = t.undertaken_by AND is_verified = 1) >= (SELECT CASE WHEN t.byuser_minreq_quest IS NULL THEN t.minimum_requested_quest ELSE GREATEST(t.minimum_requested_quest, t.byuser_minreq_quest) END) AND (SELECT COUNT(*) FROM quiz_question WHERE quiz_id = t.id_number AND username = t.undertaken_by AND is_verified IS NULL) = 0 ) OR (t.phase = 2 AND t.is_undertaken = 1 AND NOW() > t.accomplish_deadline AND (SELECT COUNT(*) FROM quiz_question WHERE quiz_id = t.id_number AND username = t.undertaken_by) < (SELECT CASE WHEN t.byuser_minreq_quest IS NULL THEN t.minimum_requested_quest ELSE GREATEST(t.minimum_requested_quest, t.byuser_minreq_quest) END)) ) ) OR (t.is_request = 0 AND (t.phase = 1 OR (t.phase = 2 AND (SELECT COUNT(*) FROM quiz_question WHERE quiz_id = t.id_number AND username = t.requested_by) >= t.minimum_requested_quest AND (SELECT COUNT(*) FROM quiz_question WHERE quiz_id = t.id_number AND username = t.requested_by AND is_verified = 1) >= t.minimum_requested_quest)) ) ) ";
    }
    elseif($kvizFazis == 4)
    {
        $q .= "AND t.is_deleted = 1 ";
    }	
	elseif($kvizFazis == 3)
    {
        $q .= "AND t.phase = 3 AND t.is_deleted = 0 ";
    }
	elseif($kvizFazis == 2)
    {
        $q .= "AND t.phase = 2 AND t.is_deleted = 0 ";
    }
	elseif($kvizFazis == 1)
    {
        $q .= "AND t.phase = 1 AND t.is_deleted = 0 ";
    }

	if($kvizTipus == 1)
    {
        $q .= "AND t.is_request = 0 ";
    }	
	elseif($kvizTipus == 2)
    {
        $q .= "AND t.is_request = 1 ";
    }
	$res=mysqli_query($con, $q);
	mysqli_close($con);
	if (!$res)
	{
		return false;
	}
	$rowcount=mysqli_num_rows($res);
	mysqli_free_result($res);
	return $rowcount;
}

/* ajax/load_activequestions_towatch.php */
function db_getactivequestions_quiz($quizid)
{
	$con = connect();
	if (!$con)
	{
		return false;
	}
	$res = mysqli_query($con, "SELECT q.question, q.ans1, q.ans2, q.ans3, q.ans4 FROM quiz_question q JOIN thema t ON (q.quiz_id = t.id_number) WHERE q.quiz_id = '" . mysqli_real_escape_string($con, $quizid) . "' AND q.is_verified = 1 AND q.is_active = 1 ORDER BY q.question LIMIT 100");
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}