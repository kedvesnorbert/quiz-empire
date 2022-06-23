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
		if(isset($_POST['pw1']) && !empty($_POST['pw1']) && strlen($_POST['pw1']) <= 100 && isset($_POST['pw2']) && !empty($_POST['pw2']) && strlen($_POST['pw2']) <= 100 && isset($_POST['pw']) && !empty($_POST['pw']) && strlen($_POST['pw']) <= 100)
		{
			$mindenok = true;
			if(logoff_ajax()==-1)
			{
				echo json_encode(array("resp"=>err_session_timeout()));
				$mindenok = false;
			}
			elseif($_POST['pw1'] == '' || $_POST['pw2'] == '' || $_POST['pw'] == '' || strlen($_POST['pw1'])< 6 || strlen($_POST['pw1'])>100)
			{
				echo json_encode(array("resp"=>"Minden mezőt kötelező kitölteni! \nA jelszó hossza 6 és 100 karakter között kell legyen!"));
				$mindenok = false;
			}
			elseif ($_POST["pw1"] != $_POST["pw2"])
			{
				echo json_encode(array("resp"=>"Nem talál a két jelszó!!"));
				$mindenok = false;
			}
			elseif(!preg_match("/^(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{6,100}$/", $_POST['pw1']) || !preg_match("/^\S*$/", $_POST['pw1']))
			{
				echo json_encode(array("resp"=>"A jelszó tartalmazzon kis-és nagybetűket, legalább 1 számjegyet és ne legyen benne szóköz!!!"));
				$mindenok = false;
			}
			if($mindenok == true)
			{
				$uj1 = hash("sha512", $_POST["pw1"]);
				$uj2 = hash("sha512", $_POST["pw2"]);
				$regij = hash("sha512", $_POST["pw"]);
				
				$con = connect();
				mysqli_query($con, "SET	@p_response");
				mysqli_query($con, "CALL change_password('" . mysqli_real_escape_string($con, $_SESSION['user']) . "', '" . mysqli_real_escape_string($con, $regij) . "', '" . mysqli_real_escape_string($con, $uj1) . "', '" . mysqli_real_escape_string($con, $uj2) . "', @p_response)");
				$q = "SELECT @p_response AS p_response";
				$res = mysqli_query($con, $q);
				$row = mysqli_fetch_assoc($res);
				mysqli_close($con);
				$kiir = $row['p_response'];
				echo json_encode(array("resp"=>"$kiir"));
			}
			
		}
		else
		{
			echo json_encode(array("resp"=>err_missing_data()));
		}
	}
	else
	{
		require_once("../error.php");
	}

}
?>