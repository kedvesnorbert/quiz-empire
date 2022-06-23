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
require_once("../db/db_allquiz.php");
require_once("../../includes/responses.php");
require_once("sessiontimeoutadmin.php");

if (isset($_SERVER['HTTP_X_REQUESTED_WITH']) && ($_SERVER['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest')) 
{
	if(adminlogoff_ajax()== -1)
    {
        echo json_encode(array("resp"=>err_session_timeout()));
    }
	elseif(!isset($_POST['quizid']) || !preg_match("/^[0-9]+$/", $_POST['quizid']) || $_POST['quizid'] < 1)
	{
		echo err_missing_data();
	}
	else
	{
		$k = 1;
		$res = db_getactivequestions_quiz($_POST['quizid']);
		if(!$res)
		{
			die(err_db());
		}
		if(mysqli_num_rows($res) == 0)
		{
			echo "Nincsenek aktív ellenőrzött kérdések ebben a kategóriában!";
			die(mysqli_connect_error());
		}
		echo "<center><br><table border='1' id='questions_table'><tr id='header_qtable'><td>Nr. <td>Kérdés szövege<td>Válaszok\n";
		while($row = mysqli_fetch_assoc($res))
		{
			
			echo "<tr style='height:100px;'>";
			echo "<td>" . $k++ . ". <td>" . htmlspecialchars($row['question']) . "<td><b>" . htmlspecialchars($row['ans1']) . "</b><br>" . htmlspecialchars($row['ans2']) . "<br>" . htmlspecialchars($row['ans3']) . "<br>" . htmlspecialchars($row['ans4']) . "\n";
		}
		echo "</table></center>";
	}
}
else
{
	require_once("../error.php");
}
}