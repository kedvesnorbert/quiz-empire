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
	require_once("sessiontimeout.php");
	require_once("../includes/responses.php");
	
	if (isset($_SERVER['HTTP_X_REQUESTED_WITH']) && ($_SERVER['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest')) 
	{
		if(isset($_POST['pw']) && !empty($_POST['pw']) && strlen($_POST['pw']) <= 100)
		{
			$mindenok = true;
			if(logoff_ajax()==-1)
			{
				echo json_encode(array("resp"=>err_session_timeout()));
				$mindenok = false;
			}
			elseif(!preg_match("/^(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{6,100}$/", $_POST['pw']) || !preg_match("/^\S*$/", $_POST['pw']))
			{
				echo json_encode(array("resp"=>"A jelszó tartalmazzon kis-és nagybetűket, legalább 1 számjegyet és ne legyen benne szóköz!!!"));
				$mindenok = false;
			}
			if($mindenok == true)
			{
				$regij = hash("sha512", $_POST["pw"]);
				
				$con = connect();
				$res = mysqli_query($con, "SELECT delete_account('" . mysqli_real_escape_string($con, $_SESSION['user_id']) . "', '" . mysqli_real_escape_string($con, $_SESSION['user_id']) . "', 'Saját fiók törlése', '" . mysqli_real_escape_string($con, $regij) . "', 1) AS response");
				mysqli_close($con);
				if(!$res)
				{
					die(err_db());
				}
				$row = mysqli_fetch_assoc($res);
				$kiir = $row['response'];
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