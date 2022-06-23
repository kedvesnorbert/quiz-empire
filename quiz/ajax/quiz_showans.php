<?php
session_start();

if(!isset($_SESSION['user']))
{
    $_SESSION = array();
	session_destroy();
	header("location: ../login.php"); 
}
else
{
require_once("../db/db_connect.php");

if (isset($_SERVER['HTTP_X_REQUESTED_WITH']) && ($_SERVER['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest')) 
{
	if(!isset($_POST["validated"]) || !preg_match("/^[0-9]+$/", $_POST['validated']) || $_POST['validated'] < 1 || $_POST['validated'] > 4 || $_SESSION['alreadyanswered'] != $_SESSION['numberofquestion']-1)
	{
		;//echo "Hibás segítség azonosító!";
	}
	else
	{
		$resp = array();
		if($_POST["validated"] == 1)
		{
			array_push($resp, "ok");
			array_push($resp, hash("sha512", $_SESSION["valaszok"][1]));
			array_push($resp, hash("sha512", $_SESSION["valaszok"][2]));
			array_push($resp, hash("sha512", $_SESSION["valaszok"][0]));
			array_push($resp, hash("sha512", $_SESSION["valaszok"][3]));
			array_push($resp, hash("sha512", $_SESSION["valaszok_shuff"][0]));
			array_push($resp, hash("sha512", $_SESSION["valaszok_shuff"][1]));
			array_push($resp, hash("sha512", $_SESSION["valaszok_shuff"][2]));
			array_push($resp, hash("sha512", $_SESSION["valaszok_shuff"][3]));
			
		}
		elseif($_POST["validated"] == 2)
		{
			array_push($resp, "ok");
			array_push($resp, hash("sha512", $_SESSION["valaszok"][1]));
			array_push($resp, hash("sha512", $_SESSION["valaszok"][2]));
			array_push($resp, hash("sha512", $_SESSION["valaszok"][0]));
			array_push($resp, hash("sha512", $_SESSION["valaszok"][3]));
			array_push($resp, hash("sha512", $_SESSION["valaszok_shuff"][1]));
			array_push($resp, hash("sha512", $_SESSION["valaszok_shuff"][0]));
			array_push($resp, hash("sha512", $_SESSION["valaszok_shuff"][2]));
			array_push($resp, hash("sha512", $_SESSION["valaszok_shuff"][3]));
		}
		elseif($_POST['validated'] == 3)
		{
			array_push($resp, "ok");
			array_push($resp, hash("sha512", $_SESSION["valaszok"][1]));
			array_push($resp, hash("sha512", $_SESSION["valaszok"][2]));
			array_push($resp, hash("sha512", $_SESSION["valaszok"][0]));
			array_push($resp, hash("sha512", $_SESSION["valaszok"][3]));
			array_push($resp, hash("sha512", $_SESSION["valaszok_shuff"][2]));
			array_push($resp, hash("sha512", $_SESSION["valaszok_shuff"][0]));
			array_push($resp, hash("sha512", $_SESSION["valaszok_shuff"][1]));
			array_push($resp, hash("sha512", $_SESSION["valaszok_shuff"][3]));
		}
		elseif($_POST['validated'] == 4)
		{
			array_push($resp, "ok");
			array_push($resp, hash("sha512", $_SESSION["valaszok"][1]));
			array_push($resp, hash("sha512", $_SESSION["valaszok"][2]));
			array_push($resp, hash("sha512", $_SESSION["valaszok"][0]));
			array_push($resp, hash("sha512", $_SESSION["valaszok"][3]));
			array_push($resp, hash("sha512", $_SESSION["valaszok_shuff"][3]));
			array_push($resp, hash("sha512", $_SESSION["valaszok_shuff"][1]));
			array_push($resp, hash("sha512", $_SESSION["valaszok_shuff"][2]));
			array_push($resp, hash("sha512", $_SESSION["valaszok_shuff"][0]));
			
		}
		echo json_encode($resp);
	}
}
else
{
	require_once("../error.php");
}
	
}

?>
