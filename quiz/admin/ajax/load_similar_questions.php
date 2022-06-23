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
	elseif(!isset($_POST['qstring']) || strlen($_POST['qstring']) < 1)
	{
		echo err_missing_data();
	}
	elseif(!isset($_POST['qid']) || !preg_match("/^[0-9]+$/", $_POST["qid"]) || $_POST["qid"] < 1 )
    {
        echo "Helytelen érték: qid!";
    }
	else
	{
		while(substr($_POST['qstring'], -1) == ',')
		{
			$_POST['qstring'] = substr($_POST['qstring'], 0, -1); /*remove last comma */
		}
		$array_to_search = preg_split("/\s+/", $_POST['qstring']); /*remove unnecessary spaces */
		$array_to_search = join("", $array_to_search);
		
		$array_to_search = preg_replace("/[\/\\#+()$~%\:?\'\"<>{}_|]/", '', $array_to_search); /*remove these special characters */
		$array_to_search = preg_replace("/[,]{2,}/", ',', $array_to_search); /*replace more than one commas to one comma */
		$array_to_search = preg_replace("/[,]/", ' ', $array_to_search); /*replace comma to space */
		
		$array = array_unique(explode(' ', $array_to_search)); /*make an unique array with these words */
		
		echo "<b>Feltétel:</b> ";
		for($i=0; $i<count($array)-1; ++$i)
		{
			echo $array[$i] . ", ";
		}
		echo $array[$i];

		$res = db_similar_questions($array, $_POST["qid"]);
		if(!$res)
		{
			echo "<br>";
			die(err_db());
		}
		$num_r = mysqli_num_rows($res);
		echo "<br><br><b>Találatok száma:</b> " . $num_r . "<hr>";
		if($num_r == 0)
		{
			echo "<br><center>Nagyszerű! Nincsenek hasonló találatok!</center>";
			die(mysqli_connect_error());
		}
		
		while($row = mysqli_fetch_assoc($res))
		{
			echo "<p>" .htmlspecialchars($row['question']) . " (<i>" . htmlspecialchars($row['ans1']) . ", " . $row['quiz_name'] . " témakör )</i></p>";
		}
		
	}
}
else
{
	require_once("../error.php");
}
}