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
	if(logoff_ajax()== -1)
	{
		echo json_encode(array("resp"=>err_session_timeout()));
	}
	elseif (!isset($_POST["quest_id"]) || empty($_POST["quest_id"]) || !preg_match("/^[0-9]+$/", $_POST['quest_id']) || $_POST["quest_id"] < 1)
	{
		echo json_encode(array("resp"=>"HIBA! Helytelen kérdés azonosító!"));
	}
	elseif (!isset($_POST["tema"]) || empty($_POST["tema"]) || $_POST["tema"] < 1 || !preg_match("/^[0-9]+$/", $_POST['tema']))
	{
		echo json_encode(array("resp"=>"HIBA! Helytelen témakör!"));
	}
	elseif (!isset($_POST["question"]) || empty($_POST["question"]) || strlen($_POST["question"]) < 1)
	{
		echo json_encode(array("resp"=>"HIBA! Nincs a kérdés mezője kitöltve!"));
	}
	elseif (strlen($_POST["question"]) > 254)
	{
		echo json_encode(array("resp"=>"HIBA! Túl hosszú a kérdés szövege! (" . strlen($_POST["question"]) . ") Az ékezetes betűk és különleges karakterek kétszer annyi helyet foglalnak, mint az angol ábécé betűi!"));
	}
	elseif (!isset($_POST["ans1"]) || empty($_POST["ans1"]) || strlen($_POST["ans1"]) < 1)
	{
		echo json_encode(array("resp"=>"HIBA! Nincs a HELYES válasz mezője kitöltve!"));
	}
	elseif (strlen($_POST["ans1"]) > 150)
	{
		echo json_encode(array("resp"=>"HIBA! Túl hosszú a HELYES válasz szövege! (" . strlen($_POST["ans1"]) . ") Az ékezetes betűk és különleges karakterek kétszer annyi helyet foglalnak, mint az angol ábécé betűi!"));
	}
	elseif (!isset($_POST["ans2"]) || empty($_POST["ans2"]) || strlen($_POST["ans2"]) < 1)
	{
		echo json_encode(array("resp"=>"HIBA! Nincs az 1. helytelen válasz mezője kitöltve!"));
	}
	elseif (strlen($_POST["ans2"]) > 150)
	{
		echo json_encode(array("resp"=>"HIBA! Túl hosszú az 1. helytelen válasz szövege! (" . strlen($_POST["ans2"]) . ") Az ékezetes betűk és különleges karakterek kétszer annyi helyet foglalnak, mint az angol ábécé betűi!"));
	}
	elseif (!isset($_POST["ans3"]) || empty($_POST["ans3"]) || strlen($_POST["ans3"]) < 1)
	{
		echo json_encode(array("resp"=>"HIBA! Nincs a 2. helytelen válasz mezője kitöltve!"));
	}
	elseif (strlen($_POST["ans3"]) > 150)
	{
		echo json_encode(array("resp"=>"HIBA! Túl hosszú a 2. helytelen válasz szövege! (" . strlen($_POST["ans3"]) . ") Az ékezetes betűk és különleges karakterek kétszer annyi helyet foglalnak, mint az angol ábécé betűi!"));
	}
	elseif (!isset($_POST["ans4"]) || empty($_POST["ans4"]) || strlen($_POST["ans4"]) < 1)
	{
		echo json_encode(array("resp"=>"HIBA! Nincs a 3. helytelen válasz mezője kitöltve!"));
	}
	elseif (strlen($_POST["ans4"]) > 150)
	{
		echo json_encode(array("resp"=>"HIBA! Túl hosszú a 3. helytelen válasz szövege! (" . strlen($_POST["ans4"]) . ") Az ékezetes betűk és különleges karakterek kétszer annyi helyet foglalnak, mint az angol ábécé betűi!"));
	}
	elseif ($_POST["ans1"] == $_POST["ans2"] || $_POST["ans1"] == $_POST["ans3"] || $_POST["ans1"] == $_POST["ans4"] || $_POST["ans2"] == $_POST["ans3"] || $_POST["ans2"] == $_POST["ans4"] || $_POST["ans3"] == $_POST["ans4"] || $_POST["question"] == $_POST["ans1"] || $_POST["question"] == $_POST["ans2"] || $_POST["question"] == $_POST["ans3"] || $_POST["question"] == $_POST["ans4"])
	{
		echo json_encode(array("resp"=>"HIBA! Mindenik válasz különböző kell legyen, valamint a kérdés sem lehet egyenlő a válaszok bármelyikével!"));
	}
	elseif (!isset($_POST['megj']))
	{
		echo json_encode(array("resp"=>"HIBA! A megjegyzés mezője nem érkezett meg a szerverhez!"));
	}
	elseif (strlen($_POST["megj"]) > 150 )
	{
		echo json_encode(array("resp"=>"HIBA! A megjegyzés mezője túl hosszú! Az ékezetes betűk és különleges karakterek kétszer annyi helyet foglalnak, mint az angol ábécé betűi!"));
	}
	else
	{
		$con = connect();
		mysqli_query($con, "SET	@p_response");
		mysqli_query($con, "CALL correcting_question('" . mysqli_real_escape_string($con, $_POST['quest_id']) . "', '" . mysqli_real_escape_string($con, $_POST['tema']) . "', '" . mysqli_real_escape_string($con, $_POST['question']) . "', '" . mysqli_real_escape_string($con, $_POST['ans1']) . "', '" . mysqli_real_escape_string($con, $_POST['ans2']) . "', '" . mysqli_real_escape_string($con, $_POST['ans3']) . "', '" . mysqli_real_escape_string($con, $_POST['ans4']) . "', '" . mysqli_real_escape_string($con, $_SESSION['user']) . "', '" . mysqli_real_escape_string($con, $_POST['megj']) . "', @p_response)");
		$q = "SELECT @p_response AS p_response";
		$res = mysqli_query($con, $q);
		mysqli_close($con);
		$row = mysqli_fetch_assoc($res);
		$kiir = $row['p_response'];
		echo json_encode(array("resp"=>$kiir));
	}
}
else
{
	require_once("../error.php");
}
}
?>