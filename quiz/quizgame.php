<?php
session_start();
require_once("db/db_connect.php");
require_once("db/db_quizgame.php");
require_once("includes/update_logoff.php");
require_once("includes/responses.php");
require_once("view/view_quizgame.php");

if(!isset($_SESSION["user"]))
{
	header("location: login.php");
	$_SESSION = array();
	session_destroy();
}
if(!isset($_SESSION['whichType']))
{
	die(err_playquiz());
}

function toArray($res)
{
	$resultarray = array();
	while($row = mysqli_fetch_assoc($res))
	{
		array_push($resultarray, $row);
	}
	return $resultarray;
}

function checkanswers()
{
	$helyes = -1;
	$jeloltvalasz = "";
	if(array_key_exists('btn1', $_POST))
	{
		$_SESSION['alreadyanswered'] = $_SESSION['numberofquestion'];
		$jeloltvalasz = $_POST['btn1'];
		if(htmlspecialchars($_POST['btn1']) == $_SESSION['valaszok'][0])
		{
			$point = $_SESSION['totalcorrect'];
			$point++;
			$_SESSION['totalcorrect']=$point;
			$helyes = 1;
		}
		else
		{
			$point = $_SESSION['totalcorrect'];
			$_SESSION['totalcorrect']=$point;
			$helyes = 0;
		}
		sleep(5);
	}
	elseif(array_key_exists('btn2', $_POST))
	{
		$_SESSION['alreadyanswered'] = $_SESSION['numberofquestion'];
		$jeloltvalasz = $_POST['btn2'];
		if(htmlspecialchars($_POST['btn2']) == $_SESSION['valaszok'][0])
		{
			$point = $_SESSION['totalcorrect'];
			$point++;
			$_SESSION['totalcorrect']=$point;
			$helyes = 1;
		}
		else
		{
			$point = $_SESSION['totalcorrect'];
			$_SESSION['totalcorrect']=$point;
			$helyes = 0;
		}
		sleep(5);
	}
	elseif(array_key_exists('btn3', $_POST))
	{
		$_SESSION['alreadyanswered'] = $_SESSION['numberofquestion'];
		$jeloltvalasz = $_POST['btn3'];
		if(htmlspecialchars($_POST['btn3']) == $_SESSION['valaszok'][0])
		{
			$point = $_SESSION['totalcorrect'];
			$point++;
			$_SESSION['totalcorrect']=$point;
			$helyes = 1;
		}
		else
		{
			$point = $_SESSION['totalcorrect'];
			$_SESSION['totalcorrect']=$point;
			$helyes = 0;
		}
		sleep(5);
		
	}
	elseif(array_key_exists('btn4', $_POST))
	{
		$_SESSION['alreadyanswered'] = $_SESSION['numberofquestion'];
		$jeloltvalasz = $_POST['btn4'];
		if(htmlspecialchars($_POST['btn4']) == $_SESSION['valaszok'][0])
		{
			$point = $_SESSION['totalcorrect'];
			$point++;
			$_SESSION['totalcorrect']=$point;
			$helyes = 1;
		}
		else
		{
			$point = $_SESSION['totalcorrect'];
			$_SESSION['totalcorrect']=$point;
			$helyes = 0;
		}
		 sleep(5);
	}
	else
	{
		$_SESSION['alreadyanswered'] = $_SESSION['numberofquestion'];
		$point = $_SESSION['totalcorrect'];
		$_SESSION['totalcorrect']=$point;
		$helyes = -1;
	}
	if(!db_updatequestion_answered($helyes, $jeloltvalasz))
	{
		die(err_playquiz());
	}
}

function show_quizquestion($res)
{
	if(!$res)
	{
		die(err_db());
	}
	$row = mysqli_fetch_assoc($res);
	?> 
	<input type="hidden" id="time_left_ans" value="<?php echo $_SESSION['time_to_answer']; ?>">
	<meta http-equiv="refresh" content="<?php echo $_SESSION['time_to_answer'] ?>;url=quizgame.php" />	 
	<?php
	$_SESSION['currentquestionid'] = $row['id'];
	$_SESSION['valaszok'] = array(htmlspecialchars($row['ans1']), htmlspecialchars($row['ans2']), htmlspecialchars($row['ans3']), htmlspecialchars($row['ans4']));
	$_SESSION['valaszok_shuff'] = $_SESSION['valaszok'];
	shuffle($_SESSION['valaszok_shuff']);
	$id = $row['id'];
	$question = htmlspecialchars($row['question']);
	show_quizquestion_data($id, $question);
}

