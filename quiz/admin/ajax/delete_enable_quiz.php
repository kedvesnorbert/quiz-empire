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
require_once("../../includes/responses.php");
require_once("sessiontimeoutadmin.php");

if (isset($_SERVER['HTTP_X_REQUESTED_WITH']) && ($_SERVER['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest')) 
{
    if(adminlogoff_ajax()== -1)
    {
        echo json_encode(array("resp"=>err_session_timeout()));
    }
    elseif(!superadmin())
    {
        echo json_encode(array("resp"=>"Ez a beállítás csak a SzuperAdmin ranggal érhető el!"));
    }
    elseif(!isset($_POST['p_quizid']) || !preg_match("/^[0-9]+$/", $_POST["p_quizid"]) || $_POST["p_quizid"] < 1 )
    {
        echo json_encode(array("resp"=>"Helytelen érték: p_quizid!"));
    }
    elseif(!isset($_POST['p_reason']) || strlen($_POST["p_reason"]) < 5 || strlen($_POST["p_reason"]) > 150)
    {
        echo json_encode(array("resp"=>"Helytelen érték: p_reason!"));
    }
    elseif(!isset($_POST['p_action']) || !preg_match("/^[0-9]+$/", $_POST["p_action"]) || $_POST["p_action"] < 0  || $_POST['p_action'] > 1)
    {
        echo json_encode(array("resp"=>"Helytelen érték: p_action!"));
    }
    else
    {
        $con = connect();
        if(!$con)
        {
            die(err_db());
        }
        $res = mysqli_query($con, "SELECT delete_enable_quiz('" . mysqli_real_escape_string($con, $_POST['p_quizid']) . "', '" . mysqli_real_escape_string($con, $_SESSION['adminuser']) . "', '" . mysqli_real_escape_string($con, $_POST['p_reason']) . "', '" . mysqli_real_escape_string($con, $_POST['p_action']) . "') AS response");
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
	require_once("../../error.php");
}

	
}


?>
