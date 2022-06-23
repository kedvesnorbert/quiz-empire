<?php
session_start();

require_once("../db/db_connect.php");
require_once("../db/db_requests.php");
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
	if(logoff_ajax()== -1)
	{
		echo err_session_timeout();
	}
	elseif(!isset($_POST['quizid']) || !preg_match("/^[0-9]+$/", $_POST['quizid']) || $_POST['quizid'] < 1)
	{
		echo err_missing_data();
	}
	else
	{
		$k = 1;
		$res = db_getquestions_quiz($_POST['quizid']);
		if(!$res)
		{
			die(err_db());
		}
		if(mysqli_num_rows($res) == 0)
		{
			echo "Még nem küldtél be kérdéseket ebben a kategóriában!";
			die(mysqli_connect_error());
		}
		echo "<center><br><table id='questions_table' class='table-hover table-bordered'><tr id='header_qtable'><td>Nr. <td style='width:55%;'>Kérdés szövege<td style='width:27%';>Helyes válasz<td>Státusz\n";
		while($row = mysqli_fetch_assoc($res))
		{
			$statusz = "";
			if(is_null($row['is_verified']) || $row['is_verified'] == 0)
			{
				echo "<tr style='height:100px;font-style:italic;'>";
				$statusz = "Ellenőrzésre vár";
			}
			elseif($row['is_verified'] == 1)
			{
				echo "<tr style='height:100px;font-weight:bold;'>";
				$statusz = "Elfogadva";
				
			}
			elseif($row['is_verified'] == 2)
			{
				echo "<tr style='height:100px;background-color:orange'>";
				$statusz = "Javításra visszaküldve";
			}
			elseif($row['is_verified'] == 3)
			{
				echo "<tr style='height:100px;font-style:italic;background-color:pink'>";
				$statusz = "Törölve";
			}
			else
			{
				echo "<tr style='height:100px;'>";
			}
			echo "<td>" . $k++ . ". <td>" . htmlspecialchars($row['question']) . "<td>" . htmlspecialchars($row['ans1']) . "<td style='text-align:center;'>" . $statusz . "\n";
			
		}
		echo "</table></center>";
	}
}
else
{
	require_once("../error.php");
}
}