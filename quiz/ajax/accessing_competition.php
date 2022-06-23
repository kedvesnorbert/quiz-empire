<?php
session_start();
require_once("../db/db_connect.php");
require_once("../includes/responses.php");
require_once("sessiontimeout.php");

if(!isset($_SESSION['user']))
{
    $_SESSION = array();
	session_destroy();
	header("location: ../login.php"); 
}
else
{

function access_competition()
{
	$con = connect();
	if(!$con)
	{
		return false;
	}
	$res = mysqli_query($con, "SELECT id_number, access, num_of_question, show_answers, time_to_answer, password, pass_degree, (SELECT access_competition('" . mysqli_real_escape_string($con, $_SESSION['user']) . "', 1)) AS eredmeny FROM thema WHERE id_number = (SELECT quiz_id FROM competition WHERE activity = 1 LIMIT 1)");
	mysqli_close($con);
	if(!$res || mysqli_num_rows($res)==0)
	{
		echo json_encode(array("resp"=>"Jelenleg itt nem érhető el a kvíz!"));
		return false;
	}
	$row = mysqli_fetch_assoc($res);
	$kiir = $row['eredmeny'];
	
	if($kiir != "ok")
	{
		echo json_encode(array("resp"=>"$kiir"));
	}
	else
	{
		if(!isset($_SESSION['whichType']))
		{
			$_SESSION['whichType'] = $row['id_number'];
		}
		else
		{
			$_SESSION['whichType'] = $row['id_number'];
		}
		if(!isset($_SESSION['isCompetition']))
		{
			$_SESSION['isCompetition'] = 1;
		}
		else
		{
			$_SESSION['isCompetition'] = 1;
		}
		
		if(!isset($_SESSION['num_of_question']))
		{
			$_SESSION['num_of_question'] = $row['num_of_question'];
		}
		else
		{
			$_SESSION['num_of_question'] = $row['num_of_question'];
		}
		
		if(!isset($_SESSION['show_answers']))
		{
			$_SESSION['show_answers'] = $row['show_answers'];
		}
		else
		{
			$_SESSION['show_answers'] = $row['show_answers'];
		}
		
		if(!isset($_SESSION['time_to_answer']))
		{
			$_SESSION['time_to_answer'] = $row['time_to_answer'];
		}
		else
		{
			$_SESSION['time_to_answer'] = $row['time_to_answer'];
		}
		
		if(!isset($_SESSION['teszt_sikeresseg']))
		{
			$_SESSION['teszt_sikeresseg'] = $row['pass_degree'];
		}
		else
		{
			$_SESSION['teszt_sikeresseg'] = $row['pass_degree'];
		}
		
		echo json_encode(array("resp"=>"mindenok"));
	}
}

if (isset($_SERVER['HTTP_X_REQUESTED_WITH']) && ($_SERVER['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest')) 
{
	if(logoff_ajax()==-1)
	{
		echo json_encode(array("resp"=>err_session_timeout()));
	}
	else
	{
		access_competition();
	}
}
else
{
	require_once("../error.php");
}
}
?>