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

function start_quiz_with_help()
{	
	$con = connect();
	if(!$con)
	{
		die(mysqli_connect_error());
	}
	$qe = "SELECT help AS help, (SELECT access_generalquiz('" . mysqli_real_escape_string($con, $_SESSION['user']) . "')) AS eredmeny FROM user WHERE user='" . mysqli_real_escape_string($con, $_SESSION['user']) . "'";
	$res = mysqli_query($con, $qe);
	mysqli_close($con);
	$row = mysqli_fetch_assoc($res);
	if($row['eredmeny'] == "ok")
	{
		if(!isset($_SESSION['has_help']))
		{
			$_SESSION['has_help'] = $row['help'];
		}
		else
		{
			$_SESSION['has_help'] = $row['help'];
		}
		
		if(!isset($_SESSION['whichType']))
		{
			$_SESSION['whichType'] = -1;
		}
		else
		{
			$_SESSION['whichType'] = -1;
		}
		
		if(!isset($_SESSION['helpSfert']))
		{
			$_SESSION['helpSfert'] = 1;
		}
		else
		{
			$_SESSION['helpSfert'] = 1;
		}
		if(!isset($_SESSION['helpHalf']))
		{
			$_SESSION['helpHalf'] = 1;
		}
		else
		{
			$_SESSION['helpHalf'] = 1;
		}
		if(!isset($_SESSION['helpFull']))
		{
			$_SESSION['helpFull'] = 1;
		}
		else
		{
			$_SESSION['helpFull'] = 1;
		}
		echo json_encode(array("resp"=>"ok"));
	}
	else
	{
		$kiir = $row['eredmeny'];
		echo json_encode(array("resp"=>"$kiir"));
	}
}

function start_gyakorlo()
{
	$con = connect();
	if(!$con)
	{
		die(mysqli_connect_error());
	}
	$res = mysqli_query($con, "SELECT access_practicemode('" . mysqli_real_escape_string($con, $_SESSION['user']) . "') AS eredmeny");
	mysqli_close($con);
	$row = mysqli_fetch_assoc($res);
	if($row['eredmeny'] == "ok")
	{
		if(!isset($_SESSION['whichType']))
		{
			$_SESSION['whichType'] = -2;
		}
		else
		{
			$_SESSION['whichType'] = -2;
		}
		
		if(!isset($_SESSION['helpSfert']))
		{
			$_SESSION['helpSfert'] = 0;
		}
		else
		{
			$_SESSION['helpSfert'] = 0;
		}

		if(!isset($_SESSION['helpHalf']))
		{
			$_SESSION['helpHalf'] = 0;
		}
		else
		{
			$_SESSION['helpHalf'] = 0;
		}

		if(!isset($_SESSION['helpFull']))
		{
			$_SESSION['helpFull'] = 0;
		}
		else
		{
			$_SESSION['helpFull'] = 0;
		}
		echo json_encode(array("resp"=>"ok"));
	}
	else
	{
		$kiir = $row['eredmeny'];
		echo json_encode(array("resp"=>"$kiir"));
	}
}

if (isset($_SERVER['HTTP_X_REQUESTED_WITH']) && ($_SERVER['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest')) 
{
	if(!isset($_POST["quiztype"]) || ($_POST['quiztype'] != -2 && $_POST['quiztype'] != -1))
	{
		echo json_encode(array("resp"=>"Hibás kviz azonosító!"));
	}
	elseif(logoff_ajax()== -1)
	{
		echo json_encode(array("resp"=>err_session_timeout()));
	}
	else
	{
		if($_POST['quiztype'] == -1)
		{
			start_quiz_with_help();
		}
		else
		{
			start_gyakorlo();
		}
	}
}
else
{
	require_once("../error.php");
}

}
?>