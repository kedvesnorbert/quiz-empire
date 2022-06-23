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
		if(!$_POST['my_comment'] || empty($_POST['my_comment']))
		{
			echo json_encode(array("resp"=>"Please write your comment!"));
		}
		if(strlen($_POST['my_comment'])<5)
		{
			echo json_encode(array("resp"=>"Your comment's length must be minimum 5"));
		}
		if(strlen($_POST['my_comment'])>1500)
		{
			echo json_encode(array("resp"=>"Your comment's length must be maximum 1500"));
		}
		if(!$_POST['q_number'] || empty($_POST['q_number']))
		{
			echo json_encode(array("resp"=>"No quiz detected!"));
		}
		if(!preg_match("/^[0-9]+$/", $_POST['q_number']) || $_POST['q_number'] < 1)
		{
			echo json_encode(array("resp"=>"No quiz detected!"));
		}
		
		if($_POST['my_comment'] && !empty($_POST['my_comment']) && strlen($_POST['my_comment'])>=5 && strlen($_POST['my_comment'])<=1500 && $_POST['q_number'] && !empty($_POST['q_number']) && preg_match("/^[0-9]+$/", $_POST['q_number']) && $_POST['q_number'] >= 1)
		{
			if(logoff_ajax()== 0)
			{
				$con = connect();
				mysqli_query($con, "SET	@p_message");
				mysqli_query($con, "CALL insert_quiz_comment('" . mysqli_real_escape_string($con, $_POST['q_number']) . "', '" . mysqli_real_escape_string($con, $_SESSION['user']) . "', '" . mysqli_real_escape_string($con, $_POST['my_comment']) . "', @p_message)");
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
			else
			{
				echo json_encode(array("resp"=>err_session_timeout()));
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