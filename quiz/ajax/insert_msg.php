<?php
session_start();

require_once("../db/db_connect.php");
require_once("sessiontimeout.php");
require_once("../includes/responses.php");
require_once("../db/db_chat.php");
require_once("../view/view_chat.php");

if(!isset($_SESSION['user']))
{
    $_SESSION = array();
	session_destroy();
	header("location: ../login.php"); 
}
else
{
	function stringSplitWords($s)
	{   
		$newword = "";
		$ary = explode(' ', $s);
		foreach($ary as $str)
		{
			if(strlen($str)>30)
			{
				$newword = $newword . chunk_split($str, 30, " ");
			}
			else
			{
				$newword = $newword . " " . $str;
			}
		}	
		return $newword; 
	}

	if(!isset($_GET['msg']) || strlen($_GET['msg']) <= 0 || strlen($_GET['msg'])>2000)
	{
		echo "Az üzenet hossza maximum 2000 karakter lehet!";
	}
	elseif(!isset($_GET["groupid"]) || !preg_match("/^[0-9]+$/", $_GET["groupid"]) || $_GET["groupid"] <= 0)
	{
		echo "Hibás csoport azonosító!";
	}
	elseif(logoff_ajax()==-1)
	{
		echo err_session_timeout();
	}
	else
	{		
		$con = connect();
		mysqli_query($con, "SET @p_response");
		mysqli_query($con, "CALL insert_chatmsg('" . mysqli_real_escape_string($con, $_SESSION['user_id']) . "', '" . mysqli_real_escape_string($con, $_GET["groupid"]) . "', '" . mysqli_real_escape_string($con, strip_tags(stringSplitWords($_GET["msg"]))) . "', @p_response)");
		$q = "SELECT @p_response AS p_response";
		$kiir = "";
		$res = mysqli_query($con, $q);
		mysqli_close($con);
		$row = mysqli_fetch_assoc($res);
		$kiir = $row['p_response'];
		
		if(strlen($kiir)< 2)
		{
			show_chatlogs($_GET["groupid"]);
		}
		else
		{
			echo $kiir;
		}
	}
}

?>