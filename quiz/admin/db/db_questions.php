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

function db_quizlist_forupdate()
{
    $con = connect();
	if (!$con)
	{
		return false;
	}
    $q = "SELECT id_number, quiz_name FROM thema WHERE phase > 1 ORDER BY quiz_name";
    $res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

function db_questiondata($id)
{
    $con = connect();
	if (!$con)
	{
		return false;
	}
    $q = "SELECT * FROM quiz_question WHERE id = '" . mysqli_real_escape_string($con, $id) . "'";
    $res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

function db_questionlist($pgeQ, $quizcategory, $questiontext, $where_searchresult, $search_in, $q_diff, $q_activity, $result_order, $result_dir, $limit)
{
	if(!preg_match("/^[0-9]+$/", $pgeQ) || !preg_match("/^[0-9]+$/", $limit))
    {
        return false;
    }
	$con = connect();
	if(!$con)
	{
		return false;
	}

	if(strlen($questiontext) < 1 || strlen($questiontext)>30)
    {
        $questiontext = "";
    }

	if($quizcategory == 0)
    {
        $qq = " q.quiz_id > 0 ";
    }
    else
    {
        $qq = " q.quiz_id = '" . mysqli_real_escape_string($con, $quizcategory) . "' ";
    }

	if($where_searchresult == 0)
	{
		$qw = " AND (q.is_verified = 0 OR q.is_verified IS NULL) ";
	}
	elseif($where_searchresult == 1)
	{
		$qw = " AND q.is_verified = 1 ";
	}
	elseif($where_searchresult == 2)
	{
		$qw = " AND q.is_verified = 2 ";
	}
	elseif($where_searchresult == 3)
	{
		$qw = " AND q.is_verified = 3 ";
	}
	else
	{
		$qw = " AND (q.is_verified > -1 OR q.is_verified IS NULL) ";
	}

	if($search_in == 1)
	{
		$questiontext = "%" . $questiontext . "%";
		$qsi = " AND q.question LIKE '" . mysqli_real_escape_string($con, $questiontext) . "' ";
	}
	elseif($search_in == 2)
	{
		$questiontext = "%" . $questiontext . "%";
		$qsi = " AND (q.ans1 LIKE '" . mysqli_real_escape_string($con, $questiontext) . "' OR q.ans2 LIKE '" . mysqli_real_escape_string($con, $questiontext) . "' OR q.ans3 LIKE '" . mysqli_real_escape_string($con, $questiontext) . "' OR q.ans4 LIKE '" . mysqli_real_escape_string($con, $questiontext) . "') ";
	}
	elseif($search_in == 3)
	{
		$questiontext = "%" . $questiontext . "%";
		$qsi = " AND (q.question LIKE '" . mysqli_real_escape_string($con, $questiontext) . "' OR q.ans1 LIKE '" . mysqli_real_escape_string($con, $questiontext) . "' OR q.ans2 LIKE '" . mysqli_real_escape_string($con, $questiontext) . "' OR q.ans3 LIKE '" . mysqli_real_escape_string($con, $questiontext) . "' OR q.ans4 LIKE '" . mysqli_real_escape_string($con, $questiontext) . "') ";
	}
	elseif($search_in == 4)
	{
		$qsi = " AND q.username = '" . mysqli_real_escape_string($con, $questiontext) . "' ";
	}
	else
	{
		$qsi = " AND q.ID = '" . mysqli_real_escape_string($con, $questiontext) . "' ";
	}
	
	if($q_diff == 3)
	{
		$qd = " AND q.difficulty > -1 ";
	}
	else
	{
		$qd = " AND q.difficulty = '" . mysqli_real_escape_string($con, $q_diff) . "' ";
	}

	if($q_activity == 3)
	{
		$qa = " AND q.is_active > -1 ";
	}
	elseif($q_activity == 2)
	{
		$qa = " AND q.is_active = 0 ";
	}
	else
	{
		$qa = " AND q.is_active = 1 ";
	}

	$q = "SELECT t.id_number, t.quiz_name, t.description, t.language, q.*, (SELECT COUNT(*) FROM question_comment WHERE question_id = q.id) c_comments, (SELECT user FROM user WHERE id = q.verified_by) adminname, (SELECT COUNT(*) FROM played_quiz_question WHERE question_id = q.id) popularity FROM quiz_question q JOIN thema t ON q.quiz_id = t.id_number WHERE " . $qq . $qw .$qsi . $qd . $qa;
	
	if($result_order == 1)
	{
		$q .= " ORDER BY q.question ";
	}
	elseif($result_order == 2)
	{
		$q .= " ORDER BY q.sending_time ";
	}
	elseif($result_order == 3)
	{
		$q .= " ORDER BY t.quiz_name ";
	}
	elseif($result_order == 4)
	{
		$q .= " ORDER BY q.username ";
	}
	else
	{
		$q .= " ORDER BY (SELECT COUNT(*) FROM played_quiz_question WHERE question_id = q.id) ";
	}
	
	if($result_dir == 2)
	{
		$q .= " DESC ";
	}
	else
	{
		$q .= " ASC ";
	}
	$q .= " LIMIT $pgeQ, $limit";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

function db_questionlist_numrows($quizcategory, $questiontext, $where_searchresult, $search_in, $q_diff, $q_activity)
{
	$con = connect();
	if(!$con)
	{
		return false;
	}

	if(strlen($questiontext) < 1 || strlen($questiontext)>30)
    {
        $questiontext = "";
    }

	if($quizcategory == 0)
    {
        $qq = " q.quiz_id > 0 ";
    }
    else
    {
        $qq = " q.quiz_id = '" . mysqli_real_escape_string($con, $quizcategory) . "' ";
    }

	if($where_searchresult == 0)
	{
		$qw = " AND (q.is_verified = 0 OR q.is_verified IS NULL) ";
	}
	elseif($where_searchresult == 1)
	{
		$qw = " AND q.is_verified = 1 ";
	}
	elseif($where_searchresult == 2)
	{
		$qw = " AND q.is_verified = 2 ";
	}
	elseif($where_searchresult == 3)
	{
		$qw = " AND q.is_verified = 3 ";
	}
	else
	{
		$qw = " AND (q.is_verified > -1 OR q.is_verified IS NULL) ";
	}

	if($search_in == 1)
	{
		$questiontext = "%" . $questiontext . "%";
		$qsi = " AND q.question LIKE '" . mysqli_real_escape_string($con, $questiontext) . "' ";
	}
	elseif($search_in == 2)
	{
		$questiontext = "%" . $questiontext . "%";
		$qsi = " AND (q.ans1 LIKE '" . mysqli_real_escape_string($con, $questiontext) . "' OR q.ans2 LIKE '" . mysqli_real_escape_string($con, $questiontext) . "' OR q.ans3 LIKE '" . mysqli_real_escape_string($con, $questiontext) . "' OR q.ans4 LIKE '" . mysqli_real_escape_string($con, $questiontext) . "') ";
	}
	elseif($search_in == 3)
	{
		$questiontext = "%" . $questiontext . "%";
		$qsi = " AND (q.question LIKE '" . mysqli_real_escape_string($con, $questiontext) . "' OR q.ans1 LIKE '" . mysqli_real_escape_string($con, $questiontext) . "' OR q.ans2 LIKE '" . mysqli_real_escape_string($con, $questiontext) . "' OR q.ans3 LIKE '" . mysqli_real_escape_string($con, $questiontext) . "' OR q.ans4 LIKE '" . mysqli_real_escape_string($con, $questiontext) . "') ";
	}
	elseif($search_in == 4)
	{
		$qsi = " AND q.username = '" . mysqli_real_escape_string($con, $questiontext) . "' ";
	}
	else
	{
		$qsi = " AND q.ID = '" . mysqli_real_escape_string($con, $questiontext) . "' ";
	}
	
	if($q_diff == 3)
	{
		$qd = " AND q.difficulty > -1 ";
	}
	else
	{
		$qd = " AND q.difficulty = '" . mysqli_real_escape_string($con, $q_diff) . "' ";
	}

	if($q_activity == 3)
	{
		$qa = " AND q.is_active > -1 ";
	}
	elseif($q_activity == 2)
	{
		$qa = " AND q.is_active = 0 ";
	}
	else
	{
		$qa = " AND q.is_active = 1 ";
	}

	$q = "SELECT q.id FROM quiz_question q JOIN thema t ON q.quiz_id = t.id_number WHERE " . $qq . $qw .$qsi . $qd . $qa;
	$res=mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return mysqli_num_rows($res);
}

/*ajax/load_question_comments.php */
function db_question_comments($id)
{
	$con = connect();
	if (!$con)
	{
		return false;
	}
	$q = "SELECT id, question_id, comment_text, comment_time, posted_by FROM question_comment WHERE question_id = '" . mysqli_real_escape_string($con, $id) . "' ORDER BY comment_time DESC";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

/*ajax/load_similar_questions.php */
function db_similar_questions($array, $id)
{
	if(!is_array($array) || count($array)< 1)
	{
		return false;
	}

	$con = connect();
	if (!$con)
	{
		return false;
	}

	$qa = "";
	if(count($array)==1)
	{
		$array[0] = '%' . $array[0] . '%';
		$qa .= " REGEXP_REPLACE(q.question, '[\'\"\/\\#+()$~%\:?\<>{}_|]', '') LIKE '" . mysqli_real_escape_string($con, $array[0]) . "' ";
	}
	else
	{
		for($i=0; $i<count($array)-1; ++$i)
		{
			$array[$i] = '%' . $array[$i] . '%';
			$qa .= " REGEXP_REPLACE(q.question, '[\'\"\/\\#+()$~%\:?\<>{}_|]', '') LIKE '" . mysqli_real_escape_string($con, $array[$i]) . "' AND ";
		}
		$array[$i] = '%' . $array[$i] . '%';
		$qa .= " REGEXP_REPLACE(q.question, '[\'\"\/\\#+()$~%\:?\<>{}_|]', '') LIKE '" . mysqli_real_escape_string($con, $array[$i]) . "' ";
	}
	
	
	$q = "SELECT t.quiz_name, q.question, q.ans1 FROM quiz_question q JOIN thema t ON (q.quiz_id = t.id_number) WHERE " . $qa . " AND q.id != '" . mysqli_real_escape_string($con, $id) . "' AND q.is_verified != 3 ORDER BY q.question LIMIT 50";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

?>