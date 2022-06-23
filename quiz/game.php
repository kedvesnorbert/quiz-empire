<?php
session_start();
if(!isset($_SESSION["user"]))
{
	header("location: login.php");
	$_SESSION = array();
	session_destroy();
}

require_once("db/db_connect.php");
require_once("db/db_game.php");
require_once("includes/responses.php");
require_once("includes/update_logoff.php");
require_once("view/view_game.php");

if(!isset($_SESSION['whichType']))
{
	die(err_playquiz());
}

function kiir($row)
{
	if(!db_updatequizquestion($row['id']))
	{
		die(err_db());
	}
	echo '<meta http-equiv="refresh" content="20;url=game.php" />';
	$_SESSION['valaszok'] = array($row['ans1'], $row['ans2'], $row['ans3'], $row['ans4']);
	$_SESSION['valaszok_shuff'] = $_SESSION['valaszok'];
	shuffle($_SESSION['valaszok_shuff']);
	$id = $row['id'];
	$question = $row['question'];
	show_question_data($question);
}

function checkanswer()
{
	if(array_key_exists('btn1', $_POST))
	{
		$_SESSION['alreadyanswered'] = $_SESSION['numberofquestion'];
		if($_POST['btn1'] == $_SESSION['valaszok'][0])
		{
			$point = $_SESSION['totalcorrect'];
			$point++;
			$_SESSION['totalcorrect']=$point;
		}
		else
		{
			$point = $_SESSION['totalcorrect'];
			$_SESSION['totalcorrect']=$point;
		}
		sleep(5);
	}
	elseif(array_key_exists('btn2', $_POST))
	{
		$_SESSION['alreadyanswered'] = $_SESSION['numberofquestion'];
		if($_POST['btn2'] == $_SESSION['valaszok'][0])
		{
			$point = $_SESSION['totalcorrect'];
			$point++;
			$_SESSION['totalcorrect']=$point;
		}
		else
		{
			$point = $_SESSION['totalcorrect'];
			$_SESSION['totalcorrect']=$point;
		}
		sleep(5);
	}
	elseif(array_key_exists('btn3', $_POST))
	{
		$_SESSION['alreadyanswered'] = $_SESSION['numberofquestion'];
		if($_POST['btn3'] == $_SESSION['valaszok'][0])
		{
			$point = $_SESSION['totalcorrect'];
			$point++;
			$_SESSION['totalcorrect']=$point;
		}
		else
		{
			$point = $_SESSION['totalcorrect'];
			$_SESSION['totalcorrect']=$point;
		}
		sleep(5);
		
	}
	elseif(array_key_exists('btn4', $_POST))
	{
		$_SESSION['alreadyanswered'] = $_SESSION['numberofquestion'];
		if($_POST['btn4'] == $_SESSION['valaszok'][0])
		{
			$point = $_SESSION['totalcorrect'];
			$point++;
			$_SESSION['totalcorrect']=$point;
		}
		else
		{
			$point = $_SESSION['totalcorrect'];
			$_SESSION['totalcorrect']=$point;
		}
		 sleep(5);
	}
	else
	{
		$_SESSION['alreadyanswered'] = $_SESSION['numberofquestion'];
		$point = $_SESSION['totalcorrect'];
		$_SESSION['totalcorrect']=$point;
	}
}

function nextquestion()
{
	$res = db_getquestion_update();
	if(!$res)
	{
		show_no_question();
	}
	else
	{		
		if($_SESSION['numberofquestion']<10)
		{
			$_SESSION['numberofquestion']++;
			$row = mysqli_fetch_assoc($res);
			kiir($row);
		}	
		else
		{
			$con = connect();
			mysqli_query($con, "SET @result = '" . mysqli_real_escape_string($con, $_SESSION['totalcorrect']) . "'");
			mysqli_query($con, "SET @score");
			$totalhelps_used = $_SESSION['helpFull'] + $_SESSION['helpHalf'] + $_SESSION['helpSfert'];
			if($totalhelps_used == 3) //ha elhasznalt legalabb 1 segitseget
			{
				$_SESSION['whichType'] = 0; //akkor nem vonunk le segitseget
			}
			
			if($_SESSION['whichType'] == 0)
			{
				mysqli_query($con, "CALL get_quiz_result(@result, 0, '" . mysqli_real_escape_string($con, $_SESSION['user']) . "', @score)");
			}
			elseif($_SESSION['whichType'] == -1)
			{
				mysqli_query($con, "CALL get_quiz_result(@result, -1, '" . mysqli_real_escape_string($con, $_SESSION['user']) . "', @score)");
			}
			elseif($_SESSION['whichType'] == -2)
			{
				db_delete_gyakorloquestions();
			}

			$res = mysqli_query($con, "SELECT @result result");
			mysqli_close($con);	
			$row = mysqli_fetch_assoc($res);

			show_gameresult($row['result']);
			
			$_SESSION['totalcorrect'] = 0;
			$_SESSION['numberofquestion']=0;
			$_SESSION['valaszok'] = array();
			$_SESSION['valaszok_shuff'] = array();
			$_SESSION['alreadyanswered']=0;
			
			$_SESSION['has_help'] = 0;
			$_SESSION['helpFull'] = 0;
			$_SESSION['helpHalf'] = 0;
			$_SESSION['helpSfert'] = 0;
		}
	}
}
?>
<html>
<head>
	<title>Quiz</title>
	<meta charset="utf-8">
	<noscript>
		<meta http-equiv="refresh" content="0; url=includes/enablejavascript.html">
	</noscript>
	<link rel="stylesheet" type="text/css" href="css/game.css" />
	<script type = "text/javascript" src="includes/jQuery.js"></script>
	<script type = "text/javascript" src="js/game.js"></script>	
</head>
<body oncontextmenu="return false" oncopy="return false" oncut="return false" onpaste="return false">
<?php

if(!isset($_SESSION['totalcorrect']))
{
	$_SESSION['totalcorrect'] = 0;
}

if(!isset($_SESSION['numberofquestion']))
{
	$_SESSION['numberofquestion']=0;
}
if(!isset($_SESSION['alreadyanswered'])){
	$_SESSION['alreadyanswered']=0;
}

checkanswer();
nextquestion();
?>
</body>
</html>