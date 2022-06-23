<?php
session_start();

function validateDate($date, $format = 'Y-m-d H:i:s')
{
    $d = DateTime::createFromFormat($format, $date);
    return $d && $d->format($format) === $date;
}

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
		if(isset($_POST['j_comment']) && !empty($_POST['j_comment']) && strlen($_POST['j_comment']) <= 1500 && isset($_POST['j_quiz']) && !empty($_POST['j_quiz']) && preg_match("/^[0-9]+$/", $_POST['j_quiz']) && $_POST['j_quiz'] >= 1 && isset($_POST['j_date']) && !empty($_POST['j_date']) && validateDate($_POST['j_date']) == true && logoff_ajax()== 0)
		{
			$con = connect();
			mysqli_query($con, "SET	@p_message");
			mysqli_query($con, "CALL delete_quiz_comment('" . mysqli_real_escape_string($con, $_SESSION['user']) . "', '" . mysqli_real_escape_string($con, $_POST['j_quiz']) . "', '" . mysqli_real_escape_string($con, $_POST['j_comment']) . "', '" . mysqli_real_escape_string($con, $_POST['j_date']) . "', @p_message)");
			$q = "SELECT @p_message AS p_message";
			$res = mysqli_query($con, $q);
			$row = mysqli_fetch_assoc($res);
			mysqli_close($con);
			$kiir = $row['p_message'];
			
			if(empty($kiir))
			{
				echo json_encode(array("resp"=>"1"));
			}
			else
			{
				echo json_encode(array("resp"=>"$kiir"));
			}
		}
		elseif(logoff_ajax()==-1)
		{
			echo json_encode(array("resp"=>err_session_timeout()));
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