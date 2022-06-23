<?php
session_start();

if(!isset($_SESSION['adminuser']) || !isset($_SESSION['is_admin']) || !isset($_SESSION['user_id']))
{
    $_SESSION = array();
	session_destroy();
	header("location: ../adminlogin.php");
}
else
{
require_once("../db/db_connect.php");
require_once("../db/db_questions.php");
require_once("../../includes/responses.php");
require_once("sessiontimeoutadmin.php");

if (isset($_SERVER['HTTP_X_REQUESTED_WITH']) && ($_SERVER['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest')) 
{
	if(adminlogoff_ajax()== -1)
    {
        echo err_session_timeout();
    }
	elseif(!isset($_POST['questionid']) || !preg_match("/^[0-9]+$/", $_POST['questionid']) || $_POST['questionid'] < 1)
	{
		echo err_missing_data();
	}
	else
	{
		$res = db_question_comments($_POST['questionid']);
		if(!$res)
		{
			die(err_db());
		}
		if(mysqli_num_rows($res) == 0)
		{
			echo "<br>Nincsenek hozzászólások!";
			die(mysqli_connect_error());
		}
		echo "<center><br><table border='1' id='questioncomments_table'><tr id='header_qtable'><td style='width:60%;'>Hozzászólás <td style='width:20%;'>Írta<td style='width:20%;'>Időpont\n";
		while($row = mysqli_fetch_assoc($res))
		{
			echo "<tr style='height:75px;'>";
			echo "<td>" . htmlspecialchars($row['comment_text']) . " <td>" . $row['posted_by'] . "<td>" . $row['comment_time'] . "\n";
		}
		echo "</table></center>";
	}
}
else
{
	require_once("../error.php");
}
}