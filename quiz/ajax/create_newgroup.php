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
	if(!isset($_POST['name_group']) || strlen($_POST['name_group'])< 5 || strlen($_POST['name_group'])>25)
	{
		echo json_encode(array("resp"=>"A csoport neve 5-25 karakter legyen!"));
	}
	elseif(!isset($_POST['group_whocaninvite']) || !preg_match("/^[0-9]+$/", $_POST["group_whocaninvite"]) || $_POST["group_whocaninvite"] < 0 || $_POST["group_whocaninvite"] > 1)
	{
		echo json_encode(array("resp"=>"Hibás adat a további tagok felvétele mezőnél!"));
	}
	elseif(!isset($_POST['group_invitemembers']))
	{
		echo json_encode(array("resp"=>"Nem választottál ki senkit a csoportba!"));
	}
	elseif(logoff_ajax()==-1)
	{
		echo json_encode(array("resp"=>err_session_timeout()));
	}
	else
	{
		if(isset($_POST['group_invitemembers']) && is_array($_POST['group_invitemembers']))
		{
			$_POST['group_invitemembers'] = implode(',',$_POST['group_invitemembers']);
		}
		else
		{
			$_POST['group_invitemembers'] = "";
		}
		
		$con = connect();
		mysqli_query($con, "SET @p_response");
		mysqli_query($con, "CALL create_new_chatgroup('" . mysqli_real_escape_string($con, $_POST['name_group']) . "', '" . mysqli_real_escape_string($con, $_SESSION['user_id']) . "', '" . mysqli_real_escape_string($con, $_POST['group_whocaninvite']) . "', '" . mysqli_real_escape_string($con, $_POST['group_invitemembers']) . "', @p_response)");
		$q = "SELECT @p_response AS p_response";
		$res = mysqli_query($con, $q);
		mysqli_close($con);	
		$row = mysqli_fetch_assoc($res);
		$kiir = $row['p_response'];
		echo json_encode(array("resp"=>"$kiir"));
	}
}
else
{
	require_once("../error.php");
}
}
?>