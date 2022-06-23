<?php
if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {
	require_once("../error.php");
	die(); /*Direct Access Not Allowed */
	exit();
};

function db_getUserData()
{
	$con = connect();
	if(!$con)
	{
		return false;
	}
	$q = "SELECT warn, premium, premium_expire, points, quizplayed_total, level, help, deleteduser FROM user WHERE id='" . mysqli_real_escape_string($con, $_SESSION["user_id"]) . "'";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

function db_getCompetition()
{
	$con = connect();
	if(!$con)
	{
		return false;
	}
	$q = "SELECT c.quiz_id, t.quiz_name, t.description, t.language, t.num_of_question, t.show_answers, t.time_to_answer, c.announcement_date, c.reward1, c.reward2, c.reward3, c.reward4, c.reward5, c.reward6, c.reward7, c.startdate, c.enddate, c.button_color FROM thema t JOIN competition c ON t.id_number = c.quiz_id WHERE c.activity = 1 LIMIT 1";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	if(mysqli_num_rows($res) == 0)
	{
		return false;
	}
	return $res;
}

function db_getNewsData()
{
	$con = connect();
	if(!$con)
	{
		return false;
	}
	$q = "SELECT n.id hir_id, CASE WHEN u.deleteduser = 0 THEN u.user ELSE 'Törölt felhasználó' END username, n.publisher_id userid, u.adminuser adminuser, DATEDIFF(NOW(), n.publication_date) publication_date, n.title title, n.description description, n.image_path image_path, n.file_path file_path, n.filename filename, n.file_size filesize FROM news n JOIN user u ON (n.publisher_id = u.id) WHERE n.is_deleted = 0 ORDER BY n.publication_date DESC LIMIT 5";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

function db_free_premium()
{
    $con = connect();
    if(!$con)
	{
		return false;
	}
	$q = "UPDATE user SET premium = 1, premium_expire = NOW() + INTERVAL 30 DAY, lawtousechat = 1, lawtosendquestion = 1, lawtosearchuser = 1, lawtoeditfaq = 1, lawtogetpoints = 1, lawtosendmail = 1, lawtouserequests = 1, lawtocreatequiz = 1 WHERE id='" . mysqli_real_escape_string($con, $_SESSION["user_id"]) . "'";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
    if(!$res)
	{
		return false;
	}
    return true;
}

function db_getCompetitionRanglist()
{
	$con = connect();
	if(!$con)
	{
		return false;
	}
	$q = "SELECT u.user, q.score, q.finishing_date FROM competition c JOIN quiz_played q ON (c.quiz_id = q.quiz_id) JOIN user u ON (q.user_id = u.id) WHERE c.activity = 1 AND c.startdate <= q.finishing_date AND q.finishing_date <= c.enddate ORDER BY q.score DESC, q.finishing_date ASC LIMIT 500";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

/* ajax/load_nextleveldata.php */
function db_nextleveldata()
{
	$con = connect();
	if(!$con)
	{
		return false;
	}
	$q = "SELECT points, quizplayed_total, level FROM user WHERE id = '" . mysqli_real_escape_string($con, $_SESSION["user_id"]) . "'";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

/*ajax/load_quizoptions.php */
function db_already_started_quiz()
{
    $con = connect();
    if(!$con)
    {
        return false;
    }
    $q = "SELECT * FROM live_question WHERE user='" . mysqli_real_escape_string($con, $_SESSION["user"]) . "'";
    $res = mysqli_query($con, $q);
    mysqli_close($con);
    if(!$res)
    {
        return false;
    }
    return $res;
}

/*ajax/logout.php */
function db_logout()
{
    $con = connect();
	if(!$con)
    {
		return false;
	}
	$q = "SELECT logout('" . mysqli_real_escape_string($con, $_SESSION['user']) . "', 1, 0, '" . mysqli_real_escape_string($con, $_SESSION['login_time']) . "') AS is_success";
	$res = mysqli_query($con, $q);
    mysqli_close($con);
    if(!$res)
    {
        return false;
    }
    return $res;
}

/*ajax/show_mynews.php */
function db_getMyNewsData()
{
	$con = connect();
	if(!$con)
	{
		return null;
	}
	$q = "SELECT n.id hir_id, u.user username, n.publisher_id userid, u.adminuser adminuser, DATEDIFF(NOW(), n.publication_date) publication_date, n.title title, n.description description, n.image_path image_path, n.file_path file_path, n.filename filename, n.file_size filesize FROM news n JOIN user u ON (n.publisher_id = u.id) WHERE n.is_deleted = 0 AND n.publisher_id = '" . mysqli_real_escape_string($con, $_SESSION["user_id"]) . "' ORDER BY n.publication_date DESC LIMIT 1";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

/* ajax/delete_news.php */
function db_getNewsFilesPath($hirid)
{
	$con = connect();
	if(!$con)
	{
		return null;
	}
	$q = "SELECT image_path, file_path FROM news WHERE id = '" . mysqli_real_escape_string($con, $hirid) . "'";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

/*ajax/db_index.php */
function db_newssection($offset, $limit)
{
	$con = connect();
	if(!$con)
	{
		return null;
	}
	$q = "SELECT n.id hir_id, u.user username, n.publisher_id userid, u.adminuser adminuser, DATEDIFF(NOW(), n.publication_date) publication_date, n.title title, n.description description, n.image_path image_path, n.file_path file_path, n.filename filename, n.file_size filesize, (SELECT adminuser FROM user WHERE id = '" . mysqli_real_escape_string($con, $_SESSION["user_id"]) . "') AS adminuser_my FROM news n JOIN user u ON (n.publisher_id = u.id) WHERE n.is_deleted = 0 ORDER BY n.publication_date DESC LIMIT $offset, $limit";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

?>