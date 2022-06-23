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

function db_getbackgroundresults($pageresult, $quizcategory, $username_to_search, $imagenametext, $where_searchresult, $result_order, $result_dir, $limit)
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

	if(strlen($imagenametext) < 1 || strlen($imagenametext)>30)
    {
        $qb = " AND b.image_path LIKE '%' ";
    }
    else
    {
        $imagenametext = "%" . $imagenametext . "%";
		$qb = " AND b.image_path LIKE '" . mysqli_real_escape_string($con, $imagenametext) . "' ";
    }

	if($where_searchresult == 2)
	{
		$qe = " AND b.active >= 0 ";
	}
	else
	{
		$qe = " AND b.active = '" . mysqli_real_escape_string($con, $where_searchresult) . "' ";
	}

	$q = "SELECT u.user, u.id userid, b.*, t.id_number, t.quiz_name, (SELECT user FROM user WHERE id = b.adminid) adminusername FROM thema t JOIN background b ON (t.id_number = b.quiz_id) JOIN user u ON (b.posted_by = u.id) WHERE " . $qq . $qu . $qb . $qe;
	
	if($result_order == 4)
	{
		$q .= "ORDER BY b.image_size ";
	}
	elseif($result_order == 3)
	{
		$q .= "ORDER BY u.user ";
	}
    elseif($result_order == 2)
	{
		$q .= "ORDER BY t.quiz_name ";
	}
    else
	{
		$q .= "ORDER BY b.posting_time ";
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

function db_numrows_backgroundresultlist($quizcategory, $username_to_search, $imagenametext, $where_searchresult)
{
    $con = connect();
	if (!$con)
	{
		return false;
	}

    if($quizcategory == 0)
    {
        $qq = " b.quiz_id > 0 ";
    }
    else
    {
        $qq = " b.quiz_id = '" . mysqli_real_escape_string($con, $quizcategory) . "' ";
    }

    if(strlen($username_to_search) < 1)
    {
        $qu = " AND u.user LIKE '%' ";
    }
    else
    {
        $qu = " AND u.user = '" . mysqli_real_escape_string($con, $username_to_search) . "' ";
    }

	if(strlen($imagenametext) < 1 || strlen($imagenametext)>30)
    {
        $qb = " AND b.image_path LIKE '%' ";
    }
    else
    {
        $imagenametext = "%" . $imagenametext . "%";
		$qb = " AND b.image_path LIKE '" . mysqli_real_escape_string($con, $imagenametext) . "' ";
    }

	if($where_searchresult == 2)
	{
		$qe = " AND b.active >= 0 ";
	}
	else
	{
		$qe = " AND b.active = '" . mysqli_real_escape_string($con, $where_searchresult) . "' ";
	}

	$q = "SELECT u.user, u.id, b.*, t.id_number, t.quiz_name FROM thema t JOIN background b ON (t.id_number = b.quiz_id) JOIN user u ON (b.posted_by = u.id) WHERE " . $qq . $qu . $qb . $qe;
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return mysqli_num_rows($res);
}

/* ajax/delete_backgroundimg.php */
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