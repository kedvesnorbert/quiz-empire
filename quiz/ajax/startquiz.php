<?php
session_start();
require_once("../db/db_connect.php");
require_once("sessiontimeout.php");
require_once("../includes/responses.php");

if(!isset($_SESSION['user']))
{
    $_SESSION = array();
	session_destroy();
	header("location: ../login.php"); 
}
else
{
	
	if (isset($_SERVER['HTTP_X_REQUESTED_WITH']) && ($_SERVER['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest')) 
	{
		if(logoff_ajax()==-1)
		{
			echo json_encode(array("resp"=>err_session_timeout()));
		}
		elseif(isset($_POST['bef_quizid']) && preg_match("/^[0-9]+$/", $_POST['bef_quizid']) && $_POST['bef_quizid'] >= 1 && $_POST['bef_quizid'] && logoff_ajax()== 0 && isset($_POST['bef_pw']))
		{
			$passw = hash("sha512", $_POST['bef_pw']);
			$con = connect();
			if(!$con)
			{
				return false;
			}
			$res = mysqli_query($con, "SELECT access, num_of_question, show_answers, time_to_answer, password, pass_degree, (SELECT access_quiz('" . mysqli_real_escape_string($con, $_SESSION['user']) . "', '" . mysqli_real_escape_string($con, $_POST['bef_quizid']) . "', '" . mysqli_real_escape_string($con, $passw) . "')) AS uzenet FROM thema WHERE id_number = '" . mysqli_real_escape_string($con, $_POST['bef_quizid']) . "'");
			if(!$res)
			{
				die(mysqli_connect_error());
			}
			mysqli_close($con);
			$row = mysqli_fetch_assoc($res);
				
			$kiir = $row['uzenet'];
			if($kiir == "ok")
			{
				if(!isset($_SESSION['whichType']))
				{
					$_SESSION['whichType'] = $_POST['bef_quizid'];
				}
				else
				{
					$_SESSION['whichType'] = $_POST['bef_quizid'];
				}
				
				if(!isset($_SESSION['isCompetition']))
				{
					$_SESSION['isCompetition'] = 0;
				}
				else
				{
					$_SESSION['isCompetition'] = 0;
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
				
				////
				if(!isset($_SESSION['pageQuiz']))
				{
					$_SESSION['pageQuiz'] = 1;
				}
				
				if(preg_match("/^[0-9]+$/", $_POST['bef_page']) && $_POST['bef_page'] > 0 && $_POST['bef_page'])
				{
					$_SESSION['pageQuiz'] = $_POST['bef_page'];
				}
				else
				{
					$_SESSION['pageQuiz'] = 1;
				}
				
				
				
				if(!isset($_SESSION['nameOfQuiz']))
				{
					$_SESSION['nameOfQuiz'] = "";
				}
				
				if(!empty($_POST['bef_name']) && strlen($_POST['bef_name']) > 0 && strlen($_POST['bef_name']) < 50)
				{
					$_SESSION['nameOfQuiz'] = $_POST['bef_name'];
				}
				else
				{
					$_SESSION['nameOfQuiz'] = ""; 
				}
				
				
				if(!isset($_SESSION['langOfQuiz']))
				{
					$_SESSION['langOfQuiz'] = 0;
				}
				
				if(preg_match("/^[0-9]+$/", $_POST['bef_lang']) && $_POST['bef_lang'] >=0 && $_POST['bef_lang'] < 3)
				{
					$_SESSION['langOfQuiz'] = $_POST['bef_lang'];
				}
				else
				{
					$_SESSION['langOfQuiz'] = 0;
				}
				
				if(!isset($_SESSION['whereSearchQuiz']))
				{
					$_SESSION['whereSearchQuiz'] = 1;
				}
				
				if(preg_match("/^[0-9]+$/", $_POST['bef_where']) && $_POST['bef_where'] > 0 && $_POST['bef_where'] < 5)
				{
					$_SESSION['whereSearchQuiz'] = $_POST['bef_where'];
				}
				else
				{
					$_SESSION['whereSearchQuiz'] = 1;
				}
				
				if(!isset($_SESSION['fromcurrentquiz']))
				{
					$_SESSION['fromcurrentquiz'] = 0;
				}
				
				if(preg_match("/^[0-9]+$/", $_POST['bef_fromquiz']))
				{
					$_SESSION['fromcurrentquiz'] = $_POST['bef_fromquiz'];
				}
				else
				{
					$_SESSION['fromcurrentquiz'] = 0;
				}
				echo json_encode(array("resp"=>"ok"));
				
			}
			else
			{
				echo json_encode(array("resp"=>"$kiir"));
			}		
		}
		else
		{
			echo json_encode(array("resp"=>err_missing_data()));
		}
	}
	else
	{
		require_once("../error.php");
	}
}
?>