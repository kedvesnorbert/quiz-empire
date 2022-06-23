<?php
if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {
	require_once("../error.php");
	die(); /*Direct Access Not Allowed */
	exit();
};

function db_themalist()
{
	$con = connect();
	if (!$con)
	{
		return null;
	}
	$sajatid = $_SESSION['user_id'];
	$admine = $_SESSION['admin_user'];
	$q = "SELECT id_number, quiz_name FROM thema WHERE is_request = 0 AND is_deleted = 0 AND 
	( (phase = 2 AND requested_by = '" . mysqli_real_escape_string($con, $_SESSION['user']) . "') OR
	  (phase = 3 AND
			(
				(accept_questions = 1 AND requested_by = '" . mysqli_real_escape_string($con, $_SESSION['user']) . "') OR
				(accept_questions = 2 AND ('" . mysqli_real_escape_string($con, $admine) . "' = 1 OR requested_by = '" . mysqli_real_escape_string($con, $_SESSION['user']) . "')) OR 
				(accept_questions = 3 AND 
					('" . mysqli_real_escape_string($con, $admine) . "' = 1 OR requested_by = '" . mysqli_real_escape_string($con, $_SESSION['user']) . "' OR id_number IN 
						(SELECT quizid FROM permission_submit_question WHERE userid = '" . mysqli_real_escape_string($con, $sajatid) . "')
						) ) OR
				accept_questions = 4
			)
	  )
	)
	UNION 
	SELECT id_number, quiz_name FROM thema WHERE is_request = 1 AND is_deleted = 0 AND 
		( (phase = 2 AND is_undertaken = 1 AND undertaken_by = '" . mysqli_real_escape_string($con, $_SESSION['user']) . "') OR phase = 3 )
	UNION
	SELECT t.id_number, t.quiz_name FROM thema t JOIN user u ON (t.requested_by = u.user) WHERE t.is_request = 0 AND phase = 3 AND t.is_deleted = 0 AND 
	t.accept_questions = 5 AND ('" . mysqli_real_escape_string($con, $admine) . "' = 1 OR t.requested_by = '" . mysqli_real_escape_string($con, $_SESSION['user']) . "' OR 
		( '" . mysqli_real_escape_string($con, $sajatid) . "' IN ( SELECT f.id1 FROM user u JOIN friend f ON f.id1 = u.id JOIN user u2 ON f.id2 = u2.id WHERE u2.user = t.requested_by AND f.status = 1 UNION SELECT f.id2 FROM user u JOIN friend f ON f.id1 = u.id JOIN user u2 ON f.id2 = u2.id WHERE u.user = t.requested_by AND f.status = 1
		)
		
		)
					)
	ORDER BY quiz_name";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

function db_lawto_sendquestion()
{
	$con = connect();
	if(!$con)
	{
		return false;
	}
	$q = "SELECT lawtosendquestion FROM user WHERE user='" . mysqli_real_escape_string($con, $_SESSION['user']) . "'";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		die();
	}
	$row = mysqli_fetch_assoc($res);
	if($row['lawtosendquestion'] == 1)
	{
		return true;
	}
	else
	{
		return false;
	}
}

function db_correct_questionlist()
{
	$con = connect();
	if (!$con)
	{
		return false;
	}
	$res = mysqli_query($con, "SELECT q.id, q.ID, q.quiz_id, t.quiz_name, q.question, q.ans1, q.ans2, q.ans3, q.ans4, c.comment_text, c.comment_time FROM thema t JOIN quiz_question q ON t.id_number=q.quiz_id JOIN question_comment c ON q.id=c.question_id WHERE q.is_verified = 2 AND q.username = '" . mysqli_real_escape_string($con, $_SESSION['user']) . "' AND c.id = (SELECT id FROM question_comment WHERE question_id=q.id ORDER BY comment_time DESC LIMIT 1) ORDER BY q.sending_time ASC");
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	return $res;
}

?>