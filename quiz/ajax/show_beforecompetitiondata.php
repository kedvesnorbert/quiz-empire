<?php
session_start();

require_once("../db/db_connect.php");
require_once("../db/db_index.php");
require_once("sessiontimeout.php");
require_once("../includes/responses.php");
require_once("../view/view_error.php");
require_once("../view/view_index.php");

if(!isset($_SESSION['user']))
{
    $_SESSION = array();
	session_destroy();
	header("location: ../login.php"); 
}
else
{

function start_competition()
{
	$res = db_getCompetition();
	if(!$res)
	{
		die(err_db());
	}
	$row = mysqli_fetch_assoc($res);

	$show_answers = ($row['show_answers'] == 1) ? " megmutatjuk." : " nem mutatjuk meg.";
	show_start_competition($row['num_of_question'], $row['time_to_answer'], $show_answers, $row['reward7'], $row['reward6'], $row['reward5'], $row['reward4'], $row['reward3'], $row['reward2'], $row['reward1']);
}

if (isset($_SERVER['HTTP_X_REQUESTED_WITH']) && ($_SERVER['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest')) 
{
	if(logoff_ajax()==-1)
	{
		err_timeout();
	}
	else
	{
		start_competition();
	}
}
else
{
	require_once("../error.php");
}
}
?>