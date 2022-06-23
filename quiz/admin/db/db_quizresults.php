<?php
if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {
	require_once("../../error.php");
	die(); /*Direct Access Not Allowed */
	exit();
};

function db_quizlist()
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

function db_getquizresults($pageresult, $quizcategory, $username_to_search, $scorecondition, $where_searchresult, $result_order, $result_dir, $limit)
{
	if(!preg_match("/^[0-9]+$/", $pageresult) || !preg_match("/^[0-9]+$/", $limit))
    {
        return false;
    }
	$con = connect();
	if (!$con)
	{
		return false;
	}

    if($quizcategory == 0)
    {
        $qq = "AND t.id_number > 0 ";
    }
    else
    {
        $qq = "AND t.id_number = '" . mysqli_real_escape_string($con, $quizcategory) . "' ";
    }

    if(strlen($username_to_search) < 1)
    {
        $qu = "AND u.user LIKE '%' ";
    }
    else
    {
        $qu = "AND u.user = '" . mysqli_real_escape_string($con, $username_to_search) . "' ";
    }

	if($where_searchresult == 4)
	{
		$q = "SELECT u.user user, q.totalcorrect totalcorrect, t.num_of_question num_of_question, q.finishing_date idopont, t.quiz_name temakor, q.test_id test_id, q.score score, q.is_verified, t.pass_degree sikeresseg, t.accomplished_by accomplished_by FROM user u JOIN quiz_played q ON (u.id = q.user_id) JOIN thema t ON (q.quiz_id = t.id_number) WHERE q.score >= '" . mysqli_real_escape_string($con, $scorecondition) . "' AND YEAR(q.finishing_date) = YEAR(NOW()) " . $qq . $qu;
	}
	elseif($where_searchresult == 3)
	{
		$q = "SELECT DISTINCT(u.user) user, q.totalcorrect totalcorrect, t.num_of_question num_of_question, t.quiz_name temakor, q.test_id test_id, q.score score, q.is_verified, t.pass_degree sikeresseg, t.accomplished_by accomplished_by, MIN(q.finishing_date) idopont FROM user u JOIN quiz_played q ON (u.id = q.user_id) JOIN thema t ON (q.quiz_id = t.id_number) WHERE q.score >= '" . mysqli_real_escape_string($con, $scorecondition) . "' " . $qq . $qu . " GROUP BY t.id_number, u.user ";
	}
	elseif($where_searchresult == 2)
	{
		$q = "SELECT u.user user, q.totalcorrect totalcorrect, t.num_of_question num_of_question, q.finishing_date idopont, t.quiz_name temakor, q.test_id test_id, q.score score, q.is_verified, t.pass_degree sikeresseg, t.accomplished_by accomplished_by FROM user u JOIN quiz_played q ON (u.id = q.user_id) JOIN thema t ON (q.quiz_id = t.id_number) WHERE q.score >= '" . mysqli_real_escape_string($con, $scorecondition) . "' AND DATE(q.finishing_date) = DATE(NOW()) " . $qq . $qu;
	}
	else
	{
		$q = "SELECT u.user user, q.totalcorrect totalcorrect, t.num_of_question num_of_question, q.finishing_date idopont, t.quiz_name temakor, q.test_id test_id, q.score score, q.is_verified, t.pass_degree sikeresseg, t.accomplished_by accomplished_by FROM user u JOIN quiz_played q ON (u.id = q.user_id) JOIN thema t ON (q.quiz_id = t.id_number) WHERE q.score >= '" . mysqli_real_escape_string($con, $scorecondition) . "' " . $qq . $qu;
	}
	
	if($result_order == 2)
	{
		$q .= "ORDER BY q.finishing_date ";
	}
    elseif($result_order == 3)
	{
		$q .= "ORDER BY t.quiz_name ";
	}
    elseif($result_order == 4)
	{
		$q .= "ORDER BY u.user ";
	}
    else
	{
		$q .= "ORDER BY q.score ";
	}
	
	if($result_dir == 1)
	{
		$q .= "ASC ";
	}
	else
	{
		$q .= "DESC ";
	}
	
	$q .= "LIMIT $pageresult, $limit";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

function db_numrows_quizresultlist($quizcategory, $username_to_search, $scorecondition, $where_searchresult)
{
    $con = connect();
	if (!$con)
	{
		return false;
	}

    if($quizcategory == 0)
    {
        $qq = "AND t.id_number > 0 ";
    }
    else
    {
        $qq = "AND t.id_number = '" . mysqli_real_escape_string($con, $quizcategory) . "' ";
    }

    if(strlen($username_to_search) < 1)
    {
        $qu = "AND u.user LIKE '%' ";
    }
    else
    {
        $qu = "AND u.user = '" . mysqli_real_escape_string($con, $username_to_search) . "' ";
    }

	if($where_searchresult == 4)
	{
		$q = "SELECT q.test_id FROM user u JOIN quiz_played q ON (u.id = q.user_id) JOIN thema t ON (q.quiz_id = t.id_number) WHERE q.score >= '" . mysqli_real_escape_string($con, $scorecondition) . "' AND YEAR(q.finishing_date) = YEAR(NOW()) " . $qq . $qu;
	}
	elseif($where_searchresult == 3)
	{
		$q = "SELECT q.test_id FROM user u JOIN quiz_played q ON (u.id = q.user_id) JOIN thema t ON (q.quiz_id = t.id_number) WHERE q.score >= '" . mysqli_real_escape_string($con, $scorecondition) . "' " . $qq . $qu . " GROUP BY t.id_number, u.user ";
	}
	elseif($where_searchresult == 2)
	{
		$q = "SELECT q.test_id FROM user u JOIN quiz_played q ON (u.id = q.user_id) JOIN thema t ON (q.quiz_id = t.id_number) WHERE q.score >= '" . mysqli_real_escape_string($con, $scorecondition) . "' AND DATE(q.finishing_date) = DATE(NOW()) " . $qq . $qu;
	}
	else
	{
		$q = "SELECT q.test_id FROM user u JOIN quiz_played q ON (u.id = q.user_id) JOIN thema t ON (q.quiz_id = t.id_number) WHERE q.score >= '" . mysqli_real_escape_string($con, $scorecondition) . "' " . $qq . $qu;
	}
	
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return mysqli_num_rows($res);
}

?>