function nextquestion()
{
	$res = db_getquestion();
	if(!$res)
	{
		show_no_quiz();
	}
	else
	{			
		if($_SESSION['numberofquestion']<$_SESSION['num_of_question'])
		{
			$_SESSION['numberofquestion']++;
			show_quizquestion($res);
		}	
		else
		{
			if($_SESSION['isCompetition'] != 1)
			{
				$con = connect();
				mysqli_query($con, "SET @result = '" . mysqli_real_escape_string($con, $_SESSION['totalcorrect']) . "'");
				mysqli_query($con, "SET @score");
				mysqli_query($con, "CALL get_quiz_result(@result, '" . mysqli_real_escape_string($con, $_SESSION['whichType']) . "', '" . mysqli_real_escape_string($con, $_SESSION['user']) . "', @score)");
				$res = mysqli_query($con, "SELECT @result result, @score score");
				mysqli_close($con);
				show_quizresult($res);
			}
			else
			{
				$con = connect();
				mysqli_query($con, "SET @result = '" . mysqli_real_escape_string($con, $_SESSION['totalcorrect']) . "'");
				mysqli_query($con, "SET @score");
				mysqli_query($con, "CALL get_competition_result(@result, '" . mysqli_real_escape_string($con, $_SESSION['whichType']) . "', '" . mysqli_real_escape_string($con, $_SESSION['user']) . "', @score)");
				$res = mysqli_query($con, "SELECT @result result, @score score");
				mysqli_close($con);
				show_competitionresult($res);
			}
			$_SESSION['backgrounds_array'] = array();
			unset($_SESSION['backgrounds_array']);
			
			$_SESSION['totalcorrect'] = 0;
			
			$_SESSION['numberofquestion']=0;
			
			$_SESSION['currentquestionid'] = 0;
			
			$_SESSION['alreadyanswered']=0;
			
			$_SESSION['valaszok'] = array();
			$_SESSION['valaszok_shuff'] = array();
			$_SESSION['whichType'] = -10;
			$_SESSION['num_of_question'] = 0;
			$_SESSION['show_answers'] = -1;
			$_SESSION['time_to_answer'] = 0;
			
			$_SESSION['isCompetition'] = 0;
			
			redirect_to_lastpage();
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
	<style>
	body {
		background-image: url(
	<?php
		if(!isset($_SESSION['backgrounds_array']))
		{
			$r = toArray(db_getBackgroundImage());
			$_SESSION['backgrounds_array'] = $r;
			
		}
		if(!empty($_SESSION['backgrounds_array']))
		{
			shuffle($_SESSION['backgrounds_array']);
			$kep = $_SESSION['backgrounds_array'][0]['image_path'];
			echo $kep . ')';
		}
		else
		{
			echo 'documents/images/quiz.jpg)';
		}
		?>
	}
	</style>
	<link rel="stylesheet" type="text/css" href="css/quizgame.css" />
    <link rel="stylesheet" href="includes/jQuery-ui.css">
	<script type = "text/javascript" src="includes/jQuery.js"></script>
	<script type = "text/javascript" src="includes/jQuery-ui.js"></script>
	<script type = "text/javascript" src="js/quizgame.js"></script>	
</head>
<body oncontextmenu="return false" oncopy="return false" oncut="return false" onpaste="return false">
<?php
if(!isset($_SESSION['totalcorrect'])){
	$_SESSION['totalcorrect'] = 0;
}

if(!isset($_SESSION['numberofquestion'])){
	$_SESSION['numberofquestion']=0;
}

if(!isset($_SESSION['currentquestionid'])){
	$_SESSION['currentquestionid']=0;
}
if(!isset($_SESSION['alreadyanswered'])){
	$_SESSION['alreadyanswered']=0;
}
checkanswers();
nextquestion();
?>
</body>
</html>