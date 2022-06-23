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

function db_getcommentresults($pageresult, $quizcategory, $username_to_search, $commenttext, $where_searchresult, $is_deletedcomment, $result_order, $result_dir, $limit)
{
	if(!preg_match("/^[0-9]+$/", $pageresult) || !preg_match("/^[0-9]+$/", $limit))
    {
        return false;
    }
	$con = connect1();
	if (!$con)
	{
		return false;
	}

    if($quizcategory == 0)
    {
        $qq = " t.id_number > 0 ";
    }
    else
    {
        $qq = " t.id_number = '" . mysqli_real_escape_string($con, $quizcategory) . "' ";
    }

    if(strlen($username_to_search) < 1)
    {
        $qu = " AND u.user LIKE '%' ";
    }
    else
    {
        $qu = " AND u.user = '" . mysqli_real_escape_string($con, $username_to_search) . "' ";
    }

	if(strlen($commenttext) < 1 || strlen($commenttext)>30)
    {
        $qc = " AND qc.comment_text LIKE '%' ";
    }
    else
    {
        $commenttext = "%" . $commenttext . "%";
		$qc = " AND qc.comment_text LIKE '" . mysqli_real_escape_string($con, $commenttext) . "' ";
    }

	if($where_searchresult == 3)
	{
		$qe = " AND qc.is_verified >= 0 ";
	}
	else
	{
		$qe = " AND qc.is_verified = '" . mysqli_real_escape_string($con, $where_searchresult) . "' ";
	}

	if($is_deletedcomment == 2)
	{
		$qd = " AND qc.is_deleted >= 0 ";
	}
	elseif($is_deletedcomment == 1)
	{
		$qd = " AND qc.is_deleted = 1 ";
	}
	else
	{
		$qd = " AND qc.is_deleted = 0 ";
	}

	$q = "SELECT u.user, u.id, qc.*, t.id_number, t.quiz_name FROM thema t JOIN quiz_comment qc ON (t.id_number = qc.quiz_id) JOIN user u ON (qc.user_id = u.id) WHERE " . $qq . $qu . $qc . $qe . $qd;
	
	if($result_order == 3)
	{
		$q .= "ORDER BY u.user ";
	}
    elseif($result_order == 2)
	{
		$q .= "ORDER BY t.quiz_name ";
	}
    else
	{
		$q .= "ORDER BY qc.comment_date ";
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

function db_numrows_quizresultlist($quizcategory, $username_to_search, $commenttext, $where_searchresult, $is_deletedcomment)
{
    $con = connect();
	if (!$con)
	{
		return false;
	}

    if($quizcategory == 0)
    {
        $qq = " t.id_number > 0 ";
    }
    else
    {
        $qq = " t.id_number = '" . mysqli_real_escape_string($con, $quizcategory) . "' ";
    }

    if(strlen($username_to_search) < 1)
    {
        $qu = " AND u.user LIKE '%' ";
    }
    else
    {
        $qu = " AND u.user = '" . mysqli_real_escape_string($con, $username_to_search) . "' ";
    }

	if(strlen($commenttext) < 1 || strlen($commenttext)>30)
    {
        $qc = " AND qc.comment_text LIKE '%' ";
    }
    else
    {
        $commenttext = "%" . $commenttext . "%";
		$qc = " AND qc.comment_text LIKE '" . mysqli_real_escape_string($con, $commenttext) . "' ";
    }

	if($where_searchresult == 3)
	{
		$qe = " AND qc.is_verified >= 0 ";
	}
	else
	{
		$qe = " AND qc.is_verified = '" . mysqli_real_escape_string($con, $where_searchresult) . "' ";
	}

	if($is_deletedcomment == 2)
	{
		$qd = " AND qc.is_deleted >= 0 ";
	}
	elseif($is_deletedcomment == 1)
	{
		$qd = " AND qc.is_deleted = 1 ";
	}
	else
	{
		$qd = " AND qc.is_deleted = 0 ";
	}

	$q = "SELECT u.user, qc.*, t.quiz_name FROM thema t JOIN quiz_comment qc ON (t.id_number = qc.quiz_id) JOIN user u ON (qc.user_id = u.id) WHERE " . $qq . $qu . $qc . $qe . $qd;
	
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return mysqli_num_rows($res);
}

?>