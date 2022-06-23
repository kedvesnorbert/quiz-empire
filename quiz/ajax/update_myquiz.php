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

function validateDate1($date, $format = 'Y-m-d')
{
    $d = DateTime::createFromFormat($format, $date);
    return $d && $d->format($format) === $date;
}

if (isset($_SERVER['HTTP_X_REQUESTED_WITH']) && ($_SERVER['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest')) 
{
	if(logoff_ajax()== -1)
	{
		echo json_encode(array("resp"=>err_session_timeout()));
	}
	elseif(!isset($_POST['quizid']) || !preg_match("/^[0-9]+$/", $_POST['quizid']) || $_POST['quizid'] < 1 || !isset($_POST['kvizelerhetoseg']) || !isset($_POST['numofplaying']) || !isset($_POST['kerdfogadas']) || !isset($_POST['verifycurrent']))
	{
		echo json_encode(array("resp"=>err_missing_data()));
	}
	else
	{
		if(($_POST['kvizelerhetoseg'] != 1 && $_POST['kvizelerhetoseg'] != 2 && $_POST['kvizelerhetoseg'] != 3 && $_POST['kvizelerhetoseg'] != 4 && $_POST['kvizelerhetoseg'] != 5) || ($_POST['numofplaying'] != 1 && $_POST['numofplaying'] != 2 && $_POST['numofplaying'] != 3 && $_POST['numofplaying'] != 4 && $_POST['numofplaying'] != 5 && $_POST['numofplaying'] != 6) || ($_POST['kerdfogadas'] != 1 && $_POST['kerdfogadas'] != 2 && $_POST['kerdfogadas'] != 3 && $_POST['kerdfogadas'] != 4 && $_POST['kerdfogadas'] != 5) || $_POST['verifycurrent'] < 0 || $_POST['verifycurrent'] > 1000000 )
		{
			echo json_encode(array("resp"=>"HIBA! Lehetséges okok: Nem választottál ki semmit a legördülő listamezőkből, vagy nem töltöttél ki egy kötelező mezőt, vagy azt helytelenül töltötted ki!"));
		}
		elseif($_POST['kvizelerhetoseg'] == 4 && ($_POST['pass1'] == "" || $_POST['pass2'] == "" || $_POST['pass1'] != $_POST['pass2']) || strlen($_POST['pass1'])>30 || strlen($_POST['pass2'])>30)
		{
			echo json_encode(array("resp"=>"HIBA! Nem írtál be semmit a teszt új jelszavaihoz (Max 30 karakter), vagy nem talál a két jelszó!"));
		}
		elseif(validateDate1($_POST['startd']) == false  && !empty($_POST['startd']) )
		{
			echo json_encode(array("resp"=>"HIBA! Helytelen a KEZDŐ dátum!"));
		}
		elseif(validateDate1($_POST['endd']) == false  && !empty($_POST['endd']) )
		{
			echo json_encode(array("resp"=>"HIBA! Helytelen a második dátum!"));
		}
		elseif(!isset($_POST['elerheto']) && $_POST['kvizelerhetoseg'] == 2)
		{
			echo json_encode(array("resp"=>"HIBA! Nem választottad ki egy barátodat sem, akik elérhetik a kvízt!"));
		}
		elseif(!isset($_POST['fogad']) && $_POST['kerdfogadas'] == 3)
		{
			echo json_encode(array("resp"=>"HIBA! Nem választottad ki egy barátodat sem, akik küldhetnek be kérdéseket a kvízedhez!"));
		}
		else
		{
			if(isset($_POST['pass1']))
			{
				$jel_new = hash("sha512", $_POST["pass1"]);
			}
			else
			{
				$jel_new = '';
			}
			
			if(isset($_POST['passcurrent']))
			{
				$jel_old = hash("sha512", $_POST["passcurrent"]);
			}
			else
			{
				$jel_old = '';
			}
			
			if(isset($_POST['mypasscurrent']))
			{
				$jel_myold = hash("sha512", $_POST["mypasscurrent"]);
			}
			else
			{
				$jel_myold = '';
			}
			
			if(isset($_POST['elerheto']) && is_array($_POST['elerheto']))
			{
				$_POST['elerheto'] = implode(',',$_POST['elerheto']);
			}
			else
			{
				$_POST['elerheto'] = "";
			}
			
			if(isset($_POST['fogad']) && is_array($_POST['fogad']))
			{
				$_POST['fogad'] = implode(',',$_POST['fogad']);
			}
			else
			{
				$_POST['fogad'] = "";
			}
			
			$con = connect();	
			mysqli_query($con, "SET @p_response");
			mysqli_query($con, "CALL update_quiz('" . mysqli_real_escape_string($con, $_POST['quizid']) . "', '" . mysqli_real_escape_string($con, $_POST['kvizelerhetoseg']) . "', '" . mysqli_real_escape_string($con, $_POST['numofplaying']) . "', '" . mysqli_real_escape_string($con, $_POST['kerdfogadas']) . "', '" . mysqli_real_escape_string($con, $_POST['startd']) . "', '" . mysqli_real_escape_string($con, $_POST['endd']) . "', '" . mysqli_real_escape_string($con, $_SESSION['user']) . "', '" . mysqli_real_escape_string($con, $jel_new) . "', '" . mysqli_real_escape_string($con, $jel_old) . "', '" . mysqli_real_escape_string($con, $jel_myold) . "', '" . mysqli_real_escape_string($con, $_POST['verifycurrent']) . "', '" . mysqli_real_escape_string($con, $_POST['elerheto']) . "', '" . mysqli_real_escape_string($con, $_POST['fogad']) . "', @p_response)");
			$q = "SELECT @p_response AS p_response";
			$res = mysqli_query($con, $q);
			$row = mysqli_fetch_assoc($res);
			$kiir = $row['p_response'];
			mysqli_close($con);	
			echo json_encode(array("resp"=>"$kiir"));
		}
	}
}
else
{
	require_once("../error.php");
}
}