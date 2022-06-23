<?php
session_start();

require_once("../db/db_connect.php");
require_once("../db/db_quizdetails.php");
require_once("sessiontimeout.php");
require_once("../includes/responses.php");
require_once("../view/view_quizdetails.php");

if(!isset($_SESSION['user']))
{
    $_SESSION = array();
	session_destroy();
	header("location: ../login.php"); 
}
else
{

function show_commentsection()
{
	$res = db_commentsection($_POST['q_number'], $_POST['c_offset'], $_POST['c_limit']);
	if(!$res)
	{
		return false;
	}
	$sorok = mysqli_num_rows($res);
	if($sorok == 0 && $_POST['c_limit'] == 0)
	{
		echo '<p id="no_comment_text">Ehhez a kvízhez még senki nem írt hozzászólást!</p>';
	}
	elseif($sorok == 0)
	{
		;
	}
	else
	{
		while($row = mysqli_fetch_assoc($res))
		{
			$comment_text1 = nl2br(htmlentities($row['hozzaszolas']));
			$comment_text = str_replace("!!!censored!!!", "<img id='censoreimg' src='documents/images/censored.gif'></img>", $comment_text1);
			if($row['is_verified'] == 2)
			{
				$moderation = "<p id='comment_modsection'>" . nl2br(htmlentities($row['moderation'])) . ", " . $row['verification_time'] . " időpontban." . "</p>";
			}
			else
			{
				$moderation = "";
			}
			$commenter = $row['user'] != 'Törölt felhasználó' ? "<b><a href='profile.php?profil_id=" . $row['userid'] . "'>" . $row['user'] . "</a></b>" : "<i>" . $row['user'] . "</i>";
			$owncomment = ($row['user'] == $_SESSION['user']) ? "1" : "0";
			view_commentsection($_POST['q_number'], $commenter, $row['idopont'], $comment_text, $moderation, $owncomment, urlencode($row['hozzaszolas']), $row['quizid']);
		}
	}
}

if (isset($_SERVER['HTTP_X_REQUESTED_WITH']) && ($_SERVER['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest')) 
{
	if(logoff_ajax()==-1)
	{
		echo err_session_timeout();
	}
	elseif(!isset($_POST['q_number']) || empty($_POST['q_number']) || !preg_match("/^[0-9]+$/", $_POST['q_number']) || $_POST['q_number'] <= 0 || 
	!isset($_POST['c_limit']) || strlen($_POST['c_limit'])<1 || !preg_match("/^[0-9]+$/", $_POST['c_limit']) || $_POST['c_limit'] <= -1 || 
	!isset($_POST['c_offset']) || strlen($_POST['c_offset'])<1 || !preg_match("/^[0-9]+$/", $_POST['c_offset']) || $_POST['c_offset'] <= -1)
	{
		
		echo err_missing_data();
	}
	else
	{
		show_commentsection();
	}
}
else
{
	require_once("../error.php");
}
}
?>